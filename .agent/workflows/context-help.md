---
description: "List all available workflows, rules, and skills with descriptions. Use when you want to see what the agent can do."
---

# Context Help — Agent Command Reference

## Quick Reference

When the user asks for help, list all available commands organized by category.

### Steps

1. **Read the workflows directory:**
   // turbo
   ```bash
   find .agent/workflows -name "*.md" -not -name "*.bak" | sort
   ```

2. **Read the rules directory:**
   // turbo
   ```bash
   find .agent/rules -name "*.md" | sort
   ```

3. **Read the skills directory:**
   // turbo
   ```bash
   ls .agent/skills/
   ```

4. **Present the following reference:**

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 AGENT COMMAND REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔧 Development Workflows (Core Pipeline)

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/context-init` | Analyze entire codebase, generate AI context docs | First time setup, after major structural changes |
| `/context-plan` | Create implementation plan (with optional brainstorming) | Before building any feature or making significant changes |
| `/context-work` | Execute tasks from an approved plan | After plan is approved, ready to implement |
| `/context-build` | Auto-detect framework + build project | After implementation, before testing |
| `/context-test` | Run comprehensive test suite + generate report | After build, verify everything works |
| `/context-review` | Code review + security audit (unified) | After implementation, before merge/deploy |
| `/context-launch` | Full pipeline: plan → work → build → test → review | End-to-end feature development |

## 🐛 Debugging & Maintenance

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/context-debug` | Systematic debugging + knowledge capture | Bugs, errors, test failures |
| `/context-refactor` | Guided code refactoring with safety nets | Improve code quality, reduce complexity |
| `/context-upgrade` | Dependency audit + safe upgrades (unified) | Keep dependencies current, fix vulnerabilities |
| `/context-migrate` | Database migration management | Schema changes, data migration |

## 📝 Documentation & Knowledge

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/context-docs` | Generate user-facing docs (README, CHANGELOG, API) | After features are complete |
| `/context-ask` | Research, Q&A, and detailed answers | Need information, guidance, or analysis |

## 🔀 Version Control & Operations

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/context-git` | Branching, commits, merges, tags, releases | Git operations with conventions |
| `/context-deploy` | Deploy to target environment | Ship to staging/production |

## ⚙️ Utility

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/context-reload` | Reload all agent rules mid-conversation | After editing .agent/rules/ |
| `/context-help` | Show this reference | Anytime |
| `/context-ui-ux` | Generate professional UI/UX with design intelligence | Frontend/UI work |

## 🔀 Aliases (Redirects)

These commands are aliases that redirect to their unified counterparts:

| Alias | Redirects To | Phase |
|-------|-------------|-------|
| `/context-brainstorm` | `/context-plan` | Phase 0: Exploration |
| `/context-compatibility` | `/context-upgrade` | Phase 1: Compatibility Audit |
| `/context-security` | `/context-review` | Phase 2: Security Audit |
| `/context-compound` | `/context-debug` | Phase 5: Knowledge Capture |

## 📏 Mandatory Rules (Always Active)

These rules apply to ALL agent actions, regardless of workflow:

| Rule | Scope |
|------|-------|
| `deep-thinking.md` | Deep analysis, anti-hallucination, completeness (HIGHEST PRIORITY) |
| `error-memory.md` | Mistake logging & learning — never repeat errors |
| `self-learning.md` | Adaptive learning from user preferences & corrections |
| `solid-principles.md` | Code structure & design |
| `developer-security.md` | Security practices |
| `database-design.md` | Database conventions |
| `dependency-management.md` | Package vetting |
| `iso-27000-compliance.md` | Compliance standards |
| `ui-ux-design.md` | UI/UX standards |

## 🧰 Skills Library

The agent has **[N] skills** covering technologies including:
- **Languages:** JavaScript, TypeScript, PHP, Python, Go, Java, Rust, C#, Kotlin, Swift, Dart
- **Frameworks:** React, Next.js, Vue, Angular, Svelte, Laravel, Django, Flask, Spring Boot, .NET
- **Databases:** PostgreSQL, MySQL, MongoDB, Redis, Elasticsearch, Oracle, SQL Server
- **Cloud:** AWS, GCP, Azure, Firebase, Supabase
- **DevOps:** Docker, Kubernetes, Terraform, Nginx, Apache
- **Testing:** Playwright, Cypress, Jest, Vitest, PHPUnit, pytest, Artillery, OWASP ZAP
- **Security:** OAuth2, JWT, AES-256, NIST CSF, ISO 27001, CIS Controls
- **AI/ML:** TensorFlow, PyTorch, Scikit-learn, OpenAI API, Gemini API
- **And many more...**

Use `/context-ask [technology]` to learn about any specific skill.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Workflow Selection Guide

Help the user choose the right workflow:

```
"I want to..."
    │
    ├── "...build something new"
    │   ├── Big feature → /context-launch (full pipeline)
    │   ├── Planned feature → /context-work (execute plan)
    │   ├── Need to think first → /context-plan --explore (brainstorm + plan)
    │   └── Just plan it → /context-plan
    │
    ├── "...fix something"
    │   ├── Bug/error → /context-debug
    │   ├── Code quality → /context-refactor
    │   └── Dependencies → /context-upgrade
    │
    ├── "...check something"
    │   ├── Code quality + security → /context-review
    │   ├── Dependency health → /context-upgrade --audit-only
    │   ├── Run tests → /context-test
    │   └── Build project → /context-build
    │
    ├── "...deploy/ship"
    │   ├── Setup project → /context-init
    │   ├── Commit changes → /context-git
    │   ├── Deploy → /context-deploy
    │   └── Generate docs → /context-docs
    │
    └── "...learn/research"
        └── Any question → /context-ask
```
