---
name: finishing-a-development-branch
description: "Use when a feature branch is complete and ready to be integrated, archived, or cleaned up. Provides 4-option methodology for branch completion."
---

# Finishing a Development Branch

## Overview

When development on a branch is complete, this skill provides a structured process for integration. It covers verification, branch completion options, and cleanup.

**Announce:** "Using the finishing-a-development-branch skill."

## Pre-Completion Checklist

Before finishing any branch:

```
☐ All tests pass
☐ Linting clean
☐ Build succeeds
☐ Code review completed (or self-reviewed)
☐ No uncommitted changes
☐ Branch is up-to-date with base branch
```

```bash
# Quick verification
git status --porcelain
npm test 2>&1 | tail -5
npm run build 2>&1 | tail -5
npm run lint 2>&1 | tail -5
```

## Determine Base Branch

```bash
# Check where this branch was created from
git log --oneline --first-parent main..HEAD | wc -l
git merge-base main HEAD
```

Common base branches:
- `main` / `master` — Most features
- `develop` — If using Git Flow
- `release/X.Y` — Hotfixes to specific release

## 4 Branch Completion Options

### Option 1: Merge (Standard)

**Best for:** Standard feature completion, team projects with PR workflow.

```bash
# Update base branch
git checkout main
git pull origin main

# Merge feature
git merge --no-ff feat/feature-name -m "feat: merge feature-name"

# Push
git push origin main

# Cleanup
git branch -d feat/feature-name
git push origin --delete feat/feature-name
```

**When to use:** Default option. Preserves branch history via merge commit.

### Option 2: Squash Merge

**Best for:** Many small commits, messy commit history, clean main branch log.

```bash
git checkout main
git pull origin main

# Squash merge
git merge --squash feat/feature-name
git commit -m "feat: implement feature-name

- Detail 1
- Detail 2
- Detail 3"

git push origin main

# Cleanup
git branch -D feat/feature-name
git push origin --delete feat/feature-name
```

**When to use:** When branch has many WIP commits that don't add value.

### Option 3: Rebase

**Best for:** Linear history, solo developers, small features.

```bash
# Rebase onto main
git checkout feat/feature-name
git rebase main

# Fast-forward merge
git checkout main
git merge --ff-only feat/feature-name

git push origin main

# Cleanup
git branch -d feat/feature-name
git push origin --delete feat/feature-name
```

**When to use:** When linear history is preferred and no one else is working on this branch.

### Option 4: Archive

**Best for:** Work paused, experimental branches, keeping for reference.

```bash
# Tag the branch for reference
git tag archive/feat/feature-name feat/feature-name

# Delete the branch (tag preserves commits)
git branch -D feat/feature-name
git push origin --delete feat/feature-name

# Push the archive tag
git push origin archive/feat/feature-name
```

**When to use:** When work is paused/abandoned but you want to preserve the code.

## Worktree Cleanup

If the branch was in a worktree:

```bash
# Remove worktree
git worktree remove ../project-feat-name

# Prune references
git worktree prune

# Verify
git worktree list
```

## Post-Completion

After branch is finished:

1. **Update plan** — Mark related task as complete
2. **Notify team** — If applicable, inform about the merge
3. **Document** — Use `knowledge-compounding` skill if learnings should be captured

## Integration

**This skill is called by:**
- **executing-plans** — Branch completion after all tasks
- **context-git.md** — Phase 4.5 references this as authoritative source

**This skill references:**
- **using-git-worktrees** — Worktree cleanup procedures
- **verification-before-completion** — Pre-completion verification
