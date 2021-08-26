#[macro_use]
extern crate rocket;
extern crate chrono;
extern crate postgres;

use chrono::NaiveDate;
use postgres::{Client, NoTls};
use rocket::response::status::NotFound;

use std::env;
use std::string::String;
use std::thread;

struct DbContext {
    host: String,
    db: String,
    user: String,
    pass: String,
}

fn read_db_env() -> Result<DbContext, env::VarError> {
    let db_context = DbContext {
        host: env::var("MDB_HOST")?,
        db: env::var("MDB_DB")?,
        user: env::var("MDB_USER")?,
        pass: env::var("MDB_PASS")?,
    };

    Ok(db_context)
}

fn fetch_db(db_env: DbContext) -> String {
    let opt_result_string = thread::spawn(move || {
        let connect = format!(
            "host={} user={} password={} dbname={}",
            db_env.host, db_env.user, db_env.pass, db_env.db
        );
        let mut client = Client::connect(&connect, NoTls).unwrap();
        let res = client
            .query(
                "SELECT content, date FROM testcounter ORDER BY id desc LIMIT 10",
                &[],
            )
            .unwrap();

        let strings: Vec<String> = res
            .iter()
            .map(|row| {
                let content: String = row.get("content");
                let date: NaiveDate = row.get("date");

                format!("{}: {}", content, date)
            })
            .collect();

        strings.join("\n")
    })
    .join();

    match opt_result_string {
        Ok(string) => string,
        Err(_) => "Could not read from database".to_string(),
    }
}

#[get("/")]
fn index() -> Result<String, NotFound<String>> {
    let db_env = read_db_env();

    match db_env {
        Ok(db) => Ok(fetch_db(db)),
        Err(_) => Err(NotFound("Could not find environment variables for database connection".to_string())),
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
