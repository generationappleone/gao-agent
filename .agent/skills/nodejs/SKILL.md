---
name: Node.js
description: Skill for building server-side applications with Node.js, covering Express/Fastify, project structure, middleware, authentication, database integration, error handling, and deployment.
---

# Node.js Skill

## Overview
Node.js is a JavaScript/TypeScript runtime for building scalable server-side applications. This skill covers Express.js, Fastify, clean architecture, authentication, and production patterns. See the JavaScript and TypeScript skills for language-level patterns.

**Minimum Version**: Node.js 20 LTS+ (recommended: Node.js 22 LTS)
**References**:
- [Node.js API Documentation](https://nodejs.org/docs/latest/api/)
- [Express.js Documentation](https://expressjs.com/)
- [Fastify Documentation](https://fastify.dev/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

---

## Project Setup

### Initialize
```bash
mkdir my-api && cd my-api
npm init -y

# Essential packages
npm install express cors helmet compression cookie-parser
npm install dotenv zod pino pino-http              # Config, validation, logging
npm install ioredis                                  # Redis client
npm install jsonwebtoken bcrypt uuid                # Auth
npm install prisma @prisma/client                   # Database ORM

# Development
npm install -D typescript @types/node @types/express
npm install -D tsx vitest @vitest/coverage-v8       # TS runner, testing
npm install -D eslint @typescript-eslint/eslint-plugin
npm install -D @types/cors @types/cookie-parser @types/bcrypt @types/jsonwebtoken
```

### package.json Scripts
```json
{
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/",
    "db:migrate": "prisma migrate dev",
    "db:generate": "prisma generate",
    "db:studio": "prisma studio"
  }
}
```

### Project Structure (Clean Architecture)
```
src/
├── server.ts                    # Bootstrap & listen
├── app.ts                       # Express configuration
├── config/
│   └── env.ts                   # Environment validation (Zod)
├── modules/                     # Feature modules (domain-driven)
│   ├── users/
│   │   ├── users.controller.ts  # HTTP request handlers
│   │   ├── users.service.ts     # Business logic
│   │   ├── users.repository.ts  # Data access
│   │   ├── users.routes.ts      # Route definitions
│   │   ├── users.schema.ts      # Zod validation schemas
│   │   ├── users.types.ts       # TypeScript types
│   │   └── __tests__/
│   │       ├── users.service.test.ts
│   │       └── users.api.test.ts
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.routes.ts
│   │   └── auth.schema.ts
│   └── orders/
│       └── ...
├── middleware/
│   ├── auth.middleware.ts
│   ├── error-handler.middleware.ts
│   ├── rate-limiter.middleware.ts
│   ├── request-id.middleware.ts
│   └── validate.middleware.ts
├── shared/
│   ├── errors/
│   │   └── app-error.ts         # Custom error hierarchy
│   ├── utils/
│   │   ├── logger.ts            # Pino logger
│   │   ├── async-handler.ts
│   │   └── response.ts          # Standard response helpers
│   └── types/
│       └── express.d.ts         # Express type augmentation
└── prisma/
    └── schema.prisma            # Database schema
```

---

## Application Bootstrap

### Server Entry Point
```typescript
// src/server.ts
import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './shared/utils/logger.js';
import { prisma } from './shared/utils/prisma.js';

async function main() {
  // Test database connection
  await prisma.$connect();
  logger.info('Database connected');

  const app = createApp();

  const server = app.listen(env.PORT, () => {
    logger.info({
      msg: 'Server started',
      port: env.PORT,
      env: env.NODE_ENV,
      pid: process.pid,
    });
  });

  // Graceful shutdown
  const shutdown = async (signal: string) => {
    logger.info({ msg: `${signal} received, shutting down gracefully` });
    server.close(async () => {
      await prisma.$disconnect();
      logger.info('Server shut down');
      process.exit(0);
    });

    // Force shutdown after 10s
    setTimeout(() => {
      logger.error('Forced shutdown after timeout');
      process.exit(1);
    }, 10_000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));

  // Catch unhandled errors (log and exit — NOT silently continue)
  process.on('unhandledRejection', (reason) => {
    logger.fatal({ err: reason }, 'Unhandled rejection');
    process.exit(1);
  });

  process.on('uncaughtException', (error) => {
    logger.fatal({ err: error }, 'Uncaught exception');
    process.exit(1);
  });
}

main().catch((error) => {
  logger.fatal({ err: error }, 'Failed to start server');
  process.exit(1);
});
```

### Express Application
```typescript
// src/app.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import cookieParser from 'cookie-parser';
import pinoHttp from 'pino-http';
import { env } from './config/env.js';
import { logger } from './shared/utils/logger.js';
import { errorHandler } from './middleware/error-handler.middleware.js';
import { requestIdMiddleware } from './middleware/request-id.middleware.js';
import { userRoutes } from './modules/users/users.routes.js';
import { authRoutes } from './modules/auth/auth.routes.js';

export function createApp() {
  const app = express();

  // ── Security ──
  app.use(helmet());
  app.use(cors({
    origin: env.ALLOWED_ORIGINS.split(','),
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }));

  // ── Parsing ──
  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true, limit: '1mb' }));
  app.use(cookieParser());

  // ── Middleware ──
  app.use(compression());
  app.use(requestIdMiddleware);
  app.use(pinoHttp({ logger, autoLogging: { ignore: (req) => req.url === '/health' } }));

  // ── Health check ──
  app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  });

  // ── Routes ──
  app.use('/api/v1/auth', authRoutes);
  app.use('/api/v1/users', userRoutes);

  // ── 404 handler ──
  app.use((_req, res) => {
    res.status(404).json({
      success: false,
      error: { code: 'NOT_FOUND', message: 'Endpoint not found' },
    });
  });

  // ── Error handler (MUST be last) ──
  app.use(errorHandler);

  return app;
}
```

### Environment Validation
```typescript
// src/config/env.ts
import { z } from 'zod';
import 'dotenv/config';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),

  // Database
  DATABASE_URL: z.string().url(),

  // Redis
  REDIS_URL: z.string().url().default('redis://localhost:6379'),

  // Auth
  JWT_PRIVATE_KEY: z.string().min(1, 'JWT private key is required'),
  JWT_PUBLIC_KEY: z.string().min(1, 'JWT public key is required'),
  JWT_ACCESS_EXPIRY: z.string().default('15m'),
  JWT_REFRESH_EXPIRY: z.string().default('7d'),

  // CORS
  ALLOWED_ORIGINS: z.string().default('http://localhost:3000'),

  // Log
  LOG_LEVEL: z.enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal']).default('info'),
});

export const env = envSchema.parse(process.env);
export type Env = z.infer<typeof envSchema>;
```

---

## Middleware

### Error Handler
```typescript
// src/middleware/error-handler.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { AppError } from '../shared/errors/app-error.js';
import { logger } from '../shared/utils/logger.js';

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  // Zod validation errors
  if (err instanceof ZodError) {
    res.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        details: err.issues.map((issue) => ({
          field: issue.path.join('.'),
          message: issue.message,
          code: issue.code,
        })),
        requestId: req.id,
      },
    });
    return;
  }

  // Known operational errors
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        requestId: req.id,
      },
    });
    return;
  }

  // Unknown errors — log full details, return generic message
  logger.error({
    err: { message: err.message, stack: err.stack, name: err.name },
    method: req.method,
    url: req.originalUrl,
    requestId: req.id,
  }, 'Unhandled error');

  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
      requestId: req.id,
    },
  });
}
```

### Validation Middleware
```typescript
// src/middleware/validate.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';

export function validate(schema: ZodSchema, source: 'body' | 'query' | 'params' = 'body') {
  return (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req[source]);

    if (!result.success) {
      return next(result.error); // Caught by error handler
    }

    // Replace with validated data (removes unknown fields)
    req[source] = result.data;
    next();
  };
}

// Usage in routes
import { createUserSchema } from './users.schema.js';

router.post('/', validate(createUserSchema), userController.create);
```

### Auth Middleware
```typescript
// src/middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../modules/auth/auth.service.js';
import { UnauthorizedError, ForbiddenError } from '../shared/errors/app-error.js';

export function authenticate(req: Request, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;

  if (!header?.startsWith('Bearer ')) {
    throw new UnauthorizedError('Missing authorization header');
  }

  try {
    const payload = verifyAccessToken(header.slice(7));
    req.user = {
      id: payload.sub,
      email: payload.email,
      roles: payload.roles,
      tenantId: payload.tenant_id,
    };
    next();
  } catch (error) {
    throw new UnauthorizedError('Invalid or expired token');
  }
}

export function authorize(...requiredRoles: string[]) {
  return (req: Request, _res: Response, next: NextFunction) => {
    const userRoles = req.user?.roles ?? [];
    const hasRole = requiredRoles.some((role) => userRoles.includes(role));

    if (!hasRole) {
      throw new ForbiddenError(`Required roles: ${requiredRoles.join(', ')}`);
    }

    next();
  };
}
```

### Request ID Middleware
```typescript
// src/middleware/request-id.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { randomUUID } from 'node:crypto';

export function requestIdMiddleware(req: Request, res: Response, next: NextFunction) {
  req.id = req.headers['x-request-id'] as string ?? randomUUID();
  res.setHeader('X-Request-ID', req.id);
  next();
}
```

---

## Module Pattern (Feature-Based)

### Users Module Example
```typescript
// src/modules/users/users.routes.ts
import { Router } from 'express';
import { UserController } from './users.controller.js';
import { UserService } from './users.service.js';
import { UserRepository } from './users.repository.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { validate } from '../../middleware/validate.middleware.js';
import { createUserSchema, updateUserSchema, listUsersSchema } from './users.schema.js';

const repo = new UserRepository();
const service = new UserService(repo);
const controller = new UserController(service);

export const userRoutes = Router();

userRoutes.use(authenticate);

userRoutes.get('/', validate(listUsersSchema, 'query'), controller.list);
userRoutes.get('/:id', controller.getById);
userRoutes.post('/', authorize('admin'), validate(createUserSchema), controller.create);
userRoutes.patch('/:id', authorize('admin', 'editor'), validate(updateUserSchema), controller.update);
userRoutes.delete('/:id', authorize('admin'), controller.delete);
```

```typescript
// src/modules/users/users.controller.ts
import { Request, Response } from 'express';
import { UserService } from './users.service.js';
import { success, created, noContent, paginated } from '../../shared/utils/response.js';

export class UserController {
  constructor(private readonly userService: UserService) {}

  list = async (req: Request, res: Response) => {
    const { page, per_page, search, status } = req.query;
    const result = await this.userService.paginate({
      page: Number(page) || 1,
      perPage: Number(per_page) || 20,
      search: search as string,
      status: status as string,
    });

    res.json(paginated(result.data, result.page, result.perPage, result.total, req.baseUrl));
  };

  getById = async (req: Request, res: Response) => {
    const user = await this.userService.findById(req.params.id);
    res.json(success(user));
  };

  create = async (req: Request, res: Response) => {
    const user = await this.userService.register(req.body);
    res.status(201)
      .setHeader('Location', `${req.baseUrl}/${user.id}`)
      .json(created(user));
  };

  update = async (req: Request, res: Response) => {
    const user = await this.userService.update(req.params.id, req.body);
    res.json(success(user));
  };

  delete = async (req: Request, res: Response) => {
    await this.userService.softDelete(req.params.id);
    res.status(204).send();
  };
}
```

```typescript
// src/modules/users/users.schema.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8).max(128),
  phone: z.string().regex(/^\+?[1-9]\d{1,14}$/).optional(),
  role: z.enum(['admin', 'editor', 'viewer']).default('viewer'),
});

export const updateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  phone: z.string().regex(/^\+?[1-9]\d{1,14}$/).optional(),
  role: z.enum(['admin', 'editor', 'viewer']).optional(),
}).refine((data) => Object.keys(data).length > 0, {
  message: 'At least one field must be provided',
});

export const listUsersSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  per_page: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().min(1).optional(),
  status: z.enum(['active', 'inactive']).optional(),
  sort: z.string().default('-created_at'),
});
```

---

## Custom Error Hierarchy

```typescript
// src/shared/errors/app-error.ts
export abstract class AppError extends Error {
  abstract readonly statusCode: number;
  abstract readonly code: string;
  readonly isOperational = true;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace?.(this, this.constructor);
  }
}

export class NotFoundError extends AppError {
  readonly statusCode = 404;
  readonly code = 'NOT_FOUND';

  constructor(resource: string, id?: string) {
    super(id ? `${resource} with ID ${id} not found` : `${resource} not found`);
  }
}

export class ConflictError extends AppError {
  readonly statusCode = 409;
  readonly code = 'CONFLICT';
}

export class UnauthorizedError extends AppError {
  readonly statusCode = 401;
  readonly code = 'UNAUTHORIZED';
}

export class ForbiddenError extends AppError {
  readonly statusCode = 403;
  readonly code = 'FORBIDDEN';
}

export class BadRequestError extends AppError {
  readonly statusCode = 400;
  readonly code = 'BAD_REQUEST';
}
```

---

## Logger (Pino)

```typescript
// src/shared/utils/logger.ts
import pino from 'pino';
import { env } from '../../config/env.js';

export const logger = pino({
  level: env.LOG_LEVEL,
  ...(env.NODE_ENV === 'development'
    ? {
        transport: {
          target: 'pino-pretty',
          options: { colorize: true, translateTime: 'SYS:standard' },
        },
      }
    : {}),
  // Production: JSON output for log aggregation (ELK, Datadog, etc.)
  serializers: {
    err: pino.stdSerializers.err,
    req: pino.stdSerializers.req,
    res: pino.stdSerializers.res,
  },
  // Redact sensitive fields
  redact: {
    paths: ['req.headers.authorization', 'req.headers.cookie', '*.password', '*.token'],
    censor: '[REDACTED]',
  },
});
```

---

## Testing

```typescript
// src/modules/users/__tests__/users.service.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { UserService } from '../users.service.js';
import { NotFoundError, ConflictError } from '../../../shared/errors/app-error.js';

describe('UserService', () => {
  let service: UserService;
  let mockRepo: any;

  beforeEach(() => {
    mockRepo = {
      findById: vi.fn(),
      findByEmail: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
      paginate: vi.fn(),
    };
    service = new UserService(mockRepo);
  });

  describe('register', () => {
    it('should create user with hashed password', async () => {
      mockRepo.findByEmail.mockResolvedValue(null);
      mockRepo.create.mockResolvedValue({
        id: '123',
        name: 'John',
        email: 'john@test.com',
      });

      const result = await service.register({
        name: 'John',
        email: 'john@test.com',
        password: 'SecurePass123!',
      });

      expect(result.email).toBe('john@test.com');
      expect(mockRepo.create).toHaveBeenCalledOnce();
      // Ensure password was hashed
      const createCall = mockRepo.create.mock.calls[0][0];
      expect(createCall.password).not.toBe('SecurePass123!');
    });

    it('should throw ConflictError for duplicate email', async () => {
      mockRepo.findByEmail.mockResolvedValue({ id: '1', email: 'exists@test.com' });

      await expect(
        service.register({ name: 'Test', email: 'exists@test.com', password: 'pass123' })
      ).rejects.toThrow(ConflictError);
    });
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      mockRepo.findById.mockResolvedValue({ id: '123', name: 'John' });

      const user = await service.findById('123');
      expect(user.name).toBe('John');
    });

    it('should throw NotFoundError when user not found', async () => {
      mockRepo.findById.mockResolvedValue(null);

      await expect(service.findById('999')).rejects.toThrow(NotFoundError);
    });
  });
});

// Integration test (API level)
// src/modules/users/__tests__/users.api.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { createApp } from '../../../app.js';

describe('Users API', () => {
  const app = createApp();

  it('GET /api/v1/users — should require auth', async () => {
    const res = await request(app).get('/api/v1/users');
    expect(res.status).toBe(401);
  });

  it('GET /api/v1/users — should return paginated users', async () => {
    const res = await request(app)
      .get('/api/v1/users')
      .set('Authorization', `Bearer ${validToken}`)
      .query({ page: 1, per_page: 10 });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.meta).toHaveProperty('total');
  });
});
```

---

## Production Checklist

| # | Practice | Implementation |
|---|----------|----------------|
| 1 | **Graceful shutdown** | Handle SIGTERM/SIGINT, close connections |
| 2 | **Health endpoint** | `GET /health` returning `200 OK` |
| 3 | **Request IDs** | UUID in `X-Request-ID` header on all responses |
| 4 | **Structured logging** | Pino with JSON output, sensitive data redaction |
| 5 | **Error handling** | Custom error hierarchy, centralized error handler |
| 6 | **Input validation** | Zod schemas on all request body/query/params |
| 7 | **Rate limiting** | Express-rate-limit or Redis-based sliding window |
| 8 | **CORS** | Whitelist origins, not `*` |
| 9 | **Security headers** | Helmet.js for X-Content-Type-Options, HSTS, etc. |
| 10 | **Process management** | PM2 or Docker for restart policies |
| 11 | **Environment validation** | Fail fast if env vars are missing/invalid |
| 12 | **Compression** | gzip/brotli for JSON responses |

---

## Rules Integration
- **SOLID**: Feature modules with Controller→Service→Repository, dependency injection via constructor
- **Security**: Helmet, CORS, Zod validation, bcrypt passwords, JWT RS256, rate limiting
- **Error handling**: Custom AppError hierarchy, centralized error handler, proper HTTP status codes
- **Logging**: Pino (structured JSON), request IDs, sensitive data redaction
- **Testing**: Vitest for unit/integration, supertest for API testing, mocked repositories
