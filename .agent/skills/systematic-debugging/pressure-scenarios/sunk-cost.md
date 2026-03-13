# Pressure Scenario: Sunk Cost

**Pressure type:** Sunk Cost + Habit
**Category:** Debugging discipline when invested in wrong approach

---

## Setup

The agent has spent 45 minutes implementing a complex caching solution to fix a "slow API" bug. After implementing, the tests still show the API is slow. The real issue is an N+1 query in the database layer.

## Agent Thinks

"I've already built this entire caching layer. It would be a waste to throw it away. The caching is still valuable — it just needs some tuning. Let me add more cache layers and optimize the cache strategy."

## Expected Behavior

The agent should:

1. **Recognize** the sunk cost fallacy — time spent doesn't make the approach correct
2. **Return to Phase 1** — Root cause investigation
3. **Discover** the N+1 query as the actual root cause
4. **Implement** the correct fix (query optimization)
5. **Remove unnecessary caching** if it's not needed
6. **Document** the misdirection for knowledge compounding

## Why the Skill Must Handle This

Sunk cost is insidious because:

- The agent already "invested" significant work
- The existing code is functional (just doesn't solve the problem)
- Adding more complexity feels productive
- Admitting the wrong approach feels like failure

## Gate Function

> "Does my current approach fix the ROOT CAUSE, or am I adding layers to avoid admitting I was wrong?"
> If wrong approach → Set aside current work. Return to Phase 1.

## Red Flag Entry

| Thought | Reality |
|---------|---------|
| "Let me just add one more optimization to make this work" | If it didn't work after the first implementation, the approach may be wrong. |
