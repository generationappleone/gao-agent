---
description: Create a comprehensive implementation plan with flow diagrams, database changes, code structure, dependency analysis, priority ordering, and detailed justifications — saved as a persistent reference document.
---

# Context Plan — Implementation Planning & Documentation

## Purpose
This workflow creates a **complete, detailed, and well-structured implementation plan** based on the user's requirements. The plan serves as a **blueprint** that guides the entire development process, ensuring nothing is missed and every decision is justified.

The plan is **saved to disk** as a persistent reference document at `.agent/plans/`.

---

## Activation
The user triggers this workflow by:
- Using `/context-plan` followed by what they want to build/change
- Describing a feature, change, or improvement they want planned

---

## Phase 1: Requirement Gathering

### Step 1.1 — Read Project Context
// turbo
Before creating any plan, MUST read the project context:

```
1. .agent/context/CONTEXT_INDEX.md    ← Understand the project
2. .agent/context/ARCHITECTURE.md     ← Understand current architecture
3. .agent/context/DATABASE_SCHEMA.md  ← Understand current database
4. .agent/context/API_REFERENCE.md    ← Understand current API surface
5. .agent/context/DEPENDENCIES.md     ← Understand current dependencies
6. .agent/context/BUSINESS_DOMAINS.md ← Understand business domains
```

If context files don't exist, inform the user:
```
⚠️ Project context belum di-generate.
Saya sarankan jalankan /context-init terlebih dahulu agar plan lebih akurat.
Saya akan analisis langsung dari source code.
```

### Step 1.2 — Analyze the User's Request

Break down the request into:

1. **What** — Apa yang diminta? (feature, fix, refactor, migration, dll)
2. **Why** — Kenapa ini diperlukan? (business value, technical debt, dll)
3. **Scope** — Seberapa luas perubahannya? (1 file, 1 module, multi-service)
4. **Impact** — Apa yang terpengaruh? (database, API, UI, infrastructure)
5. **Constraints** — Batasan apa yang ada? (deadline, backward compatibility, dll)

### Step 1.3 — Ask Clarifying Questions (MANDATORY)

**ALWAYS ask clarifying questions** if any of the following is unclear:

```markdown
❓ Klarifikasi Dibutuhkan

Untuk membuat plan yang akurat, saya perlu informasi tambahan:

1. [Pertanyaan spesifik tentang fungsionalitas]
2. [Pertanyaan tentang skala/scope]
3. [Pertanyaan tentang batasan/deadline]
4. [Pertanyaan tentang integrasi dengan sistem lain]
5. [Pertanyaan tentang target user/environment]

Informasi ini akan membantu saya membuat plan yang lebih presisi.
```

**Mandatory questions to consider asking:**
- Apakah ada deadline atau timeline?
- Apakah harus backward compatible?
- Apakah ada external services/APIs yang terlibat?
- Siapa target user dari fitur ini?
- Apakah ada referensi/mockup/wireframe?
- Apakah fitur ini perlu real-time?
- Bagaimana handling untuk edge cases?
- Environment apa? (development, staging, production)

**Rules:**
- Maximum 5 clarifying questions per plan
- Questions must be specific to the plan being created
- Always provide option to skip: "Atau saya bisa buat plan berdasarkan asumsi terlebih dahulu"
- If user provides enough information (90%+ confidence), proceed with minor assumptions noted

### Step 1.4 — Research (If Needed)

If the plan involves:
- Technologies the agent isn't confident about → Search the web
- Integration with 3rd party services → Read official docs
- New patterns not in existing skills → Research best practices

Follow the research protocol from `/context-ask` Phase 3.

---

## Phase 1.5: Skill Gap Analysis

### Step 1.5.1 — Identify Required Technologies

Based on the user's request and existing project context, list ALL technologies involved:

```markdown
### Technologies Required for This Plan

| Technology | Category | Skill Exists? | Path |
|-----------|----------|--------------|------|
| Laravel | Framework | ✅ Yes | skills/laravel/ |
| Redis | Cache | ✅ Yes | skills/redis/ |
| Pusher | WebSocket | ❌ No | — |
| Stripe | Payment | ❌ No | — |
```

### Step 1.5.2 — Check Skill Availability
// turbo

```bash
# List all available skills
ls .agent/skills/
```

For each technology identified, check if a matching skill exists in `.agent/skills/`.

### Step 1.5.3 — Handle Missing Skills

If ANY required skill is missing, inform the user:

```markdown
⚠️ Skill Gap Detected

Plan ini memerlukan teknologi yang belum memiliki skill file:

| # | Technology | Needed For | Status |
|---|-----------|-----------|--------|
| 1 | **Pusher** | Real-time notifications | ❌ Missing |
| 2 | **Stripe** | Payment processing | ❌ Missing |

Tanpa skill file, agent AI tidak memiliki panduan best practice yang terstruktur
untuk teknologi tersebut. Ini bisa menyebabkan implementasi yang kurang optimal.

**Pilihan:**

1. 📝 **Anda tambahkan skill** — Buat file `.agent/skills/[name]/SKILL.md` secara manual
2. 🤖 **Saya buatkan skill** — Saya akan riset dari sumber kredibel dan generate skill file yang komprehensif
3. ⏭️ **Lanjut tanpa skill** — Saya akan tetap membuat plan tapi tanpa panduan terstruktur (tidak disarankan)
4. 🤖📦 **Buatkan semua sekaligus** — Saya buatkan semua skill yang missing sebelum lanjut ke plan

Pilih opsi mana?
```

### Step 1.5.4 — Auto-Generate Missing Skills (If User Chooses Option 2 or 4)

When the agent creates a skill, it MUST:

#### A. Research Phase
1. **Search official documentation** — Always the primary source
2. **Search credible tech blogs** — web.dev, engineering blogs, official tutorials
3. **Cross-reference multiple sources** — Never rely on a single source
4. **Verify information is current** — Check that it applies to the latest stable version

#### B. Skill Creation Rules
The generated skill MUST:
1. Follow the **exact same format** as existing skills (YAML frontmatter + markdown)
2. Include installation/setup instructions
3. Include common patterns with code examples
4. Include best practices and anti-patterns
5. Include integration notes with existing rules:
   - `developer-security.md` — Security practices for this technology
   - `solid-principles.md` — How SOLID applies to this technology
   - `database-design.md` — If the technology involves data storage
   - `dependency-management.md` — Recommended packages/libraries
   - `iso-27000-compliance.md` — Compliance considerations
   - `ui-ux-design.md` — If the technology involves UI

#### C. Quality Verification
Before saving, verify the skill:
- [ ] Has proper YAML frontmatter (name, description)
- [ ] Covers installation/setup
- [ ] Has working code examples (not pseudo-code)
- [ ] Follows project rules
- [ ] Is based on official/credible sources
- [ ] Covers security considerations
- [ ] Includes version information

#### D. Save & Report
```markdown
✅ Skill Created: [Technology]

📁 Saved at: `.agent/skills/[technology]/SKILL.md`
📖 Sources used:
  - [Official Docs](URL)
  - [Credible Source](URL)

📋 Covers:
  - Installation & setup
  - [N] code patterns
  - Security considerations
  - Integration with project rules

Please review the skill file before I proceed with the plan.
Would you like me to modify anything?
```

### Step 1.5.5 — Proceed After Skills Ready

Only continue to Phase 2 (Impact Analysis) when:
- ALL required skills are available (existing or newly created)
- OR user explicitly chose to proceed without missing skills

---

## Phase 2: Impact Analysis

### Step 2.1 — Identify Affected Components
// turbo
Trace through the codebase to identify ALL affected areas:

```bash
# Search for related code
grep -rn "<relevant_keywords>" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" --include="*.go" --include="*.java" -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -50
```

Document:
```markdown
### Components Affected

| Component | File(s) | Type of Change | Risk Level |
|-----------|---------|---------------|------------|
| UserService | src/services/UserService.ts | Modified | Medium |
| users table | migrations/xxx_add_phone.ts | New migration | Low |
| UserController | src/controllers/UserController.ts | Modified | Medium |
| UserDTO | src/dto/UserDTO.ts | Modified | Low |
| user.test.ts | tests/user.test.ts | Modified | Low |
```

### Step 2.2 — Analyze Database Impact

If database changes are needed:

1. **Read current schema** from `DATABASE_SCHEMA.md` or migration files
2. **Identify:**
   - New tables needed
   - Columns to add/modify/remove
   - New indexes needed
   - Foreign key changes
   - Data migration required?
   - Backward compatibility (can old code still work during migration?)

### Step 2.3 — Analyze API Impact

If API changes are needed:

1. **Read current routes** from `API_REFERENCE.md`
2. **Identify:**
   - New endpoints needed
   - Existing endpoints modified
   - Breaking changes? (versioning needed?)
   - New request/response schemas
   - Authentication changes

### Step 2.4 — Analyze Dependency Impact

If new dependencies are needed, for EACH dependency:

```markdown
#### Dependency: [package-name]

| Criteria | Value | Status |
|----------|-------|--------|
| **Version** | x.y.z | Latest stable |
| **Weekly Downloads** | 500K+ | ✅ Popular |
| **Last Updated** | 2 weeks ago | ✅ Active |
| **License** | MIT | ✅ Compatible |
| **Bundle Size** | 15KB gzipped | ✅ Acceptable |
| **Known Vulnerabilities** | 0 | ✅ Safe |
| **Conflicts with existing?** | No | ✅ Compatible |
| **Alternatives considered** | [alt1, alt2] | [why this one was chosen] |

**Why this dependency:**
[Detailed justification — why this package, this version, and not alternatives]

**Conflict Analysis:**
[Check against existing package.json/composer.json for:
- Version conflicts
- Peer dependency issues
- Duplicate functionality
- Size impact]
```

// turbo
```bash
# Check for existing similar packages
cat package.json | grep -i "<similar_keyword>" 2>/dev/null
# Or for PHP
cat composer.json | grep -i "<similar_keyword>" 2>/dev/null
```

---

## Phase 3: Create the Plan Document

### Step 3.1 — Generate Plan File

Create the plan file at:
```
.agent/plans/PLAN-[YYYY-MM-DD]-[slug].md
```

Example: `.agent/plans/PLAN-2026-02-19-user-notification-system.md`

### Step 3.2 — Plan Document Structure

The plan document MUST follow this EXACT structure:

```markdown
# Implementation Plan: [Title]

> **Created:** [date & time]
> **Status:** Draft | In Review | Approved | In Progress | Completed
> **Requested by:** User
> **Estimated Effort:** [X hours/days]
> **Risk Level:** Low | Medium | High | Critical

---

## 1. Executive Summary

[2-3 paragraphs explaining WHAT will be built, WHY it's needed,
and HOW it will be implemented at a high level]

---

## 2. Application Flow Diagram

[Text-based flow diagram showing the complete flow]

### 2.1 User Flow
```
User Action → Frontend → API Request → Middleware → Controller
                                                       │
                                              Service Layer
                                                       │
                                              Repository Layer
                                                       │
                                                   Database
                                                       │
                                              Response ← ← ←
```

### 2.2 System Flow
```
[Component A] ──── request ────► [Component B]
      │                               │
      │                          [Component C]
      │                               │
      └──── response ◄──────────── result
```

### 2.3 Sequence Diagram
```
User        Frontend      API          Service       Database
 │             │            │              │             │
 │──── click ─►│            │              │             │
 │             │── POST ───►│              │             │
 │             │            │── validate ─►│             │
 │             │            │              │── query ───►│
 │             │            │              │◄── data ────│
 │             │            │◄── result ───│             │
 │             │◄── 200 ────│              │             │
 │◄── render ──│            │              │             │
```

---

## 3. Database Changes

### 3.1 Entity Relationship Diagram
```
[existing_table] (1) ──── (N) [new_table]
       │                         │
       │                    (N) [another_table]
       │
  [other_existing] (N) ──── (M) [junction_table]
```

### 3.2 New Tables

#### Table: [table_name]
| Column | Type | Nullable | Default | Index | Description |
|--------|------|----------|---------|-------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| ... | ... | ... | ... | ... | ... |
| created_at | TIMESTAMP | No | NOW() | — | Audit |
| updated_at | TIMESTAMP | No | NOW() | — | Audit |
| deleted_at | TIMESTAMP | Yes | NULL | IDX | Soft delete |

### 3.3 Modified Tables
| Table | Change | Column | Details | Reason |
|-------|--------|--------|---------|--------|
| users | ADD | phone | VARCHAR(20), nullable | [why] |

### 3.4 Migration Scripts
[List migration files to be created, in order]

---

## 4. Application Structure Changes

### 4.1 New Files
```
src/
├── services/
│   └── NotificationService.ts    ← NEW: Handle notification logic
├── controllers/
│   └── NotificationController.ts ← NEW: API endpoints for notifications
├── models/
│   └── Notification.ts           ← NEW: Data model
├── repositories/
│   └── NotificationRepository.ts ← NEW: Database queries
├── dto/
│   ├── CreateNotificationDTO.ts  ← NEW: Input validation
│   └── NotificationResponseDTO.ts← NEW: Response shape
├── routes/
│   └── notification.routes.ts    ← NEW: Route definitions
└── tests/
    └── notification.test.ts      ← NEW: Test suite
```

### 4.2 Modified Files
| File | Changes | Reason |
|------|---------|--------|
| `src/routes/index.ts` | Add notification routes import | Register new endpoints |
| `src/middleware/auth.ts` | Add new permission check | Authorization for notifications |

### 4.3 Deleted Files
| File | Reason |
|------|--------|
| [none or list] | [justification] |

---

## 5. Code Changes Detail

### 5.1 [Component Name]

**File:** `path/to/file.ts`
**Action:** New / Modified / Deleted
**Reason:** [Why this change is needed]

```typescript
// Code example showing the implementation
```

**Explanation:**
[Detailed explanation of WHY the code is written this way,
not just WHAT it does]

[Repeat 5.1 for each significant code change]

---

## 6. API Changes

### 6.1 New Endpoints
| Method | Path | Auth | Request Body | Response | Description |
|--------|------|------|-------------|----------|-------------|
| POST | /api/v1/notifications | Bearer | CreateNotificationDTO | Notification | Create notification |
| GET | /api/v1/notifications | Bearer | — | Notification[] | List user notifications |

### 6.2 Modified Endpoints
| Method | Path | Change | Reason |
|--------|------|--------|--------|
| [list] | [path] | [what changed] | [why] |

### 6.3 Request/Response Examples
[Provide example payloads for each new/modified endpoint]

---

## 7. Dependency Changes

### 7.1 New Dependencies
[For each dependency, include the full analysis from Phase 2, Step 2.4]

### 7.2 Updated Dependencies
| Package | Current | Target | Reason | Breaking Changes? |
|---------|---------|--------|--------|-------------------|
| [pkg] | v1.2.0 | v1.3.0 | [why] | No |

### 7.3 Removed Dependencies
| Package | Reason |
|---------|--------|
| [pkg] | [why removed] |

### 7.4 Vulnerability Check
| Package | Severity | CVE | Status |
|---------|----------|-----|--------|
| [all clean] | — | — | ✅ No vulnerabilities |

---

## 8. Task List & Priority

### 🔴 URGENT (Do First — Blocks Everything)
| # | Task | Est. Time | Depends On | Reason |
|---|------|-----------|------------|--------|
| 1 | [task] | 2h | — | [Why URGENT: blocks other tasks / critical path] |

### 🟠 HIGH (Do Second — Core Functionality)
| # | Task | Est. Time | Depends On | Reason |
|---|------|-----------|------------|--------|
| 2 | [task] | 4h | Task #1 | [Why HIGH: core feature / essential for MVP] |

### 🟡 MEDIUM (Do Third — Important but Not Blocking)
| # | Task | Est. Time | Depends On | Reason |
|---|------|-----------|------------|--------|
| 3 | [task] | 3h | Task #2 | [Why MEDIUM: enhances feature / not blocking] |

### 🟢 LOW (Do Last — Nice to Have)
| # | Task | Est. Time | Depends On | Reason |
|---|------|-----------|------------|--------|
| 4 | [task] | 2h | Task #3 | [Why LOW: polish / optimization / non-essential] |

### Priority Justification

**Why this ordering:**
1. **URGENT tasks** are on the critical path — other tasks cannot start without them.
   Example: Database migrations must run before services can query new tables.

2. **HIGH tasks** implement the core business logic — without them the feature
   doesn't function at all, but they don't block other parallel work.

3. **MEDIUM tasks** add important supporting functionality — API validation,
   error handling, logging. The feature works without them but isn't production-ready.

4. **LOW tasks** are quality improvements — tests, documentation updates,
   performance optimization. Should be done but can be deferred if needed.

### Execution Timeline
```
Day 1: [URGENT tasks] ████████████░░░░░░░░
Day 2: [HIGH tasks]   ░░░░████████████░░░░
Day 3: [MEDIUM tasks] ░░░░░░░░████████████
Day 4: [LOW tasks]    ░░░░░░░░░░░░████████
        Testing:      ░░░░░░░░░░░░░░░░████
```

---

## 9. Testing Strategy

### 9.1 Testing Scope Based on Plan

Determine which test types are needed based on what this plan implements:

| Test Type | Needed? | Justification | Tools |
|-----------|---------|---------------|-------|
| Unit Testing | ✅ Always | Core functionality | Vitest/Jest/PHPUnit/pytest |
| Integration Testing | ✅ Always | Component interaction | Supertest/Pest |
| API Testing | 🔶 If API changes | Endpoint correctness | Newman, curl, Supertest |
| Security SAST | ✅ Always | Code vulnerability scan | ESLint Security, Snyk, Bandit, PHPStan |
| Security DAST | 🔶 If web-facing | Runtime vulnerability scan | OWASP ZAP, Nikto, SQLMap, FFuf |
| Load Testing | 🔶 If performance-critical | Performance regression | Artillery, k6, Autocannon, JMeter, ab |
| E2E Browser | 🔶 If UI changes | User flow verification | Playwright, Cypress |
| Cross-Browser | 🔶 If public-facing UI | Browser compatibility | BrowserStack, Sauce Labs |
| Accessibility | 🔶 If UI changes | WCAG 2.1 AA compliance | pa11y, axe-core, Lighthouse CI |
| Container | 🔶 If Docker changes | Image vulnerability | Trivy, Docker Scout |
| Code Quality | 🔶 Recommended | Technical debt | SonarQube, SonarCloud |
| Network | 🔶 If infra changes | Port/SSL exposure | nmap |
| Monitoring | 🔶 If production | Uptime verification | Datadog Synthetic |
| Alerting | 🔶 If production | Failure notification | PagerDuty |

### 9.2 Required Testing Tools — 3 Categories

#### 🟢 Kategori 1: Auto-Install (Agent installs via npm/pip/composer)
| Tool | Purpose | Status | Install | Skill |
|------|---------|--------|---------|-------|
| Playwright | E2E/browser testing | ✅/❌ | `npm i -D @playwright/test` | `.agent/skills/playwright/` |
| Cypress | E2E/component testing | ✅/❌ | `npm i -D cypress` | `.agent/skills/cypress/` |
| Artillery | Load testing | ✅/❌ | `npm i -D artillery` | `.agent/skills/load-testing/` |
| Autocannon | HTTP benchmarking | ✅/❌ | `npm i -D autocannon` | `.agent/skills/load-testing/` |
| k6 | Scriptable load testing | ✅/❌ | Binary install | `.agent/skills/load-testing/` |
| Newman | Postman collection CLI | ✅/❌ | `npm i -D newman` | `.agent/skills/newman-postman/` |
| pa11y | Accessibility audits | ✅/❌ | `npm i -D pa11y` | `.agent/skills/accessibility-testing/` |
| axe-core | In-browser a11y | ✅/❌ | `npm i -D @axe-core/playwright` | `.agent/skills/accessibility-testing/` |
| Lighthouse CI | Web vitals + a11y | ✅/❌ | `npm i -D @lhci/cli` | `.agent/skills/accessibility-testing/` |
| ESLint Security | Static security | ✅/❌ | `npm i -D eslint-plugin-security` | `.agent/skills/eslint-security/` |
| Snyk | Dep vulnerability | ✅/❌ | `npm i -D snyk` | `.agent/skills/snyk/` |
| Bandit | Python SAST | ✅/❌ | `pip install bandit` | `.agent/skills/python-security-testing/` |
| Safety | Python dep scanning | ✅/❌ | `pip install safety` | `.agent/skills/python-security-testing/` |
| PHPStan | PHP static analysis | ✅/❌ | `composer require --dev phpstan/phpstan` | `.agent/skills/phpstan-larastan/` |
| Pest | PHP testing | ✅/❌ | `composer require --dev pestphp/pest` | `.agent/skills/phpstan-larastan/` |

#### 🟡 Kategori 2: CLI Tools (User installs manually, agent runs via CLI)
| Tool | Purpose | Status | Install Info | Skill |
|------|---------|--------|-------------|-------|
| OWASP ZAP | DAST scanning | ✅/❌ | Docker / installer | `.agent/skills/owasp-zap/` |
| Nikto | Web server scanner | ✅/❌ | Perl / Docker | `.agent/skills/nikto/` |
| nmap | Network scanning | ✅/❌ | System install | `.agent/skills/nmap/` |
| SQLMap | SQL injection test | ✅/❌ | `pip install sqlmap` | `.agent/skills/sqlmap/` |
| FFuf | Web fuzzing | ✅/❌ | Go binary | `.agent/skills/ffuf/` |
| Trivy | Container scan | ✅/❌ | Binary / Docker | `.agent/skills/trivy/` |
| Docker Scout | Image scan | ✅/❌ | Docker Desktop | `.agent/skills/trivy/` |
| SonarQube | Code quality | ✅/❌ | Docker + scanner | `.agent/skills/sonarqube/` |
| JMeter | Enterprise load test | ✅/❌ | Java / Docker | `.agent/skills/load-testing/` |
| Apache Bench | HTTP benchmark | ✅/❌ | System install | `.agent/skills/load-testing/` |
| Burp Suite | Security testing | ✅/❌ | GUI installer | `.agent/skills/burp-suite/` |
| Checkmarx | Enterprise SAST | ✅/❌ | License required | `.agent/skills/checkmarx/` |

#### 🔴 Kategori 3: SaaS / Cloud (User provides API key)
| Tool | Purpose | Status | Requirement | Skill |
|------|---------|--------|------------|-------|
| Snyk Cloud | Continuous monitoring | ✅/❌ | `SNYK_TOKEN` | `.agent/skills/snyk/` |
| SonarCloud | Cloud code quality | ✅/❌ | `SONAR_TOKEN` | `.agent/skills/sonarqube/` |
| BrowserStack | Cross-browser | ✅/❌ | Username + key | `.agent/skills/cross-browser-testing/` |
| Sauce Labs | Cross-device | ✅/❌ | Username + key | `.agent/skills/cross-browser-testing/` |
| Datadog | Synthetic tests | ✅/❌ | `DD_API_KEY` | `.agent/skills/datadog/` |
| PagerDuty | Alert on failures | ✅/❌ | Routing key | `.agent/skills/pagerduty/` |

⚠️ For Kategori 2 & 3 missing tools, inform the user:
```
Tools berikut perlu disediakan/di-install manual:
🟡 Manual Install: [Tool] — [Purpose] — [Install guide]
🔴 API Key Needed: [Tool] — Set [ENV_VAR] in .env
```

If testing skills are missing, follow the skill gap protocol from Phase 1.5.

### 9.3 Unit Tests
| Test | File | Covers |
|------|------|--------|
| [test name] | tests/unit/... | [what it tests] |

### 9.4 Integration Tests
| Test | File | Covers |
|------|------|--------|
| [test name] | tests/integration/... | [what it tests] |

### 9.5 API / Endpoint Tests
| Method | Path | Test | Expected |
|--------|------|------|----------|
| [GET/POST] | [/api/...] | [test description] | [expected status + response] |

### 9.6 Security Tests
| Test | Category | Tool | Covers |
|------|----------|------|--------|
| OWASP Top 10 check | SAST + Manual | Code review + ESLint | All OWASP categories |
| Auth/Authz tests | Auth | Supertest/curl | Token, role, IDOR |
| Input validation | Injection | SQLMap, code review | SQL injection, XSS, boundary |
| Dependency scan | Supply chain | npm audit, Snyk | Known vulnerabilities |
| DAST scan | Runtime | OWASP ZAP | Active vulnerability probing |
| Container scan | Infrastructure | Trivy | Image vulnerabilities |

### 9.7 Performance Tests
| Test | Tool | Target | Threshold |
|------|------|--------|----------|
| API response time | Artillery/k6 | [endpoint] | p95 < 500ms |
| Load capacity | Artillery/k6 | [endpoint] | > 100 RPS |
| Error rate under load | Artillery/k6 | [endpoint] | < 1% |

### 9.8 E2E / Browser Tests
| Test | Tool | Covers |
|------|------|--------|
| [user flow] | Playwright/Cypress | [what it verifies] |

### 9.9 Accessibility Tests (WCAG 2.1 AA)
| Criteria | Tool | Check |
|----------|------|-------|
| Color contrast | axe-core/pa11y | ≥ 4.5:1 normal, ≥ 3:1 large |
| Keyboard navigation | Playwright | All elements focusable |
| Screen reader | Manual/axe | Content readable |

### 9.10 Edge Cases to Test
| Scenario | Expected Behavior |
|----------|-------------------|
| [edge case 1] | [expected result] |
| [edge case 2] | [expected result] |

### 9.11 Test Execution
After implementation (`/context-work`), run `/context-test` to execute all tests
and generate a versioned test report. The test workflow will:
1. Auto-detect which tools are available
2. Install missing Kategori 1 tools (with user approval)
3. Request user setup for Kategori 2 & 3 tools
4. Run all applicable tests per scope
5. Generate report at `.agent/test-reports/TEST-REPORT-[date]-[scope].md`

---

## 10. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Database migration fails | Low | High | Test on staging first, backup before migration |
| API breaking change | Medium | High | Version the API (v1 → v2) |
| Performance regression | Low | Medium | Load test before deployment |
| [additional risks] | ... | ... | ... |

---

## 11. Rollback Plan

If issues are found after deployment:
1. [Step 1: immediate action]
2. [Step 2: rollback procedure]
3. [Step 3: verification]

---

## 12. Notes & Assumptions

### Assumptions Made
- [Assumption 1 — cannot be verified until user confirms]
- [Assumption 2]

### Open Questions
- [Question that still needs answering]

### References
- 📖 [Source](URL) — [What was referenced]
```

---

## Phase 4: Review & Refinement

### Step 4.1 — Present the Plan

After creating the plan, present a summary to the user:

```markdown
## 📋 Plan Created: [Title]

📁 **Saved at:** `.agent/plans/PLAN-[date]-[slug].md`

### Quick Summary
- **Tasks:** [N] total ([X] urgent, [Y] high, [Z] medium, [W] low)
- **Estimated Effort:** [X hours/days]
- **Database Changes:** [N] new tables, [M] modifications
- **API Changes:** [N] new endpoints, [M] modifications
- **New Dependencies:** [N] packages
- **New Files:** [N] files
- **Modified Files:** [N] files
- **Risk Level:** [Low/Medium/High]

### 🚀 Next Steps
1. ✅ Review the full plan at `.agent/plans/PLAN-[date]-[slug].md`
2. ❓ Ask me anything about the plan using /context-ask
3. ✏️ Request modifications to the plan
4. ▶️ Approve and start implementation

Would you like me to:
- **Modify** any part of the plan?
- **Add more detail** to a specific section?
- **Start implementing** from the first URGENT task?
```

### Step 4.2 — Handle User Feedback

The user can:

1. **Ask questions about the plan** → Switch to `/context-ask` mode
   - Answer in detail using the plan document as context
   - Update the plan based on the discussion

2. **Request modifications** → Update the plan document
   - Edit the saved plan file
   - Note changes with `[REVISED: date]` markers

3. **Approve the plan** → Mark status as "Approved"
   - Update the plan header: `Status: Approved`
   - Begin implementation from URGENT tasks

4. **Reject / Start over** → Archive and create new plan
   - Move to `.agent/plans/archive/`
   - Create new plan with revised requirements

### Step 4.3 — Plan Versioning

If the plan is modified after creation:

```markdown
> **Version History:**
> - v1.0 (2026-02-19) — Initial plan created
> - v1.1 (2026-02-19) — Added WebSocket requirement per user feedback
> - v2.0 (2026-02-20) — Major revision: changed from REST to GraphQL
```

---

## Phase 5: Post-Plan Actions

### Step 5.1 — Update Context (If Needed)

If the plan reveals information not in the context docs, update:
- `ARCHITECTURE.md` — if new patterns or components are planned
- `BUSINESS_DOMAINS.md` — if new business domains are introduced

### Step 5.2 — Create Implementation Checklist

Generate a quick-reference checklist:

```markdown
## Implementation Checklist

- [ ] 🔴 Task 1: [description]
- [ ] 🔴 Task 2: [description]
- [ ] 🟠 Task 3: [description]
- [ ] 🟠 Task 4: [description]
- [ ] 🟡 Task 5: [description]
- [ ] 🟢 Task 6: [description]
- [ ] 🧪 Run all tests
- [ ] 📝 Update documentation
- [ ] 🔍 Code review
- [ ] 🚀 Deploy
```

### Step 5.3 — Integration with Other Workflows

After plan is approved:
- Use `/context-ask` to discuss specific implementation details
- Use `/context-init` if plan reveals context documentation is outdated
- Reference the plan file in commit messages and PRs

---

## Quality Gates

A plan is NOT complete until it has ALL of the following:

- [ ] Executive summary with clear WHAT, WHY, HOW
- [ ] At least 1 flow diagram (application flow or sequence)
- [ ] Database diagram + table definitions (if DB changes)
- [ ] Complete file structure changes (new + modified)
- [ ] Code examples for all non-trivial changes
- [ ] Dependency analysis with vulnerability check (if new deps)
- [ ] Task list with 4-level priority (URGENT/HIGH/MEDIUM/LOW)
- [ ] Priority justification for EVERY task
- [ ] Risk assessment with mitigation strategies
- [ ] Testing strategy with edge cases
- [ ] Rollback plan
- [ ] Saved to `.agent/plans/` directory
