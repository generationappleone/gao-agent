---
name: MCP Server — DBHub
description: MCP Server for DBHub — universal database gateway connecting AI assistants to MySQL, PostgreSQL, MariaDB, SQL Server, SQLite, and DuckDB through a unified MCP interface.
---

# MCP Server — DBHub

## Overview
DBHub MCP Server is a universal database gateway that provides a single, unified interface for AI assistants to connect to multiple database systems. It enables schema browsing, SQL query execution, and data exploration with built-in safety checks.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_tables` | List available tables in the connected database |
| `describe_table` | Get table schema (columns, types, constraints) |
| `query` | Execute read-only SQL queries |
| `get_sample_data` | Get sample rows from a table |

## Supported Databases
- MySQL
- PostgreSQL
- MariaDB
- SQL Server
- SQLite
- DuckDB

## Configuration

### PostgreSQL
```json
{
  "mcpServers": {
    "dbhub": {
      "command": "npx",
      "args": ["-y", "dbhub"],
      "env": {
        "DATABASE_URL": "postgresql://user:password@localhost:5432/mydb"
      }
    }
  }
}
```

### MySQL
```json
{
  "mcpServers": {
    "dbhub": {
      "command": "npx",
      "args": ["-y", "dbhub"],
      "env": {
        "DATABASE_URL": "mysql://user:password@localhost:3306/mydb"
      }
    }
  }
}
```

### SQLite
```json
{
  "mcpServers": {
    "dbhub": {
      "command": "npx",
      "args": ["-y", "dbhub"],
      "env": {
        "DATABASE_URL": "sqlite:///path/to/database.db"
      }
    }
  }
}
```

## Security
- **Read-only by default**: Safety checks prevent harmful write operations
- **Query validation**: Checks for potentially destructive SQL
- **Connection isolation**: Each session gets its own connection

## Use Cases
- AI-assisted database exploration and understanding
- Natural language to SQL query generation
- Schema documentation generation
- Data analysis and reporting
- Database migration planning
