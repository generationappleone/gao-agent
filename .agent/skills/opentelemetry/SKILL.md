---
name: OpenTelemetry
description: Skill for observability with OpenTelemetry (OTel) — covering traces, metrics, logs, auto-instrumentation, SDK setup, exporters, and integration with backends (Jaeger, Zipkin, Grafana Tempo).
---

# OpenTelemetry Skill

## Overview
**OpenTelemetry (OTel)** is the vendor-neutral observability standard for generating, collecting, and exporting **traces**, **metrics**, and **logs**. It replaces OpenTracing and OpenCensus as the industry standard.

```
┌──────────────────────────────────────────────────────────────┐
│                  OPENTELEMETRY ARCHITECTURE                   │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  App (SDK)                 Collector              Backend    │
│  ┌────────┐              ┌──────────┐          ┌──────────┐ │
│  │Traces  │─── OTLP ────│ Receive  │── Jaeger │ Jaeger   │ │
│  │Metrics │─────────────│ Process  │── Prom   │ Grafana  │ │
│  │Logs    │              │ Export   │── Loki   │ Tempo    │ │
│  └────────┘              └──────────┘          └──────────┘ │
│                                                              │
│  3 Signals: Traces + Metrics + Logs                         │
│  Protocol: OTLP (OpenTelemetry Protocol)                    │
│  Export: gRPC or HTTP                                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Node.js Setup

```bash
npm install @opentelemetry/api @opentelemetry/sdk-node \
  @opentelemetry/auto-instrumentations-node \
  @opentelemetry/exporter-trace-otlp-http \
  @opentelemetry/exporter-metrics-otlp-http
```

```typescript
// tracing.ts — Initialize BEFORE any imports
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-http';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { Resource } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME, ATTR_SERVICE_VERSION } from '@opentelemetry/semantic-conventions';

const sdk = new NodeSDK({
  resource: new Resource({
    [ATTR_SERVICE_NAME]: process.env.SERVICE_NAME || 'my-api',
    [ATTR_SERVICE_VERSION]: process.env.APP_VERSION || '1.0.0',
    'deployment.environment': process.env.NODE_ENV || 'development',
  }),
  
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
  }),
  
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter({
      url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/metrics',
    }),
    exportIntervalMillis: 15000,
  }),
  
  instrumentations: [
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-http': { enabled: true },
      '@opentelemetry/instrumentation-express': { enabled: true },
      '@opentelemetry/instrumentation-pg': { enabled: true },
      '@opentelemetry/instrumentation-redis': { enabled: true },
    }),
  ],
});

sdk.start();
process.on('SIGTERM', () => sdk.shutdown());

// ✅ Auto-instruments: HTTP, Express, pg, Redis, fetch, etc.
```

### Custom Spans
```typescript
import { trace, SpanStatusCode } from '@opentelemetry/api';

const tracer = trace.getTracer('my-service');

async function processOrder(orderId: string) {
  return tracer.startActiveSpan('process_order', async (span) => {
    try {
      span.setAttribute('order.id', orderId);
      
      // Child span for payment
      await tracer.startActiveSpan('process_payment', async (paymentSpan) => {
        paymentSpan.setAttribute('payment.method', 'credit_card');
        await chargeCustomer(orderId);
        paymentSpan.end();
      });
      
      // Child span for notification
      await tracer.startActiveSpan('send_notification', async (notifSpan) => {
        await sendEmail(orderId);
        notifSpan.end();
      });
      
      span.setStatus({ code: SpanStatusCode.OK });
    } catch (error) {
      span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
      span.recordException(error);
      throw error;
    } finally {
      span.end();
    }
  });
}
```

---

## Python Setup

```bash
pip install opentelemetry-api opentelemetry-sdk \
  opentelemetry-exporter-otlp \
  opentelemetry-instrumentation-fastapi \
  opentelemetry-instrumentation-sqlalchemy \
  opentelemetry-instrumentation-redis
```

```python
# tracing.py
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

resource = Resource.create({
    "service.name": "my-api",
    "service.version": "1.0.0",
    "deployment.environment": os.getenv("ENV", "development"),
})

provider = TracerProvider(resource=resource)
processor = BatchSpanProcessor(OTLPSpanExporter(endpoint="http://localhost:4317"))
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

# Auto-instrument FastAPI
FastAPIInstrumentor.instrument_app(app)

# Custom spans
tracer = trace.get_tracer(__name__)

@app.post("/orders")
async def create_order(data: OrderInput):
    with tracer.start_as_current_span("create_order") as span:
        span.set_attribute("order.amount", data.amount)
        result = await order_service.create(data)
        return result
```

---

## OpenTelemetry Collector

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 5s
    send_batch_size: 1024
  
  attributes:
    actions:
      - key: "password"
        action: delete
      - key: "token"
        action: delete

exporters:
  # Traces
  otlp/jaeger:
    endpoint: jaeger:4317
    tls:
      insecure: true
  
  # Metrics
  prometheusremotewrite:
    endpoint: "http://prometheus:9090/api/v1/write"
  
  # Logs
  loki:
    endpoint: "http://loki:3100/loki/api/v1/push"

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch, attributes]
      exporters: [otlp/jaeger]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheusremotewrite]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [loki]
```

---

## Context Propagation (W3C Trace Context)

```
Request Header:
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
             ├──┤├────────────────────────────────┤├──────────────┤├─┤
           version          trace-id                  span-id     flags

Propagated automatically:
Service A → Service B → Service C
  span-1      span-2      span-3
  └── Same trace-id across all services
```

## Best Practices
1. **Auto-instrumentation first** — instrument HTTP, DB, cache automatically
2. **Custom spans for business logic** — order processing, payment, etc.
3. **Use Collector** — don't export directly from app to backend
4. **W3C Trace Context** — standard header propagation
5. **Set resource attributes** — service.name, service.version, environment
6. **Sample in production** — 100% tracing is expensive, sample 10-100%
7. **3 signals** — traces + metrics + logs correlated by traceId
