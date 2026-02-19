---
description: Generate user-facing project documentation — README, CHANGELOG, API docs, contributing guide. Different from /context-init which generates agent-internal context docs.
---

# Context Docs Workflow

This workflow generates **user-facing documentation** for the project. It is different from `/context-init` which generates internal agent context files.

> **`/context-init`** = docs for the AI agent. **`/context-docs`** = docs for humans (developers, users, contributors).

## Steps

1. **Read project context** — Load `.agent/context/` files for project information.
   // turbo

2. **Determine scope** — Ask the user:
   ```markdown
   📚 Documentation Generation

   What documentation do you need?
   1. 📖 README.md (project overview, setup, usage)
   2. 📝 CHANGELOG.md (version history from git)
   3. 🤝 CONTRIBUTING.md (contribution guidelines)
   4. 📡 API Documentation (OpenAPI / Swagger)
   5. 🏗️ Architecture Decision Records (ADR)
   6. 📦 All of the above
   ```

3. **For README.md** — Generate a comprehensive README:
   // turbo
   - Project title, badges, and description
   - Features list with descriptions
   - Tech stack overview
   - Prerequisites and installation
   - Configuration (environment variables)
   - Running locally (dev server)
   - Running tests
   - Project structure overview
   - Deployment instructions
   - Contributing link
   - License

4. **For CHANGELOG.md** — Generate from git history:
   // turbo
   ```bash
   git log --oneline --no-merges -50
   ```
   Follow [Keep a Changelog](https://keepachangelog.com/) format:
   - Group by version/date
   - Categories: Added, Changed, Deprecated, Removed, Fixed, Security

5. **For CONTRIBUTING.md** — Generate contribution guide:
   - Development setup
   - Branch naming conventions
   - Commit message format (Conventional Commits)
   - Pull request process
   - Code style guidelines
   - Testing requirements

6. **For API Documentation** — Generate OpenAPI/Swagger:
   // turbo
   - Read all routes from codebase
   - Document endpoints, methods, auth requirements
   - Include request/response schemas
   - Add example payloads
   - Generate in OpenAPI 3.0 format if applicable

7. **For ADR** — Create Architecture Decision Records:
   - Template in `docs/adr/` directory
   - Record key architectural decisions with context, alternatives, and consequences

8. **Present documentation** — Show generated docs for review.

9. **Save files** — After approval, save to project root or `docs/` directory.

## When to Use
- New project needs documentation
- Existing project with outdated/missing docs
- Before open-sourcing a project
- Onboarding new team members
- Before deployment/release

## When to Skip
- Documentation is already comprehensive and up-to-date
- Throwaway prototypes or experiments
