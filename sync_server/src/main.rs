mod schema;
mod sqlite_session_store;

use actix_session::{Session, SessionMiddleware};
use actix_web::cookie::Key;
use actix_web::{App, HttpResponse, HttpServer, Responder, get, post, web};
use diesel::{Connection, SqliteConnection};
use diesel_async::sync_connection_wrapper::SyncConnectionWrapper;

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}

pub fn establish_connection() -> SqliteConnection {
    // dotenv().ok();

    let database_url = std::env::var("DATABASE_URL").unwrap_or("./sessions.db".to_string());
    SqliteConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let secret_key = Key::generate();
    let session_store_conn = establish_connection();
    let session_store = sqlite_session_store::SqliteSessionStore::new(session_store_conn);

    HttpServer::new(move || {
        App::new()
            .wrap(SessionMiddleware::new(
                session_store.clone(),
                secret_key.clone(),
            ))
            .service(hello)
    })
    .workers(1)
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
