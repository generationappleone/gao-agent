---
name: Threat Modeling
description: Skill for threat modeling using STRIDE methodology — covering trust boundary identification, threat enumeration, attack surface analysis, risk scoring, and mitigation strategies for web applications.
---

# Threat Modeling Skill

## Overview
Threat modeling is a structured approach to identifying, quantifying, and mitigating security threats in software systems. It helps teams proactively find vulnerabilities during design, before they become exploitable bugs in production.

**References**:
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [Microsoft STRIDE](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [OWASP Threat Modeling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html)

---

## STRIDE Methodology

| Threat | Description | Security Property | Example |
|--------|-------------|-------------------|---------|
| **S**poofing | Impersonating another user or system | Authentication | Stolen JWT, session hijacking |
| **T**ampering | Modifying data or code | Integrity | SQL injection, parameter tampering |
| **R**epudiation | Denying actions performed | Non-repudiation | Missing audit logs |
| **I**nformation Disclosure | Exposing data to unauthorized parties | Confidentiality | API leaking PII, verbose errors |
| **D**enial of Service | Making system unavailable | Availability | DDoS, resource exhaustion |
| **E**levation of Privilege | Gaining unauthorized access | Authorization | IDOR, broken access control |

---

## Threat Modeling Process

### Step 1: Define System Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     TRUST BOUNDARY: Internet                 │
│                                                              │
│  ┌──────────┐    HTTPS     ┌──────────┐    HTTP    ┌──────┐ │
│  │  Browser  │────────────▶│   CDN/   │──────────▶ │ WAF  │ │
│  │  (React)  │◀────────────│CloudFlare│◀────────── │      │ │
│  └──────────┘              └──────────┘            └──┬───┘ │
│                                                       │     │
├───────────────────────────────────────────────────────┼─────┤
│                  TRUST BOUNDARY: DMZ                  │     │
│                                                       ▼     │
│                                              ┌──────────┐   │
│                                              │  Nginx   │   │
│                                              │  (LB)    │   │
│                                              └────┬─────┘   │
│                                                   │         │
├───────────────────────────────────────────────────┼─────────┤
│               TRUST BOUNDARY: Application         │         │
│                                                   ▼         │
│  ┌──────────┐   JWT    ┌──────────┐    SQL   ┌─────────┐   │
│  │  Auth    │◀────────▶│   API    │─────────▶│PostgreSQL│  │
│  │ Service  │          │  Server  │          │  (RDS)   │   │
│  └──────────┘          └────┬─────┘          └─────────┘   │
│                              │                              │
│                         ┌────▼─────┐    ┌──────────┐       │
│                         │  Redis   │    │   S3     │       │
│                         │ (Cache)  │    │ (Files)  │       │
│                         └──────────┘    └──────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Step 2: Identify Threats (STRIDE per Element)

```markdown
## API Server Threats

### Spoofing
| ID | Threat | Risk | Mitigation |
|----|--------|------|------------|
| S1 | JWT token theft via XSS | HIGH | HttpOnly cookies, CSP, SameSite=Strict |
| S2 | API key leakage in client code | HIGH | Server-side API calls only, env vars |
| S3 | Session fixation | MEDIUM | Regenerate session on login |

### Tampering
| ID | Threat | Risk | Mitigation |
|----|--------|------|------------|
| T1 | SQL injection via user input | CRITICAL | Parameterized queries, ORM |
| T2 | Mass assignment (over-posting) | HIGH | DTOs with explicit field lists |
| T3 | JWT payload manipulation | HIGH | Signature verification, short expiry |
| T4 | CSRF on state-changing endpoints | MEDIUM | CSRF tokens, SameSite cookies |

### Repudiation
| ID | Threat | Risk | Mitigation |
|----|--------|------|------------|
| R1 | No audit trail for admin actions | MEDIUM | Structured audit logging |
| R2 | Log injection/tampering | MEDIUM | Log sanitization, immutable log storage |

### Information Disclosure
| ID | Threat | Risk | Mitigation |
|----|--------|------|------------|
| I1 | Stack traces in error responses | HIGH | Generic error messages, log details server-side |
| I2 | Sensitive data in API responses | HIGH | Response DTOs, field filtering |
| I3 | PII in logs | MEDIUM | Log redaction for email, phone, SSN |
| I4 | Directory listing enabled | LOW | Disable autoindex in Nginx |

### Denial of Service
| ID | Threat | Risk | Mitigation |
|----|--------|------|------------|
| D1 | API rate limiting absent | HIGH | Rate limiter (100 req/min per IP) |
| D2 | Large file upload exhaustion | MEDIUM | File size limits (10MB), validation |
| D3 | ReDoS via user input | MEDIUM | Bounded regex, input length limits |
| D4 | Slow loris attack | LOW | Nginx timeout configuration |

### Elevation of Privilege
| ID | Threat | Risk | Mitigation |
|----|--------|------|------------|
| E1 | IDOR (access other users' data) | CRITICAL | Ownership checks in every query |
| E2 | Broken role-based access | HIGH | Middleware auth + role checks |
| E3 | Privilege escalation via API | HIGH | Server-side role validation |
| E4 | Path traversal in file access | HIGH | Sanitize paths, allowlist directories |
```

### Step 3: Risk Scoring (DREAD)

```markdown
| Factor | Scale | Description |
|--------|-------|-------------|
| **D**amage | 1-10 | How bad if exploited? |
| **R**eproducibility | 1-10 | How easy to reproduce? |
| **E**xploitability | 1-10 | How easy to exploit? |
| **A**ffected Users | 1-10 | How many users affected? |
| **D**iscoverability | 1-10 | How easy to discover? |

Total = (D + R + E + A + D) / 5

| Score | Rating | Action |
|-------|--------|--------|
| 8-10 | CRITICAL | Fix immediately, block release |
| 5-7 | HIGH | Fix before next release |
| 3-4 | MEDIUM | Plan fix in upcoming sprint |
| 1-2 | LOW | Accept risk or fix when convenient |
```

### Step 4: Example Risk Assessment

```markdown
| Threat ID | Threat | D | R | E | A | D | Score | Rating |
|-----------|--------|---|---|---|---|---|-------|--------|
| T1 | SQL Injection | 10 | 10 | 8 | 10 | 9 | 9.4 | CRITICAL |
| E1 | IDOR | 9 | 9 | 7 | 8 | 7 | 8.0 | CRITICAL |
| I1 | Stack traces exposed | 6 | 10 | 10 | 10 | 10 | 9.2 | CRITICAL |
| S1 | JWT theft via XSS | 8 | 7 | 6 | 8 | 6 | 7.0 | HIGH |
| D1 | No rate limiting | 7 | 10 | 10 | 10 | 8 | 9.0 | CRITICAL |
| T4 | CSRF | 6 | 8 | 5 | 6 | 5 | 6.0 | HIGH |
| R1 | No audit trail | 4 | 10 | 10 | 5 | 3 | 6.4 | HIGH |
| I4 | Directory listing | 3 | 10 | 10 | 2 | 8 | 6.6 | HIGH |
| D4 | Slow loris | 5 | 7 | 4 | 8 | 3 | 5.4 | HIGH |
```

---

## Mitigation Checklist

```markdown
### Authentication & Session
- [ ] JWT stored in HttpOnly cookies (not localStorage)
- [ ] Short-lived access tokens (15min) + refresh tokens (7d)
- [ ] Session invalidation on password change
- [ ] Brute force protection (account lockout after 5 attempts)
- [ ] MFA for admin accounts

### Authorization
- [ ] RBAC middleware on all protected endpoints
- [ ] Ownership check on every resource access (IDOR prevention)
- [ ] Principle of least privilege for API keys
- [ ] Server-side role validation (never trust client)

### Input Validation
- [ ] Parameterized queries / ORM for all database access
- [ ] Input validation (type, length, format) on server side
- [ ] File upload validation (type, size, content-type)
- [ ] Output encoding for XSS prevention

### Data Protection
- [ ] TLS 1.3 for all connections
- [ ] Encryption at rest for sensitive data
- [ ] PII redaction in logs
- [ ] Secure error responses (no stack traces)

### Infrastructure
- [ ] Rate limiting (100 req/min per IP)
- [ ] WAF (Cloudflare/AWS WAF)
- [ ] Security headers (CSP, HSTS, X-Frame-Options)
- [ ] Network segmentation (DB not publicly accessible)
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Shift left** | Threat model during design, not after deployment |
| **STRIDE** | Systematic threat enumeration per component |
| **DREAD** | Quantitative risk scoring for prioritization |
| **Trust boundaries** | Identify data flow across trust zones |
| **Iterate** | Update threat model with each major feature/change |
| **Collaborate** | Include dev, security, ops, and product in sessions |
| **Document** | Store threat models alongside architecture docs |
| **Automate** | Validate mitigations with DAST/SAST in CI/CD |

---

## Rules Integration
- **Methodology**: STRIDE for threats, DREAD for risk scoring
- **Architecture**: Data flow diagrams with trust boundaries
- **Threats**: Categorized per STRIDE, scored per DREAD
- **Mitigations**: Mapped to each threat with implementation status
- **Integration**: Findings feed into security backlog and CI/CD gates
