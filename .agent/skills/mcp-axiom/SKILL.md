---
name: MCP Server — Axiom
description: MCP Server for Axiom — enables AI assistants to query logs, traces, and metrics from Axiom's observability platform using APL (Axiom Processing Language).
---

# MCP Server — Axiom

## Overview
Axiom MCP Server provides AI assistants with access to Axiom's cloud-native observability platform for querying logs, traces, and metrics using APL (Axiom Processing Language).

## Tools Provided

| Tool | Description |
|------|-------------|
| `query` | Execute APL queries against datasets |
| `list_datasets` | List available datasets |
| `get_dataset` | Get dataset schema and info |
| `ingest` | Ingest data into a dataset |
| `get_virtual_fields` | List virtual fields |

## Configuration

```json
{
  "mcpServers": {
    "axiom": {
      "command": "npx",
      "args": ["-y", "@axiomhq/mcp-server"],
      "env": {
        "AXIOM_TOKEN": "xaat-...",
        "AXIOM_ORG_ID": "..."
      }
    }
  }
}
```

## Use Cases
- Natural language log analysis
- APL query generation from questions
- Observability data exploration
- Incident investigation with trace analysis
- Metrics monitoring and anomaly detection
