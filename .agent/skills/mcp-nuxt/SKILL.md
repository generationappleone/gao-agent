---
name: MCP Server — Nuxt
description: MCP Server for Nuxt — enables AI assistants to manage Nuxt.js projects, inspect routes/pages, analyze components, access Nuxt DevTools, and streamline Vue/Nuxt development.
---

# MCP Server — Nuxt

## Overview
Nuxt MCP Server provides AI assistants with Nuxt.js project intelligence — including route inspection, component analysis, module discovery, and DevTools access for streamlined Vue/Nuxt development.

## Tools Provided

| Tool | Description |
|------|-------------|
| `get_routes` | List all app routes with metadata |
| `get_pages` | List pages directory structure |
| `get_components` | List all auto-imported components |
| `get_composables` | List available composables |
| `get_modules` | List installed Nuxt modules |
| `get_config` | Get Nuxt configuration |
| `get_layouts` | List available layouts |
| `get_middleware` | List middleware definitions |
| `get_plugins` | List registered plugins |
| `get_server_routes` | List server API routes |

## Configuration

```json
{
  "mcpServers": {
    "nuxt": {
      "command": "npx",
      "args": ["-y", "nuxt-mcp"],
      "env": {
        "NUXT_PROJECT_DIR": "/path/to/nuxt/project"
      }
    }
  }
}
```

## Use Cases
- Understanding Nuxt project structure for AI code generation
- Route and API endpoint discovery
- Component and composable documentation
- Nuxt module integration guidance
- Configuration analysis and optimization
