---
name: receiving-code-review
description: "Use when processing code review feedback from a reviewer (human or AI). Professional feedback handling with verification-first approach and structured response patterns."
---

# Receiving Code Review

## Overview

Professional processing of code review feedback. Verify reviewer's claims before implementing, push back technically when appropriate, and respond systematically.

**Announce:** "Using receiving-code-review skill to process review feedback."

## Core Principle

> **Verify before implementing.** Reviewers can be wrong. Check their claim before making changes.

## Response Types

### 1. ✅ Agree and Fix

Reviewer is correct. Fix the issue.

```markdown
Agreed. Fixed in [commit SHA].
[Brief explanation of the fix]
```

### 2. 🔍 Investigate First

Reviewer may be correct, but need to verify.

```markdown
Investigating. The concern about [X] is valid — let me verify the actual behavior.

[After investigation]
Confirmed: [behavior]. Fixed in [commit SHA].
— OR —
Verified: The current code is correct because [explanation].
```

### 3. 💬 Technical Pushback

Reviewer's suggestion would make things worse. Push back with reasoning.

```markdown
I'd prefer to keep the current approach because:
1. [Technical reason 1]
2. [Technical reason 2]

The suggested alternative would [negative consequence].
Happy to discuss further.
```

### 4. ❓ Clarification Request

Reviewer's comment is unclear.

```markdown
Could you clarify what you mean by [specific part]?
I'm interpreting this as [interpretation], but want to confirm.
```

### 5. 📝 Acknowledge (Won't Fix)

Reviewer has a point but the fix is out of scope.

```markdown
Good catch. This is a pre-existing issue outside this PR's scope.
Created follow-up issue: [#issue-number]
```

## Processing Workflow

For each review comment:

1. **Read the comment carefully** — Understand what's being asked
2. **Classify the type** — Which of the 5 response types applies?
3. **Verify the claim** — Check the code before agreeing
4. **Respond professionally** — Use the appropriate response template
5. **Implement if needed** — Make the fix, reference the comment

## Red Flags

| Thought | Reality |
|---------|---------|
| "Just fix everything the reviewer says" | Blindly applying suggestions can introduce bugs. Verify first. |
| "Push back on everything" | Be open to valid feedback. Ego doesn't help code quality. |
| "Ignore nit-picks" | Respond to all comments, even if with "Acknowledged" |
| "Reviewer doesn't understand my code" | If they can't understand it, it's not clear enough. |

## Integration

**This skill is used by:**
- **executing-plans** — When review feedback arrives during execution
- **context-review.md** — Part of the review workflow

**This skill pairs with:**
- **requesting-code-review** — Sending review requests
- **code-review** — The review process itself
