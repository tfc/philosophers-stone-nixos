#[macro_use]
extern crate rocket;

use std::env;
use std::string::String;

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

#[get("/")]
fn index() -> String {
    let db_env = read_db_env();

    match db_env {
        Ok(db) => format!(
            "Host: {} Db: {} User: {} Pass: {}",
            db.host, db.db, db.user, db.pass
        ),
        Err(_) => "error".to_string(),
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
