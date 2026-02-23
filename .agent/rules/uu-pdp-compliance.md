# 🛡️ UU PDP Compliance — Indonesia Personal Data Protection Rule

> **Severity:** STRICT — LEGAL REQUIREMENT
> **Scope:** All applications that process personal data of Indonesian residents
> **Legal Basis:** UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi
> **Sanctions:** Criminal (max 6 years + Rp 6B) + Administrative (max 2% annual revenue)

---

## Overview

The agent **MUST** ensure every application that collects, stores, processes, or transmits personal data of Indonesian residents complies with UU PDP. Non-compliance carries **criminal** sanctions — this is not optional.

---

## 1. 📋 Data Classification (Mandatory)

### ✅ MUST classify ALL personal data fields in the application

| Category | Data Types | Protection Level | Action |
|----------|-----------|-----------------|--------|
| **Data Pribadi Umum** | Name, email, phone, address, DOB, gender, nationality, username | Standard | Secure storage, consent required |
| **Data Pribadi Spesifik** | Health, biometrics, genetics, criminal records, child data, financial, sexual orientation, political views, disability | 🔴 Maximum | Field-level encryption, strict access control, explicit consent |

```
Rule: Before implementing ANY feature that handles personal data:
      1. Identify ALL PII fields involved
      2. Classify each as 'umum' or 'spesifik'
      3. Document legal basis for processing
      4. Apply appropriate protection level
      
      Data Spesifik MUST be encrypted at field level (AES-256-GCM).
      NEVER store Data Spesifik in plain text.
```

---

## 2. 🤝 Consent Requirements (Pasal 20-22)

### ✅ MUST follow these consent rules

| Requirement | Rule | Violation if Missing |
|-------------|------|---------------------|
| **Explicit** | Consent must be an active action (opt-in), NEVER pre-checked | 🔴 CRITICAL |
| **Specific** | Consent per purpose, NOT blanket consent | 🔴 CRITICAL |
| **Informed** | User must understand what they agree to (Bahasa Indonesia) | 🔴 CRITICAL |
| **Freely Given** | Service must work without non-essential consent | 🟠 HIGH |
| **Withdrawable** | Withdrawal must be as easy as granting consent | 🔴 CRITICAL |
| **Audit Trail** | Every consent action must be immutably logged | 🟠 HIGH |
| **Version Tracked** | Track which policy version user consented to | 🟠 HIGH |

```
Rule: NEVER process personal data without one of these legal bases:
      1. Consent (persetujuan)
      2. Contract performance (pelaksanaan perjanjian)
      3. Legal obligation (kewajiban hukum)
      4. Vital interest (kepentingan vital)
      5. Public interest (kepentingan publik)
      6. Legitimate interest (kepentingan sah)
```

### ❌ PROHIBITED Consent Patterns (Dark Patterns)
- ❌ Pre-checked consent checkboxes
- ❌ Consent bundled with Terms of Service
- ❌ "Accept All" more prominent than "Reject All"
- ❌ Making service unusable without non-essential consent
- ❌ Difficult-to-find withdrawal mechanism
- ❌ Consent wall for reading privacy policy

---

## 3. 🔐 PII Security Requirements

### 3.1 Encryption

| Data State | Requirement | Standard |
|-----------|-------------|----------|
| **At Rest** (database) | All Data Spesifik MUST be encrypted | AES-256-GCM field-level |
| **In Transit** | ALL connections MUST use encryption | TLS 1.3 / HTTPS |
| **In Backups** | Backups containing PII MUST be encrypted | AES-256 |
| **In Logs** | PII MUST NEVER appear in logs | Masking required |
| **In Errors** | PII MUST NEVER appear in error messages | Generic errors only |
| **In URLs** | PII MUST NEVER appear in URLs/query params | Use POST body or path UUIDs |

### 3.2 Access Control

```
Rule: Access to PII MUST follow least privilege principle:
      - RBAC/ABAC for all PII access
      - Only roles that NEED PII can access it
      - Every PII access MUST be audit logged
      - Admin access to PII requires justification
```

### 3.3 Logging Rules

```typescript
// ❌ CRITICAL VIOLATION: Raw PII in logs
logger.info(`User registered: ${user.email}, phone: ${user.phone}`);
logger.error(`Failed for user: ${user.fullName} (KTP: ${user.ktpNumber})`);

// ✅ CORRECT: Log identifiers only, mask if PII needed
logger.info(`User registered: ${user.id}`);
logger.error(`Failed for user: ${user.id}`);
logger.debug(`Login attempt: ${mask.email(user.email)}`);  // j***@gmail.com
```

### 3.4 API Response Rules

```
Rule: API responses MUST return minimum necessary PII.
      
      ❌ WRONG: Return entire user object with all fields
      ✅ RIGHT: Return only fields needed for the specific use case
      
      Public API responses MUST NEVER include:
      - KTP/NIK number
      - Phone number (unless specifically requested by authenticated owner)
      - Date of birth (unless specifically needed)
      - Address (unless specifically needed)
      - Financial data
      - Health data
```

---

## 4. 👤 Data Subject Rights (Pasal 5-13)

### ✅ MUST implement ALL of these

| Right | Article | API Endpoint | Deadline | Priority |
|-------|---------|-------------|----------|----------|
| Hak Informasi | Pasal 5 | `GET /privacy/info` | Immediate | 🔴 |
| Hak Akses | Pasal 6 | `GET /me/data` | 3×24 jam | 🔴 |
| Hak Koreksi | Pasal 7 | `PUT /me/data` | 3×24 jam | 🔴 |
| Hak Hapus | Pasal 8 | `DELETE /me/data` | 3×24 jam | 🔴 |
| Hak Portabilitas | Pasal 9 | `GET /me/export` | 3×24 jam | 🔴 |
| Hak Menolak | Pasal 10 | `POST /me/objection` | 3×24 jam | 🟠 |
| Hak Tarik Persetujuan | Pasal 11 | `DELETE /consent/:type` | Immediate | 🔴 |

```
Rule: Every application MUST have a Privacy Center / Settings page
      where users can exercise all of their rights listed above.
      
      Route: /settings/privacy or /settings/privasi
```

---

## 5. 🚨 Data Breach Notification (Pasal 46)

```
Rule: In case of a data breach involving personal data:
      
      ⏰ DEADLINE: 3×24 HOURS from discovery
      
      1. Notify Lembaga PDP (Data Protection Authority)
         → Include: what data, when discovered, impact, actions taken
      
      2. Notify affected data subjects
         → Include: what happened, what data affected, what to do
      
      3. Document the incident
         → Breach report with root cause analysis
      
      NEVER attempt to hide or delay reporting a breach.
```

---

## 6. 🌏 Cross-Border Transfer (Pasal 56)

```
Rule: Personal data may ONLY be transferred outside Indonesia if:
      
      1. Destination country has EQUAL or HIGHER protection standard
      2. Adequate contractual safeguards exist
      3. Data subject has given explicit consent for transfer
      
      For cloud services:
      → PREFER Indonesian regions (Jakarta)
         AWS: ap-southeast-3 | GCP: asia-southeast2 | Azure: Indonesia Central
      → Data Spesifik SHOULD be stored in Indonesian region
      → Document ALL cross-border data flows
```

---

## 7. ⏰ Data Retention & Deletion (Pasal 25)

```
Rule: Personal data MUST be deleted when:
      1. Purpose of collection has been fulfilled
      2. Retention period has expired
      3. Data subject requests deletion (Hak Hapus)
      4. Consent has been withdrawn
      
      Implement auto-purge for expired data.
      
      Exceptions (legal retention):
      - Financial records: 5 years (tax law)
      - Employment records: per labor law requirements
      - Legal proceedings: until case is resolved
```

---

## 8. 👶 Children's Data (Pasal 25)

```
Rule: Processing personal data of children (< 18 years) requires:
      1. Age verification BEFORE data collection
      2. Parental/guardian consent
      3. Strict data minimization (collect absolute minimum)
      4. Enhanced security measures
      5. No profiling or automated decision-making
      6. No marketing to children
```

---

## 9. 📊 Privacy by Design Checklist

### Pre-Implementation (MUST complete before coding)

```
Data Collection
□ Only collecting data that is NECESSARY (data minimization)
□ Purpose for each data field is documented
□ Legal basis identified (consent, contract, legal obligation, etc.)
□ Data classified (umum vs spesifik)
□ Retention period defined

Protection
□ Data Spesifik encrypted at field level
□ TLS/HTTPS for all data in transit
□ PII masked in logs and error messages
□ Access control implemented (RBAC)
□ Audit logging for PII access

User Rights
□ Consent mechanism implemented (if consent-based)
□ Access/export endpoint available
□ Correction endpoint available
□ Deletion endpoint available
□ Consent withdrawal mechanism available
□ Privacy settings page accessible

Documentation
□ Privacy policy updated
□ Data flow diagram documented
□ DPIA completed (if required)
□ PII data registry updated
□ Cross-border transfers documented
```

### Post-Implementation (MUST verify before shipping)

```
Security Verification
□ No PII in application logs (grep check)
□ No PII in error messages
□ No PII in URLs or query parameters
□ API responses return minimum necessary PII
□ Encryption working for Data Spesifik
□ Audit log capturing all PII access

Functional Verification
□ Consent flow works (grant, withdraw, re-consent)
□ Data export produces complete, accurate JSON/CSV
□ Data deletion removes/anonymizes ALL instances
□ Retention auto-purge job scheduled and tested
□ Privacy settings page accessible and functional

Compliance Verification
□ Cookie consent banner displays before any tracking
□ GTM consent mode defaults to 'denied'
□ Third-party scripts blocked until consent granted
□ Age verification present (if applicable)
□ Cross-border transfer safeguards in place
```

---

## 10. Violation Severity Matrix

| Violation | UU PDP Article | Severity | Sanction Risk |
|-----------|---------------|----------|---------------|
| Processing without legal basis | Pasal 20 | 🔴 CRITICAL | Criminal |
| No consent mechanism | Pasal 20-22 | 🔴 CRITICAL | Criminal |
| PII in logs | Pasal 35 | 🟠 HIGH | Administrative |
| Missing data subject rights | Pasal 5-13 | 🔴 CRITICAL | Criminal + Administrative |
| Late breach notification (>72h) | Pasal 46 | 🔴 CRITICAL | Administrative |
| Unencrypted Data Spesifik | Pasal 35 | 🔴 CRITICAL | Criminal |
| No retention policy | Pasal 25 | 🟠 HIGH | Administrative |
| Unauthorized cross-border transfer | Pasal 56 | 🔴 CRITICAL | Criminal |
| Children's data without parental consent | Pasal 25 | 🔴 CRITICAL | Criminal |
| No audit trail | Pasal 35 | 🟠 HIGH | Administrative |
| PII in error messages | Pasal 35 | 🟡 MEDIUM | Administrative |
| Dark pattern consent UI | Pasal 20 | 🟠 HIGH | Administrative |
| Missing privacy policy | Pasal 39 | 🟠 HIGH | Administrative |

---

## Quick Reference

```
╔══════════════════════════════════════════════════════════════╗
║  UU PDP COMPLIANCE — 10 MANDATORY REQUIREMENTS              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  1. CLASSIFY all personal data (umum vs spesifik)            ║
║  2. CONSENT before processing (explicit, specific, informed) ║
║  3. ENCRYPT Data Spesifik at rest (AES-256-GCM)              ║
║  4. MASK PII in logs and errors (never raw PII)              ║
║  5. IMPLEMENT all data subject rights (7 rights)             ║
║  6. NOTIFY breach within 3×24 hours                          ║
║  7. VERIFY cross-border transfer safeguards                  ║
║  8. AUTO-PURGE expired data (retention policy)               ║
║  9. AUDIT LOG every PII access                               ║
║  10. AGE VERIFY before processing children's data            ║
║                                                              ║
║  SANCTIONS: 6 years prison + Rp 6B + 2% revenue             ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```
