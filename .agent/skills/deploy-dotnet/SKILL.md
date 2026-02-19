---
name: Deploy .NET
description: Skill for deploying .NET/C# applications — covering publish profiles, Docker, IIS, Kestrel, Azure App Service, systemd, and CI/CD.
---

# Deploy .NET Skill

## Overview
Deployment strategies for ASP.NET Core / .NET applications. Covers self-contained publish, Docker, IIS, Azure, and CI/CD.

---

## Build & Publish

```bash
# Framework-dependent (requires .NET runtime on server)
dotnet publish -c Release -o ./publish

# Self-contained (includes runtime — no dependencies needed)
dotnet publish -c Release -o ./publish --self-contained true -r linux-x64

# Single file (one executable)
dotnet publish -c Release -o ./publish \
  --self-contained true -r linux-x64 \
  -p:PublishSingleFile=true \
  -p:PublishTrimmed=true

# Trimmed + ReadyToRun (fastest startup)
dotnet publish -c Release -o ./publish \
  --self-contained true -r linux-x64 \
  -p:PublishTrimmed=true \
  -p:PublishReadyToRun=true
```

---

## Docker

```dockerfile
# Multi-stage build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS builder
WORKDIR /app
COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine
WORKDIR /app
COPY --from=builder /publish .

RUN adduser --disabled-password --no-create-home appuser
USER appuser

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "MyApp.dll"]
```

---

## Systemd Service (Linux)

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=ASP.NET Core Application
After=network.target

[Service]
Type=notify
User=appuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/MyApp
Restart=always
RestartSec=10
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://localhost:5000
EnvironmentFile=/opt/myapp/.env

[Install]
WantedBy=multi-user.target
```

### Nginx Reverse Proxy
```nginx
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## Azure App Service

```bash
# Deploy directly from CLI
az webapp up --name myapp --resource-group mygroup --runtime "DOTNET:9.0"

# Deploy from Docker
az webapp create --resource-group mygroup --plan myplan \
  --name myapp --deployment-container-image-name registry.example.com/myapp:latest
```

---

## CI/CD (GitHub Actions)

```yaml
name: Build & Deploy .NET
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '9.0.x'

      - name: Restore & Build
        run: |
          dotnet restore
          dotnet build --no-restore -c Release

      - name: Test
        run: dotnet test --no-build -c Release --verbosity normal

      - name: Publish
        run: dotnet publish -c Release -o ./publish --no-build

      - name: Deploy
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: deploy
          key: ${{ secrets.SSH_KEY }}
          script: |
            sudo systemctl stop myapp
            rsync -avz ./publish/ deploy@server:/opt/myapp/
            sudo systemctl start myapp
```

## Best Practices
1. **Self-contained** for VPS — no .NET runtime dependency
2. **Alpine Docker images** — `aspnet:9.0-alpine` for smaller images
3. **Kestrel behind Nginx** — never expose Kestrel directly
4. **Health checks** — `app.MapHealthChecks("/health")`
5. **Environment-based config** — `ASPNETCORE_ENVIRONMENT=Production`
6. **ReadyToRun** — pre-compiled for faster cold start
