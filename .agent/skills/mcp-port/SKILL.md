---
name: MCP Server — Port
description: MCP Server for Port — enables AI assistants to manage the internal developer portal, service catalog, scorecards, and developer experience metrics in Port.
---

# MCP Server — Port

## Overview
Port MCP Server provides AI assistants with access to Port's internal developer portal for managing service catalogs, scorecards, and developer platform operations.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_blueprints` | List Port blueprints (entity types) |
| `list_entities` | List entities (services, environments, etc.) |
| `create_entity` | Create a new entity |
| `update_entity` | Update entity properties |
| `get_scorecard` | Get scorecard results |
| `run_action` | Execute a self-service action |
| `search` | Search across the catalog |

## Configuration

```json
{
  "mcpServers": {
    "port": {
      "command": "npx",
      "args": ["-y", "@port-labs/mcp-server"],
      "env": {
        "PORT_CLIENT_ID": "...",
        "PORT_CLIENT_SECRET": "..."
      }
    }
  }
}
```

## Use Cases
- Service catalog management
- Developer portal administration
- Scorecard and maturity assessment
- Self-service action execution
- Software catalog documentation
