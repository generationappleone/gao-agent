---
name: knip-dead-code
description: "Skill for detecting unused exports, dependencies, and files with Knip — covering setup, configuration, CI integration, and common false positives."
---

# Knip — Dead Code & Dependency Detection

## Overview

Knip finds unused exports, unused dependencies, unused files, and duplicate exports in JavaScript/TypeScript projects. Prevents codebase bloat.

## Setup

```bash
# Install
pnpm add -D knip

# Run
pnpm knip
```

## Configuration (knip.json)

### Basic

```json
{
  "$schema": "https://unpkg.com/knip@5/schema.json",
  "entry": ["src/index.ts", "src/main.ts"],
  "project": ["src/**/*.ts"]
}
```

### With Framework Detection

```json
{
  "$schema": "https://unpkg.com/knip@5/schema.json",
  "entry": ["src/index.ts"],
  "project": ["src/**/*.ts"],
  "ignore": [
    "**/*.test.ts",
    "**/*.spec.ts",
    "**/__tests__/**"
  ],
  "ignoreBinaries": ["husky"],
  "ignoreDependencies": [
    "@types/node",
    "tsconfig-paths"
  ],
  "rules": {
    "files": "error",
    "dependencies": "error",
    "devDependencies": "warn",
    "optionalPeerDependencies": "off",
    "unlisted": "warn",
    "binaries": "warn",
    "unresolved": "error",
    "exports": "warn",
    "types": "warn",
    "duplicates": "warn"
  }
}
```

### Monorepo Configuration

```json
{
  "workspaces": {
    "packages/*": {
      "entry": ["src/index.ts"],
      "project": ["src/**/*.ts"]
    },
    "apps/web": {
      "entry": ["src/main.tsx", "src/pages/**/*.tsx"],
      "project": ["src/**/*.{ts,tsx}"]
    }
  }
}
```

## What Knip Detects

| Type | Example | Action |
|------|---------|--------|
| **Unused files** | `src/old-utils.ts` never imported | Delete file |
| **Unused exports** | `export function helper()` never imported | Remove export or delete |
| **Unused dependencies** | `"lodash"` in package.json, never used | Uninstall |
| **Unlisted dependencies** | `import axios from 'axios'` but not in package.json | Add to dependencies |
| **Duplicate exports** | Same function exported from 2 files | Consolidate |
| **Unused types** | `export type Config` never referenced | Remove type |

## Common False Positives

| False Positive | Solution |
|---------------|----------|
| Framework magic imports (Next.js pages) | Use framework plugin or add to `entry` |
| Dynamic imports `import()` | Add to `entry` array |
| Build tool plugins | Add to `ignoreDependencies` |
| Types-only packages | Add to `ignoreDependencies` |
| CLI tools (husky, lint-staged) | Add to `ignoreBinaries` |
| Test utilities | Separate test entry points |

### Plugin System

Knip auto-detects frameworks and adjusts:

```json
{
  "next": {
    "entry": ["pages/**/*.tsx", "app/**/*.tsx"]
  },
  "vitest": {
    "entry": ["**/*.test.ts"]
  }
}
```

## Package.json Scripts

```json
{
  "scripts": {
    "knip": "knip",
    "knip:fix": "knip --fix",
    "knip:production": "knip --production"
  }
}
```

### Command Options

| Command | Purpose |
|---------|---------|
| `knip` | Full analysis |
| `knip --fix` | Auto-remove unused exports and dependencies |
| `knip --production` | Only check production deps (skip devDependencies) |
| `knip --include files` | Only check for unused files |
| `knip --include dependencies` | Only check for unused dependencies |

## CI Integration

```yaml
# GitHub Actions
- name: Check for unused code
  run: pnpm knip
```

## Integration

**This skill pairs with:**
- `skills/biome/SKILL.md` — Biome catches unused imports, Knip catches unused exports
- `skills/monorepo/SKILL.md` — Workspace-level dead code detection
- `skills/typescript/SKILL.md` — Type-level unused detection
