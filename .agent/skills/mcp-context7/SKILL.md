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

### Local Server Connection (Default — No API Key Required)

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

> **This is the default mode.** Works out-of-the-box without any API key. Rate limits are IP-based.

### Remote Server Connection (Optional — Higher Rate Limits)

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

> Get a free API key at [context7.com/dashboard](https://context7.com/dashboard) for higher rate limits and priority access.

### REST API (Direct HTTP — Requires API Key)

For scripts, CI/CD, and programmatic usage. See [Context7 REST API v2](#context7-rest-api-v2) section below.

```bash
curl -X GET "https://context7.com/api/v2/libs/search?libraryName=next.js&query=setup" \
  -H "Authorization: Bearer CONTEXT7_API_KEY"
```

## GAO Agent Integration

### Quick Setup

1. Browse templates in `.agent/mcp-configs/templates/`
2. Find the template matching your AI client (see table below)
3. Copy to the correct location for your client
4. **Done!** — Templates use Local Mode by default (no API key needed)
5. *(Optional)* Add `--api-key YOUR_KEY` for higher rate limits
6. Validate with `/context-mcp-check context7`

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

### Environment Variable (for REST API)

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
- Use MCP transport for interactive AI sessions; use REST API for scripts, CI/CD, or when MCP is unavailable

---

## Context7 REST API v2

> **When to use the REST API instead of MCP:**
> - When building scripts, CI/CD pipelines, or automation tools
> - When the MCP transport is not available in your environment
> - When you need programmatic access to library documentation
> - When integrating Context7 into custom applications

### Authentication

All REST API calls require an API key from [context7.com/dashboard](https://context7.com/dashboard):

```
Authorization: Bearer CONTEXT7_API_KEY
```

### Endpoint 1: Search Libraries

Search for libraries and get their Context7-compatible IDs.

```
GET https://context7.com/api/v2/libs/search
```

**Parameters:**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| `libraryName` | Yes | string | Library name to search for (e.g., `next.js`, `react`, `laravel`) |
| `query` | No | string | User query to rank results by relevance |

**Example Request:**

```bash
curl -X GET "https://context7.com/api/v2/libs/search?libraryName=next.js&query=setup+ssr" \
  -H "Authorization: Bearer CONTEXT7_API_KEY"
```

**Example Response:**

```json
{
  "results": [
    {
      "id": "/vercel/next.js",
      "title": "Next.js",
      "description": "Next.js enables you to create full-stack web...",
      "branch": "canary",
      "lastUpdateDate": "2025-11-17T22:20:15.784Z",
      "state": "finalized",
      "totalTokens": 824953,
      "totalSnippets": 3336,
      "stars": 131745,
      "trustScore": 10,
      "benchmarkScore": 91.1,
      "versions": ["v14.3.0-canary.87", "v13.5.11", "v15.1.8"]
    }
  ]
}
```

### Endpoint 2: Get Context / Documentation

Fetch up-to-date, LLM-reranked documentation for a specific library.

```
GET https://context7.com/api/v2/context
```

**Parameters:**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| `libraryId` | Yes | string | Context7-compatible library ID (e.g., `/vercel/next.js`) |
| `query` | Yes | string | Natural language question or task |
| `type` | No | enum | Response format: `json` or `txt` (default: `txt`) |

**Example Request:**

```bash
curl -X GET "https://context7.com/api/v2/context?libraryId=/vercel/next.js&query=middleware+authentication&type=json" \
  -H "Authorization: Bearer CONTEXT7_API_KEY"
```

**Example Response (JSON format):**

```json
{
  "codeSnippets": [
    {
      "codeTitle": "Middleware Example",
      "codeDescription": "Next.js middleware for authentication",
      "codeLanguage": "typescript",
      "codeTokens": 150,
      "codeId": "https://nextjs.org/docs/app/building/middleware",
      "pageTitle": "Middleware - Next.js",
      "codeList": [
        {
          "language": "typescript",
          "code": "import { NextResponse } from 'next/server'..."
        }
      ]
    }
  ],
  "infoSnippets": [
    {
      "pageId": "https://nextjs.org/docs/app/building/middleware",
      "breadcrumb": "Docs > App Router > Building > Middleware",
      "content": "Middleware allows you to run code before a request...",
      "contentTokens": 200
    }
  ]
}
```

### REST API Usage in GAO Agent Workflows

GAO Agent can use the REST API directly within workflows and scripts:

**PowerShell (Windows):**

```powershell
# Search for a library
$headers = @{ "Authorization" = "Bearer $env:CONTEXT7_API_KEY" }
$response = Invoke-RestMethod -Uri "https://context7.com/api/v2/libs/search?libraryName=react&query=hooks" -Headers $headers
$response.results | Select-Object id, title, stars

# Fetch documentation
$docs = Invoke-RestMethod -Uri "https://context7.com/api/v2/context?libraryId=/facebook/react&query=useEffect+cleanup&type=json" -Headers $headers
$docs.codeSnippets | ForEach-Object { $_.codeTitle }
```

**Bash / curl:**

```bash
# Search for a library
curl -s "https://context7.com/api/v2/libs/search?libraryName=laravel&query=eloquent" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY" | jq '.results[].id'

# Fetch documentation
curl -s "https://context7.com/api/v2/context?libraryId=/laravel/docs&query=middleware&type=txt" \
  -H "Authorization: Bearer $CONTEXT7_API_KEY"
```

**Node.js (fetch):**

```javascript
const API_KEY = process.env.CONTEXT7_API_KEY;
const headers = { 'Authorization': `Bearer ${API_KEY}` };

// Search
const search = await fetch(
  'https://context7.com/api/v2/libs/search?libraryName=prisma&query=migrations',
  { headers }
);
const { results } = await search.json();

// Get docs
const docs = await fetch(
  `https://context7.com/api/v2/context?libraryId=${results[0].id}&query=schema+design&type=json`,
  { headers }
);
const { codeSnippets, infoSnippets } = await docs.json();
```

### MCP vs REST API — Comparison

| Feature | MCP Transport | REST API |
|---------|--------------|----------|
| **Setup** | Config file + restart IDE | API key + HTTP call |
| **API Key Required** | No (local mode) | Yes (always) |
| **Best For** | Interactive AI coding sessions | Scripts, CI/CD, automation |
| **Rate Limits** | IP-based (free) or API key | API key required |
| **Response** | Streamed via MCP protocol | JSON or plain text |
| **GAO Agent Support** | `.mcp.json` + 24 templates | Direct HTTP calls in workflows |

## References
- [Context7 GitHub](https://github.com/upstash/context7)
- [Context7 All Clients](https://context7.com/docs/resources/all-clients)
- [Context7 API Documentation](https://context7.com/docs)
- [GAO Agent MCP Config Templates](../../mcp-configs/README.md)
