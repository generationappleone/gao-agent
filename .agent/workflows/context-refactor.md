---
description: Guided code refactoring with safety nets, code metrics analysis, and atomic execution. Use when improving code quality, extracting modules, reducing complexity, or paying technical debt.
---

# Context Refactor — Safe Code Refactoring

## Purpose
This workflow provides a **safe, systematic approach** to refactoring code. It measures code quality before and after, executes changes atomically with test verification at each step, and ensures no behavior changes are introduced.

> **Key Principle:** Refactoring changes code structure, NEVER changes behavior.

---

## Activation
The user triggers this workflow by:
- Using `/context-refactor` to see options
- Using `/context-refactor [file/directory]` to target specific code
- Using `/context-refactor --metrics` to only analyze code metrics without changing anything

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 1: Analysis & Measurement

### Step 1.1 — Read Project Context
// turbo
```
1. .agent/context/ARCHITECTURE.md     ← Current architecture patterns
2. .agent/context/CONTEXT_INDEX.md    ← Project conventions
3. .agent/rules/deep-thinking.md      ← Deep analysis standards (MANDATORY)
4. .agent/rules/solid-principles.md   ← SOLID principles (MANDATORY)
```

### Step 1.2 — Read Architecture & Design Skills
// turbo
Read these skills for refactoring guidance:
- `skills/architecture-enforcement/SKILL.md` — verify refactoring aligns with expected architecture
- `skills/design-patterns/SKILL.md` — apply appropriate design patterns during restructuring

### Step 1.3 — Identify Refactoring Scope

```markdown
🔧 Refactoring Scope

What would you like to refactor?
1. 📦 **Extract module/service** — Split large files into focused units
2. 🏗️ **Architecture change** — Restructure directories/layers
3. 🧹 **Code cleanup** — Reduce complexity, remove duplication
4. 📝 **Rename/reorganize** — Improve naming, file structure
5. ⚡ **Performance** — Optimize hot paths, reduce bundle size
6. 🔄 **Pattern migration** — Class → hooks, callbacks → async/await, etc.
7. 🗑️ **Dead code removal** — Remove unreachable or unused code
8. 🎯 **Auto-detect** — Analyze the codebase and suggest refactoring targets

Affected files or directories?
```

### Step 1.4 — Measure Baseline Metrics (BEFORE)
// turbo

Before ANY changes, measure and record:

```bash
# Count lines per file
find [target_dir] -name "*.ts" -o -name "*.js" -o -name "*.php" -o -name "*.py" | xargs wc -l 2>/dev/null | sort -n | tail -20

# Find large files (>300 lines)
find [target_dir] -name "*.ts" -o -name "*.js" -o -name "*.php" -o -name "*.py" | xargs wc -l 2>/dev/null | awk '$1 > 300' | sort -rn

# Find large functions (approximate — look for long blocks)
grep -rn "function \|async \|const .* = \|def \|public function" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" [target_dir] 2>/dev/null | head -30

# Find duplicate code (approximate)
grep -rn "." --include="*.ts" --include="*.js" [target_dir] | awk -F: '{print $3}' | sort | uniq -d -c | sort -rn | head -20

# Run tests — establish baseline
npm test 2>&1 | tail -20
```

Record metrics:
```markdown
### 📏 Baseline Metrics (Before Refactoring)

| Metric | Value |
|--------|-------|
| Total files in scope | [N] |
| Total lines of code | [N] |
| Files > 300 lines | [N] |
| Functions > 50 lines | [N] |
| Max file size | [N] lines — [filename] |
| Max function size | [N] lines — [function name] |
| Code duplication (est.) | [low/medium/high] |
| Test count | [N] tests |
| Tests passing | ✅ [N]/[N] |
| Build status | ✅ Passing |
| Lint errors | [N] |
```

### Step 1.5 — Auto-Detect Refactoring Opportunities

If user chose auto-detect or scope is broad:
// turbo

```bash
# Files exceeding recommended limits
find [target_dir] \( -name "*.ts" -o -name "*.js" -o -name "*.php" -o -name "*.py" \) -not -path '*/node_modules/*' -not -path '*/vendor/*' | xargs wc -l 2>/dev/null | awk '$1 > 300 {print "🔴 " $0}'

# Circular dependency detection (Node.js)
npx madge --circular --extensions ts,js src/ 2>&1 | head -20

# Find unused exports
npx ts-unused-exports tsconfig.json 2>&1 | head -20

# Find dead code
grep -rn "TODO\|FIXME\|DEPRECATED\|@deprecated" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' | head -20
```

Present findings:
```markdown
### 🔍 Refactoring Opportunities Detected

| # | Type | Location | Issue | Recommendation | Priority |
|---|------|----------|-------|---------------|----------|
| 1 | Large file | UserService.ts (850 lines) | God class | Extract into focused services | 🔴 High |
| 2 | Duplication | auth.ts / login.ts | 45 duplicate lines | Extract shared auth utils | 🟠 Medium |
| 3 | Complexity | OrderController.ts:processOrder | 95 lines, 12 nesting levels | Break into smaller functions | 🟠 Medium |
| 4 | Dead code | utils/legacy.ts | No imports found | Remove or document | 🟡 Low |
| 5 | Circular dep | Service A ↔ Service B | Tight coupling | Introduce interface/abstraction | 🔴 High |

Which items would you like to address? (all / specific numbers / suggest order)
```

---

## Phase 2: Refactoring Plan

### Step 2.1 — Create Detailed Plan

```markdown
## Refactoring Plan

**Goal:** [What we're improving — measurable]
**Type:** [Extract / Restructure / Cleanup / Rename / Optimize / Migrate]
**Scope:** [N] files, ~[N] lines affected
**Risk Level:** [Low / Medium / High]

### Changes (Execution Order)
| # | Action | From | To | Risk | Verifiable? |
|---|--------|------|----|------|-------------|
| 1 | Extract validation | UserService.ts:45-120 | validators/userValidator.ts | Low | ✅ Tests exist |
| 2 | Move utility | utils/helpers.ts | shared/formatters.ts | Medium | ✅ Tests exist |
| 3 | Extract interface | UserService.ts | interfaces/IUserService.ts | Low | ✅ Type check |
| 4 | Update imports | 12 files | — | Low | ✅ Build check |

### Safety Nets
- [x] All existing tests pass BEFORE starting
- [x] Each change is atomic (can be reverted independently)
- [x] Tests run after EVERY change
- [x] No behavior changes — only structural improvements
- [x] Build verified after each step

### Expected Outcome
| Metric | Before | After (Expected) | Improvement |
|--------|--------|-------------------|-------------|
| Max file size | 850 lines | ~200 lines | -76% |
| Files > 300 lines | 5 | 0 | -100% |
| Code duplication | Medium | Low | Significant |
| Function max lines | 95 | ~30 | -68% |
```

### Step 2.2 — Approval

```markdown
⛔ Review the refactoring plan above.

Does this look correct? Shall I proceed?
- ✅ **Yes, proceed** — Execute all changes
- ✏️ **Modify** — Adjust the plan
- ❌ **Cancel** — Don't refactor
```

---

## Phase 3: Atomic Execution

### Step 3.1 — Execute Each Change Atomically

For EACH change in the plan:

#### A. Make ONE change
- Extract function/class/module
- Move file/directory
- Rename symbol
- Update pattern

#### B. Update all references
// turbo
```bash
# Find and update all imports referencing moved/renamed code
grep -rn "from.*[old_path]\|import.*[old_name]" --include="*.ts" --include="*.js" -not -path '*/node_modules/*' | head -20
```

#### C. Verify after each change
// turbo
```bash
# Build check — MUST pass
npm run build 2>&1 | tail -20

# Test check — MUST pass with same count
npm test 2>&1 | tail -20

# Lint check
npm run lint 2>&1 | tail -10
```

#### D. If tests fail
1. **STOP** — Do not continue with next change
2. Investigate the failure
3. Fix the issue (likely a missed import update)
4. Re-verify
5. If cannot fix → **revert this change** and report

```bash
# Revert if needed
git checkout -- [affected files] 2>&1
```

#### E. Report step completion
```markdown
✅ Step [N]/[Total]: [description]
   Build: ✅ | Tests: ✅ [N] passing | Lint: ✅
```

---

## Phase 4: Final Verification

### Step 4.1 — Final Build & Test
// turbo
```bash
# Full build
npm run build 2>&1 | tail -30

# Full test suite
npm test 2>&1 | tail -30

# Full lint
npm run lint 2>&1 | tail -20
```

### Step 4.2 — Measure Post-Refactoring Metrics (AFTER)
// turbo

```bash
# Same measurements as Phase 1
find [target_dir] -name "*.ts" -o -name "*.js" | xargs wc -l 2>/dev/null | sort -n | tail -20
```

### Step 4.3 — Compare Metrics

```markdown
### 📊 Refactoring Results

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total files in scope | [N] | [N] | +[N] (expected — from extraction) |
| Total lines of code | [N] | [N] | -[N]% |
| Files > 300 lines | [N] | [N] | -[N] |
| Functions > 50 lines | [N] | [N] | -[N] |
| Max file size | [N] lines | [N] lines | -[N]% |
| Max function size | [N] lines | [N] lines | -[N]% |
| Code duplication | [level] | [level] | Improved |
| Test count | [N] | [N] | +[N] (if tests added) |
| Tests passing | ✅ [N]/[N] | ✅ [N]/[N] | Same or better |
| Build status | ✅ | ✅ | — |
| Lint errors | [N] | [N] | -[N] |
```

### Step 4.4 — Update Documentation
// turbo

Update affected context files:
- `ARCHITECTURE.md` — if directory structure changed
- `API_REFERENCE.md` — if route files moved
- `BUSINESS_DOMAINS.md` — if domain boundaries changed

### Step 4.5 — Final Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ REFACTORING COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Goal:      [What was improved]
Changes:   [N] files modified, [M] files created
Steps:     [N]/[N] completed successfully
Reverted:  [N] steps (if any)

Metrics Improvement:
  📏 Max file:     [before] → [after] lines (-[N]%)
  📏 Max function: [before] → [after] lines (-[N]%)
  📏 Duplication:  [before] → [after]
  📏 Lint errors:  [before] → [after]

Quality:
  🔨 Build:   ✅ Passing
  🧪 Tests:   ✅ [N] passing, [M] total
  📏 Lint:    ✅ Clean
  🔀 No behavior changes confirmed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next: /context-git to commit → /context-review to verify quality
```

---

## When to Use
- Files exceeding 300+ lines
- Functions exceeding 50 lines
- God classes or modules with too many responsibilities
- Circular dependencies
- Duplicated code across files (DRY violations)
- Technical debt cleanup sprints
- Before adding features to complex modules (refactor first, then add)
- When code review identifies structural issues

## When to Skip
- Simple renames (just do them in-place, no workflow needed)
- New feature development (use `/context-plan` + `/context-work`)
- Bug fixes (use `/context-debug`)
- Prototyping / throwaway code
