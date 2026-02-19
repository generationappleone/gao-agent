# Verification Gate

## Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

This rule is **mandatory** and **non-negotiable**. It applies to ALL tasks, ALL agents, ALL scenarios.

## Gate Function

Before claiming any status or expressing satisfaction:

1. **IDENTIFY** — What command proves this claim?
2. **RUN** — Execute the FULL command (fresh, complete)
3. **READ** — Full output, check exit code, count failures
4. **VERIFY** — Does output confirm the claim?
   - If NO → State actual status with evidence
   - If YES → State claim WITH evidence
5. **CLAIM** — Only then make the claim

**Skip any step = lying, not verifying.**

## Verification Requirements

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags — Immediate Stop

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!")
- About to commit/push/PR without verification
- Trusting subagent or AI success reports without independent verification
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Agent said success" | Verify independently |
| "Different words so rule doesn't apply" | Spirit over letter |

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- Committing, PR creation, task completion
- Moving to next task in a plan
- Claiming a bug is fixed
- Delegating work to subagents
