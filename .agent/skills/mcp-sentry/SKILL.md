---
name: MCP Server — Sentry
description: MCP Server for Sentry — enables AI assistants to query errors, analyze stack traces, manage issues, view performance data, and troubleshoot application errors in Sentry.
---

# MCP Server — Sentry

## Overview
Sentry MCP Server provides AI assistants with access to Sentry's error tracking and performance monitoring platform, enabling automated error analysis, root cause identification, and issue management.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_issues` | List issues with filters (status, level, query) |
| `get_issue` | Get issue details with events and stack traces |
| `resolve_issue` | Resolve an issue |
| `list_events` | List error events for an issue |
| `get_event` | Get event details with full stack trace |
| `list_projects` | List Sentry projects |
| `get_project` | Get project settings and stats |
| `search_errors` | Search errors across projects |
| `list_releases` | List releases with deploy info |
| `get_performance` | Get performance metrics (transactions) |

## Configuration

```json
{
  "mcpServers": {
    "sentry": {
      "command": "npx",
      "args": ["-y", "@sentry/mcp-server-sentry"],
      "env": {
        "SENTRY_AUTH_TOKEN": "sntrys_...",
        "SENTRY_ORG": "your-org"
      }
    }
  }
}
```

## Use Cases
- AI-assisted error diagnosis and root cause analysis
- Automated stack trace analysis with fix suggestions
- Issue triage and prioritization
- Performance regression detection
- Release quality monitoring
- Error trend analysis and reporting
