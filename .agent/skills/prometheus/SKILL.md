---
name: Prometheus
description: Skill for metrics and monitoring with Prometheus — covering metric types, instrumentation, PromQL queries, alerting rules, Grafana dashboards, and service discovery.
---

# Prometheus Skill

## Overview
**Prometheus** is an open-source monitoring and alerting toolkit. It collects time-series metrics via a pull model, stores them locally, and supports powerful querying (PromQL) and alerting. Combined with **Grafana** for visualization.

```
App (exposes /metrics) ← Prometheus (scrapes) → Alertmanager → PagerDuty/Slack
                                                → Grafana (dashboards)
```

---

## Metric Types

| Type | Description | Example | Use |
|------|-------------|---------|-----|
| **Counter** | Monotonically increasing | `http_requests_total` | Requests, errors, events |
| **Gauge** | Goes up and down | `cpu_usage_percent` | Temperature, queue size |
| **Histogram** | Buckets of observations | `http_request_duration_seconds` | Latency percentiles |
| **Summary** | Client-side percentiles | `request_duration_summary` | Pre-calculated quantiles |

---

## Instrumentation: Node.js (Express)

```typescript
import express from 'express';
import client from 'prom-client';

// Default metrics (CPU, memory, event loop)
client.collectDefaultMetrics({ prefix: 'app_' });

// Custom metrics
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status_code'],
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
});

const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
});

// Middleware
function metricsMiddleware(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();
  activeConnections.inc();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      path: req.route?.path || req.path,
      status_code: res.statusCode.toString(),
    };
    
    httpRequestsTotal.inc(labels);
    httpRequestDuration.observe(labels, duration);
    activeConnections.dec();
  });
  
  next();
}

// Expose /metrics endpoint
app.use(metricsMiddleware);
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// Business metrics
const ordersCreated = new client.Counter({
  name: 'orders_created_total',
  help: 'Total orders created',
  labelNames: ['payment_method', 'status'],
});

const orderAmount = new client.Histogram({
  name: 'order_amount_rupiah',
  help: 'Order amount in Rupiah',
  buckets: [10000, 50000, 100000, 500000, 1000000, 5000000],
});

// Usage
ordersCreated.inc({ payment_method: 'credit_card', status: 'success' });
orderAmount.observe(750000);
```

---

## Instrumentation: Python (FastAPI)

```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from fastapi import FastAPI, Request, Response
import time

app = FastAPI()

REQUEST_COUNT = Counter('http_requests_total', 'Total requests', ['method', 'path', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'Request duration', ['method', 'path'])

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start = time.monotonic()
    response = await call_next(request)
    duration = time.monotonic() - start
    
    REQUEST_COUNT.labels(request.method, request.url.path, response.status_code).inc()
    REQUEST_DURATION.labels(request.method, request.url.path).observe(duration)
    return response

@app.get("/metrics")
async def metrics():
    return Response(content=generate_latest(), media_type="text/plain")
```

---

## Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alerts/*.yml"

scrape_configs:
  - job_name: 'api-server'
    static_configs:
      - targets: ['api:3000']
    metrics_path: '/metrics'
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  
  # Docker service discovery
  - job_name: 'docker'
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
    relabel_configs:
      - source_labels: [__meta_docker_container_label_prometheus_scrape]
        regex: 'true'
        action: keep

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
```

---

## PromQL Queries

```promql
# Request rate (req/s)
rate(http_requests_total[5m])

# Error rate percentage
sum(rate(http_requests_total{status_code=~"5.."}[5m]))
/ sum(rate(http_requests_total[5m])) * 100

# P95 latency
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

# P99 latency by path
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, path))

# Top 5 slowest endpoints
topk(5, avg(rate(http_request_duration_seconds_sum[5m])) by (path)
  / avg(rate(http_request_duration_seconds_count[5m])) by (path))

# Memory usage percentage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes)
/ node_memory_MemTotal_bytes * 100

# CPU usage
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

---

## Alerting Rules

```yaml
# alerts/app.yml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: sum(rate(http_requests_total{status_code=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate ({{ $value | humanizePercentage }})"
          
      - alert: HighLatency
        expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "P95 latency above 1s"
          
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Memory usage above 90%"
```

## Best Practices
1. **USE method** — Utilization, Saturation, Errors for every service
2. **RED method** — Rate, Errors, Duration for request-driven services
3. **Label cardinality** — keep label values low (<100 unique values)
4. **15s scrape interval** — balance between resolution and storage
5. **Recording rules** — pre-compute expensive queries
6. **Grafana dashboards** — per-service dashboard with SLI/SLO tracking
