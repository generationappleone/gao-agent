---
name: Datadog
description: Skill for application monitoring and synthetic testing with Datadog, covering APM, synthetic tests, log management, alerting, and CI/CD integration.
---

# Datadog Skill

## Overview
Datadog is an observability platform providing APM, infrastructure monitoring, log management, synthetic testing, and security monitoring. Requires an account and API key.

## Setup
```bash
# Install Datadog Agent
DD_API_KEY=your_api_key DD_SITE="datadoghq.com" bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script.sh)"

# NPM packages for Node.js APM
npm install dd-trace --save

# Environment variables
DD_API_KEY=your_api_key
DD_APP_KEY=your_app_key
DD_SITE=datadoghq.com
```

## APM (Application Performance Monitoring)

### Node.js
```javascript
// tracing.js — require FIRST before anything else
const tracer = require('dd-trace').init({
  service: 'my-api',
  env: process.env.NODE_ENV || 'development',
  version: '1.0.0',
  logInjection: true,
  runtimeMetrics: true,
});
module.exports = tracer;

// In app entry: require('./tracing');
```

### Python
```bash
pip install ddtrace
ddtrace-run python app.py
```

### PHP (Laravel)
```bash
# Install extension
pecl install datadog_trace
# Add to php.ini:
# extension=ddtrace.so
# datadog.service=my-laravel-app
# datadog.env=production
```

## Synthetic Testing

### API Test (via Datadog API)
```bash
curl -X POST "https://api.datadoghq.com/api/v1/synthetics/tests/api" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "API Health Check",
    "type": "api",
    "subtype": "http",
    "config": {
      "request": {
        "method": "GET",
        "url": "https://myapp.com/api/health"
      },
      "assertions": [
        { "type": "statusCode", "operator": "is", "target": 200 },
        { "type": "responseTime", "operator": "lessThan", "target": 500 }
      ]
    },
    "locations": ["aws:us-east-1", "aws:eu-west-1"],
    "options": {
      "tick_every": 300,
      "min_failure_duration": 0,
      "min_location_failed": 1
    },
    "message": "API health check failed!",
    "tags": ["env:production", "service:api"]
  }'
```

### Browser Test (via Datadog API)
```bash
curl -X POST "https://api.datadoghq.com/api/v1/synthetics/tests/browser" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -d '{
    "name": "Login Flow Test",
    "type": "browser",
    "config": {
      "request": { "url": "https://myapp.com/login" },
      "variables": []
    },
    "locations": ["aws:us-east-1"],
    "options": { "tick_every": 3600 },
    "tags": ["env:production"]
  }'
```

## Monitors (Alerting)

### Create Monitor via API
```bash
curl -X POST "https://api.datadoghq.com/api/v1/monitor" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -d '{
    "name": "High Error Rate",
    "type": "metric alert",
    "query": "sum(last_5m):sum:trace.http.request.errors{service:my-api}.as_count() > 50",
    "message": "Error rate exceeded threshold! @slack-alerts @pagerduty",
    "tags": ["service:my-api", "env:production"],
    "options": {
      "thresholds": { "critical": 50, "warning": 25 },
      "notify_no_data": true,
      "no_data_timeframe": 10
    }
  }'
```

## CI/CD Integration
```yaml
# GitHub Actions — run synthetic tests
- name: Datadog Synthetics
  uses: DataDog/synthetics-ci-github-action@v1
  with:
    api_key: ${{ secrets.DD_API_KEY }}
    app_key: ${{ secrets.DD_APP_KEY }}
    public_ids: 'abc-123,def-456'
    fail_on_critical_errors: true
```

## Best Practices
- Use consistent `service`, `env`, `version` tags across all telemetry
- Set up SLOs (Service Level Objectives) for critical endpoints
- Use composite monitors to reduce alert fatigue
- Enable log correlation with APM traces
- Set up dashboards for key business metrics
- Use anomaly detection for dynamic thresholds
