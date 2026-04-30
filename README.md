<div align="center">

# 🧠 GAO Agent

### **Generative AI Operations — Intelligent Coding Agent Framework**

*Enterprise-grade AI coding agent with 365 skills, 19 enforced rules, 19 automated workflows, self-learning memory, and full-stack development capabilities across 10+ languages and 30+ frameworks.*

[![Skills](https://img.shields.io/badge/Skills-365-blue?style=for-the-badge&logo=bookstack&logoColor=white)](#-skills-library-365)
[![Rules](https://img.shields.io/badge/Rules-19-red?style=for-the-badge&logo=shield&logoColor=white)](#-mandatory-rules-19)
[![Workflows](https://img.shields.io/badge/Workflows-19-green?style=for-the-badge&logo=githubactions&logoColor=white)](#-workflows-19)
[![Memory](https://img.shields.io/badge/Memory-Self--Learning-purple?style=for-the-badge&logo=brain&logoColor=white)](#-memory-system)
[![License](https://img.shields.io/badge/License-Proprietary-orange?style=for-the-badge&logo=lock&logoColor=white)](#-license)

---

*GAO Agent transforms any AI coding assistant into a production-grade software engineer — enforcing security, quality, and consistency through structured skills, non-negotiable rules, and automated workflows. It learns from every interaction, remembers every mistake, and never repeats the same error twice.*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Differentiators](#-key-differentiators)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
  - [Context7 MCP Setup](#step-5-configure-context7-mcp-recommended)
- [Mandatory Rules (19)](#-mandatory-rules-19)
- [Workflows (19)](#-workflows-19)
- [Skills Library (365)](#-skills-library-365)
- [Memory System](#-memory-system)
- [How It Works](#-how-it-works)
- [Decision Matrix](#-decision-matrix)
- [Contributing](#-contributing)
- [Statistics](#-statistics)
- [License](#-license)

---

## 🌟 Overview

**GAO Agent** (Generative AI Operations) is a comprehensive, enterprise-grade AI coding agent framework. It is **NOT** a run-of-the-mill AI assistant — it is a **structured operating system** for AI-powered software development that ensures every line of code is secure, tested, documented, and production-ready.

### What Makes GAO Agent Different?

| Traditional AI Assistant | GAO Agent |
|--------------------------|-----------|
| Generates code on demand | Generates code **with enforced security, architecture, and quality rules** |
| No memory between sessions | **Self-learning memory** — learns from corrections and never repeats mistakes |
| Generic responses | **Context-aware** — reads your entire codebase before writing a single line |
| Inconsistent patterns | **19 mandatory rules** ensure consistent output across ALL tasks |
| Limited framework knowledge | **365 deep technical skills** covering 30+ frameworks in production detail |
| Manual workflows | **18 automated workflows** from planning to deployment |
| No compliance awareness | **Built-in compliance**: ISO 27001, NIST CSF, CIS Controls, UU PDP/GDPR |

---

## 🏆 Key Differentiators

### 1. 🧠 Self-Learning Memory & Auto-Handoff
GAO Agent **remembers and learns** from every interaction:
- **Error Memory** — Every mistake is logged with root cause, correct approach, and prevention rule. The agent **never makes the same mistake twice.**
- **Learned Knowledge** — User preferences, corrections, coding style, and project conventions are recorded and applied proactively in ALL future tasks.
- **Auto-Recovery Protocol** — Seamlessly switch AI models mid-task without context amnesia. The agent tracks state in `ACTIVE_TASK.md` and picks up exactly where the last model left off.

### 2. 🔒 Security-First by Design
Security is not an afterthought — it's enforced at every layer:
- 4-layer security model (Code → Dependencies → Containers → Infrastructure)
- OWASP Top 10 protection in every API endpoint
- AES-256-GCM encryption for sensitive data
- Field-level encryption for PII compliance
- Post-quantum cryptography readiness (ML-KEM/Kyber)

### 3. 🏗️ Architecture Enforcement
The agent doesn't just write code — it **enforces architectural patterns**:
- SOLID principles are non-negotiable
- Feature-based folder structure for frontends
- Service-Repository pattern for backends
- Proper normalization and indexing for databases
- No `any` in TypeScript, no `var` in JavaScript

### 4. 📊 Full Development Lifecycle
From idea to production in a single pipeline:
```
/context-plan → /context-work → /context-build → /context-test → /context-review → /context-deploy
```

### 5. 🌏 Indonesia-Ready Compliance
Built with Indonesian digital ecosystem in mind:
- **UU PDP** (Undang-Undang Pelindungan Data Pribadi) — full compliance
- **Payment Gateways**: Midtrans, Xendit, DOKU
- **SNAP BI** compliance for banking integrations
- **QRIS** payment support

---

## 🏗 Architecture

```
.agent/
│
├── AGENTS.md                        # Master configuration — rules registry, skill index, conventions
│
├── rules/                           # 19 mandatory coding & quality rules
│   ├── deep-thinking.md                # Deep analysis, anti-hallucination, quality checklist (HIGHEST)
│   ├── error-memory.md                 # Mistake logging & learning — never repeat errors
│   ├── self-learning.md                # Adaptive learning from user preferences & corrections
│   ├── solid-principles.md             # SOLID design principles enforcement
│   ├── developer-security.md           # 4-layer security model
│   ├── database-design.md              # UUID, audit columns, soft delete, normalization
│   ├── dependency-management.md        # Vetting, pinning, auditing, license checks
│   ├── iso-27000-compliance.md         # ISO 27001 data classification & encryption
│   ├── ui-ux-design.md                 # Design tokens, dark mode, accessibility
│   ├── production-code-standards.md    # Zero hallucinations, type safety, verification
│   ├── frontend-architecture.md        # Feature-based folders, thin components, 4 UI states
│   ├── uu-pdp-compliance.md            # Indonesia data privacy law (GDPR equivalent)
│   ├── dark-light-mode.md              # Dark/light mode theming standards
│   ├── architecture-enforcement.md     # Architecture pattern validation
│   ├── adaptive-tdd.md                 # Test-driven development rules
│   ├── continuous-execution.md         # Auto-proceed between workflow stages
│   ├── verification-gate.md            # Mandatory verification before completion claims
│   ├── memory-pruning.md               # Rules for pruning ERROR_LOG and LEARNED_KNOWLEDGE
│   └── unicode-encoding.md             # Unicode & Encoding Standards (UTF-8)
│
├── workflows/                       # 18 automated development workflows
│   ├── context-init.md                 # Full project analysis & documentation generation
│   ├── context-plan.md                 # Implementation planning with brainstorming
│   ├── context-work.md                 # Task execution engine from approved plans
│   ├── context-build.md                # Framework-aware build engine (11 frameworks)
│   ├── context-test.md                 # Comprehensive testing (unit, E2E, security, a11y)
│   ├── context-review.md               # Multi-perspective code review + security audit
│   ├── context-deploy.md               # Deployment orchestration (Docker, Cloud, K8s, VPS)
│   ├── context-debug.md                # Systematic debugging + knowledge capture
│   ├── context-ask.md                  # Intelligent Q&A with code analysis & web research
│   ├── context-docs.md                 # Documentation generation (README, API, CHANGELOG)
│   ├── context-git.md                  # Git operations (branching, commits, PRs, releases)
│   ├── context-migrate.md              # Database migration management
│   ├── context-refactor.md             # Safe code refactoring with metrics
│   ├── context-upgrade.md              # Dependency audit & safe upgrade
│   ├── context-ui-ux.md                # Professional UI/UX generation
│   ├── context-launch.md               # Full pipeline: plan → work → build → test → review
│   ├── context-reload.md               # Hot-reload agent configuration mid-conversation
│   └── context-help.md                 # List all available commands, rules, and skills
│
├── skills/                          # 360 technical skill directories
│   ├── laravel/SKILL.md                # Laravel PHP framework
│   ├── reactjs/SKILL.md                # React.js frontend
│   ├── nextjs/SKILL.md                 # Next.js full-stack
│   ├── aes-256/SKILL.md                # AES-256 encryption
│   ├── midtrans/SKILL.md               # Midtrans payment gateway (Indonesia)
│   ├── xendit/SKILL.md                 # Xendit payment gateway (Indonesia)
│   ├── doku/SKILL.md                   # DOKU payment gateway (Indonesia)
│   ├── post-quantum-crypto/SKILL.md    # Post-quantum cryptography (ML-KEM)
│   ├── kubernetes/SKILL.md             # Container orchestration
│   ├── mcp-*/SKILL.md                  # 65+ MCP server integrations
│   └── ... (350+ more skill directories)
│
├── memory/                          # Persistent learning & error memory
│   ├── ERROR_LOG.md                    # Every mistake logged with root cause & prevention rule
│   └── LEARNED_KNOWLEDGE.md            # User preferences, corrections, patterns learned
│
└── context/                         # Auto-generated project documentation
    ├── CONTEXT_INDEX.md                # Master index of all documentation
    ├── ARCHITECTURE.md                 # System architecture & patterns
    ├── DATABASE_SCHEMA.md              # Complete database documentation
    ├── API_REFERENCE.md                # All API endpoints & contracts
    ├── DEPENDENCIES.md                 # Package inventory & versions
    ├── DEVELOPMENT_GUIDE.md            # Setup & configuration instructions
    ├── BUSINESS_DOMAINS.md             # Domain model documentation
    └── PROJECT_OVERVIEW.md             # Project summary & tech stack
```

---

## 🚀 Getting Started

### Prerequisites

- AI coding assistant that supports agent mode (Gemini, Claude, GPT, or compatible)
- Project workspace with source code
- Node.js / Python / PHP / Java / Go / .NET / Flutter SDK (based on your stack)

### Installation

#### Step 1: Clone the Agent Framework

```bash
# Clone the repository
git clone https://github.com/generationappleone/gao-agent.git

# Copy the .agent directory into your project
cp -r gao-agent/.agent /path/to/your-project/.agent
```

##### Step 1a (Claude Code only): Copy the Claude adapter

Claude Code reads `CLAUDE.md` at project root and slash commands from `.claude/commands/`, not `.agent/AGENTS.md` and `.agent/workflows/`. The repo ships a thin adapter layer that bridges Claude Code to the same `.agent/` source of truth — no duplication, single set of files to maintain.

```bash
# Copy the bridge files alongside .agent/
cp gao-agent/CLAUDE.md /path/to/your-project/CLAUDE.md
cp -r gao-agent/.claude /path/to/your-project/.claude
```

After this step Claude Code recognizes all 19 `/context-*` slash commands. Each command in `.claude/commands/` is a wrapper that delegates to the matching `.agent/workflows/context-*.md` file. The cross-platform translation layer (e.g. `// turbo` → auto-proceed, Antigravity tool names → Claude tools, skill access via `.agent/skills/<name>/SKILL.md` paths) is documented in `CLAUDE.md`.

> **Antigravity / Cursor / Windsurf / Gemini CLI users:** Skip Step 1a. Those clients read `.agent/AGENTS.md` and `.agent/workflows/` natively.

#### Step 2: Initialize Project Context

```
/context-init
```

This command scans your **entire codebase** and generates comprehensive documentation:
- Architecture patterns, naming conventions, tech stack detection
- Database schema analysis with relationship mapping
- API endpoint inventory with request/response shapes
- Dependency audit with version and license information
- Business domain extraction

#### Step 3: Start Building

```bash
# Plan a feature
/context-plan Add user authentication with JWT and OAuth2

# Execute the plan
/context-work

# Build the project
/context-build

# Run comprehensive tests
/context-test

# Deploy to production
/context-deploy
```

#### Step 4: Full Autonomous Pipeline (Optional)

For the complete end-to-end development lifecycle:

```
/context-launch Add payment gateway integration with Midtrans
```

This automatically runs: **Plan → Work → Build → Test → Review → Deploy**

#### Step 5: Configure Context7 MCP (Recommended)

GAO Agent ships with **Context7 MCP** — a real-time documentation engine that fetches up-to-date, version-specific library docs directly into AI context, eliminating hallucination and outdated API usage.

##### Quick Start (Works Out-of-the-Box)

Context7 uses **Local Mode by default** — no API key, no sign-up, just copy and go:

**Google Antigravity** (`.mcp.json` already included at project root):
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

**Other IDEs** — copy the matching template from `.agent/mcp-configs/templates/`:

| AI Client | Template File | Where to Copy |
|-----------|---------------|---------------|
| **Google Antigravity** ⭐ | `antigravity.mcp.json` | `.mcp.json` (project root) |
| **Cursor** | `cursor.mcp.json` | `~/.cursor/mcp.json` or `.cursor/mcp.json` |
| **VS Code** | `vscode.mcp.json` | `.vscode/mcp.json` |
| **Claude Code** | `claude-code.md` | Via CLI: `claude mcp add` |
| **Claude Desktop** | `claude-desktop.mcp.json` | `claude_desktop_config.json` |
| **Windsurf** | `windsurf.mcp.json` | Customizations > MCP config |
| **Gemini CLI** | `gemini-cli.json` | `~/.gemini/settings.json` |
| **GitHub Copilot** | `copilot.mcp.json` | `.vscode/mcp.json` |
| **JetBrains** | `jetbrains.mcp.json` | MCP settings panel |
| **Visual Studio 2022** | `visual-studio.mcp.json` | `.mcp.json` (project root) |
| **+ 14 more** | See [`.agent/mcp-configs/README.md`](.agent/mcp-configs/README.md) | Various |

> **All templates use Local Mode by default — no API key required!**
> For higher rate limits, add `"--api-key", "YOUR_KEY"` to the `args` array.
> Get a free key at [context7.com/dashboard](https://context7.com/dashboard).

##### Using Context7 in Prompts

Once configured, add `use context7` to any prompt to fetch real-time docs:

```
Create a Next.js 15 app with server actions. use context7
Implement Prisma schema with relations. use context7
How do I set up Laravel middleware? use context7
```

Or set an **auto-invoke rule** in your AI client so you never need to type it:
```
Always use Context7 MCP when I need library/API documentation,
code generation, setup or configuration steps.
```

##### Context7 REST API (For Scripts & CI/CD)

For programmatic access, Context7 also provides a REST API (requires API key):

```bash
# Search for a library
curl -X GET "https://context7.com/api/v2/libs/search?libraryName=next.js&query=setup+ssr" \
  -H "Authorization: Bearer CONTEXT7_API_KEY"

# Fetch documentation
curl -X GET "https://context7.com/api/v2/context?libraryId=/vercel/next.js&query=middleware&type=json" \
  -H "Authorization: Bearer CONTEXT7_API_KEY"
```

> See full REST API documentation in [`.agent/skills/mcp-context7/SKILL.md`](.agent/skills/mcp-context7/SKILL.md).

##### Auto-Setup via Workflow

Run the auto-setup workflow to detect your IDE and generate the config automatically:

```
/context-mcp-check --setup
```

---

## 🔒 Mandatory Rules (19)

Every action performed by GAO Agent must comply with these rules. **They are non-negotiable and enforced automatically.**

### Tier 1: Intelligence & Learning Rules (HIGHEST PRIORITY)

| # | Rule | File | Purpose |
|---|------|------|---------|
| 1 | **Deep Thinking** | `deep-thinking.md` | 12-point checklist before writing any code: understand requirements, check edge cases, verify security, validate assumptions, check past mistakes |
| 2 | **Error Memory** | `error-memory.md` | Every mistake is logged with root cause, correct approach, and prevention rule. Agent reads error log before every task |
| 3 | **Self Learning** | `self-learning.md` | Learns from user corrections, preferences, and patterns. Stored in persistent knowledge base and applied proactively |

### Tier 2: Code Quality Rules

| # | Rule | File | Purpose |
|---|------|------|---------|
| 4 | **SOLID Principles** | `solid-principles.md` | SRP (max 50 lines/function), OCP (extend via interfaces), LSP, ISP, DIP enforcement |
| 5 | **Production Code** | `production-code-standards.md` | Zero hallucinations, type safety, full context awareness, surgical edits only |
| 6 | **Frontend Architecture** | `frontend-architecture.md` | Feature-based folders, thin components, 4 UI states (loading/error/empty/success), LCP < 2.5s |
| 7 | **Architecture Enforcement** | `architecture-enforcement.md` | Validates correct folder placement, dependency direction, framework conventions |
| 8 | **Adaptive TDD** | `adaptive-tdd.md` | Test-driven development rules adapted to project context |
| 9 | **Verification Gate** | `verification-gate.md` | Mandatory verification commands before claiming any work is complete |

### Tier 3: Security & Compliance Rules

| # | Rule | File | Purpose |
|---|------|------|---------|
| 10 | **Developer Security** | `developer-security.md` | 4-layer security: Secure Code → Dependencies → Containers → Infrastructure |
| 11 | **ISO 27000** | `iso-27000-compliance.md` | Data classification (Public/Internal/Confidential/Restricted), AES-256-GCM, audit logging |
| 12 | **UU PDP Compliance** | `uu-pdp-compliance.md` | Indonesia data privacy: consent management, field-level encryption, breach notification 3×24h |

### Tier 4: Design & Convention Rules

| # | Rule | File | Purpose |
|---|------|------|---------|
| 13 | **Database Design** | `database-design.md` | UUID PKs, audit columns, soft delete, normalization (3NF+), proper indexing |
| 14 | **Dependency Mgmt** | `dependency-management.md` | Research before install, check popularity/security/license, pin versions |
| 15 | **UI/UX Design** | `ui-ux-design.md` | Design tokens, micro-interactions, WCAG 2.1 AA, mobile-first responsive |
| 16 | **Dark/Light Mode** | `dark-light-mode.md` | CSS variables, system preference detection, FOUC prevention, semantic colors |

### Tier 5: Process Rules

| # | Rule | File | Purpose |
|---|------|------|---------|
| 17 | **Continuous Execution** | `continuous-execution.md` | Auto-proceed between workflow stages, no unnecessary pauses |
| 18 | **Memory Pruning** | `memory-pruning.md` | Archiving logs and removing stale entries |
| 19 | **Unicode & Encoding** | `unicode-encoding.md` | Prevention of unicode corruption across IDEs |

### Deep Thinking Checklist (Applied Before EVERY Action)

```
┌─────────────────────────────────────────────────────────────┐
│                    DEEP THINKING CHECKLIST                   │
├─────────────────────────────────────────────────────────────┤
│  1. ☐ Have I checked ERROR_LOG.md for past mistakes?        │
│  2. ☐ Have I checked LEARNED_KNOWLEDGE.md for user prefs?   │
│  3. ☐ Do I FULLY understand what is being asked?            │
│  4. ☐ Have I read ALL relevant context and existing code?   │
│  5. ☐ What are the EDGE CASES I must handle?                │
│  6. ☐ What can go WRONG? (failure modes, race conditions)   │
│  7. ☐ Is this SECURE? (injection, auth bypass, data leak)   │
│  8. ☐ Is the data model CORRECT and NORMALIZED?             │
│  9. ☐ Does this follow existing PATTERNS in the codebase?   │
│ 10. ☐ Will this SCALE? (N+1 queries, memory, concurrency)  │
│ 11. ☐ Am I making ASSUMPTIONS? → If yes, ASK the user.     │
│ 12. ☐ Is there a SIMPLER, more ELEGANT solution?            │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Workflows (18)

### Development Lifecycle Workflows

| # | Command | Name | Purpose |
|---|---------|------|---------|
| 1 | `/context-init` | **Project Init** | Full codebase analysis → generates 8 documentation files in `.agent/context/` |
| 2 | `/context-plan` | **Planning** | Brainstorming + implementation plan with priorities, diagrams, database schema review |
| 3 | `/context-work` | **Execution** | Executes tasks from approved plan with quality verification at each step |
| 4 | `/context-build` | **Build** | Auto-detects framework (11 supported) and runs correct build command |
| 5 | `/context-test` | **Testing** | Comprehensive testing: unit, integration, E2E, security, accessibility, performance |
| 6 | `/context-review` | **Review** | Multi-perspective code review + OWASP security audit + severity classification |
| 7 | `/context-deploy` | **Deploy** | Deployment orchestration: Docker, Vercel, Netlify, AWS, GCP, Azure, VPS, Kubernetes |
| 8 | `/context-launch` | **Full Pipeline** | Autonomous: Plan → Work → Build → Test → Review → Deploy (all in one) |

### Maintenance & Operations Workflows

| # | Command | Name | Purpose |
|---|---------|------|---------|
| 9 | `/context-debug` | **Debug** | Systematic root-cause debugging + automatic knowledge capture |
| 10 | `/context-refactor` | **Refactor** | Safe refactoring with before/after metrics, atomic execution, test verification |
| 11 | `/context-upgrade` | **Upgrade** | Dependency audit + safe upgrade with breaking change analysis |
| 12 | `/context-migrate` | **Migrate** | Database migration: generate, review, apply, rollback, seed |

### Documentation & Knowledge Workflows

| # | Command | Name | Purpose |
|---|---------|------|---------|
| 13 | `/context-docs` | **Documentation** | Generate README, CHANGELOG, API docs, contributing guide, ADR |
| 14 | `/context-ask` | **Ask** | Intelligent Q&A with code analysis, skill reference, and web research |
| 15 | `/context-git` | **Git Ops** | Branching, conventional commits, merge, release tagging, PR templates |

### UI/UX & Utility Workflows

| # | Command | Name | Purpose |
|---|---------|------|---------|
| 16 | `/context-ui-ux` | **UI/UX** | Professional UI generation with design system, 67 styles, 96 color palettes |
| 17 | `/context-reload` | **Reload** | Hot-reload rules, workflows, and skills mid-conversation |
| 18 | `/context-help` | **Help** | List all available commands, rules, skills, and capabilities |

### Workflow Pipeline Visualization

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        GAO AGENT WORKFLOW PIPELINE                          │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📊 PLAN          🔨 WORK          🏗️ BUILD         🧪 TEST                │
│  ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐              │
│  │ Analyze  │────▶│ Execute │────▶│ Compile │────▶│ Verify  │              │
│  │ Design   │     │ Code    │     │ Bundle  │     │ Quality │              │
│  │ Plan     │     │ Test    │     │ Optimize│     │ Security│              │
│  └─────────┘     └─────────┘     └─────────┘     └─────────┘              │
│       │                                                │                    │
│       ▼                                                ▼                    │
│  ┌─────────┐                                     ┌─────────┐              │
│  │ ⛔ USER │                                     │ 🔍 CODE │              │
│  │ APPROVAL│                                     │ REVIEW  │              │
│  └─────────┘                                     └────┬────┘              │
│                                                       │                    │
│                                                       ▼                    │
│                                                  ┌─────────┐              │
│                                                  │ 🚀 DEPLOY│              │
│                                                  │ ⛔ APPROVE│             │
│                                                  └─────────┘              │
│                                                                              │
│  🔄 SUPPORTING WORKFLOWS:                                                   │
│  /context-debug    — Systematic debugging with knowledge capture            │
│  /context-refactor — Safe refactoring with metrics                          │
│  /context-upgrade  — Dependency audit & upgrade                             │
│  /context-migrate  — Database migration management                          │
│  /context-docs     — Documentation generation                               │
│  /context-git      — Git operations & release management                    │
│  /context-ui-ux    — Professional UI/UX generation                          │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### `/context-build` — Auto-Detection Matrix

| Detected File | Framework | Build Command |
|---------------|-----------|---------------|
| `next.config.*` | Next.js | `npm run build` |
| `vite.config.*` | Vite (React/Vue) | `npm run build` |
| `angular.json` | Angular | `ng build --configuration production` |
| `nuxt.config.*` | Nuxt.js | `npm run build` |
| `pom.xml` | Java (Maven) | `mvn clean package -DskipTests` |
| `build.gradle` | Java (Gradle) | `./gradlew build -x test` |
| `pubspec.yaml` | Flutter | `flutter build web/apk/ios` |
| `go.mod` | Go | `go build ./...` |
| `composer.json` | Laravel/PHP | `php artisan optimize` |
| `*.csproj / *.sln` | .NET/C# | `dotnet build --configuration Release` |
| `Cargo.toml` | Rust | `cargo build --release` |
| `requirements.txt` | Python | `pip install && collectstatic` |
| `Gemfile` | Ruby/Rails | `bundle exec rails assets:precompile` |

---

## 🛠 Skills Library (365)

GAO Agent includes **365 deep technical skill directories**, each containing production-ready reference implementations, architecture patterns, and best practices. Skills are NOT generic documentation — they are **battle-tested implementation guides** that the agent reads before writing any code.

### Languages & Core Frameworks

| Skill | Description |
|-------|-------------|
| `javascript` | ES2024+, async patterns, module systems, Node.js backend |
| `typescript` | Type system, generics, utility types, decorators, strict mode |
| `python` | Type hints, async, FastAPI, Django, testing, packaging |
| `java` | Spring Boot, JPA/Hibernate, REST APIs, enterprise patterns |
| `php` | PHP 8.3+, OOP, Composer, PSR standards, security |
| `golang` | Clean architecture, HTTP servers, concurrency, error handling |
| `rust` | Ownership, borrowing, traits, async/await, Actix/Axum web |
| `kotlin-android` | Jetpack Compose, MVVM, Coroutines, Room, Hilt DI |
| `swift-ios` | SwiftUI, UIKit, Combine, Core Data, App Store deployment |
| `flutter` | Cross-platform, state management, platform integration |
| `dotnet` | Clean architecture, Entity Framework, DI, async patterns |

### Web Frameworks

| Skill | Description |
|-------|-------------|
| `reactjs` | Components, hooks, state management, performance optimization |
| `nextjs` | App Router, Server Components, Server Actions, SSR/SSG/ISR |
| `vuejs` | Composition API, Pinia, Vue Router, Nuxt.js integration |
| `angular` | Modules, services, RxJS, routing, forms, HttpClient |
| `svelte` | Reactivity, SvelteKit, server-side rendering, form actions |
| `laravel` | Eloquent ORM, API development, authentication, queue workers |
| `django` | Models, DRF, admin, testing, deployment |
| `flask` | Blueprints, REST APIs, SQLAlchemy, testing |
| `aspnet` | MVC, Razor Pages, Blazor, SignalR, middleware |
| `nodejs` | Express/Fastify, middleware, auth, database integration |

### Databases

| Skill | Description |
|-------|-------------|
| `postgresql` | Advanced queries, indexing, performance tuning, extensions |
| `mysql` | Schema design, binary UUIDs, query optimization, replication |
| `mongodb` | Document modeling, aggregation pipelines, transactions |
| `sql-server` | T-SQL, query optimization, .NET integration |
| `oracle` | PL/SQL, partitioning, performance tuning |
| `sap-hana` | CDS views, SQLScript, calculation views |
| `redis` | Caching, pub/sub, streams, clustering |
| `elasticsearch` | Full-text search, Query DSL, analyzers, aggregations |
| `firebase` | Firestore, Auth, Realtime DB, Cloud Functions |
| `supabase` | Auth, PostgreSQL, Realtime, Storage, RLS |
| `prisma` | Schema design, migrations, type-safe CRUD, relations |

### Security & Encryption

| Skill | Description |
|-------|-------------|
| `aes-256` | AES-256-GCM/CBC, key management, field-level encryption |
| `post-quantum-crypto` | ML-KEM/Kyber, ML-DSA/Dilithium, hybrid encryption |
| `oauth-jwt` | OAuth 2.0 flows, JWT, PKCE, token management |
| `keycloak` | IAM, OIDC/SAML, role management, user federation |
| `xss-security` | Reflected/stored/DOM XSS, CSP, output encoding |
| `ddos-protection` | Rate limiting, Cloudflare, AWS Shield, Nginx config |
| `waf` | Cloudflare WAF, AWS WAF, ModSecurity, OWASP CRS |
| `secrets-management` | Secret detection, vault integration, key rotation |
| `secure-code-patterns` | Input validation, parameterized queries, JWT security |
| `threat-modeling` | STRIDE methodology, attack surface analysis, risk scoring |
| `security-audit` | OWASP Top 10 checklist, dependency scanning, reporting |

### Payment Gateways (Indonesia)

| Skill | Description |
|-------|-------------|
| `midtrans` | Snap API, Core API, VA, e-wallet, QRIS, credit cards |
| `xendit` | Invoices, e-wallets (OVO, DANA, ShopeePay), VA, disbursements |
| `doku` | Checkout API, Direct API, SNAP BI compliance, QRIS |
| `stripe` | Payment Intents, subscriptions, webhooks, PCI compliance |

### Cloud & Infrastructure

| Skill | Description |
|-------|-------------|
| `aws` | EC2, S3, Lambda, RDS, CloudFront, IAM, DynamoDB, SQS |
| `gcp` | Cloud Run, Functions, Storage, BigQuery, Pub/Sub |
| `azure` | App Service, Functions, Blob Storage, Cosmos DB, Key Vault |
| `docker` | Multi-stage builds, docker-compose, security hardening |
| `kubernetes` | Pods, deployments, services, ingress, autoscaling |
| `terraform` | HCL, providers, modules, state management, workspaces |
| `nginx` | Reverse proxy, SSL/TLS, rate limiting, security headers |

### AI & Machine Learning

| Skill | Description |
|-------|-------------|
| `ai-ml` | ML pipeline architecture, model serving, MLOps, LLM integration |
| `tensorflow` | CNNs, RNNs, transfer learning, TensorFlow Serving |
| `pytorch` | Model building, training loops, TorchServe deployment |
| `scikit-learn` | Classification, regression, clustering, pipelines |
| `gemini-api` | Text generation, multimodal, function calling, embeddings |
| `openai-api` | Chat completions, structured output, assistants API |
| `machine-learning` | Model selection, hyperparameter tuning, cross-validation |
| `predictive-analytics` | Forecasting, customer analytics, churn prediction |

### Deployment Skills

| Skill | Target |
|-------|--------|
| `deploy-frontend` | Vercel, Netlify, Cloudflare Pages, Nginx, Docker |
| `deploy-laravel` | Nginx/Apache, PHP-FPM, Forge, Deployer, Docker |
| `deploy-java` | JAR/WAR, Docker, Kubernetes, Tomcat, CI/CD |
| `deploy-python` | Gunicorn, uWSGI, Docker, Nginx, systemd |
| `deploy-flutter` | Android (Play Store), iOS (App Store), Web hosting |
| `deploy-go` | Static binary, Docker scratch, systemd, K8s |
| `deploy-dotnet` | IIS, Kestrel, Azure App Service, Docker |

### MCP Server Integrations (65+)

GAO Agent includes **65+ Model Context Protocol (MCP) server skills** for direct integration with external tools and services.

**⚡ Context7 & MCP Configuration Templates**
GAO Agent provides ready-to-use configuration templates for [Context7](https://context7.com) (up-to-date library documentation) and other MCP servers across **24 AI coding clients** (Google Antigravity, Cursor, VS Code, Claude, Windsurf, etc.).

**How to setup Context7 / MCP servers:**
1. Run the auto-setup workflow: `/context-mcp-check --setup`
2. Or browse the templates manually in: `.agent/mcp-configs/templates/`
3. Add your API keys to `.env` (use `.agent/mcp-configs/.env.mcp.example` as a starting point)

| Category | MCP Skills |
|----------|-----------|
| **DevOps** | GitHub, Azure DevOps, GitLab, Vercel, Terraform, Octopus Deploy |
| **Monitoring** | Sentry, Datadog, Dynatrace, Netdata, Logfire |
| **Design** | Figma, Anima, Miro |
| **Database** | Supabase, Neon, DBHub, Elasticsearch, PgEdge, Chroma |
| **Security** | Snyk, SonarQube, Stackhawk, Sonatype, Codacy |
| **Productivity** | Notion, Monday, Todoist, Atlassian, Box, Intercom |
| **AI/ML** | HuggingFace, Azure AI Foundry |
| **Web** | Playwright, Firecrawl, ScrapGraph, Tavily, Webflow, Wix |
| **Cloud** | Azure (AKS, ARM, Sentinel), Microsoft Enterprise |

### Testing & Security Scanning

| Category | Skills |
|----------|--------|
| **E2E Testing** | Playwright, Cypress |
| **API Testing** | Newman/Postman, Swagger Inspector |
| **Security Scanning** | OWASP ZAP, Burp Suite, Nikto, Nmap, SQLMap, FFuf |
| **Vulnerability** | Snyk, Trivy, OpenVAS, Nessus, Qualys, Checkmarx |
| **Code Quality** | SonarQube, ESLint Security, PHPStan, Semgrep |
| **Performance** | Artillery, k6, JMeter, Autocannon |
| **Accessibility** | pa11y, axe-core, Lighthouse CI |
| **Cross-Browser** | BrowserStack, Sauce Labs |

### Observability & Monitoring

| Skill | Description |
|-------|-------------|
| `structured-logging` | JSON logs, correlation IDs, sensitive data redaction |
| `elk-stack` | Elasticsearch + Logstash + Kibana, dashboards |
| `prometheus` | Metric types, PromQL, alerting, Grafana dashboards |
| `opentelemetry` | Traces, metrics, logs, auto-instrumentation |
| `grafana` | Multi-datasource dashboards, alerting, HTTP API |
| `datadog` | APM, synthetic tests, log management |
| `new-relic` | Full-stack observability, NRQL, NerdGraph API |

### Enterprise & Business Platforms

| Skill | Description |
|-------|-------------|
| `wordpress` | Theme/plugin development, REST API, WooCommerce |
| `shopify` | Liquid, Storefront API, Hydrogen (headless) |
| `odoo` | Module development, ORM, views, business logic |
| `whmcs` | Module development, API, hooks, hosting automation |
| `magento` | Component creation, DI, plugins, layout XML |

### UI/CSS Frameworks & Admin Templates

| Category | Skills |
|----------|--------|
| **CSS Frameworks** | Bootstrap, Tailwind CSS, Bulma, Material UI, Chakra UI, shadcn/ui |
| **Admin Templates** | AdminLTE, AdminKit, TailAdmin, Shadcn Admin, PlainAdmin, Focus Admin, CelestialAdmin, Ample Admin Lite |
| **Design** | Animation & Motion, Data Visualization, Icon Libraries, Dark/Light Mode |

### Data Engineering & Analytics

| Skill | Description |
|-------|-------------|
| `data-lake` | Medallion architecture, partitioning, Parquet/Delta/Iceberg |
| `data-warehouse` | Dimensional modeling, star/snowflake schema, ETL |
| `etl` | Extraction, transformation, loading, Airflow, Prefect |
| `hadoop` | HDFS, MapReduce, YARN, Hive, Spark, HBase |
| `business-intelligence` | KPI dashboards, Metabase, Superset, Power BI |

### Professional Roles & Methodology

| Skill | Description |
|-------|-------------|
| `data-scientist` | EDA, statistical methods, feature engineering, experiment tracking |
| `business-analyst` | Requirements, user stories, BPMN, use cases |
| `system-design` | Microservices, event-driven, caching, load balancing |
| `system-analyst` | Requirements analysis, UML, ERD, DFD |
| `project-management` | Agile, sprint planning, estimation, risk management |
| `quality-control` | Testing strategies, code review, quality gates |
| `design-patterns` | GoF patterns, Repository, CQRS, Event-Driven |

---

## 🧠 Memory System

GAO Agent features a **persistent memory system** that makes it smarter over time:

### Error Memory (`error-memory.md`)

```
┌─────────────────────────────────────────────────────────────┐
│                    ERROR MEMORY FLOW                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  BEFORE TASK:                                               │
│    ① Read .agent/memory/ERROR_LOG.md                       │
│    ② Scan prevention rules for relevance                   │
│    ③ Apply lessons learned to current task                 │
│                                                             │
│  DURING TASK (if error detected):                           │
│    ④ STOP → LOG → Fix → Resume                            │
│    ⑤ Record: what went wrong, root cause, correct way      │
│    ⑥ Create prevention rule (IF-THEN format)               │
│                                                             │
│  RESULT:                                                    │
│    → Agent NEVER makes the same mistake twice               │
│    → Prevention rules accumulate over time                  │
│    → Knowledge is persistent across conversations           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**12 Error Categories Tracked:** Code Error, Build Error, Test Failure, Wrong Approach, Hallucination, Security Issue, Database Error, Command Error, Logic Error, User Correction, Repeated Rework, Pattern Detection.

### Self-Learning Knowledge (`self-learning.md`)

```
┌─────────────────────────────────────────────────────────────┐
│                 SELF-LEARNING FLOW                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  👁️ OBSERVE:                                                │
│    • User corrections → "Don't use var, use const"         │
│    • User preferences → Always use Bahasa Indonesia        │
│    • Request patterns → Always wants dark mode in UI       │
│    • Project conventions → UUID for primary keys           │
│                                                             │
│  📝 RECORD:                                                 │
│    → Write to .agent/memory/LEARNED_KNOWLEDGE.md           │
│    → Format: ID, description, when to apply, action rule   │
│    → Acknowledge: "📚 Noted: [what was learned]"           │
│                                                             │
│  ⚡ APPLY:                                                  │
│    → Read LEARNED_KNOWLEDGE.md before every task           │
│    → Scan rules relevant to current task                   │
│    → Apply PROACTIVELY without being told again            │
│                                                             │
│  🔄 EVOLVE:                                                 │
│    → Increase confidence level with observations           │
│    → Resolve conflicts: newer > older, explicit > implicit │
│    → Never delete — only supersede                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Learning Categories:** Communication & Language, Coding Style, Architecture & Patterns, Database & Schema, Technology Preferences, Workflow & Process, Project Conventions, UI/UX Preferences.

---

## ⚙ How It Works

### Pre-Task Protocol (Before Writing ANY Code)

```
1. CHECK   → .agent/context/AGENT_LOCK           (race condition prevention)
2. READ    → .agent/context/ACTIVE_TASK.md       (auto-handoff state)
3. READ    → .agent/memory/ERROR_LOG.md          (past mistakes)
4. READ    → .agent/memory/LEARNED_KNOWLEDGE.md  (user preferences)
5. READ    → .agent/context/CONTEXT_INDEX.md     (project context)
6. READ    → .agent/context/ARCHITECTURE.md      (patterns)
7. LOAD    → Applicable skills for the tech stack
8. ENFORCE → All 19 mandatory rules
9. VERIFY  → Deep thinking checklist (12 points)
```

### During Task Execution

```
• Follow existing project patterns (never introduce new patterns without permission)
• Validate all inputs, encode outputs, use parameterized queries
• Apply SOLID principles and proper error handling
• Generate type-safe code (no `any` in TypeScript, no `var` in JavaScript)
• Log errors and corrections to memory files
• Record user preferences as they emerge
```

### Post-Task Protocol

```
1. UPDATE  → Documentation (DATABASE_SCHEMA, API_REFERENCE, etc.)
2. RUN     → Build verification
3. RUN     → Linting and tests
4. LOG     → Any errors to ERROR_LOG.md
5. LOG     → Any new knowledge to LEARNED_KNOWLEDGE.md
6. REPORT  → Completion status with verification evidence
```

---

## 📐 Decision Matrix

When GAO Agent encounters common architectural decisions, it follows these defaults:

| Question | GAO Agent's Decision | Rationale |
|----------|---------------------|-----------|
| Which database ID? | **UUID v4/v7** | Never auto-increment for public IDs — prevents enumeration attacks |
| Hard or soft delete? | **Soft delete** (`deleted_at`) | Data recovery, audit trail, referential integrity preservation |
| Store password how? | **bcrypt (cost ≥ 12)** or **Argon2id** | Industry standard, resistant to GPU/ASIC attacks |
| API response format? | `{ data, error, meta }` | Consistent, predictable, supports pagination and error details |
| Where to put logic? | **Service layer** | Never in controllers — separation of concerns, testability |
| CSS approach? | **Follow existing project pattern** | Consistency over preference |
| New dependency? | **Research first** | Check popularity, maintenance, security, license, bundle size |
| Secret management? | **Environment variables / Vault** | Never hardcode, never commit to git |
| Error handling? | **Typed exceptions / Result pattern** | Never silently swallow errors |
| Logging format? | **Structured JSON** | Machine-parseable, searchable, correlation IDs |
| API authentication? | **JWT + Refresh tokens** or **OAuth 2.0** | Stateless, scalable, industry standard |
| Database columns? | `created_at`, `updated_at`, `deleted_at` | Audit trail on every table |
| Primary language? | **Follow user preference** | Detected from LEARNED_KNOWLEDGE.md |

---

## 🤝 Contributing

### Adding a New Skill

1. Create the directory:
   ```bash
   mkdir .agent/skills/<skill-name>
   ```

2. Create `SKILL.md` with YAML frontmatter:
   ```markdown
   ---
   name: Your Skill Name
   description: Brief description covering key capabilities
   ---

   # Your Skill Name

   ## Overview
   What this skill covers and when to use it.

   ## Key Concepts
   Core patterns, architecture decisions, comparison tables.

   ## Implementation Examples
   Production-ready code examples in relevant languages.

   ## Best Practices
   Do's and don'ts with rationale.

   ## Security Considerations
   Security-specific guidance for this technology.
   ```

3. Register the skill in `.agent/AGENTS.md` under the appropriate category

### Adding a New Rule

1. Create `.agent/rules/<rule-name>.md`
2. Follow the structure: Core Principle → Enforcement Details → Examples → Anti-Patterns
3. Register in `AGENTS.md` under "📏 Mandatory Rules"
4. Add reference to `context-help.md` mandatory rules table

### Adding a New Workflow

1. Create `.agent/workflows/<workflow-name>.md` with YAML frontmatter:
   ```markdown
   ---
   description: Short description of what the workflow does
   ---

   # Workflow Title

   ## Phase 1: [Phase Name]
   ### Step 1.1 — [Step Name]
   // turbo
   [Step instructions with skill bindings and rule references]
   ```

2. Include mandatory rule reads (especially `deep-thinking.md`)
3. Bind to relevant skills from `.agent/skills/`
4. Register in `AGENTS.md` under "🔄 Available Workflows"

---

## 📊 Statistics

| Metric | Count |
|--------|-------|
| **Total Skill Directories** | 365 |
| **Mandatory Rules** | 19 |
| **Automated Workflows** | 19 |
| **Memory Files** | 2 (Error Log + Learned Knowledge) |
| **Languages Supported** | 11 (JS, TS, Python, Java, Go, PHP, C#, Dart, Rust, Kotlin, Swift) |
| **Web Frameworks** | 12 (React, Next.js, Vue, Angular, Svelte, Laravel, Django, Flask, ASP.NET, Node.js, Nuxt, SvelteKit) |
| **Mobile Frameworks** | 3 (Flutter, Kotlin/Android, Swift/iOS) |
| **Databases Supported** | 11 (PostgreSQL, MySQL, MongoDB, Oracle, SQL Server, SAP HANA, Redis, Elasticsearch, Firebase, Supabase, Prisma) |
| **Cloud Platforms** | 5 (AWS, GCP, Azure, OpenStack, Virtuozzo) |
| **Security Frameworks** | 3 (ISO 27001, NIST CSF, CIS Controls v8) |
| **Payment Gateways** | 4 (Midtrans, Xendit, DOKU, Stripe) |
| **Deployment Targets** | 7 (Frontend, Laravel, Java, Flutter, Python, Go, .NET) |
| **MCP Integrations** | 65+ |
| **Testing Tools** | 25+ (E2E, Security, Performance, Accessibility, Code Quality) |
| **AI/ML Skills** | 8 (TensorFlow, PyTorch, Sklearn, Gemini, OpenAI, ML, Predictive, AI/ML) |
| **Encryption** | 2 (AES-256-GCM, Post-Quantum ML-KEM/Kyber) |
| **Admin Templates** | 8 |
| **SIEM/SOC Skills** | 15+ (Splunk, QRadar, Wazuh, Elastic, etc.) |
| **CMS Platforms** | 5 (WordPress, Joomla, Drupal, Shopify, Magento) |

---

## 📄 License

This project is proprietary. All rights reserved.

---

<div align="center">

**Built with ❤️ by GAO Agent Team**

*Transforming AI coding assistants into production-grade software engineers — secure, compliant, and always learning.*

**365 Skills · 18 Rules · 19 Workflows · Self-Learning Memory**

</div>
