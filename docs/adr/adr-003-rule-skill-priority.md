# ADR-003: Skill vs Rule Priority System

**Date:** 2026-02-19
**Status:** Accepted
**Author:** GAO Agent Team

## Context

With 17 mandatory rules and 364 skills, conflicts can arise when a skill recommends a practice that contradicts a rule. We needed a clear priority hierarchy.

## Decision

**Rules ALWAYS win over Skills.**

| Layer | Type | Priority | Enforcement |
|-------|------|----------|-------------|
| 1 | **Rules** (`.agent/rules/`) | HIGHEST — Mandatory constraints | Non-negotiable, applied to ALL code |
| 2 | **Skills** (`.agent/skills/`) | HIGH — Implementation guides | Best practices for HOW to follow rules |
| 3 | **Workflows** (`.agent/workflows/`) | MEDIUM — Process automation | Orchestrate rules + skills into processes |

### Example Conflict Resolution:
- **Rule** `database-design.md` says: "UUID primary keys, never auto-increment"
- **Skill** `wordpress/SKILL.md` shows WordPress using auto-increment IDs
- **Resolution:** Rule wins. Agent wraps WordPress ID usage but stores UUIDs for public-facing identifiers.

## Alternatives Considered

| Alternative | Pros | Cons | Why Not |
|-------------|------|------|---------|
| Skills override rules | Flexible per-technology | Inconsistent security posture | Security rules must be universal |
| Equal priority | Simple model | Ambiguous conflict resolution | Leads to inconsistent behavior |
| Per-file priority tags | Granular control | Complex to maintain | Over-engineering |

## Consequences

### Positive
- Security and quality rules are guaranteed across all technologies
- Clear conflict resolution — no ambiguity
- Skills can be updated independently without affecting rule enforcement

### Negative
- Some technology-specific idioms may conflict with rules
- Agent must understand both rule and skill to resolve correctly

### Neutral
- The priority system is documented in AGENTS.md for explicit reference
