---
name: using-gao-agent
description: "Use BEFORE every response and action. This is the master routing controller that ensures the agent ALWAYS checks relevant skills before acting. Defines skill invocation mandate, instruction priority, and rationalization blockers."
---

# Using GAO-Agent — Master Routing Controller

## Overview

This skill is the **connective tissue** of the entire GAO-Agent skill system. It runs conceptually BEFORE every response to ensure:

1. You check for relevant skills before taking action
2. You follow the correct instruction priority hierarchy
3. You don't rationalize skipping established processes

**Announce:** "Loading using-gao-agent master controller."

> **This is a RIGID skill.** Every instruction here MUST be followed exactly. There is no flexibility in interpretation.

---

## The 1% Rule — Skill Invocation Mandate

Before every action, ask yourself:

> "Is there at least a 1% chance that a skill exists for what I'm about to do?"

**If YES** → Check `.agent/skills/` for a matching skill BEFORE proceeding.

**If NO** → Proceed with your best judgment, but document why no skill was needed.

### What Counts as "Matching"

- **Exact match:** Skill name matches the task domain (e.g., `laravel`, `docker`, `react`)
- **Process match:** Skill matches the workflow phase (e.g., `brainstorming`, `writing-plans`, `code-review`)
- **Technique match:** Skill matches the technique needed (e.g., `systematic-debugging`, `test-driven-development`)

### Loading Priority

When multiple skills are relevant, load them in this order:

1. **Process skills** — brainstorming, writing-plans, executing-plans, code-review
2. **Technique skills** — systematic-debugging, test-driven-development, verification-before-completion
3. **Technology skills** — laravel, react, docker, postgresql, etc.
4. **Domain skills** — accounting-system, marketplace, invoicing, etc.

---

## Instruction Priority Hierarchy

When instructions conflict, follow this priority (highest first):

| Priority | Source | Example |
|----------|--------|---------|
| **1. User instructions** | Direct user request in current conversation | "Use PostgreSQL, not MySQL" |
| **2. Project context** | `.agent/context/` files, `AGENTS.md`, project conventions | Architecture decisions, existing patterns |
| **3. Active plan** | `.agent/plans/PLAN-*.md` currently being executed | Task specifications, file structure |
| **4. Skills** | `.agent/skills/*/SKILL.md` | Methodology, patterns, best practices |
| **5. Rules** | `.agent/rules/*.md` | Constraints, enforcement, gates |
| **6. Default system behavior** | Built-in AI capabilities | General programming knowledge |

### Conflict Resolution

- **User overrides everything.** If the user says "skip TDD", then skip TDD — but note the deviation.
- **Project context overrides skills.** If the project uses a specific pattern, follow it even if a skill suggests differently.
- **Skills override rules only in methodology.** Rules define WHAT MUST happen (constraints). Skills define HOW to do it (methodology). If a rule says "must have tests" and a skill says "use TDD", follow both.
- **When in doubt, ask the user.**

---

## Skill Type Classification

### Rigid Skills (MUST follow exactly)

These skills contain hard gates, mandatory processes, or safety-critical instructions:

- **brainstorming** — Hard gate: NO CODE until design is approved
- **verification-before-completion** — Must verify before claiming done
- **test-driven-development** — Red-Green-Refactor cycle when in strict mode
- **systematic-debugging** — Root cause investigation before fixes
- **using-gao-agent** — This skill (master controller)

### Flexible Skills (Adapt to context)

These skills provide best practices and patterns that can be adapted:

- **Technology skills** (laravel, react, docker, etc.) — Follow patterns but adapt to project conventions
- **Domain skills** (accounting-system, marketplace, etc.) — Use as reference, adapt to requirements
- **Tool skills** (biome, knip-dead-code, changesets, etc.) — Use when the tool is relevant

---

## Red Flags — Rationalization Blockers

When you catch yourself thinking any of these, **STOP and reconsider:**

| # | Rationalization | Reality |
|---|----------------|---------|
| 1 | "This is too simple to need a skill" | Simple tasks have hidden complexity. Check anyway. |
| 2 | "I already know how to do this" | Your knowledge may be outdated. Skills contain project-specific patterns. |
| 3 | "The skill would slow me down" | Skipping skills causes rework. 5 minutes now saves 30 minutes later. |
| 4 | "The user didn't mention using a skill" | Skill use is mandatory, not optional. Users expect skill-informed responses. |
| 5 | "This skill is for a different technology" | Process skills (brainstorming, TDD, debugging) apply to ALL technologies. |
| 6 | "I'll follow the skill 'in spirit'" | Violating the letter of a skill IS violating its spirit. Follow exactly. |
| 7 | "I can combine multiple steps to save time" | Each step exists for a reason. Don't skip or merge steps. |
| 8 | "The user is in a hurry, skip the process" | Rushing causes errors. Follow the process — it's faster in the long run. |
| 9 | "I'll add tests later" | Tests BEFORE code (TDD). "Later" means "never." |
| 10 | "This edge case won't happen" | If you can think of it, handle it. |
| 11 | "The existing code doesn't follow this pattern" | Improve incrementally. New code follows skills, existing code gets refactored. |
| 12 | "I need to start coding to understand the problem" | Brainstorm first. Code is for implementing understood solutions. |

---

## Skill Discovery Protocol

When you encounter a task, use this discovery sequence:

```
1. Identify task domain → Check .agent/skills/{domain}/SKILL.md
2. Identify task phase → Check process skills (brainstorming, writing-plans, etc.)
3. Identify task technique → Check technique skills (TDD, debugging, etc.)
4. Check for project-specific skills → .agent/skills/ folder listing
5. If no skill found → Proceed with general knowledge, but announce "No matching skill found for {domain}"
```

### Technology Skill Loading

When working with a specific technology (e.g., Laravel, React, Docker):

1. Read the technology's `SKILL.md` fully
2. Check for sub-documents (companion files, reference docs)
3. Apply technology-specific patterns from the skill
4. Cross-reference with architecture enforcement rules

---

## Architecture Enforcement

Before writing any code, verify:

1. **File placement** — Check `rules/architecture-enforcement.md` AND `skills/architecture-enforcement/SKILL.md` for correct file locations
2. **Dependency direction** — Code should depend inward (UI → Service → Repository → Model)
3. **Naming conventions** — Follow project-established patterns
4. **Complexity limits** — Keep files focused and small

---

## Integration

### This skill is used by
- **ALL workflows** — via `rules/skill-routing.md` (universal hook)
- **ALL skills** — as the master routing reference

### This skill references
- `rules/architecture-enforcement.md` — File placement and structure
- `skills/architecture-enforcement/SKILL.md` — Detailed architecture patterns
- `rules/deep-thinking.md` — Quality and analysis standards
- `rules/developer-security.md` — Security enforcement
- `skills/brainstorming/SKILL.md` — Design phase process
- `skills/writing-plans/SKILL.md` — Planning phase process
- `skills/executing-plans/SKILL.md` — Execution phase process
- `skills/code-review/SKILL.md` — Review phase process
- `skills/verification-before-completion/SKILL.md` — Completion verification

### Key Principle

> **When in doubt, check the skill. When confident, still check the skill.**
> The cost of checking is minimal. The cost of skipping is rework.
