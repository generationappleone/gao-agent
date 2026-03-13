---
name: subagent-driven-development
description: "Use when executing multi-task plans with subagent capabilities. Dispatches fresh agents per task with two-stage review (spec compliance + code quality) for higher quality output."
---

# Subagent-Driven Development (SDD)

## Overview

Subagent-Driven Development is the preferred execution model when the agent platform supports dispatching subagents. Instead of executing all tasks in a single long-running session (which accumulates context and fatigue), SDD dispatches a **fresh agent per task** with clean context.

**Announce:** "Using Subagent-Driven Development for task execution."

> **When to use SDD vs `executing-plans`:**
> - **SDD** — When subagent dispatch is available AND plan has 3+ independent tasks
> - **executing-plans** — When subagents are NOT available OR tasks are tightly coupled

---

## Architecture

```
┌─────────────────────────┐
│    Orchestrator Agent    │ ← You (the main agent)
│  • Reads the plan       │
│  • Selects next task    │
│  • Dispatches subagents │
│  • Collects results     │
└──────┬──────────────────┘
       │
       ├── Dispatch: Implementer Subagent (Task #N)
       │     └── Returns: code changes + summary
       │
       ├── Dispatch: Spec Reviewer Subagent
       │     └── Returns: spec compliance report
       │
       └── Dispatch: Code Quality Reviewer Subagent
             └── Returns: quality report + issues
```

---

## The SDD Process

### Step 1: Prepare Task Context

For each task in the plan:

1. Extract the task description from the plan
2. Identify relevant files (create/modify)
3. Gather relevant context (architecture, existing code, conventions)
4. Select the appropriate skill files for the task's technology

### Step 2: Dispatch Implementer

Dispatch a fresh subagent using the **Implementer Prompt Template** (`implementer-prompt.md`):

- Provide the task description, file context, and skill references
- The implementer writes the code/content
- The implementer returns a summary of changes made

**Key principle:** The implementer gets a **clean context** — no accumulated state from previous tasks.

### Step 3: Two-Stage Review

After the implementer returns, dispatch two review subagents:

#### Stage 1: Spec Compliance Review

Use **Spec Reviewer Prompt Template** (`spec-reviewer-prompt.md`):

- Does the implementation match the plan's requirements?
- Are all specified files created/modified?
- Are all acceptance criteria met?
- Any deviations from the spec?

#### Stage 2: Code Quality Review

Use **Code Quality Reviewer Prompt Template** (`code-quality-reviewer-prompt.md`):

- Code correctness and robustness
- Adherence to project conventions
- Security concerns
- Performance considerations
- Test coverage adequacy

### Step 4: Address Review Findings

- **No issues found** → Mark task complete, proceed to next
- **Minor issues** → Fix inline (orchestrator can handle)
- **Major issues** → Re-dispatch implementer with reviewer feedback

### Step 5: Update Progress

After each task completion:

1. Update `ACTIVE_TASK.md` with progress
2. Mark task as completed in the plan
3. Run any per-task verification checks
4. Proceed to next task

---

## When to Fall Back to Sequential Execution

Use `executing-plans` instead of SDD when:

- Subagent dispatch is not available on the current platform
- Tasks are tightly coupled (each depends on the previous one's output)
- The plan has fewer than 3 tasks (overhead not worth it)
- Real-time user interaction is needed during implementation

---

## Prompt Templates

The following companion files contain the prompt templates:

- `implementer-prompt.md` — Template for implementation subagents
- `spec-reviewer-prompt.md` — Template for spec compliance review
- `code-quality-reviewer-prompt.md` — Template for code quality review

---

## Integration

### This skill is called by
- `skills/executing-plans/SKILL.md` — When SDD mode is selected
- `workflows/context-work.md` — Phase 1.5b execution mode selection

### This skill references
- `skills/requesting-code-review/SKILL.md` — For dispatching code reviewers
- `skills/finishing-a-development-branch/SKILL.md` — For branch completion
- `skills/using-gao-agent/SKILL.md` — Master controller

### Key Principle

> **Fresh context per task.** Each subagent starts clean.
> This prevents context fatigue and accumulated errors.
