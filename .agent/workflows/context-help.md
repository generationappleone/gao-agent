---
description: List all available workflows, rules, and skills with descriptions. Use when you want to see what the agent can do.
---

# Context Help — Available Commands Reference

This workflow displays all available agent capabilities, organized by category.

## Steps

1. **Display quick reference** — Show the user:

```markdown
# 🤖 Agent Quick Reference

## 📋 Workflows (slash commands)

### Development Lifecycle
| Command | Purpose |
|---------|---------|
| `/context-init` | Analyze project & generate context docs (run once for new projects) |
| `/context-brainstorm` | Explore feature ideas collaboratively before planning |
| `/context-plan` | Create detailed implementation plan with priorities |
| `/context-work` | Execute tasks from an approved plan |
| `/context-build` | Auto-detect framework & run build command |
| `/context-test` | Run comprehensive test suite with reporting |
| `/context-launch` | Full pipeline: brainstorm → plan → work → build → test → security → review |

### Quality & Security
| Command | Purpose |
|---------|---------|
| `/context-review` | Multi-perspective code review (severity classification) |
| `/context-security` | Full security audit (OWASP Top 10, dependency scan) — read-only |
| `/context-compatibility` | Tech stack compatibility audit — read-only |
| `/context-debug` | Systematic bug diagnosis with root-cause investigation |

### Operations & Maintenance
| Command | Purpose |
|---------|---------|
| `/context-deploy` | Deploy app (auto-detects framework, routes to deploy skill) |
| `/context-refactor` | Guided code refactoring with safety nets |
| `/context-migrate` | Database migration management (generate, apply, rollback) |
| `/context-upgrade` | Safe dependency upgrades with breaking change analysis |
| `/context-git` | Git operations (branching, commits, tagging, changelog) |

### Documentation & Knowledge
| Command | Purpose |
|---------|---------|
| `/context-docs` | Generate user-facing docs (README, CHANGELOG, API docs) |
| `/context-compound` | Capture solved problems as searchable documentation |
| `/context-ui-ux` | Generate professional UI/UX with design intelligence |
| `/context-ask` | Ask anything with detailed code analysis & research |

### Meta
| Command | Purpose |
|---------|---------|
| `/context-help` | This help page — list all available commands |
| `/context-reload` | Reload agent rules mid-conversation |

## 📏 Rules (always active)
Rules are mandatory constraints that apply to ALL work:
- **SOLID Principles** — Clean architecture patterns
- **Developer Security** — 4-layer security model
- **Database Design** — UUID, soft delete, audit columns
- **Verification Gate** — No claims without evidence
- **Adaptive TDD** — Test-first development
- **Continuous Execution** — No pausing between tasks
- **Production Code Standards** — Zero hallucinations

## 🛠️ Skills
The agent has **183 skills** covering languages, frameworks, databases, security, cloud, and more. Skills are loaded automatically when relevant to your task.

For the full skill catalog, see `AGENTS.md`.
```

## When to Use
- You're new and want to see what's available
- You can't remember a specific command
- You want an overview of agent capabilities
