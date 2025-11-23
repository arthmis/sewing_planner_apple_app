use std::collections::HashMap;
use std::sync::Arc;

use actix_session::storage::LoadError;
use actix_session::storage::SessionStore;
use actix_session::storage::generate_session_key;
use anyhow::anyhow;
use async_lock::Mutex;
use diesel::SqliteConnection;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use diesel_async::sync_connection_wrapper::SyncConnectionWrapper;
use serde::Deserialize;
use serde::Serialize;

type SessionState = std::collections::HashMap<String, String>;

#[derive(Clone)]
pub struct SqliteSessionStore {
    conn: Arc<Mutex<SyncConnectionWrapper<SqliteConnection>>>,
}

#[derive(Queryable, Selectable, Insertable)]
#[diesel(table_name = crate::schema::sessions)]
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
#[derive(Serialize, Deserialize)]
pub struct UserSession {
    id: String,
    data: Vec<u8>,
    expires: i32,
}

impl SqliteSessionStore {
    pub fn new(conn: SqliteConnection) -> Self {
        let conn = SyncConnectionWrapper::new(conn);
        SqliteSessionStore {
            conn: Arc::new(Mutex::new(conn)),
        }
    }
}

impl SessionStore for SqliteSessionStore {
    async fn load(
        &self,
        session_key: &actix_session::storage::SessionKey,
    ) -> Result<Option<SessionState>, LoadError> {
        use crate::schema::sessions::*;

        let result = {
            let mut conn = self.conn.lock().await;
            let result: UserSession = match table
                .filter(id.eq(session_key.as_ref()))
                .select(UserSession::as_select())
                .first(&mut conn)
                .await
            {
                Ok(session) => session,
                Err(err) => {
                    return Err(LoadError::Other(
                        anyhow!("failed to load session").context(err),
                    ));
                }
            };
            result
        };

        let session_state: HashMap<String, String> = serde_json::from_slice(&result.data).unwrap();

        Ok(Some(session_state))
    }

    async fn save(
        &self,
        session_state: SessionState,
        // TODO: add handling for ttl
        _ttl: &actix_web::cookie::time::Duration,
    ) -> Result<actix_session::storage::SessionKey, actix_session::storage::SaveError> {
        use crate::schema::sessions::*;

        let session_key = generate_session_key();
        let session_state = match serde_json::to_vec(&session_state) {
            Ok(state) => state,
            Err(err) => {
                return Err(actix_session::storage::SaveError::Other(
                    anyhow!("failed to serialize session state to store in sqlite").context(err),
                ));
            }
        };

        let user_session = UserSession {
            id: session_key.as_ref().to_string(),
            data: session_state,
            expires: 1_000,
        };

        let mut conn = self.conn.lock().await;
        match diesel::insert_into(table)
            .values(&user_session)
            .execute(&mut conn)
            .await
        {
            Ok(count) => debug_assert!(count == 1),
            Err(err) => {
                return Err(actix_session::storage::SaveError::Serialization(
                    anyhow!("failed to save session to sqlite").context(err),
                ));
            }
        }

        Ok(session_key)
    }

    async fn update(
        &self,
        session_key: actix_session::storage::SessionKey,
        session_state: SessionState,
        // TODO: deal with ttl
        _ttl: &actix_web::cookie::time::Duration,
    ) -> Result<actix_session::storage::SessionKey, actix_session::storage::UpdateError> {
        use crate::schema::sessions::*;

        let session_state = match serde_json::to_vec(&session_state) {
            Ok(state) => state,
            Err(err) => {
                return Err(actix_session::storage::UpdateError::Other(
                    anyhow!("failed to serialize session state to update in sqlite").context(err),
                ));
            }
        };

        let mut conn = self.conn.lock().await;
        match diesel::update(table.find(id))
            .set((data.eq(session_state), expires.eq(1000)))
            .execute(&mut conn)
            .await
        {
            Ok(count) => {
                debug_assert!(count == 1)
            }
            Err(err) => {
                return Err(actix_session::storage::UpdateError::Other(
                    anyhow!("failed to update session in sqlite").context(err),
                ));
            }
        }

        Ok(session_key)
    }

    async fn delete(
        &self,
        session_key: &actix_session::storage::SessionKey,
    ) -> Result<(), anyhow::Error> {
        use crate::schema::sessions::*;

        let mut conn = self.conn.lock().await;
        match diesel::delete(table.filter(id.eq(session_key.as_ref())))
            .execute(&mut conn)
            .await
        {
            Ok(num_deleted) => {
                debug_assert!(num_deleted == 1);
            }
            Err(err) => {
                return Err(anyhow!("failed to delete session from sqlite").context(err));
            }
        };

        Ok(())
    }

    async fn update_ttl(
        &self,
        session_key: &actix_session::storage::SessionKey,
        ttl: &actix_web::cookie::time::Duration,
    ) -> Result<(), anyhow::Error> {
        Ok(())
    }
}
