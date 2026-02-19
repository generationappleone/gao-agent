---
name: REST API
description: Skill for designing and implementing RESTful APIs — covering URL conventions, HTTP methods, status codes, pagination, filtering, versioning, error handling, HATEOAS, and OpenAPI documentation.
---

# REST API Skill

## Overview
REST (Representational State Transfer) is the standard architecture for web APIs. This skill covers best practices for designing consistent, scalable, and developer-friendly RESTful APIs.

---

## URL Conventions

```
✅ CORRECT patterns:
GET    /api/v1/users              → List users
GET    /api/v1/users/:id          → Get single user
POST   /api/v1/users              → Create user
PUT    /api/v1/users/:id          → Full update user
PATCH  /api/v1/users/:id          → Partial update user
DELETE /api/v1/users/:id          → Delete user

GET    /api/v1/users/:id/orders   → List user's orders (sub-resource)
POST   /api/v1/users/:id/orders   → Create order for user

❌ WRONG patterns:
GET    /api/v1/getUsers           → Don't use verbs in URLs
POST   /api/v1/createUser         → HTTP method IS the verb
GET    /api/v1/user               → Use plural nouns
DELETE /api/v1/users/delete/:id   → Don't duplicate method in URL
```

### URL Rules
```
1. Use plural nouns: /users, /orders, /products
2. Use kebab-case: /order-items, /user-profiles
3. Max 3 levels deep: /users/:id/orders (not /users/:id/orders/:oid/items/:iid/details)
4. Use query params for filtering: /users?role=admin&status=active
5. Use path params for identifiers: /users/123
6. Version prefix: /api/v1/, /api/v2/
```

---

## HTTP Methods & Status Codes

| Method | Use | Success | With Body? |
|--------|-----|---------|------------|
| `GET` | Read resource(s) | `200 OK` | Yes |
| `POST` | Create resource | `201 Created` | Yes + Location header |
| `PUT` | Full replace | `200 OK` | Yes |
| `PATCH` | Partial update | `200 OK` | Yes |
| `DELETE` | Remove resource | `204 No Content` | No |

### Status Code Reference
```
2xx Success
  200 OK              → General success
  201 Created         → Resource created (POST)
  204 No Content      → Success, no body (DELETE)

3xx Redirect
  301 Moved           → Permanent redirect
  304 Not Modified    → Cache hit (ETag match)

4xx Client Error
  400 Bad Request     → Validation error, malformed request
  401 Unauthorized    → Not authenticated (missing/invalid token)
  403 Forbidden       → Authenticated but not authorized
  404 Not Found       → Resource doesn't exist
  409 Conflict        → Duplicate resource, state conflict
  422 Unprocessable   → Validation failed (semantic error)
  429 Too Many Reqs   → Rate limited

5xx Server Error
  500 Internal Error  → Unhandled exception
  502 Bad Gateway     → Upstream service failed
  503 Unavailable     → Service temporarily unavailable
  504 Gateway Timeout → Upstream timeout
```

---

## Standard Response Envelope

```typescript
// ✅ Success response (single resource)
interface ApiResponse<T> {
  success: true;
  data: T;
  meta?: Record<string, unknown>;
}

// ✅ Success response (collection)
interface PaginatedResponse<T> {
  success: true;
  data: T[];
  meta: {
    page: number;
    perPage: number;
    total: number;
    totalPages: number;
  };
  links: {
    self: string;
    first: string;
    last: string;
    prev: string | null;
    next: string | null;
  };
}

// ✅ Error response
interface ErrorResponse {
  success: false;
  error: {
    code: string;           // Machine-readable: 'VALIDATION_ERROR'
    message: string;        // Human-readable: 'Email is required'
    details?: Array<{       // Field-level errors
      field: string;
      message: string;
      code: string;
    }>;
    requestId: string;      // For debugging
  };
}
```

### Implementation
```typescript
// helpers/response.ts
export function success<T>(data: T, meta?: Record<string, unknown>) {
  return { success: true, data, ...(meta ? { meta } : {}) };
}

export function paginated<T>(data: T[], page: number, perPage: number, total: number, baseUrl: string) {
  const totalPages = Math.ceil(total / perPage);
  return {
    success: true,
    data,
    meta: { page, perPage, total, totalPages },
    links: {
      self: `${baseUrl}?page=${page}&per_page=${perPage}`,
      first: `${baseUrl}?page=1&per_page=${perPage}`,
      last: `${baseUrl}?page=${totalPages}&per_page=${perPage}`,
      prev: page > 1 ? `${baseUrl}?page=${page - 1}&per_page=${perPage}` : null,
      next: page < totalPages ? `${baseUrl}?page=${page + 1}&per_page=${perPage}` : null,
    },
  };
}

export function error(code: string, message: string, details?: any[], status = 400) {
  return {
    success: false,
    error: { code, message, details, requestId: crypto.randomUUID() },
  };
}
```

---

## Pagination

```
✅ Offset-based (simple, common):
GET /api/v1/users?page=2&per_page=20

✅ Cursor-based (performant for large datasets):
GET /api/v1/users?cursor=eyJpZCI6MTAwfQ&limit=20

✅ Keyset-based (consistent for real-time data):
GET /api/v1/users?after_id=100&limit=20
```

## Filtering, Sorting, Searching

```
Filtering:
GET /api/v1/users?status=active&role=admin
GET /api/v1/orders?created_after=2025-01-01&total_min=100000

Sorting:
GET /api/v1/users?sort=created_at&order=desc
GET /api/v1/users?sort=-created_at,name  (- prefix = desc)

Searching:
GET /api/v1/users?q=john&search_fields=name,email

Field Selection (sparse fieldsets):
GET /api/v1/users?fields=id,name,email
```

---

## Versioning

```
✅ URL prefix (recommended):
GET /api/v1/users
GET /api/v2/users

✅ Header-based:
Accept: application/vnd.myapp.v1+json

❌ Query param (avoid):
GET /api/users?version=1
```

---

## Authentication

```
✅ Bearer Token (JWT):
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

✅ API Key (for server-to-server):
X-API-Key: sk_live_abc123
Authorization: ApiKey sk_live_abc123

❌ Basic Auth in production (unless over HTTPS for simple cases)
❌ Credentials in URL query params
```

---

## Rate Limiting Headers

```
X-RateLimit-Limit: 100         → Max requests per window
X-RateLimit-Remaining: 87      → Requests remaining
X-RateLimit-Reset: 1708387200  → Unix timestamp for reset
Retry-After: 30                → Seconds to wait (on 429)
```

---

## OpenAPI / Swagger Documentation

```yaml
# openapi.yaml
openapi: 3.1.0
info:
  title: My API
  version: 1.0.0
  description: API documentation

paths:
  /api/v1/users:
    get:
      summary: List users
      tags: [Users]
      parameters:
        - name: page
          in: query
          schema: { type: integer, default: 1 }
        - name: per_page
          in: query
          schema: { type: integer, default: 20, maximum: 100 }
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PaginatedUsers'
    post:
      summary: Create user
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserInput'
      responses:
        '201':
          description: Created
        '422':
          description: Validation error
```

## Best Practices
1. **Consistent naming** — plural nouns, kebab-case, no verbs
2. **Proper status codes** — don't return 200 for errors
3. **Standard error format** — machine-readable code + human message
4. **Pagination by default** — never return unbounded collections
5. **Versioning from day 1** — /api/v1/ prefix
6. **Rate limiting** — protect all public endpoints
7. **CORS configuration** — whitelist allowed origins
8. **Request validation** — validate ALL input (Zod, Joi, class-validator)
9. **Idempotency** — PUT and DELETE should be idempotent
10. **HATEOAS links** — include navigation links in responses
