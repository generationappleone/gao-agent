---
name: Load Balancing
description: Skill for implementing load balancing strategies with Nginx, HAProxy, and cloud load balancers, covering algorithms, health checks, SSL termination, and high availability patterns.
---

# Load Balancing Skill

## Overview
Load balancing distributes traffic across multiple servers for high availability, scalability, and fault tolerance. This skill covers Nginx, HAProxy, and cloud load balancer configurations.

## Load Balancing Algorithms
| Algorithm | Description | Best For |
|-----------|-------------|----------|
| **Round Robin** | Rotates requests sequentially | Equal-capacity servers |
| **Least Connections** | Routes to server with fewest active connections | Varying request durations |
| **Weighted Round Robin** | Proportional distribution by server weight | Mixed-capacity servers |
| **IP Hash** | Same client IP → same server (sticky) | Session affinity needed |
| **Least Time** | Routes to fastest responding server | Performance-critical apps |
| **Random** | Random server selection | Large, uniform clusters |

---

## 1. Nginx Load Balancer

### Basic Configuration
```nginx
# /etc/nginx/nginx.conf
http {
    # ─── Upstream: Define backend servers ─────────
    upstream api_backend {
        least_conn;  # Algorithm

        server 10.0.1.10:3000 weight=5;   # Higher capacity
        server 10.0.1.11:3000 weight=3;
        server 10.0.1.12:3000 weight=2;
        server 10.0.1.13:3000 backup;     # Only used if others are down

        # Health check
        keepalive 32;
    }

    upstream websocket_backend {
        ip_hash;  # Sticky sessions for WebSocket
        server 10.0.2.10:8080;
        server 10.0.2.11:8080;
    }

    # ─── Server: SSL Termination + Proxy ──────────
    server {
        listen 443 ssl http2;
        server_name api.myapp.com;

        # SSL
        ssl_certificate     /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_ciphers         HIGH:!aNULL:!MD5;
        ssl_session_cache   shared:SSL:10m;
        ssl_session_timeout 10m;

        # Security headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # Rate limiting
        limit_req_zone $binary_remote_addr zone=api:10m rate=100r/s;

        # ─── API routes ──────────────────────────
        location /api/ {
            limit_req zone=api burst=50 nodelay;

            proxy_pass http://api_backend;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Connection "";

            # Timeouts
            proxy_connect_timeout 10s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;

            # Buffering
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
        }

        # ─── WebSocket ───────────────────────────
        location /ws/ {
            proxy_pass http://websocket_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 86400;
        }

        # ─── Static files (bypass backend) ────────
        location /static/ {
            alias /var/www/myapp/static/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # ─── Health check endpoint ────────────────
        location /nginx-health {
            access_log off;
            return 200 "healthy\n";
        }
    }

    # HTTP → HTTPS redirect
    server {
        listen 80;
        server_name api.myapp.com;
        return 301 https://$host$request_uri;
    }
}
```

### Nginx Health Checks (nginx-plus or third-party module)
```nginx
upstream api_backend {
    zone backend 64k;
    server 10.0.1.10:3000;
    server 10.0.1.11:3000;

    # Active health check (Nginx Plus)
    health_check interval=10 fails=3 passes=2 uri=/health;
}
```

---

## 2. HAProxy Load Balancer

```haproxy
# /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    maxconn 50000
    user haproxy
    group haproxy
    daemon
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    option  forwardfor
    timeout connect 5s
    timeout client  30s
    timeout server  30s
    timeout http-request 10s
    timeout http-keep-alive 15s

    # Error pages
    errorfile 503 /etc/haproxy/errors/503.http

# ─── Stats Dashboard ─────────────────────
frontend stats
    bind *:8404
    stats enable
    stats uri /stats
    stats realm HAProxy\ Stats
    stats auth admin:secure_password

# ─── Frontend (SSL Termination) ──────────
frontend https_front
    bind *:443 ssl crt /etc/haproxy/ssl/myapp.pem alpn h2,http/1.1
    bind *:80
    redirect scheme https code 301 if !{ ssl_fc }

    # Rate limiting
    stick-table type ip size 100k expire 30s store http_req_rate(10s)
    http-request deny deny_status 429 if { sc_http_req_rate(0) gt 100 }
    http-request track-sc0 src

    # Route by path
    acl is_api path_beg /api
    acl is_ws  path_beg /ws

    use_backend api_servers if is_api
    use_backend ws_servers  if is_ws
    default_backend web_servers

# ─── Backend: API Servers ─────────────────
backend api_servers
    balance leastconn
    option httpchk GET /health
    http-check expect status 200

    server api1 10.0.1.10:3000 check inter 10s fall 3 rise 2 weight 5
    server api2 10.0.1.11:3000 check inter 10s fall 3 rise 2 weight 3
    server api3 10.0.1.12:3000 check inter 10s fall 3 rise 2 weight 2 backup

# ─── Backend: WebSocket Servers ───────────
backend ws_servers
    balance source  # Sticky by source IP
    option httpchk GET /health
    timeout server 86400s
    timeout tunnel 86400s

    server ws1 10.0.2.10:8080 check
    server ws2 10.0.2.11:8080 check

# ─── Backend: Web (Static) ───────────────
backend web_servers
    balance roundrobin
    option httpchk GET /
    server web1 10.0.3.10:80 check
    server web2 10.0.3.11:80 check
```

---

## 3. Cloud Load Balancers (Terraform)

### AWS ALB
```hcl
resource "aws_lb" "main" {
  name               = "myapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = true
  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "api" {
  name        = "myapp-api-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = false
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
```

## High Availability Pattern
```
                    ┌──────────────┐
    Internet ──────►│  DNS (Route53)│
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
        ┌──────────┐             ┌──────────┐
        │  LB (AZ1)│             │  LB (AZ2)│  ← Active-Active
        └────┬─────┘             └────┬─────┘
             │                        │
    ┌────────┼────────┐     ┌────────┼────────┐
    ▼        ▼        ▼     ▼        ▼        ▼
  App1     App2     App3  App4     App5     App6
    │        │        │     │        │        │
    └────────┼────────┘     └────────┼────────┘
             ▼                       ▼
        ┌──────────┐           ┌──────────┐
        │  DB (Pri)│◄─────────►│  DB (Rep)│  ← Replication
        └──────────┘           └──────────┘
```

## Rules Integration
- **Security**: SSL termination, rate limiting, security headers at LB level
- **ISO 27017**: Multi-AZ deployment, health checks, automatic failover
- **Docker/K8s**: Load balancers front containerized applications
