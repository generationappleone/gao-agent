# 🏛️ ISO/IEC 27000 Series — Information Security Compliance Rule

> **Severity:** CRITICAL  
> **Scope:** All code, infrastructure, data handling, and system design  
> **Applies to:** All projects — especially those handling sensitive data, cloud services, or PII  
> **Standards Covered:** ISO/IEC 27001, 27002, 27005, 27017, 27018

---

## Overview

The agent **MUST** apply security controls derived from the ISO/IEC 27000 family of standards when writing or modifying code. These rules translate ISO requirements into **actionable development practices** that can be verified in code, configuration, and infrastructure.

---

## 1. 📋 ISO/IEC 27001 — Information Security Management System (ISMS)

> **Purpose:** Establish, implement, maintain, and continually improve an information security management system.

### 1.1 Asset Management (A.8)

Every piece of data and system resource must be identified, classified, and protected based on its sensitivity.

#### ✅ MUST do:
- **Classify data** into sensitivity levels before processing or storing
- Apply **appropriate controls** based on classification level
- Maintain an **inventory** of data assets in code documentation
- Implement **data lifecycle management** (creation → storage → processing → deletion)

#### 💡 Example: Data Classification in Code

```typescript
// ✅ REQUIRED: Define data classification levels

enum DataClassification {
  PUBLIC = 'public',           // Freely available (marketing content, public APIs)
  INTERNAL = 'internal',       // Internal use only (employee directory, internal docs)
  CONFIDENTIAL = 'confidential', // Restricted access (financial data, contracts)
  RESTRICTED = 'restricted',   // Highest protection (PII, credentials, health records)
}

// ✅ REQUIRED: Classification decorator/annotation for data models
interface ClassifiedData {
  classification: DataClassification;
  dataOwner: string;
  retentionPeriod: string;       // e.g., "7 years", "30 days"
  encryptionRequired: boolean;
  piiFields?: string[];          // Fields containing Personally Identifiable Information
}

// ✅ Applied to a model
const UserDataPolicy: ClassifiedData = {
  classification: DataClassification.RESTRICTED,
  dataOwner: 'Identity Team',
  retentionPeriod: '5 years',
  encryptionRequired: true,
  piiFields: ['email', 'phone', 'dateOfBirth', 'address', 'nationalId'],
};

// ✅ REQUIRED: Handle data based on classification
class DataHandler {
  async store(data: Record<string, unknown>, policy: ClassifiedData): Promise<void> {
    if (policy.encryptionRequired) {
      data = await this.encryptSensitiveFields(data, policy.piiFields);
    }

    // Log access (ISO 27001 A.8.2 — Information labeling)
    this.auditLogger.log({
      action: 'DATA_STORE',
      classification: policy.classification,
      dataOwner: policy.dataOwner,
      timestamp: new Date().toISOString(),
      actor: this.currentUser.id,
    });

    await this.repository.save(data);
  }
}
```

```python
# ✅ REQUIRED: Python — Data classification with decorators

from enum import Enum
from functools import wraps

class DataClassification(Enum):
    PUBLIC = "public"
    INTERNAL = "internal"
    CONFIDENTIAL = "confidential"
    RESTRICTED = "restricted"

def classified(level: DataClassification, pii_fields: list[str] | None = None):
    """Decorator to mark functions that handle classified data."""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Audit log before processing classified data
            audit_logger.info(
                "classified_data_access",
                classification=level.value,
                function=func.__name__,
                pii_fields=pii_fields or [],
                actor=get_current_user_id(),
            )
            return await func(*args, **kwargs)
        wrapper._classification = level
        wrapper._pii_fields = pii_fields
        return wrapper
    return decorator

# Usage
@classified(DataClassification.RESTRICTED, pii_fields=["email", "phone", "ssn"])
async def get_user_profile(user_id: str) -> UserProfile:
    return await user_repo.find_by_id(user_id)
```

### 1.2 Access Control (A.9)

#### ✅ MUST implement:
- **Role-Based Access Control (RBAC)** or **Attribute-Based Access Control (ABAC)**
- **Principle of Least Privilege** — grant minimum necessary permissions
- **Separation of Duties** — prevent single user from performing conflicting operations
- **Access review logs** — all access to sensitive resources must be auditable

#### 💡 Example: RBAC Implementation

```typescript
// ✅ REQUIRED: Fine-grained permission system (ISO 27001 A.9.1)

// --- Permission definitions ---
const Permissions = {
  // Users
  'users:read': 'View user profiles',
  'users:create': 'Create new users',
  'users:update': 'Modify user data',
  'users:delete': 'Delete users',
  'users:read_pii': 'View PII fields (email, phone, SSN)',

  // Orders
  'orders:read': 'View orders',
  'orders:create': 'Create orders',
  'orders:refund': 'Process refunds',

  // Admin
  'admin:audit_logs': 'View audit logs',
  'admin:system_config': 'Modify system configuration',
} as const;

type Permission = keyof typeof Permissions;

// --- Role definitions (Least Privilege) ---
const Roles: Record<string, Permission[]> = {
  viewer: ['users:read', 'orders:read'],
  agent: ['users:read', 'users:update', 'orders:read', 'orders:create'],
  manager: ['users:read', 'users:update', 'users:read_pii', 'orders:read', 'orders:create', 'orders:refund'],
  admin: Object.keys(Permissions) as Permission[],
};

// --- Authorization middleware ---
function requirePermission(...required: Permission[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const userPermissions = req.user.permissions;
    const hasAll = required.every(p => userPermissions.includes(p));

    if (!hasAll) {
      auditLogger.warn('ACCESS_DENIED', {
        userId: req.user.id,
        requiredPermissions: required,
        endpoint: req.path,
        method: req.method,
        ip: req.ip,
      });
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    auditLogger.info('ACCESS_GRANTED', {
      userId: req.user.id,
      permissions: required,
      endpoint: req.path,
    });

    next();
  };
}

// --- Separation of Duties ---
// A user who creates an order CANNOT approve their own order
function requireDifferentApprover(req: Request, res: Response, next: NextFunction) {
  const order = req.order;
  if (order.createdBy === req.user.id) {
    return res.status(403).json({
      error: 'Separation of duties violation: cannot approve your own order',
    });
  }
  next();
}

// --- Route application ---
router.get('/api/users', requirePermission('users:read'), userController.list);
router.get('/api/users/:id/pii', requirePermission('users:read_pii'), userController.getPiiData);
router.delete('/api/users/:id', requirePermission('users:delete'), userController.delete);
router.post('/api/orders/:id/approve', requirePermission('orders:refund'), requireDifferentApprover, orderController.approve);
```

### 1.3 Cryptography (A.10)

#### ✅ MUST implement:
- **Encryption at rest** for CONFIDENTIAL and RESTRICTED data
- **Encryption in transit** (TLS 1.2+ mandatory, TLS 1.3 preferred)
- **Key management** — keys must be rotated, stored securely, never hardcoded
- Use **approved algorithms only**

#### Approved Cryptographic Algorithms

| Purpose | Approved | Prohibited |
|---------|----------|------------|
| **Hashing** | SHA-256, SHA-384, SHA-512, SHA-3 | MD5, SHA-1 |
| **Password hashing** | Argon2id, bcrypt (cost ≥ 12), scrypt | MD5, SHA-1, plain SHA-256 |
| **Symmetric encryption** | AES-256-GCM, ChaCha20-Poly1305 | DES, 3DES, RC4, AES-ECB |
| **Asymmetric encryption** | RSA ≥ 2048-bit, Ed25519, ECDSA P-256+ | RSA < 2048, DSA |
| **Key exchange** | ECDH (P-256+), X25519 | DH < 2048 |
| **TLS** | TLS 1.2, TLS 1.3 | SSL, TLS 1.0, TLS 1.1 |

#### 💡 Example: Field-Level Encryption

```typescript
// ✅ REQUIRED: Encrypt PII fields at rest (ISO 27001 A.10.1)

import { createCipheriv, createDecipheriv, randomBytes } from 'node:crypto';

class FieldEncryption {
  private readonly algorithm = 'aes-256-gcm';
  
  constructor(private readonly masterKey: Buffer) {
    if (masterKey.length !== 32) throw new Error('Key must be 256 bits');
  }

  encrypt(plaintext: string): EncryptedField {
    const iv = randomBytes(12); // 96-bit IV for GCM
    const cipher = createCipheriv(this.algorithm, this.masterKey, iv);
    
    let encrypted = cipher.update(plaintext, 'utf8', 'base64');
    encrypted += cipher.final('base64');
    const authTag = cipher.getAuthTag();

    return {
      ciphertext: encrypted,
      iv: iv.toString('base64'),
      authTag: authTag.toString('base64'),
      algorithm: this.algorithm,
      keyVersion: 'v1', // For key rotation tracking
    };
  }

  decrypt(field: EncryptedField): string {
    const decipher = createDecipheriv(
      this.algorithm,
      this.masterKey,
      Buffer.from(field.iv, 'base64'),
    );
    decipher.setAuthTag(Buffer.from(field.authTag, 'base64'));

    let decrypted = decipher.update(field.ciphertext, 'base64', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  }
}

// Usage: Encrypt PII fields before storing
class UserRepository {
  constructor(private readonly encryption: FieldEncryption, private readonly db: Database) {}

  async create(user: CreateUserData): Promise<User> {
    const encryptedUser = {
      ...user,
      email: this.encryption.encrypt(user.email),        // Encrypted at rest
      phone: this.encryption.encrypt(user.phone),        // Encrypted at rest
      nationalId: this.encryption.encrypt(user.nationalId), // Encrypted at rest
      // Non-PII fields stored in plaintext
      firstName: user.firstName,
      isActive: true,
    };
    return this.db.insert('users', encryptedUser);
  }
}
```

### 1.4 Operations Security (A.12)

#### ✅ MUST implement:
- **Comprehensive logging** for security-relevant events
- **Change management** — all changes to production must be tracked
- **Backup and recovery** procedures
- **Capacity management** — resource limits and monitoring

### 1.5 Incident Management (A.16)

#### 💡 Example: Security Event Logging

```typescript
// ✅ REQUIRED: Structured security event logging (ISO 27001 A.12.4 + A.16)

interface SecurityEvent {
  eventId: string;
  timestamp: string;
  eventType: SecurityEventType;
  severity: 'info' | 'warning' | 'critical';
  actor: {
    userId?: string;
    ip: string;
    userAgent: string;
  };
  resource: {
    type: string;
    id: string;
    classification?: DataClassification;
  };
  action: string;
  outcome: 'success' | 'failure';
  details: Record<string, unknown>;
}

enum SecurityEventType {
  AUTHENTICATION = 'authentication',
  AUTHORIZATION = 'authorization',
  DATA_ACCESS = 'data_access',
  DATA_MODIFICATION = 'data_modification',
  DATA_EXPORT = 'data_export',
  CONFIGURATION_CHANGE = 'configuration_change',
  PRIVILEGE_ESCALATION = 'privilege_escalation',
  ANOMALY_DETECTED = 'anomaly_detected',
}

class SecurityAuditLogger {
  async log(event: SecurityEvent): Promise<void> {
    // Write to immutable audit log (append-only, tamper-evident)
    await this.auditStore.append({
      ...event,
      eventId: uuidv7(),
      timestamp: new Date().toISOString(),
      integrity: this.computeHMAC(event), // Tamper detection
    });

    // Alert on critical events
    if (event.severity === 'critical') {
      await this.alertService.sendAlert({
        channel: 'security-incidents',
        message: `CRITICAL: ${event.eventType} - ${event.action} by ${event.actor.userId || 'anonymous'}`,
        event,
      });
    }
  }
}

// ✅ REQUIRED: Events that MUST be logged
// - All authentication attempts (success and failure)
// - All authorization failures (access denied)
// - All access to RESTRICTED/CONFIDENTIAL data
// - All data modifications (create, update, delete)
// - All configuration changes
// - All privilege changes (role assignments)
// - All data exports or bulk downloads
// - All API key/token creation and revocation
```

---

## 2. 🔒 ISO/IEC 27002 — Information Security Controls

> **Purpose:** Reference set of information security controls for implementing ISO 27001.

### 2.1 Organizational Controls

#### 2.1.1 Policies & Responsibilities in Code

```typescript
// ✅ REQUIRED: Security policy enforcement in code (ISO 27002 5.1)

// Password policy configuration (centralized, auditable)
const SecurityPolicy = {
  password: {
    minLength: 12,
    requireUppercase: true,
    requireLowercase: true,
    requireDigit: true,
    requireSpecialChar: true,
    maxAge: 90,                    // Days before forced rotation
    historyCount: 12,              // Prevent reusing last 12 passwords
    lockoutThreshold: 5,           // Lock after 5 failed attempts
    lockoutDuration: 15 * 60,      // 15 minutes lockout (seconds)
  },
  session: {
    accessTokenTTL: 15 * 60,       // 15 minutes
    refreshTokenTTL: 7 * 24 * 3600, // 7 days
    absoluteTimeout: 8 * 3600,     // 8 hours regardless of activity
    idleTimeout: 30 * 60,          // 30 minutes of inactivity
    maxConcurrentSessions: 3,
  },
  dataRetention: {
    auditLogs: '7 years',          // ISO 27002 8.15
    userAccounts: '5 years',       // After deletion
    transactionRecords: '7 years',
    sessionLogs: '90 days',
    temporaryFiles: '24 hours',
  },
  encryption: {
    algorithm: 'aes-256-gcm',
    keyRotationPeriod: '90 days',
    tlsMinVersion: 'TLSv1.2',
  },
} as const;
```

### 2.2 People Controls (ISO 27002 Section 6)

```typescript
// ✅ REQUIRED: User lifecycle management

class UserLifecycleService {
  // ISO 27002 6.1 — Screening: validate user before onboarding
  async onboardUser(userData: OnboardUserDto): Promise<User> {
    const user = await this.userRepo.create({
      ...userData,
      isActive: true,
      mustChangePassword: true,         // Force password change on first login
      mfaEnabled: false,                // Prompt to enable MFA
      passwordExpiresAt: this.calculatePasswordExpiry(),
    });

    await this.auditLogger.log({
      eventType: SecurityEventType.CONFIGURATION_CHANGE,
      action: 'USER_ONBOARDED',
      resource: { type: 'user', id: user.id },
      severity: 'info',
    });

    return user;
  }

  // ISO 27002 6.5 — Responsibilities after termination
  async offboardUser(userId: string, reason: string): Promise<void> {
    // 1. Revoke all active sessions
    await this.sessionService.revokeAllSessions(userId);

    // 2. Revoke all API keys/tokens
    await this.tokenService.revokeAllTokens(userId);

    // 3. Disable account (soft delete — keep for audit trail)
    await this.userRepo.update(userId, {
      isActive: false,
      deletedAt: new Date(),
      offboardReason: reason,
    });

    // 4. Transfer ownership of resources
    await this.resourceService.transferOwnership(userId, 'system-admin');

    // 5. Log the offboarding
    await this.auditLogger.log({
      eventType: SecurityEventType.CONFIGURATION_CHANGE,
      action: 'USER_OFFBOARDED',
      resource: { type: 'user', id: userId },
      severity: 'warning',
      details: { reason },
    });
  }
}
```

### 2.3 Technology Controls (ISO 27002 Section 8)

#### 2.3.1 Secure Development Lifecycle

```typescript
// ✅ REQUIRED: Input validation controls (ISO 27002 8.26)

// Central validation middleware — applied to ALL inputs
class InputValidationMiddleware {
  // ISO 27002 8.26 — Application security requirements
  validate(schema: ZodSchema, source: 'body' | 'params' | 'query') {
    return (req: Request, res: Response, next: NextFunction) => {
      const data = req[source];
      const result = schema.safeParse(data);

      if (!result.success) {
        this.auditLogger.log({
          eventType: SecurityEventType.ANOMALY_DETECTED,
          action: 'INPUT_VALIDATION_FAILURE',
          severity: 'warning',
          details: {
            endpoint: req.path,
            source,
            errors: result.error.issues,
            ip: req.ip,
          },
        });

        return res.status(400).json({
          error: { code: 'VALIDATION_ERROR', message: 'Invalid input' },
        });
      }

      req[source] = result.data; // Replace with sanitized data
      next();
    };
  }
}
```

#### 2.3.2 Secure Configuration Management

```typescript
// ✅ REQUIRED: Secure defaults (ISO 27002 8.9)

// All security controls MUST be enabled by default
const securityDefaults = {
  // HTTP Headers
  headers: {
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',
    'Content-Security-Policy': "default-src 'self'; script-src 'self'",
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
  },

  // CORS — deny all by default, allowlist specific origins
  cors: {
    origin: [], // Must explicitly add allowed origins
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true,
  },

  // Rate limiting — enabled by default
  rateLimit: {
    global: { windowMs: 15 * 60 * 1000, max: 100 },
    auth: { windowMs: 15 * 60 * 1000, max: 5 },
    api: { windowMs: 60 * 1000, max: 30 },
  },

  // Cookie security — all flags enabled by default
  cookies: {
    httpOnly: true,
    secure: true,
    sameSite: 'strict' as const,
    path: '/',
  },
};
```

---

## 3. ⚖️ ISO/IEC 27005 — Information Security Risk Management

> **Purpose:** Provide guidelines for information security risk assessment and treatment.

### 3.1 Risk Assessment in Code

#### ✅ MUST implement:
- **Identify risks** associated with each feature/module
- Assign **risk levels** (impact × likelihood)
- Apply **controls proportional to the risk level**
- Document **residual risks** that cannot be fully mitigated

#### 💡 Example: Risk-Based Security Controls

```typescript
// ✅ REQUIRED: Apply security controls based on risk level (ISO 27005)

enum RiskLevel {
  LOW = 'low',           // Public content, read-only operations
  MEDIUM = 'medium',     // Internal operations, non-sensitive data
  HIGH = 'high',         // Financial transactions, PII access
  CRITICAL = 'critical', // Authentication, privilege changes, bulk data export
}

// Risk-based control requirements
const RiskControls: Record<RiskLevel, SecurityRequirements> = {
  [RiskLevel.LOW]: {
    authentication: true,
    authorization: false,         // Public access OK
    inputValidation: true,
    rateLimit: { max: 100, windowMs: 60000 },
    auditLog: false,
    encryption: false,
    mfa: false,
  },
  [RiskLevel.MEDIUM]: {
    authentication: true,
    authorization: true,
    inputValidation: true,
    rateLimit: { max: 50, windowMs: 60000 },
    auditLog: true,               // Log all access
    encryption: false,
    mfa: false,
  },
  [RiskLevel.HIGH]: {
    authentication: true,
    authorization: true,
    inputValidation: true,
    rateLimit: { max: 20, windowMs: 60000 },
    auditLog: true,
    encryption: true,             // Encrypt data at rest
    mfa: false,
  },
  [RiskLevel.CRITICAL]: {
    authentication: true,
    authorization: true,
    inputValidation: true,
    rateLimit: { max: 5, windowMs: 60000 },
    auditLog: true,
    encryption: true,
    mfa: true,                    // Require MFA for critical operations
  },
};

// ✅ REQUIRED: Apply controls based on risk level
function applyRiskControls(riskLevel: RiskLevel) {
  const controls = RiskControls[riskLevel];
  const middlewares: RequestHandler[] = [];

  if (controls.authentication) middlewares.push(authenticateMiddleware);
  if (controls.authorization) middlewares.push(authorizeMiddleware);
  if (controls.inputValidation) middlewares.push(validateMiddleware);
  if (controls.rateLimit) middlewares.push(rateLimitMiddleware(controls.rateLimit));
  if (controls.auditLog) middlewares.push(auditLogMiddleware);
  if (controls.mfa) middlewares.push(requireMfaMiddleware);

  return middlewares;
}

// --- Route definitions with risk levels ---
// Low risk: public content
router.get('/api/articles', ...applyRiskControls(RiskLevel.LOW), articleController.list);

// Medium risk: internal data
router.get('/api/users', ...applyRiskControls(RiskLevel.MEDIUM), userController.list);

// High risk: financial operations
router.post('/api/payments', ...applyRiskControls(RiskLevel.HIGH), paymentController.create);

// Critical risk: privilege changes
router.put('/api/users/:id/role', ...applyRiskControls(RiskLevel.CRITICAL), userController.changeRole);
```

### 3.2 Risk Documentation in Code

```typescript
// ✅ REQUIRED: Document risks directly in code

/**
 * @risk HIGH — This endpoint exposes user PII.
 * @threat Unauthorized access to personal data (identity theft)
 * @impact High — Regulatory fines (GDPR), reputation damage
 * @likelihood Medium — Protected by auth + RBAC, but insider threat exists
 * @controls Authentication, RBAC (users:read_pii), audit logging, field encryption
 * @residualRisk LOW — Insider threat mitigated by audit logging and access reviews
 * @isoRef ISO 27005:2022 Section 8.2, ISO 27001 A.9.4.1
 */
router.get(
  '/api/users/:id/personal-data',
  ...applyRiskControls(RiskLevel.HIGH),
  requirePermission('users:read_pii'),
  userController.getPersonalData,
);
```

---

## 4. ☁️ ISO/IEC 27017 — Cloud Security Controls

> **Purpose:** Guidelines for information security controls applicable to cloud services.

### 4.1 Cloud-Specific Security Requirements

#### ✅ MUST implement for cloud-deployed applications:

| Control Area | Requirement |
|-------------|-------------|
| **Shared responsibility** | Document which security controls are the provider's vs. the application's |
| **Virtual isolation** | Ensure tenant data isolation in multi-tenant environments |
| **Cloud service monitoring** | Implement health checks, uptime monitoring, and alerting |
| **Data location** | Document where data is stored and processed (region/jurisdiction) |
| **Secure API access** | All cloud APIs must use authenticated, encrypted connections |
| **Resource cleanup** | Implement automated cleanup of orphaned cloud resources |

#### 💡 Example: Cloud Security Configuration

```typescript
// ✅ REQUIRED: Cloud-specific security controls (ISO 27017)

// --- Multi-tenancy isolation (ISO 27017 CLD.9.5.1) ---
class TenantIsolationMiddleware {
  handle(req: Request, res: Response, next: NextFunction) {
    const tenantId = req.headers['x-tenant-id'] as string;
    
    if (!tenantId || !isValidUUID(tenantId)) {
      return res.status(400).json({ error: 'Valid tenant ID required' });
    }

    // Verify user belongs to this tenant
    if (!req.user.tenants.includes(tenantId)) {
      this.auditLogger.log({
        eventType: SecurityEventType.AUTHORIZATION,
        action: 'CROSS_TENANT_ACCESS_BLOCKED',
        severity: 'critical',
        actor: { userId: req.user.id, ip: req.ip, userAgent: req.headers['user-agent'] },
        resource: { type: 'tenant', id: tenantId },
        outcome: 'failure',
      });
      return res.status(403).json({ error: 'Access denied' });
    }

    // Set tenant context for all downstream queries
    req.tenantContext = tenantId;
    next();
  }
}

// --- Cloud resource monitoring (ISO 27017 CLD.12.4.5) ---
class CloudHealthMonitor {
  async checkHealth(): Promise<HealthReport> {
    const checks = await Promise.allSettled([
      this.checkDatabase(),
      this.checkCache(),
      this.checkStorage(),
      this.checkExternalAPIs(),
    ]);

    const report: HealthReport = {
      status: checks.every(c => c.status === 'fulfilled') ? 'healthy' : 'degraded',
      timestamp: new Date().toISOString(),
      region: process.env.CLOUD_REGION,
      services: checks.map((c, i) => ({
        name: ['database', 'cache', 'storage', 'externalAPIs'][i],
        status: c.status === 'fulfilled' ? 'up' : 'down',
        latencyMs: c.status === 'fulfilled' ? c.value.latencyMs : null,
      })),
    };

    if (report.status !== 'healthy') {
      await this.alertService.sendAlert({ severity: 'warning', report });
    }

    return report;
  }
}
```

```hcl
# ✅ REQUIRED: Terraform — Cloud security controls (ISO 27017)

# Data residency — enforce specific regions (ISO 27017 CLD.6.3)
variable "allowed_regions" {
  type    = list(string)
  default = ["ap-southeast-1", "ap-southeast-3"]  # Singapore, Jakarta
  
  validation {
    condition     = length(var.allowed_regions) > 0
    error_message = "At least one region must be specified for data residency compliance."
  }
}

# Cloud logging (ISO 27017 CLD.12.4)
resource "aws_cloudtrail" "main" {
  name                          = "${var.project}-audit-trail"
  s3_bucket_name               = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_log_file_validation   = true  # Tamper-evident logs
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
  
  kms_key_id = aws_kms_key.audit.arn  # Encrypted audit logs
}

# Virtual network isolation (ISO 27017 CLD.13.1)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project}-vpc", ISOControl = "27017-CLD.13.1" }
}

# Enforce encryption in transit (ISO 27017 CLD.10.1)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # TLS 1.3
  certificate_arn   = aws_acm_certificate.main.arn
}

# Block all HTTP traffic
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect { port = "443"; protocol = "HTTPS"; status_code = "HTTP_301" }
  }
}
```

---

## 5. 🧑‍💼 ISO/IEC 27018 — Protection of PII in Public Clouds

> **Purpose:** Establish controls for protecting Personally Identifiable Information (PII) in cloud environments.

### 5.1 PII Categories and Handling Requirements

| PII Category | Examples | Required Controls |
|-------------|----------|-------------------|
| **Direct identifiers** | Full name, email, phone, national ID | Encryption at rest, access logging, consent tracking |
| **Indirect identifiers** | Date of birth, zip code, job title | Encryption at rest, access logging |
| **Sensitive PII** | Health records, biometric data, sexual orientation, religion | Encryption at rest + field-level, explicit consent, MFA for access |
| **Financial PII** | Credit card, bank account, salary | PCI-DSS compliance, tokenization, encryption |

### 5.2 PII Processing Controls

#### ✅ MUST implement:
- **Consent management** — track and enforce data subject consent
- **Purpose limitation** — PII must only be used for the stated purpose
- **Data minimization** — collect only PII that is strictly necessary
- **Right to access/delete** — implement DSAR (Data Subject Access Request) endpoints
- **Data breach notification** — automated detection and notification pipeline
- **Sub-processor tracking** — document all third parties that process PII

#### 💡 Example: PII Protection Framework

```typescript
// ✅ REQUIRED: PII protection framework (ISO 27018)

// --- Consent management (ISO 27018 A.2.1) ---
interface ConsentRecord {
  id: string;
  userId: string;
  purpose: ConsentPurpose;
  grantedAt: Date;
  revokedAt: Date | null;
  expiresAt: Date;
  lawfulBasis: 'consent' | 'contract' | 'legal_obligation' | 'legitimate_interest';
  version: string;
}

enum ConsentPurpose {
  MARKETING = 'marketing',
  ANALYTICS = 'analytics',
  PERSONALIZATION = 'personalization',
  THIRD_PARTY_SHARING = 'third_party_sharing',
  SERVICE_DELIVERY = 'service_delivery',
}

class ConsentService {
  async grantConsent(userId: string, purpose: ConsentPurpose, basis: string): Promise<ConsentRecord> {
    const consent: ConsentRecord = {
      id: uuidv7(),
      userId,
      purpose,
      grantedAt: new Date(),
      revokedAt: null,
      expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
      lawfulBasis: basis,
      version: '2.0',
    };

    await this.consentRepo.save(consent);
    await this.auditLogger.log({
      eventType: SecurityEventType.DATA_MODIFICATION,
      action: 'CONSENT_GRANTED',
      resource: { type: 'consent', id: consent.id, classification: DataClassification.RESTRICTED },
      details: { purpose, basis },
    });

    return consent;
  }

  async checkConsent(userId: string, purpose: ConsentPurpose): Promise<boolean> {
    const consent = await this.consentRepo.findActiveConsent(userId, purpose);
    return consent !== null && consent.revokedAt === null && consent.expiresAt > new Date();
  }
}

// --- PII access guard (ISO 27018 A.1.1) ---
async function piiAccessGuard(req: Request, res: Response, next: NextFunction) {
  const targetUserId = req.params.userId;
  const purpose = req.headers['x-data-purpose'] as string;

  // Check consent exists for this purpose
  const hasConsent = await consentService.checkConsent(targetUserId, purpose as ConsentPurpose);
  if (!hasConsent) {
    return res.status(403).json({
      error: 'No valid consent for this data purpose',
      requiredAction: 'Obtain user consent before accessing PII',
    });
  }

  // Log PII access (mandatory for ISO 27018)
  await auditLogger.log({
    eventType: SecurityEventType.DATA_ACCESS,
    action: 'PII_ACCESSED',
    actor: { userId: req.user.id, ip: req.ip, userAgent: req.headers['user-agent'] || '' },
    resource: { type: 'user_pii', id: targetUserId, classification: DataClassification.RESTRICTED },
    outcome: 'success',
    details: { purpose, fields: req.query.fields },
    severity: 'info',
  });

  next();
}

// --- Data Subject Access Request — DSAR (ISO 27018 A.1.1) ---
class DSARService {
  // Right to access — export all PII for a user
  async handleAccessRequest(userId: string): Promise<PIIExport> {
    await this.auditLogger.log({
      eventType: SecurityEventType.DATA_EXPORT,
      action: 'DSAR_ACCESS_REQUEST',
      resource: { type: 'user', id: userId },
      severity: 'warning',
    });

    return {
      personalData: await this.userRepo.findAllPII(userId),
      consents: await this.consentRepo.findAllByUser(userId),
      activityLog: await this.activityRepo.findByUser(userId),
      thirdPartySharing: await this.sharingRepo.findByUser(userId),
      exportedAt: new Date().toISOString(),
      format: 'JSON',
    };
  }

  // Right to erasure — delete all PII for a user
  async handleDeletionRequest(userId: string, reason: string): Promise<void> {
    await this.auditLogger.log({
      eventType: SecurityEventType.DATA_MODIFICATION,
      action: 'DSAR_DELETION_REQUEST',
      resource: { type: 'user', id: userId },
      severity: 'critical',
      details: { reason },
    });

    // 1. Anonymize data instead of hard delete (preserve referential integrity)
    await this.userRepo.anonymize(userId, {
      email: `deleted-${uuidv4()}@anonymized.local`,
      firstName: 'DELETED',
      lastName: 'USER',
      phone: null,
      nationalId: null,
      address: null,
    });

    // 2. Revoke all consents
    await this.consentRepo.revokeAll(userId);

    // 3. Revoke all sessions and tokens
    await this.sessionService.revokeAllSessions(userId);

    // 4. Notify sub-processors to delete PII
    await this.subProcessorService.requestDeletion(userId);
  }
}
```

### 5.3 Data Breach Response (ISO 27018 A.9.1)

```typescript
// ✅ REQUIRED: Automated breach detection and notification

class DataBreachHandler {
  // Anomaly detection triggers
  private readonly breachIndicators = [
    'BULK_PII_EXPORT',                    // Large PII data export
    'UNAUTHORIZED_PII_ACCESS',            // PII access without proper authorization
    'MULTIPLE_FAILED_AUTH_SAME_ACCOUNT',   // Brute force on specific account
    'UNUSUAL_GEOGRAPHIC_ACCESS',           // Access from unusual location
    'PRIVILEGE_ESCALATION_ATTEMPT',        // Unauthorized role change attempt
  ];

  async handlePotentialBreach(event: SecurityEvent): Promise<void> {
    // 1. Assess severity
    const severity = this.assessBreachSeverity(event);

    // 2. Contain — auto-lock affected accounts
    if (severity === 'critical') {
      await this.containBreach(event);
    }

    // 3. Notify security team immediately
    await this.notifySecurityTeam({
      breachId: uuidv7(),
      detectedAt: new Date().toISOString(),
      severity,
      event,
      affectedUsers: await this.identifyAffectedUsers(event),
      containmentActions: ['Account locked', 'Sessions revoked'],
    });

    // 4. Regulatory notification (ISO 27018 A.9.1 — within 72 hours for GDPR)
    if (severity === 'critical' && this.involvePII(event)) {
      await this.scheduleRegulatoryNotification({
        deadline: new Date(Date.now() + 72 * 60 * 60 * 1000), // 72 hours
        authority: 'Data Protection Authority',
        breachDetails: event,
      });
    }
  }
}
```

---

## 📋 ISO 27000 Compliance Checklist

### ISO 27001 — ISMS Controls
- [ ] Data classification defined and enforced in code
- [ ] RBAC/ABAC implemented with least privilege
- [ ] Separation of duties enforced for critical operations
- [ ] Approved cryptographic algorithms used (no MD5, SHA-1, DES)
- [ ] Encryption at rest for CONFIDENTIAL/RESTRICTED data
- [ ] TLS 1.2+ enforced for all network communication
- [ ] Security events logged immutably with tamper detection
- [ ] Incident detection and alerting implemented

### ISO 27002 — Security Controls
- [ ] Password policy enforced (length, complexity, rotation, history)
- [ ] Session management with timeouts and concurrent session limits
- [ ] Input validation on ALL user inputs
- [ ] Secure defaults — all security features enabled by default
- [ ] User lifecycle management (onboarding, offboarding, access review)
- [ ] Data retention policies implemented and enforced

### ISO 27005 — Risk Management
- [ ] Risk levels assigned to all endpoints/features
- [ ] Security controls proportional to risk level
- [ ] Risk documentation in code (JSDoc/comments)
- [ ] Residual risks documented and accepted

### ISO 27017 — Cloud Security
- [ ] Tenant isolation verified in multi-tenant systems
- [ ] Cloud health monitoring with alerting
- [ ] Data residency documented (region/jurisdiction)
- [ ] Virtual network isolation configured
- [ ] Cloud audit trails enabled and encrypted

### ISO 27018 — PII Protection
- [ ] PII fields identified and documented in data models
- [ ] Consent management system implemented
- [ ] PII access requires valid consent + audit logging
- [ ] DSAR endpoints implemented (access, export, deletion)
- [ ] Data anonymization for deletion requests (not hard delete)
- [ ] Data breach detection and 72-hour notification pipeline
- [ ] Sub-processor inventory documented and tracked

---

## ⚠️ Exceptions

These rules may be **relaxed** only in:

1. **Non-production environments** — Development/staging may have reduced controls, but data classification and PII protection must still be enforced if real data is used
2. **Prototyping** — Basic controls may be skipped, but agent must add `// TODO: ISO 27001 compliance required before production`
3. **Public-only data** — Systems handling only PUBLIC classified data may skip encryption at rest and PII controls

> ⚠️ **CRITICAL:** If the project handles **any PII** (names, emails, phone numbers, etc.), ISO 27018 controls are **NON-NEGOTIABLE** regardless of project phase.
