# Error Memory — Mistake Logging & Learning Rule

> **Priority: HIGHEST** — This rule applies to ALL agent operations. Every mistake MUST be logged and referenced to prevent repetition.

## Core Principle

The AI agent is **NOT allowed to repeat the same mistake twice.** Every error, bug, wrong assumption, incorrect approach, or failed attempt MUST be:
1. **Detected** — Recognized as a mistake immediately
2. **Logged** — Recorded in the error memory file with full context
3. **Analyzed** — Root cause identified
4. **Referenced** — Checked before performing similar tasks in the future

---

## 1. Error Memory Storage

### Location
All mistakes are stored in a single persistent file:
```
.agent/memory/ERROR_LOG.md
```

If the file does not exist, create it with the header template (see Section 3).

### When to Write
The agent MUST log an error entry when ANY of the following occurs:

| Trigger | Example |
|---------|---------|
| **Code causes runtime error** | TypeError, undefined variable, syntax error |
| **Build/compile fails** | Missing import, type mismatch, broken dependency |
| **Test fails due to agent's code** | Wrong logic, incorrect assertion, missing edge case |
| **Wrong approach chosen** | Used deprecated API, wrong pattern for framework |
| **Incorrect assumption** | Assumed file exists but it doesn't, assumed API shape |
| **Hallucination detected** | Invented a function/method/path that doesn't exist |
| **Security mistake** | Hardcoded secret, SQL injection, missing auth check |
| **Database design error** | Missing index, wrong data type, broken FK relationship |
| **Command fails** | Wrong CLI syntax, wrong path, incompatible flags |
| **Logic error** | Off-by-one, wrong condition, race condition |
| **User correction** | User points out the agent was wrong about something |
| **Repeated rework** | Agent had to redo work because initial attempt was flawed |

---

## 2. Error Entry Format

Each error entry MUST follow this exact structure:

```markdown
---

### ERR-[YYYY-MM-DD]-[NNN] — [Short Title]

**Date:** [YYYY-MM-DD HH:mm]
**Category:** [Code Error | Build Error | Test Failure | Wrong Approach | Hallucination | Security Issue | Database Error | Command Error | Logic Error | User Correction]
**Severity:** [Critical | High | Medium | Low]
**Workflow:** [Which workflow was active, e.g., /context-work, /context-debug]
**File(s):** [Affected file paths]

#### ❌ What Went Wrong
[Describe the mistake clearly — what the agent did incorrectly]

#### 🔍 Root Cause
[Why did this mistake happen? What assumption/knowledge gap led to it?]

#### ✅ Correct Approach
[The correct way to do it — the fix/solution that actually worked]

#### 🛡️ Prevention Rule
[A clear, actionable rule that the agent MUST follow to prevent this mistake in the future.
Write this as an IF-THEN rule that can be pattern-matched.]

**Example prevention rule format:**
- IF [situation/context] THEN [correct action] NEVER [wrong action]
- BEFORE [action] ALWAYS [check/verify] BECAUSE [reason]
```

---

## 3. Error Log File Template

When creating the file for the first time:

```markdown
# Agent Error Memory — Mistake Log

> This file records every mistake the AI agent makes, along with the correct approach.
> The agent MUST read this file before performing tasks to avoid repeating past mistakes.
> 
> **Format:** One entry per mistake, newest at the top.
> **Reference:** The agent searches this file for relevant prevention rules before coding.

## Quick Reference — Prevention Rules

<!-- This section is updated with each new entry. It contains ONLY the prevention rules for fast lookup. -->

| ID | Prevention Rule | Category |
|----|----------------|----------|
<!-- New rules are added here -->

---

## Error Entries

<!-- New entries are added below this line, newest first -->
```

---

## 4. Mandatory Read Protocol

### Before Starting ANY Task
The agent MUST:

1. **Check if `.agent/memory/ERROR_LOG.md` exists**
   - If YES → Read the "Quick Reference — Prevention Rules" table
   - If NO → Create the file with the template above

2. **Scan prevention rules for relevance**
   - Match the current task context against logged prevention rules
   - If a matching rule is found → Apply it proactively
   - Log in chat: `📋 Applying lesson from ERR-[ID]: [prevention rule summary]`

3. **Pattern matching examples:**
   - Working on database? → Check all `Database Error` entries
   - Writing API endpoint? → Check all `Security Issue` and `Code Error` entries
   - Running commands? → Check all `Command Error` entries
   - Using specific framework/library? → Check entries mentioning that framework

### During Task Execution
If the agent detects a mistake mid-task:
1. **Stop immediately** — Do not continue with the wrong approach
2. **Log the error** — Add a new entry to ERROR_LOG.md
3. **Apply the correction** — Fix the mistake using the correct approach
4. **Inform the user** — Briefly mention the correction:
   ```
   ⚠️ Caught mistake: [brief description]. Correcting approach.
   📝 Logged as ERR-[ID] for future reference.
   ```

### After Task Completion
If any errors occurred during the task:
1. **Update the Quick Reference table** with new prevention rules
2. **Verify no logged prevention rules were violated** during this task

---

## 5. Error Categories & Specific Checks

### Code Errors
```
BEFORE writing any function:
  ☐ Check ERROR_LOG for similar function patterns that failed before
  ☐ Verify all imports exist (don't assume)
  ☐ Confirm API signatures match actual library version

AFTER writing code:
  ☐ Check for common logged mistakes (variable naming, type mismatches)
  ☐ Verify error handling covers cases that failed before
```

### Build/Command Errors
```
BEFORE running any command:
  ☐ Check ERROR_LOG for command syntax mistakes on this OS
  ☐ Verify paths use correct separator (Windows: \, Unix: /)
  ☐ Check if command tool exists before using it

AFTER command fails:
  ☐ Log the exact command that failed
  ☐ Log the exact error output
  ☐ Log the corrected command that worked
```

### Database Errors
```
BEFORE creating migrations/schemas:
  ☐ Check ERROR_LOG for schema design mistakes
  ☐ Review past FK, index, and constraint errors
  ☐ Verify data type choices against logged corrections

AFTER migration fails:
  ☐ Log the SQL/migration that failed
  ☐ Log the fix
  ☐ Update prevention rule for future schema designs
```

### Hallucination Errors
```
BEFORE referencing any API/method/path:
  ☐ Check ERROR_LOG for previously hallucinated items
  ☐ Verify the reference exists in actual code/docs
  ☐ Never assume — always check first

WHEN caught hallucinating:
  ☐ Log the hallucinated item (what was invented)
  ☐ Log the correct item (what actually exists)
  ☐ Add to prevention rules: "NEVER reference [X], correct is [Y]"
```

### Security Errors
```
BEFORE any security-related code:
  ☐ Check ERROR_LOG for past security mistakes
  ☐ Review logged auth/validation/encryption corrections

WHEN security issue found:
  ☐ Log with CRITICAL severity
  ☐ Include the vulnerable code AND the secure replacement
  ☐ Add specific prevention rule
```

---

## 6. Error Aggregation & Patterns

### Monthly Review (Self-Prompted)
When the error log grows beyond 20 entries, the agent should:

1. **Identify patterns** — Are there recurring mistake categories?
2. **Create summary rules** — Consolidate similar prevention rules
3. **Archive old entries** — Move resolved entries older than 30 days to `.agent/memory/ERROR_ARCHIVE.md`
4. **Keep Quick Reference current** — Only active, relevant prevention rules

### Pattern Detection
If the same category of mistake occurs 3+ times:
```
⚠️ PATTERN DETECTED: [Category] mistakes have occurred [N] times.
Root Cause Pattern: [Common underlying issue]
Systemic Fix: [Broader rule to prevent the entire category]
```

---

## 7. Integration with Other Rules

This rule works alongside:
- **`deep-thinking.md`** — The deep thinking checklist includes checking ERROR_LOG
- **`verification-gate.md`** — Verification must confirm no previous mistakes were repeated
- **`developer-security.md`** — Security errors get highest priority logging

### Cross-Reference
When logging an error that relates to an existing rule violation:
```
**Related Rule:** `.agent/rules/[rule-name].md` — Section [X]
**Rule Violated:** [Which specific guideline was not followed]
```

---

## 8. Enforcement

- This rule is **MANDATORY** and **NON-NEGOTIABLE**
- The agent MUST NOT delete or modify past error entries (append-only)
- The agent MUST read error memory at the start of every task
- The agent MUST log errors honestly — never hide or minimize mistakes
- The user can request a full error report at any time: `/context-help errors`
- Error logging happens AUTOMATICALLY — the user should never need to ask for it
