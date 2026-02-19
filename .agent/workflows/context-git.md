---
description: Git operations — branching, committing, merging, tagging, and release management with conventional commits and changelog generation.
---

# Context Git Workflow

This workflow provides structured Git operations following best practices. It handles branching strategy, conventional commits, release tagging, and changelog generation.

## Steps

1. **Read project context** — Check for existing Git configuration.
   // turbo
   ```bash
   git status 2>&1 | head -5
   git branch -a 2>&1 | head -20
   git log --oneline -5 2>&1
   ```

2. **Read git skill** — Load `skills/git/SKILL.md` for best practices.
   // turbo

3. **Determine action** — Ask the user:
   ```markdown
   🔀 Git Operations

   What do you need?
   1. 🌿 Create feature branch
   2. 💾 Commit changes (conventional commits)
   3. 🔀 Merge branch (with conflict resolution)
   4. 🏷️ Create release tag
   5. 📝 Generate changelog from commits
   6. 🔍 Review changes (diff analysis)
   7. ⏪ Revert changes
   8. 🧹 Clean up branches (delete merged)
   ```

4. **For feature branch** — Create with naming convention:
   ```
   Format: [type]/[ticket-or-description]

   Types: feature/, bugfix/, hotfix/, refactor/, docs/, chore/
   Examples:
   - feature/user-notifications
   - bugfix/fix-login-redirect
   - hotfix/critical-auth-bypass
   ```

5. **For commits** — Enforce Conventional Commits:
   ```
   Format: type(scope): description

   Types:
   - feat:     New feature
   - fix:      Bug fix
   - docs:     Documentation only
   - style:    Formatting (no code change)
   - refactor: Code restructuring
   - perf:     Performance improvement
   - test:     Adding/fixing tests
   - chore:    Build, CI, deps changes

   Examples:
   - feat(auth): implement JWT refresh token rotation
   - fix(api): resolve N+1 query in user listing
   - docs(readme): add deployment instructions
   ```

6. **For merge** — Safe merge process:
   // turbo
   - Check for conflicts before merging
   - If conflicts → show conflicting files and help resolve
   - After merge → run build and tests to verify
   - Delete merged branch (optional)

7. **For release** — Create semantic version tag:
   ```
   Based on commits since last tag:
   - feat: → minor version bump (1.0.0 → 1.1.0)
   - fix:  → patch version bump (1.0.0 → 1.0.1)
   - BREAKING CHANGE: → major bump (1.0.0 → 2.0.0)
   ```
   // turbo
   ```bash
   git tag -a v[version] -m "Release v[version]: [summary]"
   ```

8. **For changelog** — Generate from commit history:
   // turbo
   - Parse conventional commits
   - Group by type (Features, Bug Fixes, etc.)
   - Include breaking changes prominently
   - Format as Keep a Changelog

9. **Verify** — After any Git operation:
   // turbo
   - Confirm current branch and status
   - Verify no uncommitted changes (unless intended)

## When to Use
- Starting new feature work
- Completing a task (committing)
- Preparing a release
- Managing branches
- Resolving merge conflicts

## When to Skip
- Agent auto-commits during `/context-work` (handled internally)
- Simple single-file changes
