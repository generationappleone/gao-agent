---
name: Security Audit
description: Skill for conducting comprehensive security audits on applications — covering OWASP Top 10 checklist, dependency scanning, configuration review, authentication analysis, and structured reporting with severity classification.
---

# Security Audit Skill

## Overview
A security audit systematically evaluates an application's security posture by reviewing code, configurations, dependencies, and runtime behavior against established standards (OWASP Top 10, CIS Controls). This skill provides structured checklists, automated scanning commands, and reporting templates.

**References**:
- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)

---

## OWASP Top 10 Checklist

### A01: Broken Access Control
```markdown
- [ ] Role-based access control (RBAC) implemented
- [ ] Server-side authorization on every endpoint
- [ ] IDOR prevention (users can only access their own resources)
- [ ] CORS properly configured (not wildcard *)
- [ ] Directory listing disabled
- [ ] JWT claims validated (role, permissions, expiry)
- [ ] Admin endpoints require admin role
- [ ] File upload restricted to allowed types/sizes
- [ ] Rate limiting on sensitive endpoints

# Test:
- Login as User A, try accessing User B's resources
- Access admin endpoints without admin role
- Send requests without Authorization header
- Modify JWT claims (role: user → admin)
```

### A02: Cryptographic Failures
```markdown
- [ ] TLS 1.2+ enforced (no TLS 1.0/1.1)
- [ ] Passwords hashed with bcrypt (12+ rounds)
- [ ] No MD5/SHA1 for passwords
- [ ] Sensitive data encrypted at rest (AES-256-GCM)
- [ ] No hardcoded secrets in code
- [ ] Encryption keys managed securely (env vars/vault)
- [ ] PII encrypted in database
- [ ] HSTS header enabled
- [ ] SSL certificate valid and not expiring soon
```

### A03: Injection
```markdown
- [ ] Parameterized queries for all database operations
- [ ] No string concatenation in SQL
- [ ] ORM used (Prisma, Sequelize, Eloquent)
- [ ] Input validation on all endpoints (Zod/Joi)
- [ ] Output encoding for HTML responses
- [ ] No eval(), new Function(), or exec() with user input
- [ ] Command injection prevented (no shell exec with user data)
- [ ] LDAP injection prevented (if applicable)
```

### A04: Insecure Design
```markdown
- [ ] Threat modeling completed
- [ ] Business logic abuse cases identified
- [ ] Rate limiting on authentication flows
- [ ] Account lockout after failed attempts
- [ ] Transaction limits enforced
- [ ] Input validation at business logic level
```

### A05: Security Misconfiguration
```markdown
- [ ] Default credentials changed
- [ ] Debug mode disabled in production
- [ ] Stack traces not exposed to users
- [ ] Unnecessary HTTP methods disabled
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)
- [ ] Server version not exposed
- [ ] Admin panels not publicly accessible
- [ ] .env files not in git
- [ ] CORS not set to wildcard (*)
```

### A06: Vulnerable Components
```markdown
- [ ] No known vulnerabilities in dependencies
- [ ] Dependencies regularly updated
- [ ] Automated vulnerability scanning (npm audit, Snyk)
- [ ] Lock files committed (package-lock.json)
- [ ] No unnecessary dependencies
```

### A07: Authentication Failures
```markdown
- [ ] Strong password policy enforced
- [ ] MFA available/required for admin
- [ ] Brute force protection (rate limiting + lockout)
- [ ] Session tokens regenerated after login
- [ ] Secure cookie flags (HttpOnly, Secure, SameSite)
- [ ] JWT expiry short (15 min access, 7d refresh)
- [ ] Refresh token rotation implemented
- [ ] Logout invalidates tokens server-side
- [ ] Password reset tokens expire (1 hour)
```

### A08: Software and Data Integrity
```markdown
- [ ] CI/CD pipeline secured
- [ ] Dependencies verified (checksums/signatures)
- [ ] No unsigned code in production
- [ ] Subresource Integrity (SRI) for CDN scripts
- [ ] Code reviewed before merge
```

### A09: Logging & Monitoring
```markdown
- [ ] Login attempts logged (success + failure)
- [ ] Access control failures logged
- [ ] Input validation failures logged
- [ ] Sensitive operations logged (admin actions)
- [ ] Logs do NOT contain passwords/tokens/PII
- [ ] Centralized logging (ELK/Datadog/CloudWatch)
- [ ] Alerting on security events
- [ ] Log tamper protection
```

### A10: SSRF
```markdown
- [ ] URL allowlists for external requests
- [ ] No user-controlled URLs in server-side requests
- [ ] Internal network access blocked (169.254.x.x, 10.x.x.x)
- [ ] DNS rebinding protection
```

---

## Automated Scanning Commands

```bash
# ── Dependency vulnerabilities ──
npm audit                           # Node.js vulnerabilities
npm audit --production              # Production only
npx snyk test                       # Snyk vulnerability scan
pip-audit                           # Python dependencies

# ── Static analysis ──
npx semgrep --config auto .         # Semgrep SAST
npx eslint --ext .ts,.js src/       # ESLint security rules

# ── Secret detection ──
gitleaks detect --source .          # Scan for hardcoded secrets
trufflehog filesystem --directory . # Deep secret scan

# ── Docker security ──
docker scout cves myapp:latest      # Docker image vulnerabilities
trivy image myapp:latest            # Trivy container scan

# ── SSL/TLS ──
nmap --script ssl-enum-ciphers -p 443 myapp.com
testssl.sh myapp.com                # Comprehensive SSL test

# ── Web application ──
nikto -h https://myapp.com          # Web server scan
zap-cli quick-scan https://myapp.com  # OWASP ZAP scan

# ── Headers ──
curl -sI https://myapp.com | grep -iE '(x-frame|x-content|strict-transport|content-security|x-xss|referrer)'
```

---

## Audit Report Template

```markdown
# Security Audit Report
## Application: MyApp API v1.2.3
## Date: 2024-01-15
## Auditor: Security Team

---

### Executive Summary
| Severity | Count |
|----------|-------|
| 🔴 Critical | 0 |
| 🟠 High | 2 |
| 🟡 Medium | 5 |
| 🔵 Low | 8 |
| ℹ️ Info | 3 |

Overall Risk Level: **MEDIUM**

---

### Findings

#### [HIGH] H-001: Missing Rate Limiting on Login
- **Category**: A07 - Authentication Failures
- **Location**: POST /api/auth/login
- **Description**: No rate limiting on login endpoint, enabling brute force attacks.
- **Evidence**: 1000 login attempts in 10 seconds without throttling.
- **Impact**: Account compromise through credential stuffing.
- **Remediation**: Implement rate limiting (5 attempts per 15 minutes per IP + email).
- **Priority**: P1 - Fix immediately
- **Status**: ⬜ Open

#### [MEDIUM] M-001: Missing CSP Header
- **Category**: A05 - Security Misconfiguration
- **Location**: All HTTP responses
- **Description**: Content-Security-Policy header not set.
- **Impact**: Increased risk of XSS attacks.
- **Remediation**: Add strict CSP header with helmet.js.
- **Priority**: P2 - Fix within sprint
- **Status**: ⬜ Open

---

### Recommendations
1. Implement rate limiting on all authentication endpoints
2. Add Content Security Policy headers
3. Enable MFA for admin accounts
4. Set up automated dependency scanning in CI/CD
5. Conduct quarterly security audits

---

### Tools Used
- Semgrep v1.50.0 (SAST)
- npm audit (dependency scanning)
- Nmap 7.94 (network/SSL scanning)
- Burp Suite Professional (DAST)
- Gitleaks v8.18 (secret detection)
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Checklist-driven** | Use OWASP Top 10 as systematic baseline |
| **Automated + manual** | Automated scans find known issues; manual testing finds logic flaws |
| **Severity classification** | Critical/High/Medium/Low/Info with clear criteria |
| **Evidence-based** | Include reproduction steps and evidence for each finding |
| **Prioritized** | P1 (immediate), P2 (sprint), P3 (backlog), P4 (accepted risk) |
| **Regular cadence** | Quarterly audits + continuous scanning in CI/CD |
| **Track remediation** | Follow up on findings until resolved |
| **Scope** | Define audit scope clearly (app, infra, dependencies) |
| **Tools** | Combine SAST, DAST, SCA, and manual review |
| **Report** | Executive summary + detailed findings with remediation |

---

## Rules Integration
- **Checklist**: OWASP Top 10 verification for each category
- **Automated**: npm audit, Semgrep, Gitleaks, Nmap, Nikto
- **Manual**: IDOR testing, auth bypass, business logic review
- **Reporting**: Structured findings with severity, evidence, remediation
- **Cadence**: Quarterly audits, continuous scanning in CI/CD
