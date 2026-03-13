---
name: monorepo
description: "Skill for managing monorepo projects with pnpm workspaces, Turborepo, and tsup — covering workspace setup, cross-package dependencies, testing, and build strategies."
---

# Monorepo — pnpm + Turborepo + tsup

## Overview

Patterns for managing JavaScript/TypeScript monorepos using pnpm workspaces for dependency management, Turborepo for build orchestration, and tsup for library bundling.

## Workspace Setup

### pnpm-workspace.yaml

```yaml
packages:
  - 'packages/*'
  - 'apps/*'
  - 'tools/*'
```

### Root package.json

```json
{
  "name": "monorepo-root",
  "private": true,
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "test": "turbo test",
    "lint": "turbo lint",
    "typecheck": "turbo typecheck",
    "clean": "turbo clean"
  },
  "devDependencies": {
    "turbo": "^2.0.0"
  },
  "packageManager": "pnpm@9.0.0"
}
```

### Directory Structure

```
monorepo/
├── pnpm-workspace.yaml
├── turbo.json
├── package.json
├── tsconfig.base.json
├── apps/
│   ├── web/           ← Next.js / Vite app
│   └── docs/          ← Documentation site
├── packages/
│   ├── core/          ← Core library
│   ├── ui/            ← Shared UI components
│   ├── config/        ← Shared configs (ESLint, TS, etc.)
│   └── utils/         ← Shared utilities
└── tools/
    └── scripts/       ← Build/deploy scripts
```

## Turborepo Configuration

### turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "typecheck": {
      "dependsOn": ["^build"]
    },
    "clean": {
      "cache": false
    }
  }
}
```

### Key Concepts

| Concept | Meaning |
|---------|---------|
| `dependsOn: ["^build"]` | Run build of dependencies first (topological) |
| `outputs` | Files to cache for subsequent runs |
| `cache: false` | Never cache this task (dev servers, clean) |
| `persistent: true` | Long-running process (dev servers) |

## Shared TypeScript Configuration

### tsconfig.base.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true
  }
}
```

Each package extends this:

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}
```

## Cross-Package Dependencies

### Internal Dependencies

```json
// packages/core/package.json
{
  "name": "@org/core",
  "version": "1.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    }
  }
}

// apps/web/package.json
{
  "dependencies": {
    "@org/core": "workspace:*",
    "@org/ui": "workspace:*"
  }
}
```

## tsup for Library Builds

### Package tsup.config.ts

```typescript
import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['cjs', 'esm'],
  dts: true,
  sourcemap: true,
  clean: true,
  splitting: false,
  treeshake: true,
});
```

### Build Script

```json
{
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch"
  }
}
```

## Workspace-Level Testing (Vitest)

### vitest.workspace.ts

```typescript
import { defineWorkspace } from 'vitest/config';

export default defineWorkspace([
  'packages/*/vitest.config.ts',
  'apps/*/vitest.config.ts',
]);
```

### Per-Package vitest.config.ts

```typescript
import { defineProject } from 'vitest/config';

export default defineProject({
  test: {
    name: '@org/core',
    environment: 'node',
    include: ['src/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/**/index.ts'],
    },
  },
});
```

## Factory Function Pattern

Common pattern for monorepo packages with environment auto-detection:

```typescript
// packages/core/src/client.ts
export function createClient(config?: Partial<ClientConfig>) {
  const resolved: ClientConfig = {
    apiKey: config?.apiKey ?? process.env.API_KEY ?? '',
    baseUrl: config?.baseUrl ?? process.env.API_URL ?? 'https://api.example.com',
    timeout: config?.timeout ?? 30000,
    ...config,
  };

  // validate
  if (!resolved.apiKey) {
    throw new Error('API key is required. Set API_KEY env var or pass apiKey in config.');
  }

  return new Client(resolved);
}
```

## Documentation-as-Product

Ship docs inside the npm package:

```json
{
  "scripts": {
    "build": "tsup && cp -r docs ./dist/docs"
  },
  "files": ["dist", "README.md", "LICENSE"]
}
```

## Common Commands

```bash
# Install all workspace dependencies
pnpm install

# Add dependency to specific package
pnpm add lodash --filter @org/core

# Add dev dependency to root
pnpm add -D turbo -w

# Run build for all packages
pnpm build

# Run build for single package
pnpm build --filter @org/core

# Run tests for changed packages
pnpm test --filter ...[HEAD~1]
```

## Integration

**This skill pairs with:**
- `skills/changesets/SKILL.md` — Monorepo versioning and publishing
- `skills/typescript/SKILL.md` — TypeScript configuration
