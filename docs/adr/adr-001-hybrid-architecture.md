# ADR-001: Hybrid Architecture — GSD + Super Compound

**Date:** 2026-02-19
**Status:** Accepted
**Author:** GAO Agent Team

## Context

When designing the GAO Agent framework, we needed to choose an architecture approach for the AI coding agent. Two established frameworks were evaluated:

1. **GSD (Get Stuff Done)** — A framework focused on state management, session/checkpoint patterns, planning verification, and multi-agent orchestration.
2. **Super Compound (SC)** — A framework focused on an extensive skill library, workflow automation, and rule enforcement.

Each framework had distinct strengths and weaknesses. We needed to determine the best approach for production-grade AI-assisted software development.

## Decision

We adopted a **hybrid architecture** combining the best of both frameworks:

| Component | Source | Rationale |
|-----------|--------|-----------|
| **Skill Library** (WHAT to do) | Super Compound | SC's skill library is broader, more structured, and more practical for real-world development |
| **State/Session/Checkpoint** (WHERE you are) | GSD | GSD's memory system (ERROR_LOG, LEARNED_KNOWLEDGE) provides superior context continuity |
| **Planning Verification** (HOW to validate) | GSD | GSD's verification gates and deep thinking protocol ensure higher quality output |
| **Multi-Agent Architecture** | **Skipped** | GSD's multi-agent orchestration adds complexity without proportional benefit in this context |

## Alternatives Considered

| Alternative | Pros | Cons | Why Not |
|-------------|------|------|---------|
| Pure GSD | Strong verification, good memory | Limited skill library, multi-agent overhead | Skill coverage too narrow |
| Pure Super Compound | Massive skill library, good workflows | No persistent memory, weaker verification | Lacks learning and quality gates |
| Build from scratch | Full control, custom design | Enormous effort, no proven patterns | Reinventing the wheel |

## Consequences

### Positive
- 364 production-ready skills providing comprehensive technology coverage
- Self-learning memory system that prevents repeated mistakes
- Rigorous verification gates that ensure code quality
- Simpler single-agent model reduces complexity
- Broader compatibility with different AI platforms

### Negative
- No support for parallel multi-agent task execution
- Maintaining hybrid architecture requires understanding both source frameworks
- Some redundancy between rules and skills needs careful priority management

### Neutral
- Architecture is extensible — multi-agent support can be added later if needed
- The hybrid approach requires clear documentation of which pattern comes from which source
