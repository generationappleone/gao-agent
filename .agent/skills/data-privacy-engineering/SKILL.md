---
name: Data Privacy Engineering
description: Skill for implementing privacy-by-design patterns — data anonymization, pseudonymization, PII encryption, data masking, audit logging, right to erasure, data portability, and privacy impact assessments.
---

# Data Privacy Engineering Skill

## Overview
Privacy engineering transforms legal requirements into **working code**. This skill covers the technical patterns for protecting personal data throughout the application lifecycle — from collection to deletion.

---

## 1. Data Anonymization & Pseudonymization

### Definitions
| Technique | Reversible? | Use When |
|-----------|------------|----------|
| **Anonymization** | ❌ No | Data no longer needed for individual-level processing. Fully irreversible. |
| **Pseudonymization** | ✅ Yes (with key) | Data still needed but want to reduce PII exposure. Replace identifiers with tokens. |
| **Encryption** | ✅ Yes (with key) | Data must be readable by authorized systems. Standard protection. |
| **Masking** | Partial | Display purposes only. Show partial data (e.g., `j***@gmail.com`). |

### Anonymization Functions
```typescript
// ✅ Irreversible anonymization for analytics data
function anonymizeUser(user: User): AnonymizedUser {
  return {
    id: hashSHA256(user.id + ANONYMIZATION_SALT),        // one-way hash
    ageRange: getAgeRange(user.dateOfBirth),              // '25-34' instead of exact date
    region: user.city ? getRegion(user.city) : 'unknown', // 'Jawa Barat' instead of 'Bandung'
    signupMonth: user.createdAt.toISOString().slice(0, 7), // '2025-01' instead of exact date
    orderCount: user.orderCount,                          // aggregate ok
    totalSpend: roundToNearest(user.totalSpend, 100000),  // rounded amount
  };
}

function getAgeRange(dob: Date): string {
  const age = calculateAge(dob);
  if (age < 18) return '<18';
  if (age < 25) return '18-24';
  if (age < 35) return '25-34';
  if (age < 45) return '35-44';
  if (age < 55) return '45-54';
  return '55+';
}

function roundToNearest(value: number, precision: number): number {
  return Math.round(value / precision) * precision;
}
```

### Pseudonymization with Token Mapping
```typescript
import crypto from 'crypto';

// ✅ Reversible pseudonymization — mapping stored securely
class PseudonymService {
  private readonly key: Buffer;

  constructor(encryptionKey: string) {
    this.key = Buffer.from(encryptionKey, 'hex');
  }

  pseudonymize(identifier: string): string {
    const hmac = crypto.createHmac('sha256', this.key);
    hmac.update(identifier);
    return `PSE_${hmac.digest('hex').slice(0, 16)}`;
  }

  // For reversible pseudonymization, use encrypted mapping table
  async createMapping(original: string): Promise<string> {
    const pseudonym = this.pseudonymize(original);
    await db.execute(
      'INSERT INTO pseudonym_mappings (pseudonym, encrypted_original) VALUES ($1, $2)',
      [pseudonym, this.encrypt(original)]
    );
    return pseudonym;
  }

  async resolve(pseudonym: string): Promise<string | null> {
    const row = await db.queryOne<{ encrypted_original: string }>(
      'SELECT encrypted_original FROM pseudonym_mappings WHERE pseudonym = $1',
      [pseudonym]
    );
    return row ? this.decrypt(row.encrypted_original) : null;
  }

  private encrypt(text: string): string {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-gcm', this.key, iv);
    const encrypted = Buffer.concat([cipher.update(text, 'utf8'), cipher.final()]);
    const tag = cipher.getAuthTag();
    return `${iv.toString('hex')}:${tag.toString('hex')}:${encrypted.toString('hex')}`;
  }

  private decrypt(data: string): string {
    const [ivHex, tagHex, encryptedHex] = data.split(':');
    const iv = Buffer.from(ivHex, 'hex');
    const tag = Buffer.from(tagHex, 'hex');
    const encrypted = Buffer.from(encryptedHex, 'hex');
    const decipher = crypto.createDecipheriv('aes-256-gcm', this.key, iv);
    decipher.setAuthTag(tag);
    return decipher.update(encrypted) + decipher.final('utf8');
  }
}
```

---

## 2. Field-Level Encryption

```typescript
import crypto from 'crypto';

// ✅ REQUIRED: Encrypt sensitive PII columns at application level
class FieldEncryption {
  private readonly algorithm = 'aes-256-gcm';
  private readonly key: Buffer;

  constructor(keyHex: string) {
    this.key = Buffer.from(keyHex, 'hex'); // 32-byte key
  }

  encrypt(plaintext: string): string {
    const iv = crypto.randomBytes(12);
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
    const encrypted = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
    const tag = cipher.getAuthTag();
    return [iv.toString('base64'), tag.toString('base64'), encrypted.toString('base64')].join('.');
  }

  decrypt(ciphertext: string): string {
    const [ivB64, tagB64, encB64] = ciphertext.split('.');
    const iv = Buffer.from(ivB64, 'base64');
    const tag = Buffer.from(tagB64, 'base64');
    const encrypted = Buffer.from(encB64, 'base64');
    const decipher = crypto.createDecipheriv(this.algorithm, this.key, iv);
    decipher.setAuthTag(tag);
    return decipher.update(encrypted, undefined, 'utf8') + decipher.final('utf8');
  }
}

// Usage in service layer
const fieldCrypto = new FieldEncryption(env.PII_ENCRYPTION_KEY);

async function createUser(input: CreateUserInput): Promise<User> {
  const user = await db.execute(`
    INSERT INTO users (email, phone_encrypted, ktp_encrypted, full_name)
    VALUES ($1, $2, $3, $4)
    RETURNING id, email, full_name, created_at
  `, [
    input.email,
    input.phone ? fieldCrypto.encrypt(input.phone) : null,
    input.ktpNumber ? fieldCrypto.encrypt(input.ktpNumber) : null,
    input.fullName,
  ]);
  return user;
}

async function getUserPhone(userId: string): Promise<string | null> {
  const row = await db.queryOne<{ phone_encrypted: string | null }>(
    'SELECT phone_encrypted FROM users WHERE id = $1',
    [userId]
  );
  if (!row?.phone_encrypted) return null;

  // Log PII access for audit
  await auditLog.record({ action: 'PII_ACCESS', field: 'phone', userId, accessedBy: currentUser.id });

  return fieldCrypto.decrypt(row.phone_encrypted);
}
```

---

## 3. PII Masking

```typescript
// ✅ REQUIRED: Mask PII in logs, error messages, and limited-access displays

export const mask = {
  email(email: string): string {
    const [local, domain] = email.split('@');
    if (!domain) return '***@***.***';
    const masked = local.length > 2
      ? `${local[0]}${'*'.repeat(local.length - 2)}${local[local.length - 1]}`
      : `${local[0]}***`;
    return `${masked}@${domain}`;
  },

  phone(phone: string): string {
    const digits = phone.replace(/\D/g, '');
    if (digits.length < 6) return '****';
    return `${digits.slice(0, 3)}${'*'.repeat(digits.length - 6)}${digits.slice(-3)}`;
  },

  ktp(ktp: string): string {
    if (ktp.length < 6) return '****';
    return `${ktp.slice(0, 4)}${'*'.repeat(ktp.length - 8)}${ktp.slice(-4)}`;
  },

  name(name: string): string {
    const parts = name.split(' ');
    return parts.map((p) => `${p[0]}${'*'.repeat(p.length - 1)}`).join(' ');
  },

  creditCard(number: string): string {
    const digits = number.replace(/\D/g, '');
    return `****-****-****-${digits.slice(-4)}`;
  },

  address(address: string): string {
    const words = address.split(' ');
    if (words.length <= 2) return '***';
    return `${words[0]} ${'*** '.repeat(words.length - 2)}${words[words.length - 1]}`;
  },
};

// Usage:
// mask.email('john.doe@gmail.com')     → 'j******e@gmail.com'
// mask.phone('+6281234567890')          → '628***7890'
// mask.ktp('3201012345678901')          → '3201********8901'
// mask.name('John Doe')                 → 'J*** D**'
// mask.creditCard('4111111111111111')   → '****-****-****-1111'
```

---

## 4. PII Audit Logging

```typescript
// ✅ REQUIRED: Log every PII access, modification, and deletion

interface PiiAuditEntry {
  id: string;
  timestamp: string;
  action: 'ACCESS' | 'CREATE' | 'UPDATE' | 'DELETE' | 'EXPORT' | 'TRANSFER';
  actorId: string;        // who performed the action
  actorType: 'user' | 'admin' | 'system' | 'api';
  subjectId: string;      // whose data was accessed
  resource: string;       // table/entity name
  fields: string[];       // which PII fields were accessed
  purpose: string;        // why (must be stated)
  ipAddress: string;
  userAgent: string;
  result: 'success' | 'denied' | 'error';
}

// Database table — append-only, no UPDATE/DELETE
// CREATE TABLE pii_audit_log (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
//   action VARCHAR(20) NOT NULL,
//   actor_id UUID NOT NULL,
//   actor_type VARCHAR(20) NOT NULL,
//   subject_id UUID NOT NULL,
//   resource VARCHAR(100) NOT NULL,
//   fields TEXT[] NOT NULL,
//   purpose TEXT NOT NULL,
//   ip_address INET,
//   user_agent TEXT,
//   result VARCHAR(20) NOT NULL
// );
// -- NO UPDATE or DELETE permissions on this table

class PiiAuditLogger {
  async log(entry: Omit<PiiAuditEntry, 'id' | 'timestamp'>): Promise<void> {
    await db.execute(`
      INSERT INTO pii_audit_log (action, actor_id, actor_type, subject_id, resource, fields, purpose, ip_address, user_agent, result)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    `, [
      entry.action, entry.actorId, entry.actorType, entry.subjectId,
      entry.resource, entry.fields, entry.purpose,
      entry.ipAddress, entry.userAgent, entry.result,
    ]);
  }
}

// Usage in service
async function viewUserProfile(adminId: string, userId: string): Promise<UserProfile> {
  const profile = await userRepo.findById(userId);

  await piiAudit.log({
    action: 'ACCESS',
    actorId: adminId,
    actorType: 'admin',
    subjectId: userId,
    resource: 'users',
    fields: ['full_name', 'email', 'phone', 'address'],
    purpose: 'Customer support ticket #12345',
    ipAddress: req.ip,
    userAgent: req.headers['user-agent'] ?? '',
    result: 'success',
  });

  return profile;
}
```

---

## 5. Data Portability (Export)

```typescript
// ✅ REQUIRED: Export all user data in machine-readable format
// GET /api/v1/me/export?format=json

async function exportUserData(userId: string, format: 'json' | 'csv'): Promise<DataExport> {
  // Gather all data
  const [user, orders, consents, activities, preferences] = await Promise.all([
    userRepo.findById(userId),
    orderRepo.findByUserId(userId),
    consentRepo.findByUserId(userId),
    activityRepo.findByUserId(userId, { limit: 1000 }),
    preferenceRepo.findByUserId(userId),
  ]);

  const exportData = {
    exportedAt: new Date().toISOString(),
    format,
    dataController: {
      name: 'PT. Company Name',
      email: 'dpo@company.co.id',
      address: 'Jakarta, Indonesia',
    },
    personalData: {
      profile: {
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
        address: user.address,
        createdAt: user.createdAt,
      },
      orders: orders.map((o) => ({
        orderId: o.id,
        date: o.createdAt,
        total: o.total,
        status: o.status,
        items: o.items,
      })),
      consents: consents.map((c) => ({
        type: c.consentType,
        granted: c.granted,
        date: c.createdAt,
        policyVersion: c.consentVersion,
      })),
      activityLog: activities.map((a) => ({
        action: a.action,
        date: a.createdAt,
        details: a.metadata,
      })),
      preferences,
    },
  };

  // Log the export
  await piiAudit.log({
    action: 'EXPORT',
    actorId: userId,
    actorType: 'user',
    subjectId: userId,
    resource: 'all',
    fields: ['profile', 'orders', 'consents', 'activities', 'preferences'],
    purpose: 'Data subject portability request (Pasal 9 UU PDP)',
    ipAddress: req.ip,
    userAgent: req.headers['user-agent'] ?? '',
    result: 'success',
  });

  return exportData;
}
```

---

## 6. Privacy Impact Assessment (DPIA) Template

### When DPIA is Required
- Processing **data pribadi spesifik** (sensitive data)
- **Large-scale** processing of personal data
- **Automated decision-making** (profiling, scoring)
- **New technology** deployment involving PII
- **Cross-border** data transfer
- Processing **children's data**

### DPIA Checklist
```markdown
## Privacy Impact Assessment

### 1. Processing Description
- What data: [list all PII fields]
- Data category: [umum / spesifik]
- Volume: [estimated records]
- Retention: [how long]
- Purpose: [stated purpose]

### 2. Legal Basis
- [ ] Consent (Pasal 20)
- [ ] Contract performance (Pasal 20)
- [ ] Legal obligation (Pasal 20)
- [ ] Vital interest (Pasal 20)
- [ ] Public interest (Pasal 20)
- [ ] Legitimate interest (Pasal 20)

### 3. Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Data breach | [Low/Med/High] | [Low/Med/High] | [controls] |
| Unauthorized access | [Low/Med/High] | [Low/Med/High] | [controls] |
| Cross-border exposure | [Low/Med/High] | [Low/Med/High] | [controls] |
| Purpose creep | [Low/Med/High] | [Low/Med/High] | [controls] |

### 4. Technical Controls
- [ ] Encryption at rest
- [ ] Encryption in transit
- [ ] Access control (RBAC)
- [ ] Audit logging
- [ ] Data masking in logs
- [ ] Retention auto-purge
- [ ] Anonymization for analytics

### 5. Sign-off
- DPO Review: [date]
- Engineering Lead: [date]
- Compliance: [date]
```

---

## Best Practices

1. **Encrypt at application level** — don't rely only on database encryption
2. **Separate encryption keys per data type** — different keys for health vs financial
3. **Rotate keys periodically** — implement key rotation strategy
4. **Log access, not content** — audit who accessed what, never log the PII itself
5. **Mask by default** — display masked PII, reveal only on explicit action
6. **Test deletion flows** — ensure DELETE cascades correctly, no orphaned PII
7. **Anonymize for analytics** — never use raw PII for reports/dashboards
8. **DPIA before launch** — run privacy impact assessment before processing new PII
9. **Environment separation** — production PII never in staging/dev (use synthetic data)
10. **Backup encryption** — backups containing PII must be encrypted

## Rules Integration
- **UU PDP Rule**: Technical implementation of all legal requirements
- **Database Rule**: Soft delete + audit columns support privacy requirements
- **Security Rule**: Encryption standards align with PII protection
- **ISO 27000 Rule**: Data classification + access control reinforced
