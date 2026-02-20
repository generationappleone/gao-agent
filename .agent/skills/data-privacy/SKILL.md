---
name: Data Privacy
description: Skill for data privacy compliance — covering PII detection, data classification, consent verification, data retention policies, data subject rights, privacy impact assessment, and compliance with UU PDP / GDPR.
---

# Data Privacy Skill

## Overview
Data privacy engineering implements technical controls for PII protection, consent management, data retention, data subject rights (access, deletion, portability), and compliance with regulations like GDPR and Indonesia's UU PDP. Privacy-by-design embeds protection into application architecture.

**References**:
- [GDPR](https://gdpr.eu/)
- [UU PDP (Indonesia)](https://peraturan.bpk.go.id/Details/229798)

---

## PII Detection & Classification

```typescript
// Data classification
enum DataClassification { PUBLIC = 'public', INTERNAL = 'internal', CONFIDENTIAL = 'confidential', RESTRICTED = 'restricted' }

const fieldClassification: Record<string, DataClassification> = {
  name: DataClassification.CONFIDENTIAL,
  email: DataClassification.CONFIDENTIAL,
  phone: DataClassification.RESTRICTED,
  nik: DataClassification.RESTRICTED,      // Indonesian ID
  address: DataClassification.CONFIDENTIAL,
  password: DataClassification.RESTRICTED,
  ip_address: DataClassification.INTERNAL,
};
```

---

## Data Retention

```typescript
// Automated data cleanup
async function enforceRetentionPolicies() {
  const policies = [
    { table: 'sessions', field: 'expiresAt', retention: 0 },           // Delete expired
    { table: 'audit_logs', field: 'createdAt', retention: 365 },       // 1 year
    { table: 'user_activity', field: 'createdAt', retention: 180 },    // 6 months
    { table: 'deleted_users', field: 'deletedAt', retention: 30 },     // 30 days
  ];

  for (const policy of policies) {
    const cutoff = new Date(Date.now() - policy.retention * 24 * 60 * 60 * 1000);
    await db.$executeRaw`DELETE FROM ${policy.table} WHERE ${policy.field} < ${cutoff}`;
  }
}
```

---

## Data Subject Rights

```typescript
// Right to access (data export)
async function exportUserData(userId: string): Promise<object> {
  const [user, orders, activities] = await Promise.all([
    db.user.findUnique({ where: { id: userId }, select: { name: true, email: true, phone: true, createdAt: true } }),
    db.order.findMany({ where: { userId }, select: { orderNumber: true, total: true, createdAt: true } }),
    db.activity.findMany({ where: { userId }, select: { action: true, createdAt: true } }),
  ]);
  return { personalData: user, orders, activities, exportedAt: new Date().toISOString() };
}

// Right to erasure
async function deleteUserData(userId: string) {
  await db.$transaction([
    db.activity.deleteMany({ where: { userId } }),
    db.session.deleteMany({ where: { userId } }),
    db.order.updateMany({ where: { userId }, data: { userId: null } }), // anonymize
    db.user.delete({ where: { id: userId } }),
  ]);
  await auditLog('USER_DELETED', { userId, deletedAt: new Date() });
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Classification** | Classify data by sensitivity level |
| **Retention** | Automated deletion per retention policy |
| **Right to access** | Export user data on request |
| **Right to erasure** | Delete/anonymize user data |
| **Consent** | Obtain and track consent |
| **Encryption** | Encrypt PII at rest and in transit |
| **Audit logging** | Log all PII access and changes |
| **Minimization** | Collect only necessary data |
| **Anonymization** | Anonymize data for analytics |
| **DPIA** | Data Protection Impact Assessment |

---

## Rules Integration
- **Classification**: Field-level data sensitivity
- **Retention**: Automated policy enforcement
- **Subject rights**: Export and deletion workflows
- **Compliance**: GDPR and UU PDP alignment
