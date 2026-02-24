---
description: "Multi-perspective code review with integrated security audit. Covers code quality, OWASP Top 10, dependency scanning, and severity classification. Replaces /context-security."
---

# Context Review — Code Quality + Security Audit (Unified)

## Purpose
This workflow provides a **comprehensive review** that combines **multi-perspective code quality analysis** with a **full security audit** in a single pass. It classifies all findings by severity and produces an actionable report.

> **Replaces:** `/context-security` — security audits are now integrated as Phase 2 of this workflow.
> This workflow is **read-only by default** — it reports findings but never modifies files without explicit approval.

---

## Activation
The user triggers this workflow by:
- Using `/context-review` for full code review + security audit
- Using `/context-review --code-only` to skip security audit (code quality only)
- Using `/context-review --security-only` to run only the security audit
- Using `/context-security` (alias — routes here automatically, runs `--security-only`)
- After completing an implementation (`/context-work`)
- Before merging feature branches

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 1: Code Quality Review

### Step 1.1 — Load Review Skills
// turbo
1. Read `skills/code-review/SKILL.md` — code quality patterns
2. Read `skills/security-code-review/SKILL.md` — security perspective
3. Read `skills/architecture-enforcement/SKILL.md` — architecture compliance
4. Read `skills/secure-code-patterns/SKILL.md` — secure coding patterns
5. Read `skills/threat-modeling/SKILL.md` — if reviewing security-critical features
6. Read `.agent/rules/deep-thinking.md` — deep analysis standards (MANDATORY)
7. Read `.agent/rules/developer-security.md` — security rules (MANDATORY)

### Step 1.2 — Determine Review Scope

Ask the user (or auto-detect from context):
```markdown
🔍 Review Scope

What should I review?
1. 📝 Specific files (list paths)
2. 🌿 Feature branch diff (current vs main)
3. 📦 Specific component/module
4. 🏗️ Entire project (comprehensive)
5. 🔒 Security-only audit

Additional options:
- Compare against plan? [plan file path]
- Include performance analysis? [yes/no]
```

### Step 1.3 — Read Project Context
// turbo
```
1. .agent/context/CONTEXT_INDEX.md   ← Project standards
2. .agent/context/ARCHITECTURE.md    ← Expected patterns
3. .agent/context/API_REFERENCE.md   ← API conventions
4. .agent/context/DATABASE_SCHEMA.md ← DB standards
```

### Step 1.4 — Spec Compliance Check (If Plan Exists)

If reviewing after a plan implementation:
1. Load the plan from `.agent/plans/`
2. Verify ALL acceptance criteria are met
3. Verify ALL tasks were completed
4. Verify expected behavior matches implementation

```markdown
### Spec Compliance

| # | Requirement | Status | Notes |
|---|------------|--------|-------|
| 1 | [from plan] | ✅ Met / ❌ Missing | [details] |
| 2 | [from plan] | ✅ Met / ⚠️ Partial | [details] |
```

### Step 1.5 — Multi-Perspective Code Analysis
// turbo

Review EVERY affected file from **7 perspectives**:

#### 1. ✅ Correctness
- Logic errors, off-by-one, null handling
- Error handling completeness (try/catch, validation)
- Edge cases covered
- Race conditions or concurrency issues
- Return types and data shape consistency

#### 2. 🏗️ Design & Architecture
- SOLID principles adherence (`solid-principles.md`)
- Single Responsibility — functions ≤ 50 lines, classes focused
- Dependency Injection — no tight coupling
- Design patterns appropriate? (Repository, Service Layer, etc.)
- Architecture alignment — files in correct directories
- DRY — no code duplication
- YAGNI — no over-engineering

#### 3. ⚡ Performance
- N+1 query detection
- Unnecessary re-renders (React) or re-computations
- Memory leaks (event listeners, subscriptions)
- Big-O complexity of algorithms
- Database query optimization (indexes, joins vs subqueries)
- Bundle size impact (frontend)
- Caching opportunities missed

#### 4. 📖 Readability & Maintainability
- Naming clarity (variables, functions, classes)
- Code comments on WHY, not WHAT
- Consistent style with codebase
- Complexity — cyclomatic complexity too high?
- Magic numbers/strings — should be constants
- Dead code removal

#### 5. 🧪 Testing Quality
- Test coverage for new code
- Happy path AND error paths tested
- Edge cases tested
- Test isolation (no shared state)
- Assertions meaningful (not just "no error")
- Integration tests where needed
- Mocking strategy appropriate

#### 6. 🛡️ Privacy & Data Protection
- PII handling — encrypted at rest?
- Data leakage in logs (no PII in log output)
- Consent verification (if user data collected)
- Data retention policy followed
- GDPR/UU PDP compliance (if applicable)

#### 7. 🔒 Security (Quick Pass)
- Input validation on ALL external data
- Output encoding (XSS prevention)
- Parameterized queries (SQL injection prevention)
- Authentication/authorization checks
- Secrets management (no hardcoded)
- Rate limiting on sensitive endpoints

> **Note:** The detailed security deep-dive is in Phase 2.

---

## Phase 2: Security Audit (Deep Dive)

> **This phase runs by default.** Skip with `--code-only` flag.

### Step 2.1 — Load Security Skills
// turbo
1. Read `skills/security-audit/SKILL.md` — Full audit methodology
2. Read `skills/secure-code-patterns/SKILL.md` — Secure coding patterns
3. Read `skills/secrets-management/SKILL.md` — Secrets scanning
4. Read `skills/threat-modeling/SKILL.md` — STRIDE methodology

### Step 2.2 — Secrets Exposure Scan
// turbo
```bash
# Hardcoded API keys, tokens, passwords
grep -rn "password\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" --include="*.env" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' -not -name "*.example" -not -name "*.test.*" | head -20

# Private keys
grep -rn "BEGIN.*PRIVATE KEY" --include="*.pem" --include="*.key" --include="*.ts" --include="*.js" -not -path '*/node_modules/*' | head -10

# AWS/cloud credentials
grep -rn "AKIA\|aws_secret\|GOOG\|sk_live\|sk_test" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' | head -10
```

Verify:
- `.env` in `.gitignore` ✅
- `.env.example` exists with placeholder values ✅
- No secrets in committed config files ✅

### Step 2.3 — Security Configuration Check
// turbo
```bash
# Check security headers
grep -rn "helmet\|X-Frame-Options\|Content-Security-Policy\|Strict-Transport" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' | head -10

# Check CORS configuration
grep -rn "cors\|Access-Control" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' | head -10

# Check CSRF protection
grep -rn "csrf\|_token\|xsrf" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -10

# Check for debug mode in production
grep -rn "APP_DEBUG\|DEBUG=true\|debug:\s*true" --include="*.env" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' | head -10
```

### Step 2.4 — OWASP Top 10 Assessment
// turbo

Systematically check EVERY category:

```markdown
### OWASP Top 10 Assessment

| # | Category | Check | Status | Evidence |
|---|----------|-------|--------|----------|
| A01 | Broken Access Control | Auth on ALL protected routes? RBAC enforced? IDOR checks? | ✅/❌ | [file:line or finding] |
| A02 | Cryptographic Failures | Passwords hashed (bcrypt/Argon2)? Secrets encrypted? TLS enforced? | ✅/❌ | [evidence] |
| A03 | Injection | Parameterized queries? No eval()? Template auto-escaping? | ✅/❌ | [evidence] |
| A04 | Insecure Design | Business logic validated? Rate limiting? Account lockout? | ✅/❌ | [evidence] |
| A05 | Security Misconfiguration | Default creds removed? Error messages generic? Stack traces hidden? | ✅/❌ | [evidence] |
| A06 | Vulnerable Components | Dependencies up to date? Known CVEs? | ✅/❌ | [npm audit result] |
| A07 | Auth Failures | Session management? Token rotation? MFA option? | ✅/❌ | [evidence] |
| A08 | Data Integrity Failures | Input validation? Deserialization safe? CI/CD signed? | ✅/❌ | [evidence] |
| A09 | Logging Failures | Security events logged? PII redacted? Log injection prevented? | ✅/❌ | [evidence] |
| A10 | SSRF | External URL validation? Allowlist? DNS rebinding protection? | ✅/❌ | [evidence] |
```

### Step 2.5 — Authentication & Authorization Deep Review
// turbo

Review the project's auth implementation:

**JWT-based auth:**
- Signing algorithm (must NOT be `none` or `HS256` with weak secret)
- Token expiry configured (access: 15-60min, refresh: 7-30 days)
- Refresh token rotation (one-time use)
- Token storage (httpOnly cookie, NOT localStorage)
- Revocation mechanism exists

**Session-based auth:**
- httpOnly flag on cookies
- Secure flag (HTTPS only)
- SameSite attribute (Strict or Lax)
- Session regeneration after login
- Session timeout configured

**OAuth2:**
- PKCE enabled for public clients
- State parameter validated
- Callback URL strictly validated
- Scope minimized

### Step 2.6 — Dependency Vulnerability Scan
// turbo
```bash
# Node.js
npm audit --json 2>&1 | head -100

# PHP
composer audit 2>&1 | head -30

# Python
pip audit 2>&1 | head -30

# Go
govulncheck ./... 2>&1 | head -30
```

### Step 2.7 — Threat Assessment (Quick STRIDE)
// turbo

For critical entry points, evaluate:

| Threat | Question | Status |
|--------|----------|--------|
| **S**poofing | Can an attacker impersonate a user? | ✅/❌ |
| **T**ampering | Can request/data be modified in transit? | ✅/❌ |
| **R**epudiation | Are actions logged for accountability? | ✅/❌ |
| **I**nformation Disclosure | Does the app leak sensitive data? | ✅/❌ |
| **D**enial of Service | Are there DoS vectors (no rate limit, unbounded queries)? | ✅/❌ |
| **E**levation of Privilege | Can a user gain higher permissions? | ✅/❌ |

### Step 2.8 — Data Privacy Check (If PII Detected)
// turbo

If the project processes personal data:
- Consent mechanism exists ✅/❌
- PII encrypted at rest ✅/❌
- PII not logged in plain text ✅/❌
- Data retention policy exists ✅/❌
- Data subject rights supported (access, delete, export) ✅/❌
- Cross-border transfer compliance ✅/❌

---

## Phase 3: Finding Classification & Report

### Step 3.1 — Classify ALL Findings

Every finding MUST be classified into ONE severity level:

| Severity | Criteria | Action Required |
|----------|----------|----------------|
| 🔴 **P1 Critical** | Bugs, security vulnerabilities, data loss risks, broken auth | MUST fix before merge/deploy |
| 🟠 **P2 Important** | Design issues, missing edge cases, performance problems, partial OWASP failures | SHOULD fix before deploy |
| 🟡 **P3 Moderate** | Code quality issues, missing tests, inconsistent patterns | FIX in next sprint |
| 🟢 **P4 Suggestion** | Style, naming, minor improvements, nice-to-have optimizations | BACKLOG |

### Step 3.2 — Generate Review Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 CODE REVIEW + SECURITY AUDIT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Date:     [YYYY-MM-DD HH:mm]
Scope:    [files/branch/module reviewed]
Reviewer: AI Agent
Plan:     [plan reference if applicable]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✨ Strengths
[What was done well — always start with positives]
- [Strength 1]
- [Strength 2]
- [Strength 3]

## 📊 Summary
| Category | P1 🔴 | P2 🟠 | P3 🟡 | P4 🟢 |
|----------|-------|-------|-------|-------|
| Correctness | 0 | 1 | 0 | 0 |
| Design | 0 | 0 | 2 | 1 |
| Security | 1 | 2 | 0 | 0 |
| Performance | 0 | 0 | 1 | 0 |
| Testing | 0 | 1 | 0 | 2 |
| Privacy | 0 | 0 | 1 | 0 |
| **Total** | **1** | **4** | **4** | **3** |

## 🔴 P1 Critical — MUST Fix
| # | Category | File | Line | Issue | Recommendation |
|---|----------|------|------|-------|---------------|
| 1 | Security | auth.ts | 42 | JWT signed with HS256 and weak secret | Switch to RS256 or use 256-bit secret |

## 🟠 P2 Important — SHOULD Fix
| # | Category | File | Line | Issue | Recommendation |
|---|----------|------|------|-------|---------------|
| 2 | Security | api.ts | 15 | No rate limiting on login endpoint | Add rate limiter (100 req/15min) |

## 🟡 P3 Moderate — Fix Soon
[Table format same as above]

## 🟢 P4 Suggestion — Backlog
[Table format same as above]

## 🔒 OWASP Top 10 Status
| # | Category | Status |
|---|----------|--------|
| A01 | Broken Access Control | ✅ PASS / ⚠️ PARTIAL / ❌ FAIL |
| A02 | Cryptographic Failures | ✅ PASS / ⚠️ PARTIAL / ❌ FAIL |
| ... | ... | ... |

## 🔍 Dependency Scan
| Severity | Count | Details |
|----------|-------|---------|
| Critical | 0 | — |
| High | 0 | — |
| Medium | 2 | [package details] |
| Low | 5 | [package details] |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 3.3 — Verdict

Based on findings:

| Verdict | Condition |
|---------|-----------|
| ✅ **APPROVE** | Zero P1, zero P2 findings |
| 🟡 **APPROVE WITH NOTES** | Zero P1, some P2 findings (tracked for follow-up) |
| ❌ **CHANGES REQUIRED** | Any P1 findings remain |

---

## Phase 4: Remediation (If Needed)

### Step 4.1 — Fix Critical Issues

If P1/P2 issues found:

```markdown
⚠️ Action Required

[N] critical and [M] important issues found.

Options:
1. 🔧 **Fix now** — I'll fix all P1 issues immediately
2. 📋 **Create fix plan** — Generate tasks for each issue
3. 📝 **Document only** — Note issues and proceed (NOT recommended for P1)
```

### Step 4.2 — Re-Review After Fixes

After fixes are applied:
1. Re-run relevant checks (build, test, lint)
2. Re-verify ONLY the fixed areas (not full re-review)
3. Update the review report with fix status

### Step 4.3 — Final Approval

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ REVIEW APPROVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
P1 Critical:  0 (all resolved)
P2 Important: 2 (tracked)
Verdict:      🟡 APPROVE WITH NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
🚀 /context-deploy — Deploy to staging/production
📝 /context-docs   — Update documentation
🔀 /context-git    — Commit and merge
```

---

## When to Use
- After completing an implementation (`/context-work`)
- Before merging feature branches
- When reviewing existing code for improvement
- Periodic security audits
- Before deployment to production
- After external security incidents or advisories

## When to Skip
- Trivial changes (typos, comments-only)
- Prototyping / sandbox mode
- Already reviewed in the current session with no changes
