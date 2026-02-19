---
name: CIS Controls v8
description: Skill for implementing CIS Critical Security Controls v8 in application development — covering 18 controls across 3 implementation groups (IG1-IG3) with practical security patterns.
---

# CIS Controls v8 Skill

## Overview
**CIS Controls v8** (Center for Internet Security) provides 18 prioritized security controls organized into 3 Implementation Groups (IGs). Unlike ISO 27001 (management framework) and NIST CSF (risk framework), CIS Controls are **prescriptive and actionable** — they tell you exactly WHAT to do.

---

## Implementation Groups

| Group | Target | Description |
|-------|--------|-------------|
| **IG1** (Essential) | Small orgs, limited IT | Basic cyber hygiene — 56 safeguards |
| **IG2** (Standard) | Medium orgs, IT teams | Operationally mature — 74 additional safeguards |
| **IG3** (Advanced) | Large/sensitive orgs | Advanced controls — 23 additional safeguards |

**Minimum target: IG1 for all projects, IG2 for production.**

---

## Developer-Relevant Controls

### Control 1: Inventory of Enterprise Assets
```
→ Document all servers, databases, APIs, cloud services
→ Track which services handle PII
→ Maintain infrastructure diagram
→ Tag cloud resources for ownership
```

### Control 2: Inventory of Software Assets
```
→ Maintain package.json / requirements.txt / composer.json
→ Use lock files for deterministic builds
→ Track all third-party services and APIs
→ Document all microservice dependencies
→ Run: npm ls, pip list, composer show
```

### Control 3: Data Protection
```typescript
// IG1 — Essential safeguards
// 3.1 Establish data management process
// 3.4 Enforce data retention
// 3.6 Encrypt data on end-user devices

// IG2 — Standard safeguards  
// 3.7 Establish DLP for sensitive data
// 3.10 Encrypt sensitive data in transit
// 3.11 Encrypt sensitive data at rest

// Implementation: Data classification tags in code
type DataSensitivity = 'public' | 'internal' | 'confidential' | 'restricted';

interface FieldMetadata {
  sensitivity: DataSensitivity;
  encrypted: boolean;
  pii: boolean;
  retentionDays: number;
}

// Tag your database columns
const USER_FIELDS: Record<string, FieldMetadata> = {
  id:       { sensitivity: 'internal', encrypted: false, pii: false, retentionDays: -1 },
  email:    { sensitivity: 'confidential', encrypted: false, pii: true, retentionDays: -1 },
  phone:    { sensitivity: 'confidential', encrypted: true, pii: true, retentionDays: -1 },
  ktp:      { sensitivity: 'restricted', encrypted: true, pii: true, retentionDays: 365 },
  password: { sensitivity: 'restricted', encrypted: true, pii: false, retentionDays: -1 },
};
```

### Control 4: Secure Configuration
```
→ Harden default configurations (disable debug mode in prod)
→ Use security headers
→ Disable unnecessary features/modules
→ Use .env validation at startup

// Security headers checklist
Content-Security-Policy: default-src 'self'
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 0  (use CSP instead)
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

### Control 5: Account Management
```
→ Unique accounts per user (no shared accounts)
→ Disable inactive accounts (90 days)
→ Enforce MFA for admin accounts
→ Centralized identity (Keycloak, Google OAuth)
→ Skills: skills/keycloak/, skills/google-oauth/
```

### Control 6: Access Control Management
```
→ RBAC minimum, ABAC for complex scenarios
→ Least privilege principle
→ Regular access reviews (quarterly)
→ Separate dev/staging/prod access
→ Require MFA for production access
```

### Control 7: Continuous Vulnerability Management
```bash
# IG1 — Run in CI/CD pipeline
npm audit --audit-level=high
npx eslint --config security-config .

# IG2 — Additional scanning
npx snyk test
npx snyk code test

# IG3 — Advanced scanning
# OWASP ZAP active scan
# Penetration testing (quarterly)
```

### Control 8: Audit Log Management
```typescript
// ✅ REQUIRED: Structured audit logging
interface AuditLog {
  timestamp: string;
  actor: { id: string; type: 'user' | 'admin' | 'system'; ip: string };
  action: string;
  resource: { type: string; id: string };
  result: 'success' | 'failure';
  details?: Record<string, unknown>;
}

// IG1: Log authentication events
// IG2: Log all CRUD operations on sensitive data
// IG3: Log all API access with full context
```

### Control 9: Email & Web Browser Protection
```
→ Content Security Policy (CSP) to prevent XSS
→ Subresource Integrity (SRI) for CDN scripts
→ DMARC/SPF/DKIM for email sending
→ Skills: skills/xss-security/, skills/smtp-email/
```

### Control 10: Malware Defenses
```
→ File upload validation (type, size, content)
→ Antivirus scanning for uploaded files
→ Sandbox execution for user-submitted code
→ Container image scanning (Trivy)
```

### Control 13: Network Monitoring & Defense
```
→ Web Application Firewall (WAF)
→ DDoS protection (Cloudflare, AWS Shield)
→ Rate limiting on all public endpoints
→ Skills: skills/waf/, skills/ddos-protection/
```

### Control 14: Security Awareness Training
```
→ Secure coding training for developers
→ Phishing awareness
→ Incident reporting procedures
→ Annual security refresher
```

### Control 16: Application Software Security
```
→ SAST in CI/CD (ESLint Security, SonarQube)
→ DAST in staging (OWASP ZAP)
→ Dependency scanning (npm audit, Snyk)
→ Code review with security checklist
→ Input validation on ALL user inputs
→ Parameterized database queries
→ CAPTCHA for public forms
→ Skills: skills/turnstile/, skills/recaptcha/
```

---

## CIS → NIST CSF → ISO 27001 Mapping

| CIS Control | NIST CSF | ISO 27001 |
|-------------|----------|-----------|
| 1. Asset Inventory | ID.AM | A.5.9 |
| 3. Data Protection | PR.DS | A.8.24 |
| 4. Secure Config | PR.PS | A.8.9 |
| 5. Account Mgmt | PR.AA | A.8.2 |
| 6. Access Control | PR.AA | A.8.3 |
| 7. Vulnerability Mgmt | ID.RA | A.8.8 |
| 8. Audit Logs | DE.CM | A.8.15 |
| 13. Network Defense | PR.IR | A.8.20-A.8.22 |
| 16. App Security | PR.DS | A.8.25-A.8.28 |

## Rules Integration
- **Developer Security**: Controls 4, 9, 16 → `rules/developer-security.md`
- **ISO 27001**: Direct mapping to Annex A → `skills/iso-27001/`
- **NIST CSF**: Cross-reference → `skills/nist-csf/`
- **UU PDP**: Control 3 data protection → `rules/uu-pdp-compliance.md`
