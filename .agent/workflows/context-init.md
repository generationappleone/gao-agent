---
description: Initialize project context by analyzing the entire codebase, frameworks, database, dependencies, and generating comprehensive documentation as the AI agent's primary reference.
---

# Context Init — Full Project Analysis & Documentation

## Purpose
This workflow performs a **complete project analysis** to generate comprehensive documentation that serves as the **primary reference** for the AI agent. Run this workflow **once** when first encountering a new project, or when major structural changes have been made.

The output is a set of documentation files in `.agent/context/` that the agent should **always consult first** before writing any new code, creating new flows, or making architectural decisions.

> **Cross-OS Note:** Shell commands below are written for Unix/Linux (bash). On **Windows/PowerShell**, the agent MUST automatically adapt commands:
> - `ls -la` → `Get-ChildItem` or `dir`
> - `find . -type f` → `Get-ChildItem -Recurse -File` or use the `find_by_name` tool
> - `head -N` → `Select-Object -First N`
> - `grep -rn` → `Select-String -Recurse` or use the `grep_search` tool
> - **Preferred:** Use the agent's built-in tools (`list_dir`, `find_by_name`, `grep_search`) which are OS-agnostic.

---

## Phase 0: Load Mandatory Rules
// turbo
Read these rules BEFORE analyzing the project:
- `.agent/rules/deep-thinking.md` — Deep analysis, anti-hallucination, quality standards (MANDATORY)
- `.agent/rules/developer-security.md` — Security awareness during analysis (MANDATORY)

---

## Phase 0.5: Agent Lock Check (Race Condition Prevention)
// turbo
1. Check if `.agent/context/AGENT_LOCK` exists.
2. If it exists, STOP! Another agent is currently executing. Inform the user and abort.
3. If it does not exist, immediately create `.agent/context/AGENT_LOCK` with the current timestamp.
4. IMPORTANT: Meticulously delete `.agent/context/AGENT_LOCK` at the very end of this workflow OR whenever you pause to ask the user a question.

## Phase 1: Project Discovery

### Step 1.1 — Identify Project Root & Top-Level Structure
// turbo
```
List the project root directory to understand the top-level organization.
Identify key indicators: package.json, composer.json, pom.xml, go.mod, pyproject.toml,
requirements.txt, Cargo.toml, *.sln, *.csproj, pubspec.yaml, Gemfile, Makefile,
docker-compose.yml, Dockerfile, .env.example, etc.
```

Run:
```bash
ls -la
```

Record:
- Project root path
- All top-level files and directories
- Initial assessment of project type (monorepo, single app, microservices)

### Step 1.2 — Map Complete Directory Tree
// turbo
```
Generate a full directory tree excluding common non-essential directories.
```

Run:
```bash
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/.next/*' -not -path '*/coverage/*' -not -path '*/.nuxt/*' -not -path '*/target/*' -not -path '*/bin/Debug/*' -not -path '*/bin/Release/*' -not -path '*/obj/*' -not -path '*/.dart_tool/*' -not -path '*/.gradle/*' | head -500
```

If the project is large, also run:
```bash
find . -maxdepth 3 -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' | sort
```

### Step 1.3 — Identify All Sub-Applications
For each directory that appears to be a separate application or service:
// turbo
```bash
# Find all manifest/config files that indicate separate apps
find . -maxdepth 4 \( -name "package.json" -o -name "composer.json" -o -name "pom.xml" -o -name "go.mod" -o -name "pyproject.toml" -o -name "requirements.txt" -o -name "Cargo.toml" -o -name "*.sln" -o -name "*.csproj" -o -name "pubspec.yaml" -o -name "Gemfile" \) -not -path '*/node_modules/*' -not -path '*/vendor/*'
```

---

## Phase 2: Language & Framework Detection

### Step 2.1 — Identify Programming Languages
// turbo
```
Count files by extension to determine primary and secondary languages.
```

Run:
```bash
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -30
```

### Step 2.2 — Identify Frameworks
Read the relevant manifest files found in Step 1.3 to identify frameworks:

For **each** manifest file found, read it:
```
- package.json → Check "dependencies" and "devDependencies" for:
  - React, Next.js, Vue, Nuxt, Angular, Express, Fastify, NestJS, etc.
- composer.json → Check "require" for:
  - laravel/framework, symfony/*, wordpress, etc.
- pom.xml / build.gradle → Check for:
  - spring-boot, quarkus, micronaut, etc.
- go.mod → Check for:
  - gin, echo, fiber, chi, etc.
- pyproject.toml / requirements.txt → Check for:
  - django, fastapi, flask, etc.
- pubspec.yaml → Check for:
  - flutter, dart packages
- *.csproj → Check for:
  - Microsoft.AspNetCore, EntityFrameworkCore, etc.
```

### Step 2.3 — Identify Runtime Versions
// turbo
```bash
# Check version files
cat .node-version .nvmrc .python-version .ruby-version .java-version .tool-versions 2>/dev/null
cat .editorconfig 2>/dev/null
```

Also check:
- `engines` field in `package.json`
- `require.php` in `composer.json`
- `java.sourceCompatibility` in `build.gradle`
- `<TargetFramework>` in `.csproj`

---

## Phase 3: Dependency Analysis

### Step 3.1 — List All Dependencies
For **each application** found:

**Node.js / JavaScript:**
// turbo
```bash
cat package.json | grep -A 1000 '"dependencies"' | head -50
cat package.json | grep -A 1000 '"devDependencies"' | head -50
```

**PHP / Laravel:**
// turbo
```bash
cat composer.json | grep -A 1000 '"require"' | head -50
```

**Python:**
// turbo
```bash
cat requirements.txt 2>/dev/null || cat pyproject.toml 2>/dev/null | head -80
```

**Java:**
```bash
cat pom.xml | grep -A 2 '<dependency>' | head -80
```

**Go:**
// turbo
```bash
cat go.mod
```

**.NET:**
```bash
cat *.csproj | grep 'PackageReference' | head -30
```

### Step 3.2 — Identify Key Dependencies & Their Roles
Categorize each dependency into:

| Category | Examples |
|----------|---------|
| **Core Framework** | React, Laravel, Django, Spring Boot |
| **Database ORM/Driver** | Prisma, Eloquent, SQLAlchemy, TypeORM |
| **Authentication** | NextAuth, Sanctum, Passport, JWT |
| **State Management** | Redux, Zustand, Pinia, BLoC |
| **API Client** | Axios, TanStack Query, SWR |
| **UI Library** | Tailwind, MUI, shadcn/ui, Bootstrap |
| **Testing** | Jest, Vitest, PHPUnit, pytest |
| **Build Tool** | Vite, Webpack, esbuild |
| **Dev Tools** | ESLint, Prettier, TypeScript |
| **Infrastructure** | Docker, Redis, Kafka |

### Step 3.3 — Check for Security Vulnerabilities
// turbo
```bash
# Node.js
npm audit --json 2>/dev/null | head -50

# Python
pip audit 2>/dev/null | head -30

# PHP
composer audit 2>/dev/null | head -30
```

---

## Phase 4: Database Analysis

### Step 4.1 — Identify Database Type
Look for database configuration in:
```
- .env / .env.example → DATABASE_URL, DB_CONNECTION, DB_HOST
- config/database.php (Laravel)
- prisma/schema.prisma (Prisma)
- ormconfig.ts / data-source.ts (TypeORM)
- alembic.ini (SQLAlchemy)
- application.properties / application.yml (Spring Boot)
- docker-compose.yml → database services
```

// turbo
```bash
cat .env.example 2>/dev/null || cat .env.sample 2>/dev/null || cat .env.development 2>/dev/null | grep -i "DB_\|DATABASE_\|MONGO\|REDIS\|POSTGRES\|MYSQL" | head -20
```

### Step 4.2 — Extract Schema / Migrations

**Prisma:**
```bash
cat prisma/schema.prisma
```

**Laravel:**
// turbo
```bash
find . -path "*/migrations/*.php" -not -path '*/vendor/*' | sort
# Then read each migration file
```

**Django:**
// turbo
```bash
find . -path "*/migrations/*.py" -not -path '*/__pycache__/*' -not -name "__init__.py" | sort
```

**TypeORM / EF Core:**
```bash
find . -path "*/migrations/*" -not -path '*/node_modules/*' | sort
find . -path "*/entities/*.ts" -o -path "*/entity/*.ts" -not -path '*/node_modules/*' | sort
```

**Raw SQL:**
```bash
find . -name "*.sql" -not -path '*/node_modules/*' -not -path '*/vendor/*' | sort
```

### Step 4.3 — Document Database Schema
For each table/collection found, document:
- Table name
- Columns (name, type, nullable, default)
- Primary keys (UUID vs auto-increment)
- Foreign keys & relationships
- Indexes
- Soft delete columns (deleted_at)
- Audit columns (created_at, updated_at)
- Any custom constraints or triggers

### Step 4.4 — Generate ER Diagram (Text-based)
Create a text-based entity relationship diagram:
```
users (1) ──── (N) orders
  │                 │
  │                 ├── (N) order_items (N) ──── (1) products
  │                 │
  └── (N) addresses └── (1) payments
```

---

## Phase 5: Architecture & Code Structure Analysis

### Step 5.1 — Identify Architecture Pattern
Determine which pattern(s) are used:
- **MVC** (Model-View-Controller)
- **Clean Architecture** (Domain/Application/Infrastructure/Presentation)
- **Feature-based** (modules by feature)
- **Layered** (controllers/services/repositories)
- **Microservices** (separate deployable services)
- **Monolith** (single deployable unit)
- **Serverless** (cloud functions)
- **Monorepo** (multiple packages in one repo)

### Step 5.2 — Map Code Structure
For each application, document the directory structure with purpose:

```
src/
├── controllers/     → HTTP request handlers (purpose: ___)
├── services/        → Business logic (purpose: ___)
├── repositories/    → Data access layer (purpose: ___)
├── models/          → Data models/entities (purpose: ___)
├── middleware/       → Request pipeline (purpose: ___)
├── routes/          → Route definitions (purpose: ___)
├── utils/           → Utility functions (purpose: ___)
├── config/          → Configuration (purpose: ___)
├── types/           → TypeScript types/interfaces (purpose: ___)
└── tests/           → Test files (purpose: ___)
```

### Step 5.3 — Identify Entry Points
Find and document all application entry points:
// turbo
```bash
# Common entry points
find . -maxdepth 3 \( -name "index.ts" -o -name "index.js" -o -name "main.ts" -o -name "main.py" -o -name "app.py" -o -name "server.ts" -o -name "server.js" -o -name "Program.cs" -o -name "main.go" -o -name "Application.java" -o -name "main.dart" \) -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/dist/*'
```

### Step 5.4 — Map API Endpoints / Routes
Find all route definitions:
// turbo
```bash
# Express/Node.js
grep -rn "router\.\(get\|post\|put\|patch\|delete\)\|app\.\(get\|post\|put\|patch\|delete\)" --include="*.ts" --include="*.js" -not -path '*/node_modules/*' | head -50

# Laravel
grep -rn "Route::" --include="*.php" -not -path '*/vendor/*' | head -50

# Django
grep -rn "path\|url\(" --include="*.py" -not -path '*/__pycache__/*' | grep -v migration | head -50

# Spring Boot
grep -rn "@GetMapping\|@PostMapping\|@PutMapping\|@DeleteMapping\|@RequestMapping" --include="*.java" | head -50

# ASP.NET
grep -rn '\[Http\(Get\|Post\|Put\|Delete\)\]' --include="*.cs" | head -50
```

### Step 5.5 — Identify Middleware & Guards
```bash
# Find middleware files
find . -path "*/middleware/*" -type f -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -20

# Find guards/policies
find . \( -path "*/guards/*" -o -path "*/policies/*" -o -path "*/permissions/*" \) -type f -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -20
```

---

## Phase 6: Configuration & Environment Analysis

### Step 6.1 — Environment Variables
// turbo
```bash
cat .env.example 2>/dev/null || cat .env.sample 2>/dev/null
```

Document each environment variable:
| Variable | Purpose | Required | Example |
|----------|---------|----------|---------|
| `DATABASE_URL` | Database connection string | Yes | `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | JWT signing key | Yes | 32+ character string |
| ... | ... | ... | ... |

### Step 6.2 — Docker Configuration
If Docker is present:
```bash
cat Dockerfile
cat docker-compose.yml
cat docker-compose.dev.yml 2>/dev/null
cat docker-compose.prod.yml 2>/dev/null
```

Document:
- Services defined (app, db, redis, nginx, etc.)
- Port mappings
- Volume mounts
- Environment variables
- Health checks
- Networks

### Step 6.3 — CI/CD Pipeline
```bash
cat .github/workflows/*.yml 2>/dev/null
cat .gitlab-ci.yml 2>/dev/null
cat Jenkinsfile 2>/dev/null
cat .circleci/config.yml 2>/dev/null
```

### Step 6.4 — Build & Run Scripts
```bash
cat package.json | grep -A 30 '"scripts"' 2>/dev/null
cat Makefile 2>/dev/null | head -50
```

---

## Phase 7: Testing Analysis

### Step 7.1 — Identify Test Framework & Coverage
```bash
# Find test files
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "*Test.php" -o -name "*Test.java" -o -name "test_*.py" -o -name "*_test.go" \) -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -30

# Count test files
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "*Test.php" -o -name "*Test.java" -o -name "test_*.py" -o -name "*_test.go" \) -not -path '*/node_modules/*' -not -path '*/vendor/*' | wc -l
```

### Step 7.2 — Test Configuration
```bash
# Jest config
cat jest.config.* 2>/dev/null
# Vitest config
cat vitest.config.* 2>/dev/null
# PHPUnit config
cat phpunit.xml 2>/dev/null | head -30
# pytest config
cat pytest.ini 2>/dev/null || cat pyproject.toml 2>/dev/null | grep -A 10 'pytest'
```

---

## Phase 8: Business Logic Analysis

### Step 8.1 — Read README & Documentation
// turbo
```bash
cat README.md 2>/dev/null | head -200
find . -maxdepth 2 -name "*.md" -not -path '*/.git/*' -not -path '*/node_modules/*' | head -20
```

### Step 8.2 — Identify Application Purpose
Based on all gathered information, determine:
1. **Primary purpose** of the application (e.g., e-commerce, SaaS, content management)
2. **Target users** (e.g., end consumers, admins, developers)
3. **Key features** (list all major functionalities)
4. **Business domains** (e.g., Users, Orders, Products, Payments)

### Step 8.3 — Map Business Domains
For each domain, document:
```
Domain: Orders
├── Models: Order, OrderItem, OrderStatus
├── Services: OrderService, PaymentService
├── Controllers: OrderController
├── Routes: POST /orders, GET /orders/:id, PUT /orders/:id/status
├── Events: OrderCreated, OrderPaid, OrderShipped
└── Business Rules:
    - Order total must be > 0
    - Cannot cancel after shipping
    - Auto-cancel after 24h without payment
```

---

## Phase 9: Generate Documentation

### Step 9.1 — Create Context Directory
// turbo
```bash
mkdir -p .agent/context
```

### Step 9.2 — Generate `PROJECT_OVERVIEW.md`

Create file: `.agent/context/PROJECT_OVERVIEW.md`

Content structure:
```markdown
# Project Overview

## General Information
- **Project Name:** [name]
- **Project Type:** [monorepo / single app / microservices]
- **Primary Language(s):** [TypeScript, PHP, Python, etc.]
- **Framework(s):** [Next.js, Laravel, Django, etc.]
- **Runtime Version(s):** [Node 20, PHP 8.3, Python 3.12, etc.]
- **Database(s):** [PostgreSQL, MySQL, MongoDB, etc.]
- **Cache/Queue:** [Redis, RabbitMQ, Kafka, etc.]

## Purpose & Goals
[Detailed description of what this application does, who uses it, and why it exists]

## Key Features
1. [Feature 1 — brief description]
2. [Feature 2 — brief description]
...

## Architecture
[Architecture pattern, diagram, and explanation]

## Applications / Services
| Service | Language | Framework | Port | Purpose |
|---------|----------|-----------|------|---------|
| API     | TypeScript | Express | 3000 | REST API backend |
| Web     | TypeScript | Next.js | 3001 | Frontend application |
| Worker  | Python   | Celery  | —    | Background jobs |
```

### Step 9.3 — Generate `ARCHITECTURE.md`

Create file: `.agent/context/ARCHITECTURE.md`

Content structure:
```markdown
# Architecture

## System Architecture
[High-level architecture diagram — text-based]

## Directory Structure
[Annotated directory tree with purpose of each folder]

## Design Patterns
[Patterns used: Repository, Service Layer, CQRS, Event Sourcing, etc.]

## Data Flow
[Request → Middleware → Controller → Service → Repository → Database]

## Authentication Flow
[How auth works: JWT, sessions, OAuth, etc.]

## Error Handling Strategy
[How errors are caught, logged, and returned to users]
```

### Step 9.4 — Generate `DATABASE_SCHEMA.md`

Create file: `.agent/context/DATABASE_SCHEMA.md`

Content structure:
```markdown
# Database Schema

## Database Type & Version
[PostgreSQL 16, MySQL 8, etc.]

## Entity Relationship Diagram
[Text-based ER diagram]

## Tables

### users
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| email | VARCHAR(255) | No | — | Unique email |
| ...

### orders
[Same format for each table]

## Relationships
[Document all foreign keys and their cascade behavior]

## Indexes
[List all indexes and their purpose]

## Migration History
[List of migrations in order, with what each one does]
```

### Step 9.5 — Generate `API_REFERENCE.md`

Create file: `.agent/context/API_REFERENCE.md`

Content structure:
```markdown
# API Reference

## Base URL
[http://localhost:3000/api/v1]

## Authentication
[How to authenticate: Bearer token, API key, session cookie]

## Endpoints

### Users
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /api/v1/auth/register | No | Register new user |
| POST | /api/v1/auth/login | No | Login |
| GET | /api/v1/users/me | Yes | Get current user |
| PUT | /api/v1/users/me | Yes | Update profile |

### Orders
[Same format for each domain]

## Request/Response Examples
[Provide example payloads for key endpoints]

## Error Codes
| Code | Message | Description |
|------|---------|-------------|
| 400 | Validation Error | Invalid request body |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 500 | Internal Error | Server error |
```

### Step 9.6 — Generate `DEPENDENCIES.md`

Create file: `.agent/context/DEPENDENCIES.md`

Content structure:
```markdown
# Dependencies

## Production Dependencies
| Package | Version | Category | Purpose |
|---------|---------|----------|---------|
| express | ^4.18.2 | Framework | HTTP server |
| prisma | ^5.10.0 | ORM | Database access |
| ...

## Development Dependencies
| Package | Version | Category | Purpose |
|---------|---------|----------|---------|
| vitest | ^1.3.0 | Testing | Unit/integration tests |
| eslint | ^8.56.0 | Linting | Code quality |
| ...

## Security Status
[Result of npm audit / pip audit / composer audit]

## Outdated Packages
[List of packages that need updating]
```

### Step 9.7 — Generate `DEVELOPMENT_GUIDE.md`

Create file: `.agent/context/DEVELOPMENT_GUIDE.md`

Content structure:
```markdown
# Development Guide

## Prerequisites
[Node.js 20+, Docker, etc.]

## Setup
[Step-by-step setup instructions]

## Environment Variables
[Table of all env vars with descriptions]

## Running Locally
[Commands to start the application]

## Running Tests
[Commands to run tests]

## Building for Production
[Build commands]

## Deployment
[Deployment process]

## Coding Conventions
[Naming, file structure, patterns to follow]
```

### Step 9.8 — Generate `BUSINESS_DOMAINS.md`

Create file: `.agent/context/BUSINESS_DOMAINS.md`

Content structure:
```markdown
# Business Domains

## Domain Map
[Visual overview of all domains and their relationships]

## Domain: Users
### Models
[List all models/entities in this domain]

### Business Rules
[List all business rules]

### Events
[List all domain events]

### API Surface
[List all endpoints for this domain]

## Domain: Orders
[Same structure for each domain]
```

### Step 9.9 — Generate `CONTEXT_INDEX.md`

Create file: `.agent/context/CONTEXT_INDEX.md`

This is the **master index** that the agent reads first:

```markdown
# Context Index

> **This file is the FIRST reference** for the AI agent.
> Read this file before writing ANY new code.
> Last generated: [timestamp]

## Quick Reference
- **Stack:** [TypeScript + Next.js + PostgreSQL + Redis]
- **Architecture:** [Clean Architecture with Service Layer]
- **Auth:** [JWT with refresh tokens]
- **Database:** [PostgreSQL 16 with Prisma ORM]

## Documentation Files
| File | Purpose | Read When |
|------|---------|-----------|
| PROJECT_OVERVIEW.md | High-level project summary | Always (first) |
| ARCHITECTURE.md | System design & patterns | Creating new features/modules |
| DATABASE_SCHEMA.md | Tables, columns, relationships | Any database work |
| API_REFERENCE.md | All API endpoints | Adding/modifying endpoints |
| DEPENDENCIES.md | Package list & purposes | Adding new dependencies |
| DEVELOPMENT_GUIDE.md | Setup & conventions | Setting up or onboarding |
| BUSINESS_DOMAINS.md | Domain models & rules | Understanding business logic |

## Rules to Follow
[List all rules from .agent/rules/ with brief description of each]

## Available Skills
[List all skills from .agent/skills/ with brief description of each]
```

---

## Phase 10: Validation & Summary

### Step 10.1 — Verify All Files Generated
// turbo
```bash
ls -la .agent/context/
```

Ensure all 8 files exist:
- [ ] `CONTEXT_INDEX.md`
- [ ] `PROJECT_OVERVIEW.md`
- [ ] `ARCHITECTURE.md`
- [ ] `DATABASE_SCHEMA.md`
- [ ] `API_REFERENCE.md`
- [ ] `DEPENDENCIES.md`
- [ ] `DEVELOPMENT_GUIDE.md`
- [ ] `BUSINESS_DOMAINS.md`

### Step 10.2 — Print Summary
Print a summary of what was discovered:

```
╔══════════════════════════════════════════════════════╗
║              CONTEXT INIT COMPLETE ✅                ║
╠══════════════════════════════════════════════════════╣
║  Project: [name]                                     ║
║  Type:    [monorepo / single / microservices]         ║
║  Stack:   [languages + frameworks]                    ║
║  DB:      [database type]                             ║
║  Apps:    [number] applications detected               ║
║  Tables:  [number] database tables                     ║
║  Routes:  [number] API endpoints                       ║
║  Tests:   [number] test files                          ║
║  Deps:    [number] dependencies                        ║
║                                                        ║
║  📁 Documentation: .agent/context/                     ║
║  📄 Start reading: .agent/context/CONTEXT_INDEX.md     ║
╚══════════════════════════════════════════════════════╝
```

---

## Post-Init Rules

After context init is complete, the AI agent MUST:

1. **Always read `CONTEXT_INDEX.md` first** before any new task
2. **Check `ARCHITECTURE.md`** before creating new files/folders — follow existing patterns
3. **Check `DATABASE_SCHEMA.md`** before any database changes — maintain consistency
4. **Check `API_REFERENCE.md`** before adding new endpoints — follow existing conventions
5. **Check `DEPENDENCIES.md`** before adding new packages — avoid duplicates
6. **Check `BUSINESS_DOMAINS.md`** before implementing features — understand business rules
7. **Update documentation** if structural changes are made during development
8. **Follow all rules** in `.agent/rules/` — they are non-negotiable

## Re-Init Triggers

Re-run this workflow when:
- Major framework upgrade
- New service/application added
- Significant database schema changes
- New team member onboarding
- Monthly maintenance review
