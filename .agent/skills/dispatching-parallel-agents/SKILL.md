---
name: dispatching-parallel-agents
description: "Use when debugging 3+ independent failure domains simultaneously. Dispatches focused agents per domain for parallel diagnosis."
---

# Dispatching Parallel Agents

## Overview

When a system has multiple independent failures across different domains, dispatching focused agents per domain is more efficient than serial debugging. Each agent gets a narrow scope and clean context.

**Announce:** "Using dispatching-parallel-agents for multi-domain debugging."

> **Delineation:** This skill is for **debugging parallelism** (3+ independent error domains). For **task execution parallelism** (independent implementation tasks from a plan), see `executing-plans/SKILL.md` swarm mode or `subagent-driven-development/SKILL.md`.

## When to Use

- **3+ independent failures** in different parts of the system
- **Failures don't share root cause** — fixing one won't fix others
- **Each failure domain is self-contained** — can be diagnosed independently

## When NOT to Use

- **Single failure** — Use `systematic-debugging` skill directly
- **Cascading failures** — Fix root cause first, others may resolve
- **Shared root cause** — Serial debugging is more efficient
- **Implementation tasks** — Use `executing-plans` swarm mode instead

## Domain Identification

Before dispatching, identify independent domains:

```
Example: "App broken after deploy"

Domain 1: Database — Migration failed, tables missing
Domain 2: Auth — Token validation endpoint returning 500
Domain 3: Frontend — Build error, missing env variables
Domain 4: API — Rate limiter misconfigured

→ 4 independent domains, all can be debugged in parallel
```

### Independence Test

For each pair of failures, ask: **"If I fix A, does B also get fixed?"**
- If YES → Same domain (don't split)
- If NO → Independent domains (can parallelize)

## Dispatch Pattern

### For each domain, create a focused agent task:

```markdown
## Agent Task: Debug [Domain Name]

### Context
[Current state of the system related to this domain]

### Symptom
[Exact error message, log excerpt, or behavior]

### Scope
- ONLY investigate: [specific files/services/components]
- DO NOT modify: [files outside your domain]

### Expected Output
1. Root cause identification
2. Proposed fix (code changes)
3. Verification steps
```

### Coordination

After all agents return:

1. **Review each agent's findings** — Check for cross-domain dependencies
2. **Apply fixes in dependency order** — Database → Backend → Frontend
3. **Run integration tests** — Verify no cross-domain regressions
4. **Commit per-domain** — Separate commits per domain for clean history

## Common Mistakes

| Mistake | Prevention |
|---------|-----------|
| Splitting cascading failures | Run independence test first |
| Giving agents overlapping scope | Define clear boundaries per domain |
| Applying fixes without integration check | Always run full test suite after |
| Too many domains (5+) | Group related domains to max 3-4 agents |

## Delineation: This Skill vs Similar Skills

| Aspect | Dispatching Parallel Agents | Executing-Plans Swarm Mode | Subagent-Driven Development |
|--------|----------------------------|---------------------------|----------------------------|
| **Purpose** | Debug multiple failures | Execute plan tasks in parallel | Execute plan tasks with review |
| **Trigger** | 3+ independent error domains | 5+ independent implementation tasks | 3+ tasks with subagent support |
| **Agent Focus** | Diagnosis + fix proposal | Implementation | Implementation + two-stage review |
| **Coordination** | Manual integration after | Task queue with dependencies | Orchestrator manages review loop |

## Integration

**This skill is used by:**
- **systematic-debugging** — When multiple independent failures detected
- **context-debug.md** — Workflow may suggest parallel dispatch

**This skill references:**
- **systematic-debugging** — Each agent follows debugging methodology
- **using-git-worktrees** — If agents need isolated workspaces
