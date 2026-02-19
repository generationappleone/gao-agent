---
description: Execute implementation tasks from an approved plan, following all rules and skills, with progress tracking and quality verification.
---

# Context Work — Task Execution Engine

## Purpose
This workflow **executes tasks** defined in an approved plan (from `/context-plan`). It follows the priority order (URGENT → HIGH → MEDIUM → LOW), applies all mandatory rules, references relevant skills, and tracks progress with quality verification at each step.

---

## Activation
The user triggers this workflow by:
- Using `/context-work` to start executing the current plan
- Using `/context-work [plan-file]` to specify which plan to execute
- Using `/context-work task [number]` to execute a specific task

---

## Phase 1: Plan Loading & Validation

### Step 1.1 — Load the Plan
// turbo
Find and load the plan to execute:

```bash
# List available plans
find .agent/plans -name "PLAN-*.md" -not -path '*/archive/*' | sort -r
```

If multiple plans exist, ask the user:
```markdown
📋 Multiple plans found:

1. PLAN-2026-02-19-user-notification.md (Status: Approved)
2. PLAN-2026-02-18-payment-gateway.md (Status: In Progress)

Which plan should I work on? Or specify a task number from a specific plan.
```

### Step 1.2 — Read the Plan
// turbo
Read the entire plan file to understand:
- All tasks and their priority ordering
- Dependencies between tasks
- Database changes needed
- API changes needed
- Files to create/modify
- Dependencies to install
- Testing requirements

### Step 1.3 — Read Project Context
// turbo
Before writing any code, MUST read context (as per Post-Init Rules in AGENTS.md):

```
1. .agent/context/CONTEXT_INDEX.md
2. .agent/context/ARCHITECTURE.md
3. .agent/context/DATABASE_SCHEMA.md (if DB changes)
4. .agent/context/API_REFERENCE.md (if API changes)
5. .agent/context/DEPENDENCIES.md (if adding packages)
```

### Step 1.4 — Verify Plan Status

Check plan status:
- **Draft** → Cannot execute. Ask user to review/approve first.
- **Approved** → Ready to execute. Update status to "In Progress".
- **In Progress** → Resume from last completed task.
- **Completed** → All tasks done. Inform user.

Update plan header:
```markdown
> **Status:** In Progress
> **Started:** [current date & time]
```

### Step 1.5 — Load Relevant Skills
// turbo
For each technology involved in the plan:

1. Check if a matching skill exists in `.agent/skills/`
2. Read the relevant `SKILL.md` files
3. If a required skill is MISSING:

```markdown
⚠️ Missing Skill Detected

Task #[N] requires knowledge of **[technology]**, but no skill file exists at:
`.agent/skills/[technology]/SKILL.md`

Options:
1. 📝 **You provide the skill** — Add a SKILL.md file for [technology]
2. 🤖 **I create the skill** — I'll research credible sources and generate a comprehensive skill file
3. ⏭️ **Skip for now** — Proceed without the skill (not recommended)

Which option would you prefer?
```

If the user chooses option 2 (agent creates the skill):
- Research the technology using web search (official docs, credible sources)
- Generate a SKILL.md following the same format as existing skills
- Save to `.agent/skills/[technology]/SKILL.md`
- The skill MUST follow all applicable rules (security, SOLID, database design, etc.)
- Present the generated skill to the user for review before continuing

### Step 1.6 — Verify All Rules Loaded
// turbo
Load and confirm all rules from `.agent/rules/`:

```bash
find .agent/rules -name "*.md" | sort
```

All rules are MANDATORY during execution:
- `solid-principles.md` — Code structure
- `developer-security.md` — Security practices
- `database-design.md` — Database conventions
- `dependency-management.md` — Dependency vetting
- `iso-27000-compliance.md` — Compliance
- `ui-ux-design.md` — UI/UX standards (if frontend work)

---

## Phase 2: Task Execution

### Step 2.1 — Execution Order

Execute tasks in strict priority order:

```
🔴 URGENT tasks (1, 2, ...)     ← Execute FIRST — blocks everything
    ↓ all completed
🟠 HIGH tasks (3, 4, ...)       ← Execute SECOND — core functionality
    ↓ all completed
🟡 MEDIUM tasks (5, 6, ...)     ← Execute THIRD — supporting features
    ↓ all completed
🟢 LOW tasks (7, 8, ...)        ← Execute LAST — polish & optimization
```

**Dependency check:** Before starting any task, verify all dependent tasks are completed.

### Step 2.2 — Pre-Task Announcement

Before each task, announce:

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 TASK #1 — [Task Title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Priority:    URGENT
Estimated:   2 hours
Depends on:  None
Description: [What this task accomplishes]
Files:       [Files to create/modify]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2.3 — Execute Task

For each task, follow this execution protocol:

#### A. Preparation
1. Re-read the relevant section of the plan for this task
2. Read existing files that will be modified (understand current state)
3. Load the relevant skill file(s) for the technology
4. Review applicable rules

#### B. Implementation

**For Database Tasks:**
1. Create migration file following `database-design.md` rules
2. UUID primary keys, audit columns (`created_at`, `updated_at`), soft delete (`deleted_at`)
3. Proper naming conventions (snake_case, plural tables)
4. Add indexes on foreign keys and frequently queried columns
5. Follow the project's existing migration pattern

**For Backend/Service Tasks:**
1. Follow SOLID principles (`solid-principles.md`)
2. Match existing architecture pattern (check `ARCHITECTURE.md`)
3. Input validation on ALL external data (`developer-security.md`)
4. Parameterized queries only (`developer-security.md`)
5. Proper error handling with meaningful messages
6. Follow the relevant language/framework skill

**For API/Route Tasks:**
1. RESTful conventions (check `API_REFERENCE.md` for existing patterns)
2. Authentication & authorization checks
3. Request validation (DTO/Form Request)
4. Consistent response format
5. Proper HTTP status codes
6. Rate limiting consideration

**For Frontend/UI Tasks:**
1. Follow `ui-ux-design.md` rules
2. Responsive design (mobile-first)
3. Accessibility (WCAG 2.1 AA)
4. Dark mode support
5. Micro-interactions and smooth transitions
6. Design token system

**For Dependency Installation:**
1. Follow `dependency-management.md` rules
2. Verify: popularity, maintenance, security, license, size
3. Check for conflicts with existing packages
4. Pin exact versions
5. Run security audit after installation

**For Configuration/Infra Tasks:**
1. Secrets in environment variables (never hardcoded)
2. Follow `iso-27000-compliance.md`
3. Follow Docker/K8s skill if applicable

#### C. Code Quality Check

After writing each piece of code, verify:

```markdown
### Quality Checklist — Task #[N]
- [ ] Follows existing project patterns (architecture, naming, style)
- [ ] Input validated and output escaped
- [ ] No hardcoded secrets or credentials
- [ ] Error handling is comprehensive
- [ ] Database queries use parameterized statements
- [ ] Functions ≤ 50 lines (SRP)
- [ ] No `any` type in TypeScript
- [ ] SOLID principles applied
- [ ] Security rules followed
- [ ] Accessibility met (if UI)
- [ ] Performance considered
```

### Step 2.4 — Post-Task Verification

After completing each task:

1. **Verify the code compiles/runs:**
// turbo
```bash
# Language-specific build/check
npm run build 2>&1 | tail -20          # Node.js/TypeScript
php artisan route:list 2>&1 | tail -20  # Laravel
python -m py_compile <file> 2>&1        # Python
go build ./... 2>&1 | tail -20         # Go
dotnet build 2>&1 | tail -20           # .NET
```

2. **Run relevant tests (if they exist):**
// turbo
```bash
npm test -- --passWithNoTests 2>&1 | tail -20
php artisan test 2>&1 | tail -20
pytest 2>&1 | tail -20
go test ./... 2>&1 | tail -20
```

3. **Verify linting (if configured):**
// turbo
```bash
npm run lint 2>&1 | tail -20
```

### Step 2.5 — Mark Task Complete

Update the plan file — change task checkbox:

```markdown
# Before:
- [ ] 🔴 Task 1: Create notifications table migration

# After:
- [x] 🔴 Task 1: Create notifications table migration ✅ (completed: 2026-02-19 11:30)
```

### Step 2.6 — Progress Report (Informational Only — Do NOT Pause)

After completing each priority group, show a progress report and **immediately continue** to the next step (testing).
**⚠️ RULE: `continuous-execution.md` — NEVER ask "Continue?" or wait for user confirmation. Proceed automatically.**

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 PROGRESS REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 URGENT:  ██████████ 2/2 completed ✅
🟠 HIGH:    ██████░░░░ 1/3 completed   ← Current
🟡 MEDIUM:  ░░░░░░░░░░ 0/2 pending
🟢 LOW:     ░░░░░░░░░░ 0/1 pending
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 3/8 tasks completed (37.5%)

✅ Completed:
  1. Create notifications table migration
  2. Create Notification model
  3. Create NotificationService

🧪 Running inter-sprint deep testing before next task...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2.7 — Inter-Sprint Deep Testing (MANDATORY — Before Next Task/Sprint)

**⚠️ RULE: After EVERY task or sprint is completed, MUST run comprehensive testing on the ENTIRE application before proceeding to the next task/sprint. This is NON-NEGOTIABLE.**

This step ensures no cascading errors across sprints. The agent MUST NOT skip this step.

#### A. Build Verification
// turbo
```bash
# Build the entire project — MUST pass with zero errors
npm run build 2>&1 | tail -50
# Or for PHP/Laravel:
php artisan route:clear && php artisan config:clear && php artisan view:clear && php artisan optimize 2>&1
# Or for Python:
python -m py_compile main.py 2>&1
```

#### B. Full Test Suite
// turbo
```bash
# Run ALL tests — not just tests for the current task
npm test 2>&1 | tail -80
# Or for PHP/Laravel:
php artisan test --parallel 2>&1 | tail -80
# Or for Python:
pytest -v 2>&1 | tail -80
```

#### C. Linting & Static Analysis
// turbo
```bash
# Run linter on entire codebase
npm run lint 2>&1 | tail -30
# Or for PHP:
./vendor/bin/phpstan analyse 2>&1 | tail -30
# Or for Python:
flake8 . 2>&1 | tail -30
```

#### D. Application Smoke Test
// turbo
```bash
# Start the application and verify it runs without crash
# For Node.js:
npm run dev &
sleep 5
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "FAIL"
kill %1 2>/dev/null

# For Laravel:
php artisan serve &
sleep 3
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 || echo "FAIL"
kill %1 2>/dev/null
```

#### E. Database & Migration Check (if applicable)
// turbo
```bash
# Verify migrations are clean
php artisan migrate:status 2>&1
# Or:
npx prisma migrate status 2>&1
# Or:
npx prisma validate 2>&1
```

#### F. Security Quick Scan
// turbo
```bash
# Dependency vulnerability check
npm audit --production 2>&1 | tail -20
# Or for PHP:
composer audit 2>&1 | tail -20
```

#### G. Inter-Sprint Test Report

After all checks, show the report:

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 INTER-SPRINT DEEP TEST REPORT — After Task #[N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔨 Build:           ✅ Passing / ❌ FAILED
🧪 Tests:           ✅ [N] passing, [M] total / ❌ [X] FAILED
📏 Lint:            ✅ No errors / ❌ [X] errors
🚀 App Startup:     ✅ Running / ❌ CRASHED
🗄️ DB Migrations:   ✅ Clean / ❌ PENDING/FAILED
🔒 Security Audit:  ✅ No vulnerabilities / ⚠️ [X] found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 ALL CHECKS PASSED → Proceeding to next task/sprint...
— OR —
🔴 CHECKS FAILED → Fixing issues before continuing...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### H. Decision Logic

**If ALL checks pass (✅):**
→ Proceed automatically to the next task/sprint. No pause needed.

**If ANY check fails (❌):**
→ **MUST fix ALL errors before continuing.** Follow this process:
1. Identify all failing checks
2. Fix each error systematically (build → tests → lint → app → db → security)
3. Re-run ALL checks again (not just the fixed ones)
4. Repeat until ALL checks pass
5. Only then proceed to the next task/sprint

**⚠️ CRITICAL: The agent MUST NOT proceed to the next task if ANY check fails. This prevents error accumulation across sprints.**

---

## Phase 3: Error Handling During Execution

### Step 3.1 — Build/Compile Error
If code fails to build:
1. Read the error message carefully
2. Identify the root cause
3. Fix the code
4. Re-verify
5. Document the fix in the plan (add a note)

### Step 3.2 — Test Failure
If tests fail:
1. Determine if it's the new code or existing test
2. If new code broke existing test → fix the new code
3. If test needs updating → update test (with justification)
4. Re-run all tests after fix

### Step 3.3 — Dependency Conflict
If a dependency conflict is detected:
1. Report the conflict to the user
2. Propose resolution options:
   - Use an alternative package
   - Pin to a compatible version
   - Update the conflicting package
3. Wait for user decision

### Step 3.4 — Unexpected Architecture Mismatch
If the plan doesn't match the actual code structure:
1. Stop execution
2. Report the mismatch
3. Ask user whether to:
   - Update the plan
   - Adapt the code to match the plan
   - Discuss the discrepancy

---

## Phase 4: Completion & Documentation

### Step 4.1 — Final Verification

After ALL tasks are completed:

1. **Build the entire project:**
```bash
npm run build 2>&1 | tail -30
```

2. **Run the full test suite:**
```bash
npm test 2>&1 | tail -30
```

3. **Run linting:**
```bash
npm run lint 2>&1 | tail -30
```

4. **Security audit:**
```bash
npm audit 2>&1 | tail -20
```

### Step 4.2 — Update Context Documentation

As per Post-Init Rules (AGENTS.md Rule #3), update ALL affected context files:

| What Changed | Update |
|-------------|--------|
| New database tables | `.agent/context/DATABASE_SCHEMA.md` |
| New API endpoints | `.agent/context/API_REFERENCE.md` |
| New dependencies | `.agent/context/DEPENDENCIES.md` |
| New services/modules | `.agent/context/ARCHITECTURE.md` |
| New business domains | `.agent/context/BUSINESS_DOMAINS.md` |
| New env variables | `.agent/context/DEVELOPMENT_GUIDE.md` |
| Significant features | `.agent/context/PROJECT_OVERVIEW.md` |

### Step 4.3 — Update Plan Status

```markdown
> **Status:** Completed ✅
> **Started:** 2026-02-19 11:30
> **Completed:** 2026-02-19 15:45
> **Actual Effort:** 4.25 hours
```

### Step 4.4 — Final Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ IMPLEMENTATION COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Plan:      [Plan Title]
Tasks:     [N]/[N] completed
Duration:  [X hours]
Build:     ✅ Passing
Tests:     ✅ [N] passing, [M] total
Lint:      ✅ No errors
Security:  ✅ No vulnerabilities

📁 Files Created:  [list]
📝 Files Modified: [list]
🗄️ DB Migrations:  [list]
📦 Dependencies:   [list]
📚 Docs Updated:   [list]

💡 Notes:
- [Any important observations during implementation]
- [Any deviations from the original plan]
- [Suggestions for future improvements]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Execution Rules (Non-Negotiable)

1. **NEVER skip a task** without user approval
2. **NEVER ignore rules** — all rules apply at all times
3. **NEVER install dependencies** without following dependency-management.md
4. **NEVER write raw SQL** — use parameterized queries
5. **NEVER hardcode secrets** — use environment variables
6. **NEVER skip error handling** — every path must be covered
7. **ALWAYS match existing patterns** — check context docs first
8. **ALWAYS read the relevant skill** before implementing
9. **ALWAYS verify after each task** — build, test, lint
10. **ALWAYS update documentation** after structural changes
11. **NEVER ask "Continue?"** between tasks/sprints — execute ALL tasks continuously until completion (`continuous-execution.md`)
12. **ALWAYS proceed automatically** to the next task after completing the current one — no user confirmation needed
13. **ALWAYS run inter-sprint deep testing** (Step 2.7) after EVERY task/sprint — build, test, lint, app startup, DB check, security audit on the ENTIRE application
14. **NEVER proceed to the next task/sprint** if ANY inter-sprint test fails — FIX ALL errors first, re-run ALL checks, then continue
15. **ALWAYS test the ENTIRE application** — not just the code from the current task, but ALL existing functionality to catch regressions
