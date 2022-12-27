use axum::{response::IntoResponse, http::{StatusCode, Uri, Method}};
use crate::scope;

pub async fn unknown_landing(method: Method, uri: Uri) -> impl IntoResponse {
    (StatusCode::NOT_FOUND, scope!("warning", "cannot {} \"{}\"", method.as_str(), uri.path()))
}

pub fn error_landing<T>(error: T) -> (StatusCode, String)
    where T: std::error::Error {
    (StatusCode::INTERNAL_SERVER_ERROR, scope!("fatal", "internal server error: \"{}\"", error))
}