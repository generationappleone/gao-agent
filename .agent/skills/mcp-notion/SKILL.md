---
name: MCP Server — Notion
description: MCP Server for Notion — enables AI assistants to read, create, update, and query Notion pages, databases, and blocks with Markdown-optimized content conversion.
---

# MCP Server — Notion

## Overview
Notion MCP Server provides AI assistants with secure access to your Notion workspace. It converts content to Markdown format for efficient token usage and supports full CRUD operations on pages, databases, and blocks.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search` | Search pages and databases in the workspace |
| `get_page` | Retrieve page content as Markdown |
| `create_page` | Create a new page in a database or as a child page |
| `update_page` | Update page properties |
| `archive_page` | Archive (soft-delete) a page |
| `get_database` | Get database schema and properties |
| `query_database` | Query a database with filters and sorts |
| `create_database` | Create a new database |
| `append_blocks` | Append content blocks to a page |
| `get_blocks` | Retrieve child blocks of a page/block |
| `delete_block` | Delete a specific block |
| `get_comments` | Get comments on a page |
| `add_comment` | Add a comment to a page |

## Configuration

### Using NPM
```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_API_KEY": "ntn_..."
      }
    }
  }
}
```

### Using Official Hosted MCP (OAuth)
```json
{
  "mcpServers": {
    "notion": {
      "url": "https://mcp.notion.com/mcp",
      "transport": "sse"
    }
  }
}
```

## Setup Steps
1. Go to [Notion Developers](https://developers.notion.com/)
2. Create an Internal Integration
3. Copy the Integration Token (API Key)
4. Share target pages/databases with your integration
5. Configure MCP server with the token

## Use Cases
- AI-assisted knowledge base management
- Automated documentation creation and updates
- Project management automation (task tracking, status updates)
- Content migration and data entry
- Meeting notes to action items conversion
- Database-driven content generation
