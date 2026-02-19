---
name: MCP Server — pgEdge
description: MCP Server for pgEdge — enables AI assistants to manage pgEdge distributed PostgreSQL clusters, execute queries, and handle multi-master replication.
---

# MCP Server — pgEdge

## Overview
pgEdge MCP Server provides AI assistants with access to pgEdge's distributed PostgreSQL platform for multi-master replication management, SQL execution, and cluster operations.

## Tools Provided

| Tool | Description |
|------|-------------|
| `execute_sql` | Execute SQL queries on pgEdge cluster |
| `list_clusters` | List pgEdge clusters |
| `get_cluster` | Get cluster configuration and status |
| `list_nodes` | List cluster nodes |
| `get_replication_status` | Check replication lag and sync status |
| `list_databases` | List databases |
| `get_schema` | Get table schema |

## Configuration

```json
{
  "mcpServers": {
    "pgedge": {
      "command": "npx",
      "args": ["-y", "@pgedge/mcp-server"],
      "env": {
        "PGEDGE_API_KEY": "...",
        "PGEDGE_BASE_URL": "https://api.pgedge.com"
      }
    }
  }
}
```

## Use Cases
- Distributed PostgreSQL cluster management
- Multi-master replication monitoring
- SQL query execution and optimization
- Schema management across distributed nodes
- Cluster health and replication lag analysis
