---
name: MCP Server — Dynatrace
description: MCP Server for Dynatrace — enables AI assistants to query application performance, analyze traces, view problems, manage dashboards, and monitor infrastructure through Dynatrace APM.
---

# MCP Server — Dynatrace

## Overview
Dynatrace MCP Server provides AI assistants with access to Dynatrace's full-stack monitoring platform including application performance monitoring (APM), infrastructure monitoring, and AI-powered root cause analysis.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_problems` | List detected problems |
| `get_problem` | Get problem details with root cause |
| `query_metrics` | Query time-series metrics |
| `list_entities` | List monitored entities (hosts, services, apps) |
| `get_entity` | Get entity details and relationships |
| `query_logs` | Search and analyze logs |
| `list_synthetic_monitors` | List synthetic monitors |
| `get_traces` | Query distributed traces |
| `get_dashboard` | Get dashboard configuration |
| `execute_dql` | Execute Dynatrace Query Language (DQL) |

## Configuration

```json
{
  "mcpServers": {
    "dynatrace": {
      "command": "npx",
      "args": ["-y", "@dynatrace/mcp-server"],
      "env": {
        "DYNATRACE_URL": "https://your-env.live.dynatrace.com",
        "DYNATRACE_API_TOKEN": "dt0c01...."
      }
    }
  }
}
```

### Dynatrace Managed
```json
{
  "mcpServers": {
    "dynatrace-managed": {
      "command": "npx",
      "args": ["-y", "@dynatrace/mcp-server"],
      "env": {
        "DYNATRACE_URL": "https://your-managed-instance/e/your-env-id",
        "DYNATRACE_API_TOKEN": "dt0c01...."
      }
    }
  }
}
```

## Use Cases
- AI-assisted performance troubleshooting
- Root cause analysis with Davis AI integration
- Infrastructure and application monitoring
- SLO/SLA compliance monitoring
- Distributed trace analysis
- Capacity planning and optimization
