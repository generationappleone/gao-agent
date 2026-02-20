---
name: Docker
description: Skill for containerizing applications with Docker, covering Dockerfile best practices, multi-stage builds, docker-compose, networking, security hardening, and production deployment patterns.
---

# Docker Skill

## Overview
Docker is the standard platform for containerizing applications. It packages code, runtime, libraries, and dependencies into portable containers that run consistently across environments. Docker Compose orchestrates multi-container applications for development and production.

**References**:
- [Docker Documentation](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose](https://docs.docker.com/compose/)

---

## Node.js Multi-Stage Dockerfile

```dockerfile
# Dockerfile
# ── Stage 1: Dependencies ──
FROM node:20-alpine AS deps
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --only=production && \
    cp -R node_modules /prod_modules && \
    npm ci

# ── Stage 2: Build ──
FROM node:20-alpine AS build
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build && \
    npm prune --production

# ── Stage 3: Production ──
FROM node:20-alpine AS production
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Security: non-root user
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser

COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/package.json ./

USER appuser
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "dist/main.js"]
```

---

## Next.js Standalone Dockerfile

```dockerfile
# Dockerfile.nextjs
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:20-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -D appuser

COPY --from=build /app/public ./public
COPY --from=build --chown=appuser:appgroup /app/.next/standalone ./
COPY --from=build --chown=appuser:appgroup /app/.next/static ./.next/static

USER appuser
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
```

---

## Docker Compose (Full Stack)

```yaml
# docker-compose.yml
version: "3.9"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    container_name: myapp-api
    ports:
      - "${PORT:-3000}:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://myapp:${DB_PASSWORD}@postgres:5432/myapp
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - backend

  postgres:
    image: postgres:16-alpine
    container_name: myapp-postgres
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - backend

  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - backend

  nginx:
    image: nginx:alpine
    container_name: myapp-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - backend

volumes:
  postgres_data:
  redis_data:

networks:
  backend:
    driver: bridge
```

---

## .dockerignore

```
node_modules
npm-debug.log
.git
.gitignore
.env
.env.*
dist
build
.next
coverage
*.md
.vscode
.idea
docker-compose*.yml
Dockerfile*
.dockerignore
tests
__tests__
```

---

## Docker Compose (Development)

```yaml
# docker-compose.dev.yml
version: "3.9"

services:
  app:
    build:
      context: .
      target: deps
    container_name: myapp-dev
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
      - "9229:9229"  # Debug port
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://myapp:devpass@postgres:5432/myapp
      - REDIS_URL=redis://redis:6379
    command: npm run dev
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD: devpass
    volumes:
      - pgdata_dev:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myapp"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@local.dev
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - postgres

volumes:
  pgdata_dev:
```

---

## Security Hardening

```dockerfile
# Use specific version tags, never :latest
FROM node:20.11-alpine3.19

# Run as non-root
RUN addgroup -S app && adduser -S app -G app
USER app

# Read-only filesystem where possible
# In docker-compose:
#   read_only: true
#   tmpfs: [/tmp]

# No new privileges
# security_opt: [no-new-privileges:true]

# Resource limits in compose:
#   deploy:
#     resources:
#       limits:
#         cpus: '0.5'
#         memory: 512M
```

---

## Commands Reference

```bash
# ── Build ──
docker build -t myapp:latest .
docker build -t myapp:1.0 --target production .
docker build --no-cache -t myapp:latest .

# ── Run ──
docker run -d --name myapp -p 3000:3000 myapp:latest
docker run -it --rm myapp:latest /bin/sh

# ── Compose ──
docker compose up -d                    # Start all
docker compose up -d --build            # Rebuild and start
docker compose down                     # Stop and remove
docker compose down -v                  # Stop + remove volumes
docker compose logs -f app              # Follow logs
docker compose exec app sh              # Shell into container
docker compose ps                       # List containers

# ── Debug ──
docker logs myapp --tail 100 -f
docker exec -it myapp sh
docker stats                            # Resource usage
docker inspect myapp

# ── Cleanup ──
docker system prune -af                 # Remove everything unused
docker volume prune                     # Remove unused volumes
docker image prune -af                  # Remove unused images
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Multi-stage** | Separate deps/build/production stages |
| **Alpine** | Use `-alpine` images for smaller size |
| **Non-root** | Always run as non-root user |
| **HEALTHCHECK** | Add health checks for orchestration |
| **.dockerignore** | Exclude node_modules, .git, tests |
| **Layer caching** | Copy package*.json before source code |
| **Specific tags** | Pin image versions, avoid `:latest` |
| **compose depends_on** | Use `condition: service_healthy` |
| **Volumes** | Named volumes for persistence |
| **Environment** | Use `.env` file for compose variables |

---

## Rules Integration
- **Build**: Multi-stage (deps → build → production) for minimal images
- **Compose**: Full stack (app + postgres + redis + nginx) with health checks
- **Security**: Non-root user, read-only FS, resource limits
- **Development**: Hot-reload with volume mounts + debug port
- **CI/CD**: Build → tag → push → deploy workflow
