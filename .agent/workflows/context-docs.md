---
description: Generate user-facing project documentation — README, CHANGELOG, API docs, contributing guide, and ADR. Different from /context-init which generates agent-internal context docs.
---

# Context Docs — User-Facing Documentation

## Purpose
This workflow generates **user-facing documentation** for the project. It creates professional-grade docs for developers, contributors, and users.

> **`/context-init`** = docs for the AI agent. **`/context-docs`** = docs for humans (developers, users, contributors).

---

## Activation
The user triggers this workflow by:
- Using `/context-docs` to see documentation options
- Using `/context-docs readme` to generate/update README
- Using `/context-docs changelog` to generate CHANGELOG
- Using `/context-docs api` to generate API documentation
- Using `/context-docs internal` to update internal agent context docs (`.agent/context/`)
- Using `/context-docs all` to generate everything

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 1: Context Analysis

### Step 1.1 — Read Project Context
// turbo
```
1. .agent/context/PROJECT_OVERVIEW.md   ← Project description
2. .agent/context/ARCHITECTURE.md       ← Technical architecture
3. .agent/context/API_REFERENCE.md      ← Endpoints
4. .agent/context/DEPENDENCIES.md       ← Tech stack
5. .agent/context/DEVELOPMENT_GUIDE.md  ← Dev setup
6. .agent/rules/deep-thinking.md        ← Quality standards (MANDATORY)
```

### Step 1.1b — Read Documentation Skills
// turbo
Read relevant skills for documentation quality:
- `skills/markdown/SKILL.md` — Markdown formatting best practices (CommonMark, GFM)
- `skills/rest-api/SKILL.md` — If generating API documentation (OpenAPI spec patterns)
- `skills/seo/SKILL.md` — If documentation involves web content

### Step 1.2 — Check Existing Documentation
// turbo
```bash
# Find existing docs
find . -maxdepth 2 \( -name "README.md" -o -name "CHANGELOG.md" -o -name "CONTRIBUTING.md" -o -name "LICENSE" -o -name "*.md" \) -not -path '*/.agent/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -20

# Check for API spec files
find . -maxdepth 3 \( -name "openapi.yaml" -o -name "openapi.json" -o -name "swagger.yaml" -o -name "swagger.json" \) -not -path '*/node_modules/*' | head -5

# Check docs directory
ls docs/ 2>/dev/null
ls docs/adr/ 2>/dev/null
```

### Step 1.3 — Determine Scope

```markdown
📚 Documentation Generation

What documentation do you need?
1. 📖 **README.md** — Project overview, setup, usage
2. 📝 **CHANGELOG.md** — Version history from git (Keep a Changelog)
3. 🤝 **CONTRIBUTING.md** — Contribution guidelines
4. 📡 **API Documentation** — OpenAPI / Swagger spec
5. 🏗️ **Architecture Decision Records (ADR)** — Design decisions
6. 🧠 **Internal Context Docs** — Refresh `.agent/context/` based on codebase changes
7. 📦 **All of the above**
8. 🔄 **Update existing** — Refresh outdated docs

Existing docs detected: [list found files]
```

---

## Phase 2: README.md Generation

### Step 2.1 — README Structure

Generate a comprehensive README following best practices:

```markdown
# [Project Name]

[![Build Status](badge)](#) [![License](badge)](#) [![Version](badge)](#)

> [One-line project description]

[2-3 paragraph description explaining what the project does, why it exists,
and what problems it solves]

## ✨ Features

- **[Feature 1]** — [description]
- **[Feature 2]** — [description]
- **[Feature 3]** — [description]

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | [React, Vue, etc.] |
| Backend | [Node.js, Laravel, etc.] |
| Database | [PostgreSQL, MySQL, etc.] |
| Cache | [Redis, etc.] |

## 📋 Prerequisites

- [Language] [version]+ (recommended: [version])
- [Package Manager] [version]+
- [Database] [version]+
- [Other requirements]

## 🚀 Getting Started

### 1. Clone the repository
\```bash
git clone [repo-url]
cd [project-name]
\```

### 2. Install dependencies
\```bash
[install command]
\```

### 3. Configure environment
\```bash
cp .env.example .env
# Edit .env and fill in required values
\```

### 4. Set up database
\```bash
[migration command]
[seed command — optional]
\```

### 5. Start development server
\```bash
[dev server command]
\```

Visit `http://localhost:[port]` to see the application.

## 📁 Project Structure

\```
[project tree showing key directories and files]
\```

## 🧪 Testing

\```bash
# Run all tests
[test command]

# Run with coverage
[coverage command]

# Run specific test
[specific test command]
\```

## 📦 Deployment

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) or:

\```bash
[build command]
[deploy command]
\```

## 📡 API Overview

[Brief API summary — full docs at /api-docs or link to API docs]

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/login | Authenticate user |
| GET | /api/users/me | Get current user |
[...]

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development process
and contribution guidelines.

## 📝 License

[License type] — See [LICENSE](LICENSE) for details.

## 📞 Support

[How to get help — issues, discussions, email, etc.]
```

### Step 2.2 — Validate README

Check the generated README for:
- [ ] Accurate installation steps (do they actually work?)
- [ ] Correct commands for the detected framework
- [ ] Environment variables documented
- [ ] Links are valid
- [ ] No placeholder text remaining

---

## Phase 3: CHANGELOG.md Generation

### Step 3.1 — Parse Git History
// turbo
```bash
# Get all tags
git tag -l --sort=-v:refname | head -10

# Get commits since last tag
git log $(git describe --tags --abbrev=0 2>/dev/null)..HEAD --format="%s" --no-merges 2>&1 | head -50

# Get all commits grouped by tag
git log --oneline --no-merges --date=short --format="%ad %s" 2>&1 | head -100
```

### Step 3.2 — Generate CHANGELOG

Follow [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- [from feat: commits]

### Changed
- [from refactor:, perf:, chore: commits]

### Fixed
- [from fix: commits]

### Security
- [from security-related commits]

## [X.Y.Z] — YYYY-MM-DD
### Added
- [features from this release]

### Changed
- [changes]

### Fixed
- [bug fixes]
```

---

## Phase 4: CONTRIBUTING.md Generation

### Step 4.1 — Generate Contribution Guide

```markdown
# Contributing to [Project Name]

Thank you for your interest in contributing! This document provides
guidelines and information for contributors.

## Development Setup

[Same as README getting started, but more detailed]

## Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run tests: `[test command]`
5. Run linting: `[lint command]`
6. Commit with Conventional Commits: `git commit -m "feat(scope): description"`
7. Push to your fork: `git push origin feature/my-feature`
8. Open a Pull Request

## Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

\```
type(scope): description

Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
\```

## Code Style

[Project-specific style guidelines — auto-detected from linter config]

## Testing

- All new features must include tests
- All bug fixes must include a regression test
- Minimum [X]% coverage for new code

## Pull Request Process

1. PR title follows Conventional Commits format
2. Description explains WHAT and WHY
3. All CI checks pass
4. At least one approval from maintainers
5. No merge conflicts
```

---

## Phase 5: API Documentation

### Step 5.1 — Extract API Information
// turbo
```bash
# Find all route definitions
grep -rn "router\.\|app\.\(get\|post\|put\|patch\|delete\)\|Route::" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -50

# Check for existing OpenAPI/Swagger
find . -maxdepth 3 \( -name "openapi.*" -o -name "swagger.*" \) -not -path '*/node_modules/*' | head -5
```

### Step 5.2 — Generate API Documentation

Create OpenAPI 3.0 spec or markdown API docs:

```yaml
openapi: 3.0.3
info:
  title: [Project Name] API
  version: [version]
  description: [API description]
servers:
  - url: http://localhost:[port]/api
    description: Development
paths:
  /auth/login:
    post:
      summary: Authenticate user
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                email: { type: string, format: email }
                password: { type: string, format: password }
      responses:
        200: { description: Login successful }
        401: { description: Invalid credentials }
```

---

## Phase 6: Architecture Decision Records (ADR)

### Step 6.1 — Create ADR Template

Create `docs/adr/template.md`:
```markdown
# ADR-[number]: [Title]

**Date:** [YYYY-MM-DD]
**Status:** [Proposed | Accepted | Deprecated | Superseded]

## Context
[What is the issue/decision we need to make?]

## Decision
[What was decided and why?]

## Alternatives Considered
| Alternative | Pros | Cons | Why Not |
|-------------|------|------|---------|
| [Alt A] | [pros] | [cons] | [reason] |
| [Alt B] | [pros] | [cons] | [reason] |

## Consequences
### Positive
- [benefit 1]

### Negative
- [tradeoff 1]

### Neutral
- [observation 1]
```

---

## Phase 7: Internal Context Docs Update

This phase applies only if the user requested `/context-docs internal` or included internal docs in the scope.

### Step 7.1 — Identify Outdated Context
1. Review the existing `.agent/context/` documentation.
2. Cross-reference the documentation with the latest codebase changes.
3. Determine which context files (e.g., `DATABASE_SCHEMA.md`, `API_REFERENCE.md`, `ARCHITECTURE.md`) have become outdated.

### Step 7.2 — Update Specific Context Files
For each file that requires an update:
1. Gather the required new information using codebase search tools (e.g., find new endpoints, new database models, new dependencies).
2. Use the code editing tools to update the specific `.agent/context/` file, keeping the format intact.
3. After updates, report the changes specifically in the documentation output.

---

## Phase 8: Freshness Check & Validation

### Step 8.1 — Validate Generated Docs
// turbo

For each generated document:
- [ ] All commands are correct for the detected framework
- [ ] Environment variable names match `.env.example`
- [ ] File paths reference actual files
- [ ] version numbers are current
- [ ] No placeholder text remains (e.g., `[TODO]`, `[description]`)

### Step 8.2 — Check Doc Freshness

If updating existing docs:
```bash
# When was each doc last modified?
git log -1 --format="%ai %s" -- README.md 2>&1
git log -1 --format="%ai %s" -- CHANGELOG.md 2>&1
git log -1 --format="%ai %s" -- CONTRIBUTING.md 2>&1

# What changed since docs were last updated?
git diff $(git log -1 --format="%H" -- README.md)..HEAD --stat 2>&1 | head -20
```

Report outdated sections and recommend updates.

---

## Phase 9: Save & Report

### Step 9.1 — Present for Review

Show all generated documentation for user approval before saving.

### Step 9.2 — Save Files

After approval, save to appropriate locations:
- `README.md` — project root
- `CHANGELOG.md` — project root
- `CONTRIBUTING.md` — project root
- `docs/api/openapi.yaml` — API spec
- `docs/adr/` — ADR documents
- `.agent/context/` — Updated internal context docs

### Step 9.3 — Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 DOCUMENTATION GENERATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Created:   [list of new files]
Updated:   [list of updated files]
Validated: ✅ All commands correct
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next: /context-git to commit documentation changes
```

---

## When to Use
- New project needs documentation
- Existing project with outdated/missing docs
- Before open-sourcing a project
- Onboarding new team members
- Before deployment/release
- After significant feature additions

## When to Skip
- Documentation is already comprehensive and up-to-date
- Throwaway prototypes or experiments
- Internal tooling that doesn't need formal docs
