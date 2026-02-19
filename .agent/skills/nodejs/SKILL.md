---
name: Node.js
description: Skill for building server-side applications with Node.js, covering Express/Fastify, project structure, middleware, authentication, database integration, error handling, and deployment.
---

# Node.js Skill

## Overview
Node.js is a JavaScript/TypeScript runtime for building scalable server-side applications. This skill covers Express.js, Fastify, clean architecture, authentication, and production patterns. See JavaScript skill for language-level patterns.

## Project Setup

```bash
mkdir my-api && cd my-api
npm init -y
npm install express cors helmet morgan compression dotenv
npm install -D typescript @types/node @types/express tsx nodemon
npx tsc --init
```

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### package.json Scripts
```json
{
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "vitest",
    "lint": "eslint src/",
    "typecheck": "tsc --noEmit"
  }
}
```

## Project Structure (Clean Architecture)
```
src/
├── server.ts                  # Entry point — bootstrap
├── app.ts                     # Express/Fastify app setup
├── config/
│   ├── env.ts                 # Validated env vars (Zod)
│   └── database.ts            # DB connection
├── modules/
│   └── users/
│       ├── user.entity.ts     # Domain model
│       ├── user.repository.ts # Data access interface + impl
│       ├── user.service.ts    # Business logic
│       ├── user.controller.ts # HTTP handlers
│       ├── user.routes.ts     # Route definitions
│       ├── user.dto.ts        # Request/response schemas (Zod)
│       └── user.test.ts       # Tests
├── middleware/
│   ├── auth.middleware.ts     # JWT verification
│   ├── error.middleware.ts    # Global error handler
│   ├── validate.middleware.ts # Request validation
│   └── rate-limit.middleware.ts
├── shared/
│   ├── errors/
│   │   ├── AppError.ts        # Base error class
│   │   ├── NotFoundError.ts
│   │   └── ValidationError.ts
│   ├── types/
│   └── utils/
│       ├── logger.ts          # Pino/Winston
│       └── asyncHandler.ts    # Catch async errors
└── types/
    └── express.d.ts           # Extended Request type
```

## Express App Setup
```typescript
// app.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { errorMiddleware } from './middleware/error.middleware';
import { userRoutes } from './modules/users/user.routes';
import { rateLimiter } from './middleware/rate-limit.middleware';

const app = express();

// Security & parsing
app.use(helmet());
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(','), credentials: true }));
app.use(compression());
app.use(express.json({ limit: '10kb' }));  // Limit body size
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));
app.use(rateLimiter);

// Health check
app.get('/health', (_, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

// Routes
app.use('/api/v1/users', userRoutes);

// 404 handler
app.all('*', (req, res) => {
  res.status(404).json({ error: `Route ${req.method} ${req.originalUrl} not found` });
});

// Global error handler (MUST be last)
app.use(errorMiddleware);

export { app };
```

## Controller Pattern
```typescript
// modules/users/user.controller.ts
import { Request, Response, NextFunction } from 'express';
import { UserService } from './user.service';
import { CreateUserDto, UpdateUserDto } from './user.dto';

export class UserController {
  constructor(private readonly userService: UserService) {}

  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { page = 1, limit = 20 } = req.query;
      const result = await this.userService.findAll(Number(page), Number(limit));
      res.json(result);
    } catch (error) { next(error); }
  };

  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = await this.userService.findById(req.params.id);
      if (!user) return res.status(404).json({ error: 'User not found' });
      res.json(user);
    } catch (error) { next(error); }
  };

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const dto = CreateUserDto.parse(req.body);  // Zod validation
      const user = await this.userService.create(dto);
      res.status(201).json(user);
    } catch (error) { next(error); }
  };

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const dto = UpdateUserDto.parse(req.body);
      const user = await this.userService.update(req.params.id, dto);
      res.json(user);
    } catch (error) { next(error); }
  };

  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      await this.userService.softDelete(req.params.id);
      res.status(204).send();
    } catch (error) { next(error); }
  };
}
```

## Route Definition
```typescript
// modules/users/user.routes.ts
import { Router } from 'express';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { UserRepository } from './user.repository';
import { authMiddleware } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';
import { CreateUserDto } from './user.dto';

const router = Router();
const controller = new UserController(new UserService(new UserRepository()));

router.get('/',          authMiddleware,                    controller.getAll);
router.get('/:id',       authMiddleware,                    controller.getById);
router.post('/',         authMiddleware, validate(CreateUserDto), controller.create);
router.put('/:id',       authMiddleware,                    controller.update);
router.delete('/:id',    authMiddleware,                    controller.delete);

export { router as userRoutes };
```

## Global Error Handler
```typescript
// middleware/error.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { AppError } from '../shared/errors/AppError';
import { logger } from '../shared/utils/logger';

export function errorMiddleware(err: Error, req: Request, res: Response, _next: NextFunction) {
  // Zod validation errors
  if (err instanceof ZodError) {
    return res.status(400).json({
      error: 'Validation failed',
      details: err.errors.map(e => ({ field: e.path.join('.'), message: e.message })),
    });
  }

  // Known application errors
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: err.message });
  }

  // Unknown errors
  logger.error({ err, method: req.method, url: req.url }, 'Unhandled error');
  res.status(500).json({ error: 'Internal server error' });
}
```

## JWT Authentication Middleware
```typescript
// middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';

export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) return res.status(401).json({ error: 'Authentication required' });

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as { userId: string; role: string };
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}
```

## Environment Validation
```typescript
// config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  ALLOWED_ORIGINS: z.string().default('http://localhost:3000'),
});

export const env = envSchema.parse(process.env);
```

## Key Libraries
| Category | Recommended |
|----------|------------|
| **Framework** | Express.js (stable), Fastify (performance) |
| **Validation** | Zod, Joi |
| **ORM** | Prisma, Drizzle ORM, TypeORM |
| **Auth** | jsonwebtoken, passport |
| **Logging** | Pino, Winston |
| **Testing** | Vitest, Supertest |
| **Rate Limiting** | express-rate-limit |
| **Process Manager** | PM2, Docker |

## Rules Integration
- **SOLID**: Module-based architecture, DI via constructor, interface-driven repositories
- **Security**: Helmet, CORS, rate limiting, JWT, input validation, body size limits
- **Database**: UUID PKs, soft delete, audit columns via repository pattern
- **Dependencies**: Validate env with Zod, lock versions with `package-lock.json`
