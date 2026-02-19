---
name: Docker
description: Skill for containerizing applications with Docker, covering Dockerfile best practices, multi-stage builds, docker-compose, networking, security hardening, and production deployment patterns.
---

# Docker Skill

## Overview
Docker enables packaging applications into portable containers. This skill covers Dockerfiles, multi-stage builds, compose orchestration, security hardening, and production patterns for various tech stacks.

## 1. Dockerfile Best Practices

### Node.js (Multi-stage, Production-ready)
```dockerfile
# ✅ SECURE: Multi-stage build
# Stage 1: Install dependencies
FROM node:20-alpine3.19 AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Build
FROM node:20-alpine3.19 AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: Production (distroless for security)
FROM gcr.io/distroless/nodejs20-debian12 AS production
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./

ENV NODE_ENV=production
USER nonroot:nonroot
EXPOSE 3000
CMD ["dist/server.js"]
```

### Python (FastAPI/Django)
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
RUN pip install --no-cache-dir --upgrade pip
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim AS production
WORKDIR /app

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

COPY --from=builder /install /usr/local
COPY . .

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

### Go
```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /server ./cmd/server

FROM scratch AS production
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /server /server
USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/server"]
```

### .NET
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY *.sln .
COPY src/**/*.csproj ./
RUN for f in *.csproj; do mkdir -p "src/$(basename $f .csproj)" && mv "$f" "src/$(basename $f .csproj)/"; done
RUN dotnet restore
COPY . .
RUN dotnet publish src/MyApp.Api -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS production
WORKDIR /app
COPY --from=build /app/publish .
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s CMD ["dotnet", "MyApp.Api.dll", "--urls", "http://+:8080"]
ENTRYPOINT ["dotnet", "MyApp.Api.dll"]
```

## 2. Docker Compose

### Full-Stack Application
```yaml
# docker-compose.yml
version: '3.9'

services:
  # ─── Application ────────────────────────────
  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    container_name: myapp-api
    restart: unless-stopped
    ports:
      - "${API_PORT:-3000}:3000"
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      REDIS_URL: redis://redis:6379
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - app-network
    # Security hardening
    user: "1000:1000"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    tmpfs:
      - /tmp
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://localhost:3000/health').then(r => process.exit(r.ok ? 0 : 1))"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  # ─── Frontend ────────────────────────────────
  web:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: myapp-web
    restart: unless-stopped
    ports:
      - "${WEB_PORT:-80}:80"
    depends_on:
      - api
    networks:
      - app-network

  # ─── Database ────────────────────────────────
  db:
    image: postgres:16-alpine
    container_name: myapp-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME:-myapp}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
    ports:
      - "${DB_PORT:-5432}:5432"
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres} -d ${DB_NAME:-myapp}"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G

  # ─── Cache ────────────────────────────────
  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD} --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis-data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # ─── Reverse Proxy ────────────────────────
  nginx:
    image: nginx:alpine
    container_name: myapp-nginx
    restart: unless-stopped
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
      - web
    networks:
      - app-network

volumes:
  postgres-data:
    driver: local
  redis-data:
    driver: local

networks:
  app-network:
    driver: bridge
```

### Environment File (.env)
```env
# .env (NEVER commit to git)
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=super_secure_password_here
REDIS_PASSWORD=redis_secure_password
JWT_SECRET=minimum_32_character_secret_key_here
API_PORT=3000
WEB_PORT=80
```

## 3. Docker Security Checklist

### ✅ MUST Do
```dockerfile
# 1. Use specific image tags — NEVER use :latest
FROM node:20.11.1-alpine3.19   # ✅ Pinned
FROM node:latest               # ❌ Never

# 2. Run as non-root user
USER nonroot:nonroot           # ✅
USER root                      # ❌ Never in production

# 3. Use read-only filesystem
# docker-compose: read_only: true

# 4. Drop all capabilities
# docker-compose: cap_drop: [ALL]

# 5. No new privileges
# docker-compose: security_opt: [no-new-privileges:true]

# 6. Set resource limits
# docker-compose: deploy.resources.limits

# 7. Use multi-stage builds to minimize image size

# 8. Scan images for vulnerabilities
# docker scout cves myimage:latest
# trivy image myimage:latest
```

### .dockerignore
```
node_modules
.git
.env*
*.md
.DS_Store
coverage
dist
.vscode
.idea
docker-compose*.yml
Dockerfile*
```

## 4. Useful Commands
```bash
# Build & run
docker compose up -d --build
docker compose down -v           # Stop & remove volumes

# Logs
docker compose logs -f api       # Follow logs for api service
docker compose logs --tail=100   # Last 100 lines

# Exec into container
docker compose exec api sh

# Image management
docker system prune -af          # Clean all unused images
docker image ls
docker scout cves myimage:tag    # Scan for vulnerabilities

# Health check
docker compose ps                # Show health status
docker inspect --format='{{json .State.Health}}' myapp-api
```

## 5. Production Patterns
| Pattern | Implementation |
|---------|---------------|
| **Health checks** | HEALTHCHECK in Dockerfile + healthcheck in compose |
| **Graceful shutdown** | Handle SIGTERM in app (process.on('SIGTERM')) |
| **Log aggregation** | JSON logging → stdout → Docker log driver → ELK/Loki |
| **Secrets** | Docker secrets or external vault (never env vars for sensitive data in production) |
| **Networking** | Internal network for inter-service, expose only nginx |
| **Volumes** | Named volumes for persistence, bind mounts for config (read-only) |

## Rules Integration
- **Security**: Non-root user, read-only FS, no-new-privileges, pinned image tags, vulnerability scanning
- **ISO 27017**: Cloud container isolation, network segmentation, audit logging
- **Dependencies**: Scan base images with `docker scout` or Trivy before deployment
