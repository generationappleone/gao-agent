---
name: Go (Golang)
description: Skill for Go development, covering project setup, clean architecture, HTTP servers, database access, concurrency patterns, error handling, testing, and deployment.
---

# Go (Golang) Skill

## Overview
Go is a statically typed, compiled language designed by Google for systems programming, microservices, and cloud-native applications. It provides goroutines for concurrency, interfaces for polymorphism, and a minimal standard library for HTTP servers, JSON, and I/O.

**References**:
- [Go Documentation](https://go.dev/doc/)
- [Effective Go](https://go.dev/doc/effective_go)

---

## Project Structure

```
myapp/
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── handler/
│   │   └── product.go
│   ├── service/
│   │   └── product.go
│   ├── repository/
│   │   └── product.go
│   ├── model/
│   │   └── product.go
│   └── middleware/
│       └── auth.go
├── pkg/
│   └── response/
│       └── json.go
├── go.mod
├── go.sum
└── Dockerfile
```

---

## HTTP Server (net/http + chi)

```go
// cmd/api/main.go
package main

import (
    "log"
    "net/http"
    "github.com/go-chi/chi/v5"
    "github.com/go-chi/chi/v5/middleware"
)

func main() {
    r := chi.NewRouter()
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.RequestID)

    r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("OK"))
    })

    r.Route("/api/products", func(r chi.Router) {
        r.Get("/", handler.ListProducts)
        r.Post("/", handler.CreateProduct)
        r.Get("/{slug}", handler.GetProduct)
    })

    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", r))
}
```

---

## Models

```go
// internal/model/product.go
package model

import "time"

type Product struct {
    ID          string    `json:"id" db:"id"`
    Name        string    `json:"name" db:"name"`
    Slug        string    `json:"slug" db:"slug"`
    Description string    `json:"description" db:"description"`
    Price       int       `json:"price" db:"price"`
    Stock       int       `json:"stock" db:"stock"`
    Status      string    `json:"status" db:"status"`
    CreatedAt   time.Time `json:"created_at" db:"created_at"`
}

type CreateProductInput struct {
    Name        string `json:"name" validate:"required,min=2"`
    Price       int    `json:"price" validate:"required,gte=0"`
    Description string `json:"description"`
    CategoryID  string `json:"category_id" validate:"required,uuid"`
}

type PaginatedResponse[T any] struct {
    Data       []T `json:"data"`
    Total      int `json:"total"`
    Page       int `json:"page"`
    TotalPages int `json:"total_pages"`
}
```

---

## Handler

```go
// internal/handler/product.go
package handler

import (
    "encoding/json"
    "net/http"
    "strconv"
    "github.com/go-chi/chi/v5"
)

func ListProducts(w http.ResponseWriter, r *http.Request) {
    page, _ := strconv.Atoi(r.URL.Query().Get("page"))
    if page < 1 { page = 1 }
    search := r.URL.Query().Get("search")

    products, total, err := productService.List(r.Context(), page, 20, search)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(model.PaginatedResponse[model.Product]{
        Data: products, Total: total, Page: page, TotalPages: (total + 19) / 20,
    })
}

func GetProduct(w http.ResponseWriter, r *http.Request) {
    slug := chi.URLParam(r, "slug")
    product, err := productService.GetBySlug(r.Context(), slug)
    if err != nil {
        http.Error(w, "Not found", http.StatusNotFound)
        return
    }
    json.NewEncoder(w).Encode(product)
}
```

---

## Concurrency

```go
// Goroutines with WaitGroup
func processOrders(orders []Order) error {
    var wg sync.WaitGroup
    errCh := make(chan error, len(orders))

    for _, order := range orders {
        wg.Add(1)
        go func(o Order) {
            defer wg.Done()
            if err := processOrder(o); err != nil {
                errCh <- fmt.Errorf("order %s: %w", o.ID, err)
            }
        }(order)
    }

    wg.Wait()
    close(errCh)

    var errs []error
    for err := range errCh {
        errs = append(errs, err)
    }
    return errors.Join(errs...)
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Project layout** | cmd/internal/pkg structure |
| **chi router** | Lightweight, idiomatic HTTP router |
| **Interfaces** | Define at consumer, not provider |
| **Error handling** | Return errors, wrap with `%w` |
| **Goroutines** | Use WaitGroup for fan-out patterns |
| **Channels** | Communicate via channels, not shared memory |
| **Context** | Pass context for cancellation/timeout |
| **Generics** | Use for type-safe collections (Go 1.18+) |
| **Testing** | Table-driven tests with `testing` package |
| **Defer** | Clean up resources with defer |

---

## Rules Integration
- **Server**: chi router with middleware
- **Models**: Struct tags for JSON/DB mapping
- **Handlers**: HTTP handlers with JSON responses
- **Concurrency**: Goroutines, WaitGroup, channels
- **Architecture**: cmd/internal/pkg layout
