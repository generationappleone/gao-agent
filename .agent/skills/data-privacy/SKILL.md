---
name: Data Privacy
description: Skill for data privacy compliance — covering PII detection, data classification, consent verification, data retention policies, data subject rights, privacy impact assessment, and compliance with UU PDP / GDPR.
---

# Data Privacy Skill

## Purpose
This skill provides patterns for **detecting, protecting, and managing personal data** in applications. It ensures compliance with data privacy regulations (UU PDP Indonesia, GDPR) and implements privacy-by-design principles.

---

## When to Use

- Applications processing user accounts (name, email, phone)
- Applications handling financial data (payment info, bank accounts)
- Applications storing health/biometric data
- Applications collecting location or behavioral data
- Any application where users can create profiles
- During security audits (via `/context-security` Step 11)

---

## PII Classification

### Data Umum (General Personal Data)
| Data Type | Examples | Minimum Protection |
|-----------|---------|-------------------|
| Identity | Name, email, phone, address | Encrypted at rest, masked in logs |
| Account | Username, profile photo, preferences | Access control, audit logging |
| Activity | Login history, usage patterns | Retention policy, anonymization |
| Device | IP address, user-agent, device ID | Pseudonymization |

### Data Spesifik (Sensitive Personal Data)
| Data Type | Examples | Required Protection |
|-----------|---------|-------------------|
| Health | Medical records, disabilities | Field-level encryption (AES-256-GCM) |
| Financial | Bank account, credit card, salary | Field-level encryption, PCI DSS |
| Biometric | Fingerprint, face ID, voice print | Field-level encryption, explicit consent |
| Religious | Religion, belief system | Field-level encryption, explicit consent |
| Political | Political affiliation, voting | Field-level encryption, explicit consent |
| Criminal | Criminal records | Field-level encryption, explicit consent |
| Children | Any data from users under 18 | Parental consent, enhanced protection |

---

## Privacy Scanning Checklist

### 1. PII Detection in Codebase
```bash
# Find models/schemas with PII fields
grep -rn "email\|phone\|address\|birth\|gender\|religion\|salary\|ssn\|nik\|ktp" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*' | grep -i "model\|schema\|entity\|migration\|table\|column"

# Find PII in log statements
grep -rn "console\.log\|logger\.\|Log\." --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*' | grep -i "email\|phone\|name\|address\|password\|token"
```

### 2. Consent Verification
```
Check:
- [ ] Consent is collected BEFORE processing personal data
- [ ] Consent is explicit, specific, and informed (not pre-checked boxes)
- [ ] Users can withdraw consent at any time
- [ ] Consent records are stored with timestamp and scope
- [ ] Third-party data sharing has separate consent
- [ ] No dark patterns in consent UI
- [ ] Children's data has parental consent mechanism (if applicable)
```

### 3. Encryption at Rest
```
Check:
- [ ] Data Spesifik fields encrypted at field level (AES-256-GCM)
- [ ] Database at rest encryption enabled
- [ ] Backup files encrypted
- [ ] Encryption keys stored separately from data
- [ ] Key rotation mechanism exists
```

### 4. PII in Logs
```
Check:
- [ ] Email addresses masked in logs (u***@example.com)
- [ ] Phone numbers masked (****1234)
- [ ] Names masked or excluded from logs
- [ ] No full PII objects logged
- [ ] Error messages don't expose PII
- [ ] Stack traces sanitized before logging
```

### 5. Data Retention
```
Check:
- [ ] Data retention policy defined
- [ ] Automated deletion/anonymization after retention period
- [ ] Soft-deleted data has final deletion schedule
- [ ] Backup rotation aligns with retention policy
- [ ] Third-party data sharing agreements include retention
```

### 6. Data Subject Rights (UU PDP Pasal 5-13)
```
Check:
- [ ] Right to access — User can view all their personal data
- [ ] Right to rectification — User can correct inaccurate data
- [ ] Right to erasure — User can request data deletion
- [ ] Right to data portability — User can export data (JSON/CSV)
- [ ] Right to object — User can object to data processing
- [ ] Right to withdraw consent — User can withdraw consent
- [ ] Right to complain — User can file complaints to Lembaga PDP
```

---

## Implementation Patterns

### PII Masking
```typescript
// Utility for masking PII in logs and error messages
export function maskEmail(email: string): string {
  const [local, domain] = email.split('@');
  if (!domain) return '***';
  return `${local[0]}***@${domain}`;
}

export function maskPhone(phone: string): string {
  if (phone.length < 4) return '***';
  return '****' + phone.slice(-4);
}

export function maskName(name: string): string {
  if (name.length < 2) return '***';
  return name[0] + '***';
}

export function maskPII(obj: Record<string, any>): Record<string, any> {
  const masked = { ...obj };
  const masks: Record<string, (v: string) => string> = {
    email: maskEmail,
    phone: maskPhone,
    name: maskName,
    firstName: maskName,
    lastName: maskName,
    address: () => '[REDACTED]',
    ssn: () => '[REDACTED]',
    nik: () => '[REDACTED]',
  };
  for (const [key, value] of Object.entries(masked)) {
    const maskKey = Object.keys(masks).find(k => key.toLowerCase().includes(k));
    if (maskKey && typeof value === 'string') {
      masked[key] = masks[maskKey](value);
    }
  }
  return masked;
}
```

### Data Export (Right to Portability)
```typescript
async function exportUserData(userId: string): Promise<UserDataExport> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      profile: true,
      orders: true,
      preferences: true,
      consentRecords: true,
      activityLogs: { take: 1000 },
    },
  });

  if (!user) throw new NotFoundError('User not found');

  return {
    exportDate: new Date().toISOString(),
    format: 'JSON',
    personalData: {
      name: user.name,
      email: user.email,
      phone: user.phone,
      address: user.profile?.address,
      createdAt: user.createdAt,
    },
    orders: user.orders.map(o => ({
      id: o.id,
      total: o.total,
      status: o.status,
      createdAt: o.createdAt,
    })),
    preferences: user.preferences,
    consentHistory: user.consentRecords,
    activitySummary: {
      totalLogins: user.activityLogs.filter(l => l.type === 'login').length,
      lastLogin: user.activityLogs.find(l => l.type === 'login')?.createdAt,
    },
  };
}
```

### Data Erasure (Right to Deletion)
```typescript
async function eraseUserData(userId: string): Promise<void> {
  // Step 1: Verify identity (re-authentication required)
  // Step 2: Check legal obligations (data that must be retained)

  await prisma.$transaction(async (tx) => {
    // Anonymize rather than delete to maintain referential integrity
    await tx.user.update({
      where: { id: userId },
      data: {
        name: '[DELETED USER]',
        email: `deleted_${userId}@anonymized.local`,
        phone: null,
        profilePhoto: null,
        deletedAt: new Date(),
      },
    });

    // Delete non-essential data
    await tx.activityLog.deleteMany({ where: { userId } });
    await tx.preference.deleteMany({ where: { userId } });
    await tx.consentRecord.updateMany({
      where: { userId },
      data: { withdrawnAt: new Date() },
    });

    // Create audit trail
    await tx.auditLog.create({
      data: {
        action: 'DATA_ERASURE',
        entityType: 'user',
        entityId: userId,
        performedBy: userId,
        details: { reason: 'User requested data deletion' },
      },
    });
  });
}
```

### Consent Recording
```typescript
interface ConsentRecord {
  userId: string;
  purpose: string;        // 'marketing_email', 'analytics', 'third_party_sharing'
  granted: boolean;
  grantedAt: Date;
  withdrawnAt?: Date;
  ipAddress: string;
  userAgent: string;
  version: string;        // Consent policy version
}

async function recordConsent(data: ConsentRecord): Promise<void> {
  await prisma.consentRecord.create({
    data: {
      ...data,
      version: 'v2.0',    // Track which consent policy was shown
    },
  });
}
```

---

## Privacy Impact Assessment (PIA) — Quick Template

```markdown
## Privacy Impact Assessment: [Feature Name]

### 1. Data Collected
| Field | Type | PII? | Sensitive? | Purpose | Legal Basis |
|-------|------|------|-----------|---------|-------------|
| email | string | Yes | No | Communication | Consent |
| phone | string | Yes | No | 2FA | Legitimate interest |

### 2. Data Flow
[Where does data go? Internal systems, third parties, cloud storage?]

### 3. Data Retention
[How long is data kept? When is it deleted?]

### 4. Third-Party Sharing
[Is data shared? With whom? Under what agreement?]

### 5. Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Data breach | Low | High | Encryption, access control |
| Unauthorized access | Medium | High | RBAC, audit logging |

### 6. Compliance Status
- [ ] UU PDP Article 5-13 (Data subject rights)
- [ ] Consent obtained before processing
- [ ] Data minimization applied
- [ ] Encryption for sensitive data
- [ ] Breach notification procedure ready
```

---

## Sanctions Reference (UU PDP Indonesia)

| Violation | Criminal Penalty | Administrative Penalty |
|-----------|-----------------|----------------------|
| Unlawful collection/use | Up to 5 years + Rp 5B | Up to 2% annual revenue |
| Falsifying personal data | Up to 6 years + Rp 6B | — |
| Failure to notify breach | Up to 3×24 hours SLA | Written warning → suspension |
| Cross-border transfer without approval | — | Up to 2% annual revenue |

---

## Integration with Rules
- `rules/uu-pdp-compliance.md` — Full UU PDP compliance requirements
- `rules/iso-27000-compliance.md` — Data classification and protection
- `rules/developer-security.md` — Encryption and access control
- `rules/database-design.md` — Soft delete for data retention
