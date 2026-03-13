---
name: writing-plans
description: "Use when you have requirements or a spec for a multi-step task. Creates implementation plans with configurable depth before any code is written."
---

This companion section adds YAML machine-readable todos for plans that need machine-trackable progress.

## YAML Machine-Readable Todos (Optional)

When creating plans that need to be tracked programmatically (e.g., by other tools or automation), add a YAML frontmatter `todos` array:

```yaml
---
title: "Feature: User Authentication"
status: in-progress
created: 2026-03-13
todos:
  - id: task-1
    content: "Create User model with UUID primary key"
    status: done
  - id: task-2
    content: "Implement JWT authentication middleware"
    status: in-progress
  - id: task-3
    content: "Add login/register endpoints"
    status: pending
  - id: task-4
    content: "Write integration tests for auth flow"
    status: pending
---
```

### Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not started |
| `in-progress` | Currently being worked on |
| `done` | Completed and verified |
| `blocked` | Blocked by dependency or issue |
| `skipped` | Intentionally skipped (with reason) |

### When to Use YAML Todos

- Plans with 10+ tasks that need automated tracking
- CI/CD workflows that parse plan progress
- When the user explicitly requests machine-readable format
- Cursor-compatible plan format with checkbox tracking

### When NOT to Use

- Simple plans (< 5 tasks) — Markdown tables are sufficient
- Internal agent plans that don't need external tracking
