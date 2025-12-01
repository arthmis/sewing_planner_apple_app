use diesel::ExpressionMethods;
use diesel_async::{RunQueryDsl, pg};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateProjectEventData {
    user_id: i32,
    project_id: i32,
    title: String,
}

pub trait EventDb {
    type Error;

    fn handle_create_project(
        &mut self,
        data: CreateProjectEventData,
    ) -> impl Future<Output = Result<(), Self::Error>>;
}

pub struct EventDatabase<'a> {
    conn: &'a mut pg::AsyncPgConnection,
}

impl<'a> EventDatabase<'a> {
    pub fn new(conn: &'a mut pg::AsyncPgConnection) -> Self {
        Self { conn }
    }
}

impl<'a> EventDb for EventDatabase<'a> {
    type Error = diesel::result::Error;

    async fn handle_create_project(&mut self, data: CreateProjectEventData) -> Result<(), Self::Error> {
        use app_db::schema::projects::dsl::*;

        let count = diesel::insert_into(projects)
            .values((
                user_id.eq(data.user_id),
                project_id.eq(data.project_id),
                title.eq(data.title),
                completed.eq(false),
                created_at.eq(chrono::Utc::now()),
                updated_at.eq(chrono::Utc::now()),
            ))
            .execute(self.conn)
            .await?;

        debug_assert_eq!(count, 1);

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use diesel::QueryDsl;
    use diesel_async::{AsyncConnection, AsyncPgConnection, RunQueryDsl};
    use diesel_migrations::{EmbeddedMigrations, MigrationHarness, embed_migrations};
    use testcontainers_modules::{
        postgres::{self, Postgres},
        testcontainers::{ContainerAsync, runners::AsyncRunner},
    };
    pub const MIGRATIONS: EmbeddedMigrations = embed_migrations!("../app_db/migrations");

    async fn start_postgres() -> (ContainerAsync<Postgres>, AsyncPgConnection) {
        let postgres_instance_handle = postgres::Postgres::default().start().await.unwrap();

        let connection_string =
            connection_string_from_postgres_instance(&postgres_instance_handle).await;
        run_migrations(connection_string.clone());

        let conn = pg::AsyncPgConnection::establish(&connection_string)
            .await
            .unwrap();
        (postgres_instance_handle, conn)
    }

    async fn connection_string_from_postgres_instance(
        container: &ContainerAsync<Postgres>,
    ) -> String {
        format!(
            "postgres://postgres:postgres@{}:{}/postgres",
            container.get_host().await.unwrap(),
            container.get_host_port_ipv4(5432).await.unwrap()
        )
    }

    fn run_migrations(connection_string: String) {
        use diesel::PgConnection;
        use diesel::prelude::*;
        let mut sync_conn = PgConnection::establish(&connection_string).unwrap();
        sync_conn.run_pending_migrations(MIGRATIONS).unwrap();
    }

    async fn seed_one_project(conn: &mut AsyncPgConnection) {
        use api::{Email, UserInput};
        use app_db::schema::users::dsl::*;
        let now = chrono::Utc::now();
        let user_input = UserInput::new(
            Email::new("test@example.com").unwrap(),
            "password".to_string(),
            now,
            now,
        );

        diesel::insert_into(users)
            .values(user_input)
            .execute(conn)
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn add_project() {
        let (_postgres_instance_handle, mut conn) = start_postgres().await;
        seed_one_project(&mut conn).await;

        let mut db = EventDatabase::new(&mut conn);

        let data = CreateProjectEventData {
            user_id: 1,
            project_id: 1,
            title: "Test Project".to_string(),
        };
        db.handle_create_project(data).await.unwrap();

        use app_db::schema::projects::dsl::*;

        let result: String = projects
            .filter(title.eq("Test Project"))
            .select(title)
            .get_result(&mut conn)
            .await
            .unwrap();
        assert_eq!(result, "Test Project");
    }
}
