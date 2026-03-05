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
| `query-docs` | Fetch up-to-date documentation for a specific library using its Context7 ID |

### Tool: `resolve-library-id`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | Yes | The user's question or task (used to rank results by relevance) |
| `libraryName` | Yes | The name of the library to search for |

**Example:**
```
Input:  libraryName = "Next.js", query = "server actions"
Output: libraryId = "/vercel/next.js"
```

### Tool: `query-docs`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `libraryId` | Yes | Exact Context7-compatible library ID (e.g., `/mongodb/docs`, `/vercel/next.js`) |
| `query` | Yes | The question or task to get relevant documentation for |

**Example:**
```
Input:  libraryId = "/vercel/next.js", query = "middleware JWT authentication"
Output: Up-to-date documentation + code examples for Next.js middleware
```

## Configuration

### Remote Server Connection (Recommended)

```json
{
  "mcpServers": {
    "context7": {
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

### Local Server Connection

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp", "--api-key", "YOUR_API_KEY"]
    }
  }
}
```

> **Note:** Get a free API key at [context7.com/dashboard](https://context7.com/dashboard) for higher rate limits.

## GAO Agent Integration

### Quick Setup

1. Browse templates in `.agent/mcp-configs/templates/`
2. Find the template matching your AI client (see table below)
3. Copy to the correct location for your client
4. Replace `YOUR_API_KEY` with your key from [context7.com/dashboard](https://context7.com/dashboard)
5. Validate with `/context-mcp-check context7`

### Templates per AI Client

| Client | Template | Config Location |
|--------|----------|-----------------|
| **Google Antigravity** ⭐ | `antigravity.mcp.json` | `.mcp.json` (project root) |
| **Cursor** | `cursor.mcp.json` | `~/.cursor/mcp.json` |
| **VS Code** | `vscode.mcp.json` | `.vscode/mcp.json` |
| **Claude Code** | `claude-code.md` | Via CLI command |
| **Claude Desktop** | `claude-desktop.mcp.json` | `claude_desktop_config.json` |
| **Windsurf** | `windsurf.mcp.json` | Via UI |
| **Gemini CLI** | `gemini-cli.json` | `~/.gemini/settings.json` |
| **20+ more** | See `.agent/mcp-configs/README.md` | Various |

### Environment Variable

```bash
# Set in .env file (never commit!)
CONTEXT7_API_KEY=your_api_key_here
```

Template: `.agent/mcp-configs/.env.mcp.example`

## Usage Patterns

### In Prompts
Add `use context7` to your prompts to automatically fetch current docs:
```
Create a Next.js 14 app with server actions. use context7
```

### Using Library ID Directly
Skip library matching by specifying the ID:
```
Implement basic authentication with Supabase. use library /supabase/supabase for API and docs.
```

### Specifying a Version
Mention the version in your prompt:
```
How do I set up Next.js 14 middleware? use context7
```

### Auto-Invoke Rule
Add to your AI client rules to avoid typing `use context7` every time:
```
Always use Context7 MCP when I need library/API documentation, code generation,
setup or configuration steps without me having to explicitly ask.
```

## Supported Libraries
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
- **Complements GAO Agent skills**: Skills provide architecture patterns; Context7 provides real-time API reference

## Best Practices
- Always use Context7 when generating code for third-party libraries
- Combine with `resolve-library-id` first to ensure correct library matching
- Useful for rapidly evolving frameworks (React, Next.js, etc.)
- Context7 supplements (not replaces) GAO Agent skill files

## References
- [Context7 GitHub](https://github.com/upstash/context7)
- [Context7 All Clients](https://context7.com/docs/resources/all-clients)
- [GAO Agent MCP Config Templates](../../mcp-configs/README.md)
