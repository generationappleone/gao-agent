---
name: Prometheus
description: Skill for metrics and monitoring with Prometheus — covering metric types, instrumentation, PromQL queries, alerting rules, Grafana dashboards, and service discovery.
---

# Prometheus Skill

## Overview
Prometheus is an open-source monitoring and alerting toolkit for collecting time-series metrics. It uses a pull-based model, PromQL for queries, and integrates with Grafana for visualization. Prometheus supports counters, gauges, histograms, and summaries.

**References**:
- [Prometheus Documentation](https://prometheus.io/docs/)
- [PromQL Guide](https://prometheus.io/docs/prometheus/latest/querying/basics/)

---

## Setup

```yaml
# docker-compose.yml
services:
  prometheus:
    image: prom/prometheus:latest
    ports: ["9090:9090"]
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  grafana:
    image: grafana/grafana:latest
    ports: ["3001:3000"]
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
```

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'myapp-api'
    static_configs:
      - targets: ['host.docker.internal:3000']
    metrics_path: /metrics

rule_files:
  - 'alerts.yml'

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
```

---

## Node.js Instrumentation

```typescript
import { Registry, Counter, Histogram, Gauge, collectDefaultMetrics } from 'prom-client';

const register = new Registry();
collectDefaultMetrics({ register });

const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 3, 5],
  registers: [register],
});

const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Active WebSocket connections',
  registers: [register],
});

// Middleware
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer({ method: req.method, route: req.route?.path || req.path });
  res.on('finish', () => {
    httpRequestsTotal.inc({ method: req.method, route: req.route?.path || req.path, status: res.statusCode });
    end();
  });
  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

---

## Alerting Rules

```yaml
# alerts.yml
groups:
  - name: myapp
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels: { severity: critical }
        annotations: { summary: "High error rate (>5%)" }

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels: { severity: warning }
        annotations: { summary: "P95 latency > 1s" }
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Counter** | Use for total counts (requests, errors) |
| **Histogram** | Use for durations with buckets |
| **Gauge** | Use for current values (connections, queue) |
| **Labels** | Add method, route, status dimensions |
| **Naming** | `app_subsystem_unit_total` convention |
| **Alerts** | Rate-based alerts with `for` duration |
| **Grafana** | Dashboard visualization for metrics |
| **Service discovery** | Auto-discover targets in K8s |
| **Retention** | Configure data retention period |
| **Federation** | Hierarchical Prometheus for scale |

---

## Rules Integration
- **Metrics**: Counter, Histogram, Gauge for HTTP/business
- **Collection**: Pull-based scraping at /metrics
- **Alerting**: Rules for error rate, latency, capacity
- **Visualization**: Grafana dashboards for monitoring
