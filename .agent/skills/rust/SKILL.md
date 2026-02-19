---
name: Rust
description: Skill for Rust systems programming — covering ownership, borrowing, lifetimes, traits, error handling, async/await, Cargo, structs, enums, pattern matching, and web development with Actix/Axum.
---

# Rust Skill

## Overview
Rust is a systems programming language focused on safety, speed, and concurrency with zero-cost abstractions.

**Reference**: [The Rust Programming Language](https://doc.rust-lang.org/book/)

## Project Setup
```bash
cargo new myapp        # Binary project
cargo new mylib --lib  # Library project
cargo build            # Build
cargo run              # Build + run
cargo test             # Run tests
cargo clippy           # Lint
cargo fmt              # Format
```

## Core Concepts
```rust
// Ownership & Borrowing
fn main() {
    let s1 = String::from("hello");  // s1 owns the String
    let s2 = &s1;                     // s2 borrows (immutable reference)
    let s3 = &mut s1;                 // mutable borrow (exclusive)
    println!("{}", s2);
}

// Structs
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
struct User {
    id: String,
    name: String,
    email: String,
    age: Option<u32>,
}

impl User {
    fn new(name: &str, email: &str) -> Self {
        Self { id: uuid::Uuid::new_v4().to_string(), name: name.to_string(), email: email.to_string(), age: None }
    }

    fn display_name(&self) -> &str { &self.name }
}

// Enums + Pattern Matching
enum AppError {
    NotFound(String),
    Unauthorized,
    Internal(anyhow::Error),
}

fn handle_error(err: AppError) -> String {
    match err {
        AppError::NotFound(id) => format!("Not found: {}", id),
        AppError::Unauthorized => "Unauthorized".to_string(),
        AppError::Internal(e) => format!("Internal error: {}", e),
    }
}

// Traits
trait Repository<T> {
    fn find_by_id(&self, id: &str) -> Option<T>;
    fn save(&mut self, item: T) -> Result<(), AppError>;
}

// Error handling with Result
fn parse_config(path: &str) -> Result<Config, Box<dyn std::error::Error>> {
    let content = std::fs::read_to_string(path)?;  // ? propagates error
    let config: Config = serde_json::from_str(&content)?;
    Ok(config)
}
```

## Async / Web (Axum)
```rust
use axum::{Router, Json, extract::{Path, State}, routing::{get, post}, http::StatusCode};
use serde::{Deserialize, Serialize};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/users", get(list_users).post(create_user))
        .route("/users/:id", get(get_user))
        .with_state(AppState::new());

    axum::serve(tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap(), app).await.unwrap();
}

async fn list_users(State(state): State<AppState>) -> Json<Vec<User>> {
    let users = state.db.fetch_users().await;
    Json(users)
}

async fn create_user(State(state): State<AppState>, Json(input): Json<CreateUserInput>) -> (StatusCode, Json<User>) {
    let user = state.db.create_user(input).await;
    (StatusCode::CREATED, Json(user))
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **`clippy`** | Always lint with `cargo clippy` |
| **`Result<T, E>`** | Use for recoverable errors, avoid `unwrap()` |
| **`anyhow`/`thiserror`** | Use for error handling in apps/libraries |
| **`serde`** | For serialization/deserialization |
| **Ownership** | Prefer borrowing (`&T`) over cloning |
| **`Option`** | Use instead of null — `None` is explicit |
| **Pattern matching** | Use `match` for exhaustive handling |
| **Traits** | For polymorphism and abstraction |
| **`tokio`** | Async runtime for I/O-bound applications |
| **Documentation** | Use `///` doc comments with examples |
