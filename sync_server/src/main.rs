mod api;
mod db;
mod schema;

use actix_session::SessionMiddleware;
use actix_session::config::PersistentSession;
use actix_web::cookie::Key;
use actix_web::{App, HttpServer, web};
use base64::Engine;
use diesel::{Connection, SqliteConnection};
use diesel_async::AsyncPgConnection;
use diesel_async::pooled_connection::AsyncDieselConnectionManager;
use dotenvy::dotenv;

pub fn get_session_conn() -> SqliteConnection {
    let database_url = std::env::var("DATABASE_URL").unwrap_or("./sessions.db".to_string());
    SqliteConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}

pub async fn get_app_db_conn() -> AsyncDieselConnectionManager<AsyncPgConnection> {
    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or("postgres://postgres:postgres@localhost:7777".to_string());
    let config = AsyncDieselConnectionManager::<diesel_async::AsyncPgConnection>::new(database_url);
    return config;
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    let secret_key = std::env::var("COOKIE_SECRET_KEY").unwrap();
    let bytes = base64::engine::general_purpose::STANDARD
        .decode(secret_key)
        .unwrap();
    let secret_key = Key::from(&bytes);

    let session_store_conn = get_session_conn();
    let session_store = sqlite_session_store::SqliteSessionStore::new(session_store_conn);
    let session_store_clone = session_store.clone();
    // TODO: think about holding a handle to this within the server so it shuts down when the server shuts down
    let _session_deletion_task = actix_web::rt::spawn(async move {
        loop {
            let result = session_store_clone.delete_expired().await;
            if let Err(err) = result {
                // TODO: log the error
                eprintln!("Error deleting expired sessions: {}", err);
            }
            actix_web::rt::time::sleep(std::time::Duration::from_secs(100)).await;
        }
    });

    let config = get_app_db_conn().await;
    let pool = diesel_async::pooled_connection::deadpool::Pool::builder(config)
        .max_size(10)
        .build()
        .unwrap();

    HttpServer::new(move || {
        App::new()
            .wrap(
                SessionMiddleware::builder(session_store.clone(), secret_key.clone())
                    .cookie_secure(false)
                    .session_lifecycle(
                        PersistentSession::default()
                            .session_ttl(actix_web::cookie::time::Duration::new(60, 0)),
                    )
                    .build(),
            )
            .app_data(web::Data::new(pool.clone()))
            .service(api::hello)
            .service(api::signup_endpoint)
            .service(api::login)
    })
    .workers(1)
    .bind(("localhost", 8080))?
    .run()
    .await
}
