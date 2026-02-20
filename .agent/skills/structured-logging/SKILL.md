---
name: Structured Logging
description: Skill for structured logging — covering JSON log format, log levels, context propagation, correlation IDs, request tracing, sensitive data redaction, and logging libraries (Winston, Pino, Python logging).
---

# Structured Logging Skill

## Overview
Structured logging outputs logs as JSON objects with consistent fields, enabling machine parsing, search, and aggregation. It supports correlation IDs for request tracing, log levels, context propagation, and sensitive data redaction.

**References**:
- [Pino Documentation](https://getpino.io/)
- [Winston Documentation](https://github.com/winstonjs/winston)

---

## Pino Logger Setup

```typescript
// src/lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: process.env.NODE_ENV === 'development' ? { target: 'pino-pretty', options: { colorize: true } } : undefined,
  redact: ['req.headers.authorization', 'req.headers.cookie', 'password', '*.password', '*.token'],
  serializers: { err: pino.stdSerializers.err, req: pino.stdSerializers.req, res: pino.stdSerializers.res },
  base: { service: 'myapp-api', env: process.env.NODE_ENV, version: process.env.APP_VERSION },
});
```

---

## Request Context & Correlation

```typescript
// src/middleware/request-context.ts
import { randomUUID } from 'crypto';
import { AsyncLocalStorage } from 'async_hooks';

interface RequestContext { requestId: string; userId?: string; ip: string; method: string; path: string; }
export const als = new AsyncLocalStorage<RequestContext>();

export function requestContextMiddleware(req: Request, res: Response, next: NextFunction) {
  const requestId = (req.headers['x-request-id'] as string) || randomUUID();
  res.setHeader('x-request-id', requestId);

  const context: RequestContext = { requestId, userId: req.user?.id, ip: req.ip!, method: req.method, path: req.path };
  als.run(context, () => next());
}

// Context-aware logger
export function getLogger() {
  const ctx = als.getStore();
  return ctx ? logger.child({ requestId: ctx.requestId, userId: ctx.userId }) : logger;
}

// Usage
const log = getLogger();
log.info({ orderId: order.id, total: order.total }, 'Order created successfully');
log.error({ err, orderId }, 'Payment processing failed');
```

---

## Request Logging Middleware

```typescript
export function requestLoggingMiddleware(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    const log = getLogger();
    const logData = { method: req.method, path: req.path, status: res.statusCode, duration, userAgent: req.headers['user-agent'] };
    if (res.statusCode >= 500) log.error(logData, 'Request error');
    else if (res.statusCode >= 400) log.warn(logData, 'Request warning');
    else log.info(logData, 'Request completed');
  });
  next();
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **JSON format** | Structured JSON for machine parsing |
| **Correlation ID** | Request ID across service boundaries |
| **Log levels** | error, warn, info, debug, trace |
| **Redaction** | Redact passwords, tokens, PII |
| **Context** | AsyncLocalStorage for request context |
| **Pino** | Fastest Node.js logger |
| **Child loggers** | Add context with logger.child() |
| **Request logging** | Log method, path, status, duration |
| **Serializers** | Custom error/request serializers |
| **Pretty print** | Development-only pretty formatting |

---

## Rules Integration
- **Logger**: Pino with redaction and serializers
- **Context**: AsyncLocalStorage for correlation
- **Middleware**: Request logging with duration/status
- **Child loggers**: Context-aware child loggers
