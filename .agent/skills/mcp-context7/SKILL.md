---
name: MCP Server — Context7
description: MCP Server for Context7 — fetches up-to-date, version-specific library and framework documentation directly into AI assistant context, preventing outdated code generation.
---

# MCP Server — Context7

## Overview
Context7 MCP Server solves the problem of AI coding assistants using outdated library documentation. It fetches real-time, version-specific documentation from library sources and injects it into the AI's context at query time.

## Tools Provided

| Tool | Description |
|------|-------------|
| `resolve-library-id` | Resolve a library name to its Context7-compatible library ID |
| `get-library-docs` | Fetch up-to-date documentation for a specific library/version |

## Configuration

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

## Usage Patterns

### In Prompts
Add `use context7` to your prompts to automatically fetch current docs:
```
Create a Next.js 14 app with server actions. use context7
```

### In Cursor Rules
```
Always use context7 for code-related queries to ensure up-to-date API usage.
```

### Supported Libraries
Context7 supports thousands of popular libraries including:
- **Frontend**: React, Vue, Angular, Svelte, Next.js, Nuxt
- **Backend**: Express, FastAPI, Django, Laravel, Spring Boot
- **Databases**: Prisma, TypeORM, Sequelize, Mongoose
- **Tools**: Vite, Webpack, ESLint, Jest, Playwright
- **Cloud**: AWS SDK, GCP Libraries, Azure SDK

## Key Benefits
- **Prevents deprecated API usage**: Always fetches current docs
- **Version-specific**: Pulls docs for the exact version in use
- **Real-time**: No stale training data — live documentation retrieval
- **Framework-aware**: Understands library ecosystems and relationships

## Best Practices
- Always use Context7 when generating code for third-party libraries
- Combine with `resolve-library-id` first to ensure correct library matching
- Useful for rapidly evolving frameworks (React, Next.js, etc.)
