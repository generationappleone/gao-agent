---
name: MCP Server — Guru
description: MCP Server for Guru — enables AI assistants to search and access enterprise knowledge from Guru's knowledge management platform.
---

# MCP Server — Guru

## Overview
Guru MCP Server provides AI assistants with access to Guru's enterprise knowledge management platform for searching cards, boards, and verified knowledge content.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search` | Search Guru knowledge cards |
| `get_card` | Get a specific card's content |
| `list_boards` | List knowledge boards |
| `list_collections` | List card collections |
| `get_board` | Get board with cards |

## Configuration

```json
{
  "mcpServers": {
    "guru": {
      "command": "npx",
      "args": ["-y", "@getguru/mcp-server"],
      "env": {
        "GURU_API_TOKEN": "...",
        "GURU_EMAIL": "user@example.com"
      }
    }
  }
}
```

## Use Cases
- Enterprise knowledge retrieval
- Verified information lookup for AI responses
- Company wiki and procedure search
- Onboarding documentation access
- Internal SOPs and process documentation
