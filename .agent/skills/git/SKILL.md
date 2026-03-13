---
name: Git
description: Skill for version control with Git, covering branching strategies, conventional commits, conflict resolution, hooks, CI/CD integration, and team collaboration workflows.
---

# Git Skill

## Overview
Git is the standard distributed version control system. It provides branching, merging, rebasing, stashing, and collaboration workflows. Conventional Commits and Git Flow/GitHub Flow are common patterns for team development.

**References**:
- [Git Documentation](https://git-scm.com/doc)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## Conventional Commits

```
<type>(<scope>): <description>

[optional body]
[optional footer]

Types:
  feat:     New feature
  fix:      Bug fix
  docs:     Documentation
  style:    Formatting (no code change)
  refactor: Code refactoring
  perf:     Performance improvement
  test:     Tests
  build:    Build system/dependencies
  ci:       CI/CD configuration
  chore:    Maintenance tasks

Examples:
  feat(auth): add Google OAuth login
  fix(cart): prevent negative quantity
  refactor(api): extract validation middleware
  docs(readme): update setup instructions
```

---

## Branching Strategy (GitHub Flow)

```bash
# Feature branch
git checkout -b feat/user-profile
# ... make changes ...
git add .
git commit -m "feat(profile): add user avatar upload"
git push origin feat/user-profile
# Create Pull Request on GitHub

# Hotfix
git checkout -b fix/cart-total
git commit -m "fix(cart): correct tax calculation"
git push origin fix/cart-total

# After PR merged
git checkout main
git pull origin main
git branch -d feat/user-profile
```

---

## Common Commands

```bash
# Status & log
git status
git log --oneline -10
git log --graph --oneline --all

# Stash
git stash
git stash pop
git stash list

# Rebase (clean history)
git checkout feat/my-feature
git rebase main
# Resolve conflicts if any, then:
git rebase --continue

# Interactive rebase (squash commits)
git rebase -i HEAD~3

# Cherry-pick
git cherry-pick <commit-hash>

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Tags
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Clean untracked files
git clean -fd
```

---

## .gitignore

```gitignore
node_modules/
dist/
.env
.env.local
.env.*.local
*.log
.DS_Store
Thumbs.db
.idea/
.vscode/
*.swp
coverage/
.next/
vendor/
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Conventional commits** | Structured commit messages |
| **Feature branches** | One branch per feature/fix |
| **Small commits** | Atomic, focused changes |
| **PR reviews** | All changes through pull requests |
| **Rebase** | Clean linear history |
| **Tags** | Semantic versioning for releases |
| **gitignore** | Exclude env, deps, IDE files |
| **Hooks** | Pre-commit linting, commit-msg validation |
| **Protected branches** | Require reviews for main/develop |
| **Squash merge** | Clean history on merge |

---

## GitHub Templates

### Pull Request Template

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Summary
[Brief description of changes]

## Type of Change
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 🔧 Refactor
- [ ] 📚 Documentation
- [ ] 🔒 Security patch

## Checklist
- [ ] Tests pass locally
- [ ] Code follows project conventions
- [ ] Self-review completed
- [ ] Documentation updated (if applicable)
```

### Issue Templates (YAML)

Create `.github/ISSUE_TEMPLATE/bug_report.yml`:

```yaml
name: 🐛 Bug Report
description: Report a bug
labels: [bug, triage]
body:
  - type: textarea
    attributes:
      label: Description
      description: Clear description of the bug
    validations:
      required: true
  - type: textarea
    attributes:
      label: Steps to Reproduce
      value: |
        1. Go to '...'
        2. Click on '...'
        3. See error
    validations:
      required: true
  - type: textarea
    attributes:
      label: Expected Behavior
    validations:
      required: true
```

Create `.github/ISSUE_TEMPLATE/feature_request.yml`:

```yaml
name: ✨ Feature Request
description: Suggest a feature
labels: [enhancement]
body:
  - type: textarea
    attributes:
      label: Problem Statement
      description: What problem does this solve?
    validations:
      required: true
  - type: textarea
    attributes:
      label: Proposed Solution
    validations:
      required: true
```

### CONTRIBUTING.md Pattern

```markdown
# Contributing

## Development Setup
1. Fork and clone the repository
2. Run `[install command]`
3. Create a feature branch from `main`

## Commit Convention
We use [Conventional Commits](https://conventionalcommits.org/).

## Pull Request Process
1. Ensure tests pass
2. Update documentation if needed
3. Request review from maintainers
```

---

## Rules Integration
- **Commits**: Conventional commit format
- **Branching**: Feature branch → PR → merge
- **Workflow**: GitHub Flow for simplicity
- **Tags**: Semantic versioning for releases
