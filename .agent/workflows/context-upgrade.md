---
description: "Safely audit and upgrade dependencies — compatibility checks, breaking change analysis, version conflicts, and automated testing. Replaces /context-compatibility."
---

# Context Upgrade — Compatibility Audit + Safe Dependency Upgrade (Unified)

## Purpose
This workflow provides a **complete dependency lifecycle** — from **auditing compatibility** (read-only) to **safely executing upgrades** with breaking change analysis and automated verification.

> **Replaces:** `/context-compatibility` — compatibility audits are now Phase 1 of this workflow.
> Phase 1 is **strictly read-only** — it never modifies files without explicit approval.

---

## Activation
The user triggers this workflow by:
- Using `/context-upgrade` for full audit + upgrade
- Using `/context-upgrade --audit-only` to run only the compatibility audit (read-only)
- Using `/context-compatibility` (alias — routes here, runs `--audit-only`)
- Using `/context-upgrade --security-only` to fix only vulnerability patches
- Using `/context-upgrade [package-name]` to upgrade a specific package

---

## Phase 1: Compatibility Audit (Read-Only)

> **This phase is ALWAYS run first.** It is strictly read-only — reports findings but never modifies files.

### Step 1.1 — Load Skills & Rules
// turbo
1. Read `skills/compatibility-check/SKILL.md` — Audit mode process
2. Read project context: `DEPENDENCIES.md`, `DEVELOPMENT_GUIDE.md`
3. Read `.agent/rules/deep-thinking.md` — Deep analysis standards (MANDATORY)
4. Read `.agent/rules/dependency-management.md` — Package vetting rules (MANDATORY)

### Step 1.2 — Scan Dependency Files
// turbo

Read ALL package manifests found in the project:

```bash
# Find all manifest files
find . -maxdepth 3 \( \
  -name "package.json" -o \
  -name "package-lock.json" -o \
  -name "pnpm-lock.yaml" -o \
  -name "yarn.lock" -o \
  -name "requirements.txt" -o \
  -name "pyproject.toml" -o \
  -name "Pipfile" -o \
  -name "Pipfile.lock" -o \
  -name "go.mod" -o \
  -name "go.sum" -o \
  -name "composer.json" -o \
  -name "composer.lock" -o \
  -name "Cargo.toml" -o \
  -name "Cargo.lock" -o \
  -name "Gemfile" -o \
  -name "Gemfile.lock" -o \
  -name "*.csproj" \
\) -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' 2>/dev/null
```

### Step 1.3 — Detect Runtime Versions
// turbo

```bash
# Check version pinning files
cat .node-version .nvmrc .python-version .ruby-version .java-version .tool-versions 2>/dev/null

# Check engines field
cat package.json 2>/dev/null | grep -A 5 '"engines"'

# Check Dockerfiles for base images
grep "^FROM" Dockerfile docker/Dockerfile 2>/dev/null

# Check runtime configs
cat .editorconfig 2>/dev/null | head -20
```

### Step 1.4 — Build Dependency Map
// turbo

For each manifest file, extract ALL dependencies with versions:

```bash
# Node.js
npm outdated 2>&1 | head -40
npm ls --depth=0 2>&1 | head -40

# PHP
composer outdated --direct 2>&1 | head -30
composer show --direct 2>&1 | head -30

# Python
pip list --outdated 2>&1 | head -30

# Go
go list -m -u all 2>&1 | head -30
```

### Step 1.5 — Cross-Reference & Conflict Detection

Analyze for:
- **Peer dependency conflicts** — Package A requires X@^2.0, Package B requires X@^3.0
- **Deprecated packages** — Packages with no maintenance for 12+ months
- **EOL runtimes** — Node.js 16, Python 3.7, PHP 7.4, etc.
- **Framework ↔ runtime mismatches** — React 19 with Node 14, Laravel 11 with PHP 8.0
- **Duplicate functionality** — Two packages doing the same thing
- **License conflicts** — GPL in MIT project, etc.

### Step 1.6 — Web Search for Known Issues
// turbo

For each flagged combination, search for:
- Known incompatibilities and breaking changes
- End-of-life and deprecation notices
- Security advisories (CVEs)
- Recommended version combinations from official docs

### Step 1.7 — Generate Compatibility Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 COMPATIBILITY AUDIT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Date:     [YYYY-MM-DD HH:mm]
Project:  [project name]
Stack:    [detected stack]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Runtime Versions
| Runtime | Current | Latest Stable | LTS? | EOL Date | Status |
|---------|---------|--------------|------|----------|--------|
| Node.js | 20.11.0 | 22.x | Yes (20) | Apr 2026 | ✅ OK |
| PHP | 8.2.15 | 8.3.x | Yes | Dec 2025 | 🟡 Update recommended |

## 🔴 Critical Issues (Will break)
| # | Issue | Packages | Impact | Fix |
|---|-------|----------|--------|-----|
| 1 | Peer conflict | react@19 + react-router@5 | Build fails | Upgrade react-router to v7 |

## 🟡 Warnings (Risky)
| # | Issue | Package | Risk | Recommendation |
|---|-------|---------|------|---------------|
| 1 | Deprecated | moment.js@2.29 | No security patches | Migrate to dayjs or date-fns |
| 2 | Approaching EOL | Node.js 18 | EOL Apr 2025 | Upgrade to Node.js 20 LTS |

## 🟢 Informational
| # | Info | Package | Current | Latest | Notes |
|---|------|---------|---------|--------|-------|
| 1 | Minor update | axios | 1.6.0 | 1.7.2 | Non-breaking, recommended |

## Dependency Health Score: [X]/10
- Freshness: [X]/10 (how up-to-date)
- Security: [X]/10 (known vulnerabilities)
- Maintenance: [X]/10 (actively maintained)
- License: [X]/10 (all compatible)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1.8 — Ask for Upgrade Approval

```markdown
⛔ STOP — Audit Complete (Read-Only Phase Done)

Would you like me to proceed with upgrades?
1. ✅ **Upgrade all** — Apply all recommended changes
2. 🎯 **Upgrade selected** — Choose which items to upgrade (by number)
3. 🔒 **Security patches only** — Only fix vulnerabilities
4. 📋 **Save report only** — No changes, just save the audit report
5. ❌ **No changes** — Done for now

Select option:
```

**If `--audit-only` was specified, STOP HERE.**

---

## Phase 2: Upgrade Planning

> **This phase only runs if the user approves upgrades from Phase 1.**

### Step 2.1 — Categorize Upgrades

```markdown
## Upgrade Plan

### ✅ Safe Upgrades (patch/minor — low risk)
| # | Package | Current | Target | Type | Risk | Breaking? |
|---|---------|---------|--------|------|------|-----------|
| 1 | axios | 1.6.0 | 1.7.2 | Minor | Low | No |
| 2 | lodash | 4.17.20 | 4.17.21 | Patch | Low | No |

### ⚠️ Risky Upgrades (major — requires code changes)
| # | Package | Current | Target | Type | Risk | Breaking Changes |
|---|---------|---------|--------|------|------|-----------------|
| 3 | react | 18.2 | 19.0 | Major | High | New API, removed deprecated |
| 4 | react-router | 5.3 | 7.0 | Major | High | Complete API rewrite |

### 🔒 Security Fixes (recommended immediately)
| # | Package | Current | Target | CVE | Severity | Fix |
|---|---------|---------|--------|-----|----------|-----|
| 5 | lodash | 4.17.20 | 4.17.21 | CVE-2021-23337 | High | Patch |
```

### Step 2.2 — Research Breaking Changes (For Major Upgrades)

For each major upgrade:
1. Search official migration guide (web search)
2. Read changelog/release notes
3. Identify code patterns that need updating
4. Estimate effort for migration

```markdown
### Breaking Change Analysis: [package] v[old] → v[new]

**Migration Guide:** [URL]

| # | Breaking Change | Affected Files | Migration Effort |
|---|----------------|---------------|-----------------|
| 1 | [API removed] | src/utils/... | 30 min |
| 2 | [Default changed] | config/... | 15 min |

**Total migration effort:** [X hours]
```

### Step 2.3 — Final Approval

```markdown
⛔ Ready to execute upgrades:

| # | Package | Change | Risk |
|---|---------|--------|------|
| 1 | axios | 1.6.0 → 1.7.2 | ✅ Safe |
| 2 | react | 18.2 → 19.0 | ⚠️ Major |

Proceed? (all / safe-only / specific numbers / cancel)
```

---

## Phase 3: Upgrade Execution

### Step 3.1 — Create Backup Point
// turbo
```bash
# Create a git branch/stash before upgrades
git stash push -m "pre-upgrade-backup-$(date +%Y%m%d-%H%M)" 2>&1
# Or create a branch
git checkout -b chore/dependency-upgrade-$(date +%Y%m%d) 2>&1
```

### Step 3.2 — Execute Safe Upgrades (Batch)
// turbo

Apply all safe (patch/minor) upgrades at once:
```bash
# Node.js
npm update 2>&1 | tail -20

# PHP
composer update --with-dependencies 2>&1 | tail -20

# Python
pip install --upgrade -r requirements.txt 2>&1 | tail -20
```

### Step 3.3 — Verify After Safe Upgrades
// turbo
```bash
# Build check
npm run build 2>&1 | tail -30

# Test check
npm test 2>&1 | tail -30

# Lint check
npm run lint 2>&1 | tail -20
```

If any fail → investigate and fix or revert specific package.

### Step 3.4 — Execute Risky Upgrades (One at a Time)

For each major upgrade:
1. Apply the upgrade
2. Apply migration changes (code updates)
3. Build
4. Run tests
5. If build/tests fail → investigate and fix or revert
6. Commit the upgrade separately

```bash
# Example: Upgrade one package
npm install react@19 react-dom@19 2>&1 | tail -10

# Build check
npm run build 2>&1 | tail -30

# Test check
npm test 2>&1 | tail -30
```

### Step 3.5 — Handle Breaking Changes

For major upgrades that require code changes:
1. Search for deprecated API usage in codebase
2. Apply migration guide changes
3. Update code to use new APIs
4. Verify tests pass after each change

```bash
# Find deprecated patterns
grep -rn "<deprecated_pattern>" --include="*.ts" --include="*.js" -not -path '*/node_modules/*' | head -20
```

---

## Phase 4: Verification & Report

### Step 4.1 — Final Verification
// turbo
```bash
# Full build
npm run build 2>&1 | tail -30

# Full test suite
npm test 2>&1 | tail -30

# Security audit
npm audit --production 2>&1 | tail -20

# Application smoke test
npm run dev &
sleep 5
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "FAIL"
kill %1 2>/dev/null
```

### Step 4.2 — Update Documentation

Update `.agent/context/DEPENDENCIES.md` with new versions.

### Step 4.3 — Upgrade Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ UPGRADE COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Upgraded:    [N] packages
Skipped:     [N] packages
Reverted:    [N] packages (breaking)
Security:    [N] vulnerabilities fixed
Build:       ✅ Passing
Tests:       ✅ All passing ([N] total)
Audit:       ✅ Clean

Upgrade Details:
| Package | Before | After | Type |
|---------|--------|-------|------|
| axios | 1.6.0 | 1.7.2 | Minor ✅ |
| lodash | 4.17.20 | 4.17.21 | Patch 🔒 |

Next Steps:
🔍 /context-review — Review the upgrade changes
🚀 /context-deploy — Deploy updated application
📝 /context-git    — Commit upgrade changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## When to Use
- Before deployment (patch security vulnerabilities)
- Monthly maintenance (keep dependencies current)
- Major framework upgrades (React, Laravel, etc.)
- After cloning a new project (pairs with `/context-init`)
- Periodic health checks on long-running projects
- When encountering unexplained build or test failures
- When onboarding to an unfamiliar codebase

## When to Skip
- Brand new project with no dependencies yet
- Single-file scripts or trivial projects
- In the middle of a feature sprint (finish first)
- User explicitly says "don't update dependencies"
- You just ran this workflow and nothing changed
