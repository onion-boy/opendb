use super::fallbacks::error_landing;
use axum::{
    extract::{Query, State},
    http::StatusCode,
    Form, Json,
};
use serde::{Deserialize, Serialize};
use sqlx::{
    postgres::PgPool,
    types::chrono::{self, NaiveDate},
};

#[derive(Deserialize)]
pub struct CreateUserForm {
    full_name: String,
    email: String,
    username: String,
}

#[derive(Serialize)]
pub struct UserId {
    unique_id: String,
}

#[derive(Serialize, sqlx::Type)]
#[sqlx(type_name = "composite_user")]
pub struct User {
    unique_id: String,
    email: String,
    username: String,
    created: NaiveDate,
}

#[derive(Deserialize)]
pub struct LookupUserForm {
    username: Option<String>,
    email: Option<String>,
    id: Option<String>,
}

pub async fn create_new_user(
    State(pool): State<PgPool>,
    form: Form<CreateUserForm>,
) -> Result<Json<UserId>, (StatusCode, String)> {
    let created = chrono::Local::now().date_naive();

    let new_user = sqlx::query_as!(UserId,
        "INSERT INTO \"users\".\"basic\" (full_name, email, username, created) VALUES ($1::varchar(256), $2::varchar(256), $3::varchar(15), $4::date) RETURNING \"unique_id\"",
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

pub async fn lookup_user(
    State(pool): State<PgPool>,
    query: Query<LookupUserForm>,
) -> Result<Json<User>, (StatusCode, String)> {
    let detail;
    let value = if let Some(username) = query.username.clone() {
        detail = Some("username");
        Some(username)
    } else if let Some(email) = query.email.clone() {
        detail = Some("email");
        Some(email)
    } else if let Some(id) = query.id.clone() {
        detail = Some("unique_id");
        Some(id)
    } else {
        detail = None;
        None
    };

    if let Some(detail_name) = detail {
        let query = format!("SELECT (unique_id,email,username,created)::users.composite_user FROM \"users\".\"basic\" WHERE \"{}\" = $1", detail_name);
        sqlx::query_as(&query)
            .bind(value.unwrap())
            .fetch_one(&pool)
            .await
            .map_err(|_| error_landing("user not found", StatusCode::NOT_FOUND, "warn"))
            .map(|u: (User,)| Json(u.0))
    } else {
        Err(error_landing(
            "malformed request",
            StatusCode::BAD_REQUEST,
            "fatal",
        ))
    }
}
