---
name: MCP Server — Microsoft Sentinel
description: MCP Server for Microsoft Sentinel — enables AI assistants to explore security data, query incidents, analyze threats, and manage SIEM operations in Microsoft Sentinel.
---

# MCP Server — Microsoft Sentinel

## Overview
Microsoft Sentinel MCP Server provides AI assistants with access to Microsoft Sentinel's cloud-native SIEM platform for security data exploration, incident management, and threat analysis.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_incidents` | List security incidents |
| `get_incident` | Get incident details with alerts |
| `query_logs` | Execute KQL queries against Sentinel data |
| `list_analytics_rules` | List detection rules |
| `list_threat_indicators` | List threat intelligence indicators |
| `get_entities` | Get related entities for an incident |
| `list_watchlists` | List security watchlists |
| `run_hunting_query` | Execute a threat hunting query |

## Configuration

```json
{
  "mcpServers": {
    "sentinel": {
      "command": "npx",
      "args": ["-y", "@microsoft/sentinel-mcp"],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "...",
        "AZURE_RESOURCE_GROUP": "...",
        "AZURE_WORKSPACE_NAME": "...",
        "AZURE_TENANT_ID": "...",
        "AZURE_CLIENT_ID": "...",
        "AZURE_CLIENT_SECRET": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted security incident investigation
- KQL query generation for threat hunting
- Security data exploration and analysis
- Threat intelligence integration
- Incident response automation
- Detection rule management
