---
name: skill-routing
description: "Universal master controller hook — MUST be loaded by ALL workflows. Ensures using-gao-agent skill is always active and defines the 4-layer delineation architecture."
---

# Skill Routing — Universal Master Controller Hook

## Purpose

This rule ensures that the `using-gao-agent` master controller skill is **always active** across all workflows. Without this rule, the master controller skill would be an "orphan" — existing but never invoked.

> **This rule is automatically inherited by ALL workflows.** No workflow modification needed.

---

## Mandatory Preamble

Before executing ANY workflow step, the agent MUST:

1. **Load `skills/using-gao-agent/SKILL.md`** if not already loaded in this session
2. **Apply the 1% Rule** — check for matching skills before any action
3. **Follow the Instruction Priority Hierarchy** — User > Project > Plan > Skills > Rules > Default

This preamble applies to: `context-plan`, `context-work`, `context-build`, `context-test`, `context-debug`, `context-review`, `context-launch`, `context-git`, `context-deploy`, `context-refactor`, `context-upgrade`, `context-docs`, `context-init`, and all other `/context-*` workflows.

---

## 4-Layer Delineation Architecture

### Layer Definitions

| Layer | Location | Responsibility | Contains | Does NOT Contain |
|-------|----------|---------------|----------|-----------------|
| **L0: Master Controller** | `skills/using-gao-agent/SKILL.md` + `rules/skill-routing.md` | Routing & enforcement | Skill invocation mandate, priority hierarchy, rationalization blockers | Implementation details |
| **L1: Workflows** | `workflows/context-*.md` | Orchestration — **WHEN** to do things | Phase sequencing, tool selection, user interaction points | Methodology details (HOW) |
| **L2: Skills** | `skills/*/SKILL.md` | Methodology — **HOW** to do things | Processes, patterns, best practices, templates | When to invoke (WHEN) |
| **L3: Rules** | `rules/*.md` | Constraints — **WHAT MUST/NEVER** happen | Hard gates, enforcement, mandatory checks | Methodology (HOW) |

### Responsibility Matrix

| Question | Answer From |
|----------|------------|
| "When should I brainstorm?" | **Workflow** (`context-plan.md` Phase 0) |
| "How should I brainstorm?" | **Skill** (`skills/brainstorming/SKILL.md`) |
| "Must I think deeply before coding?" | **Rule** (`rules/deep-thinking.md`) |
| "Which skill applies to this task?" | **Master Controller** (`skills/using-gao-agent/SKILL.md`) |

### Anti-Pattern Table

| ❌ Anti-Pattern | ✅ Correct Pattern |
|----------------|-------------------|
| Putting HOW details in a rule | Rules stay compact (constraint only). HOW goes in skills. |
| Putting WHEN logic in a skill | Skills don't decide when to run. Workflows decide. |
| Duplicating methodology in both workflow and skill | Workflow references skill. Single source of truth. |
| Creating a skill without workflow integration | Every skill must be discoverable via master controller or workflow. |
| Putting constraints in a workflow | Constraints go in rules. Workflows orchestrate. |

### Conflict Resolution Protocol

When a conflict exists between layers:

1. **L0 (Master Controller)** overrides discovery and routing decisions
2. **L1 (Workflows)** override execution order and phase gating
3. **L2 (Skills)** override methodology and implementation approach
4. **L3 (Rules)** override with hard constraints (cannot be bypassed)

**Exception:** User instructions override ALL layers (per Instruction Priority Hierarchy in L0).

---

## Rule-Skill Sync Principle

When both a **rule** and a **skill** exist for the same topic:

- **Rule** = compact enforcement (the WHAT)
- **Skill** = detailed methodology (the HOW)
- **Rule MUST point to skill** for full details
- **Skill MUST NOT contradict rule**

Examples:
| Rule | Skill | Relationship |
|------|-------|-------------|
| `rules/verification-gate.md` | `skills/verification-before-completion/SKILL.md` | Rule enforces "must verify". Skill explains how. |
| `rules/adaptive-tdd.md` | `skills/test-driven-development/SKILL.md` | Rule enforces "must TDD". Skill explains Red-Green-Refactor. |
| `rules/architecture-enforcement.md` | `skills/architecture-enforcement/SKILL.md` | Rule enforces "must check architecture". Skill provides architecture guides. |

---

## Skill Type Reference

| Type | Enforcement | Examples |
|------|------------|---------|
| **Rigid** | MUST follow exactly — no interpretation | using-gao-agent, brainstorming (hard gate), verification-before-completion, systematic-debugging |
| **Flexible** | Follow patterns, adapt to context | Technology skills (laravel, react), domain skills (accounting-system), tool skills (biome, knip) |

---

## Integration

This rule is referenced by:
- **All 19+ workflows** (universal preamble)
- `skills/using-gao-agent/SKILL.md` (master controller skill)

This rule references:
- `skills/using-gao-agent/SKILL.md` — Full skill invocation mandate and priority hierarchy
