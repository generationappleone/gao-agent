---
name: Deploy Java
description: Skill for deploying Java/Spring Boot applications — covering JAR/WAR packaging, Docker, Kubernetes, Tomcat, systemd service, CI/CD, and cloud platforms (AWS, GCP).
---

# Deploy Java Skill

## Overview
Deployment strategies for Java/Spring Boot applications. Covers executable JAR, Docker, Kubernetes, Tomcat, and CI/CD pipelines.

---

## Build Artifacts

```bash
# Maven — executable JAR
mvn clean package -DskipTests
# Output: target/app-1.0.0.jar

# Maven — executable JAR (Spring Boot)
mvn clean package spring-boot:repackage
# Output: target/app-1.0.0.jar (fat JAR with embedded Tomcat)

# Gradle
./gradlew clean build -x test
# Output: build/libs/app-1.0.0.jar
```

---

## Run as Systemd Service (VPS)

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Spring Boot Application
After=network.target

[Service]
Type=simple
User=appuser
Group=appuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/java -Xms256m -Xmx512m -jar /opt/myapp/app.jar --spring.profiles.active=production
SuccessExitStatus=143
Restart=always
RestartSec=10
StandardOutput=append:/var/log/myapp/stdout.log
StandardError=append:/var/log/myapp/stderr.log

Environment="JAVA_OPTS=-Xms256m -Xmx512m"
Environment="SPRING_PROFILES_ACTIVE=production"
EnvironmentFile=/opt/myapp/.env

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable myapp
sudo systemctl start myapp
sudo systemctl status myapp
```

---

## Docker

```dockerfile
# Multi-stage build
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn clean package -DskipTests -q

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

# Security: non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-Xms256m", "-Xmx512m", "-jar", "app.jar"]
```

### Docker Compose
```yaml
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/myapp
      - SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s

volumes:
  pgdata:
```

---

## CI/CD (GitHub Actions)

```yaml
name: Build & Deploy Java
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: 'maven'

      - name: Build & Test
        run: mvn clean package

      - name: Build Docker Image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Push to Registry
        run: |
          echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
          docker tag myapp:${{ github.sha }} registry.example.com/myapp:latest
          docker push registry.example.com/myapp:latest

      - name: Deploy
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: deploy
          key: ${{ secrets.SSH_KEY }}
          script: |
            docker pull registry.example.com/myapp:latest
            docker compose up -d --force-recreate app
```

## Best Practices
1. **Fat JAR** — Spring Boot executable JAR with embedded Tomcat
2. **Multi-stage Docker** — build with Maven image, run with JRE-only image
3. **Health checks** — `/actuator/health` endpoint for liveness/readiness
4. **JVM tuning** — set `-Xms` and `-Xmx` based on container memory
5. **Non-root user** — never run as root in Docker
6. **Graceful shutdown** — Spring Boot handles SIGTERM by default
7. **Profile-based config** — `application-production.yml` for prod settings
