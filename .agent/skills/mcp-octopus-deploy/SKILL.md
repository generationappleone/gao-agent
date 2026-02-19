---
name: MCP Server — Octopus Deploy
description: MCP Server for Octopus Deploy — enables AI assistants to manage deployments, releases, environments, projects, and deployment pipelines in Octopus Deploy.
---

# MCP Server — Octopus Deploy

## Overview
Octopus Deploy MCP Server provides AI assistants with access to Octopus Deploy's release management and continuous deployment platform.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_projects` | List Octopus projects |
| `list_environments` | List deployment environments |
| `list_releases` | List releases for a project |
| `create_release` | Create a new release |
| `deploy_release` | Deploy a release to an environment |
| `get_deployment` | Get deployment status and logs |
| `list_machines` | List deployment targets |
| `list_tenants` | List tenants (multi-tenant deployments) |
| `get_task` | Get task execution details |
| `list_spaces` | List Octopus spaces |

## Configuration

```json
{
  "mcpServers": {
    "octopus-deploy": {
      "command": "npx",
      "args": ["-y", "@octopusdeploy/mcp-server"],
      "env": {
        "OCTOPUS_URL": "https://your-octopus-instance.com",
        "OCTOPUS_API_KEY": "API-..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted release management
- Deployment pipeline monitoring
- Environment configuration management
- Multi-tenant deployment coordination
- Deployment troubleshooting with log analysis
