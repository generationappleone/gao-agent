---
name: UU PDP Compliance
description: Skill for implementing Indonesia's Personal Data Protection Law (UU No. 27 Tahun 2022) in applications — covering data classification, consent management, data subject rights, breach notification, cross-border transfer, and privacy by design.
---

# UU PDP (Pelindungan Data Pribadi) Compliance Skill

## Overview
**UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP)** is Indonesia's comprehensive personal data protection law, equivalent to EU's GDPR. Every application that processes personal data of Indonesian residents **MUST** comply.

**Key dates:**
- Enacted: 17 October 2022
- Transition period: 2 years (ended October 2024)
- **Status: FULLY ENFORCEABLE**

**Sanctions:**
- 🔴 Criminal: up to 6 years imprisonment + Rp 6 billion fine
- 🟠 Administrative: up to 2% of annual revenue
- 🟡 Prohibition from processing personal data

---

## 1. Key Terminology

| UU PDP Term | English Equivalent | Definition |
|-------------|-------------------|------------|
| Data Pribadi | Personal Data | Any data about an identified/identifiable individual |
| Data Pribadi Umum | General Personal Data | Name, email, phone, address, nationality, age, gender |
| Data Pribadi Spesifik | Specific/Sensitive Personal Data | Health, biometrics, genetics, criminal records, child data, financial, sexual orientation, political views, disability |
| Subjek Data Pribadi | Data Subject | The individual whose data is processed |
| Pengendali Data Pribadi | Data Controller | Entity that determines purpose & means of processing |
| Prosesor Data Pribadi | Data Processor | Entity that processes data on behalf of controller |
| Pejabat PDP | Data Protection Officer | Person responsible for data protection compliance |
| Lembaga PDP | Data Protection Authority | Government authority under the President |
| Persetujuan | Consent | Explicit agreement from data subject |

---

## 2. Data Classification (Pasal 4)

### ✅ MUST classify ALL personal data in your application

#### Data Pribadi Umum (General)
| Data Type | Examples | Protection Level |
|-----------|---------|-----------------|
| Identity | Nama, jenis kelamin, kewarganegaraan, agama | Standard |
| Contact | Email, nomor telepon, alamat | Standard |
| Account | Username, user ID | Standard |
| Demographic | Tanggal lahir, usia, status perkawinan | Standard |
| Visual | Foto profil | Standard |

#### Data Pribadi Spesifik (Sensitive) — EXTRA PROTECTION REQUIRED
| Data Type | Examples | Protection Level |
|-----------|---------|-----------------|
| Kesehatan | Medical records, diagnosa, resep obat | 🔴 Maximum |
| Biometrik | Fingerprint, face scan, retina, voice print | 🔴 Maximum |
| Genetika | DNA data, genetic testing results | 🔴 Maximum |
| Catatan Kriminal | Criminal history, police records | 🔴 Maximum |
| Data Anak | Any data of person < 18 years old | 🔴 Maximum |
| Keuangan | Bank account, salary, credit score, tax | 🔴 Maximum |
| Orientasi Seksual | Sexual preference, gender identity | 🔴 Maximum |
| Pandangan Politik | Political affiliation, voting history | 🔴 Maximum |
| Disabilitas | Disability status, accessibility needs | 🔴 Maximum |

### Implementation: Data Classification Table
```sql
-- ✅ REQUIRED: Track which columns contain PII
CREATE TABLE pii_data_registry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name VARCHAR(100) NOT NULL,
  column_name VARCHAR(100) NOT NULL,
  data_category VARCHAR(20) NOT NULL CHECK (data_category IN ('umum', 'spesifik')),
  data_type VARCHAR(50) NOT NULL,           -- e.g., 'email', 'health', 'biometric'
  encryption_required BOOLEAN DEFAULT false,
  retention_days INTEGER,                   -- auto-delete after N days
  legal_basis VARCHAR(50) NOT NULL,         -- 'consent', 'contract', 'legal_obligation', 'vital_interest', 'public_interest', 'legitimate_interest'
  purpose TEXT NOT NULL,                    -- stated purpose for collection
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Example registrations
INSERT INTO pii_data_registry (table_name, column_name, data_category, data_type, encryption_required, retention_days, legal_basis, purpose) VALUES
('users', 'email', 'umum', 'email', false, NULL, 'contract', 'Account authentication and communication'),
('users', 'phone', 'umum', 'phone', false, NULL, 'consent', 'Optional contact method'),
('users', 'full_name', 'umum', 'name', false, NULL, 'contract', 'Account identification'),
('medical_records', 'diagnosis', 'spesifik', 'health', true, 1825, 'consent', 'Health service delivery'),
('kyc_documents', 'ktp_number', 'umum', 'national_id', true, 365, 'legal_obligation', 'KYC verification');
```

---

## 3. Consent Management (Pasal 20-22)

### Legal Requirements
```
Rule: Data processing REQUIRES one of these legal bases:
      1. Persetujuan (Consent) — MOST COMMON
      2. Pelaksanaan perjanjian (Contract performance)
      3. Kewajiban hukum (Legal obligation)
      4. Kepentingan vital (Vital interest)
      5. Kepentingan publik (Public interest)
      6. Kepentingan sah (Legitimate interest)
```

### Consent Requirements (Pasal 20)
- ✅ Must be **explicit** (not implied or pre-checked)
- ✅ Must be **specific** (per purpose, not blanket)
- ✅ Must be **informed** (user understands what they agree to)
- ✅ Must be **freely given** (not coerced, service not contingent on non-essential consent)
- ✅ Must be **withdrawable** at any time, as easy as giving consent
- ✅ Must maintain **audit trail** (when, what version, how)

### Database Schema
```sql
-- ✅ REQUIRED: Consent records
CREATE TABLE consent_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  consent_type VARCHAR(50) NOT NULL,       -- 'marketing', 'analytics', 'personalization', 'third_party_sharing'
  purpose TEXT NOT NULL,                    -- human-readable purpose in Bahasa Indonesia
  granted BOOLEAN NOT NULL,
  consent_version VARCHAR(20) NOT NULL,    -- policy version when consent was given
  granted_at TIMESTAMPTZ,
  withdrawn_at TIMESTAMPTZ,
  ip_address INET,
  user_agent TEXT,
  method VARCHAR(20) NOT NULL DEFAULT 'web_form',  -- 'web_form', 'api', 'mobile_app', 'offline'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_consent CHECK (
    (granted = true AND granted_at IS NOT NULL) OR
    (granted = false)
  )
);

CREATE INDEX idx_consent_user ON consent_records(user_id);
CREATE INDEX idx_consent_type ON consent_records(consent_type);

-- ✅ REQUIRED: Privacy policy versions
CREATE TABLE privacy_policy_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version VARCHAR(20) NOT NULL UNIQUE,
  title TEXT NOT NULL,
  content_hash VARCHAR(64) NOT NULL,       -- SHA-256 of policy content
  effective_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints
```typescript
// ✅ REQUIRED: Consent API
// GET  /api/v1/consent              → Get user's current consent status
// POST /api/v1/consent              → Grant consent (specific type + purpose)
// DELETE /api/v1/consent/:type      → Withdraw consent
// GET  /api/v1/consent/history      → Audit trail of consent changes

interface ConsentStatus {
  type: string;
  purpose: string;
  granted: boolean;
  grantedAt: string | null;
  policyVersion: string;
}

interface ConsentRequest {
  type: 'marketing' | 'analytics' | 'personalization' | 'third_party_sharing';
  granted: boolean;
  policyVersion: string;
}
```

---

## 4. Data Subject Rights (Pasal 5-13)

### ✅ MANDATORY: Every application MUST implement these endpoints

| Right | UU PDP Article | API Endpoint | Response Time |
|-------|---------------|-------------|---------------|
| Hak Informasi | Pasal 5 | `GET /api/v1/privacy/info` | Immediate |
| Hak Akses | Pasal 6 | `GET /api/v1/me/data` | 3×24 hours |
| Hak Koreksi | Pasal 7 | `PUT /api/v1/me/data` | 3×24 hours |
| Hak Hapus | Pasal 8 | `DELETE /api/v1/me/data` | 3×24 hours |
| Hak Portabilitas | Pasal 9 | `GET /api/v1/me/export` | 3×24 hours |
| Hak Menolak | Pasal 10 | `POST /api/v1/me/objection` | 3×24 hours |
| Hak Tarik Persetujuan | Pasal 11 | `DELETE /api/v1/consent/:type` | Immediate |
| Hak Mengajukan Keberatan | Pasal 12 | `POST /api/v1/me/complaint` | 3×24 hours |

### Implementation: Data Export (Portability)
```typescript
// ✅ REQUIRED: Export user's data in machine-readable format
// GET /api/v1/me/export?format=json

interface DataExportResponse {
  exportedAt: string;
  format: 'json' | 'csv';
  dataSubject: {
    id: string;
    email: string;
    fullName: string;
  };
  personalData: {
    profile: ProfileData;
    orders: OrderData[];
    activityLog: ActivityEntry[];
    consents: ConsentRecord[];
    preferences: UserPreferences;
  };
  metadata: {
    dataController: string;
    contactEmail: string;
    exportVersion: string;
  };
}
```

### Implementation: Right to Erasure (Hapus)
```typescript
// ✅ REQUIRED: Delete all personal data on request
// DELETE /api/v1/me/data

async function deleteUserData(userId: string): Promise<void> {
  // 1. Verify identity (re-authentication required)
  // 2. Check for legal retention obligations
  // 3. Delete or anonymize data across ALL tables
  
  await db.transaction(async (tx) => {
    // Anonymize instead of hard-delete where legal retention applies
    await tx.execute(`
      UPDATE users SET
        full_name = 'DELETED_USER',
        email = CONCAT('deleted_', id, '@deleted.local'),
        phone = NULL,
        address = NULL,
        date_of_birth = NULL,
        profile_photo_url = NULL,
        deleted_at = NOW()
      WHERE id = $1
    `, [userId]);
    
    // Hard delete data without retention obligation
    await tx.execute('DELETE FROM user_preferences WHERE user_id = $1', [userId]);
    await tx.execute('DELETE FROM user_sessions WHERE user_id = $1', [userId]);
    await tx.execute('DELETE FROM push_tokens WHERE user_id = $1', [userId]);
    
    // Anonymize transactional data (retain for financial audit)
    await tx.execute(`
      UPDATE orders SET
        customer_name = 'ANONYMIZED',
        customer_email = 'anonymized@deleted.local',
        customer_phone = NULL,
        shipping_address = 'ANONYMIZED'
      WHERE user_id = $1
    `, [userId]);
    
    // Delete from search indexes
    await searchService.removeUser(userId);
    
    // Delete uploaded files
    await storageService.deleteUserFiles(userId);
    
    // Log the deletion (audit, no PII)
    await auditLog.record({
      action: 'DATA_ERASURE',
      subjectId: userId,
      performedBy: 'SUBJECT_REQUEST',
      timestamp: new Date(),
    });
  });
}
```

---

## 5. Data Breach Notification (Pasal 46)

### Requirements
```
Rule: In case of data breach involving personal data:
      1. Notify Lembaga PDP within 3×24 HOURS
      2. Notify affected data subjects
      3. Document everything
      
      Notification MUST include:
      - What data was breached
      - When it was discovered
      - How it happened
      - What actions were taken
      - Contact person for inquiries
```

### Implementation
```typescript
// ✅ REQUIRED: Breach notification system
interface DataBreachReport {
  breachId: string;
  discoveredAt: string;
  occurredAt: string | null;
  description: string;
  dataTypes: string[];                  // ['email', 'phone', 'financial']
  dataCategories: ('umum' | 'spesifik')[];
  affectedCount: number;
  severity: 'low' | 'medium' | 'high' | 'critical';
  cause: string;                        // root cause analysis
  actionsTaken: string[];
  notifiedAuthority: boolean;
  notifiedAuthorityAt: string | null;
  notifiedSubjects: boolean;
  notifiedSubjectsAt: string | null;
  contactPerson: {
    name: string;
    email: string;
    phone: string;
  };
}

// Deadline checker
function isWithinNotificationDeadline(discoveredAt: Date): boolean {
  const hoursElapsed = (Date.now() - discoveredAt.getTime()) / (1000 * 60 * 60);
  return hoursElapsed <= 72; // 3×24 hours
}
```

---

## 6. Cross-Border Data Transfer (Pasal 56)

### Requirements
```
Rule: Personal data may ONLY be transferred outside Indonesia if:
      1. Destination country has EQUAL or HIGHER data protection standard
      2. Adequate safeguards exist (binding agreements)
      3. Data subject has given explicit consent for the transfer
      4. Transfer is necessary for contract performance
      
      If using cloud services (AWS, GCP, Azure):
      - Ensure data residency options (ap-southeast-1 / Jakarta region)
      - Document data flow and storage locations
      - Consider data localization for sensitive data
```

### Cloud Provider Regions (Indonesia)
| Provider | Region | Code |
|----------|--------|------|
| AWS | Jakarta | `ap-southeast-3` |
| GCP | Jakarta | `asia-southeast2` |
| Azure | Jakarta | `Indonesia Central` |
| Alibaba | Jakarta | `ap-southeast-5` |

---

## 7. Data Retention (Pasal 25)

### Required Retention Policy
```sql
-- ✅ REQUIRED: Define retention per data type
CREATE TABLE data_retention_policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  data_category VARCHAR(50) NOT NULL,
  retention_days INTEGER NOT NULL,
  legal_basis TEXT NOT NULL,
  deletion_method VARCHAR(20) NOT NULL DEFAULT 'hard_delete',  -- 'hard_delete', 'anonymize', 'archive'
  auto_delete BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO data_retention_policies (data_category, retention_days, legal_basis, deletion_method) VALUES
('user_sessions', 90, 'Contract — active session management', 'hard_delete'),
('activity_logs', 365, 'Legitimate interest — security audit', 'anonymize'),
('transaction_records', 1825, 'Legal obligation — tax records (5 years)', 'archive'),
('marketing_consent', 1095, 'Consent — marketing communication', 'hard_delete'),
('deleted_user_data', 30, 'Post-deletion buffer for support', 'hard_delete'),
('kyc_documents', 1825, 'Legal obligation — financial regulations', 'hard_delete');
```

### Auto-Purge Job
```typescript
// ✅ REQUIRED: Scheduled job to purge expired data
async function purgeExpiredData(): Promise<void> {
  const policies = await db.query<RetentionPolicy[]>(
    'SELECT * FROM data_retention_policies WHERE auto_delete = true'
  );
  
  for (const policy of policies) {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - policy.retentionDays);
    
    if (policy.deletionMethod === 'hard_delete') {
      await db.execute(
        `DELETE FROM ${policy.dataCategory} WHERE created_at < $1`,
        [cutoffDate]
      );
    } else if (policy.deletionMethod === 'anonymize') {
      // Anonymize PII columns but keep aggregate data
      await anonymizeRecords(policy.dataCategory, cutoffDate);
    }
    
    await auditLog.record({
      action: 'AUTO_PURGE',
      category: policy.dataCategory,
      cutoffDate: cutoffDate.toISOString(),
      method: policy.deletionMethod,
    });
  }
}
```

---

## 8. PII Handling in Code

### Logging — NEVER Log Raw PII
```typescript
// ❌ BAD: Logging PII
logger.info(`User registered: ${user.email}, phone: ${user.phone}`);

// ✅ GOOD: Log identifier only
logger.info(`User registered: ${user.id}`);

// ✅ GOOD: Masked PII if needed for debugging
logger.debug(`User login: ${maskEmail(user.email)}`);
// Output: "User login: j***@gmail.com"

function maskEmail(email: string): string {
  const [local, domain] = email.split('@');
  return `${local[0]}***@${domain}`;
}

function maskPhone(phone: string): string {
  return phone.replace(/(\d{3})\d{4,}(\d{3})/, '$1****$2');
}
```

### API Responses — Minimize PII Exposure
```typescript
// ❌ BAD: Returning all user data
app.get('/api/users/:id', (req, res) => {
  const user = await getUserById(req.params.id);
  res.json(user); // Exposes everything including KTP, DOB, etc.
});

// ✅ GOOD: Return only necessary fields
app.get('/api/users/:id', (req, res) => {
  const user = await getUserById(req.params.id);
  res.json({
    id: user.id,
    name: user.fullName,
    avatar: user.avatarUrl,
    role: user.role,
    // NEVER return: ktp_number, date_of_birth, phone, address, etc.
  });
});
```

### Error Messages — No PII Leakage
```typescript
// ❌ BAD: PII in error message
throw new Error(`User with email ${email} not found`);

// ✅ GOOD: Generic error without PII
throw new NotFoundException('User not found');
```

---

## Compliance Checklist

```
Before shipping ANY feature that handles personal data:

Data Classification
□ All personal data fields identified and classified (umum/spesifik)
□ PII data registry updated
□ Spesifik data has extra encryption

Consent
□ Legal basis identified for each data processing activity
□ Consent mechanism implemented (if consent-based)
□ Consent can be withdrawn easily
□ Consent audit trail maintained

Subject Rights
□ Access endpoint implemented (GET /me/data)
□ Correction endpoint implemented (PUT /me/data)
□ Deletion endpoint implemented (DELETE /me/data)
□ Export endpoint implemented (GET /me/export)
□ Objection mechanism available

Security
□ PII encrypted at rest (spesifik data)
□ PII encrypted in transit (TLS 1.3)
□ PII masked in logs
□ PII not in error messages
□ API responses minimize PII exposure
□ Audit logging for all PII access

Retention
□ Retention period defined for each data type
□ Auto-purge job scheduled
□ Deletion method appropriate (hard delete vs anonymize)

Cross-Border
□ Data storage location documented
□ Cloud region appropriate (Indonesia preferred for spesifik)
□ Transfer mechanism documented if cross-border
```

## Rules Integration
- **Database Rule**: Soft delete + audit columns support right to erasure and audit trail
- **Security Rule**: Encryption + input validation support PII protection
- **ISO 27000 Rule**: Data classification + access control align with UU PDP requirements
- **Production Code Rule**: No hallucinated PII endpoints, verify all data fields exist
