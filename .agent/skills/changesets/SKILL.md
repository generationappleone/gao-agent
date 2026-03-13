---
name: changesets
description: "Skill for monorepo versioning and publishing with Changesets — covering version management, changelog generation, CI automation, and npm publishing."
---

# Changesets — Monorepo Versioning & Publishing

## Overview

Changesets provides a structured workflow for version management in monorepos. Developers add changeset files describing their changes, and CI automates versioning and publishing.

## Setup

```bash
# Install
pnpm add -D @changesets/cli -w

# Initialize
pnpm changeset init
```

### .changeset/config.json

```json
{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "main",
  "updateInternalDependencies": "patch",
  "ignore": [],
  "___experimentalUnsafeOptions_WILL_CHANGE_IN_PATCH": {
    "onlyUpdatePeerDependentsWhenOutOfRange": true
  }
}
```

### Versioning Strategies

| Strategy | Config Key | Behavior |
|----------|-----------|----------|
| **Independent** | Default | Each package versioned independently |
| **Fixed** | `"fixed": [["@org/core", "@org/utils"]]` | Grouped packages always share same version |
| **Linked** | `"linked": [["@org/core", "@org/utils"]]` | Grouped packages bump together when any changes |

## Developer Workflow

### 1. Create a Changeset

```bash
pnpm changeset
```

Interactive prompts:
1. Which packages changed? → Select packages
2. Major, minor, or patch? → Select bump type
3. Summary? → Write human-readable description

### 2. Generated File

Creates `.changeset/[random-name].md`:

```markdown
---
"@org/core": minor
"@org/utils": patch
---

Add retry logic to API client and update utility helpers
```

### 3. Version Bump Guidance

| Change Type | Bump | Example |
|-------------|------|---------|
| Breaking API change | **major** | Remove public function, change return type |
| New feature (backward compatible) | **minor** | Add new function, new option parameter |
| Bug fix | **patch** | Fix null check, correct calculation |
| Internal refactor (no API change) | **patch** | Rename internal variable, optimize code |

## CI Integration

### GitHub Actions: Version Packages PR

```yaml
name: Release

on:
  push:
    branches: [main]

concurrency: ${{ github.workflow }}-${{ github.ref }}

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: 'pnpm'

      - run: pnpm install
      - run: pnpm build

      - name: Create Release Pull Request or Publish
        uses: changesets/action@v1
        with:
          publish: pnpm changeset publish
          version: pnpm changeset version
          commit: 'chore: version packages'
          title: 'chore: version packages'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### How the CI Flow Works

```
Developer pushes → Changesets exist?
├── YES → CI creates "Version Packages" PR
│         ├── Updates package.json versions
│         ├── Updates CHANGELOG.md
│         └── Removes changeset files
│         
│         Developer merges PR → CI publishes to npm
│
└── NO → Nothing happens (normal CI)
```

## CHANGELOG Generation

Changesets auto-generates `CHANGELOG.md` per package:

```markdown
# @org/core

## 2.1.0

### Minor Changes

- abc1234: Add retry logic to API client

### Patch Changes

- Updated dependencies
  - @org/utils@1.0.5
```

## Common Commands

```bash
# Create changeset
pnpm changeset

# Preview version bumps
pnpm changeset status

# Apply version bumps locally
pnpm changeset version

# Publish to npm
pnpm changeset publish

# Pre-release
pnpm changeset pre enter next
pnpm changeset version
pnpm changeset publish
pnpm changeset pre exit
```

## Integration

**This skill requires:**
- `skills/monorepo/SKILL.md` — pnpm workspace setup

**This skill pairs with:**
- `skills/git/SKILL.md` — Commit conventions
- `skills/github-api/SKILL.md` — CI/CD automation
