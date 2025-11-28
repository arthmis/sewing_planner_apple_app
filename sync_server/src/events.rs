use event_database::{CreateProjectData, EventDb};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Event {
    id: String,
    data: EventData,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum EventData {
    CreateProject(CreateProjectData),
}

async fn handle_event<T>(event: Event, mut db: T) -> Result<(), T::Error>
where
    T: EventDb,
    T::Error: std::error::Error,
{
    match event.data {
        EventData::CreateProject(data) => db.handle_create_project(data).await,
    }
}
