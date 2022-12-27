mod routes;
mod util;

use axum::{http::StatusCode, response::IntoResponse, routing::{get, post}, Router};
use dotenv::dotenv;
use sqlx::postgres::PgPoolOptions;
use tokio::signal;
use std::net::SocketAddr;
use routes::{fallbacks::unknown_landing, user::{create_new_user, lookup_username_or_email}};

async fn default_landing() -> impl IntoResponse {
    (StatusCode::OK, "no API path specificed")
}

// directly copied from axum/examples :)
async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }

    pscope!("info", "signal received, starting graceful shutdown",);
}

#[tokio::main]
async fn main() {
    dotenv().ok();

    let database_uri = std::env::var("DATABASE_URL")
        .expect("could not find database URI in .env file!");

    let user_dbpool = PgPoolOptions::new()
        .max_connections(10)
        .connect(&database_uri)
        .await
        .expect("could not connect to postgres database!");

    let user_routes = Router::new()
        .route("/users/new", post(create_new_user))
        .route("/users/lookup", get(lookup_username_or_email))
        .with_state(user_dbpool);

    let app = user_routes
        .fallback(unknown_landing)
        .route("/", get(default_landing));

    let addr = SocketAddr::from(([127, 0, 0, 1], 80));
    pscope!("info", "server listening on {}", addr);
    pscope!("info", "database connection active",);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .with_graceful_shutdown(shutdown_signal())
        .await
        .unwrap();
}
