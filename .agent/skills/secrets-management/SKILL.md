---
name: Secrets Management
description: Skill for managing secrets securely — covering secret detection, environment variable management, vault integration, key rotation, .env best practices, and preventing credential exposure in code and logs.
---

# Secrets Management Skill

## Purpose
This skill provides patterns for **detecting, preventing, and managing** secrets (API keys, passwords, tokens, certificates) to ensure they are never exposed in source code, logs, or version control.

---

## Modes

### Scan Mode
Detect secrets already in the codebase. Used by `/context-security` workflow.

### Implementation Mode
Implement secure secret storage and rotation. Used during development.

---

## Scan Mode — Secret Detection

### Step 1: Check .gitignore
```bash
# Verify .env files are ignored
grep -n "\.env" .gitignore 2>/dev/null
# Expected: .env, .env.local, .env.*.local should be listed
```

**Required .gitignore entries:**
```gitignore
# Environment files
.env
.env.local
.env.*.local
.env.production
.env.staging

# Key files
*.pem
*.key
*.p12
*.pfx
*.jks

# IDE/tool secrets
.idea/
.vscode/settings.json
```

### Step 2: Check .env.example exists
```bash
# Verify .env.example with placeholder values
cat .env.example 2>/dev/null || echo "MISSING: .env.example not found"
```

**Required:** `.env.example` must exist with placeholder values (never real credentials):
```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/mydb

# JWT
JWT_SECRET=your-jwt-secret-here-min-32-chars
JWT_EXPIRY=3600

# External APIs
STRIPE_SECRET_KEY=sk_test_placeholder
SENDGRID_API_KEY=SG.placeholder
```

### Step 3: Scan for Hardcoded Secrets
```bash
# API Keys
grep -rn "sk_live\|sk_test\|pk_live\|pk_test" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" --include="*.go" --include="*.java" --include="*.cs" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*'

# AWS Keys
grep -rn "AKIA[0-9A-Z]\{16\}" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*'

# Generic passwords/secrets
grep -rn "password\s*[:=]\s*['\"][^'\"]\{3,\}['\"]" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" --include="*.json" --include="*.yml" --include="*.yaml" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' | grep -iv "test\|spec\|mock\|example\|sample\|placeholder\|your-\|change-me\|xxx"

# Private keys
grep -rn "-----BEGIN\s\(RSA\|EC\|OPENSSH\)\sPRIVATE KEY-----" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*'

# Tokens / Bearer
grep -rn "Bearer\s[A-Za-z0-9\-_.]\{20,\}" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' | grep -iv "test\|mock\|example"

# .env files tracked in git
git ls-files | grep -i "\.env" | grep -v "\.example\|\.sample\|\.template"
```

### Step 4: Scan for Secrets in Logs
```bash
# Check if sensitive fields are logged
grep -rn "console\.log\|logger\.\|Log\.\|logging\." --include="*.ts" --include="*.js" --include="*.php" --include="*.py" -not -path '*/node_modules/*' -not -path '*/vendor/*' | grep -i "password\|secret\|token\|key\|credential\|auth"
```

### Step 5: Check Docker/CI secrets
```bash
# Dockerfile secrets
grep -n "ENV.*SECRET\|ENV.*PASSWORD\|ENV.*KEY\|ARG.*SECRET" Dockerfile* docker-compose*.yml 2>/dev/null

# CI/CD secrets in plain text
grep -rn "secret\|password\|token\|key" .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile 2>/dev/null | grep -v "\${{.*secrets\.\|env\.\|vault\."
```

---

## Implementation Mode — Secure Secret Storage

### Pattern 1: Environment Variables (Minimum Standard)
```typescript
// ✅ Correct: Read from environment
const dbUrl = process.env.DATABASE_URL;
if (!dbUrl) throw new Error('DATABASE_URL is required');

// ❌ Wrong: Hardcoded
const dbUrl = 'postgresql://admin:secret123@prod-db:5432/app';
```

### Pattern 2: Configuration Module
```typescript
// config/env.ts — Centralized environment validation
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRY: z.coerce.number().default(3600),
  REDIS_URL: z.string().url().optional(),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  SMTP_PASSWORD: z.string().min(1),
});

export const env = envSchema.parse(process.env);
// Throws at startup if any required env var is missing/invalid
```

### Pattern 3: Secret Rotation
```typescript
// Rotate JWT secret without downtime
// Support both old and new secret during rotation window

const JWT_SECRETS = [
  process.env.JWT_SECRET_CURRENT,    // Primary
  process.env.JWT_SECRET_PREVIOUS,   // Still valid during rotation
].filter(Boolean) as string[];

function verifyToken(token: string): JwtPayload {
  for (const secret of JWT_SECRETS) {
    try {
      return jwt.verify(token, secret) as JwtPayload;
    } catch {
      continue; // Try next secret
    }
  }
  throw new UnauthorizedError('Invalid token');
}

// Always sign with the current (first) secret
function signToken(payload: JwtPayload): string {
  return jwt.sign(payload, JWT_SECRETS[0], { expiresIn: '1h' });
}
```

### Pattern 4: PII Redaction in Logs
```typescript
// Redact sensitive fields before logging
const SENSITIVE_FIELDS = ['password', 'token', 'secret', 'authorization', 'cookie', 'ssn', 'creditCard'];

function redactSensitive(obj: Record<string, any>): Record<string, any> {
  const redacted = { ...obj };
  for (const key of Object.keys(redacted)) {
    if (SENSITIVE_FIELDS.some(f => key.toLowerCase().includes(f))) {
      redacted[key] = '[REDACTED]';
    } else if (typeof redacted[key] === 'object' && redacted[key] !== null) {
      redacted[key] = redactSensitive(redacted[key]);
    }
  }
  return redacted;
}

// Usage
logger.info('User login', redactSensitive({ email: user.email, password: req.body.password }));
// Output: { email: "user@example.com", password: "[REDACTED]" }
```

---

## Vault Integration Patterns

### HashiCorp Vault
```typescript
import Vault from 'node-vault';

const vault = Vault({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN,
});

async function getSecret(path: string): Promise<string> {
  const result = await vault.read(`secret/data/${path}`);
  return result.data.data.value;
}
```

### AWS Secrets Manager
```typescript
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: 'ap-southeast-1' });

async function getSecret(secretName: string): Promise<string> {
  const command = new GetSecretValueCommand({ SecretId: secretName });
  const response = await client.send(command);
  return response.SecretString!;
}
```

---

## Severity Classification

| Finding | Severity |
|---------|----------|
| Hardcoded production credentials in code | 🔴 P1 Critical |
| .env file committed to git | 🔴 P1 Critical |
| Private key in repository | 🔴 P1 Critical |
| API key in frontend bundle | 🔴 P1 Critical |
| Secret in log output | 🟡 P2 Important |
| Missing .env.example | 🟡 P2 Important |
| .env not in .gitignore | 🟡 P2 Important |
| No secret rotation mechanism | 🟢 P3 Suggestion |
| No vault integration | 🟢 P3 Suggestion |

---

## Integration with Rules
- `rules/developer-security.md` — Secrets in vault/env, never hardcoded
- `rules/iso-27000-compliance.md` — A.9 Access control, A.10 Cryptography
- `rules/production-code-standards.md` — Zero hallucinations on imports/configs
