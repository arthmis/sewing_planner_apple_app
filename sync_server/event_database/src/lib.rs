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

// #[cfg(test)]
// mod tests {
//     use super::*;

//     #[test]
//     fn it_works() {
//         let result = add(2, 2);
//         assert_eq!(result, 4);
//     }
// }
