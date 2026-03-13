---
name: using-git-worktrees
description: "Use when working on multiple features simultaneously or when SDD/swarm mode needs isolated branch workspaces. Safe worktree creation with project setup verification."
---

# Using Git Worktrees

## Overview

Git worktrees allow working on multiple branches simultaneously in separate directories. This skill provides safe worktree creation with proper project setup.

**Announce:** "Using git-worktrees skill for isolated branch workspace."

## When to Use

- **SDD (Subagent-Driven Development):** Each subagent gets its own worktree
- **Swarm mode execution:** Parallel agents need isolated directories
- **Working on multiple features:** Switch between features without stashing
- **Reviewing PRs:** Check out PR branch without affecting current work

## Directory Selection

### Strategy

```
project-root/
├── main-worktree/              ← Your original repo
├── main-worktree-feat-auth/    ← Worktree for auth feature
├── main-worktree-fix-login/    ← Worktree for login fix
└── main-worktree-refactor-db/  ← Worktree for DB refactor
```

**Naming convention:** `{project-dir}-{branch-type}-{description}`

### Safety Verification

Before creating a worktree:

```bash
# 1. Verify git repo is clean
git status --porcelain

# 2. Check existing worktrees
git worktree list

# 3. Verify target directory doesn't exist
[ -d "../project-feat-name" ] && echo "EXISTS" || echo "SAFE"

# 4. Verify target branch doesn't exist (or use existing)
git branch --list "feat/branch-name"
```

## Creating a Worktree

### New Feature Branch
```bash
# Create worktree with new branch
git worktree add ../project-feat-name -b feat/feature-name main

# Verify creation
git worktree list
cd ../project-feat-name
git branch --show-current
```

### Existing Branch
```bash
# Create worktree from existing branch
git worktree add ../project-feat-name feat/existing-branch

# Verify
cd ../project-feat-name
git log --oneline -5
```

## Project Setup in Worktree

After creating a worktree, the project may need setup:

```bash
cd ../project-feat-name

# Install dependencies
npm install   # or: composer install, pip install -r requirements.txt

# Copy environment file if needed
cp ../{main-worktree}/.env .env

# Verify project works
npm run build   # or equivalent
npm test        # or equivalent
```

### Common Setup Checklist

```
☐ Dependencies installed
☐ Environment file present
☐ Build passes
☐ Tests pass
☐ Git branch verified
```

## Cleaning Up Worktrees

After branch is merged or work is complete:

```bash
# Remove the worktree
git worktree remove ../project-feat-name

# Or force remove (if uncommitted changes)
git worktree remove --force ../project-feat-name

# Prune stale worktree references
git worktree prune

# Verify cleanup
git worktree list
```

## Common Mistakes

| Mistake | Prevention |
|---------|-----------|
| Creating worktree inside repo | Always use `../` (parent directory) |
| Forgetting to install deps | Always run project setup after creation |
| Leaving stale worktrees | Clean up after merge |
| Shared mutable state (.env) | Copy env file, don't symlink |

## Integration

**This skill is used by:**
- **executing-plans** — Worktree mode for git setup
- **subagent-driven-development** — Isolated workspace per subagent
- **finishing-a-development-branch** — Cleanup includes worktree removal
