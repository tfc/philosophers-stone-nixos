use chrono::NaiveDate;
use postgres::{Client, NoTls};
use std::env;

pub struct DbContext {
    pub host: String,
    pub db: String,
    pub user: String,
    pub pass: String,
}

pub fn read_db_env() -> Result<DbContext, env::VarError> {
    let db_context = DbContext {
        host: env::var("MDB_HOST")?,
        db: env::var("MDB_DB")?,
        user: env::var("MDB_USER")?,
        pass: env::var("MDB_PASS")?,
    };

    Ok(db_context)
}

pub fn fetch_db(db_env: DbContext) -> String {
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
}
