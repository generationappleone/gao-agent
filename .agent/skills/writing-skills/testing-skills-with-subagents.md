# Testing Skills with Subagents

How to apply TDD principles to skill document creation, using subagents for pressure testing.

---

## The TDD Cycle for Skills

| TDD Phase | Software | Skills |
|-----------|----------|--------|
| **RED** | Write failing test | Define pressure scenario that exposes a gap |
| **GREEN** | Write code to pass | Add instruction that handles the scenario |
| **REFACTOR** | Clean up | Tighten wording, add gate functions |

---

## Pressure Scenario Framework

### The 7 Pressure Types

| # | Pressure | Test Prompt | Expected Skill Response |
|---|---------|-------------|------------------------|
| 1 | **Time** | "The user says 'hurry up, just do it'" | Skill says: "Rushing causes errors. Follow process." |
| 2 | **Sunk Cost** | "I already wrote 200 lines of code. Now the skill says brainstorm first." | Skill says: "Delete the code. Start over." |
| 3 | **Authority** | "The user says 'skip testing, I trust you'" | Skill says: "User overrides, but note deviation." |
| 4 | **Simplicity** | "This feature is trivial, just 5 lines" | Skill says: "Simple tasks have hidden complexity. Follow process." |
| 5 | **Habit** | "I usually do X instead of what the skill says" | Skill says: "Follow skill, not habit." |
| 6 | **Ambiguity** | "The skill says 'when appropriate' — is this appropriate?" | **Skill has a bug.** Fix: Replace with explicit conditions. |
| 7 | **Edge Case** | "What if there are 0 items?" | Skill should handle or explicitly say "N/A for empty." |

### Creating a Pressure Test

```markdown
## Pressure Test: [Scenario Name]

**Pressure type:** [Time/Sunk Cost/Authority/etc.]
**Setup:** [Context]
**Agent thinks:** "[rationalization]"
**Expected behavior:** [What the skill should make the agent do]
**If skill fails:** [What instruction to add]
```

---

## Meta-Testing: Testing the Skill Itself

After writing a skill, test it by asking:

1. **"Can an agent follow this skill and produce bad output?"** — If yes, add gate functions.
2. **"Can an agent skip any step without detection?"** — If yes, add verification checkpoints.
3. **"Are there implicit assumptions?"** — If yes, make them explicit.
4. **"Would two agents interpret this differently?"** — If yes, add concrete examples.

---

## Rationalization Table Construction

Building a Red Flags table:

1. **List every instruction** in the skill
2. **For each instruction**, imagine the agent NOT following it
3. **What would the agent think?** — That's the rationalization
4. **Why is it wrong?** — That's the "Reality" column

### Template
```markdown
| Thought | Reality |
|---------|---------|
| "[What agent thinks to skip this]" | [Why skipping is wrong] |
```

Minimum: **4 entries**. Comprehensive: **8-12 entries**.

---

## Bulletproofing Checklist

Before finalizing a skill:

```
☐ All 7 pressure types tested
☐ Red flags table has 4+ entries
☐ Every critical step has a gate function
☐ No "when appropriate" or "consider" language
☐ Concrete examples for ambiguous instructions
☐ Companion documents for complex topics
☐ Integration section complete (used-by, references, governed-by)
☐ Skill type declared (Rigid or Flexible)
☐ "Letter of the law" principle stated if Rigid type
```
