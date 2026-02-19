---
name: MCP Server — Fabric Real-Time Intelligence
description: MCP Server for Microsoft Fabric Real-Time Intelligence — enables AI assistants to query real-time data streams, KQL databases, and eventhouses in Microsoft Fabric.
---

# MCP Server — Fabric Real-Time Intelligence

## Overview
Microsoft Fabric Real-Time Intelligence MCP Server provides AI assistants with access to real-time data analytics capabilities including KQL (Kusto Query Language) database queries, event stream analysis, and real-time dashboards.

## Tools Provided

| Tool | Description |
|------|-------------|
| `execute_kql` | Execute Kusto Query Language queries |
| `list_databases` | List KQL databases |
| `list_tables` | List tables in a KQL database |
| `get_schema` | Get table schema |
| `list_eventhouses` | List Eventhouses |
| `query_eventstream` | Query event stream data |

## Configuration

```json
{
  "mcpServers": {
    "fabric-rti": {
      "command": "npx",
      "args": ["-y", "@microsoft/fabric-rti-mcp"],
      "env": {
        "FABRIC_WORKSPACE_ID": "...",
        "AZURE_TENANT_ID": "...",
        "AZURE_CLIENT_ID": "...",
        "AZURE_CLIENT_SECRET": "..."
      }
    }
  }
}
```

## Use Cases
- Real-time data stream analysis
- KQL query generation from natural language
- IoT and telemetry data exploration
- Real-time anomaly detection
- Business intelligence on streaming data
