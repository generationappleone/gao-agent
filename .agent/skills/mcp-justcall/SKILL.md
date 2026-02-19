---
name: MCP Server — JustCall
description: MCP Server for JustCall — enables AI assistants to manage phone calls, SMS, contacts, and call analytics through JustCall's cloud telephony platform.
---

# MCP Server — JustCall

## Overview
JustCall MCP Server provides AI assistants with access to JustCall's cloud phone system for call management, SMS operations, contact management, and call analytics.

## Tools Provided

| Tool | Description |
|------|-------------|
| `make_call` | Initiate a phone call |
| `send_sms` | Send an SMS message |
| `list_calls` | List call history |
| `get_call` | Get call details and recording |
| `list_contacts` | List contacts |
| `create_contact` | Create a new contact |
| `list_sms` | List SMS history |
| `get_analytics` | Get call analytics and metrics |

## Configuration

```json
{
  "mcpServers": {
    "justcall": {
      "command": "npx",
      "args": ["-y", "@justcall/mcp-server"],
      "env": {
        "JUSTCALL_API_KEY": "...",
        "JUSTCALL_API_SECRET": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted call management and logging
- Automated SMS campaigns
- Contact management and CRM integration
- Call analytics and reporting
- Communication workflow automation
