mod api;
mod db;
mod schema;

use actix_session::{Session, SessionMiddleware};
use actix_web::cookie::Key;
use actix_web::{App, HttpServer, Responder, get, web};
use diesel::{Connection, SqliteConnection};
use diesel_async::AsyncPgConnection;
use diesel_async::pooled_connection::AsyncDieselConnectionManager;

#[get("/")]
async fn hello(session: Session) -> impl Responder {
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
    "Hello"
}

pub fn get_session_conn() -> SqliteConnection {
    // dotenv().ok();

    let database_url = std::env::var("DATABASE_URL").unwrap_or("./sessions.db".to_string());
    SqliteConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}

pub async fn get_db_conn() -> AsyncDieselConnectionManager<AsyncPgConnection> {
    // dotenv().ok();

    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or("postgres://postgres:postgres@localhost:7777".to_string());
    let config = AsyncDieselConnectionManager::<diesel_async::AsyncPgConnection>::new(database_url);
    return config;
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let secret_key = Key::generate();
    let session_store_conn = get_session_conn();
    let session_store = sqlite_session_store::SqliteSessionStore::new(session_store_conn);
    let config = get_db_conn().await;

    let pool = diesel_async::pooled_connection::deadpool::Pool::builder(config)
        .max_size(10)
        .build()
        .unwrap();

    HttpServer::new(move || {
        App::new()
            .wrap(SessionMiddleware::new(
                session_store.clone(),
                secret_key.clone(),
            ))
            .app_data(web::Data::new(pool.clone()))
            .service(hello)
            .service(api::signup_endpoint)
            .service(api::login)
    })
    .workers(1)
    .bind(("localhost", 8080))?
    .run()
    .await
}
