use axum::{
  Router,
  http::StatusCode,
  response::{IntoResponse, Response},
  routing::get,
};

use tokio::fs;

#[tokio::main]
async fn main() {
  tracing_subscriber::fmt::init();

  let app = Router::new()
    .route("/kickstart/sh", get(get_kickstart_sh))
    .fallback(not_found);

  let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
  axum::serve(listener, app).await.unwrap();
}

async fn get_kickstart_sh() -> Response {
  match fs::read_to_string("sh/kickstart.sh").await {
    Ok(sh) => sh.into_response(),
    Err(e) => {
      tracing::error!("Failed to read sh/kickstart.sh: {}", e);
      internal_server_error().await
    }
  }
}

async fn not_found() -> Response {
  (StatusCode::NOT_FOUND, "404 Not Found").into_response()
}

async fn internal_server_error() -> Response {
  (StatusCode::INTERNAL_SERVER_ERROR, "500 Internal Server Error").into_response()
}
