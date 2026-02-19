---
name: Security Audit
description: Skill for conducting comprehensive security audits on applications — covering OWASP Top 10 checklist, dependency scanning, configuration review, authentication analysis, and structured reporting with severity classification.
---

# Security Audit Skill

## Purpose
This skill provides a structured methodology for conducting **full security audits** on applications. It serves as the **orchestrator skill** that coordinates specialized security skills (secrets-management, secure-code-patterns, threat-modeling, data-privacy) into a unified audit process.

---

## Audit Modes

### Full Audit Mode
Complete security assessment covering all OWASP Top 10 categories, dependency scanning, configuration review, and threat assessment. Use for initial audits or periodic reviews.

### Quick Scan Mode
Focused scan on high-risk areas: secrets exposure, dependency vulnerabilities, and critical misconfigurations. Use for pre-deployment checks.

### Targeted Mode
Deep dive into a specific security domain (auth, injection, access control, etc.). Use when investigating a specific concern.

---

## Decision Tree — Routing to Specialized Skills

```
Security Audit Start
├── Secrets & Credentials → skills/secrets-management/SKILL.md
│   └── Hardcoded keys, .env exposure, secret rotation
├── Code Patterns → skills/secure-code-patterns/SKILL.md
│   └── Input validation, output encoding, parameterized queries
├── Threat Analysis → skills/threat-modeling/SKILL.md
│   └── STRIDE analysis, trust boundaries, attack surface
├── Data Privacy → skills/data-privacy/SKILL.md
│   └── PII handling, consent, data retention, subject rights
├── Dependency Vulnerabilities → skills/snyk/SKILL.md or npm audit
│   └── Known CVEs, outdated packages, license issues
├── XSS Prevention → skills/xss-security/SKILL.md
│   └── CSP, output encoding, DOM sanitization
├── DDoS & Rate Limiting → skills/ddos-protection/SKILL.md
│   └── Rate limiting, Cloudflare, graceful degradation
├── WAF Configuration → skills/waf/SKILL.md
│   └── Rules, bot protection, OWASP CRS
├── Encryption → skills/aes-256/SKILL.md
│   └── AES-256-GCM, key management, field-level encryption
└── Compliance → skills/iso-27001/SKILL.md + skills/nist-csf/SKILL.md
    └── Control mapping, risk assessment, audit preparation
```

---

## OWASP Top 10 (2021) Checklist

### A01: Broken Access Control
```
Check:
- [ ] Role-based access control (RBAC) implemented on all endpoints
- [ ] Authorization checks on every controller/route (not just frontend)
- [ ] IDOR protection — users cannot access other users' resources
- [ ] Directory traversal prevention (path validation)
- [ ] CORS configured restrictively (not wildcard *)
- [ ] JWT/session cannot be tampered with
- [ ] Admin routes protected with proper middleware
- [ ] API rate limiting in place
```

**How to check:**
```bash
# Find routes without auth middleware
grep -rn "router\.\(get\|post\|put\|delete\)" --include="*.ts" --include="*.js" | grep -v "auth\|middleware\|protect\|guard"
# Laravel
grep -rn "Route::" --include="*.php" -not -path '*/vendor/*' | grep -v "middleware\|auth\|guest"
```

### A02: Cryptographic Failures
```
Check:
- [ ] Passwords hashed with bcrypt (cost ≥ 12) or Argon2id
- [ ] Sensitive data encrypted at rest (AES-256-GCM)
- [ ] TLS 1.2+ enforced for data in transit
- [ ] No sensitive data in URLs or query parameters
- [ ] No sensitive data in logs
- [ ] Cryptographic keys stored in vault/env (not code)
- [ ] No deprecated algorithms (MD5, SHA1, DES, RC4)
```

**How to check:**
```bash
# Find potential weak hashing
grep -rn "md5\|sha1\|SHA1\|MD5" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*'
# Find hardcoded secrets
grep -rn "password\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*' | grep -v "test\|spec\|mock\|example\|sample"
```

### A03: Injection
```
Check:
- [ ] All SQL uses parameterized queries (no string concatenation)
- [ ] ORM used for database access (Prisma, Eloquent, SQLAlchemy)
- [ ] User input validated and sanitized before processing
- [ ] No eval(), exec(), or dynamic code execution with user input
- [ ] No shell command injection (child_process with user input)
- [ ] Template engines auto-escape output
- [ ] LDAP injection prevention (if applicable)
```

**How to check:**
```bash
# Find potential SQL injection
grep -rn "query\|execute\|raw" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*' | grep -i "concat\|\+\|format\|%s\|\${"
# Find dangerous functions
grep -rn "eval\|exec\|system\|passthru\|shell_exec\|popen" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*'
```

### A04: Insecure Design
```
Check:
- [ ] Business logic has server-side validation (not just frontend)
- [ ] Rate limiting on authentication endpoints
- [ ] Account lockout after failed attempts
- [ ] Secure password reset flow (time-limited tokens)
- [ ] No sensitive operations via GET requests
- [ ] Proper error messages (no stack traces to users)
```

### A05: Security Misconfiguration
```
Check:
- [ ] Debug mode disabled in production
- [ ] Default credentials changed
- [ ] Unnecessary features/ports disabled
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options, etc.)
- [ ] Error pages don't reveal stack traces
- [ ] Directory listing disabled
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
```

**How to check:**
```bash
# Check for debug mode
grep -rn "DEBUG\s*=\s*[Tt]rue\|APP_DEBUG\s*=\s*true\|NODE_ENV.*development" -not -path '*/node_modules/*' -not -path '*/vendor/*' --include="*.env" --include="*.env.*"
```

### A06: Vulnerable and Outdated Components
```
Check:
- [ ] No known vulnerabilities in dependencies (npm audit, composer audit)
- [ ] Dependencies up to date (no EOL versions)
- [ ] License compliance verified
- [ ] Only necessary dependencies installed
- [ ] Lock files committed (package-lock.json, composer.lock)
```

### A07: Identification and Authentication Failures
```
Check:
- [ ] Strong password policy enforced (min 8 chars, complexity)
- [ ] Multi-factor authentication available (if applicable)
- [ ] Session management secure (httpOnly, Secure, SameSite cookies)
- [ ] JWT properly configured (algorithm, expiry, refresh rotation)
- [ ] Brute force protection (rate limiting, CAPTCHA)
- [ ] Session invalidation on logout
- [ ] Password reset tokens are single-use and time-limited
```

### A08: Software and Data Integrity Failures
```
Check:
- [ ] CI/CD pipeline secured (no arbitrary code execution)
- [ ] Dependency integrity verified (lockfiles, checksums)
- [ ] No unsafe deserialization of user input
- [ ] Signed releases/deployments
- [ ] Subresource Integrity (SRI) for CDN resources
```

### A09: Security Logging and Monitoring Failures
```
Check:
- [ ] Authentication events logged (login, logout, failed attempts)
- [ ] Authorization failures logged
- [ ] Input validation failures logged
- [ ] High-value transactions logged
- [ ] Logs don't contain sensitive data (passwords, tokens, PII)
- [ ] Log injection prevention (sanitized log input)
- [ ] Alerting configured for suspicious activity
```

### A10: Server-Side Request Forgery (SSRF)
```
Check:
- [ ] URL validation for user-supplied URLs
- [ ] Whitelist allowed domains/IPs for outbound requests
- [ ] No internal network access from user-supplied URLs
- [ ] DNS rebinding protection
- [ ] Metadata endpoint blocking (cloud environments)
```

---

## Report Format

### Summary Table
```markdown
## Security Audit Summary

| Category | Status | Findings | Severity |
|----------|--------|----------|----------|
| A01: Broken Access Control | ✅ Pass / ⚠️ Partial / ❌ Fail | [count] | [highest] |
| A02: Cryptographic Failures | ✅ / ⚠️ / ❌ | [count] | [highest] |
| A03: Injection | ✅ / ⚠️ / ❌ | [count] | [highest] |
| ... | ... | ... | ... |
| Secrets Exposure | ✅ / ⚠️ / ❌ | [count] | [highest] |
| Dependency Vulnerabilities | ✅ / ⚠️ / ❌ | [count] | [highest] |
| Privacy Compliance | ✅ / ⚠️ / ❌ | [count] | [highest] |
```

### Finding Format
```markdown
### Finding #[N]: [Title]

**Severity:** 🔴 P1 Critical / 🟡 P2 Important / 🟢 P3 Suggestion
**Category:** [OWASP category]
**File(s):** `path/to/file.ts:42`
**Description:** [What the vulnerability is]
**Impact:** [What could happen if exploited]
**Recommendation:** [How to fix it]
**Code Example:**
```[language]
// Before (vulnerable)
...

// After (fixed)
...
```
```

---

## Security Review Exit Criteria

A security audit is COMPLETE when:
- [ ] All 10 OWASP categories have been checked
- [ ] Secrets scan completed (no hardcoded credentials)
- [ ] Dependency vulnerability scan completed
- [ ] Authentication implementation reviewed
- [ ] All P1 Critical findings have remediation plans
- [ ] Report generated with prioritized findings
- [ ] Data privacy assessment completed (if PII present)

---

## Integration with Rules

This skill enforces and validates:
- `rules/developer-security.md` — 4-layer security model
- `rules/iso-27000-compliance.md` — Compliance controls
- `rules/uu-pdp-compliance.md` — Indonesian data privacy (if applicable)
- `rules/database-design.md` — Secure database patterns
- `rules/production-code-standards.md` — Zero-hallucination verification
