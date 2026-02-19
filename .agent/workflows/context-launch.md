---
description: "Full autonomous pipeline: plan (with optional brainstorm) → work → build → test → review (with security) → debug-compound. Use when you want the complete development lifecycle."
---

# Context Launch — Full Development Pipeline

## Purpose
This workflow executes the **complete development pipeline** from idea to deployment-ready code. It orchestrates all major workflows in sequence, ensuring nothing is missed.

> This is the "just build it" command — ideal for end-to-end feature development.

---

## Activation
The user triggers this workflow by:
- Using `/context-launch` followed by what they want built
- Using `/context-launch --explore` to start with brainstorming
- Describing a complete feature they want from start to finish

---

## Pipeline Stages

```
[1. Plan]  →  [2. Work]  →  [3. Build]  →  [4. Test]  →  [5. Review]  →  [6. Documentation]
    │              │             │              │              │                │
 brainstorm    implement      compile      verify         audit            capture
 + plan        all tasks      project      everything     quality          knowledge
```

### ⚠️ Pipeline Rules
- **MANDATORY:** Read `.agent/rules/deep-thinking.md` BEFORE starting any stage — all deep thinking, security, and quality standards apply throughout
- Each stage MUST complete successfully before proceeding
- If any stage fails, fix the issue before moving forward
- User is informed at each stage transition (but NOT asked "Continue?" — execution is continuous)
- The pipeline follows `continuous-execution.md` — auto-proceed between stages
- Reference relevant skills from `.agent/skills/` at each stage for framework-specific best practices

---

## Stage 1: Planning (includes optional brainstorming)

**Execute:** `/context-plan` (which includes Phase 0: Exploration if needed)

```markdown
━━━━━ STAGE 1/6: PLANNING ━━━━━
```

1. Read `.agent/rules/deep-thinking.md` — apply deep thinking checklist to planning
2. If requirements are vague → Run Phase 0 (brainstorming/exploration)
3. Analyze requirements, impact, and security implications
4. Read relevant skills for selected technologies
5. Fill skill gaps (auto-generate missing skills)
6. Create comprehensive plan document with database schema review if applicable
7. **⛔ PAUSE for user approval of the plan**

**Gate:** Plan must be `Approved` before proceeding.

---

## Stage 2: Implementation

**Execute:** `/context-work`

```markdown
━━━━━ STAGE 2/6: IMPLEMENTATION ━━━━━
```

1. Load the approved plan
2. Read framework-specific skills from `.agent/skills/` for implementation patterns
3. Execute tasks in priority order (URGENT → HIGH → MEDIUM → LOW)
4. Apply deep-thinking checklist (edge cases, security, validation) for EVERY task
5. Inter-sprint deep testing after each task/sprint
6. Continuous build, test, lint verification
7. Update context documentation as changes are made

**Gate:** All tasks completed, ALL inter-sprint tests passing.

---

## Stage 3: Build Verification

**Execute:** `/context-build`

```markdown
━━━━━ STAGE 3/6: BUILD VERIFICATION ━━━━━
```

1. Auto-detect framework and build tool
2. Install any missing dependencies
3. Execute production build
4. Verify output artifacts
5. Check bundle size (if frontend)

**Gate:** Clean build with zero errors.

---

## Stage 4: Comprehensive Testing

**Execute:** `/context-test`

```markdown
━━━━━ STAGE 4/6: TESTING ━━━━━
```

1. Run full test suite (unit, integration, E2E)
2. Run coverage analysis
3. Run security testing (SAST + dependency scan) — reference `skills/secure-code-patterns/SKILL.md`
4. Run performance baseline (if applicable)
5. Run accessibility audit (if frontend) — reference `skills/accessibility-testing/SKILL.md`
6. Verify database queries for N+1 problems and missing indexes
7. Generate test report

**Gate:** All critical tests passing, no P1 security issues.

---

## Stage 5: Code Review + Security Audit

**Execute:** `/context-review` (includes integrated security audit)

```markdown
━━━━━ STAGE 5/6: REVIEW + SECURITY ━━━━━
```

1. Multi-perspective code review (7 perspectives)
2. Spec compliance check (against the plan)
3. Full security audit (OWASP Top 10, secrets, auth, STRIDE)
4. Dependency vulnerability scan
5. Privacy check (if PII involved)
6. Severity classification and verdictive report
7. Fix P1 critical issues immediately

**Gate:** No P1 Critical issues. Verdict: APPROVE or APPROVE WITH NOTES.

---

## Stage 6: Documentation & Knowledge Capture

```markdown
━━━━━ STAGE 6/6: DOCUMENTATION ━━━━━
```

1. **Update context docs** — If significant changes made:
   - `.agent/context/ARCHITECTURE.md`
   - `.agent/context/API_REFERENCE.md`
   - `.agent/context/DATABASE_SCHEMA.md`
   - `.agent/context/DEPENDENCIES.md`

2. **Capture knowledge** — If non-trivial patterns or solutions discovered:
   - Run Phase 5 (Knowledge Capture) of `/context-debug`
   - Save to `docs/solutions/`

3. **Suggest user-facing docs** — Recommend running `/context-docs` if:
   - New public API endpoints added
   - README needs updating
   - CHANGELOG entry needed

---

## Final Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 LAUNCH COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature:     [Feature Title]
Plan:        .agent/plans/PLAN-[date]-[slug].md
Duration:    [X hours total]

Pipeline Results:
  📋 Plan:     ✅ Approved
  🔨 Work:     ✅ [N]/[N] tasks completed
  🏗️ Build:    ✅ Production build clean
  🧪 Test:     ✅ [N] tests passing, [X]% coverage
  🔍 Review:   ✅ Approved (P2: [N] noted)
  🔒 Security: ✅ No P1 issues
  📚 Docs:     ✅ Updated

📁 Files Created:  [N]
📝 Files Modified: [N]
🗄️ DB Migrations:  [N]
📦 Dependencies:   [N]
📊 Test Report:    .agent/test-reports/TEST-REPORT-[date].md

🚀 Ready for deployment!
   Next: /context-git to commit → /context-deploy to ship
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## When to Use
- Building a complete feature from scratch
- Major feature additions requiring planning through deployment
- When you want the full quality assurance pipeline
- New team members wanting a guided development experience

## When to Skip
- Small bug fixes (use `/context-debug`)
- Quick changes with known scope (use `/context-work` directly)
- Documentation-only updates (use `/context-docs`)
- Dependency updates (use `/context-upgrade`)
