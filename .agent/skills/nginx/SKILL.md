---
name: Nginx
description: Skill for configuring Nginx web server — covering reverse proxy, SSL/TLS, load balancing, caching, rate limiting, security headers, gzip compression, and virtual hosts.
---

# Nginx Skill

## Overview
Nginx is a high-performance HTTP server, reverse proxy, and load balancer. It handles static file serving, SSL termination, rate limiting, caching, and upstream proxying. Nginx is essential for production deployments.

**References**:
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Nginx Admin Guide](https://docs.nginx.com/nginx/admin-guide/)

---

## Main Configuration

```nginx
# /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    multi_accept on;
    use epoll;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # ── Logging ──
    log_format main '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent" '
                    '$request_time $upstream_response_time';
    access_log /var/log/nginx/access.log main;

    # ── Performance ──
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    keepalive_requests 100;
    client_max_body_size 50m;

    # ── Gzip ──
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript
               text/xml application/xml text/javascript image/svg+xml;

    # ── Security Headers ──
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # ── Rate Limiting ──
    limit_req_zone $binary_remote_addr zone=api:10m rate=30r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    limit_conn_zone $binary_remote_addr zone=conn:10m;

    # ── Upstream ──
    upstream app_backend {
        least_conn;
        server app:3000 max_fails=3 fail_timeout=30s;
        # server app2:3000 max_fails=3 fail_timeout=30s;  # Add for load balancing
        keepalive 32;
    }

    include /etc/nginx/conf.d/*.conf;
}
```

---

## Reverse Proxy + SSL

```nginx
# /etc/nginx/conf.d/app.conf
# HTTP → HTTPS redirect
server {
    listen 80;
    server_name myapp.com www.myapp.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name myapp.com www.myapp.com;

    # ── SSL ──
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;

    # ── API Proxy ──
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        limit_conn conn 50;

        proxy_pass http://app_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";

        proxy_connect_timeout 5s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;

        # CORS
        add_header Access-Control-Allow-Origin $http_origin always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;

        if ($request_method = OPTIONS) {
            return 204;
        }
    }

    # ── Auth endpoints (stricter rate limit) ──
    location /api/auth/login {
        limit_req zone=login burst=3 nodelay;
        proxy_pass http://app_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # ── WebSocket ──
    location /ws/ {
        proxy_pass http://app_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 86400s;
    }

    # ── Static files (SPA) ──
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ /index.html;

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2?)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            access_log off;
        }
    }

    # ── Uploads ──
    location /uploads/ {
        alias /var/www/uploads/;
        expires 30d;
        add_header Cache-Control "public";
        access_log off;
    }

    # ── Health check ──
    location /health {
        access_log off;
        return 200 "OK";
        add_header Content-Type text/plain;
    }

    # ── Block sensitive paths ──
    location ~ /\.(env|git|htaccess) {
        deny all;
        return 404;
    }
}
```

---

## Load Balancing

```nginx
# Multiple upstream servers
upstream app_cluster {
    # Algorithms: round-robin (default), least_conn, ip_hash, hash
    least_conn;

    server app1:3000 weight=3;    # 3x traffic
    server app2:3000 weight=2;    # 2x traffic
    server app3:3000 weight=1;    # 1x traffic
    server app4:3000 backup;      # Only when others are down

    keepalive 64;
}
```

---

## Caching

```nginx
# Proxy cache
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m
                 max_size=1g inactive=60m use_temp_path=off;

location /api/products {
    proxy_pass http://app_backend;
    proxy_cache api_cache;
    proxy_cache_valid 200 10m;
    proxy_cache_valid 404 1m;
    proxy_cache_key "$request_uri";
    proxy_cache_use_stale error timeout updating;
    add_header X-Cache-Status $upstream_cache_status;
}
```

---

## Commands

```bash
# Test configuration
nginx -t

# Reload (no downtime)
nginx -s reload

# Start / Stop
systemctl start nginx
systemctl stop nginx
systemctl restart nginx

# Check status
systemctl status nginx

# View logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **SSL/TLS** | TLS 1.2+ only, HSTS header, strong ciphers |
| **Rate limiting** | Zone-based limits per IP for API and login |
| **Gzip** | Compress text, JSON, CSS, JS, SVG |
| **Security headers** | X-Frame-Options, CSP, X-Content-Type-Options |
| **Static caching** | Long-lived cache (1y) for hashed/immutable assets |
| **Upstream keepalive** | Reuse connections to backend servers |
| **try_files** | SPA fallback with `try_files $uri /index.html` |
| **Block sensitive** | Deny access to `.env`, `.git`, `.htaccess` |
| **Logging** | Custom log format with response time |
| **Health endpoint** | Lightweight `/health` for monitoring |

---

## Rules Integration
- **Proxy**: Reverse proxy to upstream with keepalive
- **SSL**: TLS termination with Let's Encrypt certificates
- **Security**: Rate limiting, headers, block sensitive paths
- **Performance**: Gzip, static caching, upstream connection pooling
- **WebSocket**: Upgrade headers for WS proxy
