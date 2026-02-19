---
description: Guided code refactoring with safety nets. Use when improving code quality, extracting modules, reducing complexity, or paying technical debt.
---

# Context Refactor Workflow

This workflow provides a **safe, systematic approach** to refactoring code. It ensures refactoring doesn't break existing functionality by maintaining test coverage throughout the process.

## Steps

1. **Read project context** — Load `.agent/context/ARCHITECTURE.md` and relevant context files.
   // turbo

2. **Identify refactoring scope** — Ask the user:
   ```markdown
   🔧 Refactoring Scope

   What would you like to refactor?
   1. 📦 Extract module/service (split large files)
   2. 🏗️ Architecture change (restructure directories)
   3. 🧹 Code cleanup (reduce complexity, remove duplication)
   4. 📝 Rename/reorganize (improve naming, file structure)
   5. ⚡ Performance (optimize hot paths, reduce bundle)
   6. 🔄 Pattern migration (e.g., class → hooks, callbacks → async/await)

   Affected files or directories?
   ```

3. **Analyze current state** — Before any changes:
   // turbo
   - Read all affected files
   - Map dependencies and imports
   - Run existing tests to establish baseline
   - Measure complexity metrics (lines, nesting depth, cyclomatic complexity)

4. **Read architecture-enforcement skill** — Load `skills/architecture-enforcement/SKILL.md` to verify the refactoring aligns with project architecture.
   // turbo

5. **Create refactoring plan** — Document what will change:
   ```markdown
   ## Refactoring Plan

   **Goal:** [What we're improving]
   **Type:** [Extract / Restructure / Cleanup / Rename / Optimize / Migrate]

   ### Changes
   | # | Action | From | To | Risk |
   |---|--------|------|----|------|
   | 1 | Extract function | UserService.ts:45-120 | createUserValidator.ts | Low |
   | 2 | Move file | utils/helpers.ts | shared/formatters.ts | Medium |

   ### Safety Nets
   - [ ] All existing tests pass before starting
   - [ ] Each change is atomic and testable
   - [ ] No behavior changes (only structure)
   ```

6. **⛔ Ask approval** — "Does this refactoring plan look correct? Shall I proceed?"

7. **Execute refactoring** — One change at a time:
   - Make one atomic change
   // turbo
   - Run tests after each change
   - If tests fail → revert and investigate
   - Commit each successful step

8. **Update imports** — After moves/renames:
   // turbo
   - Find and update all import references
   - Verify no broken imports remain
   ```bash
   npm run build 2>&1 | tail -30
   ```

9. **Verify** — Full verification after all changes:
   // turbo
   - Build passes
   - All tests pass
   - Lint clean
   - No regressions

10. **Update documentation** — Update affected context files:
    - `ARCHITECTURE.md` if structure changed
    - `API_REFERENCE.md` if routes moved
    - `BUSINESS_DOMAINS.md` if domains reorganized

11. **Report** — Summary of what changed:
    ```markdown
    ━━━━━━━━━━━━━━━━━━━━━━━━━
    ✅ REFACTORING COMPLETE
    ━━━━━━━━━━━━━━━━━━━━━━━━━
    Changes: [N] files modified
    Tests:   ✅ All passing
    Build:   ✅ Clean
    Metrics:
    - Lines reduced: [before] → [after]
    - Max complexity: [before] → [after]
    - Files split: [count]
    ━━━━━━━━━━━━━━━━━━━━━━━━━
    ```

## When to Use
- Files exceeding 1000 lines
- Functions exceeding 50 lines
- God classes or modules
- Circular dependencies
- Duplicated code across files
- Technical debt cleanup sprints

## When to Skip
- Simple renames (just do them in-place)
- New feature development (use `/context-work`)
- Bug fixes (use `/context-debug`)
