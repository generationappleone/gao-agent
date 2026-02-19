---
name: MCP Server — HoloModular ServiceBricks
description: MCP Server for HoloModular ServiceBricks — enables AI assistants to manage microservice building blocks, API gateways, and modular service architectures.
---

# MCP Server — HoloModular ServiceBricks

## Overview
HoloModular ServiceBricks MCP Server provides AI assistants with access to the ServiceBricks microservice framework for managing modular service components, API configurations, and service architectures.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_services` | List available service bricks |
| `get_service` | Get service configuration |
| `create_service` | Create a new service brick |
| `configure_service` | Update service configuration |
| `list_apis` | List API endpoints |
| `get_health` | Get service health status |

## Configuration

```json
{
  "mcpServers": {
    "servicebricks": {
      "command": "npx",
      "args": ["-y", "servicebricks-mcp"],
      "env": {
        "SERVICEBRICKS_URL": "...",
        "SERVICEBRICKS_API_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- Microservice architecture management
- Service brick composition and configuration
- API gateway management
- Service health monitoring
- Modular application scaffolding
