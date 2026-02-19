<div align="center">

# 🧠 GAO Agent

### **Generative AI Operations — Intelligent Coding Agent**

*An enterprise-grade AI coding agent framework with 126 skills, 9 mandatory rules, 6 workflows, and full-stack development capabilities.*

[![Skills](https://img.shields.io/badge/Skills-126-blue?style=for-the-badge&logo=bookstack&logoColor=white)](#-skills-126)
[![Rules](https://img.shields.io/badge/Rules-9-red?style=for-the-badge&logo=shield&logoColor=white)](#-mandatory-rules-9)
[![Workflows](https://img.shields.io/badge/Workflows-6-green?style=for-the-badge&logo=githubactions&logoColor=white)](#-workflows-6)
[![License](https://img.shields.io/badge/License-Proprietary-orange?style=for-the-badge&logo=lock&logoColor=white)](#license)

---

*GAO Agent is a comprehensive AI-powered coding assistant framework that provides structured skills, enforced rules, and automated workflows for building production-ready applications across multiple languages, frameworks, and platforms.*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Mandatory Rules](#-mandatory-rules-9)
- [Workflows](#-workflows-6)
- [Skills](#-skills-126)
- [Project Structure](#-project-structure)
- [How It Works](#-how-it-works)
- [Contributing](#-contributing)
- [License](#license)

---

## 🌟 Overview

**GAO Agent** (Generative AI Operations) is an intelligent coding agent framework designed to produce consistent, secure, and production-grade code. Unlike generic AI assistants, GAO Agent operates with:

- **🔒 9 Enforced Rules** — Security, SOLID principles, database design, UI/UX standards, and compliance (UU PDP/GDPR) are non-negotiable
- **🛠️ 126 Technical Skills** — Deep reference implementations across 20+ technology categories
- **📋 6 Automated Workflows** — From project initialization to testing and deployment
- **📚 Context-Aware** — Reads and maintains project documentation to ensure consistency across every change

### Key Capabilities

| Capability | Description |
|-----------|------------|
| **Multi-Language Support** | JavaScript, TypeScript, Python, Java, Go, PHP, C#, Dart, Rust |
| **Full-Stack Development** | Frontend (React, Vue, Angular) + Backend (Laravel, Django, Spring Boot) + Mobile (Flutter) |
| **Security-First** | OWASP, ISO 27001, NIST CSF, CIS Controls compliance built-in |
| **Data Privacy** | UU PDP (Indonesia GDPR) compliance with field-level encryption |
| **AI/ML Integration** | TensorFlow, PyTorch, Scikit-learn, Gemini AI, OpenAI API |
| **Observability** | Structured logging, Prometheus, OpenTelemetry, ELK Stack |
| **Automated CI/CD** | Build detection, deployment recipes for 7 frameworks |

---

## 🏗 Architecture

```
.agent/
├── AGENTS.md                    # Master configuration (mandatory rules, skill registry)
│
├── rules/                       # 9 enforced coding rules
│   ├── solid-principles.md          # SOLID design principles
│   ├── developer-security.md        # 4-layer security model
│   ├── database-design.md           # UUID, audit columns, soft delete
│   ├── dependency-management.md     # Vetting, pinning, auditing
│   ├── iso-27000-compliance.md      # ISO 27001 data classification
│   ├── ui-ux-design.md              # Design tokens, dark mode, accessibility
│   ├── production-code-standards.md # Zero hallucinations, type safety
│   ├── frontend-architecture.md     # Feature-based, thin components
│   └── uu-pdp-compliance.md         # Indonesia data privacy law
│
├── workflows/                   # 6 automated workflows
│   ├── context-init.md              # Project analysis & doc generation
│   ├── context-ask.md               # Intelligent Q&A with research
│   ├── context-plan.md              # Implementation planning
│   ├── context-work.md              # Task execution engine
│   ├── context-test.md              # Comprehensive testing
│   └── context-build.md             # Framework-aware build engine
│
├── skills/                      # 126 technical skills
│   ├── laravel/SKILL.md             # Laravel PHP framework
│   ├── reactjs/SKILL.md             # React.js frontend
│   ├── deploy-frontend/SKILL.md     # Frontend deployment
│   ├── aes-256/SKILL.md             # AES-256 encryption
│   ├── post-quantum-crypto/SKILL.md # Post-quantum cryptography
│   └── ... (127 skill directories)
│
└── context/                     # Auto-generated project docs
    ├── CONTEXT_INDEX.md             # Master index
    ├── ARCHITECTURE.md              # System architecture
    ├── DATABASE_SCHEMA.md           # Database documentation
    ├── API_REFERENCE.md             # API endpoints
    ├── DEPENDENCIES.md              # Package inventory
    ├── DEVELOPMENT_GUIDE.md         # Setup instructions
    ├── BUSINESS_DOMAINS.md          # Domain documentation
    └── PROJECT_OVERVIEW.md          # Project summary
```

---

## 🚀 Getting Started

### Prerequisites

- AI coding assistant (Gemini, Claude, GPT, or compatible)
- Project workspace with source code

### Installation

1. **Clone/copy the `.agent/` directory** into your project root:

```bash
# Copy the agent framework into your project
cp -r gao-agent/.agent /path/to/your-project/.agent
```

2. **Initialize the project context** (first-time setup):

```
/context-init
```

This will scan your entire codebase and generate documentation in `.agent/context/`.

3. **Start building:**

```
/context-plan    # Plan your feature
/context-work    # Execute the plan
/context-build   # Build the project
/context-test    # Run tests
```

---

## 🔒 Mandatory Rules (9)

Every line of code produced by GAO Agent must comply with these rules. **They are non-negotiable.**

### 1. SOLID Principles
| Principle | Enforcement |
|-----------|------------|
| **SRP** | Each class/function has ONE responsibility. Max 50 lines per function |
| **OCP** | Extend via interfaces/abstractions, not modification |
| **LSP** | Subtypes must be substitutable for base types |
| **ISP** | Small, focused interfaces over large monolithic ones |
| **DIP** | Depend on abstractions, inject dependencies |

### 2. Developer Security
```
Layer 1: Secure Code     → Input validation, output encoding, parameterized queries
Layer 2: Dependencies    → Vetting, pinning, auditing (npm audit, pip audit)
Layer 3: Containers      → Non-root, minimal base images, vulnerability scanning
Layer 4: Infrastructure  → Secrets in vault, security headers, HTTPS
```

### 3. Database Design
- ✅ UUID primary keys (never auto-increment for public IDs)
- ✅ Audit columns: `created_at`, `updated_at` on every table
- ✅ Soft delete: `deleted_at` column (never hard delete user data)
- ✅ Proper normalization (3NF minimum)
- ✅ Indexes on foreign keys and frequently queried columns

### 4. Dependency Management
- Research before installing ANY dependency
- Check: popularity, maintenance, security, license, size
- Pin exact versions, run security audits

### 5. ISO 27000 Compliance
- Data classification: Public, Internal, Confidential, Restricted
- AES-256-GCM encryption for sensitive data
- Audit logging for all security events
- Vulnerability patching SLA (Critical: 24h, High: 7d)

### 6. UI/UX Design
- Micro-interactions and smooth transitions
- WCAG 2.1 AA accessibility compliance
- Dark mode support (mandatory)
- Design token system for consistency
- Mobile-first responsive design

### 7. Production Code Standards
- Zero hallucinations — verify every import and function exists
- Type-safe everything — `any` is BANNED in TypeScript
- Full context awareness — read ALL related files before coding
- Surgical edits — change only what's necessary

### 8. Frontend Architecture
- Feature-based folder structure
- Thin components (JSX only — logic in hooks)
- 4 UI states: loading, error, empty, success
- Performance budgets: LCP < 2.5s, bundle < 200KB gzipped

### 9. UU PDP Compliance (Indonesia GDPR)
- Data classification: Umum (general) vs Spesifik (sensitive)
- Explicit consent before processing
- Field-level encryption for Data Spesifik (AES-256-GCM)
- 7 data subject rights implementation
- Breach notification within 3×24 hours

---

## 📋 Workflows (6)

| # | Workflow | Command | Purpose |
|---|----------|---------|---------|
| 1 | **Context Init** | `/context-init` | Scans the entire codebase and generates comprehensive documentation |
| 2 | **Context Ask** | `/context-ask` | Answers questions with code analysis and internet research |
| 3 | **Context Plan** | `/context-plan` | Creates detailed implementation plans with priorities and dependencies |
| 4 | **Context Work** | `/context-work` | Executes tasks from an approved plan with quality verification |
| 5 | **Context Test** | `/context-test` | Runs comprehensive testing (features, security, reliability) |
| 6 | **Context Build** | `/context-build` | Auto-detects framework and runs the correct build command |

### Workflow Chain
```
/context-init  →  /context-plan  →  /context-work  →  /context-build  →  /context-test
    ↓                  ↓                  ↓                  ↓                  ↓
 Analyze           Plan it           Execute it          Build it           Test it
 Project           (diagrams,        (code, DB,          (detect            (E2E,
                   priorities)       APIs, UI)           framework)         security)
```

### `/context-build` — Framework Auto-Detection

The build workflow automatically detects your project framework:

| Detected File | Framework | Build Command |
|--------------|-----------|--------------|
| `next.config.*` | Next.js | `npm run build` |
| `vite.config.*` | Vite (React/Vue) | `npm run build` |
| `angular.json` | Angular | `ng build --configuration production` |
| `pom.xml` | Java (Maven) | `mvn clean package -DskipTests` |
| `build.gradle` | Java (Gradle) | `./gradlew build -x test` |
| `pubspec.yaml` | Flutter | `flutter build web/apk/ios` |
| `go.mod` | Go | `go build ./...` |
| `composer.json` | Laravel/PHP | `php artisan optimize` |
| `*.csproj` | .NET | `dotnet build --configuration Release` |
| `requirements.txt` | Python | `pip install && collectstatic` |
| `Cargo.toml` | Rust | `cargo build --release` |

---

## 🛠 Skills (126)

### Overview by Category

| Category | Count | Technologies |
|----------|-------|-------------|
| **Languages & Frameworks** | 13 | Laravel, React.js, Python, Java, JavaScript, Flutter, Go, PHP, .NET, ASP.NET, Flask, Django, ionCube |
| **Databases** | 6 | PostgreSQL, MySQL, MongoDB, SAP HANA, Oracle, SQL Server |
| **CSS & UI** | 6 | Bootstrap, Tailwind CSS, shadcn/ui, Chakra UI, Bulma, Material UI |
| **Frontend Enhancement** | 3 | Animation & Motion, Data Visualization, Icon Libraries |
| **Admin Templates** | 8 | TailAdmin, AdminLTE, AdminKit, Shadcn Admin, CelestialAdmin, PlainAdmin, Focus Admin, Ample Admin |
| **Platform & Tools** | 8 | Node.js, Docker, SEO, Apache, XAMPP, Laragon, Kubernetes, Git |
| **Messaging & Infra** | 3 | Redis, Kafka, Load Balancing |
| **Deployment** | 7 | Frontend, Laravel, Java, Flutter, Python, Go, .NET |
| **Business Platforms** | 2 | WHMCS, Odoo |
| **CMS** | 4 | WordPress, Joomla, Drupal, Wix/Squarespace |
| **E-Commerce** | 2 | Shopify, Magento |
| **Security & Quality** | 2 | Security Code Review, Code Quality |
| **Security Frameworks** | 3 | ISO 27001, NIST CSF, CIS Controls |
| **Privacy & Compliance** | 3 | UU PDP, Consent Management, Data Privacy Engineering |
| **Authentication** | 2 | Keycloak, Google OAuth |
| **Email & Messaging** | 2 | SMTP OTP, SMTP Email |
| **Application Security** | 3 | XSS Security, DDoS Protection, WAF |
| **Encryption** | 2 | AES-256, Post-Quantum Cryptography |
| **CAPTCHA & Bot** | 2 | Cloudflare Turnstile, Google reCAPTCHA |
| **API Standards** | 2 | REST API, IETF JSON Standards |
| **Data Engineering** | 4 | Data Lake, Data Warehouse, ETL, Hadoop |
| **AI & ML** | 6 | AI/ML, Machine Learning, TensorFlow, PyTorch, Scikit-learn, Predictive Analytics |
| **AI API Providers** | 2 | Gemini AI, OpenAI |
| **Roles & Methodology** | 7 | Data Scientist, Business Analyst, BI, System Design, System Analyst, Quality Control, Project Management |
| **Observability** | 4 | Structured Logging, ELK Stack, Prometheus, OpenTelemetry |
| **Testing (Auto-Install)** | 9 | Playwright, Cypress, Load Testing, Newman, Accessibility, ESLint, Snyk, Python Security, PHPStan |
| **Testing (CLI)** | 9 | OWASP ZAP, Nikto, Nmap, SQLMap, FFuf, Burp Suite, Trivy, SonarQube, Checkmarx |
| **Testing (Cloud/SaaS)** | 3 | Cross-Browser, Datadog, PagerDuty |

### Skill File Format

Each skill follows a consistent structure:

```markdown
---
name: Skill Name
description: Brief description covering key capabilities
---

# Skill Name

## Overview
What this skill covers and when to use it.

## Key Concepts
Core patterns, architecture decisions, and comparison tables.

## Implementation Examples
Production-ready code examples in relevant languages.

## Best Practices
Do's and don'ts with rationale.
```

---

## 📁 Project Structure

```
your-project/
├── .agent/                    # GAO Agent configuration
│   ├── AGENTS.md              # Master configuration file
│   ├── rules/                 # 9 mandatory coding rules
│   ├── skills/                # 126 technical skills
│   ├── workflows/             # 6 automated workflows
│   └── context/               # Auto-generated project documentation
│
├── src/                       # Your application source code
├── tests/                     # Test files
├── package.json               # (or pom.xml, composer.json, etc.)
└── README.md                  # Project README
```

---

## ⚙ How It Works

### 1. Pre-Task Protocol
Before writing ANY code, GAO Agent:
1. **Reads** `CONTEXT_INDEX.md` and relevant context files
2. **Identifies** existing patterns (architecture, naming, conventions)
3. **Loads** applicable skills for the technology stack
4. **Enforces** all 9 mandatory rules

### 2. Code Generation
During implementation:
- Follows existing project patterns (never introduces new patterns without permission)
- Validates all inputs, encodes outputs, uses parameterized queries
- Applies SOLID principles and proper error handling
- Generates type-safe code (no `any` in TypeScript)

### 3. Post-Task Protocol
After making changes:
- Updates relevant documentation (DATABASE_SCHEMA, API_REFERENCE, etc.)
- Runs build verification
- Executes linting and tests
- Reports completion status

### Decision Matrix

| Question | GAO Agent's Answer |
|----------|-------------------|
| Which database ID? | UUID (never auto-increment for public IDs) |
| Hard or soft delete? | Soft delete (`deleted_at` column) |
| Store password how? | bcrypt (cost ≥ 12) or Argon2id |
| API response format? | `{ data, error, meta }` |
| Where to put logic? | Service layer (never in controllers) |
| CSS approach? | Follow existing project pattern |
| New dependency? | Research first (check popularity, security, license) |

---

## 🤝 Contributing

### Adding a New Skill

1. Create a directory: `.agent/skills/<skill-name>/`
2. Create `SKILL.md` with YAML frontmatter:

```markdown
---
name: Your Skill Name
description: Brief description of what the skill covers
---

# Your Skill Name
[Content following the standard skill structure]
```

3. Register the skill in `.agent/AGENTS.md` under the appropriate category
4. Update the skill count in the header

### Adding a New Rule

1. Create `.agent/rules/<rule-name>.md` with the rule content
2. Register in `AGENTS.md` under "📏 Mandatory Rules"

### Adding a New Workflow

1. Create `.agent/workflows/<workflow-name>.md` with YAML frontmatter:

```markdown
---
description: Short description of what the workflow does
---

# Workflow Title
[Workflow steps with phases and turbo annotations]
```

2. Register in `AGENTS.md` under "🔄 Available Workflows"

---

## 📊 Statistics

| Metric | Count |
|--------|-------|
| **Total Skills** | 126 |
| **Mandatory Rules** | 9 |
| **Automated Workflows** | 6 |
| **Languages Supported** | 9+ (JS, TS, Python, Java, Go, PHP, C#, Dart, Rust) |
| **Frameworks Covered** | 15+ (React, Next.js, Vue, Angular, Laravel, Django, Flask, Spring Boot, Flutter, .NET, etc.) |
| **Databases Supported** | 6 (PostgreSQL, MySQL, MongoDB, Oracle, SQL Server, SAP HANA) |
| **Security Frameworks** | 3 (ISO 27001, NIST CSF, CIS Controls) |
| **Deployment Targets** | 7 (Frontend, Laravel, Java, Flutter, Python, Go, .NET) |
| **Testing Tools** | 21 (E2E, Security, Performance, Accessibility) |
| **AI/ML Skills** | 8 (TensorFlow, PyTorch, Sklearn, Gemini, OpenAI, Predictive Analytics) |
| **Encryption** | 2 (AES-256-GCM, Post-Quantum/ML-KEM) |
| **Skill Directories** | 127 |
| **Rule Files** | 9 |
| **Workflow Files** | 6 |

---

## 📄 License

This project is proprietary. All rights reserved.

---

<div align="center">

**Built with ❤️ by GAO Agent Team**

*Making AI coding assistants production-ready, secure, and compliant.*

</div>
