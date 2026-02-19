---
name: MCP Server — Intercom
description: MCP Server for Intercom — enables AI assistants to manage conversations, contacts, articles, and customer support workflows in Intercom.
---

# MCP Server — Intercom

## Overview
Intercom MCP Server provides AI assistants with access to Intercom's customer messaging platform for conversation management, contact operations, and help center content.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_conversations` | List support conversations |
| `get_conversation` | Get conversation with messages |
| `reply_to_conversation` | Reply to a conversation |
| `list_contacts` | List contacts/customers |
| `create_contact` | Create a new contact |
| `search_contacts` | Search contacts by attributes |
| `list_articles` | List help center articles |
| `create_article` | Create a help center article |
| `list_tags` | List tags |
| `tag_conversation` | Tag a conversation |

## Configuration

```json
{
  "mcpServers": {
    "intercom": {
      "command": "npx",
      "args": ["-y", "@intercom/mcp-server"],
      "env": {
        "INTERCOM_ACCESS_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- Customer support automation
- Conversation triage and routing
- Help center content management
- Contact data enrichment
- Support analytics and reporting
