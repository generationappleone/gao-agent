---
name: MCP Server — Supabase
description: MCP Server for Supabase — enables AI assistants to manage Supabase projects, execute SQL, manage database schemas, handle auth, storage, and edge functions.
---

# MCP Server — Supabase

## Overview
Supabase MCP Server provides AI assistants with access to Supabase projects including database management, authentication, storage, and edge functions through a standardized MCP interface.

## Tools Provided

| Tool | Description |
|------|-------------|
| `execute_sql` | Execute SQL queries against the Supabase database |
| `list_tables` | List all tables in the database |
| `get_table_schema` | Get column definitions for a table |
| `create_table` | Create a new table with columns and constraints |
| `apply_migration` | Apply a SQL migration |
| `list_projects` | List Supabase projects |
| `get_project_info` | Get project details (URL, keys, status) |
| `manage_rls_policies` | Create/update Row Level Security policies |
| `list_edge_functions` | List deployed edge functions |
| `deploy_edge_function` | Deploy an edge function |
| `get_logs` | Retrieve project logs |

## Configuration

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "supabase-mcp-server"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "sbp_...",
        "SUPABASE_PROJECT_REF": "your-project-ref"
      }
    }
  }
}
```

## Use Cases
- AI-assisted database design and optimization
- Automated RLS policy generation from requirements
- Schema migration management
- Edge function development and deployment
- SQL query generation and optimization
- Project monitoring and log analysis
