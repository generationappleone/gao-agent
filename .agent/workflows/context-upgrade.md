---
description: Safely upgrade dependencies with compatibility checks, breaking change analysis, and automated testing. Use when updating packages or frameworks.
---

# Context Upgrade Workflow

This workflow provides a **safe, systematic approach** to upgrading dependencies. It analyzes breaking changes, runs compatibility checks, and verifies everything works after upgrades.

> **Companion to `/context-compatibility`**: compatibility audits (read-only), this workflow performs the actual upgrades.

## Steps

1. **Read project context** — Load `DEPENDENCIES.md` and project manifests.
   // turbo

2. **Run compatibility audit** — Execute `/context-compatibility` first to get the current state.
   // turbo

3. **Determine upgrade scope** — Ask the user:
   ```markdown
   📦 Dependency Upgrade

   What would you like to upgrade?
   1. 🔄 All outdated packages (incremental)
   2. 🎯 Specific package(s)
   3. 🚀 Major framework upgrade (e.g., React 18 → 19, Laravel 10 → 11)
   4. 🔒 Security patches only (fix vulnerabilities)
   5. 🧹 Remove unused dependencies
   ```

4. **Analyze upgrade impact** — For each package to upgrade:
   // turbo
   ```bash
   # Node.js: Check outdated packages
   npm outdated 2>&1 | head -30

   # PHP: Check outdated packages
   composer outdated --direct 2>&1 | head -30
   ```

   For each upgrade:
   - Check changelog / release notes (web search)
   - Identify breaking changes
   - Check peer dependency compatibility
   - Estimate risk level

5. **Create upgrade plan** — Present to user:
   ```markdown
   ## Upgrade Plan

   ### Safe Upgrades (patch/minor — low risk)
   | Package | Current | Target | Risk | Breaking? |
   |---------|---------|--------|------|-----------|
   | axios | 1.6.0 | 1.7.2 | Low | No |

   ### Risky Upgrades (major — requires code changes)
   | Package | Current | Target | Risk | Breaking Changes |
   |---------|---------|--------|------|-----------------|
   | react | 18.2 | 19.0 | High | New API, removed deprecated |

   ### Security Fixes (recommended immediately)
   | Package | Current | Target | CVE | Severity |
   |---------|---------|--------|-----|----------|
   | lodash | 4.17.20 | 4.17.21 | CVE-2021-23337 | High |
   ```

6. **⛔ Ask approval** — "Which upgrades shall I apply? (all / safe only / specific numbers)"

7. **Execute upgrades** — One at a time for risky, batch for safe:
   // turbo
   - Apply upgrade
   - Run build
   - Run tests
   - If build/tests fail → investigate and fix or revert

8. **Handle breaking changes** — For major upgrades:
   - Search for deprecated API usage
   - Apply migration guide changes
   - Update code to use new APIs
   - Verify tests pass after each change

9. **Final verification** — After all upgrades:
   // turbo
   - Full build
   - Full test suite
   - Security audit (`npm audit` / `composer audit`)
   - Application smoke test

10. **Update documentation** — Update `DEPENDENCIES.md` with new versions.

11. **Report** — Upgrade summary:
    ```markdown
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ✅ UPGRADE COMPLETE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Upgraded:  [N] packages
    Skipped:   [N] packages
    Reverted:  [N] packages (breaking)
    Security:  [N] vulnerabilities fixed
    Build:     ✅ Passing
    Tests:     ✅ All passing
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ```

## When to Use
- Before deployment (patch security vulnerabilities)
- Monthly maintenance (keep dependencies current)
- Major framework upgrades (React, Laravel, etc.)
- After `/context-compatibility` identifies issues

## When to Skip
- Brand new project (dependencies just installed)
- In the middle of a feature sprint (finish first)
- User explicitly says "don't update dependencies"
