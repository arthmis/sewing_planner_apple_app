-- Your SQL goes here
CREATE TABLE sessions (
    id TEXT PRIMARY KEY NOT NULL,
    data BLOB NOT NULL,
    expires INTEGER NOT NULL
);
