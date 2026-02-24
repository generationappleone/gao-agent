---
description: Run comprehensive testing across features, data flow, reliability, security, and functions — generate detailed test documentation with version tracking and external tool integration.
---

# Context Test — Comprehensive Testing & Documentation

## Purpose
This workflow performs **complete, thorough testing** of the application covering features, data flow, reliability, security, and functions. It generates **detailed test documentation** with version tracking, timestamps, and justification for every test. The agent can leverage **external testing tools** (browser testing, API testing, security scanners, etc.) to ensure maximum coverage.

---

## Activation
The user triggers this workflow by:
- Using `/context-test` to run all tests
- Using `/context-test [scope]` to test a specific area (e.g., `/context-test security`, `/context-test api`)
- Using `/context-test [plan-file]` to test against a specific plan's requirements

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 0.5: Agent Lock Check (Race Condition Prevention)
// turbo
1. Check if `.agent/context/AGENT_LOCK` exists.
2. If it exists, STOP! Another agent is currently executing. Inform the user and abort.
3. If it does not exist, immediately create `.agent/context/AGENT_LOCK` with the current timestamp.
4. IMPORTANT: Meticulously delete `.agent/context/AGENT_LOCK` at the very end of this workflow OR whenever you pause to ask the user a question.

## Phase 1: Test Preparation

### Step 1.1 — Read Project Context
// turbo
Load project understanding:

```
1. .agent/context/CONTEXT_INDEX.md       ← Project overview
2. .agent/context/ARCHITECTURE.md        ← System architecture
3. .agent/context/DATABASE_SCHEMA.md     ← Database structure
4. .agent/context/API_REFERENCE.md       ← API endpoints
5. .agent/context/DEPENDENCIES.md        ← Installed packages
6. .agent/context/BUSINESS_DOMAINS.md    ← Business rules
7. .agent/rules/deep-thinking.md         ← Deep analysis standards (MANDATORY)
```

### Step 1.1b — Load Testing Skills
// turbo
Read relevant testing skills based on detected framework:
- `skills/unit-testing/SKILL.md` — Unit testing patterns (AAA, mocking, fixtures)
- `skills/playwright/SKILL.md` or `skills/cypress/SKILL.md` — E2E testing (if frontend)
- `skills/security-audit/SKILL.md` — Security testing patterns
- `skills/load-testing/SKILL.md` — Performance testing (if applicable)
- `skills/accessibility-testing/SKILL.md` — A11y testing (if frontend)

### Step 1.2 — Load Related Plan (If Applicable)

If testing is triggered after `/context-work`:
```bash
# Find the most recent plan
find .agent/plans -name "PLAN-*.md" -not -path '*/archive/*' | sort -r | head -1
```

Read the plan to understand:
- What was implemented
- Expected behavior
- Edge cases documented
- Business rules to verify

### Step 1.3 — Identify Testing Scope

Determine what needs to be tested:

```markdown
### Test Scope Assessment

| Area | Applicable? | Reason |
|------|------------|--------|
| Feature/Functional | ✅ Yes | Core functionality must work |
| Data Flow | ✅ Yes | Data integrity across layers |
| API/Endpoint | ✅ Yes | All endpoints respond correctly |
| Database | ✅ Yes | Queries, migrations, constraints |
| Security | ✅ Yes | Vulnerabilities, auth, input validation |
| Performance | 🔶 Conditional | If performance-critical changes |
| UI/UX | 🔶 Conditional | If frontend changes exist |
| Reliability | ✅ Yes | Error handling, edge cases |
| Integration | 🔶 Conditional | If multiple services involved |
| Accessibility | 🔶 Conditional | If UI changes (WCAG AA) |
```

### Step 1.4 — Detect Required Testing Tools

Check what testing tools are available and what's needed:

#### A. Check Existing Test Infrastructure
// turbo
```bash
# Node.js / TypeScript
cat package.json 2>/dev/null | grep -E "jest|vitest|mocha|cypress|playwright|supertest|artillery" | head -20

# PHP / Laravel
cat composer.json 2>/dev/null | grep -E "phpunit|pest|dusk|phpstan|larastan" | head -20

# Python
cat requirements.txt 2>/dev/null | grep -E "pytest|unittest|locust|bandit|safety" | head -10
cat pyproject.toml 2>/dev/null | grep -E "pytest|unittest|locust|bandit" | head -10

# Go
grep -r "testing" go.mod 2>/dev/null | head -5

# Check for test config files
find . -maxdepth 2 \( -name "jest.config*" -o -name "vitest.config*" -o -name "cypress.config*" -o -name "playwright.config*" -o -name "phpunit.xml" -o -name "pytest.ini" -o -name ".eslintrc*" \) -not -path '*/node_modules/*' 2>/dev/null
```

#### B. Identify Missing Tools — 3 Categories

```markdown
### Testing Tools Assessment

#### 🟢 Category 1: Auto-Install (npm/pip/composer)
Tools that can be installed and run directly by the agent:

| Tool | Purpose | Status | Install Command | Skill |
|------|---------|--------|----------------|-------|
| Playwright | E2E/browser testing | ✅/❌ | `npm i -D @playwright/test` | playwright |
| Cypress | E2E/component testing | ✅/❌ | `npm i -D cypress` | cypress |
| Artillery | Load/performance testing | ✅/❌ | `npm i -D artillery` | load-testing |
| Autocannon | HTTP benchmarking | ✅/❌ | `npm i -D autocannon` | load-testing |
| k6 | Scriptable load testing | ✅/❌ | `choco install k6` / binary | load-testing |
| Newman | Postman collection CLI | ✅/❌ | `npm i -D newman` | newman-postman |
| pa11y | Accessibility audits | ✅/❌ | `npm i -D pa11y pa11y-ci` | accessibility-testing |
| axe-core | In-browser a11y testing | ✅/❌ | `npm i -D @axe-core/playwright` | accessibility-testing |
| Lighthouse CI | Web vitals + a11y audit | ✅/❌ | `npm i -D @lhci/cli` | accessibility-testing |
| ESLint Security | Static security analysis | ✅/❌ | `npm i -D eslint-plugin-security` | eslint-security |
| Snyk | Dependency vulnerability | ✅/❌ | `npm i -D snyk` | snyk |
| Bandit | Python SAST | ✅/❌ | `pip install bandit` | python-security-testing |
| Safety | Python dep scanning | ✅/❌ | `pip install safety` | python-security-testing |
| PHPStan/Larastan | PHP static analysis | ✅/❌ | `composer require --dev phpstan/phpstan` | phpstan-larastan |
| Pest | PHP testing framework | ✅/❌ | `composer require --dev pestphp/pest` | phpstan-larastan |

#### 🟡 Category 2: CLI Tools (Manual Install, Agent Runs)
Tools that need to be installed manually by the user, but can be run by the agent via CLI:

| Tool | Purpose | Status | Install Info | Skill |
|------|---------|--------|-------------|-------|
| OWASP ZAP | DAST security scanning | ✅/❌ | Docker / installer | owasp-zap |
| Nikto | Web server scanner | ✅/❌ | Perl / Docker | nikto |
| nmap | Network/port scanning | ✅/❌ | System install | nmap |
| SQLMap | SQL injection testing | ✅/❌ | `pip install sqlmap` | sqlmap |
| FFuf | Web fuzzing/discovery | ✅/❌ | Go binary / download | ffuf |
| Trivy | Container vulnerability | ✅/❌ | Binary / Docker | trivy |
| Docker Scout | Image vulnerability | ✅/❌ | Docker Desktop plugin | trivy |
| SonarQube Scanner | Code quality + security | ✅/❌ | `npx sonarqube-scanner` | sonarqube |
| JMeter | Enterprise load testing | ✅/❌ | Java app / Docker | load-testing |
| Apache Bench (ab) | HTTP benchmarking | ✅/❌ | `apt install apache2-utils` | load-testing |
| Burp Suite | Security testing (GUI) | ✅/❌ | Desktop installer | burp-suite |
| Checkmarx | Enterprise SAST | ✅/❌ | License required | checkmarx |

#### 🔴 Category 3: SaaS / Cloud (API Key Required)
Cloud-based tools that require an account + API key:

| Tool | Purpose | Status | Requirement | Skill |
|------|---------|--------|------------|-------|
| Snyk Cloud | Continuous dep monitoring | ✅/❌ | API key (free tier) | snyk |
| SonarCloud | Cloud code quality | ✅/❌ | Token + org | sonarqube |
| BrowserStack | Cross-browser testing | ✅/❌ | Account + key | cross-browser-testing |
| Sauce Labs | Cross-browser/device | ✅/❌ | Account + key | cross-browser-testing |
| Datadog Synthetic | Synthetic monitoring | ✅/❌ | API key | datadog |
| PagerDuty | Alert on test failures | ✅/❌ | Routing key | pagerduty |
```

#### C. Handle Missing Tools — Per Category

If required tools are missing:

```markdown
⚠️ Testing Tools Required

### 🟢 Auto-Install (Agent can install directly)
| # | Tool | Purpose | Command |
|---|------|---------|--------|
| 1 | Playwright | E2E testing | `npm i -D @playwright/test && npx playwright install` |
| 2 | Artillery | Load testing | `npm i -D artillery` |
| 3 | pa11y | Accessibility | `npm i -D pa11y` |
| ... | ... | ... | ... |

→ **May I install these now?** (Yes / No / Select specific ones)

### 🟡 Manual Install (User must install, agent runs)
| # | Tool | Purpose | Install Guide |
|---|------|---------|---------------|
| 1 | OWASP ZAP | DAST scanning | `docker pull ghcr.io/zaproxy/zaproxy:stable` |
| 2 | nmap | Port scanning | https://nmap.org/download |
| 3 | Trivy | Container scan | `docker pull aquasec/trivy` |
| ... | ... | ... | ... |

→ **Please install the tools above, then confirm readiness**

### 🔴 Cloud/SaaS (User provides API key)
| # | Tool | Purpose | Setup |
|---|------|---------|-------|
| 1 | Snyk Cloud | Dep monitoring | Set `SNYK_TOKEN` in .env |
| 2 | SonarCloud | Code quality | Set `SONAR_TOKEN` in .env |
| 3 | BrowserStack | Cross-browser | Set `BROWSERSTACK_USERNAME` + `BROWSERSTACK_ACCESS_KEY` |
| ... | ... | ... | ... |

→ **Add API key to .env, then confirm**

**Global Options:**
1. 📦 **Install all Category 1** — I'll install all npm/pip packages
2. 🎯 **Install only what's needed** — I'll only install what's relevant for this test scope
3. ⏭️ **Skip all missing** — Test with existing tools only (reduced coverage)
4. 🔧 **Wait for user setup** — You set up manually first, I'll continue when ready
```

### Step 1.5 — Check Required Skills

Verify testing-related skills exist:
// turbo
```bash
ls .agent/skills/
```

Match detected tools to available skills:
```markdown
### Testing Skills Assessment

| Tool | Skill Required | Skill Path | Status |
|------|---------------|-----------|--------|
| Playwright | playwright | `.agent/skills/playwright/SKILL.md` | ✅ Available |
| Cypress | cypress | `.agent/skills/cypress/SKILL.md` | ✅ Available |
| Artillery/k6/ab | load-testing | `.agent/skills/load-testing/SKILL.md` | ✅ Available |
| Newman | newman-postman | `.agent/skills/newman-postman/SKILL.md` | ✅ Available |
| pa11y/axe/Lighthouse | accessibility-testing | `.agent/skills/accessibility-testing/SKILL.md` | ✅ Available |
| ESLint Security | eslint-security | `.agent/skills/eslint-security/SKILL.md` | ✅ Available |
| Snyk | snyk | `.agent/skills/snyk/SKILL.md` | ✅ Available |
| Bandit/Safety | python-security-testing | `.agent/skills/python-security-testing/SKILL.md` | ✅ Available |
| PHPStan/Pest | phpstan-larastan | `.agent/skills/phpstan-larastan/SKILL.md` | ✅ Available |
| OWASP ZAP | owasp-zap | `.agent/skills/owasp-zap/SKILL.md` | ✅ Available |
| Nikto | nikto | `.agent/skills/nikto/SKILL.md` | ✅ Available |
| nmap | nmap | `.agent/skills/nmap/SKILL.md` | ✅ Available |
| SQLMap | sqlmap | `.agent/skills/sqlmap/SKILL.md` | ✅ Available |
| FFuf | ffuf | `.agent/skills/ffuf/SKILL.md` | ✅ Available |
| Burp Suite | burp-suite | `.agent/skills/burp-suite/SKILL.md` | ✅ Available |
| Trivy/Docker Scout | trivy | `.agent/skills/trivy/SKILL.md` | ✅ Available |
| SonarQube/Cloud | sonarqube | `.agent/skills/sonarqube/SKILL.md` | ✅ Available |
| Checkmarx | checkmarx | `.agent/skills/checkmarx/SKILL.md` | ✅ Available |
| BrowserStack/Sauce Labs | cross-browser-testing | `.agent/skills/cross-browser-testing/SKILL.md` | ✅ Available |
| Datadog | datadog | `.agent/skills/datadog/SKILL.md` | ✅ Available |
| PagerDuty | pagerduty | `.agent/skills/pagerduty/SKILL.md` | ✅ Available |
```

If a skill is missing for a required tool, follow the skill auto-generation protocol from `/context-plan` Phase 1.5.4.

### Step 1.6 — Generate Test Session ID

Create a unique identifier for this test session:
```
Format: TEST-[YYYY-MM-DD]-[HH:mm]-[scope]
Example: TEST-2026-02-19-11:34-full
         TEST-2026-02-19-11:34-security
         TEST-2026-02-19-11:34-api
```

---

## Phase 2: Feature / Functional Testing

### Step 2.1 — Run Existing Test Suite
// turbo

```bash
# Node.js
npm test 2>&1 | tee .agent/test-results/unit-test-output.txt

# PHP / Laravel
php artisan test 2>&1 | tee .agent/test-results/unit-test-output.txt

# Python
pytest -v 2>&1 | tee .agent/test-results/unit-test-output.txt

# Go
go test -v ./... 2>&1 | tee .agent/test-results/unit-test-output.txt

# .NET
dotnet test --verbosity normal 2>&1 | tee .agent/test-results/unit-test-output.txt
```

Record:
- Total tests run
- Passed / Failed / Skipped
- Failed test details (name, error, stack trace)
- Coverage percentage (if available)

### Step 2.2 — Run Coverage Report
// turbo

```bash
# Node.js (Vitest/Jest)
npx vitest run --coverage 2>&1 | tail -50
# or
npx jest --coverage 2>&1 | tail -50

# PHP
php artisan test --coverage 2>&1 | tail -30

# Python
pytest --cov=. --cov-report=term-missing 2>&1 | tail -50

# Go
go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out | tail -30
```

### Step 2.3 — Identify Untested Code

Analyze coverage report to find:
```markdown
### Untested Code Areas

| File | Coverage | Untested Lines | Risk |
|------|----------|---------------|------|
| src/services/PaymentService.ts | 45% | 23-45, 67-89 | 🔴 High |
| src/controllers/OrderController.ts | 72% | 34-40 | 🟡 Medium |
| src/utils/validators.ts | 90% | 15-18 | 🟢 Low |
```

### Step 2.4 — Write Missing Tests (If Gaps Found)

For critical untested code, write new tests:
- Follow existing test patterns
- Cover happy path + error paths
- Include edge cases from the plan

---

## Phase 3: Data Flow Testing

### Step 3.1 — Trace Data Through Layers

For each major feature, trace data flow:

```markdown
### Data Flow: [Feature Name]

1. **Input** → [Where data enters: form, API request, webhook]
   - Validation: [What validation occurs?]
   - Sanitization: [Is input sanitized?]

2. **Controller/Handler** → [How request is processed]
   - Auth check: [Is authentication verified?]
   - Authorization: [Are permissions checked?]

3. **Service Layer** → [Business logic applied]
   - Transformations: [How data is transformed?]
   - Business rules: [What rules are enforced?]

4. **Repository/ORM** → [How data reaches database]
   - Query type: [Select/Insert/Update/Delete]
   - Parameterized: [Yes/No — MUST be Yes]

5. **Database** → [How data is stored]
   - Constraints: [FK, unique, not null honored?]
   - Audit: [created_at/updated_at populated?]

6. **Response** → [How data returns to client]
   - Shape: [Response format correct?]
   - Sensitive data: [Any leakage?]

Status: ✅ PASS / ❌ FAIL / ⚠️ WARNING
```

### Step 3.2 — Test Data Integrity

```bash
# Verify database constraints
# Check for orphaned records, broken foreign keys
# Verify audit columns are populated
# Check soft delete works correctly
```

### Step 3.3 — Test Data Boundaries

| Test | Input | Expected | Actual | Status |
|------|-------|----------|--------|--------|
| Empty string | `""` | Validation error | ? | ? |
| Max length | `"a" * 256` | Validation error | ? | ? |
| SQL injection | `' OR 1=1--` | Escaped/rejected | ? | ? |
| XSS payload | `<script>alert(1)</script>` | Escaped | ? | ? |
| Unicode | `日本語テスト` | Accepted | ? | ? |
| Null bytes | `\x00` | Rejected | ? | ? |
| Negative numbers | `-1` | Depends on field | ? | ? |
| Very large number | `99999999999` | Validation error | ? | ? |

---

## Phase 4: API / Endpoint Testing

### Step 4.1 — Test All API Endpoints

Read `API_REFERENCE.md` and test EVERY endpoint:

```markdown
### API Test Results

| # | Method | Path | Auth | Status | Time | Result |
|---|--------|------|------|--------|------|--------|
| 1 | POST | /api/auth/login | No | 200 | 45ms | ✅ PASS |
| 2 | GET | /api/users/me | Bearer | 200 | 32ms | ✅ PASS |
| 3 | POST | /api/orders | Bearer | 201 | 78ms | ✅ PASS |
| 4 | GET | /api/orders/999 | Bearer | 404 | 12ms | ✅ PASS |
| 5 | DELETE | /api/users/1 | No auth | 401 | 8ms | ✅ PASS |
```

### Step 4.2 — Test Error Responses

| Scenario | Endpoint | Expected Status | Expected Body | Actual | Status |
|----------|----------|----------------|---------------|--------|--------|
| Missing required field | POST /api/users | 400 | Validation error | ? | ? |
| Invalid token | GET /api/users/me | 401 | Unauthorized | ? | ? |
| Wrong role | DELETE /api/admin/x | 403 | Forbidden | ? | ? |
| Non-existent resource | GET /api/users/999 | 404 | Not found | ? | ? |
| Duplicate entry | POST /api/users | 409 | Conflict | ? | ? |

### Step 4.3 — Test API with External Tools (If Available)

```bash
# Using curl for manual endpoint testing
curl -s -w "\nHTTP_CODE:%{http_code} TIME:%{time_total}s\n" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  http://localhost:3000/api/users/me

# Using Playwright/Puppeteer for browser-based API testing
# Using Postman/Newman for collection testing
npx newman run .agent/test-collections/api-tests.json 2>&1 | tail -30
```

---

## Phase 5: Security Testing

### Step 5.1 — Static Analysis (SAST)
// turbo

Run ALL applicable SAST tools. Read the relevant skill BEFORE running:

```bash
# ─── JavaScript/TypeScript (Skill: eslint-security) ───
npx eslint . --ext .ts,.js --format json 2>&1 | head -100

# ESLint Security Plugin (if installed)
npx eslint . --ext .ts,.js,.tsx,.jsx --format json 2>&1 | head -100

# ─── PHP (Skill: phpstan-larastan) ───
# vendor/bin/phpstan analyse --level 8 --error-format=json 2>&1 | head -100

# ─── Python (Skill: python-security-testing) ───
# bandit -r . -ll -f json 2>&1 | head -100

# ─── Dependency Vulnerabilities ───
# Node.js
npm audit --json 2>&1 | head -100

# Snyk (Skill: snyk) — if authenticated
# npx snyk test --json 2>&1 | head -100
# npx snyk code test --json 2>&1 | head -100

# Python
# safety check -r requirements.txt --output json 2>&1 | head -60
# pip audit 2>/dev/null | head -30

# PHP
# composer audit 2>/dev/null | head -30
```

### Step 5.2 — OWASP Top 10 Check

Manually review code against OWASP Top 10:

```markdown
### OWASP Top 10 Assessment

| # | Vulnerability | Check | Status | Details |
|---|--------------|-------|--------|---------|
| A01 | Broken Access Control | Auth on all protected routes? | ? | [details] |
| A02 | Cryptographic Failures | Passwords hashed? Secrets encrypted? | ? | [details] |
| A03 | Injection | Parameterized queries everywhere? | ? | [details] |
| A04 | Insecure Design | Business logic flaws? | ? | [details] |
| A05 | Security Misconfiguration | Default creds? Debug mode? | ? | [details] |
| A06 | Vulnerable Components | Dependencies up to date? | ? | [details] |
| A07 | Auth Failures | Rate limiting? Session management? | ? | [details] |
| A08 | Data Integrity Failures | Input validation? Deserialization? | ? | [details] |
| A09 | Logging Failures | Security events logged? | ? | [details] |
| A10 | SSRF | External URL validation? | ? | [details] |
```

### Step 5.3 — Security Code Review
// turbo

```bash
# Check for hardcoded secrets
grep -rn "password\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.php" --include="*.py" --include="*.env" -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' -not -name "*.example" -not -name "*.test.*" | head -20

# Check for raw SQL (non-parameterized)
grep -rn "query\s*(" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -20

# Check for eval/exec usage
grep -rn "eval\s*(\|exec\s*(\|Function\s*(" --include="*.ts" --include="*.js" -not -path '*/node_modules/*' | head -20

# Check for missing CSRF protection
grep -rn "csrf\|_token\|xsrf" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' -not -path '*/vendor/*' | head -10

# Check for proper security headers
grep -rn "helmet\|X-Frame-Options\|Content-Security-Policy\|Strict-Transport" --include="*.ts" --include="*.js" --include="*.php" -not -path '*/node_modules/*' | head -10
```

### Step 5.4 — Authentication & Authorization Testing

| Test | Description | Expected | Actual | Status |
|------|-------------|----------|--------|--------|
| Access without token | Request protected route | 401 Unauthorized | ? | ? |
| Expired token | Use expired JWT | 401 Unauthorized | ? | ? |
| Wrong role | User accesses admin route | 403 Forbidden | ? | ? |
| IDOR | User A accesses User B data | 403 Forbidden | ? | ? |
| Brute force | 100 rapid login attempts | Rate limited (429) | ? | ? |
| SQL injection in login | `' OR 1=1--` as username | Rejected | ? | ? |
| Password requirements | `123` as password | Validation error | ? | ? |

### Step 5.5 — Dynamic Application Security Testing (DAST)

Run applicable DAST tools. Read the relevant skill BEFORE running each tool.
⚠️ Only run on development/staging — NEVER on production without permission.

#### A. OWASP ZAP (Skill: owasp-zap)
```bash
# Passive baseline scan (fast, safe)
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
  -t http://host.docker.internal:3000 \
  -J zap-baseline.json -r zap-baseline.html 2>&1 | tail -30

# API scan (if OpenAPI/Swagger available)
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py \
  -t http://host.docker.internal:3000/api-docs/swagger.json \
  -f openapi -J zap-api.json 2>&1 | tail -30

# Full active scan (comprehensive, takes longer)
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-full-scan.py \
  -t http://host.docker.internal:3000 \
  -J zap-full.json -m 10 2>&1 | tail -30
```

#### B. Nikto — Web Server Scanner (Skill: nikto)
```bash
nikto -h http://localhost:3000 -o nikto-report.json -Format json 2>&1 | head -50
```

#### C. nmap — Network/Port Scan (Skill: nmap)
```bash
# Quick port scan
nmap -F localhost 2>&1 | head -30

# SSL/TLS cipher check (if HTTPS)
nmap --script ssl-enum-ciphers -p 443 localhost 2>&1 | head -30

# Security headers check
nmap --script http-headers -p 3000 localhost 2>&1 | head -30

# Check for exposed database ports
nmap -p 3306,5432,27017,6379 localhost 2>&1 | head -20
```

#### D. SQLMap — SQL Injection Testing (Skill: sqlmap)
```bash
# Test query parameters for SQL injection (safe, read-only)
sqlmap -u "http://localhost:3000/api/search?q=test" --batch --level 1 --risk 1 2>&1 | tail -30

# Test POST endpoint
sqlmap -u "http://localhost:3000/api/login" \
  --data='{"email":"test","password":"test"}' \
  --headers="Content-Type: application/json" \
  --batch --level 1 --risk 1 2>&1 | tail -30
```

#### E. FFuf — Web Fuzzing (Skill: ffuf)
```bash
# Directory discovery (use common wordlist)
ffuf -w /usr/share/wordlists/common.txt -u http://localhost:3000/FUZZ -fc 404 -mc 200,301,302,403 -o ffuf-results.json -of json 2>&1 | tail -20

# Discover hidden API endpoints
ffuf -w /usr/share/wordlists/api-endpoints.txt -u http://localhost:3000/api/FUZZ -fc 404 -o ffuf-api.json -of json 2>&1 | tail -20
```

#### F. Trivy — Container Scanning (Skill: trivy)
If the application uses Docker:
```bash
# Scan Docker image
trivy image --severity HIGH,CRITICAL --format json -o trivy-report.json myapp:latest 2>&1 | tail -20

# Scan filesystem for vulnerabilities
trivy fs --severity HIGH,CRITICAL . 2>&1 | tail -30

# Scan Dockerfile for misconfigurations
trivy config Dockerfile 2>&1 | tail -20

# Docker Scout (alternative)
docker scout cves myapp:latest 2>&1 | tail -30
```

#### G. SonarQube / SonarCloud (Skill: sonarqube)
```bash
# Run SonarQube scanner
npx sonarqube-scanner \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=$SONAR_TOKEN 2>&1 | tail -30

# Or SonarCloud
npx sonarqube-scanner \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.organization=$SONAR_ORG \
  -Dsonar.token=$SONAR_TOKEN 2>&1 | tail -30
```

#### H. Checkmarx (Skill: checkmarx) — Enterprise Only
```bash
# CxFlow scan (if available)
java -jar cx-flow.jar --scan --cx-project="MyProject" --f="./src" \
  --bug-tracker=Json --output-file=cx-results.json 2>&1 | tail -30
```

### Step 5.6 — Snyk Comprehensive Scan (Skill: snyk)

If Snyk is authenticated:
```bash
# Dependencies
npx snyk test --severity-threshold=high --json 2>&1 | head -100

# Source code (SAST)
npx snyk code test --json 2>&1 | head -100

# Container (if Docker)
npx snyk container test myapp:latest --json 2>&1 | head -100

# IaC (if infrastructure files exist)
npx snyk iac test . --json 2>&1 | head -100

# Monitor (register for continuous scanning)
npx snyk monitor 2>&1
```

---

## Phase 6: Reliability Testing

### Step 6.1 — Error Handling Verification

```markdown
### Error Handling Coverage

| Scenario | Component | Handled? | Recovery? | Logged? | Status |
|----------|----------|----------|-----------|---------|--------|
| DB connection lost | Repository | ? | Retry/graceful fail | ? | ? |
| External API timeout | Service | ? | Fallback/retry | ? | ? |
| Invalid JSON body | Controller | ? | 400 response | ? | ? |
| File not found | FileService | ? | Graceful error | ? | ? |
| Out of memory | Global | ? | Process restart | ? | ? |
| Uncaught exception | Global | ? | 500 + logging | ? | ? |
```

### Step 6.2 — Edge Case Testing

| Test | Input/Condition | Expected Behavior | Status |
|------|----------------|-------------------|--------|
| Concurrent writes | 2 users update same record | Last write wins / conflict error | ? |
| Empty database | No records exist | Graceful empty response | ? |
| Maximum payload | 10MB request body | 413 Payload Too Large | ? |
| Slow network | High latency simulation | Timeout handling | ? |
| Malformed request | Invalid Content-Type | 415 Unsupported Media | ? |
| Double submit | Same request twice quickly | Idempotent / duplicate rejected | ? |

### Step 6.3 — Performance & Load Testing (Skill: load-testing)

Read `.agent/skills/load-testing/SKILL.md` before running. Use the best available tool:

#### A. Artillery (Recommended — npm)
```bash
# Quick benchmark
npx artillery quick --count 100 --num 10 http://localhost:3000/api/health 2>&1 | tail -30

# Full scenario test (if artillery.yml exists)
npx artillery run artillery.yml --output artillery-report.json 2>&1 | tail -30
npx artillery report artillery-report.json --output artillery-report.html
```

#### B. k6 (Advanced scriptable)
```bash
k6 run --vus 50 --duration 30s load-test.js 2>&1 | tail -30
```

#### C. Autocannon (Quick Node.js benchmark)
```bash
npx autocannon -c 50 -d 10 -p 5 http://localhost:3000/api/health 2>&1 | tail -20
```

#### D. Apache Bench (System tool)
```bash
ab -n 1000 -c 50 http://localhost:3000/api/health 2>&1 | tail -30
```

#### E. JMeter (Enterprise — headless)
```bash
jmeter -n -t test-plan.jmx -l results.jtl -e -o report/ 2>&1 | tail -30
```

#### Performance Results
```markdown
### Performance Baseline

| Metric | Value | Threshold | Status |
|--------|-------|----------|--------|
| RPS (requests/sec) | [N] | > 100 | ✅/❌ |
| p50 latency | [N]ms | < 100ms | ✅/❌ |
| p95 latency | [N]ms | < 500ms | ✅/❌ |
| p99 latency | [N]ms | < 1000ms | ✅/❌ |
| Error rate | [N]% | < 1% | ✅/❌ |
| Max concurrent | [N] | Depends | info |
```

---

## Phase 7: UI/UX Testing (If Frontend Exists)

### Step 7.1 — E2E Browser Testing (Skills: playwright, cypress)

Read the relevant skill BEFORE running:

```bash
# ─── Playwright (Skill: playwright) ───
npx playwright test 2>&1 | tail -30
npx playwright test --project=chromium 2>&1 | tail -30
npx playwright test --project=firefox 2>&1 | tail -30
npx playwright test --project=webkit 2>&1 | tail -30
npx playwright show-report    # view HTML report

# ─── Cypress (Skill: cypress) ───
npx cypress run 2>&1 | tail -30
npx cypress run --browser chrome 2>&1 | tail -30
```

### Step 7.2 — Cross-Browser Testing (Skill: cross-browser-testing)

If BrowserStack or Sauce Labs credentials are configured:

```bash
# BrowserStack
npx playwright test --config=playwright.browserstack.config.ts 2>&1 | tail -30

# Sauce Labs
npx playwright test --config=playwright.saucelabs.config.ts 2>&1 | tail -30
```

### Step 7.3 — Responsive Design Testing

Test at standard breakpoints:

| Breakpoint | Width | Layout | Status |
|-----------|-------|--------|--------|
| Mobile S | 320px | Single column | ? |
| Mobile L | 425px | Single column | ? |
| Tablet | 768px | Adjusted layout | ? |
| Laptop | 1024px | Full layout | ? |
| Desktop | 1440px | Full layout | ? |

### Step 7.4 — Accessibility Testing (Skill: accessibility-testing)

Read `.agent/skills/accessibility-testing/SKILL.md` before running.
Target: **WCAG 2.1 AA** compliance.

```bash
# ─── pa11y (Quick CLI audit) ───
npx pa11y http://localhost:3000 2>&1 | tail -30
npx pa11y --standard WCAG2AA http://localhost:3000 2>&1 | tail -30
npx pa11y --reporter json http://localhost:3000 > pa11y-report.json 2>&1

# Multiple pages via pa11y-ci
npx pa11y-ci 2>&1 | tail -30

# ─── axe-core with Playwright ───
npx playwright test --grep accessibility 2>&1 | tail -30

# ─── Lighthouse CI (Full web vitals + a11y) ───
npx lhci autorun 2>&1 | tail -30
# or specific URL
npx lhci collect --url=http://localhost:3000 2>&1 | tail -30
npx lhci assert 2>&1 | tail -30
```

| Criteria | Check | Status |
|----------|-------|--------|
| Color contrast ratio | ≥ 4.5:1 (normal text), ≥ 3:1 (large text) | ? |
| Keyboard navigation | All interactive elements focusable | ? |
| Alt text | All images have alt text | ? |
| ARIA labels | Interactive elements properly labeled | ? |
| Focus indicators | Visible focus rings | ? |
| Screen reader | Content readable via VoiceOver/NVDA | ? |
| Skip navigation | Skip to content link present | ? |
| Language attribute | `lang` on `<html>` element | ? |
| Form labels | All inputs have associated labels | ? |
| Heading hierarchy | Proper h1-h6 structure | ? |

---

## Phase 8: Generate Test Documentation

### Step 8.1 — Create Test Report Directory
// turbo
```bash
mkdir -p .agent/test-reports
```

### Step 8.2 — Generate Test Report

Create test report at:
```
.agent/test-reports/TEST-REPORT-[YYYY-MM-DD]-[HH-mm]-[scope].md
```

The report MUST follow this EXACT structure:

```markdown
# Test Report

> **Test Session ID:** TEST-2026-02-19-11:34-full
> **Version:** v1.0.0
> **Date:** 2026-02-19 11:34 WIB
> **Tester:** AI Agent
> **Environment:** Development (localhost)
> **Triggered By:** [Manual / Post-implementation / Scheduled]
> **Related Plan:** PLAN-2026-02-19-[slug].md (if applicable)
> **Status:** ✅ PASSED / ❌ FAILED / ⚠️ PASSED WITH WARNINGS

---

## Test Justification

### Why This Test Was Conducted
[Detailed explanation of why this test session was triggered:
- After implementing features from plan X
- Routine security audit
- User-requested comprehensive check
- Pre-deployment verification
- Post-incident investigation]

### Scope of Testing
[What was tested and what was NOT tested, with justification]

### Testing Standards Applied
- `.agent/rules/developer-security.md` — Security verification
- `.agent/rules/solid-principles.md` — Code quality standards
- `.agent/rules/database-design.md` — Data integrity checks
- `.agent/rules/iso-27000-compliance.md` — Compliance verification
- `.agent/rules/ui-ux-design.md` — UI/UX standards (if applicable)

---

## Executive Summary

| Category | Pass | Fail | Warning | Coverage |
|----------|------|------|---------|----------|
| Feature/Functional | [N] | [N] | [N] | [X]% |
| Data Flow | [N] | [N] | [N] | — |
| API Endpoints | [N] | [N] | [N] | [X]% |
| Security | [N] | [N] | [N] | — |
| Reliability | [N] | [N] | [N] | — |
| Performance | [N] | [N] | [N] | — |
| UI/UX | [N] | [N] | [N] | — |
| Accessibility | [N] | [N] | [N] | — |
| **TOTAL** | **[N]** | **[N]** | **[N]** | **[X]%** |

### Critical Issues Found
| # | Severity | Category | Description | Recommendation |
|---|----------|----------|-------------|----------------|
| 1 | 🔴 Critical | Security | [description] | [fix recommendation] |
| 2 | 🟠 High | Data Flow | [description] | [fix recommendation] |

### Passed Highlights
- ✅ All API endpoints return correct status codes
- ✅ Authentication and authorization working correctly
- ✅ No SQL injection vulnerabilities found
- ✅ Database constraints enforced properly

---

## Detailed Results

### 1. Feature / Functional Tests
[Full table from Phase 2]

### 2. Data Flow Tests
[Full tables from Phase 3]

### 3. API / Endpoint Tests
[Full table from Phase 4]

### 4. Security Tests
#### 4.1 OWASP Top 10 Assessment
[Full table from Phase 5.2]

#### 4.2 Static Analysis Results
[Results from Phase 5.1]

#### 4.3 Authentication & Authorization
[Full table from Phase 5.4]

#### 4.4 Dependency Vulnerabilities
[Results from npm audit / pip audit]

### 5. Reliability Tests
[Full tables from Phase 6]

### 6. Performance Baseline
[Results from Phase 6.3]

### 7. UI/UX Tests (if applicable)
[Results from Phase 7]

---

## Recommendations

### 🔴 Critical (Fix Immediately)
| # | Issue | Location | Fix | Priority |
|---|-------|----------|-----|----------|
| 1 | [issue] | [file:line] | [recommended fix] | Immediate |

### 🟠 High (Fix Before Deployment)
| # | Issue | Location | Fix | Priority |
|---|-------|----------|-----|----------|
| 2 | [issue] | [file:line] | [recommended fix] | Before deploy |

### 🟡 Medium (Fix Soon)
| # | Issue | Location | Fix | Priority |
|---|-------|----------|-----|----------|
| 3 | [issue] | [file:line] | [recommended fix] | Next sprint |

### 🟢 Low (Improvement Opportunity)
| # | Issue | Location | Fix | Priority |
|---|-------|----------|-----|----------|
| 4 | [issue] | [file:line] | [recommended fix] | Backlog |

---

## Test Tools Used

| Tool | Version | Category | Purpose | Skill | Result |
|------|---------|----------|---------|-------|--------|
| Vitest/Jest | x.x.x | 🟢 Cat.1 | Unit testing | — | ✅ |
| ESLint Security | x.x.x | 🟢 Cat.1 | Static security | eslint-security | ✅ |
| npm audit | built-in | 🟢 Cat.1 | Dep vulnerability | — | ✅ |
| Playwright | x.x.x | 🟢 Cat.1 | E2E browser testing | playwright | ✅/⏭️ |
| Artillery | x.x.x | 🟢 Cat.1 | Load testing | load-testing | ✅/⏭️ |
| pa11y | x.x.x | 🟢 Cat.1 | Accessibility | accessibility-testing | ✅/⏭️ |
| Snyk | x.x.x | 🟢 Cat.1 | Dep+code scanning | snyk | ✅/⏭️ |
| OWASP ZAP | x.x.x | 🟡 Cat.2 | DAST scanning | owasp-zap | ✅/⏭️ |
| Nikto | x.x.x | 🟡 Cat.2 | Web server scan | nikto | ✅/⏭️ |
| nmap | x.x.x | 🟡 Cat.2 | Port/SSL scan | nmap | ✅/⏭️ |
| Trivy | x.x.x | 🟡 Cat.2 | Container scan | trivy | ✅/⏭️ |
| SonarQube | x.x.x | 🟡 Cat.2 | Code quality | sonarqube | ✅/⏭️ |
| BrowserStack | — | 🔴 Cat.3 | Cross-browser | cross-browser-testing | ✅/⏭️ |
| Datadog | — | 🔴 Cat.3 | Synthetic tests | datadog | ✅/⏭️ |

---

## Version History

| Version | Date | Tester | Trigger | Result |
|---------|------|--------|---------|--------|
| v1.0.0 | 2026-02-19 | AI Agent | Post-implementation | ✅ PASSED |

---

## Appendix

### A. Full Test Output Logs
[Reference to .agent/test-results/ files]

### B. Coverage Report
[Summary or reference to coverage report]

### C. Related Documents
- Plan: `.agent/plans/PLAN-2026-02-19-[slug].md`
- Context: `.agent/context/`
- Previous Test Reports: [list]
```

---

## Phase 9: Post-Test Actions

### Step 9.1 — Handle Failures

If critical or high-severity issues are found:

```markdown
🚨 Critical Issues Detected

[N] critical and [M] high-severity issues were found during testing.

**Recommended Actions:**
1. 🔴 Fix critical issues immediately (see Recommendations section)
2. 📋 Create a fix plan using `/context-plan`
3. 🔧 Execute fixes using `/context-work`
4. 🔄 Re-run tests using `/context-test`

Would you like me to:
1. 📋 Create a fix plan for the critical issues?
2. 🔧 Fix the issues directly now?
3. 📝 Just document and move on?
```

### Step 9.2 — Update Context Documentation

If tests reveal information about the project:
- Update `ARCHITECTURE.md` if architectural concerns found
- Update `API_REFERENCE.md` if endpoint behavior differs from documentation
- Update `DATABASE_SCHEMA.md` if schema issues found

### Step 9.3 — Update Plan Status (If Plan-Based Testing)

If testing was triggered from a plan implementation:

```markdown
# In the plan file, update:
> **Testing Status:** ✅ PASSED (TEST-2026-02-19-11:34-full)
> **Test Report:** .agent/test-reports/TEST-REPORT-2026-02-19-11-34-full.md
```

### Step 9.4 — Final Summary

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ TESTING COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session:    TEST-2026-02-19-11:34-full
Duration:   [X minutes]
Result:     ✅ PASSED / ❌ FAILED / ⚠️ PASSED WITH WARNINGS

Summary:
  ✅ Passed:    [N] tests
  ❌ Failed:    [N] tests
  ⚠️ Warnings:  [N] items
  📊 Coverage:  [X]%

Critical:   [N] issues (🔴)
High:       [N] issues (🟠)
Medium:     [N] issues (🟡)
Low:        [N] issues (🟢)

📁 Report: .agent/test-reports/TEST-REPORT-2026-02-19-11-34-full.md
📁 Logs:   .agent/test-results/

🚀 Next Steps:
1. Review the full report
2. Fix critical/high issues
3. Re-run tests after fixes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Test Execution Rules (Non-Negotiable)

1. **NEVER skip security tests** — Always run OWASP Top 10 check
2. **NEVER ignore failing tests** — Every failure must be documented
3. **ALWAYS check data flow** — Verify input → processing → storage → output
4. **ALWAYS test error paths** — Not just happy paths
5. **ALWAYS check auth/authz** — Every protected route must be verified
6. **ALWAYS document results** — Save report to `.agent/test-reports/`
7. **ALWAYS track versions** — Every report must have version and date
8. **ALWAYS reference rules** — Apply security, SOLID, database, and compliance rules
9. **ALWAYS offer remediation** — For every issue found, provide a fix recommendation
10. **ALWAYS re-test after fixes** — Never assume a fix works without verification
