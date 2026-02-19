---
name: MCP Server — Clarity
description: MCP Server for Microsoft Clarity — enables AI assistants to access user behavior analytics, heatmaps, session recordings, and UX insights from Clarity.
---

# MCP Server — Microsoft Clarity

## Overview
Microsoft Clarity MCP Server provides AI assistants with access to Clarity's user behavior analytics platform including heatmaps, session recordings, and user interaction insights.

## Tools Provided

| Tool | Description |
|------|-------------|
| `get_dashboard` | Get Clarity dashboard metrics |
| `get_heatmaps` | Get heatmap data for pages |
| `list_recordings` | List session recordings |
| `get_insights` | Get smart insights and anomalies |
| `get_rage_clicks` | Get rage click data |
| `get_dead_clicks` | Get dead click data |
| `get_scroll_depth` | Get scroll depth analytics |

## Configuration

```json
{
  "mcpServers": {
    "clarity": {
      "command": "npx",
      "args": ["-y", "@microsoft/clarity-mcp"],
      "env": {
        "CLARITY_PROJECT_ID": "...",
        "CLARITY_API_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- UX analysis from user behavior data
- Identifying usability issues (rage clicks, dead clicks)
- Scroll depth optimization
- Session replay analysis for bug reproduction
- Data-driven UI/UX improvement recommendations
