---
name: Go (Golang)
description: Skill for Go development, covering project setup, clean architecture, HTTP servers, database access, concurrency patterns, error handling, testing, and deployment.
---

# Go (Golang) Skill

## Overview
Go is a statically-typed, compiled language designed for simplicity, performance, and concurrency. Use this skill for microservices, CLI tools, APIs, and systems programming.

## Project Setup
```bash
mkdir my-service && cd my-service
go mod init github.com/myorg/my-service
```

## Directory Structure (Standard Go Layout)
```
cmd/
├── server/
│   └── main.go              # Entry point
internal/                     # Private application code
├── domain/                   # Business entities & interfaces
│   ├── user.go               # Entity + repository interface
│   └── errors.go             # Domain errors
├── service/                  # Business logic (use cases)
│   └── user_service.go
├── handler/                  # HTTP handlers
│   ├── user_handler.go
│   └── middleware.go
├── repository/               # Data access implementations
│   └── postgres/
│       └── user_repository.go
├── config/                   # Configuration
│   └── config.go
└── server/                   # HTTP server setup
    └── server.go
pkg/                          # Public reusable packages
├── logger/
└── validator/
migrations/                   # SQL migrations
go.mod
go.sum
Dockerfile
Makefile
```

## Domain Layer (DIP — Interfaces in Domain)
```go
// internal/domain/user.go
package domain

import (
    "context"
    "time"
    "github.com/google/uuid"
)

type User struct {
    ID        uuid.UUID  `json:"id" db:"id"`
    Email     string     `json:"email" db:"email"`
    FirstName string     `json:"firstName" db:"first_name"`
    LastName  string     `json:"lastName" db:"last_name"`
    IsActive  bool       `json:"isActive" db:"is_active"`
    CreatedAt time.Time  `json:"createdAt" db:"created_at"`
    UpdatedAt time.Time  `json:"updatedAt" db:"updated_at"`
    DeletedAt *time.Time `json:"-" db:"deleted_at"`
}

// Repository interface (defined in domain — DIP)
type UserRepository interface {
    FindByID(ctx context.Context, id uuid.UUID) (*User, error)
    FindByEmail(ctx context.Context, email string) (*User, error)
    Create(ctx context.Context, user *User) error
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id uuid.UUID) error
    List(ctx context.Context, limit, offset int) ([]*User, int, error)
}
```

## Service Layer
```go
// internal/service/user_service.go
package service

type UserService struct {
    repo   domain.UserRepository
    hasher PasswordHasher
    logger *slog.Logger
}

func NewUserService(repo domain.UserRepository, hasher PasswordHasher, logger *slog.Logger) *UserService {
    return &UserService{repo: repo, hasher: hasher, logger: logger}
}

func (s *UserService) Register(ctx context.Context, req CreateUserRequest) (*domain.User, error) {
    existing, _ := s.repo.FindByEmail(ctx, req.Email)
    if existing != nil {
        return nil, domain.ErrEmailAlreadyExists
    }

    hashed, err := s.hasher.Hash(req.Password)
    if err != nil {
        return nil, fmt.Errorf("hash password: %w", err)
    }

    user := &domain.User{
        ID:        uuid.New(),
        Email:     req.Email,
        FirstName: req.FirstName,
        LastName:  req.LastName,
        IsActive:  true,
        CreatedAt: time.Now().UTC(),
        UpdatedAt: time.Now().UTC(),
    }

    if err := s.repo.Create(ctx, user); err != nil {
        return nil, fmt.Errorf("create user: %w", err)
    }

    s.logger.Info("user registered", slog.String("user_id", user.ID.String()))
    return user, nil
}
```

## HTTP Handler
```go
// internal/handler/user_handler.go
func (h *UserHandler) Register(w http.ResponseWriter, r *http.Request) {
    var req CreateUserRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        respondError(w, http.StatusBadRequest, "invalid request body")
        return
    }

    if err := h.validator.Validate(req); err != nil {
        respondError(w, http.StatusBadRequest, err.Error())
        return
    }

    user, err := h.service.Register(r.Context(), req)
    if err != nil {
        switch {
        case errors.Is(err, domain.ErrEmailAlreadyExists):
            respondError(w, http.StatusConflict, "email already exists")
        default:
            h.logger.Error("register failed", slog.Any("error", err))
            respondError(w, http.StatusInternalServerError, "internal error")
        }
        return
    }

    respondJSON(w, http.StatusCreated, user)
}
```

## Error Handling (Idiomatic Go)
```go
// ✅ REQUIRED: Wrap errors with context
if err != nil {
    return fmt.Errorf("userService.Register: %w", err)
}

// ✅ REQUIRED: Sentinel errors for domain errors
var (
    ErrNotFound          = errors.New("resource not found")
    ErrEmailAlreadyExists = errors.New("email already exists")
    ErrUnauthorized      = errors.New("unauthorized")
)
```

## Concurrency Patterns
```go
// ✅ Worker pool pattern
func processItems(ctx context.Context, items []Item, workers int) error {
    g, ctx := errgroup.WithContext(ctx)
    ch := make(chan Item, len(items))

    for i := 0; i < workers; i++ {
        g.Go(func() error {
            for item := range ch {
                if err := process(ctx, item); err != nil {
                    return err
                }
            }
            return nil
        })
    }

    for _, item := range items {
        ch <- item
    }
    close(ch)

    return g.Wait()
}
```

## Testing
```go
func TestUserService_Register(t *testing.T) {
    repo := &MockUserRepository{}
    repo.FindByEmailFn = func(ctx context.Context, email string) (*domain.User, error) {
        return nil, domain.ErrNotFound
    }
    repo.CreateFn = func(ctx context.Context, user *domain.User) error {
        return nil
    }

    svc := service.NewUserService(repo, &FakeHasher{}, slog.Default())
    user, err := svc.Register(context.Background(), service.CreateUserRequest{
        Email:     "test@example.com",
        FirstName: "John",
        LastName:  "Doe",
        Password:  "password123",
    })

    assert.NoError(t, err)
    assert.Equal(t, "test@example.com", user.Email)
    assert.True(t, repo.CreateCalled)
}
```

## Key Tools
| Tool | Purpose |
|------|---------|
| `slog` | Structured logging (stdlib) |
| `chi` / `gorilla/mux` | HTTP router |
| `sqlx` | SQL database access |
| `golang-migrate` | Database migrations |
| `golangci-lint` | Linting |
| `govulncheck` | Vulnerability scanning |
| `errgroup` | Concurrent error handling |

## Rules Integration
- **SOLID**: Interfaces in domain (DIP), small interfaces (ISP), constructor injection
- **Security**: Input validation, parameterized queries, `crypto/rand` for secrets
- **Dependencies**: `go mod tidy`, `govulncheck`, pin versions in go.mod
