---
name: Git
description: Skill for version control with Git, covering branching strategies, conventional commits, conflict resolution, hooks, CI/CD integration, and team collaboration workflows.
---

# Git Skill

## Overview
Git is the standard distributed version control system. This skill covers branching strategies, conventional commits, workflow patterns, hooks, and best practices for team collaboration.

## Configuration
```bash
# Identity
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Defaults
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global fetch.prune true
git config --global core.autocrlf input    # Linux/macOS
git config --global core.autocrlf true     # Windows
git config --global core.editor "code --wait"

# Aliases (productivity)
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st "status -sb"
git config --global alias.lg "log --oneline --graph --decorate -20"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.undo "reset HEAD~1 --mixed"
git config --global alias.amend "commit --amend --no-edit"
```

## Branching Strategy (Git Flow)
```
main ─────────●────────────●────────────●──────── (production releases)
              │            ↑            ↑
develop ──●───┼───●───●────┼───●───●────┼──────── (integration branch)
          │   │   │   ↑    │   │   ↑    │
feature ──┘   │   └───┘    │   └───┘    │
              │     feature/   │   feature/
              │     user-auth  │   dashboard
              │                │
hotfix ───────┴────────────────┘
              hotfix/fix-login
```

| Branch | Purpose | Base | Merge Into |
|--------|---------|------|-----------|
| `main` | Production code | — | — |
| `develop` | Integration branch | `main` | `main` (release) |
| `feature/*` | New features | `develop` | `develop` |
| `bugfix/*` | Bug fixes | `develop` | `develop` |
| `hotfix/*` | Production fixes | `main` | `main` + `develop` |
| `release/*` | Release preparation | `develop` | `main` + `develop` |

### Simplified (GitHub Flow)
```
main ──────●──────●──────●──────●──── (always deployable)
           │      ↑      │      ↑
feature ───┘──────┘      └──────┘
           PR + review    PR + review
```

## Conventional Commits
```bash
# Format: <type>(<scope>): <description>

# Types
feat:     # New feature (minor version bump)
fix:      # Bug fix (patch version bump)
docs:     # Documentation only
style:    # Code style (formatting, semicolons)
refactor: # Code change that neither fixes nor adds
perf:     # Performance improvement
test:     # Adding/fixing tests
build:    # Build system or dependencies
ci:       # CI/CD configuration
chore:    # Other changes (gitignore, config)

# Examples
git commit -m "feat(auth): add JWT refresh token rotation"
git commit -m "fix(api): prevent SQL injection in user search"
git commit -m "docs(readme): add deployment instructions"
git commit -m "refactor(users): extract validation to service layer"
git commit -m "perf(db): add composite index on orders table"
git commit -m "test(auth): add integration tests for login flow"

# Breaking changes (major version bump)
git commit -m "feat(api)!: change response format to JSON:API"
# or with body
git commit -m "refactor(auth): migrate to OAuth 2.0

BREAKING CHANGE: Token format changed from JWT to opaque tokens.
All API clients must update their authentication flow."
```

## Common Workflows

### Feature Development
```bash
# 1. Start feature
git checkout develop
git pull origin develop
git checkout -b feature/user-profile

# 2. Work in small commits
git add -p                              # Stage interactively
git commit -m "feat(profile): add avatar upload endpoint"
git commit -m "feat(profile): add image resize service"
git commit -m "test(profile): add avatar upload tests"

# 3. Keep up to date
git fetch origin
git rebase origin/develop               # Rebase onto latest develop

# 4. Push & create PR
git push -u origin feature/user-profile
# Create Pull Request on GitHub/GitLab
```

### Conflict Resolution
```bash
# During rebase
git rebase origin/develop
# CONFLICT in src/service.ts
# 1. Open conflicted files
# 2. Resolve conflicts (keep correct changes)
# 3. Stage resolved files
git add src/service.ts
git rebase --continue

# Abort if needed
git rebase --abort
```

### Hotfix
```bash
git checkout main
git pull origin main
git checkout -b hotfix/fix-payment-bug

# Fix the bug
git commit -m "fix(payment): handle null currency code"

# Merge to main
git checkout main
git merge hotfix/fix-payment-bug
git tag -a v1.2.1 -m "Hotfix: payment currency bug"
git push origin main --tags

# Also merge to develop
git checkout develop
git merge hotfix/fix-payment-bug
git push origin develop
```

## .gitignore Best Practice
```gitignore
# Dependencies
node_modules/
vendor/
__pycache__/
.venv/

# Build output
dist/
build/
*.egg-info/
target/

# Environment
.env
.env.local
.env.production

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Coverage
coverage/
.nyc_output/
htmlcov/

# Secrets (NEVER commit)
*.pem
*.key
*.p12
credentials.json
service-account.json
```

## Git Hooks (Pre-commit)
```bash
# .husky/pre-commit (Node.js projects with Husky)
#!/bin/sh
npx lint-staged

# .husky/commit-msg
#!/bin/sh
npx --no-install commitlint --edit "$1"
```

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{css,scss}": ["prettier --write"],
    "*.{json,md}": ["prettier --write"]
  }
}
```

## Essential Commands
```bash
# Status & diff
git status -sb                    # Short status
git diff --staged                 # Staged changes
git log --oneline -20             # Recent history

# Stash
git stash                         # Save work in progress
git stash pop                     # Restore stashed work
git stash list                    # List stashes

# Reset & restore
git restore <file>                # Discard working changes
git restore --staged <file>       # Unstage file
git reset HEAD~1 --soft           # Undo last commit (keep changes staged)
git reset HEAD~1 --mixed          # Undo last commit (keep changes unstaged)

# Tags
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin --tags

# Cherry-pick
git cherry-pick <commit-hash>     # Apply specific commit

# Blame
git blame src/service.ts          # Who changed what

# Bisect (find bug-introducing commit)
git bisect start
git bisect bad                    # Current is broken
git bisect good v1.0.0            # This version was fine
# Git will binary search for the bad commit
```

## Rules Integration
- **Security**: Never commit secrets (.env, keys, credentials), use git-secrets or pre-commit hooks
- **Code Quality**: Pre-commit hooks enforce linting and formatting
- **ISO 27001**: Commit history provides audit trail, signed commits for integrity
