use actix_session::{Session, SessionInsertError};
use actix_web::http::{StatusCode, header};
use actix_web::{HttpResponse, Responder, get, mime, post, web};
use actix_web::{HttpResponseBuilder, ResponseError};
use auth_utils::GenerateHashError;
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
use snafu::Location;
use snafu::ResultExt;
use snafu::prelude::*;
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
    type Error = SignupError;

    fn try_from(value: SignupCredentials) -> Result<Self, Self::Error> {
        let email = EmailAddress::parse_with_options(&value.email, Options::default())
            .context(InvalidEmailSnafu {})?;
        let email = Email(email);

        if value.password.is_empty() {
            return Err(SignupError::InvalidPassword);
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
) -> actix_web::Result<(), SignupError> {
    let mut conn = db_pool.get().await.unwrap();
    let db = DB::new(&mut conn).unwrap();

    signup(credentials, db).await?;

    Ok(())
}

#[derive(Debug, Snafu)]
pub enum SignupError {
    #[snafu(display("Invalid email"))]
    InvalidEmail {
        #[snafu(implicit)]
        location: Location,
        source: email_address::Error,
    },
    #[snafu(display("Invalid password"))]
    InvalidPassword,
    #[snafu(display("Create user failed"))]
    CreateUserFailed {
        #[snafu(implicit)]
        location: Location,
        source: diesel::result::Error,
    },
    #[snafu(display("Password hash error"))]
    PasswordHashError {
        #[snafu(implicit)]
        location: Location,
        source: GenerateHashError,
    },
}

impl ResponseError for SignupError {
    fn status_code(&self) -> actix_web::http::StatusCode {
        match self {
            SignupError::InvalidEmail { .. } => actix_web::http::StatusCode::BAD_REQUEST,
            SignupError::InvalidPassword => actix_web::http::StatusCode::BAD_REQUEST,
            SignupError::CreateUserFailed { .. } => {
                actix_web::http::StatusCode::INTERNAL_SERVER_ERROR
            }
            SignupError::PasswordHashError { .. } => {
                actix_web::http::StatusCode::INTERNAL_SERVER_ERROR
            }
        }
    }

    fn error_response(&self) -> actix_web::HttpResponse<actix_web::body::BoxBody> {
        let mut response_builder = HttpResponseBuilder::new(self.status_code());
        response_builder.insert_header((header::CONTENT_TYPE, mime::TEXT_PLAIN_UTF_8));
        let message = self.to_string();
        let response = response_builder.body(message);

        response
    }
}

async fn signup(credentials: SignupCredentials, mut db: impl Database) -> Result<(), SignupError> {
    let credentials = UserCredentials::try_from(credentials)?;
    let hash =
        auth_utils::generate_password_hash(&credentials.password).context(PasswordHashSnafu {})?;
    let user = UserInput {
        email: credentials.email,
        password_hash: hash,
    };

    db.create_user(user)
        .await
        .context(CreateUserFailedSnafu {})?;

    Ok(())
}

#[derive(Debug, Snafu)]
pub enum LoginError {
    #[snafu(display("Invalid email or password"))]
    InvalidCredentials,
    #[snafu(display("Internal server error. Please try again later."))]
    UserNotFound {
        #[snafu(implicit)]
        location: Location,
        source: diesel::result::Error,
    },
    #[snafu(display("Internal server error. Please try again later."))]
    SessionError {
        #[snafu(implicit)]
        location: Location,
        source: SessionInsertError,
    },
}

impl ResponseError for LoginError {
    fn status_code(&self) -> StatusCode {
        match self {
            LoginError::InvalidCredentials => StatusCode::OK,
            LoginError::UserNotFound { .. } | LoginError::SessionError { .. } => {
                StatusCode::INTERNAL_SERVER_ERROR
            }
        }
    }

    fn error_response(&self) -> actix_web::HttpResponse<actix_web::body::BoxBody> {
        let mut response_builder = HttpResponseBuilder::new(self.status_code());
        response_builder.insert_header((header::CONTENT_TYPE, mime::TEXT_PLAIN_UTF_8));

        let message = self.to_string();
        let response = response_builder.body(message);

        response
    }
}

#[post("/login")]
async fn login(
    db_pool: web::Data<DbPool>,
    web::Json(credentials): web::Json<UserLogin>,
    session: Session,
) -> actix_web::Result<(), LoginError> {
    let mut conn = db_pool.get().await.unwrap();
    let user = get_user(&credentials.email, &mut conn)
        .await
        .context(UserNotFoundSnafu)?;

    let result = auth_utils::compare_passwords(&credentials.password, &user.password_hash);
    if let auth_utils::PasswordVerify::NoMatch = result {
        return Err(LoginError::InvalidCredentials);
    }

    session.insert("user_id", user.id).context(SessionSnafu)?;
    Ok(())
}

#[get("/")]
pub async fn hello(session: Session) -> impl Responder {
    // let user_id = session.insert("user_id", "hello").unwrap();
    let user_id: Option<i32> = session.get("user_id").unwrap();
    dbg!(user_id);
    // let user_id = session.get::<UserSession>("user_id").unwrap();
    // if let Some(user_id) = user_id {
    //     dbg!(user_id);
    //     HttpResponse::Ok().body(format!("Hello user {}", "user"))
    // } else {
    //     HttpResponse::Ok().body("Hello world!")
    // }
    match user_id {
        Some(id) => HttpResponse::Ok().body(format!("Hello user {}", id)),
        None => HttpResponse::Ok().body("Hello world!"),
    }
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
        get_user_fn: Box<dyn Fn(&Email) -> Result<User, diesel::result::Error> + Send + Sync>,
        create_user_fn: Box<dyn Fn(UserInput) -> Result<(), diesel::result::Error> + Send + Sync>,
    }

    impl MockDatabase {
        pub fn builder() -> MockDatabaseBuilder {
            MockDatabaseBuilder::default()
        }
    }

    pub struct MockDatabaseBuilder {
        get_user_fn:
            Option<Box<dyn Fn(&Email) -> Result<User, diesel::result::Error> + Send + Sync>>,
        create_user_fn:
            Option<Box<dyn Fn(UserInput) -> Result<(), diesel::result::Error> + Send + Sync>>,
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
            F: Fn(&Email) -> Result<User, diesel::result::Error> + Send + Sync + 'static,
        {
            self.get_user_fn = Some(Box::new(f));
            self
        }

        pub fn with_create_user<F>(mut self, f: F) -> Self
        where
            F: Fn(UserInput) -> Result<(), diesel::result::Error> + Send + Sync + 'static,
        {
            self.create_user_fn = Some(Box::new(f));
            self
        }

        pub fn build(self) -> MockDatabase {
            MockDatabase {
                get_user_fn: self
                    .get_user_fn
                    .unwrap_or_else(|| Box::new(|_| Err(diesel::result::Error::NotFound))),
                create_user_fn: self.create_user_fn.unwrap_or_else(|| Box::new(|_| Ok(()))),
            }
        }
    }

    impl Database for MockDatabase {
        async fn get_user(&mut self, user_email: &Email) -> Result<User, diesel::result::Error> {
            (self.get_user_fn)(user_email)
        }

        async fn create_user(&mut self, user: UserInput) -> Result<(), diesel::result::Error> {
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
