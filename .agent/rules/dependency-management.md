# 📦 Dependency Management — Mandatory Pre-Installation Verification Rule

> **Severity:** CRITICAL  
> **Scope:** All dependencies, packages, libraries, and modules installed or added to any project  
> **Applies to:** All package managers — npm, yarn, pnpm, pip, poetry, go mod, cargo, composer, nuget, maven, gradle, etc.  
> **Objective:** Ensure every dependency is compatible, actively maintained, secure, and necessary before installation

---

## Overview

Before installing or adding **ANY** dependency, the agent **MUST** perform a thorough verification process. The agent **MUST** use credible internet sources to research each dependency and complete all verification steps. **No dependency may be installed without passing this verification.**

---

## 1. 🔍 Mandatory Pre-Installation Research

### 1.1 Research Sources

The agent **MUST** consult the following credible sources before installing any dependency:

| Source | URL Pattern | Purpose |
|--------|------------|---------|
| **npm Registry** | `https://www.npmjs.com/package/{name}` | JS/TS package info, versions, downloads |
| **PyPI** | `https://pypi.org/project/{name}` | Python package info, versions, classifiers |
| **Go Packages** | `https://pkg.go.dev/{module}` | Go module info, documentation |
| **crates.io** | `https://crates.io/crates/{name}` | Rust crate info |
| **NuGet** | `https://www.nuget.org/packages/{name}` | .NET package info |
| **Maven Central** | `https://search.maven.org` | Java/Kotlin package info |
| **GitHub/GitLab** | Repository URL | Source code, issues, PRs, activity |
| **Snyk Vulnerability DB** | `https://snyk.io/vuln/npm:{name}` | Known vulnerabilities |
| **Socket.dev** | `https://socket.dev/npm/package/{name}` | Supply chain risk analysis |
| **Bundlephobia** | `https://bundlephobia.com/package/{name}` | Bundle size analysis (JS) |
| **Libraries.io** | `https://libraries.io/{platform}/{name}` | Cross-platform dependency info |

### 1.2 Information to Gather

For each dependency, the agent **MUST** gather and evaluate the following:

```
┌─────────────────────────────────────────────────────────────┐
│                DEPENDENCY VERIFICATION REPORT               │
├─────────────────────────────────────────────────────────────┤
│ Package Name:        ___________________________________    │
│ Requested Version:   ___________________________________    │
│ Latest Version:      ___________________________________    │
│ License:             ___________________________________    │
│ Repository URL:      ___________________________________    │
│ Last Publish Date:   ___________________________________    │
│ Weekly Downloads:    ___________________________________    │
│ GitHub Stars:        ___________________________________    │
│ Open Issues:         ___________________________________    │
│ Contributors:        ___________________________________    │
│ Bundle Size (JS):    ___________________________________    │
│ Transitive Deps:     ___________________________________    │
│ Known Vulns:         ___________________________________    │
│ Compatibility:       ___________________________________    │
│ Alternatives:        ___________________________________    │
│ Verdict:             ✅ APPROVED / ⚠️ CONDITIONAL / ❌ REJECTED │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. ✅ Compatibility Verification

### 2.1 Runtime & Language Version Compatibility

#### ✅ MUST verify:
- The dependency supports the project's **runtime version** (Node.js, Python, Go, etc.)
- The dependency supports the project's **language version** (TypeScript, ES2022, Python 3.12, etc.)
- The `engines` field (npm) or equivalent specifies compatibility with the current runtime
- The dependency is compatible with the project's **target platform** (browser, server, mobile, edge)

#### 💡 Example: Checking Node.js Version Compatibility

```typescript
// Before installing a package, check its package.json on npm:
// https://www.npmjs.com/package/some-package

// ❌ REJECTED: Package requires Node.js >= 20, but project uses Node.js 18
// Package engines: { "node": ">=20.0.0" }
// Project .nvmrc: 18.19.0
// VERDICT: Incompatible — either upgrade Node.js or find an alternative

// ✅ APPROVED: Package supports the project's Node.js version
// Package engines: { "node": ">=16.0.0" }
// Project .nvmrc: 20.11.0
// VERDICT: Compatible
```

```python
# Before installing a Python package, check its classifiers on PyPI:
# https://pypi.org/project/some-package/

# ❌ REJECTED: Package only supports Python 3.10+, but project uses 3.9
# Classifier: Programming Language :: Python :: 3.10
# Project: python_requires = ">=3.9"
# VERDICT: Incompatible

# ✅ APPROVED: Package supports the project's Python version
# Classifier: Programming Language :: Python :: 3 :: Only
# python_requires: ">=3.8"
# Project: python = "^3.11"
# VERDICT: Compatible
```

### 2.2 Peer Dependency & Existing Dependency Compatibility

#### ✅ MUST verify:
- All **peer dependencies** are satisfied by existing project dependencies
- The new dependency does not create **version conflicts** with existing packages
- The dependency's transitive dependencies do not conflict with the project's dependency tree
- Framework-specific packages match the framework version (e.g., `@angular/core@17` with Angular 17)

#### 💡 Example: Peer Dependency Conflict Detection

```bash
# Step 1: Check peer dependencies before installing
npm info react-router-dom peerDependencies
# Output: { "react": ">=16.8", "react-dom": ">=16.8" }

# Step 2: Verify against project's installed versions
npm ls react
# Output: react@18.2.0

# Step 3: Evaluate
# react-router-dom requires react >= 16.8
# Project has react@18.2.0
# VERDICT: ✅ Compatible
```

```bash
# ❌ CONFLICT EXAMPLE:
# Project uses: next@14.1.0 (requires react@18.x)
# New package requires: react@17.x
# VERDICT: ❌ REJECTED — peer dependency conflict with React version

# Resolution options:
# 1. Find an alternative package compatible with React 18
# 2. Check if a newer version of the package supports React 18
# 3. If no alternative exists, document the conflict and ask the user
```

### 2.3 Cross-Dependency Compatibility Matrix

#### ✅ MUST verify these common compatibility pairs:

| Ecosystem | Verify Compatibility With |
|-----------|--------------------------|
| **React** | react, react-dom, @types/react, next.js, react-router version alignment |
| **Next.js** | next, react, react-dom, TypeScript, ESLint config versions |
| **Vue** | vue, vue-router, pinia/vuex, vite version alignment |
| **Angular** | All @angular/* packages must be the same major version |
| **Python/Django** | django, djangorestframework, database drivers, celery versions |
| **Python/FastAPI** | fastapi, pydantic, uvicorn, starlette version alignment |
| **Go** | Go version in go.mod, indirect dependency compatibility |
| **TypeScript** | typescript version, @types/* packages, bundler compatibility |

#### 💡 Example: Full Compatibility Check for a React Project

```typescript
// Project's current dependencies (package.json):
// {
//   "react": "^18.2.0",
//   "react-dom": "^18.2.0",
//   "next": "^14.1.0",
//   "typescript": "^5.3.0"
// }

// Agent wants to install: @tanstack/react-query@5.x

// Step 1: Check @tanstack/react-query peer dependencies
// npm info @tanstack/react-query peerDependencies
// → { "react": "^18.0.0" }               ✅ Compatible (project has 18.2.0)

// Step 2: Check TypeScript compatibility
// → Requires TypeScript >= 4.7             ✅ Compatible (project has 5.3.0)

// Step 3: Check bundle size impact
// → Bundlephobia: 13.2 kB minified+gzipped ✅ Acceptable

// Step 4: Check framework compatibility
// → Works with Next.js App Router          ✅ Compatible

// Step 5: Check for known issues
// → No open critical bugs                   ✅ Safe

// VERDICT: ✅ APPROVED — Install @tanstack/react-query@^5.17.0
```

---

## 3. 🛡️ Security Vulnerability Assessment

### 3.1 Vulnerability Check Process

#### ✅ MUST do before every installation:
- Search for the package on **Snyk Vulnerability Database** (`snyk.io/vuln`)
- Check **GitHub Security Advisories** for the repository
- Review **npm audit** / **pip audit** / **go vuln check** output
- Check **Socket.dev** for supply chain risk analysis (npm packages)
- Verify the package has **no known critical or high severity CVEs**

#### ❌ MUST NOT install if:
- The package has **unpatched critical (CVSS 9.0+) vulnerabilities**
- The package has **unpatched high (CVSS 7.0+) vulnerabilities** without a documented workaround
- The package has been flagged for **malware** or **supply chain attacks**
- The package has been **deprecated** due to security concerns

### 3.2 Vulnerability Severity Response Matrix

| CVSS Score | Severity | Action |
|-----------|----------|--------|
| **9.0 - 10.0** | Critical | ❌ **BLOCK** — Do not install. Find an alternative immediately. |
| **7.0 - 8.9** | High | ⚠️ **CONDITIONAL** — Only install if a patch/workaround exists. Document the risk. |
| **4.0 - 6.9** | Medium | ⚠️ **WARN** — Install with documented risk acknowledgment. Plan upgrade path. |
| **0.1 - 3.9** | Low | ✅ **ALLOW** — Install, but note in dependency documentation. |
| **None** | No known vulns | ✅ **ALLOW** — Proceed with installation. |

### 3.3 Supply Chain Risk Indicators

#### 🚩 Red flags that require deeper investigation:

| Indicator | Risk | Action |
|-----------|------|--------|
| Package name is similar to a popular package | **Typosquatting** | Verify exact package name on official registry |
| Install scripts (`preinstall`, `postinstall`) | **Arbitrary code execution** | Review the scripts before installing |
| Many new maintainers added recently | **Account takeover risk** | Check maintainer history |
| Single maintainer, low downloads | **Abandonment risk** | Consider well-maintained alternatives |
| Obfuscated or minified source code | **Malware concealment** | Do not install — review source first |
| Excessive permission requests | **Data exfiltration risk** | Investigate why permissions are needed |
| Recent ownership transfer | **Supply chain hijack** | Verify the transfer is legitimate |

#### 💡 Example: Security Assessment

```bash
# Step 1: Check npm audit for existing vulnerabilities
npm audit
# Output:
# found 2 vulnerabilities (1 moderate, 1 high)
#   semver <7.5.4 — Moderate — Regular Expression Denial of Service
#   xml2js <0.5.0 — High — Prototype Pollution

# Step 2: Check Snyk for the new package
# Visit: https://snyk.io/vuln/npm:new-package-name
# Result: 0 known vulnerabilities ✅

# Step 3: Check Socket.dev for supply chain risk
# Visit: https://socket.dev/npm/package/new-package-name
# Result: No install scripts, no obfuscated code, 5 maintainers ✅

# Step 4: Resolve existing vulnerabilities before adding new ones
npm audit fix
# Or override specific packages:
# "overrides": { "semver": ">=7.5.4", "xml2js": ">=0.5.0" }
```

```python
# Python: Security check with pip-audit
pip-audit
# Output:
# Name    Version  ID              Fix Versions
# ------- -------- --------------- ------------
# django  4.2.0    PYSEC-2024-001  4.2.8

# VERDICT: Upgrade django to 4.2.8 before adding new dependencies
pip install --upgrade django==4.2.8
```

---

## 4. 📊 Health & Maintenance Assessment

### 4.1 Activity & Maintenance Indicators

#### ✅ MUST verify:

| Metric | Healthy Threshold | Warning Threshold | Reject Threshold |
|--------|-------------------|-------------------|------------------|
| **Last commit** | < 3 months | 3-12 months | > 12 months |
| **Last release** | < 6 months | 6-18 months | > 18 months |
| **Open issues response** | Maintainers respond within 1 month | 1-3 months | No response > 3 months |
| **Weekly downloads (npm)** | > 10,000 | 1,000-10,000 | < 1,000 (investigate) |
| **GitHub stars** | > 500 | 100-500 | < 100 (investigate) |
| **Contributors** | > 5 | 2-5 | 1 (bus factor risk) |
| **Test coverage** | Has CI/CD + tests | Has some tests | No tests visible |

#### 💡 Example: Health Assessment

```
Package: date-fns (npm)
─────────────────────────────────
Last commit:      2 weeks ago          ✅ Active
Last release:     1 month ago          ✅ Recent
Weekly downloads: 18,000,000           ✅ Extremely popular
GitHub stars:     34,000               ✅ Well-established
Open issues:      150 (50 recent)      ✅ Actively triaged
Contributors:     400+                 ✅ Large community
License:          MIT                  ✅ Permissive
Test suite:       Comprehensive + CI   ✅ Well-tested
Bundle size:      5.6 kB (tree-shake)  ✅ Efficient

VERDICT: ✅ APPROVED — Excellent health indicators
```

```
Package: obscure-date-lib (npm)
─────────────────────────────────
Last commit:      14 months ago        ❌ Stale
Last release:     2 years ago          ❌ Abandoned
Weekly downloads: 230                  ❌ Very low adoption
GitHub stars:     45                   ⚠️ Low visibility
Open issues:      30 (0 responses)     ❌ Unmaintained
Contributors:     1                    ❌ Single maintainer (bus factor)
License:          MIT                  ✅ Permissive
Test suite:       None visible         ❌ No quality assurance

VERDICT: ❌ REJECTED — Unmaintained, single maintainer, no tests
RECOMMENDATION: Use date-fns or dayjs instead
```

### 4.2 Deprecation Check

#### ✅ MUST verify:
- The package is **not deprecated** on the registry
- The package README does not contain deprecation notices
- The package has not been **superseded** by a newer package from the same author
- The GitHub repository is not **archived**

#### 💡 Example: Detecting Deprecated Packages

```bash
# npm: Check for deprecation warnings
npm info request
# Output: DEPRECATED - request has been deprecated
# See: https://github.com/request/request/issues/3142

# VERDICT: ❌ REJECTED — Use 'undici', 'got', or native 'fetch' instead
```

```python
# Python: Check PyPI classifiers
# Visit: https://pypi.org/project/some-package/
# Look for: "Development Status :: 7 - Inactive"
# Or: "Development Status :: 1 - Planning" (not production-ready)

# VERDICT: ❌ REJECTED if status is Inactive
```

---

## 5. 📏 Necessity & Size Assessment

### 5.1 Do You Really Need This Dependency?

#### ✅ MUST ask before installing:
1. **Can this be implemented in < 50 lines of code?** → Do not add a dependency
2. **Does the project already have a package that provides similar functionality?** → Use the existing one
3. **Is this a polyfill for features already supported by the target runtime?** → Skip it
4. **Is this dependency only needed for a single use case?** → Consider copy-pasting the specific utility

#### 💡 Example: Avoiding Unnecessary Dependencies

```typescript
// ❌ REJECTED: Installing 'is-odd' package (1 line of code!)
// npm install is-odd
// Usage: isOdd(3) → true

// ✅ REQUIRED: Implement it yourself
function isOdd(n: number): boolean {
  return n % 2 !== 0;
}

// ❌ REJECTED: Installing 'left-pad' package (5 lines of code!)
// npm install left-pad

// ✅ REQUIRED: Use native method
const padded = '5'.padStart(3, '0'); // '005'

// ❌ REJECTED: Installing 'is-number' package
// npm install is-number

// ✅ REQUIRED: Use native check
function isNumber(value: unknown): value is number {
  return typeof value === 'number' && !isNaN(value);
}
```

### 5.2 Bundle Size Budget (Frontend Projects)

#### ✅ MUST evaluate for frontend/browser projects:

| Size Category | Threshold | Action |
|--------------|-----------|--------|
| **Tiny** | < 5 kB gzipped | ✅ Acceptable |
| **Small** | 5-20 kB gzipped | ✅ Acceptable — verify necessity |
| **Medium** | 20-50 kB gzipped | ⚠️ Justify the size — consider alternatives |
| **Large** | 50-100 kB gzipped | ⚠️ Strong justification needed — consider lazy loading |
| **Very Large** | > 100 kB gzipped | ❌ Requires explicit user approval — must consider alternatives |

#### 💡 Example: Size-Aware Decision Making

```bash
# Check bundle size before installing (JavaScript)
# Visit: https://bundlephobia.com/package/moment@2.30.1
# Result: 72.1 kB minified + gzipped  ❌ Very large!
# Transitive dependencies: 0
# Tree-shakeable: No ❌

# Alternative: date-fns
# Visit: https://bundlephobia.com/package/date-fns@3.3.1
# Result: 5.6 kB minified + gzipped (with tree-shaking) ✅
# Tree-shakeable: Yes ✅

# VERDICT: Use date-fns instead of moment.js
```

---

## 6. 📄 License Compatibility

### 6.1 License Verification

#### ✅ MUST check:
- The dependency license is **compatible** with the project's license
- The dependency does not introduce **copyleft obligations** (GPL, AGPL) into proprietary projects
- All transitive dependencies have **compatible licenses**

### 6.2 License Compatibility Matrix

| Dependency License | Proprietary Project | MIT Project | GPL Project | Apache 2.0 Project |
|-------------------|--------------------:|:-----------:|:-----------:|:------------------:|
| **MIT** | ✅ | ✅ | ✅ | ✅ |
| **Apache 2.0** | ✅ | ✅ | ✅ | ✅ |
| **BSD 2/3-Clause** | ✅ | ✅ | ✅ | ✅ |
| **ISC** | ✅ | ✅ | ✅ | ✅ |
| **MPL 2.0** | ⚠️ Modified files must stay open | ✅ | ✅ | ⚠️ |
| **LGPL** | ⚠️ Dynamic linking only | ✅ | ✅ | ⚠️ |
| **GPL 2.0/3.0** | ❌ Entire project must be GPL | ❌ | ✅ | ❌ |
| **AGPL 3.0** | ❌ Network use = distribution | ❌ | ❌ | ❌ |
| **Unlicensed / No License** | ❌ No permission granted | ❌ | ❌ | ❌ |

#### 💡 Example: License Check

```bash
# npm: Check license of a package and all its dependencies
npx license-checker --summary
# Output:
# ├─ MIT: 150
# ├─ Apache-2.0: 12
# ├─ ISC: 8
# ├─ BSD-3-Clause: 5
# └─ GPL-3.0: 1  ⚠️ INVESTIGATE THIS!

npx license-checker --onlyAllow "MIT;Apache-2.0;ISC;BSD-2-Clause;BSD-3-Clause"
# If any package uses a disallowed license, the command will fail

# Python: Check license
pip-licenses --format=table --with-urls
# Output:
#  Name       Version  License     URL
#  fastapi    0.109.2  MIT         https://...
#  pydantic   2.6.1    MIT         https://...
#  uvicorn    0.27.0   BSD-3       https://...
```

---

## 7. 📋 Verification Report Template

Before installing any dependency, the agent **MUST** produce a verification report (can be brief for well-known packages):

### 7.1 Quick Report (for well-known packages)

```markdown
## Dependency Verification: @tanstack/react-query@5.17.0

- **Purpose:** Server state management for React
- **Compatibility:** ✅ React 18 compatible, TypeScript 5 compatible
- **Security:** ✅ No known vulnerabilities (checked Snyk)
- **Health:** ✅ Active (last release: 2 weeks ago, 38K stars, 700+ contributors)
- **Size:** ✅ 13.2 kB gzipped (tree-shakeable)
- **License:** ✅ MIT
- **Verdict:** ✅ APPROVED
```

### 7.2 Detailed Report (for lesser-known or first-time packages)

```markdown
## Dependency Verification: some-new-package@2.1.0

### Basic Info
- **Package:** some-new-package
- **Version:** 2.1.0 (latest: 2.1.0)
- **Purpose:** Provides XYZ functionality
- **Repository:** https://github.com/org/some-new-package
- **License:** MIT ✅

### Compatibility
- **Node.js:** Requires >= 18.0.0 (project: 20.11.0) ✅
- **TypeScript:** Requires >= 5.0 (project: 5.3.0) ✅
- **Peer Deps:** react >= 18.0.0 (project: 18.2.0) ✅
- **Conflicts:** None detected ✅

### Security
- **Snyk:** 0 vulnerabilities ✅
- **Socket.dev:** No risk indicators ✅
- **npm audit:** Clean ✅
- **Install scripts:** None ✅

### Health
- **Last commit:** 3 weeks ago ✅
- **Last release:** 1 month ago ✅
- **Weekly downloads:** 45,000 ✅
- **GitHub stars:** 2,300 ✅
- **Contributors:** 25 ✅
- **Open issues:** 15 (actively triaged) ✅
- **Test coverage:** CI/CD with 90%+ coverage ✅

### Size Impact
- **Bundle size:** 8.2 kB gzipped ✅
- **Tree-shakeable:** Yes ✅
- **Transitive deps:** 2 (both well-known) ✅

### Alternatives Considered
1. **alternative-pkg** — Larger bundle (25 kB), less active
2. **another-pkg** — Missing TypeScript types
3. **Native implementation** — Would require ~200 lines → dependency justified

### Verdict: ✅ APPROVED
```

---

## 8. 🔄 Post-Installation Verification

### ✅ MUST do after installation:
1. Run **`npm audit`** / **`pip audit`** / **`go vuln check`** to confirm no new vulnerabilities
2. Verify the **lock file** is updated and committed
3. Run the project's **test suite** to confirm nothing is broken
4. Verify **build succeeds** with the new dependency
5. Check for **TypeScript type compatibility** (if applicable)

#### 💡 Example: Post-Installation Checklist

```bash
# After npm install new-package

# 1. Security audit
npm audit
# Expected: 0 vulnerabilities

# 2. Verify lock file
git diff package-lock.json  # Should show the new package

# 3. Run tests
npm test
# Expected: All tests pass

# 4. Build check
npm run build
# Expected: Build succeeds

# 5. Type check (TypeScript projects)
npx tsc --noEmit
# Expected: No type errors
```

---

## 9. 📋 Master Checklist

Before installing any dependency, the agent **MUST** complete this checklist:

### Pre-Installation
- [ ] **Research** — Package information gathered from credible sources (registry, GitHub, Snyk)
- [ ] **Necessity** — Cannot be implemented in < 50 lines of code
- [ ] **No duplicate** — No existing dependency provides the same functionality
- [ ] **Runtime compatibility** — Supports the project's language/runtime version
- [ ] **Peer dependencies** — All peer deps are satisfied, no version conflicts
- [ ] **Framework compatibility** — Works with the project's framework and version
- [ ] **Security** — No unpatched critical or high vulnerabilities
- [ ] **Supply chain** — No red flags (typosquatting, install scripts, ownership changes)
- [ ] **Health** — Actively maintained (last commit < 12 months, responsive maintainers)
- [ ] **Not deprecated** — Package is not deprecated or archived
- [ ] **License** — Compatible with the project's license
- [ ] **Size** — Bundle size is justified for frontend projects
- [ ] **Verification report** — Quick or detailed report produced

### Post-Installation
- [ ] **Audit clean** — `npm audit` / `pip audit` shows no new vulnerabilities
- [ ] **Lock file** — Updated and ready to commit
- [ ] **Tests pass** — Existing test suite passes
- [ ] **Build succeeds** — Project builds without errors
- [ ] **Types valid** — No TypeScript/type errors (if applicable)

---

## ⚠️ Exceptions

This rule may be **relaxed** only in these situations:

1. **Well-known, industry-standard packages** — Packages like `react`, `express`, `django`, `fastapi`, `lodash` may use a quick verification report instead of a full report
2. **User explicitly requests a specific package** — The agent must still warn about any issues found but may proceed after informing the user
3. **Development-only dependencies** — `devDependencies` (test runners, linters, formatters) may have a lighter verification, but security checks are still **mandatory**

> ⚠️ **IMPORTANT:** Even with exceptions, the agent must NEVER install a package with known **critical vulnerabilities** or **malware flags** without explicit user acknowledgment of the risk.
