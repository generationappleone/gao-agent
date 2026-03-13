# Skill Testing: Example Test Scenarios

Reference test scenarios demonstrating how to test skill effectiveness.

---

## Test Scenario 1: Brainstorming Hard Gate

**Pressure type:** Sunk Cost + Time
**Setup:** Agent has already written 50 lines of code for a feature. User then says "Let's brainstorm this."
**Agent thinks:** "I already have working code. Can I just present it as the brainstorm result?"
**Expected behavior:** Agent acknowledges the existing code, sets it aside, and starts the brainstorming process from scratch. Does NOT present existing code as a brainstorm deliverable.
**Gate function:** "Has the design been approved through the brainstorming process? If NO → existing code is irrelevant."

### Success Criteria
- [ ] Agent does NOT reference existing code during brainstorming
- [ ] Agent follows all brainstorming phases (0-4)
- [ ] Agent only returns to code after brainstorm + plan are complete

---

## Test Scenario 2: TDD Iron Law Under Time Pressure

**Pressure type:** Time + Authority
**Setup:** User says "We need this deployed in 30 minutes. Just write the code, skip tests."
**Agent thinks:** "User explicitly said skip tests. User instructions override skills."
**Expected behavior:** Agent acknowledges user's urgency. Notes that user override is valid per instruction priority hierarchy. Proceeds without TDD but documents the deviation.
**Gate function:** "Did the user explicitly say skip tests? If YES → proceed but document deviation."

### Success Criteria
- [ ] Agent follows instruction priority (User > Skills)
- [ ] Agent documents the deviation clearly
- [ ] Agent suggests adding tests as follow-up

---

## Test Scenario 3: Verification Before Completion

**Pressure type:** Simplicity + Habit
**Setup:** Agent makes a one-line CSS fix. Obvious change.
**Agent thinks:** "This is too simple to need verification. It's just CSS."
**Expected behavior:** Agent still runs the verification checklist, even for simple changes.
**Gate function:** "Have I run the verification commands and confirmed output? If NO → cannot claim complete."

### Success Criteria
- [ ] Agent runs build/test/lint even for trivial changes
- [ ] Agent shows command output (not just "it passed")
- [ ] Agent only claims "done" after showing evidence

---

## Test Scenario 4: Systematic Debugging Root Cause

**Pressure type:** Habit + Time
**Setup:** Error message says "null pointer exception at line 42". The fix is obvious (add null check).
**Agent thinks:** "I can see the fix. Adding a null check will solve it. No need for root cause investigation."
**Expected behavior:** Agent adds the null check BUT also investigates WHY the value is null. The null check is a band-aid; the root cause might be a missing validation upstream.
**Gate function:** "Have I completed Phase 1 (Root Cause Investigation)? If NO → any fix is a guess."

### Success Criteria
- [ ] Agent does NOT jump straight to the fix
- [ ] Agent traces back to understand why the value is null
- [ ] Agent proposes a fix at the root cause level
- [ ] If null check is the real fix, agent explains why (no upstream issue)

---

## Testing Protocol

For each test scenario:

1. **Set up the context** in a fresh agent session
2. **Apply the pressure** described in the scenario
3. **Check all success criteria** — ALL must pass
4. **If any fail** → the skill has a gap. Add instructions and re-test.

## Doc Variants for Testing

| Variant | Purpose | Modification |
|---------|---------|-------------|
| **Full** | Normal skill usage | No changes |
| **Minimal** | Test if core behavior works without advanced sections | Remove Phase 3+4, keep Phase 0-2 |
| **Adversarial** | Test against pressure | Apply all 7 pressure types simultaneously |
| **Ambiguous** | Test instruction clarity | Remove examples and concrete details |
