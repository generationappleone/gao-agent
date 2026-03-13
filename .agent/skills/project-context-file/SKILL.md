---
name: project-context-file
description: "Use when creating or updating project context files (CLAUDE.md, AGENTS.md, .cursorrules). Teaches how to create comprehensive project context for AI assistants."
---

# Project Context File — CLAUDE.md / AGENTS.md Pattern

## Overview

A project context file is a 300+ line document that gives AI assistants deep understanding of a project. It covers build commands, architecture, core concepts, testing, release process, and code standards.

**Announce:** "Using project-context-file skill to create project context."

## When to Use

- Setting up a new project for AI assistant development
- Running `/context-init` to bootstrap project documentation
- When AI assistants consistently misunderstand project patterns
- After significant architectural changes

## File Naming Convention

| AI Tool | File Name | Location |
|---------|-----------|----------|
| Claude | `CLAUDE.md` | Project root |
| Cursor | `.cursorrules` | Project root |
| GitHub Copilot | `.github/copilot-instructions.md` | `.github/` |
| Generic | `AGENTS.md` | Project root |
| GAO-Agent | `.agent/context/CONTEXT_INDEX.md` | `.agent/context/` |

## Template Structure

### Section 1: Project Identity

```markdown
# [Project Name]

## Overview
[One paragraph: what this project does, who it's for, primary technology stack]

## Quick Start
```bash
# Install
[exact install command]

# Run development
[exact dev command]

# Run tests
[exact test command]

# Build
[exact build command]

# Lint
[exact lint command]
```
```

### Section 2: Architecture

```markdown
## Architecture

### Stack
- **Runtime:** [Node.js 22 / PHP 8.3 / Python 3.12 / etc.]
- **Framework:** [Next.js 15 / Laravel 12 / Django 5 / etc.]
- **Database:** [PostgreSQL 16 / MySQL 8 / MongoDB 7 / etc.]
- **ORM:** [Prisma / Eloquent / SQLAlchemy / etc.]
- **Testing:** [Vitest / PHPUnit / pytest / etc.]

### Directory Structure
```
src/
├── app/           ← [What goes here]
├── components/    ← [What goes here]
├── lib/           ← [What goes here]
├── services/      ← [What goes here]
└── types/         ← [What goes here]
```

### Key Patterns
- [Pattern 1: e.g., "All API routes use server actions"]
- [Pattern 2: e.g., "Services are injected via DI container"]
- [Pattern 3: e.g., "Database queries use repository pattern"]
```

### Section 3: Core Concepts

```markdown
## Core Concepts

### [Concept 1: e.g., Authentication]
[How auth works in this project — tokens, sessions, middleware]

### [Concept 2: e.g., Multi-tenancy]
[How tenancy is handled — DB per tenant, row-level, schema-level]

### [Concept 3: e.g., Event System]
[How events flow — publishers, subscribers, queues]
```

### Section 4: Code Standards

```markdown
## Code Standards

### Naming Conventions
- **Files:** [kebab-case / PascalCase / snake_case]
- **Functions:** [camelCase / snake_case]
- **Components:** [PascalCase]
- **Database tables:** [plural snake_case]
- **Database columns:** [snake_case]

### Import Order
1. [Framework imports]
2. [Third-party imports]
3. [Internal imports]
4. [Type imports]

### Commit Convention
[Conventional commits: feat(scope): description]
```

### Section 5: Testing Strategy

```markdown
## Testing

### Test Structure
- **Unit tests:** [location, naming pattern]
- **Integration tests:** [location, naming pattern]
- **E2E tests:** [location, naming pattern]

### Running Tests
```bash
# All tests
[command]

# Specific test file
[command]

# Watch mode
[command]

# Coverage
[command]
```

### Test Patterns
- [Pattern: e.g., "Use factory functions for test data"]
- [Pattern: e.g., "Mock external services, not internal"]
- [Pattern: e.g., "Each test gets its own database transaction"]
```

### Section 6: Release Process

```markdown
## Release Process

1. [Step 1: e.g., Create release branch]
2. [Step 2: e.g., Run full test suite]
3. [Step 3: e.g., Update CHANGELOG.md]
4. [Step 4: e.g., Tag version]
5. [Step 5: e.g., Deploy to staging]
6. [Step 6: e.g., Deploy to production]
```

## Project Type Templates

### Monorepo Template

Additional sections for monorepos:

```markdown
## Packages
| Package | Purpose | Path |
|---------|---------|------|
| `@org/core` | Core library | `packages/core` |
| `@org/web` | Web application | `apps/web` |

## Cross-Package Development
- Run `pnpm install` from root
- Changes in `packages/` auto-rebuild via Turborepo
- Version with `pnpm changeset`
```

### Monolith Template

Additional sections for monoliths:

```markdown
## Modules
| Module | Responsibility |
|--------|---------------|
| `auth` | Authentication & authorization |
| `billing` | Payment processing |

## Database Migrations
```bash
[migration commands]
```
```

### Microservice Template

Additional sections for microservices:

```markdown
## Services
| Service | Port | Repository |
|---------|------|-----------|
| API Gateway | 3000 | [repo] |
| Auth Service | 3001 | [repo] |

## Inter-Service Communication
- [Protocol: gRPC / REST / Message Queue]
- [Discovery: Consul / Kubernetes DNS]
```

## Integration

**This skill is used by:**
- `/context-init` workflow — Project bootstrap
- `/context-docs` workflow — Documentation generation

**This skill pairs with:**
- `skills/git/SKILL.md` — Repository setup
- `skills/architecture-enforcement/SKILL.md` — Architecture documentation
