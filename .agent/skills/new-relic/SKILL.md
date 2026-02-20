---
name: New Relic
description: Skill for New Relic — full-stack observability with APM, infrastructure monitoring, logs, browser monitoring, NRQL queries, and REST/NerdGraph API.
---

# New Relic Skill

## Overview
New Relic is a full-stack observability platform providing APM, infrastructure monitoring, log management, browser monitoring, synthetics, and NRQL for querying telemetry data. It supports auto-instrumentation for Node.js, Java, Python, and .NET.

**References**:
- [New Relic Documentation](https://docs.newrelic.com/)
- [NRQL Reference](https://docs.newrelic.com/docs/nrql/get-started/introduction-nrql-new-relics-query-language/)

---

## APM Setup (Node.js)

```javascript
// Must be first require
require('newrelic');

// newrelic.js config
exports.config = {
  app_name: ['MyApp API'],
  license_key: process.env.NEW_RELIC_LICENSE_KEY,
  distributed_tracing: { enabled: true },
  logging: { level: 'info' },
  allow_all_headers: true,
  attributes: { exclude: ['request.headers.cookie', 'request.headers.authorization'] },
};
```

---

## Custom Instrumentation

```javascript
const newrelic = require('newrelic');

// Custom transaction
newrelic.startBackgroundTransaction('processOrder', async () => {
  const transaction = newrelic.getTransaction();
  newrelic.addCustomAttributes({ orderId: order.id, userId: user.id, total: order.total });
  try {
    await processOrder(order);
  } catch (error) {
    newrelic.noticeError(error);
    throw error;
  } finally {
    transaction.end();
  }
});

// Custom events
newrelic.recordCustomEvent('OrderCreated', { orderId: order.id, total: order.total, channel: 'web' });

// Custom metrics
newrelic.recordMetric('Custom/OrderProcessingTime', durationMs);
```

---

## NRQL Queries

```sql
-- Error rate by endpoint
SELECT percentage(count(*), WHERE error IS true) FROM Transaction WHERE appName = 'MyApp API' FACET name SINCE 1 hour ago

-- Response time percentiles
SELECT percentile(duration, 50, 95, 99) FROM Transaction WHERE appName = 'MyApp API' SINCE 1 hour ago TIMESERIES

-- Throughput
SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName = 'MyApp API' FACET name SINCE 30 minutes ago
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **APM** | Auto-instrument with newrelic agent |
| **Custom events** | recordCustomEvent for business metrics |
| **Custom attributes** | Add context to transactions |
| **NRQL** | Query telemetry with SQL-like syntax |
| **Distributed tracing** | Track requests across services |
| **Alerts** | NRQL alert conditions |
| **Dashboards** | Custom NRQL-based dashboards |
| **Browser** | Real user monitoring for frontend |
| **Error tracking** | noticeError for custom error capture |
| **Deployment markers** | Track deploys with change tracking |

---

## Rules Integration
- **APM**: Auto-instrumentation with custom attributes
- **Events**: Custom business event recording
- **NRQL**: SQL-like queries for analysis
- **Alerting**: NRQL-based alert conditions
