---
name: MCP Server — Webflow
description: MCP Server for Webflow — enables AI assistants to manage Webflow sites, CMS collections, pages, and design elements through Webflow's API.
---

# MCP Server — Webflow

## Overview
Webflow MCP Server provides AI assistants with access to Webflow's visual web development platform for site management, CMS operations, and content publishing.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_sites` | List Webflow sites |
| `get_site` | Get site details |
| `list_collections` | List CMS collections |
| `list_items` | List items in a CMS collection |
| `create_item` | Create a CMS collection item |
| `update_item` | Update a CMS item |
| `publish_site` | Publish site to production |
| `list_pages` | List site pages |
| `get_page` | Get page content and metadata |
| `list_domains` | List configured domains |

## Configuration

```json
{
  "mcpServers": {
    "webflow": {
      "command": "npx",
      "args": ["-y", "webflow-mcp-server"],
      "env": {
        "WEBFLOW_API_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted CMS content management
- Bulk content creation and updates
- Site publishing automation
- Content migration workflows
- SEO metadata management
