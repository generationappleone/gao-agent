---
name: MCP Server — Postman
description: MCP Server for Postman — enables AI assistants to manage collections, execute API requests, run tests, manage environments, and interact with the Postman API platform.
---

# MCP Server — Postman

## Overview
Postman MCP Server provides AI assistants with access to Postman's API development platform, enabling collection management, API request execution, test running, and environment configuration.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_collections` | List Postman collections |
| `get_collection` | Get collection with requests and tests |
| `run_collection` | Execute a collection (like Newman) |
| `send_request` | Send a single API request |
| `list_environments` | List environments |
| `get_environment` | Get environment variables |
| `create_collection` | Create a new collection |
| `create_request` | Add a request to a collection |
| `list_workspaces` | List workspaces |

## Configuration

```json
{
  "mcpServers": {
    "postman": {
      "command": "npx",
      "args": ["-y", "@postman/mcp-server"],
      "env": {
        "POSTMAN_API_KEY": "PMAK-..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted API testing and debugging
- Collection generation from API specifications
- Automated API regression testing
- Environment-specific variable management
- API documentation from collections
