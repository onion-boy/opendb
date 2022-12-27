use super::fallbacks::{error_landing, default_error_landing};
use axum::{
    extract::{Query, State},
    http::StatusCode,
    Form, Json,
};
use serde::{Deserialize, Serialize};
use sqlx::{
    postgres::{PgArguments, PgPool},
    query::QueryAs,
    types::chrono::{self, NaiveDate},
    Postgres,
};

#[derive(Deserialize)]
pub struct CreateUserForm {
    full_name: String,
    email: String,
    username: String,
}

#[derive(Serialize)]
pub struct UserId {
    user_id: i32
}

#[derive(Serialize)]
#[derive(sqlx::Type)]
#[sqlx(type_name = "composite_user")]
pub struct User {
    user_id: i32,
    email: String,
    username: String,
    created: NaiveDate
}

#[derive(Deserialize)]
pub struct LookupUserForm {
    username: Option<String>,
    email: Option<String>,
    user_id: Option<String>,
}

pub async fn create_new_user(
    State(pool): State<PgPool>,
    form: Form<CreateUserForm>,
) -> Result<Json<UserId>, (StatusCode, String)> {
    let created = chrono::Utc::now().date_naive();

    let new_user = sqlx::query_as!(UserId,
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
    } else if let Some(user_id) = query.user_id.clone() {
        detail = Some("user_id");
        Some(user_id)
    } else {
        detail = None;
        None
    };

    if let Some(detail_name) = detail {
        let query = format!("SELECT (user_id,email,username,created)::composite_user FROM users.basic WHERE {} = $1", detail_name);
        let result: QueryAs<Postgres, (User,), PgArguments> = sqlx::query_as(&query);
        let bound;

        if detail_name == "user_id" {
            bound = result.bind(value.unwrap().parse::<i32>().unwrap());
        } else {
            bound = result.bind(value.unwrap());
        }

        // |_| error_landing("user not found", StatusCode::NOT_FOUND, "warning")

        bound
            .fetch_one(&pool)
            .await
            .map_err(default_error_landing)
            .map(|u| Json(u.0))
    } else {
        Err(error_landing(
            "malformed request",
            StatusCode::BAD_REQUEST,
            "fatal",
        ))
    }
}
