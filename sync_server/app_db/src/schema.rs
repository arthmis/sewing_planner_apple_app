// @generated automatically by Diesel CLI.

diesel::table! {
    projects (id) {
        id -> Int4,
        user_id -> Int4,
        project_id -> Int4,
        #[max_length = 255]
        title -> Varchar,
        completed -> Bool,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

diesel::table! {
    users (id) {
        id -> Int4,
        #[max_length = 255]
        email -> Varchar,
        #[max_length = 255]
        password_hash -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

diesel::joinable!(projects -> users (user_id));

diesel::allow_tables_to_appear_in_same_query!(projects, users,);
