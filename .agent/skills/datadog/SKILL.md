---
name: Datadog
description: Skill for application monitoring and synthetic testing with Datadog, covering APM, synthetic tests, log management, alerting, and CI/CD integration.
---

# Datadog Skill

## Overview
Datadog is a cloud monitoring and analytics platform providing APM (Application Performance Monitoring), infrastructure monitoring, log management, synthetic testing, and real user monitoring (RUM). It supports 700+ integrations.

**References**:
- [Datadog Documentation](https://docs.datadoghq.com/)
- [Datadog APM](https://docs.datadoghq.com/tracing/)

---

## APM Setup (Node.js)

```typescript
// Must be first import
import tracer from 'dd-trace';
tracer.init({
  service: 'myapp-api',
  env: process.env.NODE_ENV,
  version: process.env.APP_VERSION,
  logInjection: true,
  runtimeMetrics: true,
});

// Custom span
const span = tracer.startSpan('process.order');
span.setTag('order.id', orderId);
try {
  await processOrder(orderId);
  span.setTag('status', 'success');
} catch (error) {
  span.setTag('error', true);
  span.setTag('error.message', error.message);
  throw error;
} finally {
  span.finish();
}
```

---

## Custom Metrics

```typescript
import StatsD from 'hot-shots';

const dogstatsd = new StatsD({ host: process.env.DD_AGENT_HOST || 'localhost', port: 8125, prefix: 'myapp.' });

// Counter
dogstatsd.increment('orders.created', 1, { channel: 'web', status: 'success' });

// Histogram
dogstatsd.histogram('order.processing_time', durationMs, { status: 'success' });

// Gauge
dogstatsd.gauge('active_users', activeCount);

// Distribution
dogstatsd.distribution('api.response_time', responseTime, { endpoint: '/api/products' });
```

---

## Log Management

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json(),
  ),
  defaultMeta: { service: 'myapp-api', env: process.env.NODE_ENV },
  transports: [new winston.transports.Console()],
});

// Structured logs with Datadog correlation
logger.info('Order created', { orderId: order.id, userId: user.id, total: order.total, dd: { trace_id: span.context().toTraceId() } });
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **APM** | Auto-instrument with dd-trace |
| **Custom spans** | Track business operations |
| **Metrics** | DogStatsD for custom metrics |
| **Logs** | JSON format with trace correlation |
| **Dashboards** | Monitor SLIs/SLOs with dashboards |
| **Alerts** | Anomaly detection, threshold alerts |
| **Synthetics** | API and browser synthetic tests |
| **RUM** | Real User Monitoring for frontend |
| **Service map** | Visualize service dependencies |
| **Tags** | Consistent tagging (env, service, version) |

---

## Rules Integration
- **APM**: dd-trace for auto-instrumentation
- **Metrics**: DogStatsD for counters/histograms/gauges
- **Logs**: Winston with trace correlation
- **Alerting**: Anomaly and threshold-based alerts
