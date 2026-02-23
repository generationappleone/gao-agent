# ADR-002: Self-Learning Memory System

**Date:** 2026-02-19
**Status:** Accepted
**Author:** GAO Agent Team

## Context

AI coding agents tend to repeat the same mistakes across conversations because each session starts with no memory of past errors. Additionally, user preferences are not retained between sessions, resulting in the agent repeatedly misunderstanding user expectations.

We needed a mechanism for the agent to persistently learn from mistakes and capture user preferences.

## Decision

We implemented a **dual-file memory system** stored in `.agent/memory/`:

| File | Purpose | Trigger |
|------|---------|---------|
| `ERROR_LOG.md` | Logs all mistakes with root cause analysis and prevention rules | After any mistake is identified |
| `LEARNED_KNOWLEDGE.md` | Captures user preferences, communication style, and project conventions | After observing repeated user patterns |

### Key Design Decisions:
- **Markdown format** — Human-readable, version-controllable, easily searchable
- **Structured entries** — Each entry has Date, Category, Severity, Root Cause, and Prevention Rule
- **Pre-task protocol** — Agent MUST read both files before starting ANY task
- **Append-only** — New entries are appended; old entries are never deleted (only archived)
- **Cross-conversation persistence** — Files persist on the filesystem across all conversations

## Alternatives Considered

| Alternative | Pros | Cons | Why Not |
|-------------|------|------|---------|
| Database storage | Structured queries, scalable | Requires DB setup, not human-readable | Over-engineering for the use case |
| JSON files | Machine-parseable | Not human-readable, hard to review | Agent output is markdown-native |
| In-memory only | Fast access | Lost between sessions | Defeats the purpose of persistent learning |
| No memory | Simple | Repeats mistakes indefinitely | Unacceptable quality regression |

## Consequences

### Positive
- Agent learns from mistakes and never repeats logged errors
- User preferences are automatically applied across sessions
- Human-reviewable format enables manual curation
- Git-trackable changes enable audit trail

### Negative
- Files grow unbounded over time (mitigated by auto-pruning rule)
- Reading memory files adds latency to task startup
- Manual entries could introduce incorrect rules

### Neutral
- Memory quality depends on the accuracy of root cause analysis
- Pruning/archival strategy needed for long-term maintenance
