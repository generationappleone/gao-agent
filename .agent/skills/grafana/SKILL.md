---
name: Grafana
description: Skill for Grafana — open-source dashboard and visualization platform with multi-datasource support, alerting, and HTTP API.
---

# Grafana Skill

## Overview
Grafana is the leading open-source platform for monitoring and observability dashboards. It connects to Prometheus, Elasticsearch, PostgreSQL, MySQL, and 100+ data sources. Grafana provides rich visualizations, alerting, and provisioning via code.

**References**:
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Grafana HTTP API](https://grafana.com/docs/grafana/latest/developers/http_api/)

---

## Setup

```yaml
services:
  grafana:
    image: grafana/grafana:latest
    ports: ["3001:3000"]
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
      GF_INSTALL_PLUGINS: grafana-clock-panel,grafana-simple-json-datasource
    volumes:
      - grafana_data:/var/lib/grafana
      - ./provisioning:/etc/grafana/provisioning
```

---

## Provisioning Datasource

```yaml
# provisioning/datasources/prometheus.yml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

  - name: PostgreSQL
    type: postgres
    url: postgres:5432
    database: myapp
    user: grafana_reader
    jsonData: { sslmode: disable, maxOpenConns: 10 }
    secureJsonData: { password: ${PG_PASSWORD} }
```

---

## Dashboard (JSON Model)

```json
{
  "dashboard": {
    "title": "MyApp Overview",
    "panels": [
      {
        "title": "Request Rate",
        "type": "timeseries",
        "gridPos": { "h": 8, "w": 12, "x": 0, "y": 0 },
        "targets": [{
          "expr": "rate(http_requests_total[5m])",
          "legendFormat": "{{method}} {{route}}"
        }]
      },
      {
        "title": "P95 Latency",
        "type": "gauge",
        "gridPos": { "h": 8, "w": 6, "x": 12, "y": 0 },
        "targets": [{
          "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
        }],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "steps": [
                { "color": "green", "value": null },
                { "color": "yellow", "value": 0.5 },
                { "color": "red", "value": 1 }
              ]
            },
            "unit": "s"
          }
        }
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "gridPos": { "h": 4, "w": 6, "x": 18, "y": 0 },
        "targets": [{
          "expr": "rate(http_requests_total{status=~'5..'}[5m]) / rate(http_requests_total[5m]) * 100"
        }],
        "fieldConfig": { "defaults": { "unit": "%", "color": { "mode": "thresholds" } } }
      }
    ]
  }
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Provisioning** | Datasources and dashboards as code |
| **Variables** | Template variables for dynamic filtering |
| **Annotations** | Mark deployments, incidents on graphs |
| **Alerting** | Alert rules with notification channels |
| **Panels** | Time series, gauge, stat, table, heatmap |
| **PromQL** | rate(), histogram_quantile(), sum by() |
| **Folders** | Organize dashboards by team/service |
| **RBAC** | Role-based access for teams |
| **Explore** | Ad-hoc queries for troubleshooting |
| **JSON model** | Version control dashboard definitions |

---

## Rules Integration
- **Setup**: Docker with provisioning for datasources
- **Dashboards**: JSON model with panels and PromQL
- **Alerting**: Threshold-based alerts with notifications
- **Visualization**: Time series, gauges, stats, tables
