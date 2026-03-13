# Anthropic Best Practices for Skill Design

Adapted patterns from AI instruction engineering for writing effective agent skills.

---

## Progressive Disclosure

Structure instructions from simple to complex. Don't frontload all rules — let the agent build understanding:

```
Level 1: The ONE thing that matters most  → Put in first paragraph
Level 2: Core process steps              → Phase 1-3
Level 3: Edge cases and exceptions       → Later sections
Level 4: Integration and meta-info       → End of document
```

### Application to Skills

```markdown
## Overview           ← Level 1: What and why
## The Process        ← Level 2: Core methodology
## Advanced Patterns  ← Level 3: Edge cases
## Red Flags          ← Level 3: Anti-patterns
## Integration        ← Level 4: Connections
```

---

## Workflow Loops and Feedback

Effective skills create **feedback loops** — the agent can self-correct:

### Self-Check Pattern
```markdown
After [step], verify:
- [ ] [condition 1]
- [ ] [condition 2]
If any fail → go back to [previous step].
```

### Iteration Limit Pattern
```markdown
Max [N] iterations. If not converged → escalate to user.
```

### Evidence Pattern
```markdown
Before claiming [X], show the evidence:
- Run [command]
- Show output
- Only then proceed
```

---

## Evaluation-Driven Development

Design skills by defining what "good output" looks like first:

1. **Define success criteria** — What does following this skill correctly look like?
2. **Define failure criteria** — What does violating this skill look like?
3. **Write instructions** — Instructions that produce success and prevent failure
4. **Test** — Apply pressure types, check if success criteria still hold

---

## Anti-Patterns in Skill Writing

| Anti-Pattern | Why It Fails | Better Approach |
|-------------|-------------|----------------|
| "Consider doing X" | Agent may not consider it | "Do X" |
| "When appropriate" | Agent decides what's appropriate | Define exact conditions |
| "Use your judgment" | Judgment varies by context | Provide decision table |
| "Be careful about X" | Doesn't specify HOW to be careful | "Before X, check Y. If Z, then W." |
| Long paragraphs | Agent may skip or summarize | Bullet points, tables, checklists |
| Abstract principles | Hard to apply in practice | Concrete examples with code |

---

## Executable Scripts Pattern

When a skill involves terminal commands:

```markdown
### Step N: [Action]
// turbo
```bash
[exact command]
```
Expected output: [what success looks like]
If error: [what to do]
```

The `// turbo` annotation signals safe auto-run. Include expected output so the agent can verify success.

---

## Checklist: Writing Effective Instructions

```
☐ First paragraph explains WHAT and WHY (not HOW)
☐ Each step is a single action (not compound)
☐ Commands are exact (no placeholders without definition)
☐ Expected output is specified
☐ Error handling is included
☐ Gate functions prevent critical bypasses
☐ Red flags table has 4+ entries
☐ Integration section declares connections
☐ No "consider" or "when appropriate" — explicit conditions
```
