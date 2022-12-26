use axum::{extract::State, http::StatusCode, Form};
use serde::{Deserialize, Serialize};
use sqlx::{postgres::PgPool, types::chrono};

use super::fallbacks::error_landing;

#[derive(Deserialize)]
pub struct CreateUserData {
    full_name: String,
    email: String,
    username: String
}

#[derive(Serialize)]
pub struct CreatedUser {
    user_id: String
}

pub async fn create_new_user(
    State(pool): State<PgPool>,
    form: Form<CreateUserData>
) -> Result<String, (StatusCode, String)> {
    let created = chrono::Utc::now().date_naive();
    
    let new_user = sqlx::query!(
        "INSERT INTO users.basic (full_name, email, username, created) VALUES ($1::varchar(256), $2::varchar(256), $3::varchar(15), $4::date) RETURNING user_id",
        form.full_name, form.email, form.username, created)
        .fetch_one(&pool)
        .await;

    match new_user {
        Ok(user) => Ok(user.user_id.to_string()),
        Err(error) => Err(error_landing(error))
    }
}