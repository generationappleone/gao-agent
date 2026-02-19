---
name: Deploy Python
description: Skill for deploying Python applications (Django, Flask, FastAPI) — covering Gunicorn, uWSGI, Docker, Nginx reverse proxy, systemd, and cloud platforms.
---

# Deploy Python Skill

## Overview
Deployment strategies for Python web applications (Django, Flask, FastAPI). Covers WSGI/ASGI servers, Docker, Nginx reverse proxy, and CI/CD.

---

## Architecture

```
Client → Nginx (reverse proxy) → Gunicorn/Uvicorn → Django/Flask/FastAPI
                                        ↕
                                   PostgreSQL / Redis
```

---

## Gunicorn (Django/Flask)

### systemd Service
```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=Gunicorn Django Application
After=network.target

[Service]
Type=notify
User=appuser
Group=www-data
WorkingDirectory=/var/www/myapp
Environment="PATH=/var/www/myapp/venv/bin"
Environment="DJANGO_SETTINGS_MODULE=config.settings.production"
ExecStart=/var/www/myapp/venv/bin/gunicorn config.wsgi:application \
  --workers 4 \
  --worker-class gthread \
  --threads 2 \
  --bind unix:/run/myapp/gunicorn.sock \
  --timeout 120 \
  --access-logfile /var/log/myapp/access.log \
  --error-logfile /var/log/myapp/error.log
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Uvicorn (FastAPI / ASGI)
```ini
ExecStart=/var/www/myapp/venv/bin/uvicorn main:app \
  --host 0.0.0.0 --port 8000 \
  --workers 4 \
  --loop uvloop \
  --access-log
```

### Nginx Reverse Proxy
```nginx
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://unix:/run/myapp/gunicorn.sock;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
    }

    location /static/ {
        alias /var/www/myapp/staticfiles/;
        expires 30d;
    }

    location /media/ {
        alias /var/www/myapp/media/;
        expires 7d;
    }
}
```

---

## Docker

### Django
```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN python manage.py collectstatic --noinput

RUN adduser --disabled-password --no-create-home appuser
USER appuser

EXPOSE 8000
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "4"]
```

### FastAPI
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN adduser --disabled-password --no-create-home appuser
USER appuser
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

---

## CI/CD (GitHub Actions)

```yaml
name: Deploy Python
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'

      - name: Install & Test
        run: |
          pip install -r requirements.txt
          python -m pytest --tb=short

      - name: Build & Push Docker
        run: |
          docker build -t myapp:${{ github.sha }} .
          docker push registry.example.com/myapp:${{ github.sha }}

      - name: Deploy
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: deploy
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /var/www/myapp
            git pull origin main
            source venv/bin/activate
            pip install -r requirements.txt
            python manage.py migrate --noinput
            python manage.py collectstatic --noinput
            sudo systemctl restart myapp
```

## Best Practices
1. **Gunicorn workers** — `2 * CPU_CORES + 1` workers
2. **Virtual environment** — always use venv in production
3. **Nginx for static files** — don't serve static via Django/Flask
4. **Non-root user** — never run app as root
5. **HTTPS via Certbot** — `certbot --nginx -d example.com`
6. **Environment variables** — use `.env` file with `python-dotenv`
