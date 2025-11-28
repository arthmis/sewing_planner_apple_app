use crate::api::Email;
use crate::api::User;
use crate::api::UserInput;
use diesel::ExpressionMethods;
use diesel::QueryDsl;
use diesel::SelectableHelper;
use diesel::result::Error;
use diesel_async::RunQueryDsl;
use diesel_async::pg;

pub trait Database {
    async fn get_user(&mut self, user_email: &Email) -> Result<User, Error>;
    async fn create_user(&mut self, user: UserInput) -> Result<(), Error>;
    // fn update_user(&self, id: &str, email: &str, password: &str) -> Result<User, Error>;
    // fn delete_user(&self, id: &str) -> Result<(), Error>;
}

pub struct DB<'a> {
    conn: &'a mut pg::AsyncPgConnection,
}

impl<'a> DB<'a> {
    pub fn new(conn: &'a mut pg::AsyncPgConnection) -> Self {
        Self { conn }
    }
}

impl<'a> Database for DB<'a> {
    async fn get_user(&mut self, user_email: &Email) -> Result<User, Error> {
        use app_db::schema::users::dsl::*;

        let user_id: User = users
            .filter(email.eq(&user_email.as_str()))
            .select(User::as_select())
            .get_result(&mut self.conn)
            .await?;

        Ok(user_id)
    }

    async fn create_user(&mut self, user: UserInput) -> Result<(), Error> {
        use app_db::schema::users::dsl::*;

        // return Err(diesel::result::Error::DatabaseError(
        //     diesel::result::DatabaseErrorKind::ClosedConnection,
        //     Box::new("Database connection closed".to_string()),
        // ));

        let count = diesel::insert_into(users)
            .values(user)
            .execute(&mut self.conn)
            .await?;

        debug_assert!(count == 1);

        Ok(())
    }
}
