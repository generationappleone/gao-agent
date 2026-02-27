---
name: GAO Framework
description: Skill for building full-stack server-side applications with GAO Framework — covering project setup, configuration, DI container, HTTP controllers, ORM (Active Record), admin UI template, security middleware, view engine, email, queue, WebSocket, and deployment.
---

# GAO Framework Skill

## Overview
GAO Framework is a TypeScript-first, monorepo-based backend framework with 14 packages. It uses decorator-based routing, a built-in DI container, Active Record ORM, glassmorphism admin UI, and a security-first middleware chain. Runs on both **Node.js** and **Bun**.

**Runtime**: Node.js 20+ or Bun 1.0+
**Language**: TypeScript 5.9+ (strict mode, ES2023 target)
**Repository**: [github.com/generationappleone/gao-framework](https://github.com/generationappleone/gao-framework)
**Monorepo**: pnpm workspaces + Turbo

### Package Ecosystem
| Package | Import | Purpose |
|---------|--------|---------|
| `@gao/core` | `from '@gao/core'` | App lifecycle, DI container, config, events, cache, plugins |
| `@gao/http` | `from '@gao/http'` | HTTP server, controllers, decorators, middleware, sessions |
| `@gao/orm` | `from '@gao/orm'` | Database drivers, models, query builder, migrations, Active Record |
| `@gao/view` | `from '@gao/view'` | Template engine with directives, layouts, partials |
| `@gao/ui` | `from '@gao/ui'` | Fonts, icons, admin template, dashboard components |
| `@gao/security` | `from '@gao/security'` | Helmet, CORS, CSRF, rate limiter, XSS guard, JWT, RBAC |
| `@gao/email` | `from '@gao/email'` | Email sending |
| `@gao/queue` | `from '@gao/queue'` | Background job queue |
| `@gao/websocket` | `from '@gao/websocket'` | Real-time WebSocket |
| `@gao/monitor` | `from '@gao/monitor'` | Application monitoring |
| `@gao/testing` | `from '@gao/testing'` | Test utilities |
| `@gao/cli` | `from '@gao/cli'` | CLI commands |
| `@gao/desktop` | `from '@gao/desktop'` | Desktop app support |
| `@gao/mobile` | `from '@gao/mobile'` | Mobile app support |

---

## Project Setup

### 1. Initialize Project in Monorepo

GAO apps live inside the `framework/` monorepo as workspace members.

```bash
# Clone the monorepo
git clone https://github.com/generationappleone/gao-framework.git
cd gao-framework/framework

# Create your app directory
mkdir my-app
cd my-app
```

### 2. Create package.json

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/app.ts",
    "start": "node dist/app.js",
    "build": "tsc --project tsconfig.json"
  },
  "dependencies": {
    "@gao/core": "workspace:*",
    "@gao/http": "workspace:*",
    "@gao/orm": "workspace:*",
    "@gao/view": "workspace:*",
    "@gao/ui": "workspace:*",
    "@gao/security": "workspace:*"
  },
  "devDependencies": {
    "tsx": "^4.19.0",
    "pino-pretty": "^13.0.0",
    "typescript": "^5.9.0"
  }
}
```

### 3. Create tsconfig.json

```json
{
  "extends": "../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src",
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  },
  "include": ["src"]
}
```

> **CRITICAL**: `experimentalDecorators` and `emitDecoratorMetadata` MUST be `true`.  
> GAO uses `Reflect.metadata` for `@Controller`, `@Get`, `@Post`, etc.

### 4. Register in Workspace

Add your app to `framework/pnpm-workspace.yaml`:

```yaml
packages:
  - "packages/*"
  - "my-app"
```

### 5. Install Dependencies

```bash
cd ..  # back to framework/
pnpm install
pnpm --filter @gao/core --filter @gao/http --filter @gao/orm --filter @gao/view --filter @gao/ui --filter @gao/security build
```

### 6. Project Structure

```
my-app/
├── gao.config.ts                   # App config (REQUIRED in project root)
├── package.json
├── tsconfig.json
└── src/
    ├── app.ts                      # Main entry point
    ├── controllers/
    │   ├── dashboard.controller.ts # Page controllers
    │   └── api/
    │       └── user.api.controller.ts
    ├── models/                     # ORM models (Active Record)
    │   ├── user.model.ts
    │   └── post.model.ts
    ├── migrations/                 # Database migrations
    │   ├── 001_create_users.ts
    │   └── 002_create_posts.ts
    ├── services/                   # Business logic services
    │   └── user.service.ts
    ├── views/                      # View renderer helpers
    │   └── renderer.ts
    └── seed.ts                     # Database seed data
```

---

## Configuration (gao.config.ts)

GAO does NOT use `.env` files. Configuration is TypeScript-first.

```typescript
// gao.config.ts
import { defineConfig } from '@gao/core';

export default defineConfig({
    app: {
        name: 'My Application',
        port: 3000,
        environment: 'development',   // 'development' | 'staging' | 'production' | 'test'
        debug: true,
    },
    database: {
        driver: 'sqlite',            // 'postgres' | 'mysql' | 'mariadb' | 'sqlite'
        filename: 'app.db',          // SQLite only
        // For production:
        // driver: 'postgres',
        // host: 'localhost',
        // port: 5432,
        // database: 'myapp',
        // user: 'postgres',
        // password: process.env.DB_PASSWORD,  // Use system env vars for secrets
    },
    security: {
        cors: { origin: '*' },
        rateLimit: { windowMs: 60_000, maxRequests: 100 },
    },
});
```

### Config Resolution Order (last wins)
1. Framework defaults (`name: 'GaoApp'`, `port: 3000`)
2. `gao.config.ts` (user config)
3. `gao.config.{env}.ts` (environment overrides)
4. System env vars (`GAO_APP_NAME`, `GAO_APP_PORT`, `GAO_APP_DEBUG`)

### Environment Variables (System Only)
```
GAO_APP_NAME=MyApp
GAO_APP_PORT=8080
GAO_APP_DEBUG=true
```

---

## Application Entry Point (src/app.ts)

```typescript
import { createApp } from '@gao/core';
import {
    createHttpHandler,
    bodyParserMiddleware,
    Server,
} from '@gao/http';

// Import @gao/ui for side-effect font/icon registration
import '@gao/ui';

// Import controllers
import { DashboardController } from './controllers/dashboard.controller.js';
import { UserApiController } from './controllers/api/user.api.controller.js';

async function main() {
    // 1. Create application instance
    const app = createApp();

    // 2. Boot (loads config, configures logger, boots plugins)
    await app.boot();

    // 3. Create HTTP handler with controllers & middleware
    const handler = createHttpHandler({
        container: app.container,
        controllers: [
            DashboardController,
            UserApiController,
        ],
        middlewares: [
            bodyParserMiddleware(),  // Parse JSON/form bodies → req.body
        ],
    });

    // 4. Start server
    const server = new Server(handler, {
        port: app.config.app.port,
        hostname: '0.0.0.0',
    });

    await server.listen();
    app.logger.info(`🚀 Running at http://localhost:${app.config.app.port}`);
}

main().catch((error) => {
    console.error('Failed to start:', error);
    process.exit(1);
});
```

### GaoApplication Public API

```typescript
const app = createApp();

// Properties
app.config       // GaoConfig (readonly, frozen after boot)
app.container    // DI Container
app.router       // Router
app.events       // EventEmitter
app.cache        // CacheService (default: MemoryCacheAdapter)
app.logger       // Logger (pino-based)

// Methods
app.register(plugin)              // Register a plugin before boot
app.resolve<T>(token)             // Resolve from DI container
await app.boot(options?)          // Boot app (load config, plugins)
await app.shutdown()              // Graceful shutdown
```

---

## DI Container

```typescript
const { container } = app;

// Register services
container.singleton('userService', () => new UserService());
container.transient('tempService', () => new TempService());
container.instance('config', configObject);  // Pre-created instance

// Resolve services
const service = container.resolve<UserService>('userService');

// Auto-register class (reads @Inject metadata)
container.autoRegister(UserService);
```

---

## HTTP Controllers

### Page Controller (HTML responses)

```typescript
import { Controller, Get } from '@gao/http';
import type { GaoRequest, GaoResponse } from '@gao/http';

@Controller('/')
export class DashboardController {

    @Get('/')
    async index(_req: GaoRequest, res: GaoResponse) {
        const html = '<h1>Hello GAO</h1>';
        return res.html(html);
    }

    @Get('/about')
    async about(_req: GaoRequest, res: GaoResponse) {
        return res.html('<h1>About</h1>');
    }
}
```

### REST API Controller (JSON responses)

```typescript
import { Controller, Get, Post, Put, Delete, Patch } from '@gao/http';
import type { GaoRequest, GaoResponse } from '@gao/http';

@Controller('/api/users')
export class UserApiController {

    @Get('/')
    async list(req: GaoRequest, res: GaoResponse) {
        // req.query contains parsed query parameters
        const { page, search } = req.query;
        const users = await getUsers({ page, search });
        return res.json(users);
        // → { "data": [...], "meta": {...} }  (auto-wrapped in envelope)
    }

    @Get('/:id')
    async show(req: GaoRequest, res: GaoResponse) {
        // req.params contains route parameters
        const user = await findUser(req.params.id);
        if (!user) {
            return res.error(404, 'NOT_FOUND', 'User not found');
        }
        return res.json(user);
    }

    @Post('/')
    async create(req: GaoRequest, res: GaoResponse) {
        // req.body contains parsed body (from bodyParserMiddleware)
        const user = await createUser(req.body);
        return res.status(201).json(user);
    }

    @Put('/:id')
    async update(req: GaoRequest, res: GaoResponse) {
        const user = await updateUser(req.params.id, req.body);
        if (!user) {
            return res.error(404, 'NOT_FOUND', 'User not found');
        }
        return res.json(user);
    }

    @Delete('/:id')
    async destroy(req: GaoRequest, res: GaoResponse) {
        const deleted = await deleteUser(req.params.id);
        if (!deleted) {
            return res.error(404, 'NOT_FOUND', 'User not found');
        }
        return res.empty();  // 204 No Content
    }
}
```

### GaoRequest API

```typescript
// Properties
req.native          // Original Web API Request
req.method          // 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
req.url             // URL object
req.ip              // Client IP (respects X-Forwarded-For)
req.correlationId   // UUID (auto-generated or from X-Correlation-Id)
req.body            // Parsed body (set by bodyParserMiddleware)
req.query           // Parsed query params (Record<string, string>)
req.params          // Route params (e.g. { id: '123' })
req.user            // User context (set by auth middleware)
req.session         // Session data (set by sessionMiddleware)
req.flash           // Flash messages (set by flashMiddleware)

// Methods
req.header(name)    // Get specific header
req.validated<T>()  // Get validated data (from @Validate decorator)
```

### GaoResponse API

```typescript
// Builder pattern (chainable)
res.status(201)                    // Set HTTP status code
res.header('X-Custom', 'value')   // Set header

// Terminators (return Response — use ONE per handler)
res.json(data, meta?)             // JSON with envelope: { data, meta? }
res.error(status, code, message, details?)  // Error envelope: { error: { code, message } }
res.html(htmlString)              // HTML response
res.text(string)                  // Plain text response
res.redirect(url, status?)        // 302 redirect (default)
res.stream(readableStream, type?) // Stream response
res.empty()                       // 204 No Content

// Examples
return res.json({ name: 'Budi' });                    // 200 + JSON envelope
return res.status(201).json({ id: 'uuid-123' });      // 201 + JSON envelope
return res.error(422, 'VALIDATION', 'Invalid email');  // 422 + error envelope
return res.html('<h1>Hello</h1>');                     // 200 + HTML
return res.redirect('/login');                          // 302 redirect
```

### JSON Envelope Format

All `res.json()` responses are wrapped in a standard envelope:

```json
// Success
{
  "data": { "id": "uuid-123", "name": "Budi Santoso" },
  "meta": { "page": 1, "total": 50 }
}

// Error (from res.error())
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email address",
    "details": { "email": ["must be a valid email"] }
  }
}
```

### Route Decorators

```typescript
@Controller('/prefix')    // Class-level prefix
@Controller('/prefix', [middlewareFn])  // With controller-level middleware

@Get('/path')             // GET   /prefix/path
@Post('/path')            // POST  /prefix/path
@Put('/path')             // PUT   /prefix/path
@Delete('/path')          // DELETE /prefix/path
@Patch('/path')           // PATCH /prefix/path

// With route-level middleware
@Get('/path', [authMiddleware])

// Dynamic segments
@Get('/:id')              // req.params.id
@Get('/:userId/posts')    // req.params.userId

// Route-level middleware via decorator
@UseMiddleware(rateLimiter({ maxRequests: 10 }))
@Post('/upload')
async upload(req, res) { ... }
```

---

## Middleware

### Built-in Middleware

```typescript
import {
    bodyParserMiddleware,    // Parse JSON/form/multipart bodies
    corsMiddleware,          // CORS headers
    sessionMiddleware,       // Session management
    flashMiddleware,         // Flash messages
    errorHandlerMiddleware,  // Global error handler
} from '@gao/http';

const handler = createHttpHandler({
    controllers: [...],
    middlewares: [
        errorHandlerMiddleware(),
        corsMiddleware({ origin: '*' }),
        bodyParserMiddleware(),
        sessionMiddleware({ store }),
        flashMiddleware(),
    ],
});
```

### Security Middleware (from @gao/security)

```typescript
import {
    helmet,                  // Security headers
    cors,                    // CORS
    csrf,                    // CSRF protection
    rateLimiter,             // Rate limiting
    xssGuard,                // XSS protection
    ddosShield,              // DDoS mitigation
    validate,                // Input validation
    secureUpload,            // Secure file uploads
} from '@gao/security';
```

### Custom Middleware

```typescript
import type { GaoRequest, GaoResponse, MiddlewareHandler } from '@gao/http';

// Middleware is a function: (req, res, next) => Promise<Response>
function logRequest(): MiddlewareHandler {
    return async (req: GaoRequest, res: GaoResponse, next) => {
        const start = Date.now();
        const response = await next(req, res);
        console.log(`${req.method} ${req.url.pathname} — ${Date.now() - start}ms`);
        return response;
    };
}

// Use globally
const handler = createHttpHandler({
    middlewares: [logRequest(), bodyParserMiddleware()],
    controllers: [...],
});

// Or per-controller/route
@Controller('/admin', [authMiddleware()])
export class AdminController {
    @Get('/stats', [rateLimiter({ maxRequests: 10 })])
    async stats(req, res) { ... }
}
```

---

## ORM — Active Record Pattern

### Model Definition

```typescript
import { Model, Table, Column, Index, ForeignKey, Unique, Encrypted } from '@gao/orm';

@Table('users')
export class User extends Model {
    @Column({ primary: true }) id!: string;
    @Column() @Unique() email!: string;
    @Column() name!: string;
    @Column() @Encrypted() password!: string;
    @Column({ nullable: true }) avatar_url!: string | null;
    @Column() role!: 'admin' | 'user';
    @Column() is_active!: boolean;
    @Column() @Index() company_id!: string;
    @ForeignKey({ table: 'companies', column: 'id', onDelete: 'CASCADE' })
    company_id_fk!: string;
    @Column() created_at!: string;
    @Column() updated_at!: string;
    @Column({ nullable: true }) deleted_at!: string | null;
}
```

### Active Record CRUD

```typescript
import { setModelDriver } from '@gao/orm';
import { SQLiteDriver } from '@gao/orm';

// Initialize driver (once at boot)
const driver = new SQLiteDriver('app.db');
await driver.connect();
setModelDriver(driver, 'sqlite');

// ── CREATE ──
const user = await User.create({
    id: crypto.randomUUID(),
    email: 'budi@example.com',
    name: 'Budi Santoso',
    role: 'user',
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
});

// ── READ ──
const user = await User.find('uuid-here');           // By PK (nullable)
const user = await User.findOrFail('uuid-here');     // By PK (throws NotFoundError)
const users = await User.all();                       // All (excludes soft-deleted)

// ── Query Builder ──
const admins = await User
    .where('role', 'admin')
    .where('is_active', true)
    .get();

// ── UPDATE ──
const user = await User.findOrFail('uuid-here');
user.name = 'Updated Name';
await user.save();  // Only updates dirty fields

// ── DELETE (soft delete by default) ──
await user.destroy();                       // Sets deleted_at
await user.destroy({ force: true });       // Hard delete

// ── Upsert ──
const user = await User.updateOrCreate(
    { email: 'budi@example.com' },          // Match criteria
    { name: 'Budi S.', role: 'admin' },     // Data to set
);

// ── Eager Loading ──
const users = await User.with('company', 'posts').get();

// ── Dirty Tracking ──
user.name = 'Changed';
user.isDirty();             // true
user.isDirty('name');       // true
user.getDirty();            // { name: 'Changed' }

// ── Refresh ──
await user.refresh();       // Re-fetch from database

// ── JSON Serialization ──
user.toJSON();              // Returns attributes as plain object
```

### Migrations

```typescript
import type { Migration } from '@gao/orm';
import type { DatabaseDriver } from '@gao/orm';

export const CreateUsersTable: Migration = {
    name: '001_create_users',

    async up(driver: DatabaseDriver) {
        await driver.execute(`
            CREATE TABLE users (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                email VARCHAR(255) NOT NULL UNIQUE,
                name VARCHAR(255) NOT NULL,
                password TEXT NOT NULL,
                role VARCHAR(50) NOT NULL DEFAULT 'user',
                is_active BOOLEAN NOT NULL DEFAULT true,
                company_id UUID REFERENCES companies(id) ON DELETE SET NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                deleted_at TIMESTAMP
            );
            CREATE INDEX idx_users_email ON users(email);
            CREATE INDEX idx_users_company_id ON users(company_id);
        `);
    },

    async down(driver: DatabaseDriver) {
        await driver.execute('DROP TABLE IF EXISTS users');
    },
};
```

### Running Migrations

```typescript
import { MigrationEngine } from '@gao/orm';

const engine = new MigrationEngine(driver);
await engine.setup();                        // Create gao_migrations table

// Apply pending
const applied = await engine.up(migrations);

// Rollback last
const rolledBack = await engine.down(migrations, 1);

// Reset all
await engine.reset(migrations);

// Fresh (reset + re-apply)
const { rolledBack, applied } = await engine.refresh(migrations);

// Status
const status = await engine.status(migrations);
// [{ name: '001_create_users', status: 'executed', executedAt: '...', batch: 1 }]
```

### Schema Builder (Fluent API)

```typescript
import { SchemaBuilder, TableBuilder } from '@gao/orm';

const schema = new SchemaBuilder(driver);

await schema.createTable('posts', (table: TableBuilder) => {
    table.uuid('id').primary();
    table.string('title', 255);
    table.text('content');
    table.string('slug', 255).unique();
    table.uuid('author_id');
    table.boolean('published').default(false);
    table.integer('view_count').default(0);
    table.decimal('price', 10, 2).nullable();
    table.json('metadata').nullable();
    table.timestamps();           // created_at + updated_at
    table.timestamp('deleted_at').nullable();  // Soft delete
    table.foreignKey('author_id', 'users', 'id', 'CASCADE');
    table.index('slug');
    table.index(['author_id', 'published']);
});
```

### Database Conventions
- **Primary keys**: UUID (`id UUID PRIMARY KEY`)
- **Naming**: `snake_case` for columns, plural for table names  
- **Audit cols**: `created_at TIMESTAMP`, `updated_at TIMESTAMP`
- **Soft delete**: `deleted_at TIMESTAMP` (nullable)
- **Foreign keys**: `{entity}_id UUID`, always indexed
- **Supported drivers**: `postgres`, `mysql`, `mariadb`, `sqlite`

---

## Admin UI Template (@gao/ui)

### Rendering Admin Pages

```typescript
import {
    createAdminTemplate,
    statCard,
    dataTable,
    donutChart,
    barChart,
    lineChart,
    form,
    badge,
    avatar,
    progress,
    modal,
    toast,
    emptyState,
    alertBanner,
    gaoIcon,
    type SidebarItem,
    type AdminLayoutConfig,
    type StatCardConfig,
    type DataTableConfig,
} from '@gao/ui';

// ── Build a complete admin page ──
function renderPage(config: { title: string; content: string; activePath: string }): string {
    const sidebar: SidebarItem[] = [
        { section: 'MAIN' },
        { label: 'Dashboard', icon: 'home', href: '/', active: config.activePath === '/' },
        { section: 'MANAGEMENT' },
        { label: 'Users', icon: 'users', href: '/users', active: config.activePath === '/users' },
        { label: 'Settings', icon: 'settings', href: '/settings' },
    ];

    return createAdminTemplate.layout({
        title: config.title,
        brandName: 'My App',
        brandIcon: 'layout',
        sidebar,
        navbar: {
            showSearch: true,
            user: { name: 'Admin', role: 'Administrator' },
            notifications: 3,
        },
        content: config.content,
        footer: '© 2026 My App',
    });
}

// Use in controller
@Get('/')
async dashboard(_req: GaoRequest, res: GaoResponse) {
    const content = `
        <h1>Dashboard</h1>
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:20px;">
            ${statCard({ icon: 'users', value: '150', label: 'Users', trend: { value: '+12%', direction: 'up' } })}
            ${statCard({ icon: 'dollar', value: 'Rp 50.000.000', label: 'Revenue' })}
        </div>
    `;
    return res.html(renderPage({ title: 'Dashboard', content, activePath: '/' }));
}
```

### Component Reference

#### Stat Card
```typescript
statCard({
    icon: 'users',                    // GaoIconName
    value: '150',                     // string | number
    label: 'Total Users',
    trend: { value: '+12%', direction: 'up' },  // Optional
    iconColor: '#6366f1',             // Optional
    iconBg: 'rgba(99,102,241,0.15)', // Optional
});
```

#### Data Table
```typescript
// NOTE: DataTable escapes all cell values (XSS protection).
// For rich HTML content (badges, links), build raw <table> HTML instead.
dataTable({
    columns: [
        { key: 'name', label: 'Name', align: 'left' },    // align: 'left' | 'center' | 'right'
        { key: 'email', label: 'Email' },
        { key: 'role', label: 'Role' },
    ],
    rows: [
        { name: 'Budi S.', email: 'budi@test.com', role: 'Admin' },
        { name: 'Sari D.', email: 'sari@test.com', role: 'User' },
    ],
    pageInfo: { current: 1, total: 50, perPage: 10 },     // Optional pagination
});
```

> **⚠️ IMPORTANT**: `dataTable()` auto-escapes cell values with `esc()`.  
> If you need HTML in cells (badges, links, avatars), build raw `<table class="gao-admin-table">` instead.
> See the "Rich HTML Table" pattern below.

#### Charts
```typescript
donutChart([
    { label: 'Active', value: 120, color: '#22c55e' },
    { label: 'Inactive', value: 30, color: '#ef4444' },
], 180);  // optional size

barChart([
    { label: 'Jan', value: 100 },
    { label: 'Feb', value: 150 },
], 200);  // optional height

lineChart([
    { label: 'Mon', value: 42 },
    { label: 'Tue', value: 68 },
], 200);
```

#### Other Components
```typescript
badge({ text: 'Active', variant: 'success' });     // 'primary' | 'success' | 'warning' | 'danger' | 'info'
avatar({ name: 'Budi Santoso', size: 'md' });       // 'sm' | 'md' | 'lg'
progress({ value: 75, max: 100, showLabel: true });
modal({ id: 'delete-modal', title: 'Confirm', body: 'Are you sure?' });
toast({ message: 'Saved!', type: 'success' });
emptyState('No Data', 'Start by adding records.', 'inbox');
alertBanner({ message: 'Warning!', type: 'warning' });
form([{ name: 'email', label: 'Email', type: 'email', required: true }], '/submit');
gaoIcon('users', { size: 20, color: '#6366f1' });   // SVG icon string
```

### Rich HTML Table Pattern

When you need badges, links, avatars in table cells:

```typescript
const tableRows = users.map((u) => `<tr>
    <td>
        <div style="display:flex;align-items:center;gap:10px;">
            <div style="width:32px;height:32px;border-radius:50%;background:#6366f1;display:flex;align-items:center;justify-content:center;color:#fff;font-size:12px;font-weight:700;">${u.name[0]}</div>
            <div>
                <div style="font-weight:600;">${escapeHtml(u.name)}</div>
                <div style="font-size:12px;color:var(--gao-text-muted);">${escapeHtml(u.email)}</div>
            </div>
        </div>
    </td>
    <td><span style="padding:4px 10px;border-radius:12px;font-size:12px;font-weight:600;color:#fff;background:${u.role === 'admin' ? '#6366f1' : '#22c55e'}">${u.role}</span></td>
    <td style="font-size:13px;color:var(--gao-text-muted);">${timeAgo(u.created_at)}</td>
</tr>`).join('');

const html = `
<div class="gao-card" style="padding:24px;">
    <div class="gao-admin-table-wrapper">
        <table class="gao-admin-table">
            <thead><tr><th>User</th><th>Role</th><th>Joined</th></tr></thead>
            <tbody>${tableRows}</tbody>
        </table>
    </div>
</div>`;
```

### Available Icon Names (GaoIconName)

Icons are organized by category. Use `gaoIcon('name', { size, color })`:

**Navigation**: `home`, `menu`, `chevron-left`, `chevron-right`, `chevron-up`, `chevron-down`, `arrow-left`, `arrow-right`, `arrow-up`, `arrow-down`, `external-link`  
**Actions**: `plus`, `minus`, `x`, `check`, `edit`, `trash`, `save`, `copy`, `search`, `filter`, `settings`, `refresh`, `upload`, `download`, `share`, `link`  
**Status**: `check-circle`, `x-circle`, `alert-triangle`, `info`, `help-circle`, `clock`, `trending-up`, `activity`  
**Data**: `file`, `folder`, `database`, `layers`, `grid`, `list`, `inbox`, `archive`  
**Commerce**: `dollar`, `credit-card`, `shopping-cart`, `store`, `tag`, `percent`  
**Social**: `users`, `user`, `user-plus`, `mail`, `messages`, `bell`, `phone`, `globe`, `map-pin`

---

## Authentication & Security

### JWT Authentication

```typescript
import { JwtService, guard, RbacEngine } from '@gao/security';

// Setup JWT
const jwt = new JwtService({
    secret: process.env.JWT_SECRET!,
    accessTokenTtl: '15m',
    refreshTokenTtl: '7d',
});

// Generate tokens
const tokens = jwt.sign({ sub: user.id, role: user.role });
// → { accessToken: '...', refreshToken: '...' }

// Verify token
const payload = jwt.verify(tokens.accessToken);
// → { sub: 'uuid', role: 'admin', iat: 123, exp: 456 }
```

### RBAC (Role-Based Access Control)

```typescript
const rbac = new RbacEngine({
    roles: [
        { name: 'admin', permissions: ['*'] },
        { name: 'editor', permissions: ['posts:read', 'posts:write', 'posts:delete'] },
        { name: 'viewer', permissions: ['posts:read'] },
    ],
});

// Check permission
rbac.can('editor', 'posts:write');   // true
rbac.can('viewer', 'posts:delete');  // false
```

### Security Middleware Chain

```typescript
import { helmet, cors, csrf, rateLimiter, xssGuard } from '@gao/security';

const handler = createHttpHandler({
    middlewares: [
        errorHandlerMiddleware(),
        helmet(),                                    // Security headers
        cors({ origin: ['https://myapp.com'] }),    // CORS
        rateLimiter({ windowMs: 60_000, maxRequests: 100 }), // Rate limiting
        xssGuard(),                                  // XSS protection
        bodyParserMiddleware(),
    ],
    controllers: [...],
});
```

### Password Hashing

```typescript
import { hashPassword, verifyPassword } from '@gao/security';

const hash = await hashPassword('my-password');
const isValid = await verifyPassword('my-password', hash);  // true
```

### AES-256 Encryption

```typescript
import { encrypt, decrypt, deriveKey } from '@gao/security';

const key = deriveKey('master-secret', 'salt-value');
const encrypted = encrypt('sensitive data', key);
const decrypted = decrypt(encrypted, key);
```

---

## View Engine (@gao/view)

The view engine uses a custom template syntax with compiled JS functions.

```typescript
import { GaoViewEngine } from '@gao/view';

const engine = new GaoViewEngine({
    viewsDir: './src/views/templates',
    cache: true,
    extension: '.gao.html',
});

// Render a view file
const html = await engine.render('dashboard', { title: 'My Dashboard', users: [...] });
```

### Template Syntax

```html
<!-- Output (auto-escaped) -->
{{ title }}

<!-- Raw output (no escaping — use carefully) -->
{!! rawHtml !!}

<!-- Conditionals -->
@if(user.role === 'admin')
    <span>Admin Panel</span>
@elseif(user.role === 'editor')
    <span>Editor View</span>
@else
    <span>User View</span>
@endif

<!-- Loops -->
@foreach(users as user)
    <li>{{ user.name }}</li>
@endforeach

<!-- Layouts -->
@layout('layouts/main')

@section('content')
    <h1>Page Title</h1>
@endsection

<!-- In layout file: -->
{!! yieldSection('content') !!}

<!-- Partials -->
{!! partial('partials/header', { title }) !!}

<!-- Components -->
@component('card', { title: 'Stats' })
    <p>Card body content</p>
@endcomponent
```

### Built-in Template Helpers
```
{{ url('/users') }}        → URL generation
{{ asset('/css/app.css') }} → Asset URL
{{ csrf() }}               → CSRF hidden input
{{ can('posts:write') }}   → Permission check
{{ old('email', '') }}     → Previous form value
{{ paginate(meta) }}       → Pagination HTML
```

---

## Events

```typescript
const { events } = app;

// Listen
events.on('user:created', async (payload) => {
    console.log('New user:', payload.user.name);
    // Send welcome email, etc.
});

// Emit
await events.emit('user:created', { user: newUser });

// One-time listener
events.once('app:booted', async () => {
    console.log('App booted!');
});
```

---

## Caching

```typescript
const { cache } = app;

// Set with TTL (seconds)
await cache.set('user:123', userData, 3600);  // 1 hour

// Get
const user = await cache.get<UserData>('user:123');

// Check
const exists = await cache.has('user:123');

// Delete
await cache.delete('user:123');

// Clear namespace
await cache.clear('user:');
```

For Redis:
```typescript
import { RedisCacheAdapter, createRedisClient } from '@gao/core';

const redis = createRedisClient({ host: 'localhost', port: 6379 });
const cache = new CacheService(new RedisCacheAdapter(redis));
```

---

## Server Options

```typescript
const server = new Server(handler, {
    port: 3000,
    hostname: '0.0.0.0',
    timeout: 30000,           // Request timeout in ms (default 30s)
    maxBodySize: 1048576,     // Max body size in bytes (default 1MB)
    keepAliveTimeout: 5000,   // Keep-alive timeout
    tls: {                    // HTTPS (optional)
        key: fs.readFileSync('./key.pem', 'utf-8'),
        cert: fs.readFileSync('./cert.pem', 'utf-8'),
    },
});

await server.listen();   // Auto-detects Bun vs Node.js
await server.stop();     // Graceful shutdown
```

---

## Plugin System

```typescript
import type { Plugin } from '@gao/core';

const myPlugin: Plugin = {
    name: 'my-plugin',
    version: '1.0.0',

    onRegister(app) {
        // Called during app.register(plugin)
        // Use app.resolve(), app.config, etc.
    },

    onBoot(app) {
        // Called during app.boot()
        // All plugins registered, config loaded
    },

    onShutdown(app) {
        // Called during app.shutdown()
        // Cleanup connections, flush buffers, etc.
    },
};

app.register(myPlugin);
await app.boot();
```

> **⚠️ Known Issue**: The `gaoUIPlugin` from `@gao/ui` has a bug where `onRegister(container)` receives the `app` object instead of the container. **Workaround**: Import `@gao/ui` directly for side-effect registration of fonts/icons instead of using `app.register(gaoUIPlugin())`.

---

## Session Management

```typescript
import { sessionMiddleware } from '@gao/http';

// In middleware setup
middlewares: [
    sessionMiddleware({ store: memoryStore }),
],

// In controller
@Post('/login')
async login(req: GaoRequest, res: GaoResponse) {
    req.session?.set('userId', user.id);
    return res.redirect('/dashboard');
}

@Get('/profile')
async profile(req: GaoRequest, res: GaoResponse) {
    const userId = req.session?.get('userId');
    // ...
}
```

---

## Development Workflow

### Running in Development
```bash
# With tsx (recommended — fast TypeScript execution)
npx tsx src/app.ts

# With tsx watch mode (auto-restart on changes)
npx tsx watch src/app.ts

# Build for production
npx tsc --project tsconfig.json

# Run production build
node dist/app.js
```

### Build All Framework Packages First
```bash
cd framework/
pnpm --filter @gao/core --filter @gao/http --filter @gao/orm --filter @gao/view --filter @gao/ui --filter @gao/security build
```

### Required Dev Dependencies
```bash
pnpm add -D tsx pino-pretty typescript
```

> **CRITICAL**: Always install `pino-pretty` as a devDependency. The logger uses it for pretty-printing in development mode. Without it, the app will crash with `"unable to determine transport target for pino-pretty"`.

---

## Complete Working Example (CRM App)

```typescript
// ── gao.config.ts ──
import { defineConfig } from '@gao/core';

export default defineConfig({
    app: {
        name: 'GAO CRM',
        port: 3000,
        environment: 'development',
        debug: true,
    },
});

// ── src/app.ts ──
import { createApp } from '@gao/core';
import { createHttpHandler, bodyParserMiddleware, Server } from '@gao/http';
import '@gao/ui';
import { DashboardController } from './controllers/dashboard.controller.js';
import { ApiContactController } from './controllers/api/contact.api.controller.js';

async function main() {
    const app = createApp();
    await app.boot();

    const handler = createHttpHandler({
        container: app.container,
        controllers: [DashboardController, ApiContactController],
        middlewares: [bodyParserMiddleware()],
    });

    const server = new Server(handler, { port: app.config.app.port });
    await server.listen();
    app.logger.info(`🚀 CRM running at http://localhost:${app.config.app.port}`);
}

main().catch(console.error);

// ── src/controllers/dashboard.controller.ts ──
import { Controller, Get } from '@gao/http';
import type { GaoRequest, GaoResponse } from '@gao/http';
import { createAdminTemplate, statCard, gaoIcon, type SidebarItem } from '@gao/ui';

@Controller('/')
export class DashboardController {
    @Get('/')
    async index(_req: GaoRequest, res: GaoResponse) {
        const sidebar: SidebarItem[] = [
            { section: 'MAIN' },
            { label: 'Dashboard', icon: 'home', href: '/', active: true },
            { section: 'CRM' },
            { label: 'Contacts', icon: 'users', href: '/contacts' },
        ];

        const stats = `
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:20px;">
            ${statCard({ icon: 'users', value: '8', label: 'Total Contacts', trend: { value: '+12%', direction: 'up' } })}
            ${statCard({ icon: 'dollar', value: 'Rp 250.000.000', label: 'Revenue' })}
        </div>`;

        const html = createAdminTemplate.layout({
            title: 'Dashboard — CRM',
            brandName: 'GAO CRM',
            sidebar,
            navbar: { showSearch: true, user: { name: 'Admin' }, notifications: 3 },
            content: `<div style="padding:8px;"><h1>Dashboard</h1>${stats}</div>`,
        });

        return res.html(html);
    }
}

// ── src/controllers/api/contact.api.controller.ts ──
import { Controller, Get, Post, Put, Delete } from '@gao/http';
import type { GaoRequest, GaoResponse } from '@gao/http';

@Controller('/api/contacts')
export class ApiContactController {
    @Get('/')
    async list(_req: GaoRequest, res: GaoResponse) {
        return res.json({ contacts: [] });
    }

    @Post('/')
    async create(req: GaoRequest, res: GaoResponse) {
        return res.status(201).json(req.body);
    }

    @Get('/:id')
    async show(req: GaoRequest, res: GaoResponse) {
        return res.json({ id: req.params.id });
    }

    @Put('/:id')
    async update(req: GaoRequest, res: GaoResponse) {
        return res.json({ id: req.params.id, ...req.body });
    }

    @Delete('/:id')
    async destroy(_req: GaoRequest, res: GaoResponse) {
        return res.empty();
    }
}
```

---

## Common Gotchas

| Issue | Cause | Solution |
|-------|-------|----------|
| `container.singleton is not a function` | Using `gaoUIPlugin()` — plugin receives `app`, not container | Import `@gao/ui` directly instead of `app.register(gaoUIPlugin())` |
| `unable to determine transport target for "pino-pretty"` | Missing `pino-pretty` package | `pnpm add -D pino-pretty` |
| Decorators don't work | Missing tsconfig options | Set `experimentalDecorators: true` and `emitDecoratorMetadata: true` |
| `req.body` is empty | Missing bodyParserMiddleware | Add `bodyParserMiddleware()` to middlewares array |
| `req.json()` doesn't exist | GaoRequest has no `.json()` method | Use `req.body` (parsed by bodyParserMiddleware) |
| `dataTable` escapes HTML | By design — XSS protection | Build raw `<table class="gao-admin-table">` for rich content |
| Route params undefined | Params not extracted | Use `req.params.id` (auto-populated from `:id` segments) |
| Config not loading | Wrong CWD | Run from the project root (where `gao.config.ts` lives) |
| `sortable` property error | `DataTableColumn` doesn't have `sortable` | Only `key`, `label`, `align` are valid column properties |
| `trend` type error | `trend` expects object, not string | Use `{ value: '+12%', direction: 'up' }` format |
| Module not found errors | Framework packages not built | Run `pnpm --filter @gao/core ... build` first |
| Can't use `.env` files | GAO doesn't use dotenv | Use `gao.config.ts` + system env vars |

---

## Best Practices

| Practice | Description |
|----------|-------------|
| **Config in TypeScript** | Use `gao.config.ts` with `defineConfig()` for type-safe config |
| **Secrets in system env** | Use `process.env.DB_PASSWORD` — never hardcode passwords |
| **Controllers are thin** | Keep business logic in services, controllers only handle HTTP |
| **UUID primary keys** | Use `crypto.randomUUID()` for all IDs |
| **Audit columns** | Always include `created_at`, `updated_at`, `deleted_at` |
| **Soft delete by default** | Use `deleted_at` — hard delete only with `force: true` |
| **Body parser first** | Register `bodyParserMiddleware()` early for `req.body` to work |
| **Import @gao/ui** | Import for side-effects to register fonts/icons |
| **Build before run** | Build framework packages before running your app |
| **Use pino-pretty** | Install as devDependency for readable dev logs |

---

## Rules Integration
- **Architecture**: TypeScript monorepo, decorator-based controllers, service layer for business logic
- **Database**: UUID PKs, snake_case columns, audit timestamps, soft delete, indexed foreign keys
- **Security**: Input validation on ALL endpoints, parameterized queries, password hashing, JWT + RBAC
- **API Design**: RESTful conventions, standard JSON envelope, proper HTTP status codes
- **Error Handling**: `res.error(status, code, message)` — structured error responses
