use axum::{
    extract::{Query, State},
    http::StatusCode,
    Json,
};
use chrono::NaiveDate;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

use super::fallbacks::error_landing;

// #[derive(Deserialize)]
// pub struct CreateDatabaseForm {
//     name: String,
//     created: NaiveDate,
//     user_id: String,
// }

#[derive(Serialize)]
pub struct Database {
    name: String,
    created: NaiveDate,
    unique_id: String,
    user_id: String,
}

#[derive(Deserialize)]
pub struct LookupDatabaseByOwnerQuery {
    user_id: String,
}

// pub async fn create_database(
//     State(pool): State<PgPool>,
//     form: Form<CreateDatabaseForm>
// ) -> Result<Json<UserId>, (StatusCode, String)> {

// }

#[axum_macros::debug_handler]
pub async fn lookup_database_by_owner(
    State(pool): State<PgPool>,
    query: Query<LookupDatabaseByOwnerQuery>,
) -> Result<Json<Vec<Database>>, (StatusCode, String)> {
    let results = sqlx::query_as!(Database,
        "SELECT \"name\", \"databases\".\"basic\".\"unique_id\", \"users\".\"basic\".\"unique_id\" AS \"user_id\", \"databases\".\"basic\".\"created\" FROM \"databases\".\"basic\" INNER JOIN \"users\".\"basic\" ON \"user_id\" = \"users\".\"basic\".\"id\" AND \"users\".\"basic\".\"unique_id\" = $1::varchar(15);",
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
