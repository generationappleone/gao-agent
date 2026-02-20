---
name: OpenTelemetry
description: Skill for observability with OpenTelemetry (OTel) — covering traces, metrics, logs, auto-instrumentation, SDK setup, exporters, and integration with backends (Jaeger, Zipkin, Grafana Tempo).
---

# OpenTelemetry Skill

## Overview
OpenTelemetry (OTel) is the standard for distributed tracing, metrics, and logging. It provides vendor-neutral APIs, SDKs, and auto-instrumentation for Node.js, Python, Java, and Go. OTel collects telemetry data and exports to backends like Jaeger, Zipkin, Grafana Tempo, and Datadog.

**References**:
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [OTel Node.js](https://opentelemetry.io/docs/languages/js/)

---

## Setup (Node.js)

```typescript
// src/instrumentation.ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-http';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { Resource } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME, ATTR_SERVICE_VERSION } from '@opentelemetry/semantic-conventions';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';

const sdk = new NodeSDK({
  resource: new Resource({
    [ATTR_SERVICE_NAME]: 'myapp-api',
    [ATTR_SERVICE_VERSION]: '1.0.0',
  }),
  traceExporter: new OTLPTraceExporter({ url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT + '/v1/traces' }),
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter({ url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT + '/v1/metrics' }),
    exportIntervalMillis: 30000,
  }),
  instrumentations: [getNodeAutoInstrumentations({
    '@opentelemetry/instrumentation-http': { ignoreIncomingPaths: ['/health'] },
    '@opentelemetry/instrumentation-express': { enabled: true },
  })],
});

sdk.start();
process.on('SIGTERM', () => sdk.shutdown());
```

---

## Custom Spans

```typescript
import { trace, SpanStatusCode } from '@opentelemetry/api';

const tracer = trace.getTracer('myapp');

export async function processOrder(orderId: string) {
  return tracer.startActiveSpan('processOrder', async (span) => {
    span.setAttribute('order.id', orderId);
    try {
      const order = await tracer.startActiveSpan('fetchOrder', async (childSpan) => {
        const result = await db.order.findUnique({ where: { id: orderId } });
        childSpan.setAttribute('order.total', result?.total || 0);
        childSpan.end();
        return result;
      });
      span.setStatus({ code: SpanStatusCode.OK });
      return order;
    } catch (error) {
      span.setStatus({ code: SpanStatusCode.ERROR, message: (error as Error).message });
      span.recordException(error as Error);
      throw error;
    } finally {
      span.end();
    }
  });
}
```

---

## Custom Metrics

```typescript
import { metrics } from '@opentelemetry/api';

const meter = metrics.getMeter('myapp');
const orderCounter = meter.createCounter('orders.created', { description: 'Total orders created' });
const orderDuration = meter.createHistogram('orders.duration_ms', { description: 'Order processing duration' });
const activeUsers = meter.createUpDownCounter('users.active', { description: 'Active users' });

// Usage
orderCounter.add(1, { status: 'success', channel: 'web' });
orderDuration.record(235, { status: 'success' });
activeUsers.add(1); // on login
activeUsers.add(-1); // on logout
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Auto-instrumentation** | Use for HTTP, Express, DB, Redis |
| **Service name** | Set via ATTR_SERVICE_NAME |
| **Custom spans** | Add for business logic operations |
| **Attributes** | Add relevant context (order.id, user.id) |
| **Error recording** | recordException + SpanStatusCode.ERROR |
| **Metrics** | Counter, Histogram, UpDownCounter |
| **Context propagation** | W3C Trace Context for distributed tracing |
| **Sampling** | Configure head/tail sampling in production |
| **Health endpoint** | Exclude from tracing |
| **OTLP** | Use OTLP protocol for vendor-neutral export |

---

## Rules Integration
- **SDK**: Auto-instrumentation + custom spans/metrics
- **Tracing**: Distributed traces across services
- **Metrics**: Counters, histograms for business metrics
- **Export**: OTLP to Jaeger, Tempo, Datadog, New Relic
