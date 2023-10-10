#![deny(future_incompatible, nonstandard_style, unsafe_code, rust_2018_idioms)]
#![warn(clippy::pedantic)]
#![allow(
    clippy::single_match_else,
    clippy::let_unit_value,
    clippy::no_effect_underscore_binding,
    clippy::needless_pass_by_value,
    clippy::wildcard_imports,
    clippy::module_name_repetitions
)]

#[macro_use]
extern crate rocket;
#[cfg(test)]
#[macro_use]
extern crate rstest;
use rocket::routes;

#[get("/healthz")]
fn healthz() {}

#[rocket::main]
async fn main() -> anyhow::Result<()> {
    rocket::build()
        .mount("/api", routes![healthz,])
        .launch()
        .await?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use rocket::{http::Status, local::blocking::Client};

    use super::*;

    #[fixture]
    fn client() -> Client {
        Client::tracked(rocket::build().mount("/", routes![healthz])).unwrap()
    }

    #[rstest]
    fn healthz_returns_ok(client: Client) {
        assert_eq!(Status::Ok, client.get("/healthz").dispatch().status());
    }
}
