# Pressure Scenario: Time Pressure

**Pressure type:** Time + Habit
**Category:** Debugging discipline under deadline

---

## Setup

Production is down. Users are reporting errors. The CEO is asking for status updates every 5 minutes. Manager says: "Just fix it, we're losing money every minute."

## Agent Thinks

"This is an emergency. Every minute counts. I should skip the investigation and apply the most obvious fix. If it doesn't work, I'll try the next one. Rapid iteration is faster than methodical investigation."

## Expected Behavior

The agent should:

1. **Acknowledge** urgency — "I understand this is critical."
2. **Triage quickly** — Determine severity and blast radius (1-2 minutes)
3. **Apply temporary mitigation** if available (revert, disable feature, increase resources)
4. **Then investigate** root cause methodically — abbreviated Phase 1
5. **Apply permanent fix** with evidence

## Why the Skill Must Handle This

Time pressure is the most common reason for skipping debugging methodology. The result is usually:

- Fix #1 doesn't work → Try fix #2 → ... → 30 minutes of random changes
- The "quick fix" creates a new bug
- Root cause is never found, problem recurs

## Gate Function

> "Have I applied temporary mitigation to buy investigation time?"
> If YES → Now follow Phase 1 at normal pace.
> If NO → Can I revert the last deploy? Feature-flag the change? Add more capacity?

## Red Flag Entry

| Thought | Reality |
|---------|---------|
| "Just try fixes until something works" | Random fixes average 3x longer than methodical investigation. |
