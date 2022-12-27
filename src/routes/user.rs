use super::fallbacks::error_landing;
use axum::{
    extract::{Query, State},
    http::StatusCode,
    Form, Json,
};
use serde::{Deserialize, Serialize};
use sqlx::{postgres::PgPool, types::chrono, Error};

#[derive(Deserialize)]
pub struct CreateUserForm {
    full_name: String,
    email: String,
    username: String,
}

#[derive(Serialize)]
pub struct LookupUser {
    user_id: i32,
}
#[derive(sqlx::Type)]
#[sqlx(transparent)]
pub struct UserId(i32);

#[derive(Deserialize)]
pub struct LookupUserForm {
    username: Option<String>,
    email: Option<String>,
}

pub async fn create_new_user(
    State(pool): State<PgPool>,
    form: Form<CreateUserForm>,
) -> Result<Json<LookupUser>, (StatusCode, String)> {
    let created = chrono::Utc::now().date_naive();

    let new_user = sqlx::query_as!(LookupUser,
        "INSERT INTO users.basic (full_name, email, username, created) VALUES ($1::varchar(256), $2::varchar(256), $3::varchar(15), $4::date) RETURNING user_id",
        form.full_name, form.email, form.username, created)
        .fetch_one(&pool)
        .await;

    match new_user {
        Ok(user) => Ok(Json(user)),
        Err(_) => Err(error_landing(
            "while creating user",
            StatusCode::CONFLICT,
            "warning",
        )),
    }
}

pub async fn lookup_username_or_email(
    State(pool): State<PgPool>,
    query: Query<LookupUserForm>,
) -> Result<Json<LookupUser>, (StatusCode, String)> {
    let detail;
    let value = if let Some(username) = query.username.clone() {
        detail = Some("username");
        Some(username)
    } else if let Some(email) = query.email.clone() {
        detail = Some("email");
        Some(email)
    } else {
        detail = None;
        None
    };

    if let Some(detail_name) = detail {
        let query = format!("SELECT user_id FROM users.basic WHERE {} = $1", detail_name);
        let result: Result<(UserId,), Error> = sqlx::query_as(&query)
            .bind(value.unwrap())
            .fetch_one(&pool)
            .await;

        result
            .map_err(|_| error_landing("user not found", StatusCode::NOT_FOUND, "warning"))
            .map(|u| Json(LookupUser { user_id: u.0 .0 }))
    } else {
        Err(error_landing(
            "malformed request",
            StatusCode::BAD_REQUEST,
            "fatal",
        ))
    }
}
