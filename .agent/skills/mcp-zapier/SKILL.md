---
name: MCP Server — Zapier
description: MCP Server for Zapier — enables AI assistants to create automations (Zaps), trigger workflows, and connect 6,000+ apps through Zapier's automation platform.
---

# MCP Server — Zapier

## Overview
Zapier MCP Server provides AI assistants with access to Zapier's automation platform, enabling workflow creation, trigger management, and integration of 6,000+ connected applications.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_zaps` | List active Zaps |
| `create_zap` | Create a new automation |
| `trigger_zap` | Manually trigger a Zap |
| `list_apps` | List available connected apps |
| `list_actions` | List available actions for an app |
| `get_zap_history` | Get Zap execution history |
| `enable_zap` | Enable a Zap |
| `disable_zap` | Disable a Zap |

## Configuration

```json
{
  "mcpServers": {
    "zapier": {
      "command": "npx",
      "args": ["-y", "@zapier/mcp-server"],
      "env": {
        "ZAPIER_API_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted workflow automation design
- Cross-application integration management
- Automation monitoring and troubleshooting
- Workflow optimization recommendations
- No-code automation configuration
