---
name: Security Code Review
description: Skill for conducting comprehensive security code reviews using OWASP Top 10, SAST/DAST patterns, and Hack23 ISMS secure development policy to identify and remediate vulnerabilities.
---

# Security Code Review Skill

## Overview
Security code review goes beyond functional correctness to identify vulnerabilities, insecure patterns, and compliance gaps. This skill provides structured checklists organized by vulnerability category, with patterns for both manual review and automated tooling.

**References**:
- [OWASP Code Review Guide](https://owasp.org/www-project-code-review-guide/)
- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)

---

## Review Checklist by Category

### Authentication & Session
```markdown
# Auth Review Points
- [ ] Passwords hashed with bcrypt/argon2 (not MD5/SHA1)
- [ ] Password complexity enforced (min 8 chars, mixed case)
- [ ] Brute force protection (rate limiting + lockout)
- [ ] Session tokens regenerated after authentication
- [ ] Logout invalidates session server-side
- [ ] JWT: short expiry (15min), RS256 not HS256 with weak secret
- [ ] JWT: refresh token rotation with reuse detection
- [ ] MFA implementation for admin/sensitive operations
- [ ] Password reset tokens single-use and time-limited
- [ ] No credentials in URLs, logs, or error messages
```

```typescript
// ❌ VULNERABLE: Weak password hashing
const hash = crypto.createHash('md5').update(password).digest('hex');

// ✅ SECURE: bcrypt with proper rounds
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(password, 12);
const valid = await bcrypt.compare(password, hash);

// ❌ VULNERABLE: JWT with weak secret
jwt.sign(payload, 'secret123', { expiresIn: '30d' });

// ✅ SECURE: Strong secret, short expiry
jwt.sign(payload, process.env.JWT_SECRET, { // 64+ byte random string
  expiresIn: '15m',
  algorithm: 'RS256',
  issuer: 'myapp.com',
});
```

### Input Validation
```markdown
- [ ] All inputs validated server-side (not just client)
- [ ] Schema validation (Zod/Joi) on request body
- [ ] Path parameters validated (type, range)
- [ ] Query parameters sanitized
- [ ] File uploads: type, size, name validation
- [ ] No reliance on Content-Type header for security
- [ ] Array/object depth limits to prevent DoS
```

```typescript
// ❌ VULNERABLE: No validation
app.post('/api/users', (req, res) => {
  db.user.create({ data: req.body });  // Accepts anything
});

// ✅ SECURE: Schema validation
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100).trim(),
  role: z.enum(['user', 'admin']),
}).strict();  // Reject unknown fields

app.post('/api/users', (req, res) => {
  const data = CreateUserSchema.parse(req.body);
  db.user.create({ data });
});
```

### SQL Injection
```markdown
- [ ] Parameterized queries everywhere
- [ ] No string concatenation/interpolation in SQL
- [ ] ORM used correctly (no raw queries with user input)
- [ ] Stored procedures use parameterized inputs
- [ ] Database user has minimal required permissions
```

```typescript
// ❌ VULNERABLE: String interpolation
const users = await db.$queryRawUnsafe(`SELECT * FROM users WHERE email = '${email}'`);

// ✅ SECURE: Parameterized query
const users = await db.$queryRaw`SELECT * FROM users WHERE email = ${email}`;

// ❌ VULNERABLE: Dynamic column name
const orderBy = req.query.sort;  // Could be: "name; DROP TABLE users--"
const users = await db.$queryRawUnsafe(`SELECT * FROM users ORDER BY ${orderBy}`);

// ✅ SECURE: Allowlist for dynamic values
const allowedSort = ['name', 'email', 'created_at'];
const orderBy = allowedSort.includes(req.query.sort) ? req.query.sort : 'created_at';
```

### XSS (Cross-Site Scripting)
```markdown
- [ ] Output encoding in HTML context
- [ ] React: no dangerouslySetInnerHTML with user data
- [ ] CSP header configured (no unsafe-inline/eval)
- [ ] URL validation (block javascript: protocol)
- [ ] Cookie flags: HttpOnly, Secure, SameSite
- [ ] Rich text sanitized with DOMPurify (strict allowlist)
```

### Authorization
```markdown
- [ ] Authorization checked on every API endpoint
- [ ] Server-side checks (not just UI hiding)
- [ ] Resource ownership verified (IDOR prevention)
- [ ] Horizontal privilege escalation prevented
- [ ] Vertical privilege escalation prevented
- [ ] Admin endpoints properly protected
- [ ] File access restricted to authorized users
```

```typescript
// ❌ VULNERABLE: No ownership check (IDOR)
app.get('/api/orders/:id', async (req, res) => {
  const order = await db.order.findUnique({ where: { id: req.params.id } });
  res.json(order);  // Any user can access any order!
});

// ✅ SECURE: Ownership verification
app.get('/api/orders/:id', authenticate, async (req, res) => {
  const order = await db.order.findFirst({
    where: { id: req.params.id, userId: req.user.id },  // Scope to user
  });
  if (!order) return res.status(404).json({ error: 'Not found' });
  res.json(order);
});
```

### Secrets Management
```markdown
- [ ] No hardcoded secrets in source code
- [ ] .env files in .gitignore
- [ ] Secrets loaded from environment variables
- [ ] API keys not logged or exposed in errors
- [ ] Secrets not passed in URLs (query parameters)
- [ ] Log redaction for sensitive fields
```

### Error Handling
```markdown
- [ ] Generic error messages to users (no stack traces)
- [ ] Detailed errors logged server-side only
- [ ] No sensitive data in error responses
- [ ] Global error handler catches all unexpected errors
- [ ] Async errors properly caught (try/catch, error middleware)
```

```typescript
// ❌ VULNERABLE: Stack trace exposed
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.message, stack: err.stack });
});

// ✅ SECURE: Generic response, detailed logging
app.use((err, req, res, next) => {
  logger.error({ err, requestId: req.id, url: req.url });
  res.status(500).json({ error: 'Internal server error', requestId: req.id });
});
```

### File Operations
```markdown
- [ ] File uploads validated (MIME type, extension, size)
- [ ] Files stored outside web root
- [ ] Filenames sanitized (no path traversal)
- [ ] No execution of uploaded files
- [ ] Virus scanning for uploads (if applicable)
- [ ] Path traversal prevention (no ../ in paths)
```

---

## Review Process

```markdown
# Security Code Review Steps

## 1. Preparation
- Understand the application architecture
- Identify sensitive data flows
- Review authentication and authorization model
- Check dependency versions for known CVEs

## 2. Automated Scanning
- Run Semgrep: `semgrep --config p/security-audit .`
- Run npm audit: `npm audit --production`
- Run Gitleaks: `gitleaks detect --source .`
- Run ESLint security: `eslint --plugin security src/`

## 3. Manual Review
- Authentication flows (login, register, reset)
- Authorization checks on all endpoints
- Input validation on all user-controlled data
- Database queries for injection patterns
- File handling for upload/download
- Error handling for information leakage
- Secrets management (.env, hardcoded values)
- Logging for sensitive data exposure

## 4. Reporting
- Classify by severity (Critical/High/Medium/Low)
- Include CWE references for each finding
- Provide specific remediation code examples
- Prioritize by risk and exploitability
```

---

## Severity Classification

| Severity | Criteria | Response Time |
|----------|----------|---------------|
| **🔴 Critical** | RCE, SQLi, authentication bypass, data breach | Fix immediately |
| **🟠 High** | Stored XSS, IDOR, privilege escalation, SSRF | Fix within 24h |
| **🟡 Medium** | Reflected XSS, missing headers, weak crypto | Fix within sprint |
| **🔵 Low** | Info disclosure, verbose errors, missing rate limit | Fix in backlog |
| **ℹ️ Info** | Best practice, code quality, defense in depth | Improve over time |

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Checklist-driven** | Systematic review covering all OWASP categories |
| **Both automated + manual** | SAST finds patterns, humans find logic flaws |
| **Code examples** | Show vulnerable AND secure versions in findings |
| **CWE references** | Map findings to CWE for standard classification |
| **Severity + priority** | Distinguish severity (impact) from priority (urgency) |
| **Defense in depth** | Multiple security layers, not single point of failure |
| **Shift left** | Review early in development, not just before release |
| **Knowledge sharing** | Document patterns so team learns from findings |
| **Track findings** | Use issue tracker, verify remediation |
| **Regular cadence** | Review happens for every PR + periodic deep review |

---

## Rules Integration
- **Checklist**: Auth, input validation, SQLi, XSS, authorization, secrets, errors, files
- **Process**: Preparation → Automated scanning → Manual review → Reporting
- **Severity**: Critical/High/Medium/Low with response time SLAs
- **Code examples**: Vulnerable and secure patterns for each category
- **Tools**: Semgrep, npm audit, Gitleaks, ESLint security plugin
