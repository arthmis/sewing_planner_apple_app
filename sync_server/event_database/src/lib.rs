use diesel::ExpressionMethods;
use diesel_async::{RunQueryDsl, pg};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateProjectData {
    user_id: i32,
    project_id: i32,
    title: String,
}

pub trait EventDb {
    type Error;

    fn handle_create_project(
        &mut self,
        data: CreateProjectData,
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

    async fn handle_create_project(&mut self, data: CreateProjectData) -> Result<(), Self::Error> {
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
    use diesel_async::AsyncConnection;
    use diesel_migrations::{EmbeddedMigrations, MigrationHarness, embed_migrations};
    use testcontainers_modules::{postgres, testcontainers::runners::AsyncRunner};
    pub const MIGRATIONS: EmbeddedMigrations = embed_migrations!("../app_db/migrations");

    async fn start_db() -> String {
        let postgres_instance = postgres::Postgres::default().start().await.unwrap();

        let connection_string = format!(
            "postgres://postgres:postgres@{}:{}/postgres",
            postgres_instance.get_host().await.unwrap(),
            postgres_instance.get_host_port_ipv4(5432).await.unwrap()
        );

        connection_string
    }

    #[tokio::test]
    async fn add_project() {
        // let connection_string = start_db().await;
        let postgres_instance = postgres::Postgres::default().start().await.unwrap();

        let connection_string = format!(
            "postgres://postgres:postgres@{}:{}/postgres",
            postgres_instance.get_host().await.unwrap(),
            postgres_instance.get_host_port_ipv4(5432).await.unwrap()
        );
        {
            use diesel::PgConnection;
            use diesel::prelude::*;
            let mut sync_conn = PgConnection::establish(&connection_string).unwrap();
            sync_conn.run_pending_migrations(MIGRATIONS).unwrap();
        }
        let mut conn = pg::AsyncPgConnection::establish(&connection_string)
            .await
            .unwrap();
        let mut db = EventDatabase::new(&mut conn);

        let data = CreateProjectData {
            user_id: 1,
            project_id: 1,
            title: "Test Project".to_string(),
        };

        db.handle_create_project(data).await.unwrap();

        let mut conn = pg::AsyncPgConnection::establish(&connection_string)
            .await
            .unwrap();

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
