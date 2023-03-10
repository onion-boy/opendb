use super::{fallbacks::error_landing, basic::HasUniqueId};
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

#[derive(Serialize, sqlx::Type)]
#[sqlx(type_name = "composite_user")]
pub struct User {
    unique_id: String,
    email: String,
    username: String,
    created: NaiveDate,
}

#[derive(Deserialize)]
pub struct LookupUserQuery {
    username: Option<String>,
    unique_id: Option<String>,
}

pub async fn create_new_user(
    State(pool): State<PgPool>,
    form: Form<CreateUserForm>,
) -> Result<Json<HasUniqueId>, (StatusCode, String)> {
    let created = chrono::Local::now().date_naive();

    let new_user = sqlx::query_as!(HasUniqueId,
        "INSERT INTO users.basic (full_name, email, username, created) VALUES ($1::varchar(256), $2::varchar(256), $3::varchar(15), $4::date) RETURNING unique_id",
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
    query: Query<LookupUserQuery>,
) -> Result<Json<User>, (StatusCode, String)> {
    let mut detail = None;
    let value = if let Some(username) = query.username.clone() {
        detail = Some("username");
        Some(username)
    } else if let Some(unique_id) = query.unique_id.clone() {
        detail = Some("unique_id");
        Some(unique_id)
    } else {
        None
    };

    if let Some(detail_name) = detail {
        let query = format!("SELECT (unique_id,email,username,created)::users.composite_user FROM users.basic WHERE {} = $1", detail_name);
        let user: Result<(User,), sqlx::Error> = sqlx::query_as(&query)
            .bind(value.unwrap())
            .fetch_one(&pool)
            .await;

        match user {
            Ok(u) => Ok(Json(u.0)),
            Err(_) => Err(error_landing(
                "user not found",
                StatusCode::NOT_FOUND,
                "warning",
            )),
        }
    } else {
        Err(error_landing(
            "malformed request",
            StatusCode::BAD_REQUEST,
            "fatal",
        ))
    }
}
