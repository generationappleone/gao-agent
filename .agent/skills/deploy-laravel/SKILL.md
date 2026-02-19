---
name: Deploy Laravel
description: Skill for deploying Laravel/PHP applications — covering server setup, Nginx/Apache, PHP-FPM, Forge, Deployer, Docker, shared hosting, queue workers, and zero-downtime deployment.
---

# Deploy Laravel Skill

## Overview
Deployment strategies for Laravel applications. Covers traditional VPS, Docker, managed platforms (Forge, Vapor), shared hosting, and CI/CD pipelines.

---

## Deployment Options

| Platform | Best For | Cost | Complexity |
|----------|----------|------|-----------|
| **Laravel Forge** | Managed VPS (DigitalOcean, AWS) | $12/mo + VPS | ⭐ Easy |
| **Laravel Vapor** | Serverless (AWS Lambda) | Pay-per-use | ⭐⭐ Medium |
| **VPS + Nginx** | Full control | $5-50/mo | ⭐⭐⭐ Manual |
| **Docker** | Containerized, reproducible | VPS cost | ⭐⭐ Medium |
| **Shared Hosting** | Budget, cPanel | $3-10/mo | ⭐⭐ Medium |

---

## VPS + Nginx Deployment

### Server Setup (Ubuntu 22.04+)
```bash
# 1. Install dependencies
sudo apt update && sudo apt install -y \
  nginx php8.3-fpm php8.3-cli php8.3-mbstring php8.3-xml \
  php8.3-curl php8.3-zip php8.3-mysql php8.3-redis php8.3-gd \
  php8.3-bcmath php8.3-intl supervisor redis-server

# 2. Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# 3. Create app directory
sudo mkdir -p /var/www/app
sudo chown -R www-data:www-data /var/www/app
```

### Nginx Configuration
```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/app/current/public;
    index index.php;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2)$ {
        expires 30d;
        add_header Cache-Control "public";
    }
}
```

### Deploy Script (deploy.sh)
```bash
#!/bin/bash
set -e

APP_DIR="/var/www/app"
RELEASE_DIR="$APP_DIR/releases/$(date +%Y%m%d_%H%M%S)"
SHARED_DIR="$APP_DIR/shared"
CURRENT_LINK="$APP_DIR/current"

echo "🚀 Deploying Laravel..."

# 1. Create release directory
mkdir -p "$RELEASE_DIR"
git clone --depth 1 git@github.com:user/repo.git "$RELEASE_DIR"

# 2. Shared files (persist across deployments)
ln -sf "$SHARED_DIR/.env" "$RELEASE_DIR/.env"
ln -sf "$SHARED_DIR/storage" "$RELEASE_DIR/storage"

# 3. Install dependencies
cd "$RELEASE_DIR"
composer install --no-dev --optimize-autoloader --no-interaction

# 4. Laravel optimizations
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
php artisan migrate --force

# 5. Swap symlink (zero-downtime)
ln -sfn "$RELEASE_DIR" "$CURRENT_LINK"

# 6. Restart services
sudo systemctl reload php8.3-fpm
sudo supervisorctl restart laravel-worker:*

# 7. Cleanup old releases (keep last 5)
cd "$APP_DIR/releases"
ls -dt */ | tail -n +6 | xargs rm -rf

echo "✅ Deployment complete!"
```

### Queue Worker (Supervisor)
```ini
; /etc/supervisor/conf.d/laravel-worker.conf
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/app/current/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/log/laravel-worker.log
stopwaitsecs=3600
```

---

## Docker Deployment

```dockerfile
FROM php:8.3-fpm-alpine

RUN apk add --no-cache nginx supervisor \
    && docker-php-ext-install pdo_mysql bcmath opcache

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader \
    && php artisan config:cache \
    && php artisan route:cache \
    && chown -R www-data:www-data storage bootstrap/cache

COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisord.conf

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
```

---

## CI/CD Pipeline (GitHub Actions)

```yaml
name: Deploy Laravel
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: mbstring, xml, curl, zip, mysql, redis

      - name: Install & Test
        run: |
          composer install --prefer-dist --no-interaction
          php artisan test

      - name: Deploy to Server
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /var/www/app
            bash deploy.sh
```

## Best Practices
1. **Zero-downtime** — symlink swap (`current` → `releases/timestamp`)
2. **Shared storage** — `.env` and `storage/` persist across deployments
3. **Cache everything** — `config:cache`, `route:cache`, `view:cache`
4. **Queue workers** — Supervisor for reliable background jobs
5. **PHP-FPM tuning** — `pm.max_children` based on RAM (1 worker ≈ 30MB)
6. **OPcache** — always enable in production
7. **ionCube** — encode business logic before deploy (see `skills/ioncube/`)
