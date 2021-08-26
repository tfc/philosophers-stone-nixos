#[macro_use]
extern crate rocket;

#[get("/")]
fn index() -> String {
   "Hello World".to_string();
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
