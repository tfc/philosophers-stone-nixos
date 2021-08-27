mod db_helper;
use crate::db_helper::*;

#[tokio::main]
async fn main() {
    let db_env = read_db_env().expect("Could not read database credentials");

    let db_entries = fetch_db(db_env).await.expect("Could not read from database.");

    println!("{}", db_entries);
}
