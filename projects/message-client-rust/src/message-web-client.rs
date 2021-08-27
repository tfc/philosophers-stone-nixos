#[macro_use]
extern crate rocket;

use rocket::response::status::NotFound;
use std::string::String;
use std::thread;

mod db_helper;
use crate::db_helper::*;

fn fetch_testcounter(db_env: DbContext) -> String {
    let opt_result_string = thread::spawn(move || fetch_db(db_env)).join();

    match opt_result_string {
        Ok(string) => string,
        Err(_) => "Could not read from database".to_string(),
    }
}

#[get("/")]
fn index() -> Result<String, NotFound<String>> {
    let db_env = read_db_env();

    match db_env {
        Ok(db) => Ok(fetch_testcounter(db)),
        Err(_) => Err(NotFound(
            "Could not find environment variables for database connection".to_string(),
        )),
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
