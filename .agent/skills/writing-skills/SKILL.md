---
name: writing-skills
description: "Meta-skill for creating high-quality AI agent skills. Covers TDD for process documentation, skill types, testing methodology, and bulletproofing against loopholes."
---

# Writing Skills — Meta-Skill for Skill Creation

## Overview

This meta-skill teaches how to create new skills that are effective, bulletproof, and testable. Writing a skill is fundamentally **TDD for process documentation** — you define expected behavior, then write the instructions to produce it.

**Announce:** "Using writing-skills to create a new skill file."

## Phase 0: Understand the Domain

Before writing, deeply understand:

1. **What problem does this skill solve?** — Not "what does it do", but "what goes wrong without it?"
2. **Who is the audience?** — An AI agent, a human developer, or both?
3. **What are the failure modes?** — How can this skill be misinterpreted or bypassed?

## Phase 1: Skill Design (RED — Define Expected Behavior)

### 1.1 Define the Skill Type

| Type | Enforcement | Examples |
|------|------------|---------|
| **Rigid** | MUST follow exactly — hard gates, no interpretation | brainstorming, verification-before-completion |
| **Flexible** | Follow patterns, adapt to context | laravel, react, postgresql |

### 1.2 Define the Gate Functions

For each critical instruction, write a **gate function** — a yes/no question that prevents skipping:

```markdown
> Before [action], ask: "[gate question]?"
> If NO → [enforcement action]
```

Example:
```markdown
> Before writing code, ask: "Has the design been approved?"
> If NO → STOP. Return to brainstorming phase.
```

### 1.3 Define the Red Flags Table

Write rationalization blockers — thoughts the agent might have that would lead to skipping the skill:

| Thought | Reality |
|---------|---------|
| "[rationalization]" | [why it's wrong] |

**Rule of thumb:** Write at least 4 entries. If you can only think of 2, you haven't explored enough failure modes.

## Phase 2: Skill Implementation (GREEN — Write the Instructions)

### 2.1 Structure

Every skill MUST follow this structure:

```yaml
---
name: skill-name
description: "One-line description starting with 'Use when...'"
---

# Skill Title

## Overview
[What this skill does, when to use it]

## [Phases/Steps]
[The core methodology]

## Red Flags
[Rationalization blocker table]

## Integration
[How this skill connects to others]
```

### 2.2 Writing Principles

1. **Command, don't suggest** — "Do X" not "Consider doing X"
2. **Concrete, not abstract** — Include code examples, exact commands
3. **Sequential, not parallel** — Steps in order, no "also consider"
4. **Gate-driven** — Each critical step has a gate function
5. **Anti-pattern paired** — Each instruction paired with what NOT to do

### 2.3 Progressive Disclosure

Structure content from simple to complex:

```
Phase 0: Quick assessment (do I even need this?)
Phase 1: Core process (the main loop)
Phase 2: Advanced patterns (edge cases, optimizations)
Phase 3: Integration (how this connects to other skills)
```

## Phase 3: Bulletproofing (REFACTOR — Close Loopholes)

### 3.1 Pressure Testing

For each instruction, apply these 7 pressure types:

| # | Pressure Type | Test Question |
|---|--------------|---------------|
| 1 | **Time pressure** | "If the agent is in a hurry, will it skip this step?" |
| 2 | **Sunk cost** | "If the agent has already started coding, will it go back?" |
| 3 | **Authority** | "If the user says skip this, what happens?" |
| 4 | **Simplicity** | "If the task seems simple, will this step be skipped?" |
| 5 | **Habit** | "Does this step fight against common AI patterns?" |
| 6 | **Ambiguity** | "Could this instruction be interpreted differently?" |
| 7 | **Edge case** | "What happens when [unusual situation]?" |

### 3.2 Loophole Closure

For each vulnerability found in pressure testing:

1. **Add explicit instruction** — Close the gap
2. **Add to Red Flags table** — The rationalization that would trigger it
3. **Add gate function** — A check that prevents it

### 3.3 The "Letter of the Law" Principle

> **"Violating the letter of the rules is violating the spirit of the rules."**

If you find that an agent could "technically" follow the skill while producing bad output, your skill has a loophole. Close it.

## Phase 4: Companion Documents

Complex skills should include companion documents:

| Document Type | Purpose | Example |
|--------------|---------|---------|
| **Examples** | Reference implementations | `examples/CLAUDE_MD_TESTING.md` |
| **Anti-patterns** | What NOT to do | `testing-anti-patterns.md` |
| **Techniques** | Deep-dive on specific methods | `root-cause-tracing.md` |
| **Prompts** | Templates for subagent dispatch | `implementer-prompt.md` |

## Phase 5: Integration Declaration

Every skill MUST declare its connections:

```markdown
## Integration

**This skill is used by:**
- [parent skills/workflows that invoke this]

**This skill references:**
- [child skills/documents this uses]

**This skill is governed by:**
- [rules that constrain this skill]
```

## Supporting Documents

| Document | Content |
|----------|---------|
| `anthropic-best-practices.md` | Progressive disclosure patterns, workflow loops, evaluation-driven development |
| `testing-skills-with-subagents.md` | TDD cycle for skills, pressure scenarios, rationalization table construction |
| `persuasion-principles.md` | 7 Cialdini principles applied to skill design |
| `examples/CLAUDE_MD_TESTING.md` | 4 test scenarios with success criteria |

## Phase 6: Distributable Skills (Optional)

When creating skills intended for external distribution (publishable via `npx skills add` or shared across projects):

### YAML Frontmatter Optimization

Optimize the frontmatter for AI discoverability:

```yaml
---
name: my-skill
description: "Use when [exact trigger]. [One-line of what it does]."
version: "1.0.0"
tags: [category, technology, pattern]
requires: [dependency-skill-1, dependency-skill-2]
---
```

### Quick Start Section

Distributable skills MUST include a quick start:

```markdown
## Quick Start

1. Install: `npx skills add my-skill`
2. Read: `.agent/skills/my-skill/SKILL.md`
3. Use: [one-line example of how to invoke]
```

### Version-Specific Docs

Reference specific library/framework versions:

```markdown
> **Tested with:** React 19.x, Next.js 15.x, Node.js 22.x
> For older versions, see [migration notes below].
```

## Red Flags

| Thought | Reality |
|---------|---------|
| "This skill is obvious, no need for gate functions" | Gate functions prevent subtle bypasses. Always include them. |
| "4 red flags is enough" | If you can't find more, you haven't done enough pressure testing. |
| "The agent will understand what I mean" | Ambiguity is the enemy. Be explicit. |
| "This edge case won't happen" | If you thought of it, it will happen. |
| "Companion docs are overkill" | Complex skills need supporting documents for depth. |

## Integration

**This skill is used by:**
- Any agent creating new skills in `.agent/skills/`
- Developers packaging skills for distribution

**This skill references:**
- `anthropic-best-practices.md` — AI-specific writing techniques
- `testing-skills-with-subagents.md` — Skill testing framework
- `persuasion-principles.md` — Persuasion principles for AI instructions
- `examples/CLAUDE_MD_TESTING.md` — Test scenario examples
