---
name: Load Balancing
description: Skill for implementing load balancing strategies with Nginx, HAProxy, and cloud load balancers, covering algorithms, health checks, SSL termination, and high availability patterns.
---

# Load Balancing Skill

## Overview
Load balancing distributes traffic across multiple server instances for high availability and scalability. Nginx and HAProxy are the most common software load balancers. Cloud providers offer managed load balancers (AWS ALB/NLB, Azure LB, GCP LB).

**References**:
- [Nginx Load Balancing](https://docs.nginx.com/nginx/admin-guide/load-balancer/)
- [HAProxy Documentation](https://www.haproxy.org/#doc)

---

## Nginx Load Balancing

```nginx
# /etc/nginx/conf.d/loadbalancer.conf
upstream api_backend {
    least_conn;  # Algorithm: least_conn, round_robin, ip_hash
    server app1:3000 weight=3 max_fails=3 fail_timeout=30s;
    server app2:3000 weight=2 max_fails=3 fail_timeout=30s;
    server app3:3000 backup;  # standby server

    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name api.myapp.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location / {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 5s;
        proxy_read_timeout 60s;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location /health {
        proxy_pass http://api_backend/health;
        access_log off;
    }
}
```

---

## Docker Compose (Multi-Instance)

```yaml
services:
  nginx:
    image: nginx:alpine
    ports: ["443:443"]
    volumes: [./nginx.conf:/etc/nginx/conf.d/default.conf]
    depends_on: [app1, app2, app3]

  app1: &app
    build: .
    environment: { NODE_ENV: production, PORT: 3000 }
  app2: *app
  app3: *app
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Algorithm** | Round-robin, least_conn, ip_hash |
| **Health checks** | Verify backend health periodically |
| **SSL termination** | Terminate SSL at load balancer |
| **Sticky sessions** | ip_hash for stateful applications |
| **Weights** | Unequal distribution for varied capacity |
| **Backup** | Standby server for failover |
| **Keepalive** | Persistent connections to backends |
| **Timeouts** | Configure connect/read timeouts |
| **Horizontal scaling** | Add instances behind LB |
| **Cloud LB** | Use managed LB (ALB, NLB) in cloud |

---

## Rules Integration
- **Nginx**: Upstream blocks with algorithm selection
- **Health**: Backend health checking
- **SSL**: TLS termination at load balancer
- **Docker**: Multi-instance with docker-compose
