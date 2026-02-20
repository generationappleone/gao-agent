---
name: Rust
description: Skill for Rust systems programming — covering ownership, borrowing, lifetimes, traits, error handling, async/await, Cargo, structs, enums, pattern matching, and web development with Actix/Axum.
---

# Rust Skill

## Overview
Rust is a systems programming language focused on performance, safety, and concurrency. It uses ownership/borrowing for memory safety without garbage collection. Rust is used for web servers (Axum, Actix), CLI tools, and WebAssembly.

**References**:
- [Rust Book](https://doc.rust-lang.org/book/)
- [Axum](https://github.com/tokio-rs/axum)

---

## Web Server (Axum)

```rust
use axum::{routing::{get, post}, Router, Json, extract::{Path, Query, State}};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

#[derive(Serialize)]
struct Product { id: String, name: String, price: i32, status: String }

#[derive(Deserialize)]
struct ListParams { page: Option<i32>, search: Option<String> }

async fn list_products(State(pool): State<PgPool>, Query(params): Query<ListParams>) -> Json<Vec<Product>> {
    let page = params.page.unwrap_or(1);
    let offset = (page - 1) * 20;
    let products = sqlx::query_as!(Product,
        "SELECT id, name, price, status FROM products WHERE status = 'active' ORDER BY created_at DESC LIMIT 20 OFFSET $1",
        offset as i64
    ).fetch_all(&pool).await.unwrap();
    Json(products)
}

#[tokio::main]
async fn main() {
    let pool = PgPool::connect(&std::env::var("DATABASE_URL").unwrap()).await.unwrap();
    let app = Router::new()
        .route("/api/products", get(list_products))
        .with_state(pool);
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

---

## Error Handling

```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum AppError {
    #[error("Not found: {0}")]
    NotFound(String),
    #[error("Validation: {0}")]
    Validation(String),
    #[error("Database: {0}")]
    Database(#[from] sqlx::Error),
}

impl axum::response::IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        let (status, message) = match &self {
            AppError::NotFound(msg) => (axum::http::StatusCode::NOT_FOUND, msg.clone()),
            AppError::Validation(msg) => (axum::http::StatusCode::BAD_REQUEST, msg.clone()),
            AppError::Database(_) => (axum::http::StatusCode::INTERNAL_SERVER_ERROR, "Internal error".into()),
        };
        (status, Json(serde_json::json!({"error": message}))).into_response()
    }
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Ownership** | Move semantics, borrow with `&` and `&mut` |
| **Result/Option** | Use `?` operator for error propagation |
| **thiserror** | Derive Error for custom error types |
| **serde** | Serialize/Deserialize for JSON |
| **sqlx** | Compile-time checked SQL queries |
| **Axum** | Type-safe extractors (State, Path, Query, Json) |
| **tokio** | Async runtime for I/O-bound tasks |
| **Clippy** | Use `cargo clippy` for lint checks |
| **Tests** | `#[cfg(test)]` module with `#[test]` functions |
| **Cargo** | Package manager and build tool |

---

## Rules Integration
- **Server**: Axum with typed extractors and state
- **Models**: Structs with serde derive macros
- **Database**: sqlx with compile-time query checking
- **Errors**: thiserror + IntoResponse for API errors
