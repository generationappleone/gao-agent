---
name: NIST CSF 2.0
description: Skill for implementing NIST Cybersecurity Framework 2.0 in application development — covering the 6 core functions (Govern, Identify, Protect, Detect, Respond, Recover) with practical coding patterns and security controls.
---

# NIST Cybersecurity Framework 2.0 Skill

## Overview
**NIST CSF 2.0** (released February 2024) is a voluntary framework for managing cybersecurity risk. Version 2.0 adds a new **Govern** function and expands scope beyond critical infrastructure to ALL organizations. This skill maps the framework to application development practices.

---

## 6 Core Functions

```
┌──────────────────────────────────────────────────────────────┐
│                    NIST CSF 2.0                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────┐                     │
│  │           1. GOVERN (GV)            │ ← NEW in 2.0       │
│  │  Cybersecurity risk management      │                     │
│  │  strategy, policy, oversight        │                     │
│  └─────────────────────────────────────┘                     │
│                                                              │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐│
│  │IDENTIFY │→│ PROTECT │→│ DETECT  │→│ RESPOND │→│RECOVER ││
│  │  (ID)   │ │  (PR)   │ │  (DE)   │ │  (RS)   │ │  (RC)  ││
│  │Asset    │ │Safeguard│ │Monitor  │ │Incident │ │Restore ││
│  │mgmt,   │ │data,    │ │anomalies│ │analysis,│ │normal  ││
│  │risk     │ │access   │ │& events │ │mitigate │ │ops     ││
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └────────┘│
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 1. GOVERN (GV) — Strategy & Oversight

### GV.OC — Organizational Context
```
→ Document what systems process sensitive data
→ Identify regulatory requirements (UU PDP, ISO 27001)
→ Define risk appetite and tolerance levels
→ Map dependencies (third-party services, APIs)
```

### GV.SC — Supply Chain Risk
```
→ Vet third-party dependencies (npm audit, Snyk)
→ Monitor supply chain attacks (lockfile, integrity checks)
→ Use lock files (package-lock.json, yarn.lock)
→ Pin dependency versions in production
→ Skills: skills/snyk/
```

### GV.RM — Risk Management Strategy
```
→ Conduct threat modeling for new features
→ Maintain risk register (spreadsheet or tool)
→ Review risks quarterly
→ Assign risk owners to development teams
```

---

## 2. IDENTIFY (ID) — Asset & Risk Management

### ID.AM — Asset Management
```typescript
// ✅ Inventory all data assets
interface DataAsset {
  name: string;
  description: string;
  dataClassification: 'public' | 'internal' | 'confidential' | 'restricted';
  piiCategory: 'none' | 'umum' | 'spesifik';
  storageLocation: string;     // database, S3, etc.
  owner: string;               // team/person responsible
  accessRoles: string[];       // who can access
  backupFrequency: string;     // daily, hourly, etc.
  retentionDays: number;
}
```

### ID.RA — Risk Assessment
```
For each feature/component, assess:
1. What can go wrong? (threats)
2. How likely is it? (1-5 scale)
3. How bad would it be? (1-5 scale)
4. What controls exist? (mitigations)
5. What residual risk remains? (after controls)
```

---

## 3. PROTECT (PR) — Safeguards

### PR.AA — Identity Management & Access Control
```typescript
// ✅ Authentication: Multi-layered
// Layer 1: Password (bcrypt/argon2)
// Layer 2: MFA (TOTP, WebAuthn)
// Layer 3: Session management (JWT + refresh tokens)
// Layer 4: Rate limiting (brute force protection)

// ✅ Authorization: RBAC/ABAC
// - Enforce at API level (never frontend-only)
// - Principle of least privilege
// - Regular access reviews
// Skills: skills/keycloak/, skills/google-oauth/
```

### PR.DS — Data Security
```
→ Encrypt at rest: AES-256-GCM for sensitive data
→ Encrypt in transit: TLS 1.3
→ Backup encryption: All backups encrypted
→ Data masking: PII masked in logs/errors
→ Input validation: Whitelist approach
→ Output encoding: Context-aware encoding
→ Skills: skills/data-privacy-engineering/
```

### PR.PS — Platform Security
```
→ Security headers (CSP, HSTS, X-Frame-Options)
→ Dependency updates (automated with Dependabot/Renovate)
→ Container scanning (Trivy)
→ Infrastructure as Code security (tfsec, checkov)
→ Environment separation (dev/staging/prod)
```

### PR.IR — Technology Infrastructure Resilience
```
→ Rate limiting on all public endpoints
→ Circuit breakers for external dependencies
→ Graceful degradation patterns
→ Health check endpoints
→ Auto-scaling configuration
→ Skills: skills/ddos-protection/, skills/waf/
```

---

## 4. DETECT (DE) — Monitoring & Analysis

### DE.CM — Continuous Monitoring
```typescript
// ✅ Application-level security monitoring
// 1. Failed login attempts (threshold alerting)
// 2. Unusual data access patterns
// 3. API rate limit violations
// 4. Error rate spikes
// 5. Unauthorized access attempts

// Structured security event logging
interface SecurityEvent {
  timestamp: string;
  eventType: 'AUTH_FAILURE' | 'ACCESS_DENIED' | 'RATE_LIMIT' | 'SUSPICIOUS_ACTIVITY' | 'DATA_ACCESS';
  severity: 'low' | 'medium' | 'high' | 'critical';
  userId?: string;
  ipAddress: string;
  userAgent: string;
  resource: string;
  action: string;
  details: Record<string, unknown>;
}

function logSecurityEvent(event: SecurityEvent): void {
  // Send to SIEM or security monitoring system
  logger.warn({ ...event, category: 'security' });
}
```

### DE.AE — Adverse Event Analysis
```
→ Centralized logging (ELK, Datadog, CloudWatch)
→ Alert rules for security events
→ Correlation of events across services
→ Anomaly detection for API usage patterns
→ Skills: skills/datadog/
```

---

## 5. RESPOND (RS) — Incident Response

### Incident Response Plan
```markdown
## Incident Response Runbook

### Severity Classification
| Level | Description | Response Time | Escalation |
|-------|-------------|---------------|------------|
| SEV-1 | Data breach, system compromise | 15 min | CTO + DPO immediately |
| SEV-2 | Service outage, vulnerability exploited | 30 min | Engineering Lead |
| SEV-3 | Degraded performance, minor vulnerability | 4 hours | On-call engineer |
| SEV-4 | Low-risk finding, informational | Next business day | Team backlog |

### Response Steps
1. **Detect** — Identify and confirm the incident
2. **Contain** — Isolate affected systems, revoke compromised credentials
3. **Eradicate** — Remove threat, patch vulnerability
4. **Recover** — Restore services, verify integrity
5. **Learn** — Post-mortem, update controls, share lessons
```

---

## 6. RECOVER (RC) — Recovery Planning

```
→ Backup & restore procedures documented and tested
→ Recovery Time Objective (RTO) defined per service
→ Recovery Point Objective (RPO) defined per data type
→ Disaster recovery plan tested annually
→ Communication plan for stakeholders during recovery
```

---

## NIST CSF Tiers (Maturity Levels)

| Tier | Level | Description |
|------|-------|-------------|
| **Tier 1** | Partial | Ad hoc, reactive security |
| **Tier 2** | Risk-Informed | Some risk awareness, not org-wide |
| **Tier 3** | Repeatable | Consistent, org-wide policies |
| **Tier 4** | Adaptive | Continuous improvement, predictive |

**Target: Tier 3 minimum for production applications.**

---

## Mapping: NIST CSF → ISO 27001

| NIST CSF Function | ISO 27001 Controls |
|-------------------|-------------------|
| Govern (GV) | A.5.1-A.5.4 (Policies, Roles) |
| Identify (ID) | A.5.9 (Asset Inventory), A.5.23 (Cloud) |
| Protect (PR) | A.8.2-A.8.5 (Access), A.8.24 (Crypto) |
| Detect (DE) | A.8.15-A.8.16 (Logging, Monitoring) |
| Respond (RS) | A.5.24-A.5.28 (Incident Management) |
| Recover (RC) | A.5.29-A.5.30 (Business Continuity) |

## Rules Integration
- **Developer Security**: PR.DS aligns with `rules/developer-security.md`
- **ISO 27001 Skill**: Maps directly to `skills/iso-27001/`
- **UU PDP Rule**: GV.OC regulatory requirements include `rules/uu-pdp-compliance.md`
