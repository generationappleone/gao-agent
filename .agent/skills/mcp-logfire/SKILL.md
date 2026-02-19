---
name: MCP Server — Logfire
description: MCP Server for Logfire — enables AI assistants to query application traces, logs, and metrics from Pydantic Logfire observability platform.
---

# MCP Server — Logfire

## Overview
Logfire MCP Server provides AI assistants with access to Pydantic Logfire's observability platform for querying traces, logs, and metrics from Python applications instrumented with OpenTelemetry.

## Tools Provided

| Tool | Description |
|------|-------------|
| `query_traces` | Query distributed traces |
| `query_logs` | Search application logs |
| `query_metrics` | Query time-series metrics |
| `list_projects` | List Logfire projects |
| `get_exceptions` | Get recent exceptions and errors |

## Configuration

```json
{
  "mcpServers": {
    "logfire": {
      "command": "npx",
      "args": ["-y", "logfire-mcp"],
      "env": {
        "LOGFIRE_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted application debugging
- Trace analysis for Python/FastAPI applications
- Error pattern detection and diagnosis
- Performance bottleneck identification
- Log aggregation and analysis
