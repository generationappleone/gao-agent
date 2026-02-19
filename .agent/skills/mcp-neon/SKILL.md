---
name: MCP Server — Neon
description: MCP Server for Neon — enables AI assistants to manage Neon serverless PostgreSQL databases, branches, execute SQL, and manage database schemas.
---

# MCP Server — Neon

## Overview
Neon MCP Server provides AI assistants with access to Neon's serverless PostgreSQL platform, enabling database management, branching, SQL execution, and schema operations.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_projects` | List Neon projects |
| `create_project` | Create a new Neon project |
| `list_branches` | List database branches |
| `create_branch` | Create a branch (instant copy) |
| `execute_sql` | Run SQL queries |
| `get_schema` | Get database schema |
| `list_databases` | List databases in a project |
| `list_roles` | List database roles |
| `get_connection_uri` | Get connection string |

## Configuration

```json
{
  "mcpServers": {
    "neon": {
      "command": "npx",
      "args": ["-y", "@neondatabase/mcp-server-neon"],
      "env": {
        "NEON_API_KEY": "..."
      }
    }
  }
}
```

## Key Features
- **Database branching**: Instant point-in-time copies for development/testing
- **Serverless**: Auto-scales to zero, no idle costs
- **SQL execution**: Direct SQL queries through the MCP interface

## Use Cases
- AI-assisted serverless PostgreSQL management
- Database schema design and migration
- Development branch creation for testing
- SQL query generation and optimization
- Database provisioning for new projects
