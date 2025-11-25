use actix_session::Session;
use actix_web::{Error, post, web};
use diesel::ExpressionMethods;
use diesel::Insertable;
use diesel::QueryDsl;
use diesel::Queryable;
use diesel::Selectable;
use diesel::SelectableHelper;
use diesel::deserialize::{self, FromSql};
use diesel::serialize::{self, Output, ToSql};
use diesel::sql_types::Text;
use diesel_async::AsyncPgConnection;
use diesel_async::RunQueryDsl;
use diesel_async::pg;
use diesel_async::pooled_connection::deadpool::Pool;
use email_address::{EmailAddress, Options};
use serde::Deserialize;
use serde::Serialize;
use std::io::Write;

use crate::db::{DB, Database};

#[derive(
    Debug,
    Clone,
    Serialize,
    Deserialize,
    diesel::expression::AsExpression,
    diesel::deserialize::FromSqlRow,
)]
#[diesel(sql_type = Text)]
pub struct Email(EmailAddress);

impl FromSql<Text, diesel::pg::Pg> for Email {
    fn from_sql(bytes: diesel::pg::PgValue) -> deserialize::Result<Self> {
        let text = <String as FromSql<Text, diesel::pg::Pg>>::from_sql(bytes)?;
        EmailAddress::parse_with_options(&text, Options::default())
            .map(Email)
            .map_err(|_| format!("Invalid email address: {}", text).into())
    }
}

impl ToSql<Text, diesel::pg::Pg> for Email {
    fn to_sql<'b>(&'b self, out: &mut Output<'b, '_, diesel::pg::Pg>) -> serialize::Result {
        let email_str = self.0.to_string();
        out.write_all(email_str.as_bytes())?;
        Ok(serialize::IsNull::No)
    }
}

impl Email {
    pub fn as_str(&self) -> &str {
        self.0.as_str()
    }
}

#[derive(Deserialize)]
struct SignupCredentials {
    email: String,
    password: String,
}

struct UserCredentials {
    email: Email,
    password: String,
}

impl TryFrom<SignupCredentials> for UserCredentials {
    type Error = anyhow::Error;

    fn try_from(value: SignupCredentials) -> Result<Self, Self::Error> {
        let email = EmailAddress::parse_with_options(&value.email, Options::default());

        let email = match email {
            Ok(email) => Email(email),
            Err(_) => {
                return Err(
                    anyhow::anyhow!("Invalid email address").context("Failed to parse email")
                );
            }
        };

        if value.password.is_empty() {
            return Err(anyhow::anyhow!("Email and password cannot be empty"));
        }

        Ok(UserCredentials {
            email,
            password: value.password,
        })
    }
}

#[derive(Insertable, Debug)]
#[diesel(table_name = crate::schema::users)]
pub struct UserInput {
    email: Email,
    password_hash: String,
}

#[derive(Debug, Deserialize)]
struct UserLogin {
    email: Email,
    password: String,
}

#[derive(Queryable, Insertable, Selectable, Debug, Serialize)]
#[diesel(table_name = crate::schema::users)]
pub struct User {
    id: i32,
    email: Email,
    password_hash: String,
}

type DbPool = Pool<AsyncPgConnection>;

#[post("/signup")]
async fn signup_endpoint(
    db_pool: web::Data<DbPool>,
    web::Json(credentials): web::Json<SignupCredentials>,
) -> actix_web::Result<(), actix_web::Error> {
    let mut conn = db_pool.get().await.unwrap();
    let db = DB::new(&mut conn).unwrap();

    signup(credentials, db).await.unwrap();
    Ok(())
}

async fn signup(credentials: SignupCredentials, mut db: impl Database) -> Result<(), Error> {
    let credentials = UserCredentials::try_from(credentials).unwrap();
    let hash = auth_utils::generate_password_hash(&credentials.password).unwrap();
    let user = UserInput {
        email: credentials.email,
        password_hash: hash,
    };

    db.create_user(user).await.unwrap();

    Ok(())
}

#[post("/login")]
async fn login(
    db_pool: web::Data<DbPool>,
    web::Json(credentials): web::Json<UserLogin>,
    session: Session,
) -> actix_web::Result<(), Error> {
    let mut conn = db_pool.get().await.unwrap();
    let user = get_user(&credentials.email, &mut conn).await.unwrap();
    let result = auth_utils::compare_passwords(&credentials.password, &user.password_hash).unwrap();

    if let auth_utils::PasswordVerify::NoMatch = result {
        return Err(actix_web::error::ErrorUnauthorized("Invalid credentials"));
    }

    dbg!(user.id);
    let _user_id = session.insert("user_id", user.id).unwrap();
    let session_user_id: i32 = session.get("user_id").unwrap().unwrap();
    dbg!(session_user_id);
    Ok(())
}

async fn get_user(
    user_email: &Email,
    conn: &mut pg::AsyncPgConnection,
) -> Result<User, diesel::result::Error> {
    use crate::schema::users::dsl::*;

    let user_id: User = users
        .filter(email.eq(&user_email.as_str()))
        .select(User::as_select())
        .get_result(conn)
        .await
        .unwrap();

    Ok(user_id)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::db::Database;

    pub struct MockDatabase {
        get_user_fn: Box<dyn Fn(&Email) -> Result<User, anyhow::Error> + Send + Sync>,
        create_user_fn: Box<dyn Fn(UserInput) -> Result<(), anyhow::Error> + Send + Sync>,
    }

    impl MockDatabase {
        pub fn builder() -> MockDatabaseBuilder {
            MockDatabaseBuilder::default()
        }
    }

    pub struct MockDatabaseBuilder {
        get_user_fn: Option<Box<dyn Fn(&Email) -> Result<User, anyhow::Error> + Send + Sync>>,
        create_user_fn: Option<Box<dyn Fn(UserInput) -> Result<(), anyhow::Error> + Send + Sync>>,
    }

    impl Default for MockDatabaseBuilder {
        fn default() -> Self {
            Self {
                get_user_fn: None,
                create_user_fn: None,
            }
        }
    }

    impl MockDatabaseBuilder {
        pub fn with_get_user<F>(mut self, f: F) -> Self
        where
            F: Fn(&Email) -> Result<User, anyhow::Error> + Send + Sync + 'static,
        {
            self.get_user_fn = Some(Box::new(f));
            self
        }

        pub fn with_create_user<F>(mut self, f: F) -> Self
        where
            F: Fn(UserInput) -> Result<(), anyhow::Error> + Send + Sync + 'static,
        {
            self.create_user_fn = Some(Box::new(f));
            self
        }

        pub fn build(self) -> MockDatabase {
            MockDatabase {
                get_user_fn: self.get_user_fn.unwrap_or_else(|| {
                    Box::new(|_| Err(anyhow::anyhow!("get_user not configured")))
                }),
                create_user_fn: self.create_user_fn.unwrap_or_else(|| Box::new(|_| Ok(()))),
            }
        }
    }

    impl Database for MockDatabase {
        async fn get_user(&mut self, user_email: &Email) -> Result<User, anyhow::Error> {
            (self.get_user_fn)(user_email)
        }

        async fn create_user(&mut self, user: UserInput) -> Result<(), anyhow::Error> {
            (self.create_user_fn)(user)
        }
    }

    #[actix_web::test]
    async fn test_create_user() {
        let mock_db = MockDatabase::builder()
            .with_create_user(|_user| Ok(()))
            .build();

        let credentials = SignupCredentials {
            email: "test@example.com".to_string(),
            password: "password123".to_string(),
        };

        let result = signup(credentials, mock_db).await;
        assert!(result.is_ok());
    }

    // #[actix_rt::test]
    // async fn test_get_user() {
    //     let mut conn = db_pool.get().await.unwrap();
    //     let user = UserInput {
    //         email: "test@example.com".parse().unwrap(),
    //         password_hash: "password".to_string(),
    //     };

    //     create_user(user, &mut conn).await.unwrap();

    //     let user = get_user(&"test@example.com".parse().unwrap(), &mut conn).await.unwrap();
    //     assert_eq!(user.email, "test@example.com");
    // }
}
