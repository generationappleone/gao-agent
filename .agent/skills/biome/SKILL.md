---
name: biome
description: "Skill for modern linting and formatting with Biome — covering configuration, migration from ESLint/Prettier, key rules, and CI integration."
---

# Biome — Modern Linter & Formatter

## Overview

Biome is a fast, all-in-one tool that replaces ESLint + Prettier. Single tool, single config, significantly faster execution.

## Setup

```bash
# Install
pnpm add -D @biomejs/biome

# Initialize config
pnpm biome init
```

## Configuration (biome.jsonc)

```jsonc
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "tab",
    "indentWidth": 2,
    "lineWidth": 100,
    "lineEnding": "lf"
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "complexity": {
        "noExcessiveCognitiveComplexity": {
          "level": "warn",
          "options": { "maxAllowedComplexity": 15 }
        }
      },
      "performance": {
        "noBarrelFile": "warn",
        "noReExportAll": "warn",
        "noAccumulatingSpread": "warn"
      },
      "suspicious": {
        "noExplicitAny": "warn",
        "noConsoleLog": "warn"
      },
      "a11y": {
        "recommended": true
      },
      "correctness": {
        "noUnusedImports": "error",
        "noUnusedVariables": "warn"
      },
      "style": {
        "noNonNullAssertion": "warn",
        "useConst": "error",
        "useTemplate": "error"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "trailingCommas": "all",
      "semicolons": "always"
    }
  },
  "files": {
    "ignore": [
      "node_modules",
      "dist",
      ".next",
      "coverage",
      "*.min.js"
    ]
  }
}
```

## Key Rules

| Category | Rule | Purpose |
|----------|------|---------|
| **Complexity** | `noExcessiveCognitiveComplexity` | Limit function complexity |
| **Performance** | `noBarrelFile` | Avoid barrel `index.ts` re-exports |
| **Performance** | `noReExportAll` | No `export * from` (tree-shaking) |
| **Performance** | `noAccumulatingSpread` | No spread in loops |
| **A11y** | `useButtonType` | Require `type` on `<button>` |
| **A11y** | `useAltText` | Require `alt` on `<img>` |
| **Correctness** | `noUnusedImports` | Remove dead imports |
| **Style** | `useConst` | Prefer `const` over `let` |

## Migration from ESLint/Prettier

```bash
# Migrate ESLint config
pnpm biome migrate eslint --write

# Migrate Prettier config
pnpm biome migrate prettier --write
```

After migration:
1. Remove `.eslintrc.*`, `.prettierrc.*`
2. Uninstall ESLint and Prettier packages
3. Update scripts in `package.json`

## Package.json Scripts

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --fix .",
    "format": "biome format --write .",
    "ci": "biome ci ."
  }
}
```

### Command Differences

| Command | Behavior |
|---------|----------|
| `biome check` | Run all checks (lint + format + imports) |
| `biome check --fix` | Auto-fix safe issues |
| `biome format` | Only formatting |
| `biome lint` | Only linting |
| `biome ci` | CI mode: non-zero exit on violations |

## .editorconfig Complement

```ini
# .editorconfig
root = true

[*]
indent_style = tab
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

## CI Integration

```yaml
# GitHub Actions
- name: Lint & Format Check
  run: pnpm biome ci .
```

## Integration

**This skill replaces:**
- ESLint + Prettier combination

**This skill pairs with:**
- `skills/typescript/SKILL.md` — TypeScript-specific rules
- `skills/monorepo/SKILL.md` — Shared configs across packages
