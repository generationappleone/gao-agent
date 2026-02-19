---
name: MCP Server — PagerDuty
description: MCP Server for PagerDuty — enables AI assistants to manage incidents, on-call schedules, services, and escalation policies in PagerDuty.
---

# MCP Server — PagerDuty

## Overview
PagerDuty MCP Server provides AI assistants with access to PagerDuty's incident management platform for incident response, on-call management, and service health monitoring.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_incidents` | List incidents with filters |
| `create_incident` | Create a new incident |
| `update_incident` | Update incident status/priority |
| `acknowledge_incident` | Acknowledge an incident |
| `resolve_incident` | Resolve an incident |
| `list_services` | List monitored services |
| `list_on_calls` | Get current on-call schedules |
| `list_escalation_policies` | List escalation policies |
| `add_note` | Add a note to an incident |

## Configuration

```json
{
  "mcpServers": {
    "pagerduty": {
      "command": "npx",
      "args": ["-y", "@pagerduty/mcp-server"],
      "env": {
        "PAGERDUTY_API_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted incident response and triage
- On-call schedule management
- Incident status updates and communication
- Service health overview
- Escalation policy configuration
