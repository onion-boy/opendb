use axum::{
    extract::{Query, State},
    http::StatusCode,
    Json, Form,
};
use chrono::NaiveDate;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

use super::{fallbacks::{error_landing, default_error_landing}, basic::HasUniqueId};

#[derive(Deserialize)]
pub struct CreateDatabaseForm {
    name: String,
    user_id: String,
}

#[derive(Serialize, sqlx::Type)]
#[sqlx(type_name = "composite_database")]
pub struct Database {
    name: String,
    created: NaiveDate,
    unique_id: String,
    user_id: String,
}

#[derive(Deserialize)]
pub struct LookupDatabaseQuery {
    user_id: String,
    unique_id: Option<String>
}

pub async fn create_database(
    State(pool): State<PgPool>,
    form: Form<CreateDatabaseForm>
) -> Result<Json<HasUniqueId>, (StatusCode, String)> {
    let created = chrono::Local::now().date_naive();

    let new_db = sqlx::query_as!(HasUniqueId,
        "INSERT INTO databases.basic (name, user_id, created) VALUES ($1, (SELECT users.basic.id FROM users.basic WHERE users.basic.unique_id = $2), $3) RETURNING unique_id;",
        form.name, form.user_id, created)
        .fetch_one(&pool)
        .await;

        match new_db {
            Ok(db) => Ok(Json(db)),
            Err(e) => Err(default_error_landing(e)),
        }
}

#[axum_macros::debug_handler]
pub async fn lookup_database(
    State(pool): State<PgPool>,
    query: Query<LookupDatabaseQuery>,
) -> Result<Json<Vec<Database>>, (StatusCode, String)> {
    let mut append = "SELECT name, databases.basic.unique_id, users.basic.unique_id AS \"user_id\", databases.basic.created FROM databases.basic INNER JOIN users.basic ON user_id = users.basic.id AND users.basic.unique_id = $1::char(15)".to_string();
    if let Some(unique_id) = query.unique_id {
        append = format!("{}{}", append, " database.basic.unique_id = $2::char(15)")
    }
    let results = sqlx::query_as!(Database,
        ,
        query.user_id)
        .fetch_all(&pool)
        .await;

    match results {
        Ok(databases) => Ok(Json(databases)),
        Err(_) => Err(error_landing(
            "could not locate databases",
            StatusCode::NOT_FOUND,
            "warning",
        )),
    }
}
