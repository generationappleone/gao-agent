---
name: MCP Server — Amplitude
description: MCP Server for Amplitude — enables AI assistants to query product analytics, user behavior, funnel analysis, and cohort data from Amplitude.
---

# MCP Server — Amplitude

## Overview
Amplitude MCP Server provides AI assistants with access to Amplitude's product analytics platform for user behavior analysis, funnel insights, retention metrics, and event analytics.

## Tools Provided

| Tool | Description |
|------|-------------|
| `query_events` | Query event data |
| `get_funnel` | Get funnel conversion data |
| `get_retention` | Get user retention metrics |
| `get_cohort` | Get cohort analysis data |
| `get_user_activity` | Get individual user activity |
| `search_events` | Search event types |
| `get_daily_active_users` | Get DAU/WAU/MAU metrics |

## Configuration

```json
{
  "mcpServers": {
    "amplitude": {
      "command": "npx",
      "args": ["-y", "@amplitude/mcp-server"],
      "env": {
        "AMPLITUDE_API_KEY": "...",
        "AMPLITUDE_SECRET_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- Product analytics exploration with natural language
- Funnel analysis and conversion optimization
- User retention analysis
- Feature adoption tracking
- User behavior pattern discovery
