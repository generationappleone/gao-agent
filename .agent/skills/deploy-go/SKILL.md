---
name: Deploy Go
description: Skill for deploying Go applications — covering static binary compilation, Docker (scratch/distroless), systemd, Kubernetes, CI/CD, and cross-compilation.
---

# Deploy Go Skill

## Overview
Go compiles to a **single static binary** — no runtime dependencies needed. This makes Go one of the easiest languages to deploy. Covers binary builds, Docker, systemd, and CI/CD.

---

## Build

```bash
# Standard build
go build -o bin/server ./cmd/server

# Production build (smaller binary, stripped debug info)
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -ldflags="-s -w -X main.version=$(git describe --tags)" \
  -o bin/server ./cmd/server

# Cross-compilation
GOOS=windows GOARCH=amd64 go build -o bin/server.exe ./cmd/server
GOOS=darwin GOARCH=arm64 go build -o bin/server-mac ./cmd/server
GOOS=linux GOARCH=arm64 go build -o bin/server-arm ./cmd/server
```

---

## Docker (Scratch — Smallest Image)

```dockerfile
# Stage 1: Build
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /server ./cmd/server

# Stage 2: Run (scratch — ~5MB total image)
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

### Alternative: Distroless (with shell for debugging)
```dockerfile
FROM gcr.io/distroless/static-debian12
COPY --from=builder /server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

---

## Systemd Service

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Go Application
After=network.target

[Service]
Type=simple
User=appuser
Group=appuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/server
Restart=always
RestartSec=5
LimitNOFILE=65535
EnvironmentFile=/opt/myapp/.env

[Install]
WantedBy=multi-user.target
```

```bash
# Deploy binary directly
scp bin/server deploy@server:/opt/myapp/server
ssh deploy@server "sudo systemctl restart myapp"
```

---

## CI/CD (GitHub Actions)

```yaml
name: Build & Deploy Go
on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'
          cache: true

      - name: Test
        run: go test ./... -race -coverprofile=coverage.out

      - name: Build
        run: CGO_ENABLED=0 go build -ldflags="-s -w" -o server ./cmd/server

      - name: Build & Push Docker
        run: |
          docker build -t myapp:${{ github.sha }} .
          docker push registry.example.com/myapp:${{ github.sha }}
```

## Best Practices
1. **Single static binary** — `CGO_ENABLED=0` for true static build
2. **Scratch Docker image** — Go doesn't need an OS; ~5MB images
3. **`-ldflags="-s -w"`** — strip debug info for smaller binary
4. **Health endpoint** — `/healthz` for load balancer/K8s probes
5. **Graceful shutdown** — handle `SIGTERM` with `context.WithCancel`
6. **No runtime dependencies** — just copy the binary and run
