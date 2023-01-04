use serde::Serialize;

#[derive(Serialize)]
pub struct HasUniqueId {
    pub unique_id: String
}