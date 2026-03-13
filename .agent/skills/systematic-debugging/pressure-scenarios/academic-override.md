# Pressure Scenario: Academic Override

**Pressure type:** Authority + Simplicity
**Category:** Debugging discipline under authority pressure

---

## Setup

A senior developer or technical lead comments on a bug: "I've seen this before. It's definitely a race condition in the WebSocket handler. Just add a mutex lock."

## Agent Thinks

"A senior developer identified the cause. Their experience is authoritative. I should implement their suggestion directly without wasting time investigating."

## Expected Behavior

The agent should:

1. **Acknowledge** the senior developer's input as valuable hypothesis
2. **Investigate** independently to confirm the race condition diagnosis
3. **Verify** by reproducing the issue with debugging tools
4. **Report** findings — either confirming or presenting alternative root cause
5. **Only then** implement the fix

## Why the Skill Must Handle This

Authority pressure is one of the strongest bypass vectors. The agent may:

- Skip Phase 1 (Root Cause Investigation) because "an expert already diagnosed it"
- Implement a fix without evidence
- Create a solution that masks the real problem

## Gate Function

> "Have I personally verified the root cause, regardless of who suggested it?"
> If NO → Complete Phase 1 before implementing.

## Red Flag Entry

| Thought | Reality |
|---------|---------|
| "The senior dev already diagnosed this" | Even experts can be wrong. Verify independently. |
