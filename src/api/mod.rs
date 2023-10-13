use crate::hurl_ext;
use crate::hurl_ext::ext::{HurlParseErrorEnum, HurlPos};
use rocket::serde::json::Json;
use rocket::serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct File {
    content: String,
}

#[derive(Serialize)]
pub struct ParseResponse {
    error: Option<ParseError>,
    result: Option<String>,
}

#[derive(Serialize)]
pub struct ParseError {
    pos: HurlPos,
    error: HurlParseErrorEnum,
    message: String,
}
#[post("/parse", data = "<input>")]
pub fn parse(input: Json<File>) -> Json<ParseResponse> {
    let result = match hurl_ext::ext::try_parse(input.content.as_str()) {
        Ok(_) => ParseResponse {
            error: None,
            result: Some("File is okay".to_string()),
        },
        Err(err) => ParseResponse {
            error: Some(ParseError {
                pos: err.pos.clone(),
                error: err.inner.clone(),
                message: hurl_ext::ext::parse_err_to_pos_err(&err.inner, err.pos),
            }),
            result: None,
        },
    };
    Json(result)
}
