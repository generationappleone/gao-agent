---
name: Structured Logging
description: Skill for structured logging — covering JSON log format, log levels, context propagation, correlation IDs, request tracing, sensitive data redaction, and logging libraries (Winston, Pino, Python logging).
---

# Structured Logging Skill

## Overview
**Structured logging** outputs log entries as machine-parseable JSON instead of plain text. This enables powerful querying, alerting, and analysis in log management systems. This skill covers log format standards, log levels, context propagation, and implementation patterns.

---

## Structured vs Unstructured

```
❌ Unstructured (hard to parse, search, aggregate):
[2025-02-19 10:30:15] INFO: User john@email.com logged in from 192.168.1.1

✅ Structured (JSON, machine-parseable):
{
  "timestamp": "2025-02-19T10:30:15.123Z",
  "level": "info",
  "message": "user_login_success",
  "service": "auth-service",
  "version": "1.2.0",
  "environment": "production",
  "requestId": "req-abc123",
  "traceId": "trace-xyz789",
  "userId": "usr-456",
  "ip": "192.168.1.1",
  "userAgent": "Mozilla/5.0...",
  "duration_ms": 145
}
```

---

## Log Levels

```
┌──────────────────────────────────────────────────────────────┐
│                     LOG LEVELS                               │
├──────────┬───────────────────────────────────────────────────┤
│ Level    │ When to Use                                       │
├──────────┼───────────────────────────────────────────────────┤
│ FATAL    │ System is unusable. Requires immediate action.    │
│          │ → Database connection lost, out of memory         │
│          │ → Alert: PagerDuty immediately                    │
├──────────┼───────────────────────────────────────────────────┤
│ ERROR    │ Operation failed. Needs attention.                │
│          │ → API call failed, payment declined               │
│          │ → Alert: Within 15 minutes                        │
├──────────┼───────────────────────────────────────────────────┤
│ WARN     │ Unexpected but recoverable. Potential issue.      │
│          │ → Retry succeeded, cache miss, slow query         │
│          │ → Alert: If threshold exceeded (>10/min)          │
├──────────┼───────────────────────────────────────────────────┤
│ INFO     │ Normal operations. Business events.               │
│          │ → User logged in, order created, deploy started   │
│          │ → Alert: None (used for dashboards)               │
├──────────┼───────────────────────────────────────────────────┤
│ DEBUG    │ Detailed diagnostic. Dev/staging only.            │
│          │ → Function inputs/outputs, SQL queries            │
│          │ → Alert: None (disabled in production)            │
├──────────┼───────────────────────────────────────────────────┤
│ TRACE    │ Very detailed. Framework/library level.           │
│          │ → HTTP headers, full request/response bodies      │
│          │ → Alert: None (only for troubleshooting)          │
└──────────┴───────────────────────────────────────────────────┘

Production log level: INFO (include INFO, WARN, ERROR, FATAL)
Staging log level:    DEBUG (include all except TRACE)
```

---

## Standard Log Fields

```typescript
// ✅ Every log entry MUST include:
interface LogEntry {
  timestamp: string;     // ISO 8601: 2025-02-19T10:30:15.123Z
  level: string;         // info, warn, error, debug
  message: string;       // Machine-readable event name: "user_login_success"
  service: string;       // Service name: "auth-service"
  environment: string;   // production, staging, development
  
  // Context propagation
  requestId: string;     // Unique per request (UUID)
  traceId?: string;      // Distributed trace ID (OpenTelemetry)
  spanId?: string;       // Current span ID
  
  // Request context (if applicable)
  method?: string;       // GET, POST, etc.
  path?: string;         // /api/v1/users
  statusCode?: number;   // 200, 404, 500
  duration_ms?: number;  // Request duration
  userId?: string;       // Authenticated user ID
  
  // Error context (if level = error)
  error?: {
    code: string;        // VALIDATION_ERROR, DB_CONNECTION_FAILED
    message: string;     // Human-readable error message
    stack?: string;      // Stack trace (non-production only)
  };
}
```

---

## Context Propagation

### Request Context (Express.js)
```typescript
import { randomUUID } from 'crypto';
import { AsyncLocalStorage } from 'async_hooks';

// Create async context storage
const requestContext = new AsyncLocalStorage<Map<string, string>>();

// Middleware: Inject request context
export function requestContextMiddleware(req: Request, res: Response, next: NextFunction) {
  const store = new Map<string, string>();
  
  // Propagate or create IDs
  store.set('requestId', req.headers['x-request-id'] as string || randomUUID());
  store.set('traceId', req.headers['traceparent']?.split('-')[1] || randomUUID());
  store.set('userId', req.user?.id || 'anonymous');
  store.set('method', req.method);
  store.set('path', req.path);
  store.set('ip', req.ip || '');
  
  // Set response header for client correlation
  res.setHeader('X-Request-Id', store.get('requestId')!);
  
  requestContext.run(store, () => next());
}

// Get context anywhere in the request lifecycle
export function getRequestContext(): Record<string, string> {
  const store = requestContext.getStore();
  if (!store) return {};
  return Object.fromEntries(store);
}
```

### Logger with Context
```typescript
import pino from 'pino';

const baseLogger = pino({
  level: process.env.LOG_LEVEL || 'info',
  timestamp: pino.stdTimeFunctions.isoTime,
  formatters: {
    level: (label) => ({ level: label }),
  },
  redact: {
    paths: ['password', 'token', 'authorization', 'cookie', 'email', '*.password', '*.token'],
    censor: '[REDACTED]',
  },
  base: {
    service: process.env.SERVICE_NAME || 'my-app',
    environment: process.env.NODE_ENV || 'development',
    version: process.env.APP_VERSION || '0.0.0',
  },
});

// Context-aware logger
export function getLogger() {
  const context = getRequestContext();
  return baseLogger.child(context);
}

// Usage
app.get('/api/users', (req, res) => {
  const logger = getLogger();
  logger.info('user_list_requested');
  // Output: {"level":"info","time":"2025-02-19T10:30:15.123Z","service":"my-app",
  //          "requestId":"abc-123","userId":"usr-456","message":"user_list_requested"}
});
```

---

## Python Structured Logging

```python
import structlog
import logging

# Configure structlog
structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,  # Context propagation
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.JSONRenderer(),  # JSON output
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
)

logger = structlog.get_logger()

# Context propagation (FastAPI)
from structlog.contextvars import bind_contextvars, clear_contextvars

@app.middleware("http")
async def logging_middleware(request: Request, call_next):
    clear_contextvars()
    bind_contextvars(
        request_id=request.headers.get("x-request-id", str(uuid.uuid4())),
        method=request.method,
        path=request.url.path,
    )
    
    start = time.monotonic()
    response = await call_next(request)
    duration = (time.monotonic() - start) * 1000
    
    logger.info("request_completed", status=response.status_code, duration_ms=round(duration, 2))
    return response

# Usage
logger.info("user_created", user_id="usr-123", role="admin")
logger.error("payment_failed", order_id="ord-456", error_code="INSUFFICIENT_FUNDS")
```

---

## Sensitive Data Redaction

```typescript
// ✅ REQUIRED: Never log PII or secrets
const REDACT_PATTERNS = [
  'password', 'token', 'secret', 'apiKey', 'api_key',
  'authorization', 'cookie', 'creditCard', 'ssn', 'nik',
];

// Configure in Pino:
const logger = pino({
  redact: {
    paths: ['password', 'req.headers.authorization', '*.token', '*.apiKey'],
    censor: '[REDACTED]',
  },
});

// Manual redaction for email
function redactEmail(email: string): string {
  const [local, domain] = email.split('@');
  return `${local[0]}***@${domain}`;
}
```

---

## Correlation Across Services

```
Frontend → Backend A → Backend B → Database
   │            │            │
   req-abc123   req-abc123   req-abc123    ← Same requestId
   trace-xyz    trace-xyz    trace-xyz     ← Same traceId

Headers to propagate:
  X-Request-Id: req-abc123
  traceparent: 00-trace-xyz-span-01       ← W3C Trace Context
```

## What to Log

```
✅ DO log:
  - Business events (user_registered, order_created, payment_processed)
  - Failed operations with error context
  - Security events (login_failed, permission_denied, rate_limited)
  - Performance metrics (request duration, query time)
  - System events (server_started, deployment, health_check)

❌ DON'T log:
  - PII (email, phone, address, NIK) — redact or mask
  - Passwords, tokens, API keys — NEVER
  - Full request/response bodies in production
  - High-frequency events without sampling (every DB query)
  - Sensitive business data (salary, medical records)
```

## Best Practices
1. **JSON format always** — never plain text in production
2. **Machine-readable messages** — `user_login_success` not `"User logged in"`
3. **Include context** — requestId, userId, traceId in every log
4. **Redact PII** — configure automatic redaction
5. **Log levels correctly** — INFO for business events, ERROR for failures
6. **Correlate requests** — propagate requestId across services
7. **Structured > free-text** — `{ action: "login", result: "success" }` not `"Login was successful"`
