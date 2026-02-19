---
name: Quality Control (QC)
description: Skill for software quality control — covering testing strategies (unit, integration, E2E), code review standards, quality gates, defect management, test automation, and QA metrics.
---

# Quality Control (QC) Skill

## Overview
**Quality Control** ensures software meets defined standards through systematic testing, code review, and quality gates. This skill covers QC processes, testing strategies, and metrics for measuring quality.

---

## Testing Pyramid

```
           /  E2E Tests  \        ← Few, slow, expensive
          / (Playwright/Cy)\       UI smoke tests, critical paths
         /──────────────────\
        / Integration Tests  \    ← Moderate, API/DB tests
       / (API, DB, Services)  \    Service interactions
      /────────────────────────\
     /     Unit Tests           \ ← Many, fast, cheap
    / (Functions, Classes, Hooks)\ Isolated logic
   /──────────────────────────────\
```

### Coverage Targets
| Test Type | Coverage Target | Run When |
|-----------|----------------|----------|
| Unit | ≥ 80% line coverage | Every commit (CI) |
| Integration | Critical paths covered | Every PR |
| E2E | Top 10 user journeys | Pre-deploy |
| Performance | All public endpoints | Weekly / pre-release |
| Security | OWASP Top 10 | Weekly / pre-release |

---

## Code Review Standards

### Review Checklist
```markdown
## Code Review Checklist

### Correctness
- [ ] Logic is correct and handles edge cases
- [ ] Error handling is comprehensive
- [ ] Input validation present for all user inputs
- [ ] No hardcoded values (use constants/config)

### Security
- [ ] No hardcoded secrets or credentials
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] Authentication/authorization checks on API endpoints
- [ ] PII not exposed in logs or error messages

### Performance
- [ ] No N+1 queries
- [ ] Database indexes for frequent queries
- [ ] No unnecessary re-renders (React)
- [ ] Large lists use virtualization or pagination

### Maintainability
- [ ] Code follows project conventions
- [ ] Functions/methods have single responsibility
- [ ] Variable names are descriptive
- [ ] Complex logic has comments explaining WHY
- [ ] No unused imports, variables, or dead code

### Testing
- [ ] Unit tests for new/changed logic
- [ ] Edge cases covered
- [ ] Tests are deterministic (no random, no time-dependent)
- [ ] Mocks used appropriately (not over-mocked)
```

---

## Quality Gates

```yaml
# CI/CD Quality Gates
quality_gates:
  pr_merge:
    - unit_tests: pass
    - lint: pass (0 errors)
    - type_check: pass
    - code_coverage: >= 80%
    - security_scan: no critical/high vulnerabilities
    - code_review: >= 1 approval
    
  staging_deploy:
    - all_pr_gates: pass
    - integration_tests: pass
    - e2e_tests: pass
    - performance_test: p95 < 500ms
    
  production_deploy:
    - all_staging_gates: pass
    - smoke_tests: pass
    - security_audit: pass
    - compliance_check: pass (UU PDP, ISO 27001)
    - change_approval: signed off
```

---

## Defect Management

### Severity Classification
| Severity | Description | Response | Example |
|----------|-------------|----------|---------|
| **SEV-1 Critical** | System down, data loss | Fix immediately | Production crash, data breach |
| **SEV-2 Major** | Feature broken, no workaround | Fix within 24h | Payment fails, login broken |
| **SEV-3 Moderate** | Feature broken, workaround exists | Fix within sprint | Export fails, but CSV works |
| **SEV-4 Minor** | Cosmetic, UX inconvenience | Backlog | Alignment off, typo |

### Bug Report Template
```markdown
## Bug Report: [BUG-001] [Short title]

**Severity:** SEV-1 / SEV-2 / SEV-3 / SEV-4
**Environment:** Production / Staging / Dev
**Reporter:** [Name]
**Assigned to:** [Name]

### Steps to Reproduce
1. Navigate to /dashboard
2. Click "Export" button
3. Select date range > 30 days

### Expected Result
CSV file downloads with all data

### Actual Result
Error 500 — "Request timeout"

### Evidence
- Screenshot: [attached]
- Console error: "TimeoutError: query exceeded 30s"
- Affected users: ~50 (estimated from error logs)

### Root Cause (filled by developer)
Query on fact_sales not using date partition index. Full table scan.

### Fix
Added index on fact_sales(date_key). Query now < 2s.
```

---

## QA Metrics Dashboard

```
Quality Metrics:
│ Metric                  │ Target    │ Current │ Status │
├─────────────────────────┼───────────┼─────────┼────────┤
│ Code Coverage           │ ≥ 80%     │ 83%     │ ✅     │
│ Open SEV-1/2 Bugs       │ 0         │ 0       │ ✅     │
│ Defect Escape Rate      │ < 5%      │ 3%      │ ✅     │
│ Mean Time to Fix (SEV-1)│ < 4h      │ 2.5h    │ ✅     │
│ Test Automation Rate     │ ≥ 70%     │ 75%     │ ✅     │
│ Deploy Success Rate      │ ≥ 95%     │ 97%     │ ✅     │
│ Flaky Test Rate          │ < 3%      │ 2%      │ ✅     │
│ Avg PR Review Time       │ < 24h     │ 18h     │ ✅     │
```

## Best Practices
1. **Shift left** — find defects early (static analysis, unit tests) where fixes are cheap
2. **Automate regressions** — manual for exploratory, automated for repeated tests
3. **Quality is everyone's job** — not just QA team
4. **Measure and improve** — track defect escape rate, coverage, fix time
5. **Test data management** — use factories/fixtures, never production PII in tests
6. **Definition of Done** — includes tests, review, documentation
