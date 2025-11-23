// @generated automatically by Diesel CLI.

diesel::table! {
    sessions (id) {
        id -> Text,
        data -> Binary,
        expires -> Integer,
    }
}
