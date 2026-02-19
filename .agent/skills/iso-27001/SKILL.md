---
name: ISO 27001:2022
description: Skill for implementing ISO 27001:2022 Information Security Management System controls in application development — covering Annex A controls, risk assessment, access control, cryptography, and secure development lifecycle.
---

# ISO 27001:2022 Skill

## Overview
**ISO/IEC 27001:2022** is the international standard for Information Security Management Systems (ISMS). The 2022 revision reorganized controls into **4 themes** with **93 controls** (down from 114 in 2013). This skill maps relevant controls to application development practices.

---

## Annex A Control Themes (2022)

| Theme | Controls | Focus |
|-------|----------|-------|
| **A.5** Organizational (37) | Policies, roles, responsibilities, threat intelligence |
| **A.6** People (8) | Screening, awareness, training, remote working |
| **A.7** Physical (14) | Secure areas, equipment, media |
| **A.8** Technological (34) | Access control, crypto, secure dev, monitoring |

---

## Developer-Relevant Controls

### A.5 — Organizational Controls

#### A.5.1 Policies for Information Security
```
Implementation: Every project MUST have documented security policies.
→ Store in: /docs/security-policy.md or project wiki
→ Review: At least annually or on major changes
```

#### A.5.7 Threat Intelligence
```
Implementation: Monitor vulnerability databases and advisories.
→ Use: npm audit, Snyk, GitHub Dependabot, CVE feeds
→ Automate: CI/CD pipeline security scanning
→ Skills: skills/snyk/, skills/eslint-security/
```

#### A.5.23 Information Security for Cloud Services
```
Implementation: When using cloud services (AWS, GCP, Azure):
→ Enable encryption at rest and in transit
→ Use IAM with least privilege
→ Enable audit logging (CloudTrail, Cloud Audit Logs)
→ Regularly review access permissions
→ Use cloud-native security tools (GuardDuty, Security Center)
```

#### A.5.34 Privacy and Protection of PII
```
Implementation: Align with UU PDP (Indonesia) and/or GDPR.
→ Skills: skills/uu-pdp-compliance/, skills/consent-management/
→ Rules: rules/uu-pdp-compliance.md
```

### A.8 — Technological Controls (Most Relevant)

#### A.8.1 User Endpoint Devices
```
No hardcoded credentials in source code.
Use environment variables or secret managers.
```

#### A.8.2 Privileged Access Rights
```typescript
// ✅ Implement RBAC with least privilege
enum Role {
  VIEWER = 'viewer',
  EDITOR = 'editor',
  ADMIN = 'admin',
  SUPER_ADMIN = 'super_admin',
}

// Separate permissions from roles
interface Permission {
  resource: string;
  actions: ('read' | 'create' | 'update' | 'delete')[];
}

const ROLE_PERMISSIONS: Record<Role, Permission[]> = {
  [Role.VIEWER]: [
    { resource: 'articles', actions: ['read'] },
    { resource: 'profile', actions: ['read', 'update'] },
  ],
  [Role.EDITOR]: [
    { resource: 'articles', actions: ['read', 'create', 'update'] },
    { resource: 'media', actions: ['read', 'create'] },
  ],
  [Role.ADMIN]: [
    { resource: '*', actions: ['read', 'create', 'update'] },
    { resource: 'users', actions: ['read', 'create', 'update'] },
  ],
  [Role.SUPER_ADMIN]: [
    { resource: '*', actions: ['read', 'create', 'update', 'delete'] },
  ],
};

// Middleware
function requirePermission(resource: string, action: string) {
  return (req: Request, res: Response, next: NextFunction) => {
    const userRole = req.user?.role as Role;
    const permissions = ROLE_PERMISSIONS[userRole] || [];
    const allowed = permissions.some(
      (p) => (p.resource === '*' || p.resource === resource) && p.actions.includes(action as any)
    );
    if (!allowed) return res.status(403).json({ error: 'Insufficient permissions' });
    next();
  };
}
```

#### A.8.3 Information Access Restriction
```
Rule: API endpoints MUST enforce authorization checks.
      NEVER rely on frontend-only access control.
      Every API route = authentication + authorization.
```

#### A.8.4 Access to Source Code
```
→ Use branch protection rules (main/master)
→ Require code review (PR approval)
→ Enable signed commits
→ Restrict force push
→ Audit repository access logs
```

#### A.8.5 Secure Authentication
```typescript
// ✅ Requirements:
// - Multi-factor authentication (MFA) for admin accounts
// - Password complexity: min 12 chars, mixed case, numbers, symbols
// - Account lockout after 5 failed attempts (15 min cooldown)
// - Session timeout: 30 min inactive, 8 hours absolute
// - Secure password storage: bcrypt/argon2 with salt

import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

// Password policy
function validatePassword(password: string): { valid: boolean; errors: string[] } {
  const errors: string[] = [];
  if (password.length < 12) errors.push('Minimum 12 characters');
  if (!/[A-Z]/.test(password)) errors.push('Must contain uppercase letter');
  if (!/[a-z]/.test(password)) errors.push('Must contain lowercase letter');
  if (!/[0-9]/.test(password)) errors.push('Must contain number');
  if (!/[^A-Za-z0-9]/.test(password)) errors.push('Must contain special character');
  return { valid: errors.length === 0, errors };
}
```

#### A.8.9 Configuration Management
```
→ Use .env files (never commit to git)
→ Use secret managers (AWS Secrets Manager, Vault, etc.)
→ Validate all config at startup
→ Document all configuration options
→ Use different configs per environment (dev/staging/prod)
```

#### A.8.12 Data Leakage Prevention
```
→ Never log PII (see rules/uu-pdp-compliance.md)
→ Sanitize API responses (return minimum data)
→ Block sensitive file downloads
→ Monitor for data exfiltration patterns
```

#### A.8.24 Use of Cryptography
```
Approved algorithms:
- Hashing: SHA-256, SHA-3, bcrypt, argon2id
- Symmetric: AES-256-GCM
- Asymmetric: RSA-2048+, Ed25519
- TLS: 1.2 minimum, 1.3 preferred
- Key derivation: PBKDF2 (100k+ iterations), scrypt, argon2

BANNED: MD5, SHA-1, DES, 3DES, RC4, TLS 1.0/1.1
```

#### A.8.25-A.8.27 Secure Development Lifecycle
```
1. Secure coding training for developers
2. Security requirements in user stories
3. Threat modeling before implementation
4. Secure code review (peer review)
5. SAST scanning in CI/CD (ESLint Security, SonarQube)
6. DAST scanning in staging (OWASP ZAP)
7. Dependency vulnerability scanning (npm audit, Snyk)
8. Penetration testing before production release
9. Security regression testing
10. Incident response plan documented
```

#### A.8.28 Secure Coding
```
→ Input validation on ALL user inputs
→ Output encoding (prevent XSS)
→ Parameterized queries (prevent SQL injection)
→ CSRF protection tokens
→ Security headers (CSP, HSTS, X-Frame-Options)
→ Error handling without information leakage
→ Skills: skills/xss-security/, rules/developer-security.md
```

---

## Risk Assessment Matrix

| Risk Level | Likelihood × Impact | Action |
|-----------|-------------------|--------|
| 🔴 Critical (15-25) | High × High | Immediate remediation required |
| 🟠 High (10-14) | Medium × High | Remediate within sprint |
| 🟡 Medium (5-9) | Low × Medium | Plan for remediation |
| 🟢 Low (1-4) | Low × Low | Accept or monitor |

```
Likelihood: 1=Rare, 2=Unlikely, 3=Possible, 4=Likely, 5=Almost Certain
Impact:     1=Negligible, 2=Minor, 3=Moderate, 4=Major, 5=Severe
Risk Score = Likelihood × Impact
```

---

## Statement of Applicability (SoA) Template

For each Annex A control, document:
```markdown
| Control | Applicable | Implemented | Justification |
|---------|-----------|-------------|---------------|
| A.8.5 Secure Authentication | ✅ Yes | ✅ Yes | bcrypt + JWT + MFA |
| A.8.24 Cryptography | ✅ Yes | ✅ Yes | AES-256-GCM + TLS 1.3 |
| A.8.28 Secure Coding | ✅ Yes | ✅ Yes | ESLint Security + code review |
| A.7.3 Securing Offices | ❌ N/A | — | Cloud-only, no physical offices |
```

---

## Audit Preparation Checklist

```
Documentation
□ Information Security Policy documented
□ Risk assessment completed and documented
□ Statement of Applicability (SoA) up to date
□ Asset inventory maintained
□ Access control policy documented

Technical Evidence
□ SAST/DAST scan reports available
□ Dependency vulnerability reports available
□ Penetration test reports available
□ Access review logs available
□ Incident response plan tested
□ Backup and recovery tested
□ Encryption inventory documented

Processes
□ Change management process followed
□ Code review process enforced
□ Security training records available
□ Incident reports archived
□ Business continuity plan documented
```

## Rules Integration
- **Developer Security**: A.8.28 secure coding aligns with `rules/developer-security.md`
- **ISO 27000 Rule**: A.5.34 PII protection aligns with `rules/iso-27000-compliance.md`
- **UU PDP Rule**: Privacy controls align with `rules/uu-pdp-compliance.md`
- **Database Rule**: A.8.24 cryptography aligns with `rules/database-design.md`
