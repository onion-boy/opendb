use axum::{response::IntoResponse, http::{StatusCode, Uri, Method}};
use crate::scope;

pub async fn unknown_landing(method: Method, uri: Uri) -> impl IntoResponse {
    (StatusCode::NOT_FOUND, scope!("warning", "cannot {} \"{}\"", method.as_str(), uri.path()))
}

pub fn error_landing<T>(error: T, code: StatusCode, level: &str) -> (StatusCode, String)
    where T: ToString {
    (code, scope!(level, "{}", error.to_string()))
}

// pub fn default_error_landing<T>(error: T) -> (StatusCode, String)
//     where T: ToString {
//     (StatusCode::INTERNAL_SERVER_ERROR, scope!("fatal", "internal server error: {}", error.to_string()))
// }