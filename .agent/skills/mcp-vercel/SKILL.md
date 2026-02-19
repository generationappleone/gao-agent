---
name: MCP Server — Vercel
description: MCP Server for Vercel — enables AI assistants to manage Vercel deployments, projects, domains, environment variables, serverless functions, and Next.js dev tools.
---

# MCP Server — Vercel

## Overview
Vercel MCP Server provides AI assistants with access to Vercel's deployment platform, including project management, deployment workflows, domain configuration, and Next.js development tools.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_projects` | List Vercel projects |
| `get_project` | Get project details and settings |
| `list_deployments` | List deployments with status |
| `get_deployment` | Get deployment details and logs |
| `create_deployment` | Trigger a new deployment |
| `list_domains` | List configured domains |
| `add_domain` | Add a domain to a project |
| `list_env_vars` | List environment variables |
| `set_env_var` | Set an environment variable |
| `get_deployment_logs` | Get build and runtime logs |
| `rollback_deployment` | Rollback to a previous deployment |

## Configuration

```json
{
  "mcpServers": {
    "vercel": {
      "command": "npx",
      "args": ["-y", "@vercel/mcp"],
      "env": {
        "VERCEL_TOKEN": "..."
      }
    }
  }
}
```

### Next.js Dev Tools
```json
{
  "mcpServers": {
    "vercel-next-dev": {
      "command": "npx",
      "args": ["-y", "@vercel/next-dev-tools-mcp"],
      "env": {}
    }
  }
}
```

## Use Cases
- AI-assisted deployment management
- Environment variable configuration across environments
- Domain setup and DNS management
- Deployment troubleshooting with build logs
- Next.js development workflow optimization
- Rollback management for production issues
