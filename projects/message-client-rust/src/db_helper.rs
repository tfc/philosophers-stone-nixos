use chrono::NaiveDate;
use tokio_postgres::{NoTls, Error};
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

pub async fn fetch_db(db_env: DbContext) -> Result<String, Error> {
    let connect = format!(
        "host={} user={} password={} dbname={}",
        db_env.host, db_env.user, db_env.pass, db_env.db
    );
    let (client, connection) =
        tokio_postgres::connect(&connect, NoTls).await?;

    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {}", e);
        }
    });

    let rows = client
        .query("SELECT content, date FROM testcounter ORDER BY id desc LIMIT 10", &[])
        .await?;

    let strings: Vec<String> = rows
        .iter()
        .map(|row| {
            let content: String = row.get("content");
            let date: NaiveDate = row.get("date");

            format!("{}: {}", content, date)
        })
        .collect();

    Ok(strings.join("\n"))
}
