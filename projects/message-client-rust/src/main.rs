#[macro_use]
extern crate rocket;
extern crate postgres;

use postgres::{Client, NoTls};

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
    thread::spawn(move || {
        let connect = format!(
            "host={} user={} password={} dbname={}",
            db_env.host, db_env.user, db_env.pass, db_env.db
        );
        let mut client = Client::connect(&connect, NoTls).unwrap();

        for row in client
            .query(
                "SELECT content, date FROM testcounter ORDER BY id desc LIMIT 10",
                &[],
            )
            .unwrap()
        {
            let content: String = row.get("content");
            //let date: String = row.get("content");
            println!("foo: {}", content);
        }
    })
    .join()
    .expect("Thread panicked");

    "".to_string()
}

#[get("/")]
fn index() -> String {
    let db_env = read_db_env();

    match db_env {
        Ok(db) => fetch_db(db),
        Err(_) => "error".to_string(),
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
