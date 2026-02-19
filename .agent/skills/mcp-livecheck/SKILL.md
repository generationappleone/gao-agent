---
name: MCP Server — LiveCheck AI
description: MCP Server for LiveCheck AI — enables AI assistants to perform real-time website monitoring, uptime checks, and performance analysis.
---

# MCP Server — LiveCheck AI

## Overview
LiveCheck AI MCP Server provides AI assistants with real-time website monitoring capabilities including uptime checks, response time analysis, and availability alerting.

## Tools Provided

| Tool | Description |
|------|-------------|
| `check_url` | Perform a live health check on a URL |
| `get_uptime` | Get uptime statistics for a monitored site |
| `list_monitors` | List configured monitors |
| `create_monitor` | Create a new uptime monitor |
| `get_response_times` | Get response time metrics |
| `get_incidents` | List downtime incidents |

## Configuration

```json
{
  "mcpServers": {
    "livecheck": {
      "command": "npx",
      "args": ["-y", "livecheck-ai-mcp"],
      "env": {
        "LIVECHECK_API_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- Real-time website health monitoring
- Uptime verification and reporting
- Performance degradation detection
- Incident tracking and analysis
- SLA compliance monitoring
