---
name: requesting-code-review
description: "Use when dispatching a code reviewer subagent or preparing code for human review. Includes structured review request template and reviewer agent definition."
---

# Requesting Code Review

## Overview

Structure code review requests for maximum effectiveness — whether sending to a human reviewer or dispatching a reviewer subagent.

**Announce:** "Using requesting-code-review skill to prepare review request."

## Review Request Template

### For Human Reviewers

```markdown
## Code Review Request

### What Changed
[Brief description of the changes]

### Why
[Motivation, ticket reference, or user story]

### How to Review
1. Start with [file/component] — this is the core change
2. Then check [file] — supporting changes
3. Finally review [tests] — coverage

### Areas of Concern
- [Specific areas where you want extra scrutiny]

### Testing Done
- [How you verified the changes work]

### Context
- Base: `main`
- Branch: `feat/feature-name`
- Files changed: [N]
- Lines: +[N] -[N]
```

### For Subagent Reviewer

Use `subagent-driven-development/code-quality-reviewer-prompt.md` as the base template, with these additions:

```markdown
## Reviewer Agent Definition

You are a senior code reviewer. Your review covers:

### 1. Plan Alignment
- Does the code implement what the plan specifies?
- Any deviations from the plan?

### 2. Code Quality
- Readability, naming, DRY, SOLID
- Error handling completeness
- No hardcoded values

### 3. Architecture
- File placement correct
- Dependency direction inward
- No circular dependencies

### 4. Security
- Input validation on external data
- Parameterized queries
- No secrets in code
- Auth checks present

### 5. Documentation
- Public APIs documented
- Complex logic explained

### 6. Issue Identification
- P1 (Critical) — Must fix
- P2 (Important) — Should fix
- P3 (Suggestion) — Nice to have
- P4 (Nitpick) — Optional
```

## Dispatch Process

1. **Gather context** — Collect the diff, plan reference, base/head SHAs
2. **Fill template** — Use the appropriate template (human or subagent)
3. **Dispatch** — Send to reviewer or dispatch subagent
4. **Process feedback** — Use `receiving-code-review` skill for responses

## Placeholders Reference

| Placeholder | Source |
|-------------|--------|
| `{WHAT_WAS_IMPLEMENTED}` | Implementer's summary |
| `{PLAN_OR_REQUIREMENTS}` | Plan task description |
| `{CODE_OR_FILE_PATHS}` | Git diff or file contents |
| `{BASE_SHA}` | Base branch commit SHA |
| `{HEAD_SHA}` | Feature branch HEAD SHA |

## Integration

**This skill is used by:**
- **executing-plans** — After task completion, before merge
- **subagent-driven-development** — Stage 2 dispatches reviewer
- **context-review.md** — Workflow references this for subagent reviews

**This skill pairs with:**
- **receiving-code-review** — Processing review responses
- **code-review** — The full review skill
