use actix_session::Session;
use actix_web::{Responder, get};

#[get("/")]
async fn signup(session: Session) -> impl Responder {
    // let user_id = session.insert("user_id", "hello").unwrap();
    let user_id: Option<String> = session.get("user_id").unwrap();
    // let user_id = session.get::<UserSession>("user_id").unwrap();
    // if let Some(user_id) = user_id {
    //     dbg!(user_id);
    //     HttpResponse::Ok().body(format!("Hello user {}", "user"))
    // } else {
    //     HttpResponse::Ok().body("Hello world!")
    // }
    "Hello"
}
