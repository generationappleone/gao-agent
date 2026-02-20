---
name: REST API
description: Skill for designing and implementing RESTful APIs — covering URL conventions, HTTP methods, status codes, pagination, filtering, versioning, error handling, HATEOAS, and OpenAPI documentation.
---

# REST API Skill

## Overview
REST (Representational State Transfer) is the architectural style for designing networked APIs. This skill covers best practices for designing consistent, scalable, well-documented, and developer-friendly RESTful APIs. Following these patterns ensures your APIs are predictable, easy to integrate, and maintainable long-term.

**References**:
- [RFC 7231 — HTTP/1.1 Semantics and Content](https://datatracker.ietf.org/doc/html/rfc7231)
- [RFC 9457 — Problem Details for HTTP APIs](https://datatracker.ietf.org/doc/html/rfc9457)
- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)
- [Google API Design Guide](https://cloud.google.com/apis/design)
- [JSON:API Specification](https://jsonapi.org/)

---

## URL Conventions

### ✅ CORRECT Patterns
```
GET    /api/v1/users                → List users (collection)
GET    /api/v1/users/:id            → Get single user (resource)
POST   /api/v1/users                → Create user
PUT    /api/v1/users/:id            → Full update (replace entire resource)
PATCH  /api/v1/users/:id            → Partial update (modify specific fields)
DELETE /api/v1/users/:id            → Soft-delete user

GET    /api/v1/users/:id/orders     → List user's orders (sub-resource)
POST   /api/v1/users/:id/orders     → Create order for user
GET    /api/v1/users/:id/orders/:oid → Get specific order of user

POST   /api/v1/users/:id/activate   → Action endpoint (RPC-style, use sparingly)
POST   /api/v1/reports/generate     → Trigger long-running operation
```

### ❌ WRONG Patterns (Anti-Patterns)
```
GET    /api/v1/getUsers             ❌ Don't use verbs in URLs (HTTP method IS the verb)
POST   /api/v1/createUser           ❌ Don't duplicate method semantics
GET    /api/v1/user                 ❌ Use plural nouns (/users, not /user)
DELETE /api/v1/users/delete/:id     ❌ Don't duplicate method in URL
GET    /api/v1/user_profiles        ❌ Use kebab-case, not snake_case
GET    /api/v1/Users                ❌ Use lowercase
POST   /api/v1/users/123/orders/456/items/789/details  ❌ Too deep (max 3 levels)
```

### URL Design Rules
```
Rule 1: Use plural nouns         → /users, /orders, /products, /categories
Rule 2: Use kebab-case           → /order-items, /user-profiles, /payment-methods
Rule 3: Max 3 levels deep        → /users/:id/orders (not deeper)
Rule 4: Query params for filters → /users?role=admin&status=active
Rule 5: Path params for IDs      → /users/550e8400-e29b-41d4-a716-446655440000
Rule 6: Version prefix           → /api/v1/, /api/v2/
Rule 7: No trailing slashes      → /users (not /users/)
Rule 8: No file extensions       → /users (not /users.json)
Rule 9: Use UUIDs for IDs        → /users/550e8400... (not /users/123)
```

---

## HTTP Methods & Status Codes

### Method Reference
| Method | Semantics | Idempotent | Safe | Success Code | Response Body |
|--------|-----------|:----------:|:----:|:------------:|:-------------:|
| `GET` | Read resource(s) | ✅ | ✅ | `200 OK` | Yes |
| `POST` | Create resource | ❌ | ❌ | `201 Created` | Yes + `Location` header |
| `PUT` | Full replace | ✅ | ❌ | `200 OK` | Yes |
| `PATCH` | Partial update | ❌ | ❌ | `200 OK` | Yes |
| `DELETE` | Remove resource | ✅ | ❌ | `204 No Content` | No |
| `HEAD` | Same as GET, no body | ✅ | ✅ | `200 OK` | No |
| `OPTIONS` | List allowed methods | ✅ | ✅ | `204 No Content` | No (CORS preflight) |

### Status Code Reference (Complete)
```
2xx Success
  200 OK              → General success (GET, PUT, PATCH)
  201 Created         → Resource created (POST) — MUST include Location header
  202 Accepted        → Request accepted, processing async (long-running tasks)
  204 No Content      → Success, no body (DELETE, PUT with no response needed)

3xx Redirection
  301 Moved Permanently → Resource URL changed permanently
  302 Found             → Temporary redirect
  304 Not Modified      → Cache hit (ETag/If-Modified-Since match)

4xx Client Error
  400 Bad Request       → Malformed request (invalid JSON, wrong content-type)
  401 Unauthorized      → Not authenticated (missing or invalid token)
                          ⚠️ Name is misleading — means "unauthenticated"
  403 Forbidden         → Authenticated but not authorized (insufficient permissions)
  404 Not Found         → Resource doesn't exist
  405 Method Not Allowed → HTTP method not supported for this endpoint
  409 Conflict          → Duplicate resource, state conflict (e.g., edit conflict)
  410 Gone              → Resource permanently deleted (useful for hard-deleted resources)
  415 Unsupported Media → Wrong Content-Type header
  422 Unprocessable Entity → Semantic validation failed (valid JSON, invalid data)
  429 Too Many Requests → Rate limit exceeded — MUST include Retry-After header

5xx Server Error
  500 Internal Error    → Unhandled exception (log full stack, show generic message)
  502 Bad Gateway       → Upstream service returned invalid response
  503 Service Unavailable → Server overloaded or in maintenance — include Retry-After
  504 Gateway Timeout   → Upstream service timed out
```

### When to Use 400 vs 422
```
400 Bad Request:
  - Invalid JSON syntax
  - Wrong Content-Type header
  - Missing required headers
  → The request itself is malformed

422 Unprocessable Entity:
  - Email format invalid
  - Password too short
  - Date in the past
  → The request is well-formed, but the data fails business validation
```

---

## Standard Response Envelope

### TypeScript Interfaces
```typescript
// ✅ Success response (single resource)
interface ApiResponse<T> {
  success: true;
  data: T;
  meta?: Record<string, unknown>;
}

// ✅ Success response (collection with pagination)
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

// ✅ Error response (RFC 9457-inspired Problem Details)
interface ErrorResponse {
  success: false;
  error: {
    code: string;           // Machine-readable: 'VALIDATION_ERROR', 'NOT_FOUND'
    message: string;        // Human-readable: 'Validation failed'
    details?: Array<{       // Field-level errors (for 400/422)
      field: string;        // Dot notation: 'address.city'
      message: string;
      code: string;         // 'required', 'too_short', 'invalid_format'
    }>;
    requestId: string;      // Unique ID for debugging/support tickets
    timestamp: string;      // ISO 8601 timestamp
  };
}
```

### Implementation
```typescript
// helpers/response.ts

export function success<T>(data: T, meta?: Record<string, unknown>) {
  return { success: true as const, data, ...(meta ? { meta } : {}) };
}

export function created<T>(data: T, location: string) {
  // Express: res.setHeader('Location', location);
  return { success: true as const, data };
}

export function paginated<T>(
  data: T[],
  page: number,
  perPage: number,
  total: number,
  baseUrl: string
) {
  const totalPages = Math.ceil(total / perPage);
  return {
    success: true as const,
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

export function error(code: string, message: string, status = 400, details?: any[]) {
  return {
    success: false as const,
    error: {
      code,
      message,
      details: details || undefined,
      requestId: crypto.randomUUID(),
      timestamp: new Date().toISOString(),
    },
  };
}
```

### Response Examples
```json
// GET /api/v1/users/123 → 200 OK
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "admin",
    "createdAt": "2026-01-15T08:30:00Z"
  }
}

// POST /api/v1/users → 201 Created + Location: /api/v1/users/550e8400...
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2026-02-19T14:20:00Z"
  }
}

// GET /api/v1/users?page=2&per_page=20 → 200 OK
{
  "success": true,
  "data": [
    { "id": "...", "name": "Alice", "email": "alice@example.com" },
    { "id": "...", "name": "Bob", "email": "bob@example.com" }
  ],
  "meta": {
    "page": 2,
    "perPage": 20,
    "total": 150,
    "totalPages": 8
  },
  "links": {
    "self": "/api/v1/users?page=2&per_page=20",
    "first": "/api/v1/users?page=1&per_page=20",
    "last": "/api/v1/users?page=8&per_page=20",
    "prev": "/api/v1/users?page=1&per_page=20",
    "next": "/api/v1/users?page=3&per_page=20"
  }
}

// POST /api/v1/users → 422 Unprocessable Entity
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      { "field": "email", "message": "Invalid email format", "code": "invalid_format" },
      { "field": "password", "message": "Must be at least 8 characters", "code": "too_short" }
    ],
    "requestId": "req_abc123",
    "timestamp": "2026-02-19T14:20:00Z"
  }
}

// GET /api/v1/users/999 → 404 Not Found
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "requestId": "req_def456",
    "timestamp": "2026-02-19T14:20:00Z"
  }
}
```

---

## Pagination

### Offset-Based (Simple, Common)
```
GET /api/v1/users?page=2&per_page=20

# Pro: Simple, supports jumping to any page
# Con: Slow on large datasets (OFFSET scans rows), inconsistent with concurrent writes
# Use when: Small datasets (<100K rows), users need page numbers
```

### Cursor-Based (Performant)
```
GET /api/v1/users?cursor=eyJpZCI6MTAwfQ&limit=20

# Pro: O(1) performance regardless of dataset size, consistent results
# Con: Cannot jump to arbitrary page, more complex to implement
# Use when: Large datasets, infinite scroll, real-time data

# Response includes:
{
  "data": [...],
  "meta": { "hasMore": true },
  "links": {
    "next": "/api/v1/users?cursor=eyJpZCI6MTIwfQ&limit=20"
  }
}
```

### Keyset-Based (Consistent, Efficient)
```
GET /api/v1/users?after_id=550e8400-e29b&limit=20

# Pro: No OFFSET, uses WHERE + ORDER BY (index scan), consistent with writes
# Con: Cannot jump to arbitrary page
# Use when: Large datasets with UUID/timestamp ordering

# SQL: SELECT * FROM users WHERE id > $after_id ORDER BY id LIMIT 20
```

### Pagination Decision Matrix
| Criteria | Offset | Cursor | Keyset |
|----------|:------:|:------:|:------:|
| Jump to page N | ✅ | ❌ | ❌ |
| Performance at page 1000 | ❌ | ✅ | ✅ |
| Consistent during writes | ❌ | ✅ | ✅ |
| Implementation complexity | Simple | Medium | Medium |
| Use case | Admin panels | Mobile feeds | Public APIs |

---

## Filtering, Sorting & Searching

```
# ──────────────────────────────────────────────────
# Filtering (exact match, range, multiple values)
# ──────────────────────────────────────────────────
GET /api/v1/users?status=active                          # Exact match
GET /api/v1/users?role=admin,editor                      # Multiple values (OR)
GET /api/v1/orders?created_after=2026-01-01              # Date range (start)
GET /api/v1/orders?created_before=2026-12-31             # Date range (end)
GET /api/v1/orders?total_min=10000&total_max=50000       # Numeric range
GET /api/v1/products?in_stock=true                       # Boolean filter

# ──────────────────────────────────────────────────
# Sorting (prefix - for descending)
# ──────────────────────────────────────────────────
GET /api/v1/users?sort=name                              # Ascending by name
GET /api/v1/users?sort=-created_at                       # Descending by date
GET /api/v1/users?sort=-created_at,name                  # Multi-field sort

# Alternative (explicit order parameter):
GET /api/v1/users?sort=created_at&order=desc

# ──────────────────────────────────────────────────
# Searching (full-text search)
# ──────────────────────────────────────────────────
GET /api/v1/users?q=john                                 # Search all searchable fields
GET /api/v1/users?q=john&search_fields=name,email        # Search specific fields

# ──────────────────────────────────────────────────
# Field Selection / Sparse Fieldsets
# ──────────────────────────────────────────────────
GET /api/v1/users?fields=id,name,email                   # Only return these fields
GET /api/v1/users?include=orders,profile                 # Include related resources

# ──────────────────────────────────────────────────
# Combined example
# ──────────────────────────────────────────────────
GET /api/v1/orders?status=pending,confirmed&created_after=2026-01-01&sort=-total&page=1&per_page=50&fields=id,status,total,created_at
```

---

## Versioning

### URL Prefix (Recommended)
```
✅ Most common, easiest to understand, cacheable
GET /api/v1/users
GET /api/v2/users

# Implementation: separate route files per version
// routes/v1/users.routes.ts
router.get('/api/v1/users', v1UserController.getAll);

// routes/v2/users.routes.ts  
router.get('/api/v2/users', v2UserController.getAll);
```

### Header-Based
```
✅ Cleaner URLs, but harder to test and cache
Accept: application/vnd.myapp.v1+json
Accept: application/vnd.myapp.v2+json
```

### Versioning Rules
```
1. Version from day 1 — even if you think you won't need it
2. Support at least 2 versions simultaneously
3. Deprecate old versions with sunset headers:
   Sunset: Sat, 01 Mar 2027 00:00:00 GMT
   Link: </api/v2/users>; rel="successor-version"
4. Never break existing contracts within a version
5. Adding fields is NOT a breaking change (backward compatible)
6. Removing/renaming fields IS a breaking change (new version needed)
```

---

## Authentication & Security Headers

### Authentication Patterns
```
✅ Bearer Token (JWT) — for user authentication:
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...

✅ API Key — for server-to-server / service accounts:
X-API-Key: sk_live_abc123def456
# Or in Authorization header:
Authorization: ApiKey sk_live_abc123def456

❌ Basic Auth in production (unless over HTTPS for simple cases)
❌ Credentials in URL query params (/api?key=secret)
❌ API keys in request body
```

### Required Security Headers
```
# CORS
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400

# Rate Limiting
X-RateLimit-Limit: 100           # Max requests per window
X-RateLimit-Remaining: 87        # Requests remaining
X-RateLimit-Reset: 1708387200    # Unix timestamp for window reset
Retry-After: 30                  # Seconds to wait (on 429 responses)

# Security
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'

# Caching
Cache-Control: no-store           # For sensitive data
Cache-Control: public, max-age=3600  # For public data
ETag: "abc123"                    # For conditional requests
```

---

## Idempotency

```typescript
// WHY: Idempotent operations can be safely retried without side effects.
// Critical for payment processing, order creation, etc.

// POST is NOT idempotent by default. Use an idempotency key:
// Client sends: Idempotency-Key: <unique-uuid>
// Server stores: key → response, returns cached response on retry

async function handleIdempotentPost(req: Request, res: Response) {
  const idempotencyKey = req.headers['idempotency-key'];

  if (!idempotencyKey) {
    return res.status(400).json(error('MISSING_IDEMPOTENCY_KEY', 'Idempotency-Key header required'));
  }

  // Check if this request was already processed
  const cached = await redis.get(`idempotency:${idempotencyKey}`);
  if (cached) {
    const { statusCode, body } = JSON.parse(cached);
    return res.status(statusCode).json(body);
  }

  // Process the request
  const result = await processOrder(req.body);
  const responseBody = success(result);

  // Cache the response for 24 hours
  await redis.setex(
    `idempotency:${idempotencyKey}`,
    86400,
    JSON.stringify({ statusCode: 201, body: responseBody })
  );

  res.status(201).json(responseBody);
}
```

---

## OpenAPI / Swagger Documentation

```yaml
# openapi.yaml
openapi: 3.1.0
info:
  title: My Application API
  version: 1.0.0
  description: |
    RESTful API for My Application.
    
    ## Authentication
    All authenticated endpoints require a Bearer token in the Authorization header.
    
    ## Rate Limiting
    All endpoints are rate-limited to 100 requests per minute.
  contact:
    name: API Support
    email: api@example.com

servers:
  - url: https://api.example.com
    description: Production
  - url: https://staging-api.example.com
    description: Staging

security:
  - BearerAuth: []

paths:
  /api/v1/users:
    get:
      summary: List users
      description: Returns a paginated list of users with optional filtering.
      operationId: listUsers
      tags: [Users]
      parameters:
        - name: page
          in: query
          description: Page number (1-indexed)
          schema: { type: integer, default: 1, minimum: 1 }
        - name: per_page
          in: query
          description: Items per page
          schema: { type: integer, default: 20, minimum: 1, maximum: 100 }
        - name: status
          in: query
          description: Filter by user status
          schema:
            type: string
            enum: [active, inactive, pending]
        - name: sort
          in: query
          description: Sort field (prefix with - for descending)
          schema: { type: string, default: '-created_at' }
      responses:
        '200':
          description: Paginated list of users
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PaginatedUsers'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '429':
          $ref: '#/components/responses/RateLimited'

    post:
      summary: Create user
      operationId: createUser
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserInput'
            example:
              name: "John Doe"
              email: "john@example.com"
              password: "SecureP@ss123"
      responses:
        '201':
          description: User created successfully
          headers:
            Location:
              description: URL of the created resource
              schema: { type: string }
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '409':
          description: Email already exists
        '422':
          $ref: '#/components/responses/ValidationError'

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    CreateUserInput:
      type: object
      required: [name, email, password]
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 100
        email:
          type: string
          format: email
        password:
          type: string
          minLength: 8
          maxLength: 128

    UserResponse:
      type: object
      properties:
        success: { type: boolean, enum: [true] }
        data:
          $ref: '#/components/schemas/User'

  responses:
    Unauthorized:
      description: Authentication required
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
    ValidationError:
      description: Validation failed
    RateLimited:
      description: Too many requests
      headers:
        Retry-After:
          schema: { type: integer }
```

---

## API Design Checklist

| # | Practice | Details |
|---|----------|---------|
| 1 | **Consistent naming** | Plural nouns, kebab-case, no verbs in URLs |
| 2 | **Proper status codes** | Never return 200 for errors; use specific codes |
| 3 | **Standard error format** | Machine-readable code + human message + request ID |
| 4 | **Pagination by default** | NEVER return unbounded collections |
| 5 | **Versioning from day 1** | `/api/v1/` prefix, even for MVP |
| 6 | **Rate limiting** | Protect ALL public endpoints, include headers |
| 7 | **CORS configuration** | Whitelist allowed origins, don't use `*` in production |
| 8 | **Input validation** | Validate ALL input server-side (Zod, Joi, class-validator) |
| 9 | **Idempotency** | PUT and DELETE must be idempotent; POST with idempotency keys |
| 10 | **HATEOAS links** | Include navigation links in collection responses |
| 11 | **OpenAPI documentation** | Generate from code or maintain spec, always up-to-date |
| 12 | **Request IDs** | Include in every request/response for debugging |
| 13 | **Compression** | Enable gzip/brotli for JSON responses |
| 14 | **Content negotiation** | Return `application/json` by default |
| 15 | **Graceful deprecation** | Sunset header, successor links, migration guide |
