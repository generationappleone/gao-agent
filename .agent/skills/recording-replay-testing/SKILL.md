---
name: recording-replay-testing
description: "Use when testing webhook/API integrations against production data. Record production interactions, export to fixtures, replay in tests with sensitive data redaction."
---

# Recording & Replay Testing

## Overview

Record real production webhook/API interactions, export them as test fixtures, and replay in automated tests. This bridges the gap between unit tests (fast but synthetic) and production verification (slow but real).

**Announce:** "Using recording-replay-testing for production-data fixtures."

## When to Use

- Payment gateway webhook testing (Stripe, Midtrans, Xendit)
- Third-party API integration testing
- Complex multi-step API flows
- When synthetic fixtures miss edge cases that production reveals

## Phase 1: Recording Configuration

### Directory Structure

```
tests/
├── fixtures/
│   ├── recordings/
│   │   ├── 2026-03-13-stripe-checkout/
│   │   │   ├── request.json
│   │   │   ├── response.json
│   │   │   └── metadata.json
│   │   └── 2026-03-13-webhook-payment-success/
│   │       ├── request.json
│   │       ├── response.json
│   │       └── metadata.json
│   └── replays/
│       ├── stripe-checkout.fixture.json
│       └── webhook-payment-success.fixture.json
```

### Recording in Development

```typescript
// Middleware to record API interactions
function recordInteraction(name: string) {
  return (req: Request, res: Response, next: NextFunction) => {
    const startTime = Date.now();
    const originalJson = res.json.bind(res);

    res.json = (body: unknown) => {
      const recording = {
        name,
        timestamp: new Date().toISOString(),
        sha: process.env.GIT_SHA || 'dev',
        request: {
          method: req.method,
          url: req.originalUrl,
          headers: redactHeaders(req.headers),
          body: req.body,
        },
        response: {
          status: res.statusCode,
          headers: redactHeaders(res.getHeaders()),
          body,
        },
        duration: Date.now() - startTime,
      };

      saveRecording(name, recording);
      return originalJson(body);
    };

    next();
  };
}
```

## Phase 2: Sensitive Data Redaction

### SENSITIVE_HEADERS Pattern

```typescript
const SENSITIVE_HEADERS = new Set([
  'authorization',
  'x-api-key',
  'cookie',
  'x-webhook-secret',
  'stripe-signature',
]);

function redactHeaders(
  headers: Record<string, string>
): Record<string, string> {
  const redacted: Record<string, string> = {};

  for (const [key, value] of Object.entries(headers)) {
    if (SENSITIVE_HEADERS.has(key.toLowerCase())) {
      // Preserve first 10 chars for debugging, redact rest
      redacted[key] = value.substring(0, 10) + '...[REDACTED]';
    } else {
      redacted[key] = value;
    }
  }

  return redacted;
}
```

**Why preserve first 10 chars:** Enables debugging ("is this the right API key format?") without exposing secrets.

### Body Redaction

```typescript
const SENSITIVE_FIELDS = ['password', 'secret', 'token', 'ssn', 'credit_card'];

function redactBody(body: unknown): unknown {
  if (typeof body !== 'object' || body === null) return body;

  const redacted = { ...body } as Record<string, unknown>;
  for (const key of Object.keys(redacted)) {
    if (SENSITIVE_FIELDS.some(f => key.toLowerCase().includes(f))) {
      redacted[key] = '[REDACTED]';
    } else if (typeof redacted[key] === 'object') {
      redacted[key] = redactBody(redacted[key]);
    }
  }
  return redacted;
}
```

## Phase 3: SHA-Based Tagging

Tag recordings with the Git SHA to track which code version produced them:

```typescript
interface RecordingMetadata {
  name: string;
  gitSha: string;
  timestamp: string;
  environment: 'development' | 'staging' | 'production';
  tags: string[];
}
```

### jq Extraction Commands

```bash
# Extract all recordings from a specific Git SHA
cat recordings/*.json | jq 'select(.sha == "abc123")'

# Extract all webhook recordings
cat recordings/*.json | jq 'select(.name | startswith("webhook-"))'

# Get all unique status codes
cat recordings/*.json | jq '.response.status' | sort -u
```

## Phase 4: Replay in Tests

### Fixture Format

```json
{
  "name": "stripe-checkout-success",
  "source": "recordings/2026-03-13-stripe-checkout/",
  "request": { "...": "..." },
  "response": { "...": "..." },
  "assertions": {
    "statusCode": 200,
    "bodyContains": ["checkout_session"],
    "headersPresent": ["content-type"]
  }
}
```

### Replay Test Utilities

```typescript
import { readFixture, replayRequest } from './replay-test-utils';

describe('Stripe Checkout', () => {
  it('should handle checkout success', async () => {
    const fixture = readFixture('stripe-checkout-success');
    const response = await replayRequest(fixture);

    expect(response.status).toBe(fixture.assertions.statusCode);
    for (const keyword of fixture.assertions.bodyContains) {
      expect(JSON.stringify(response.body)).toContain(keyword);
    }
  });
});
```

## Red Flags

| Thought | Reality |
|---------|---------|
| "Production data in tests is fine" | ALWAYS redact sensitive data before committing. |
| "I'll redact later" | Redact at recording time. Sensitive data should never touch disk unredacted. |
| "All headers are safe" | Authorization, cookies, and API keys are ALWAYS sensitive. |

## Integration

**This skill pairs with:**
- **unit-testing** — Fixtures complement synthetic test data
- **systematic-debugging** — Replay production scenarios to reproduce bugs
