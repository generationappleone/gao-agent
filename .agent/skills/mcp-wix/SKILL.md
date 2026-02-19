---
name: MCP Server — Wix
description: MCP Server for Wix — enables AI assistants to manage Wix sites, collections, pages, and CMS content through Wix's platform API.
---

# MCP Server — Wix

## Overview
Wix MCP Server provides AI assistants with access to Wix's website building platform for site management, CMS operations, and content management.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_sites` | List Wix sites |
| `get_site` | Get site details |
| `list_collections` | List CMS collections |
| `query_collection` | Query CMS collection items |
| `create_item` | Create a CMS item |
| `update_item` | Update a CMS item |
| `list_pages` | List site pages |
| `publish_site` | Publish site changes |

## Configuration

```json
{
  "mcpServers": {
    "wix": {
      "command": "npx",
      "args": ["-y", "@wix/mcp-server"],
      "env": {
        "WIX_API_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- CMS content management automation
- Bulk content updates across Wix sites
- Site configuration management
- E-commerce product management
- Content migration and synchronization
