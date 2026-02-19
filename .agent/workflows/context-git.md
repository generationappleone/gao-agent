---
description: Git operations — branching, committing, merging, tagging, and release management with conventional commits, PR templates, and changelog generation.
---

# Context Git — Structured Git Operations

## Purpose
This workflow provides **structured, safe Git operations** following best practices. It handles branching strategy, conventional commits, merge conflict resolution, release tagging, changelog generation, and PR template creation.

---

## Activation
The user triggers this workflow by:
- Using `/context-git` to see operation menu
- Using `/context-git commit` to commit current changes
- Using `/context-git branch [name]` to create a branch
- Using `/context-git release` to create a release
- Using `/context-git changelog` to generate changelog

---

## Phase 1: Context Gathering

### Step 1.1 — Read Git State
// turbo
```bash
git status 2>&1 | head -15
git branch -a 2>&1 | head -20
git log --oneline -10 2>&1
git remote -v 2>&1
git stash list 2>&1 | head -5
```

### Step 1.2 — Read Git Skill & Rules
// turbo
Read these for best practices:
- `skills/git/SKILL.md` — Git best practices and conventions
- `skills/github-api/SKILL.md` — If using GitHub (PR creation, API automation)
- `.agent/rules/deep-thinking.md` — Deep thinking & quality standards (MANDATORY)

### Step 1.3 — Determine Action

```markdown
🔀 Git Operations

What do you need?
1. 🌿 **Create branch** — Start a new feature/fix/hotfix branch
2. 💾 **Commit changes** — Stage + commit with conventional format
3. 🔀 **Merge branch** — Safe merge with conflict resolution
4. 🏷️ **Create release** — Semantic version tag + changelog
5. 📝 **Generate changelog** — From commit history
6. 🔍 **Review changes** — Diff analysis before commit
7. ⏪ **Revert changes** — Undo recent commits safely
8. 🧹 **Clean up** — Delete merged branches, prune remotes
9. 📄 **Generate PR template** — Create pull request description
10. 🔐 **Pre-commit check** — Run build, test, lint before committing
```

---

## Phase 2: Branch Management

### Step 2.1 — Branch Naming Convention

```
Format: [type]/[ticket-or-description]

Types:
├── feature/   — New feature or enhancement
├── bugfix/    — Non-critical bug fix
├── hotfix/    — Critical production fix
├── refactor/  — Code restructuring
├── docs/      — Documentation only
├── chore/     — Build, CI, dependencies
├── test/      — Adding or fixing tests
└── release/   — Release preparation

Examples:
- feature/user-notifications
- bugfix/fix-login-redirect
- hotfix/critical-auth-bypass
- refactor/extract-payment-service
- chore/upgrade-react-19
```

### Step 2.2 — Create Branch
// turbo
```bash
# Ensure clean working directory
git status --porcelain 2>&1

# Create from latest main/master
git checkout main 2>&1 || git checkout master 2>&1
git pull origin main 2>&1 || git pull origin master 2>&1
git checkout -b [type]/[description] 2>&1

# Verify
git branch --show-current 2>&1
```

---

## Phase 3: Committing

### Step 3.1 — Pre-Commit Verification
// turbo

Before any commit, verify:
```bash
# Build check
npm run build 2>&1 | tail -10

# Test check
npm test -- --passWithNoTests 2>&1 | tail -10

# Lint check
npm run lint 2>&1 | tail -10
```

**If any fail → FIX before committing.** Never commit broken code.

### Step 3.2 — Stage Changes
// turbo
```bash
# Review what changed
git diff --stat 2>&1 | head -30
git diff --name-status 2>&1 | head -30

# Stage (ask user or auto-detect)
git add -A 2>&1

# Verify staged files
git diff --cached --stat 2>&1 | head -30
```

### Step 3.3 — Conventional Commit Format

```
Format: type(scope): description

type     — What kind of change
scope    — What area (optional but recommended)
description — Present tense, lowercase, no period

Types:
├── feat:     New feature                     → MINOR version bump
├── fix:      Bug fix                         → PATCH version bump
├── docs:     Documentation only
├── style:    Formatting (no code change)
├── refactor: Code restructuring (no behavior change)
├── perf:     Performance improvement
├── test:     Adding/fixing tests
├── build:    Build system, dependencies
├── ci:       CI/CD pipeline changes
├── chore:    Other maintenance
└── revert:   Reverts a previous commit

Breaking changes:
- Add BREAKING CHANGE: in footer       → MAJOR version bump
- Or use ! after type: feat!: new API  → MAJOR version bump

Examples:
- feat(auth): implement JWT refresh token rotation
- fix(api): resolve N+1 query in user listing
- fix(auth)!: remove deprecated login endpoint
- docs(readme): add deployment instructions
- refactor(services): extract payment validation logic
- perf(db): add composite index on orders table
- test(user): add edge case tests for registration
- chore(deps): upgrade TypeScript to 5.4
```

### Step 3.4 — Generate Commit Message

Analyze the staged changes and generate an appropriate commit message:

```bash
# Analyze staged changes to determine commit type and scope
git diff --cached --stat 2>&1
git diff --cached 2>&1 | head -100
```

Present the generated message for approval:
```markdown
💾 Suggested Commit

`feat(notifications): add real-time notification service`

Body:
- Create NotificationService with WebSocket support
- Add notification model with UUID primary key
- Implement notification controller with CRUD endpoints
- Add migration for notifications table

Staged files: [N]
Lines changed: +[N] -[N]

Proceed with this commit? (yes / edit / cancel)
```

### Step 3.5 — Execute Commit
```bash
git commit -m "type(scope): description" -m "body details" 2>&1
```

---

## Phase 4: Merging

### Step 4.1 — Pre-Merge Analysis
// turbo
```bash
# Check the current branch
git branch --show-current 2>&1

# Check for divergence
git fetch origin 2>&1
git log --oneline main..HEAD 2>&1 | head -10
git log --oneline HEAD..main 2>&1 | head -10

# Check for conflicts (dry run)
git merge --no-commit --no-ff main 2>&1 | head -20
git merge --abort 2>&1
```

### Step 4.2 — Conflict Resolution

If conflicts detected:

```markdown
⚠️ Merge Conflicts Detected

| # | File | Conflict Type |
|---|------|--------------|
| 1 | src/services/UserService.ts | Both modified |
| 2 | package.json | Version conflict |

Options:
1. 🔧 **Resolve automatically** — I'll resolve obvious conflicts
2. 📋 **Show conflicts** — Display each conflict for manual review
3. ❌ **Abort merge** — Cancel and keep current state
```

For each conflict:
1. Show both versions (ours vs theirs)
2. Recommend resolution based on context
3. Apply resolution after user approval

### Step 4.3 — Post-Merge Verification
// turbo
```bash
# Build check
npm run build 2>&1 | tail -20

# Test check
npm test 2>&1 | tail -20

# Lint check
npm run lint 2>&1 | tail -10

# Verify merge commit
git log --oneline -3 2>&1
```

### Step 4.4 — Clean Up After Merge
```bash
# Delete merged branch (optional, ask user)
git branch -d [branch-name] 2>&1
git push origin --delete [branch-name] 2>&1
```

---

## Phase 5: Releases & Tags

### Step 5.1 — Determine Version Bump

Analyze commits since last tag:
// turbo
```bash
# Find last tag
git describe --tags --abbrev=0 2>&1

# List commits since last tag
git log $(git describe --tags --abbrev=0 2>/dev/null)..HEAD --oneline 2>&1 | head -30
```

Apply semver rules:
```
BREAKING CHANGE: or feat!: → MAJOR (1.0.0 → 2.0.0)
feat:                      → MINOR (1.0.0 → 1.1.0)
fix:                       → PATCH (1.0.0 → 1.0.1)
```

### Step 5.2 — Create Release Tag

```bash
# Create annotated tag
git tag -a v[version] -m "Release v[version]: [summary]" 2>&1

# Verify
git tag -l -n1 | tail -5
```

### Step 5.3 — Generate Release Notes

```markdown
## Release v[X.Y.Z] — [YYYY-MM-DD]

### ✨ Features
- [feat commit summaries]

### 🐛 Bug Fixes
- [fix commit summaries]

### ⚡ Performance
- [perf commit summaries]

### 🔒 Security
- [security-related changes]

### 💥 Breaking Changes
- [breaking change descriptions with migration guide]

### 📦 Dependencies
- [chore(deps) commit summaries]

**Full Changelog:** [compare URL]
```

---

## Phase 6: Changelog Generation

### Step 6.1 — Parse Commit History
// turbo
```bash
# Get all commits since last tag (or all commits)
git log $(git describe --tags --abbrev=0 2>/dev/null)..HEAD --format="%H|%s|%an|%ad" --date=short 2>&1 | head -100
```

### Step 6.2 — Generate CHANGELOG.md

Follow [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- [new features from feat: commits]

### Changed
- [changes from refactor: and perf: commits]

### Deprecated
- [deprecated features]

### Removed
- [removed features]

### Fixed
- [bug fixes from fix: commits]

### Security
- [security fixes]

## [1.0.0] — 2026-02-19

### Added
- Initial release
[...]
```

---

## Phase 7: PR Template Generation

### Step 7.1 — Generate Pull Request Description

Based on the branch commits, generate a comprehensive PR template:

```markdown
## 📋 Description
[Auto-generated summary of changes from commit messages]

## 🔗 Related Issues
- Closes #[issue-number]

## 📝 Changes
[List of changes grouped by type]

## 🧪 Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## 📸 Screenshots (if UI changes)
[Add screenshots]

## ✅ Checklist
- [ ] Code follows project conventions
- [ ] All tests passing
- [ ] Build succeeds
- [ ] Lint clean
- [ ] Documentation updated
- [ ] No security issues introduced
- [ ] No P1/P2 review findings
```

---

## Phase 8: Verification & Report

### Step 8.1 — Post-Operation Verification
// turbo
```bash
# Verify current state
git status 2>&1 | head -10
git branch --show-current 2>&1
git log --oneline -5 2>&1
```

### Step 8.2 — Operation Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ GIT OPERATION COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action:   [branch / commit / merge / release]
Branch:   [current branch]
Status:   ✅ Clean
Commits:  [N] new commits
Tag:      [if applicable]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## When to Use
- Starting new feature work (branching)
- Completing a task (committing)
- Preparing a release (tagging, changelog)
- Managing branches (merge, cleanup)
- Resolving merge conflicts
- Generating PR descriptions

## When to Skip
- Agent auto-commits during `/context-work` (handled internally)
- Simple single-file changes where the user prefers to commit manually
