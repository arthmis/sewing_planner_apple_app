use bytestring::ByteString;
use event_database::{CreateProjectData, EventDb};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Event {
    id: String,
    data: EventData,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum EventData {
    CreateProject(CreateProjectData),
}

pub fn deserialize_event(event: ByteString) -> Result<Event, serde_json::Error> {
    let data = serde_json::from_slice(event.as_bytes())?;
    Ok(Event {
        id: uuid::Uuid::new_v4().to_string(),
        data,
    })
}

pub async fn handle_event<T>(user_id: i32, event: Event, db: &mut T) -> Result<(), T::Error>
where
    T: EventDb,
    T::Error: std::error::Error,
{
    dbg!(&event);
    match event.data {
        EventData::CreateProject(data) => db.handle_create_project(data).await,
    }
}
