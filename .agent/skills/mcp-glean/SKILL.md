---
name: MCP Server — Glean
description: MCP Server for Glean — enables AI assistants to search across enterprise knowledge, including documents, conversations, and internal tools via Glean's unified search platform.
---

# MCP Server — Glean

## Overview
Glean MCP Server provides AI assistants with access to Glean's enterprise search platform, enabling unified search across all connected enterprise tools and knowledge sources.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search` | Search across all connected enterprise sources |
| `get_document` | Retrieve a specific document |
| `list_datasources` | List connected data sources |
| `ask` | Ask a question with AI-powered answers |

## Configuration

```json
{
  "mcpServers": {
    "glean": {
      "command": "npx",
      "args": ["-y", "@glean/mcp-server"],
      "env": {
        "GLEAN_API_TOKEN": "...",
        "GLEAN_INSTANCE": "your-company.glean.com"
      }
    }
  }
}
```

## Connected Sources
Glean indexes content from: Google Drive, Slack, Confluence, Jira, GitHub, Notion, Salesforce, SharePoint, and 100+ more enterprise tools.

## Use Cases
- Enterprise knowledge retrieval for AI assistants
- Cross-tool information discovery
- Internal documentation search
- Contextual answers from company knowledge
