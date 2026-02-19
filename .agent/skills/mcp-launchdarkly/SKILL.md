---
name: MCP Server — LaunchDarkly
description: MCP Server for LaunchDarkly — enables AI assistants to manage feature flags, targeting rules, environments, and feature flag lifecycle across applications.
---

# MCP Server — LaunchDarkly

## Overview
LaunchDarkly MCP Server provides AI assistants with access to LaunchDarkly's feature flag management platform for creating, updating, and managing feature flags and targeting rules.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_flags` | List feature flags |
| `get_flag` | Get flag details and targeting rules |
| `create_flag` | Create a new feature flag |
| `update_flag` | Update flag settings |
| `toggle_flag` | Enable/disable a flag |
| `add_targeting_rule` | Add a targeting rule |
| `list_environments` | List environments |
| `list_projects` | List projects |
| `get_flag_status` | Get flag evaluation status |

## Configuration

```json
{
  "mcpServers": {
    "launchdarkly": {
      "command": "npx",
      "args": ["-y", "@launchdarkly/mcp-server"],
      "env": {
        "LAUNCHDARKLY_API_KEY": "api-..."
      }
    }
  }
}
```

## Use Cases
- Feature flag lifecycle management
- Targeting rule configuration
- Rollout strategy automation
- Feature experiment management
- Kill switch management for incidents
