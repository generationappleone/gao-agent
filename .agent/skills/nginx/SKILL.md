---
name: Nginx
description: Skill for configuring Nginx web server — covering reverse proxy, SSL/TLS, load balancing, caching, rate limiting, security headers, gzip compression, and virtual hosts.
---

# Nginx Skill

## Overview
Nginx is a high-performance HTTP server, reverse proxy, and load balancer. This skill covers Nginx configuration for production web applications.

**Reference**: [Nginx Documentation](https://nginx.org/en/docs/)

## Basic Server Block
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com www.example.com;

    # SSL
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';" always;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;

    root /var/www/example.com/public;
    index index.html index.php;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## Reverse Proxy (Node.js / API)
```nginx
upstream backend {
    server 127.0.0.1:3000;
    server 127.0.0.1:3001;
    keepalive 64;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 90s;
        proxy_connect_timeout 90s;
    }

    # Static files
    location /static/ {
        alias /var/www/app/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

## Rate Limiting
```nginx
# Define rate limit zone
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;

server {
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        limit_req_status 429;
        proxy_pass http://backend;
    }

    location /api/auth/login {
        limit_req zone=login burst=3 nodelay;
        proxy_pass http://backend;
    }
}
```

## Load Balancing
```nginx
upstream app_servers {
    least_conn;  # or: round_robin (default), ip_hash, hash
    server 10.0.0.1:3000 weight=3;
    server 10.0.0.2:3000 weight=2;
    server 10.0.0.3:3000 backup;
}
```

## PHP-FPM (Laravel)
```nginx
location ~ \.php$ {
    fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    include fastcgi_params;
    fastcgi_hide_header X-Powered-By;
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **HTTPS only** | Redirect all HTTP to HTTPS |
| **HTTP/2** | Enable `http2` for multiplexing |
| **Security headers** | Always set HSTS, CSP, X-Frame-Options |
| **Gzip** | Enable for text-based content types |
| **Rate limiting** | Protect API endpoints from abuse |
| **Proxy headers** | Always forward `X-Real-IP`, `X-Forwarded-For` |
| **WebSocket** | Set `Upgrade` and `Connection` headers |
| **Static caching** | Long `expires` for immutable assets |
| **Error pages** | Custom 404/500 pages |
| **Logging** | Access + error logs with rotation |
