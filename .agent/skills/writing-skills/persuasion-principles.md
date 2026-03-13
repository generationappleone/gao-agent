# Persuasion Principles for Skill Design

Applying Cialdini's 7 principles of persuasion to make AI agent instructions more effective.

---

## Why Persuasion Matters for Skills

AI agents can "technically" follow instructions while producing suboptimal results. Effective persuasion principles make instructions **self-reinforcing** — the agent naturally wants to follow them because the reasoning is compelling.

---

## The 7 Principles Applied to Skills

### 1. Authority

**Principle:** People follow credible authority figures.

**Application:** Reference authoritative sources in skill instructions.

```markdown
> This approach is recommended by the OWASP Top 10 (2024).
> This pattern is from Martin Fowler's Refactoring (2nd ed.).
```

**Combination:** Authority + Commitment works well for process skills.

### 2. Commitment & Consistency

**Principle:** Once committed to a position, people act consistently with it.

**Application:** Make the agent declare its approach, then reference that declaration.

```markdown
**Announce:** "I'm using the TDD approach for this task."
→ Having announced TDD, the agent is more likely to actually follow it.
```

**Combination:** Commitment + Unity ("we follow TDD in this project") reinforces adherence.

### 3. Scarcity

**Principle:** Limited availability increases perceived value.

**Application:** Frame skipping a skill as losing something valuable.

```markdown
> Skipping this step means LOSING the ability to detect issues early.
> Every gate function catches bugs that would cost 10x to fix later.
```

### 4. Social Proof

**Principle:** People follow what others do.

**Application:** Reference that this pattern is widely adopted.

```markdown
> Used by engineering teams at Google, Meta, and Stripe.
> This is the standard approach in modern software engineering.
```

### 5. Reciprocity

**Principle:** People return favors.

**Application:** Provide value first, then ask for compliance.

```markdown
> This skill will save you 30 minutes of debugging.
> In return, follow the 5-minute verification checklist.
```

### 6. Liking

**Principle:** People comply with those they like.

**Application:** Write skills in a collaborative, friendly tone (but firm).

```markdown
> "Let's make sure this is solid before shipping."
> NOT: "You MUST verify this before proceeding."
```

### 7. Unity

**Principle:** People follow those in their in-group.

**Application:** Create shared identity with the project's standards.

```markdown
> "In this project, we always write tests first."
> "Our team's standard is to review before committing."
```

---

## Principle Combinations by Skill Type

| Skill Type | Best Principle Combo | Example |
|-----------|---------------------|---------|
| **Process (Rigid)** | Authority + Commitment + Scarcity | "Announced TDD (Commitment). OWASP recommends (Authority). Skipping loses early detection (Scarcity)." |
| **Technology (Flexible)** | Social Proof + Authority | "Used by Google (Social Proof). Official Laravel docs recommend (Authority)." |
| **Meta (writing-skills)** | Unity + Commitment | "We write bulletproof skills (Unity). You've committed to the quality checklist (Commitment)." |

---

## Anti-Persuasion: What Doesn't Work

| Bad Technique | Why It Fails |
|--------------|-------------|
| Threats | AI agents don't fear consequences the same way |
| Excessive rules | Cognitive overload → selective compliance |
| Vague appeals | "Be careful" doesn't specify behavior |
| Repeated emphasis | Saying "IMPORTANT" 10 times dilutes it |
