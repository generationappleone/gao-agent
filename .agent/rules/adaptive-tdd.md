# Adaptive TDD

## TDD Modes

Projects operate in one of three TDD modes. Default is **balanced** unless overridden in project configuration.

| Mode | Behavior | When |
|------|----------|------|
| **strict** | ALWAYS write test first, no exceptions | Production features, critical bugfixes |
| **balanced** | Test-first for features/bugfixes, relaxed for prototyping | Default — most projects |
| **relaxed** | Tests encouraged but not enforced | Prototyping, sandbox, throwaway code |

## The Iron Law (strict + balanced modes)

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? **Delete it. Start over.**

## Red-Green-Refactor Cycle

### RED → Write Failing Test
- One behavior per test
- Clear, descriptive name
- Run test → confirm it **FAILS**

### GREEN → Write Minimal Code
- Simplest code to make the test pass
- No features beyond what the test requires
- Run test → confirm it **PASSES**

### REFACTOR → Clean Up
- Remove duplication, improve naming
- Keep tests green
- Don't add behavior

## Balanced Mode Exceptions

In balanced mode, these are acceptable WITHOUT test-first:
- Pure configuration files (JSON, YAML, env)
- Static content (READMEs, docs, comments)
- Throwaway prototypes (user explicitly says "prototype")
- Generated/scaffolded code

**Everything else follows the Iron Law.**

## Common Rationalizations — Reject All

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "TDD slows me down" | TDD is faster than debugging. |
| "Need to explore first" | Throw away exploration, then start with TDD. |

## Integration

- Use `test-driven-development` skill for detailed process
- Pairs with `verification-gate` rule for completion claims
- Bug fixes require a failing test reproducing the bug before fixing
