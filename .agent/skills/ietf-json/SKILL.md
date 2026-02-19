---
name: IETF JSON Standards
description: Skill for implementing IETF JSON standards — covering RFC 8259 (JSON), RFC 7807/9457 (Problem Details), RFC 6901 (JSON Pointer), RFC 6902 (JSON Patch), RFC 7396 (JSON Merge Patch), and JSON:API specification.
---

# IETF JSON Standards Skill

## Overview
The **IETF (Internet Engineering Task Force)** defines standards for JSON usage in HTTP APIs. Following these standards ensures interoperability, consistency, and compliance with industry best practices.

---

## RFC 8259 — The JSON Data Interchange Format

The foundational JSON specification. Key rules:

```
✅ Valid JSON:
- Strings: MUST use double quotes ("hello", not 'hello')
- Numbers: No leading zeros (0.5, not .5), no trailing commas
- Boolean: true/false (lowercase)
- Null: null (lowercase)
- Encoding: MUST be UTF-8
- No comments allowed in JSON
- No trailing commas

✅ Valid:   {"name": "John", "age": 30, "active": true, "address": null}
❌ Invalid: {name: 'John', age: 030, 'active': True,}
```

---

## RFC 7807 / RFC 9457 — Problem Details for HTTP APIs

Standardized error response format. **RFC 9457** supersedes RFC 7807.

```typescript
// ✅ Standard error response
// Content-Type: application/problem+json

interface ProblemDetails {
  type: string;      // URI identifying the problem type
  status: number;    // HTTP status code
  title: string;     // Short human-readable summary
  detail?: string;   // Human-readable explanation specific to this occurrence
  instance?: string; // URI identifying the specific occurrence
  
  // Extension members (custom fields)
  [key: string]: unknown;
}
```

### Implementation
```typescript
// Express middleware for RFC 9457 errors
class HttpProblem extends Error {
  constructor(
    public status: number,
    public type: string,
    public title: string,
    public detail?: string,
    public extensions?: Record<string, unknown>,
  ) {
    super(title);
  }
}

// Error handler middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof HttpProblem) {
    res.status(err.status).type('application/problem+json').json({
      type: err.type,
      status: err.status,
      title: err.title,
      detail: err.detail,
      instance: req.originalUrl,
      timestamp: new Date().toISOString(),
      ...err.extensions,
    });
  } else {
    res.status(500).type('application/problem+json').json({
      type: 'https://api.example.com/errors/internal',
      status: 500,
      title: 'Internal Server Error',
      instance: req.originalUrl,
    });
  }
});

// Usage
throw new HttpProblem(
  422,
  'https://api.example.com/errors/validation',
  'Validation Error',
  'The email field is invalid',
  {
    errors: [
      { field: 'email', message: 'Must be a valid email address', code: 'invalid_format' },
      { field: 'password', message: 'Must be at least 12 characters', code: 'too_short' },
    ],
  },
);

// Response:
// {
//   "type": "https://api.example.com/errors/validation",
//   "status": 422,
//   "title": "Validation Error",
//   "detail": "The email field is invalid",
//   "instance": "/api/v1/users",
//   "timestamp": "2025-02-19T10:30:15.123Z",
//   "errors": [
//     { "field": "email", "message": "Must be a valid email address", "code": "invalid_format" },
//     { "field": "password", "message": "Must be at least 12 characters", "code": "too_short" }
//   ]
// }
```

---

## RFC 6901 — JSON Pointer

A string syntax for identifying a specific value within a JSON document.

```
Document:
{
  "users": [
    { "name": "Alice", "addresses": [{ "city": "Jakarta" }] }
  ],
  "meta": { "total": 1 }
}

JSON Pointers:
  ""              → entire document
  "/users"        → [{ "name": "Alice", ... }]
  "/users/0"      → { "name": "Alice", ... }
  "/users/0/name" → "Alice"
  "/users/0/addresses/0/city" → "Jakarta"
  "/meta/total"   → 1
```

---

## RFC 6902 — JSON Patch

A format for describing changes to a JSON document. Uses JSON Pointer for targeting.

```typescript
// Content-Type: application/json-patch+json
// PATCH /api/v1/users/123

const patch = [
  { "op": "replace", "path": "/name", "value": "Alice Updated" },
  { "op": "add", "path": "/phone", "value": "+6281234567890" },
  { "op": "remove", "path": "/temporary_field" },
  { "op": "copy", "from": "/name", "path": "/display_name" },
  { "op": "move", "from": "/old_email", "path": "/email" },
  { "op": "test", "path": "/version", "value": 3 },  // Assert value before patching
];

// Operations:
// add    → Add value at path
// remove → Remove value at path
// replace→ Replace value at path
// move   → Move value from one path to another
// copy   → Copy value from one path to another
// test   → Verify value at path (prevents race conditions)
```

### Implementation
```typescript
import jsonpatch from 'fast-json-patch';

app.patch('/api/v1/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  const document = user.toJSON();
  
  // Validate patch operations
  const errors = jsonpatch.validate(req.body, document);
  if (errors) {
    throw new HttpProblem(400, '...', 'Invalid Patch', errors.message);
  }
  
  // Apply patch
  const patched = jsonpatch.applyPatch(document, req.body).newDocument;
  
  // Save
  Object.assign(user, patched);
  await user.save();
  res.json({ success: true, data: user });
});
```

---

## RFC 7396 — JSON Merge Patch

Simpler alternative to JSON Patch. Send partial document; `null` means delete.

```typescript
// Content-Type: application/merge-patch+json
// PATCH /api/v1/users/123

// Merge Patch:
{
  "name": "Alice Updated",    // Replace
  "phone": "+6281234567890",  // Add
  "temporary_field": null     // Delete (set to null = remove)
}

// Implementation
app.patch('/api/v1/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  
  for (const [key, value] of Object.entries(req.body)) {
    if (value === null) {
      delete user[key];  // RFC 7396: null means remove
    } else {
      user[key] = value;
    }
  }
  
  await user.save();
  res.json({ success: true, data: user });
});
```

---

## JSON:API Specification (jsonapi.org)

A specification for building APIs in JSON.

```typescript
// Response format
// Content-Type: application/vnd.api+json

{
  "data": {
    "type": "users",
    "id": "123",
    "attributes": {
      "name": "Alice",
      "email": "alice@example.com",
    },
    "relationships": {
      "orders": {
        "data": [
          { "type": "orders", "id": "1" },
          { "type": "orders", "id": "2" },
        ],
        "links": {
          "related": "/api/v1/users/123/orders"
        }
      }
    },
    "links": {
      "self": "/api/v1/users/123"
    }
  },
  "included": [
    {
      "type": "orders",
      "id": "1",
      "attributes": { "total": 150000, "status": "completed" }
    }
  ],
  "meta": {
    "total": 1
  },
  "links": {
    "self": "/api/v1/users/123"
  }
}
```

---

## Date/Time Format (RFC 3339 / ISO 8601)

```
✅ Always use RFC 3339 / ISO 8601 for dates in JSON:
  "2025-02-19T10:30:15.123Z"           → UTC
  "2025-02-19T17:30:15.123+07:00"      → WIB (UTC+7)

❌ Never use:
  "02/19/2025"       → Ambiguous (MM/DD or DD/MM?)
  "1708345815"       → Unix timestamp (not human-readable)
  "19 Feb 2025"      → Not standard format
```

---

## Summary: Which Standard When?

| Standard | Use When |
|----------|----------|
| **RFC 8259** | Every JSON document (foundational) |
| **RFC 9457** | Error responses (Problem Details) |
| **RFC 6901** | Referencing specific values in JSON |
| **RFC 6902** | Complex partial updates (JSON Patch) |
| **RFC 7396** | Simple partial updates (Merge Patch) |
| **JSON:API** | Resource-oriented APIs with relationships |
| **RFC 3339** | Date/time values in JSON |

## Best Practices
1. **RFC 9457 for all errors** — consistent, standard error format
2. **RFC 7396 for simple updates** — easier than JSON Patch for most cases
3. **RFC 6902 for complex patches** — when you need `test`, `move`, `copy`
4. **ISO 8601/RFC 3339 for dates** — always include timezone
5. **UTF-8 encoding** — always, per RFC 8259
6. **Content-Type headers** — use appropriate MIME types
