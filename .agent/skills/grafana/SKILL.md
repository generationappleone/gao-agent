---
name: Grafana
description: Skill for Grafana — open-source dashboard and visualization platform with multi-datasource support, alerting, and HTTP API.
---

# Grafana — Dashboard & Visualization

## Overview
Grafana is an open-source analytics and visualization platform supporting 50+ data sources (Prometheus, Elasticsearch, InfluxDB, CloudWatch, etc.) with rich dashboards and alerting.

## HTTP API
```python
import requests
headers = {"Authorization": "Bearer YOUR_API_KEY"}

# Get dashboards
dashboards = requests.get("http://grafana:3000/api/search", headers=headers)

# Create dashboard
requests.post("http://grafana:3000/api/dashboards/db", headers=headers, json={
    "dashboard": {
        "title": "Service Metrics",
        "panels": [{
            "type": "timeseries",
            "title": "Request Rate",
            "targets": [{"expr": "rate(http_requests_total[5m])"}]
        }]
    }
})

# Get datasources
datasources = requests.get("http://grafana:3000/api/datasources", headers=headers)
```

## Best Practices
- Use **provisioning** (YAML) for configuration-as-code
- Implement **dashboard variables** for dynamic filtering
- Configure **unified alerting** with contact points
