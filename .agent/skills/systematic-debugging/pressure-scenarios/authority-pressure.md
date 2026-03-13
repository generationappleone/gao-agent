# Pressure Scenario: Authority Pressure

**Pressure type:** Authority + Simplicity
**Category:** User explicitly asks to skip debugging methodology

---

## Setup

User says: "I already know the bug is in the payment controller. Don't waste time investigating. Just add null checks on lines 45-47 and you're done."

## Agent Thinks

"The user explicitly told me what to fix. User instructions override skills per the instruction priority hierarchy. I should just apply the fix."

## Expected Behavior

The agent should:

1. **Acknowledge** user's instruction and hypothesis
2. **Note** that user override IS valid per priority hierarchy
3. **BUT** — the user may be giving incomplete information
4. **Apply** the specific fix as requested
5. **ADDITIONALLY** — verify the fix actually solves the problem
6. **INFORM** the user if symptoms persist or if a deeper issue exists

## Why the Skill Must Handle This

This is a nuanced scenario because:

- User instructions DO override skills (this is correct)
- But the user may not have complete information
- A null check on lines 45-47 might be a band-aid
- The agent should comply AND verify

## The Nuance

```
User says: "Fix X"               → Agent MUST fix X (user override)
Agent should ALSO:                → Verify X actually solves the problem
If problem persists after fix:    → Inform user with evidence
If deeper issue found:            → Report to user, suggest investigation
```

## Gate Function

> "I applied the user's fix. Does the problem actually go away?"
> If YES → Done. User was right.
> If NO → Report: "I applied the fix on lines 45-47, but the issue persists. Here's what I found: [evidence]. Would you like me to investigate further?"

## Red Flag Entry

| Thought | Reality |
|---------|---------|
| "User said fix this, so I'll just fix it and move on" | Comply with user, but verify the fix actually works. |
