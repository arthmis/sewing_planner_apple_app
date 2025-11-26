use argon2::{
    Argon2, PasswordHash, PasswordHasher, PasswordVerifier,
    password_hash::{SaltString, rand_core::OsRng},
};
use snafu::prelude::*;

#[derive(Debug, Snafu)]
#[snafu(display("Failed to generate password hash"))]
pub struct GenerateHashError {
    source: argon2::password_hash::Error,
    #[snafu(implicit)]
    location: snafu::Location,
}

pub fn generate_password_hash(password: &str) -> Result<String, GenerateHashError> {
    let argon = Argon2::default();

    let salt = SaltString::generate(&mut OsRng);
    let password = argon
        .hash_password(password.as_bytes(), &salt)
        .context(GenerateHashSnafu {})?
        .to_string();

    return Ok(password);
}

pub fn compare_passwords(password: &str, password_hash: &str) -> PasswordVerify {
    let argon = Argon2::default();
    let parsed_hash = match PasswordHash::new(&password_hash) {
        Ok(hash) => hash,
        // TODO: add logging
        Err(_) => return PasswordVerify::NoMatch,
    };

    let result = match argon.verify_password(password.as_bytes(), &parsed_hash) {
        Ok(_) => PasswordVerify::Match,
        Err(_) => PasswordVerify::NoMatch,
    };

    result
}

pub enum PasswordVerify {
    Match,
    NoMatch,
}
