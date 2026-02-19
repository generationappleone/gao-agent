---
name: JavaScript
description: Skill for modern JavaScript development, covering ES2024+ features, Node.js backend, module systems, async patterns, error handling, testing, and tooling best practices.
---

# JavaScript Skill

## Overview
JavaScript is the language of the web. Use this skill for both client-side (browser) and server-side (Node.js, Deno, Bun) development. Prefer TypeScript for all new projects, but this skill covers vanilla JS patterns.

## Modern JS Features (ES2022+)

### MUST Use Modern Syntax
```javascript
// ✅ Modules (ESM — always prefer over CommonJS)
import { readFile } from 'node:fs/promises';
export function processData(data) { /* ... */ }

// ✅ Top-level await (ESM)
const config = await loadConfig();

// ✅ Optional chaining & nullish coalescing
const city = user?.address?.city ?? 'Unknown';

// ✅ Structured clone (deep copy)
const copy = structuredClone(originalObject);

// ✅ Array.at() for negative indexing
const last = items.at(-1);

// ✅ Object.groupBy (ES2024)
const grouped = Object.groupBy(users, user => user.role);

// ✅ Promise.withResolvers (ES2024)
const { promise, resolve, reject } = Promise.withResolvers();
```

## Node.js Backend Patterns

### Project Structure
```
src/
├── server.js            # Entry point
├── config/
│   └── env.js           # Environment validation
├── routes/
│   └── users.routes.js
├── controllers/
│   └── users.controller.js
├── services/
│   └── users.service.js
├── repositories/
│   └── users.repository.js
├── middleware/
│   ├── auth.js
│   ├── errorHandler.js
│   └── rateLimiter.js
└── utils/
    └── logger.js
```

### Async Error Handling
```javascript
// ✅ REQUIRED: Async wrapper for Express
function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

router.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await userService.findById(req.params.id);
  if (!user) throw new NotFoundError('User not found');
  res.json(user);
}));

// ✅ REQUIRED: Global error handler
app.use((err, req, res, next) => {
  const status = err.statusCode || 500;
  const message = status === 500 ? 'Internal server error' : err.message;
  logger.error({ err, correlationId: req.correlationId });
  res.status(status).json({ error: { code: err.code, message }, correlationId: req.correlationId });
});
```

### Environment Validation
```javascript
// ✅ Validate all env vars at startup
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
});

export const env = envSchema.parse(process.env);
```

## Testing with Vitest
```javascript
import { describe, it, expect, vi } from 'vitest';

describe('UserService', () => {
  it('should create a user with hashed password', async () => {
    const mockRepo = { create: vi.fn().mockResolvedValue({ id: '1', email: 'test@test.com' }) };
    const service = new UserService(mockRepo);

    const user = await service.register({ email: 'test@test.com', password: 'pass1234' });

    expect(user.email).toBe('test@test.com');
    expect(mockRepo.create).toHaveBeenCalledOnce();
  });
});
```

## Security Reminders
- NEVER use `eval()`, `Function()`, or `new Function()` with user input
- NEVER use `innerHTML` with unsanitized data — use `textContent`
- Always use parameterized queries for database access
- Validate ALL inputs with Zod or Joi
- Use `node:crypto` for cryptographic operations, not custom implementations

## Rules Integration
- **SOLID**: Module-based separation, dependency injection (constructor), single-file responsibility
- **Security**: Input validation (Zod), env validation, no `eval`, parameterized queries
- **Dependencies**: Check with `npm audit`, use exact versions, `package-lock.json` committed
