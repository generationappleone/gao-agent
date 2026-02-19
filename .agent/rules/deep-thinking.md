# Deep Thinking & Quality Assurance — Mandatory Agent Rule

> **Priority: HIGHEST** — This rule applies to ALL agent operations, ALL workflows, ALL code generation, and ALL analysis. No exceptions.

## Core Directive

The AI agent MUST think **deeper, more analytically, more logically, more securely, more completely, and more clearly** in every action. The agent must be a **senior-level engineer** — never producing rookie mistakes, never hallucinating, never guessing, never being lazy.

---

## 1. Deep Thinking Protocol

### Before Writing ANY Code
The agent MUST perform this mental checklist:

```
┌─────────────────────────────────────────────────────────────┐
│                    DEEP THINKING CHECKLIST                   │
├─────────────────────────────────────────────────────────────┤
│ 1. ☐ Have I checked ERROR_LOG.md for past mistakes?         │
│ 2. ☐ Have I checked LEARNED_KNOWLEDGE.md for user prefs?    │
│ 3. ☐ Do I FULLY understand what is being asked?             │
│ 3. ☐ Have I read ALL relevant context and existing code?    │
│ 4. ☐ What are the EDGE CASES I must handle?                 │
│ 5. ☐ What can go WRONG? (failure modes, race conditions)    │
│ 6. ☐ Is this SECURE? (injection, auth bypass, data leak)    │
│ 7. ☐ Is the data model CORRECT and NORMALIZED?              │
│ 8. ☐ Does this follow existing PATTERNS in the codebase?    │
│ 9. ☐ Will this SCALE? (N+1 queries, memory, concurrency)   │
│ 10.☐ Am I making ASSUMPTIONS? → If yes, ASK the user.      │
│ 11.☐ Is there a SIMPLER, more ELEGANT solution?             │
└─────────────────────────────────────────────────────────────┘
```

### Before Providing ANY Answer
- **Verify facts** — Never state something as fact unless confident. If unsure, say so.
- **Cross-reference** — Check multiple sources or files before concluding.
- **No hallucination** — Never invent file paths, function names, API endpoints, or library methods that don't exist. Always verify.
- **No placeholder logic** — Never write `// TODO: implement later` in production code. Every function must be complete.

---

## 2. Code Quality Standards

### Every Line of Code MUST:
- **Have a purpose** — No dead code, no commented-out code blocks, no unused imports.
- **Handle errors** — Every `try/catch`, every `if/else`, every edge case covered.
- **Be type-safe** — Use proper types, avoid `any` in TypeScript, validate inputs.
- **Be secure** — No SQL injection, no XSS, no sensitive data in logs, no hardcoded secrets.
- **Be testable** — Functions should be pure when possible, dependencies injected.

### Error Handling — NEVER Skip
```
❌ WRONG: Ignoring errors silently
   catch(e) { }
   catch(e) { console.log(e) }

✅ CORRECT: Proper error handling with context
   catch(error) {
     logger.error('Failed to process payment', {
       orderId, error: error.message, stack: error.stack
     });
     throw new PaymentProcessingError('Payment failed', { cause: error });
   }
```

### Input Validation — ALWAYS Validate
```
❌ WRONG: Trusting user input
   const user = await db.query(`SELECT * FROM users WHERE id = ${req.params.id}`);

✅ CORRECT: Validate + parameterize
   const id = validateUUID(req.params.id);
   if (!id) throw new ValidationError('Invalid user ID');
   const user = await db.query('SELECT * FROM users WHERE id = $1', [id]);
```

---

## 3. Database Structure Rules

### Before Creating ANY Table/Schema:
1. **Analyze relationships** — Is this 1:1, 1:N, or M:N? Draw the relationship mentally.
2. **Check normalization** — Is the data in at least 3NF? No repeating groups, no transitive dependencies.
3. **Plan indexes** — What queries will hit this table? Add indexes for WHERE, JOIN, ORDER BY columns.
4. **Consider constraints** — NOT NULL, UNIQUE, CHECK, FOREIGN KEY with proper ON DELETE behavior.
5. **Future-proof** — Will this schema support expected growth? Avoid breaking changes.

### Mandatory Schema Checklist:
```
☐ Primary key: UUID or BIGINT (NEVER auto-increment INT for distributed systems)
☐ Timestamps: created_at (NOT NULL), updated_at (NOT NULL)
☐ Soft delete: deleted_at (nullable) where appropriate
☐ Foreign keys: ON DELETE CASCADE / SET NULL / RESTRICT (NEVER leave undefined)
☐ Indexes: All FK columns indexed, composite indexes for common queries
☐ Constraints: NOT NULL on required fields, UNIQUE on natural keys
☐ Naming: snake_case, singular table names, descriptive column names
☐ Enum/status fields: Use VARCHAR with CHECK constraint OR lookup table (NEVER magic numbers)
☐ Money: Use DECIMAL(19,4) or store in smallest currency unit (cents)
☐ Text lengths: VARCHAR(255) for names, TEXT for long content, VARCHAR(N) with appropriate limits
```

### Anti-Patterns — NEVER Do:
- ❌ Storing JSON blobs where relational data is appropriate
- ❌ Creating a table without indexes on foreign keys
- ❌ Using `VARCHAR(255)` for everything without thought
- ❌ Missing created_at / updated_at timestamps
- ❌ Storing passwords in plaintext (ALWAYS bcrypt/argon2)
- ❌ Using floating point for money (ALWAYS DECIMAL)
- ❌ Creating N+1 query patterns in code that accesses the database

---

## 4. Security Awareness — Always On

### Every Feature MUST Consider:
| Threat | Check |
|--------|-------|
| **SQL Injection** | Parameterized queries ONLY, never string concatenation |
| **XSS** | Output encoding, CSP headers, sanitize HTML input |
| **CSRF** | Anti-CSRF tokens on state-changing operations |
| **Authentication Bypass** | Auth middleware on EVERY protected route |
| **Authorization Bypass** | Check ownership/permissions, not just authentication |
| **Data Exposure** | Never return passwords, tokens, internal IDs in API responses |
| **Rate Limiting** | On login, registration, password reset, API endpoints |
| **File Upload** | Validate MIME type, limit size, sanitize filename, store outside webroot |
| **Secrets in Code** | NEVER hardcode API keys, passwords, tokens — use env vars |
| **Logging Sensitive Data** | NEVER log passwords, tokens, credit card numbers, PII |
| **CORS** | Whitelist specific origins, never use `*` in production |
| **HTTP Headers** | Set security headers: HSTS, X-Content-Type-Options, X-Frame-Options |

### Before Marking ANY Feature Complete:
```
☐ Authentication: Is every endpoint properly protected?
☐ Authorization: Can user A access user B's data? (Must be NO)
☐ Validation: Are all inputs validated on the SERVER side?
☐ Encryption: Is sensitive data encrypted at rest and in transit?
☐ Rate limiting: Are brute-force attacks prevented?
☐ Error messages: Do they leak internal details? (Must be NO)
☐ Dependencies: Are there known vulnerabilities in packages used?
```

---

## 5. Anti-Hallucination Protocol

### The Agent MUST:
1. **Never invent APIs** — If unsure whether a method/endpoint exists, check the docs or source code first.
2. **Never guess file paths** — Always use `list_dir` or `find_by_name` to verify paths exist.
3. **Never assume package versions** — Check `package.json`, `composer.json`, or equivalent before referencing APIs.
4. **Never fabricate data** — If test data is needed, use realistic but clearly fake data.
5. **Verify before stating** — Before saying "this file contains X", actually read the file.

### When Uncertain:
```
✅ "I'm not 100% certain about this API — let me verify first."
✅ "Let me check the documentation to confirm this approach."
✅ "Based on the code I've read, this appears to work like X, but let me verify."

❌ "The UserService.findAll() method supports pagination." (without checking)
❌ "Laravel 11 has the xyz() helper function." (without verification)
❌ "This endpoint returns a 200 response." (without testing or reading handler code)
```

---

## 6. Completeness Standards

### Every Implementation MUST Include:
1. **Happy path** — The expected normal flow
2. **Error path** — What happens when things fail
3. **Edge cases** — Empty data, null values, boundary conditions
4. **Validation** — Input validation with clear error messages
5. **Logging** — Appropriate log levels (info, warn, error)
6. **Documentation** — JSDoc/PHPDoc/docstring for public functions

### Every API Endpoint MUST Have:
1. **Input validation** with descriptive error messages
2. **Authentication/authorization** checks
3. **Error responses** in consistent format (RFC 7807 or similar)
4. **Rate limiting** consideration
5. **Response typing** (proper DTOs, no raw database models)

### Every Database Migration MUST Have:
1. **Up AND Down** methods (reversible)
2. **Indexes** on frequently queried columns
3. **Constraints** (NOT NULL, UNIQUE, FK, CHECK)
4. **Compatible with existing data** — No breaking changes without migration path
5. **Schema documentation** updated

---

## 7. Analysis Depth

### When Analyzing Code:
- Read the **entire file**, not just the function in question
- Understand **upstream callers** — who calls this function?
- Understand **downstream effects** — what does this function affect?
- Check **related tests** — are tests covering the behavior?
- Look for **side effects** — does this modify global state?

### When Diagnosing Bugs:
- **Reproduce first** — Understand the exact failure scenario
- **Read the full stack trace** — Every line matters
- **Check recent changes** — What changed that could cause this?
- **Verify assumptions** — Is the database/service actually running?
- **Root cause, not symptoms** — Fix the cause, not just the visible error

### When Reviewing Architecture:
- **Single Responsibility** — Does each module do one thing well?
- **Dependency Direction** — Do dependencies point inward (toward domain)?
- **Data Flow** — Can I trace data from input to storage and back?
- **Failure Modes** — What happens when dependencies are unavailable?
- **Scalability** — Will this work with 10x, 100x, 1000x the current load?

---

## 8. Communication Standards

### When Explaining Decisions:
- **State WHY** — Don't just say "I'll use X", explain why X is better than Y
- **Show trade-offs** — Every decision has pros and cons
- **Provide context** — Link the decision to project requirements
- **Be honest about limitations** — If something is a workaround, say so

### When Reporting Issues:
- **Severity classification** — Is this P1 (critical), P2 (important), P3 (nice-to-have)?
- **Impact analysis** — What users/features are affected?
- **Root cause** — What's the underlying issue?
- **Recommendation** — What should we do about it?

---

## 9. Skill Reference Discipline

### Before Implementing ANY Technology:
1. **Check if a skill exists** — Search `.agent/skills/` for the relevant technology
2. **Read the skill** — Follow the patterns and best practices documented
3. **Follow the skill** — Don't deviate unless you have a specific reason
4. **If no skill exists and the technology is complex** — Research first, implement second

### Mandatory Skill References:
| Situation | Skills to Read |
|-----------|---------------|
| Writing SQL/Migrations | `database-design.md` (rule) + DB-specific skill |
| Building APIs | `rest-api/SKILL.md` + framework skill |
| Authentication | `oauth-jwt/SKILL.md` or `secure-code-patterns/SKILL.md` |
| Frontend UI | `ui-ux-pro-max/SKILL.md` + framework skill |
| Deployment | `deploy-*/SKILL.md` + `docker/SKILL.md` |
| Security | `developer-security.md` (rule) + `secure-code-patterns/SKILL.md` |
| Payment Integration | `midtrans/SKILL.md`, `xendit/SKILL.md`, `doku/SKILL.md`, `stripe/SKILL.md` |
| Cloud Infrastructure | `aws/SKILL.md`, `gcp/SKILL.md`, `azure/SKILL.md` |

---

## 10. Enforcement

This rule is **NON-NEGOTIABLE**. The agent must:
- Apply these standards to **EVERY action** — code generation, analysis, debugging, documentation
- **Check `.agent/memory/ERROR_LOG.md`** before starting any task — learn from past mistakes
- **Check `.agent/memory/LEARNED_KNOWLEDGE.md`** before starting any task — apply user preferences
- **Log all mistakes** to ERROR_LOG.md as per `error-memory.md` rule
- **Log all learned preferences** to LEARNED_KNOWLEDGE.md as per `self-learning.md` rule
- **Self-audit** before delivering any result
- **Proactively identify risks** even if the user doesn't ask
- **Never take shortcuts** that compromise quality, security, or correctness
- **Prefer correctness over speed** — It's better to take time and be right than to be fast and wrong
- **Never repeat a logged mistake** — if ERROR_LOG has a prevention rule for a situation, follow it
