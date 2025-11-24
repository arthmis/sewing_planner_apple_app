use argon2::{
    Argon2, PasswordHash, PasswordHasher, PasswordVerifier,
    password_hash::{SaltString, rand_core::OsRng},
};

pub fn generate_password_hash(password: &str) -> Result<String, argon2::password_hash::Error> {
    let argon = Argon2::default();

    let salt = SaltString::generate(&mut OsRng);
    let password = argon.hash_password(password.as_bytes(), &salt)?.to_string();

    return Ok(password);
}

pub fn compare_passwords(
    password: &str,
    password_hash: &str,
) -> Result<PasswordVerify, argon2::password_hash::Error> {
    let argon = Argon2::default();
    let parsed_hash = PasswordHash::new(&password_hash)?;
    let result = match argon.verify_password(password.as_bytes(), &parsed_hash) {
        Ok(_) => PasswordVerify::Match,
        Err(_) => PasswordVerify::NoMatch,
    };

    Ok(result)
}

pub enum PasswordVerify {
    Match,
    NoMatch,
}
