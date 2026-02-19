---
name: Security Code Review
description: Skill for conducting comprehensive security code reviews using OWASP Top 10, SAST/DAST patterns, and Hack23 ISMS secure development policy to identify and remediate vulnerabilities.
---

# Security Code Review Skill

## Overview
This skill guides comprehensive security code reviews combining the **OWASP Top 10**, **SAST/DAST analysis patterns**, and **Hack23 ISMS secure development policy** to systematically identify, classify, and remediate security vulnerabilities in code.

---

## 1. OWASP Top 10 (2021) — Review Checklist

### A01: Broken Access Control

#### ✅ Review For:
```typescript
// ❌ VULNERABLE: No ownership check (IDOR)
app.get('/api/users/:id', async (req, res) => {
  const user = await db.users.findById(req.params.id);  // Any user can access any profile
  res.json(user);
});

// ✅ SECURE: Ownership verification
app.get('/api/users/:id', authMiddleware, async (req, res) => {
  const user = await db.users.findById(req.params.id);
  if (!user) return res.status(404).json({ error: 'Not found' });
  if (user.id !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  res.json(user);
});
```

**Checklist:**
- [ ] Every endpoint verifies user identity AND authorization
- [ ] IDOR prevented — users cannot access other users' data by changing IDs
- [ ] CORS configured correctly (deny by default)
- [ ] Directory listing disabled
- [ ] JWT/session tokens validated on every request
- [ ] Rate limiting on sensitive endpoints
- [ ] Principle of least privilege enforced

### A02: Cryptographic Failures

**Checklist:**
- [ ] No hardcoded secrets, keys, or passwords in code
- [ ] Passwords hashed with bcrypt/Argon2 (cost factor ≥ 12)
- [ ] AES-256-GCM for symmetric encryption (NOT AES-ECB, DES, 3DES)
- [ ] RSA ≥ 2048-bit or ECDSA ≥ P-256 for asymmetric
- [ ] TLS 1.2+ enforced (TLS 1.3 preferred)
- [ ] No MD5 or SHA-1 for security purposes
- [ ] Sensitive data encrypted at rest AND in transit
- [ ] Key rotation mechanism exists
- [ ] Secrets stored in vault (not environment variables in production)

### A03: Injection

```typescript
// ❌ VULNERABLE: SQL Injection
const query = `SELECT * FROM users WHERE email = '${email}'`;

// ✅ SECURE: Parameterized query
const query = 'SELECT * FROM users WHERE email = $1';
const result = await db.query(query, [email]);

// ❌ VULNERABLE: NoSQL Injection
db.users.find({ email: req.body.email });  // If email = { $gt: "" }

// ✅ SECURE: Type validation
const email = z.string().email().parse(req.body.email);
db.users.find({ email });

// ❌ VULNERABLE: Command Injection
exec(`ping ${userInput}`);

// ✅ SECURE: Use specific APIs, never shell commands with user input
import { execFile } from 'child_process';
execFile('ping', ['-c', '4', validatedHost]);
```

**Checklist:**
- [ ] All SQL uses parameterized queries or ORM
- [ ] All user input validated and sanitized
- [ ] No `eval()`, `exec()`, or template literals with user input
- [ ] GraphQL depth/complexity limits set
- [ ] NoSQL query operators blocked from user input

### A04: Insecure Design

**Checklist:**
- [ ] Threat modeling performed for critical flows
- [ ] Business logic abuse scenarios considered
- [ ] Rate limiting on authentication, registration, password reset
- [ ] Account lockout after failed attempts
- [ ] Anti-automation controls on forms (CAPTCHA where appropriate)
- [ ] Separation of duties for sensitive operations

### A05: Security Misconfiguration

**Checklist:**
- [ ] Default credentials changed
- [ ] Debug mode disabled in production
- [ ] Stack traces not exposed to users
- [ ] Unnecessary HTTP methods disabled
- [ ] Security headers set (CSP, X-Frame-Options, HSTS, etc.)
- [ ] CORS origin whitelist (not `*`)
- [ ] Directory listing disabled
- [ ] Unused features/endpoints removed

### A06: Vulnerable and Outdated Components

**Checklist:**
- [ ] All dependencies have known version (no `latest` or `*`)
- [ ] `npm audit` / `pip audit` / `dotnet list package --vulnerable` run in CI
- [ ] No dependencies with known CVEs (Critical/High)
- [ ] Base Docker images scanned and pinned
- [ ] License compatibility verified
- [ ] Unused dependencies removed

### A07: Identification and Authentication Failures

```typescript
// ✅ SECURE: Password policy enforcement
const passwordSchema = z.string()
  .min(12, 'Minimum 12 characters')
  .regex(/[A-Z]/, 'Requires uppercase')
  .regex(/[a-z]/, 'Requires lowercase')
  .regex(/[0-9]/, 'Requires digit')
  .regex(/[^A-Za-z0-9]/, 'Requires special character');

// ✅ SECURE: Account lockout
if (loginAttempts >= 5) {
  await lockAccount(userId, 15 * 60 * 1000); // 15 min lockout
  throw new AppError('Account locked. Try again later.', 429);
}
```

**Checklist:**
- [ ] Password minimum 12 characters, complexity enforced
- [ ] Account lockout after 5 failed attempts
- [ ] MFA available for sensitive accounts
- [ ] Session tokens regenerated after login
- [ ] Sessions expire (idle timeout 15-30 min)
- [ ] Passwords stored with bcrypt/Argon2
- [ ] Password reset tokens single-use, time-limited

### A08: Software and Data Integrity Failures

**Checklist:**
- [ ] Dependency integrity verified (lockfiles committed)
- [ ] CI/CD pipeline secured (no arbitrary code execution)
- [ ] Subresource Integrity (SRI) for CDN scripts
- [ ] Signed commits/releases where applicable
- [ ] Deserialization of untrusted data protected

### A09: Security Logging and Monitoring Failures

**Checklist:**
- [ ] Authentication events logged (login, logout, failed attempts)
- [ ] Authorization failures logged
- [ ] Input validation failures logged
- [ ] High-value transactions logged with audit trail
- [ ] Logs contain timestamp, user ID, IP address, action
- [ ] Logs do NOT contain passwords, tokens, PII in plain text
- [ ] Alerting configured for anomalous patterns

### A10: Server-Side Request Forgery (SSRF)

```typescript
// ❌ VULNERABLE: Unvalidated URL fetch
app.get('/fetch', async (req, res) => {
  const response = await fetch(req.query.url);  // Can access internal services!
  res.json(await response.json());
});

// ✅ SECURE: URL validation + allowlist
const ALLOWED_DOMAINS = ['api.github.com', 'api.stripe.com'];
app.get('/fetch', async (req, res) => {
  const url = new URL(req.query.url);
  if (!ALLOWED_DOMAINS.includes(url.hostname)) {
    return res.status(400).json({ error: 'Domain not allowed' });
  }
  if (url.protocol !== 'https:') {
    return res.status(400).json({ error: 'HTTPS required' });
  }
  // Also block internal IPs (10.x, 172.16.x, 192.168.x, 127.x, 169.254.x)
  const response = await fetch(url.toString());
  res.json(await response.json());
});
```

---

## 2. SAST/DAST Patterns

### SAST (Static Application Security Testing)

SAST scans source code **before runtime**. Look for these patterns:

#### Taint Analysis Patterns
```
Source (user input) → Propagation → Sink (dangerous function)

Sources:          req.body, req.params, req.query, req.headers, process.env, file reads
Propagation:      string concatenation, template literals, object spread
Sinks:            db.query(), exec(), eval(), fs.write(), res.send(), redirect(), innerHTML
```

#### Regex for Dangerous Patterns (Grep/SAST Rules)
```bash
# Hardcoded secrets
grep -rn "password\s*=\s*['\"]" --include="*.{ts,js,py,cs,java}"
grep -rn "api[_-]?key\s*=\s*['\"]" --include="*.{ts,js,py,cs,java}"
grep -rn "secret\s*=\s*['\"]" --include="*.{ts,js,py,cs,java}"

# SQL Injection risk
grep -rn "query.*\$\{" --include="*.{ts,js}"           # Template literals in SQL
grep -rn "f\".*SELECT" --include="*.py"                  # f-strings in SQL
grep -rn "\"SELECT.*\" \+" --include="*.{java,cs}"       # String concat in SQL

# Command injection
grep -rn "exec\(.*req\." --include="*.{ts,js}"
grep -rn "os\.system\(" --include="*.py"
grep -rn "subprocess\.call.*shell=True" --include="*.py"

# XSS risk
grep -rn "innerHTML\s*=" --include="*.{ts,js,tsx,jsx}"
grep -rn "dangerouslySetInnerHTML" --include="*.{tsx,jsx}"
grep -rn "\| safe" --include="*.html"                    # Django/Jinja2
grep -rn "Html\.Raw\(" --include="*.cshtml"              # ASP.NET

# Insecure crypto
grep -rn "createHash.*md5\|sha1" --include="*.{ts,js}"
grep -rn "hashlib\.md5\|hashlib\.sha1" --include="*.py"
grep -rn "DES\|3DES\|RC4\|ECB" --include="*.{ts,js,py,cs,java}"
```

### DAST (Dynamic Application Security Testing)

DAST tests the **running application**. Key test areas:

| Test | Method |
|------|--------|
| **Authentication bypass** | Test endpoints without auth token |
| **IDOR** | Change resource IDs in URLs |
| **SQL Injection** | Send `' OR 1=1 --` in inputs |
| **XSS** | Send `<script>alert(1)</script>` in inputs |
| **CSRF** | Remove CSRF token from POST requests |
| **SSRF** | Send `http://169.254.169.254/` as URL parameter |
| **Header injection** | Send `\r\nX-Injected: true` in headers |
| **Rate limit bypass** | Send 100+ requests rapidly |
| **Directory traversal** | Send `../../etc/passwd` in file paths |
| **HTTP verb tampering** | Try DELETE/PUT on GET-only endpoints |

### Recommended SAST/DAST Tools
| Type | Tool | Languages |
|------|------|-----------|
| **SAST** | SonarQube / SonarCloud | Multi-language |
| **SAST** | Semgrep | Multi-language |
| **SAST** | CodeQL (GitHub) | Multi-language |
| **SAST** | Bandit | Python |
| **SAST** | ESLint Security Plugin | JavaScript/TypeScript |
| **SAST** | SpotBugs + FindSecBugs | Java |
| **DAST** | OWASP ZAP | Any web app |
| **DAST** | Burp Suite | Any web app |
| **SCA** | Snyk | Dependencies |
| **SCA** | npm audit / pip audit | npm / Python |
| **Container** | Trivy / Docker Scout | Docker images |

---

## 3. Hack23 ISMS Secure Development Policy

### Secure Development Lifecycle (SDL)

The Hack23 ISMS policy requires integrating security at every stage of development:

#### Phase 1: Requirements & Design
- [ ] **Threat modeling** performed (STRIDE methodology)
  - **S**poofing, **T**ampering, **R**epudiation, **I**nformation disclosure, **D**oS, **E**levation of privilege
- [ ] Security requirements documented alongside functional requirements
- [ ] Data classification applied (Public, Internal, Confidential, Restricted)
- [ ] Privacy Impact Assessment (PIA) if PII is involved
- [ ] Architecture reviewed for attack surface minimization

#### Phase 2: Implementation
- [ ] Secure coding guidelines followed (OWASP)
- [ ] Input validation on ALL external inputs
- [ ] Output encoding applied (context-dependent: HTML, URL, JS, CSS, SQL)
- [ ] Least privilege applied to service accounts and roles
- [ ] Secrets management via vault (not in code or env vars)
- [ ] Error handling does not expose internal details
- [ ] Logging includes security events without sensitive data

#### Phase 3: Verification
- [ ] SAST scan passed (zero Critical/High findings)
- [ ] DAST scan passed on staging environment
- [ ] Dependency scan passed (no known Critical CVEs)
- [ ] Peer security code review completed
- [ ] Penetration testing for critical applications
- [ ] Security regression tests in CI/CD

#### Phase 4: Release & Operations
- [ ] Security configuration reviewed (production hardening)
- [ ] Monitoring and alerting configured
- [ ] Incident response plan documented
- [ ] Vulnerability disclosure process defined
- [ ] Patch management SLA defined (Critical: 24h, High: 7d, Medium: 30d, Low: 90d)

### Security Review Report Template

```markdown
# Security Code Review Report

## Summary
- **Project:** [Name]
- **Reviewer:** [Name]
- **Date:** [Date]
- **Scope:** [Files/modules reviewed]
- **Risk Rating:** Critical | High | Medium | Low

## Findings

### Finding #1: [Title]
- **Severity:** Critical | High | Medium | Low
- **OWASP Category:** A01-A10
- **CWE:** CWE-XXX
- **Location:** `file.ts:123`
- **Description:** [What the vulnerability is]
- **Impact:** [What an attacker could do]
- **Proof of Concept:** [Reproduction steps]
- **Remediation:** [How to fix it]
- **Code Fix:**
  ```diff
  - vulnerable code
  + secure code
  ```

## Statistics
| Severity | Count |
|----------|-------|
| Critical | 0     |
| High     | 0     |
| Medium   | 0     |
| Low      | 0     |
| Info     | 0     |

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

## Sign-off
- [ ] All Critical/High findings remediated
- [ ] SAST scan passed
- [ ] Ready for deployment
```

---

## 4. CI/CD Security Gate

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

      - name: Semgrep SAST
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/owasp-top-ten
            p/javascript
            p/typescript

  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=high
      - uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  container-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t myapp:scan .
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:scan'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'
```

## Rules Integration
- **ISO 27001/A.14**: Secure development policy aligns with ISMS requirements
- **Developer Security**: Extends the 4-layer security model with formal review process
- **Dependencies**: SCA scanning validates the dependency management rule
