#[macro_use]
extern crate rocket;

use rocket::response::status::NotFound;
use std::string::String;

mod db_helper;
use crate::db_helper::*;

#[get("/")]
async fn index() -> Result<String, NotFound<String>> {
    let db_env = read_db_env();

    match db_env {
        Ok(db) => match fetch_db(db).await {
            Ok(db_entries) => Ok(db_entries),
            Err(e) => Err(NotFound(format!("Could not connect to database: {}", e.to_string()))),
        },
        Err(e) => Err(NotFound(
            format!("Could not find environment variables for database connection: {}", e.to_string()))),
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
