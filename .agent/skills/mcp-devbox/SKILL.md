---
name: MCP Server — Dev Box
description: MCP Server for Microsoft Dev Box — enables AI assistants to manage cloud-based developer workstations, provision dev environments, and configure development boxes.
---

# MCP Server — Microsoft Dev Box

## Overview
Microsoft Dev Box MCP Server provides AI assistants with access to Azure Dev Box for managing cloud-based development workstations, provisioning developer environments, and managing dev box pools.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_dev_boxes` | List developer workstations |
| `create_dev_box` | Provision a new dev box |
| `start_dev_box` | Start a dev box |
| `stop_dev_box` | Stop a dev box |
| `delete_dev_box` | Delete a dev box |
| `list_pools` | List available dev box pools |
| `list_projects` | List Dev Center projects |
| `get_dev_box` | Get dev box details and status |

## Configuration

```json
{
  "mcpServers": {
    "devbox": {
      "command": "npx",
      "args": ["-y", "@microsoft/devbox-mcp"],
      "env": {
        "AZURE_TENANT_ID": "...",
        "AZURE_CLIENT_ID": "...",
        "AZURE_CLIENT_SECRET": "...",
        "AZURE_DEV_CENTER": "your-dev-center"
      }
    }
  }
}
```

## Use Cases
- Developer workstation provisioning
- Dev environment lifecycle management
- On-demand development environments
- Team dev box management
- Environment standardization
