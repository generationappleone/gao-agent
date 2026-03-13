---
description: "Systematically diagnose and fix bugs with automatic knowledge capture. Replaces /context-compound for post-debug documentation."
---

# Context Debug — Systematic Debugging + Knowledge Capture (Unified)

## Purpose
This workflow provides a **structured, methodical approach** to diagnosing and fixing bugs. After the fix is verified, it **automatically captures the solution** as searchable documentation to prevent the same issue from recurring.

> **Replaces:** `/context-compound` — knowledge capture is now Phase 5 of this workflow.
> The agent follows TDD: write a failing test → find root cause → fix → verify test passes → document.

---

## Activation
The user triggers this workflow by:
- Using `/context-debug` followed by a description of the bug
- Using `/context-debug [error-message]` with the specific error
- Using `/context-compound` (alias — routes here, starts at Phase 5 for standalone documentation)
- Encountering errors, test failures, or unexpected behavior during development

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 0.5: Agent Lock Check (Race Condition Prevention)
// turbo
1. Check if `.agent/context/AGENT_LOCK` exists.
2. If it exists, STOP! Another agent is currently executing. Inform the user and abort.
3. If it does not exist, immediately create `.agent/context/AGENT_LOCK` with the current timestamp.
4. IMPORTANT: Meticulously delete `.agent/context/AGENT_LOCK` at the very end of this workflow OR whenever you pause to ask the user a question.

## Phase 1: Reproduce & Understand

### Step 1.1 — Load Debugging Skill
// turbo
Read `skills/systematic-debugging/SKILL.md` and follow its investigation protocol.

### Step 1.2 — Read Project Context
// turbo
```
1. .agent/context/CONTEXT_INDEX.md   ← Project overview
2. .agent/context/ARCHITECTURE.md    ← Understand component relationships
3. .agent/context/DATABASE_SCHEMA.md ← If data-related bug
4. .agent/context/API_REFERENCE.md   ← If API-related bug
5. .agent/rules/deep-thinking.md     ← Deep analysis & anti-hallucination (MANDATORY)
6. .agent/rules/developer-security.md ← Security awareness (MANDATORY)
```

### Step 1.3 — Collect Bug Information

Gather ALL available information:

```markdown
### 🐛 Bug Report

**Symptom:** [What the user sees/reports]
**Expected:** [What should happen]
**Actual:** [What actually happens]
**Frequency:** [Always / Sometimes / Once]
**Environment:** [Dev / Staging / Production]
**Since When:** [When did this start? Recent change?]

**Error Output:**
```
[Full error message, stack trace, log output]
```

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]
```

### Step 1.4 — Reproduce the Bug
// turbo

Attempt to reproduce the issue:

```bash
# Run the exact command/test that fails
npm test -- --grep "[test name]" 2>&1 | tail -50
# or
npm run dev 2>&1 | tail -50
# or run specific failing scenario
curl -s http://localhost:3000/api/[endpoint] 2>&1
```

**If reproducible:** → Continue to Phase 2
**If NOT reproducible:**
- Check environment differences (env vars, database state, dependencies)
- Check for race conditions or timing-dependent bugs
- Check logs for intermittent errors
- Ask user for additional reproduction steps

### Step 1.5 — Classify Bug Type

| Type | Characteristics | Investigation Focus |
|------|----------------|-------------------|
| **Build Error** | Won't compile/build | Dependencies, syntax, types |
| **Runtime Error** | Crashes during execution | Stack trace, exception handling |
| **Logic Error** | Wrong output, no crash | Business logic, conditions |
| **Data Error** | Corrupted/missing data | Database, migrations, queries |
| **Performance** | Slow, timeouts | Queries, algorithms, memory |
| **UI/Visual** | Layout broken, styling | CSS, responsive, components |
| **Integration** | Service communication | APIs, auth, network |
| **Regression** | Was working, now broken | Recent changes, dependencies |

---

## Phase 2: Investigate Root Cause

### Step 2.1 — Trace the Flow
// turbo

Follow the data/execution path from entry point to error:

```markdown
### Execution Trace

1. **Entry Point:** [Where the request/action starts]
   - Input: [What data enters]
   - Validation: [What checks occur]

2. **Flow Through Components:**
   - [Component A] → received [data], called [method]
   - [Component B] → processed [data], returned [result]
   - [Component C] → ⚠️ ERROR OCCURS HERE

3. **Root Cause Location:**
   - File: [path/to/file.ts]
   - Line: [line number]
   - Reason: [Why it fails]
```

### Step 2.2 — Check Recent Changes
// turbo

```bash
# What changed recently?
git log --oneline -20 2>&1
git diff HEAD~5 --stat 2>&1 | head -30

# Check if this file was recently modified
git log --oneline -5 -- [suspicious_file] 2>&1
```

### Step 2.3 — Check Dependencies & Environment
// turbo

```bash
# Check for dependency issues
npm ls --depth=0 2>&1 | grep "UNMET\|ERR\|invalid" | head -10

# Check environment variables
env | grep -i "DB\|API\|SECRET\|KEY\|NODE_ENV\|APP_" 2>&1 | head -20

# Check database connectivity (if data-related)
# [framework-specific commands]
```

### Step 2.4 — Search for Existing Solutions
// turbo

```bash
# Search existing solution docs
find docs/solutions -name "*.md" 2>/dev/null | head -20

# Search for similar issues in codebase comments
grep -rn "TODO\|FIXME\|HACK\|BUG\|WORKAROUND" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -20
```

Also search the web for the exact error message if it's from a library/framework.

### Step 2.5 — Form Hypothesis

```markdown
### Root Cause Hypothesis

**Primary Hypothesis:**
[Most likely cause based on evidence]
- Evidence: [What supports this]
- Confidence: [High / Medium / Low]

**Alternative Hypothesis (if primary is uncertain):**
[Alternative explanation]
- Evidence: [What supports this]
- Confidence: [High / Medium / Low]

**Testing approach:**
[How to verify which hypothesis is correct]
```

---

## Phase 3: Write Failing Test (TDD)

### Step 3.1 — Create a Test That Reproduces the Bug

**BEFORE writing ANY fix**, write a test that:
- Reproduces the exact bug scenario
- Currently FAILS (proves the bug exists)
- Will PASS once the fix is applied

```markdown
### Failing Test Created

File: `tests/[path]/[test-file].test.ts`
Test: `[test name]`
Status: ❌ FAILING (expected — proves bug exists)
```

// turbo
```bash
# Run the new test — it MUST fail
npm test -- --grep "[test name]" 2>&1 | tail -30
```

**If you can't write a test** (e.g., environment-specific, visual bug):
- Document WHY a test isn't possible
- Create a manual verification checklist instead
- Plan automated regression test for later

---

## Phase 4: Fix & Verify

### Step 4.1 — Apply the Fix

Based on the root cause analysis, implement the minimal fix:

**Rules for the fix:**
1. **Minimize changes** — Fix only the bug, don't refactor or add features
2. **Follow existing patterns** — Match the codebase style
3. **Apply rules** — Follow `developer-security.md`, `solid-principles.md`
4. **Handle edge cases** — The fix should be robust, not brittle
5. **Add comments** — Explain WHY this fix works if not obvious

```markdown
### Fix Applied

File(s) modified: [list]
Change description: [what was changed and WHY]
Lines changed: [N] lines
```

### Step 4.2 — Run the Failing Test (Must Now Pass)
// turbo

```bash
# The previously failing test MUST now pass
npm test -- --grep "[test name]" 2>&1 | tail -30
```

**If test still fails** → Revisit Phase 2 (investigate further)
**If test passes** → Continue to Step 4.3

### Step 4.3 — Run Full Test Suite (Regression Check)
// turbo

```bash
# Ensure the fix doesn't break anything else
npm test 2>&1 | tail -50
```

**If other tests fail** → The fix introduced a regression → investigate and adjust

### Step 4.4 — Build Verification
// turbo

```bash
# Ensure the fix compiles cleanly
npm run build 2>&1 | tail -30
```

### Step 4.5 — Lint Verification
// turbo

```bash
# Ensure no lint errors
npm run lint 2>&1 | tail -20
```

### Step 4.6 — Manual Verification (If Applicable)

If the bug has visual or behavioral aspects that can't be fully tested:
- Start the application
- Verify the bug is fixed in the running application
- Check related functionality still works

### Step 4.7 — Fix Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ BUG FIX VERIFIED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bug:        [Short description]
Root Cause: [What caused it]
Fix:        [What was changed]
Test:       ✅ New test passing
Regression: ✅ All existing tests passing
Build:      ✅ Passing
Lint:       ✅ Clean
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Phase 5: Knowledge Capture (Automatic)

> **This phase runs automatically** after a non-trivial bug fix.
> It captures the solution as searchable documentation for future reference.
> Can also be triggered standalone via `/context-compound`.

### Step 5.1 — Evaluate Complexity

Determine if documentation is warranted:

| Criteria | Threshold |
|----------|----------|
| Fix took > 15 minutes to find | ✅ Document |
| Root cause was non-obvious | ✅ Document |
| Multiple files affected | ✅ Document |
| Bug could recur in similar code | ✅ Document |
| External dependency involved | ✅ Document |
| Involved debugging tools/techniques | ✅ Document |
| Trivial typo or syntax error | ❌ Skip |
| One-line obvious fix | ❌ Skip |

If ALL criteria are "Skip" → Skip Phase 5 entirely.

### Step 5.2 — Classify the Issue

```markdown
### Issue Classification

| Attribute | Value |
|-----------|-------|
| **Category** | Bug Fix / Configuration / Integration / Performance / Security / Data |
| **Severity** | Critical / High / Medium / Low |
| **Area** | [Backend / Frontend / Database / Infrastructure / API ] |
| **Tags** | [auth, database, caching, TypeScript, React, etc.] |
| **Recurrence Risk** | High / Medium / Low |
```

### Step 5.3 — Check Existing Documentation
// turbo

```bash
# Check if this issue or similar has been documented before
find docs/solutions -name "*.md" 2>/dev/null | head -20
grep -rn "<relevant_keyword>" docs/solutions/ 2>/dev/null | head -10
```

If similar documentation exists → UPDATE instead of creating new.

### Step 5.4 — Create Solution Document

> **Process reference:** See `skills/knowledge-compounding/SKILL.md` for the full knowledge compounding methodology — cross-referencing, pattern detection, and index management.
> The template below is debug-specific. The skill provides the authoritative capture process.

Save to `docs/solutions/[YYYY-MM-DD]-[slug].md`:

```markdown
# [Problem Title]

> **Date:** [YYYY-MM-DD]
> **Category:** [Bug Fix / Configuration / Integration / Performance / Security]
> **Severity:** [Critical / High / Medium / Low]
> **Area:** [Backend / Frontend / Database / Infrastructure]
> **Tags:** [comma-separated tags]
> **Recurrence Risk:** [High / Medium / Low]
> **Time to Diagnose:** [X minutes/hours]
> **Time to Fix:** [X minutes]

---

## Problem
[Clear description of what went wrong]

**Symptom:**
[What the user/system experienced]

**Error Message:**
```
[Exact error output]
```

## Root Cause
[Detailed explanation of WHY the bug occurred]

**Why this happened:**
[Technical reasoning — not just "the code was wrong" but WHY it was wrong]

**Contributing factors:**
- [Factor 1 — e.g., missing type check]
- [Factor 2 — e.g., API changed behavior]

## Solution
[Step-by-step fix with code snippets]

**Files Changed:**
| File | Change |
|------|--------|
| `path/to/file` | [description of change] |

**Before:**
```[lang]
[code before fix]
```

**After:**
```[lang]
[code after fix]
```

**Why this fix works:**
[Explanation of WHY the fix resolves the root cause]

## Prevention
[How to prevent this from happening again]

- [ ] [Add validation for X]
- [ ] [Add test for Y edge case]
- [ ] [Update linting rule for Z]
- [ ] [Add monitoring/alert for W]

## Related
- [Link to related docs or issues]
- [Link to framework documentation]
- [Stack Overflow / GitHub issue if applicable]

## Test Coverage
- [Test file and test name that covers this scenario]
```

### Step 5.5 — Detect Patterns

If this is the 2nd+ similar issue in the same area:

```markdown
⚠️ Pattern Detected

This is the [N]th issue in the **[area]** area involving **[pattern]**.

Consider:
1. 🔍 /context-review — Review the entire [area] for similar issues
2. 🏗️ /context-refactor — Refactor [area] to prevent future occurrences
3. 📋 /context-plan — Create a plan to address the systemic issue
```

### Step 5.6 — Summary

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 KNOWLEDGE CAPTURED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Problem:     [Short title]
Root Cause:  [One-line summary]
Solution:    [One-line summary]
Saved at:    docs/solutions/[filename].md
Searchable:  [tags]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 Bug fixed + documented. Ready for next task.
Next: /context-git to commit the fix, or continue development.
```

---

## Debugging Decision Tree

Use this to quickly route to the right investigation approach:

```
Error occurs
    │
    ├── Build fails?
    │   ├── Syntax error → Check recent edits, fix syntax
    │   ├── Type error → Check types, interfaces, generics
    │   ├── Import error → Check file paths, exports
    │   └── Dependency error → Check package.json, node_modules
    │
    ├── Test fails?
    │   ├── Assertion error → Check business logic
    │   ├── Timeout → Check async operations, DB connections
    │   ├── Mock error → Check test setup, mock configuration
    │   └── All tests fail → Check test config, environment
    │
    ├── Runtime error?
    │   ├── 500 error → Check server logs, exception handler
    │   ├── 404 error → Check routes, middleware
    │   ├── 401/403 → Check auth, tokens, permissions
    │   ├── DB error → Check connection, schema, queries
    │   └── Unhandled rejection → Check async/await, promises
    │
    ├── Wrong behavior?
    │   ├── Wrong data → Trace data flow (input → process → output)
    │   ├── Missing feature → Check if implemented or just planned
    │   ├── UI broken → Check CSS, responsive, component state
    │   └── Performance → Profile queries, algorithms, rendering
    │
    └── Intermittent?
        ├── Race condition → Check async operations, locks
        ├── Memory → Check for leaks, event listeners
        ├── Network → Check timeouts, retry logic
        └── Data-dependent → Check edge case inputs
```

---

## When to Use
- Any bug, error, or unexpected behavior
- Test failures (unit, integration, E2E)
- Build or compilation errors
- Performance regressions
- Documenting solutions to solved problems (standalone, via `/context-compound`)

## When to Skip
- Feature requests (use `/context-plan` instead)
- Code quality improvements (use `/context-refactor` instead)
- Known issue that's already documented in `docs/solutions/`
