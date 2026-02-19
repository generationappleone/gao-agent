---
name: MCP Server — UI5
description: MCP Server for SAP UI5 — enables AI assistants to access UI5 documentation, generate UI5 components, and develop SAP Fiori applications with correct API patterns.
---

# MCP Server — SAP UI5

## Overview
UI5 MCP Server provides AI assistants with access to SAP UI5/SAPUI5 framework documentation, component patterns, and best practices for building SAP Fiori applications.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search_api` | Search UI5 API documentation |
| `get_control` | Get control documentation and properties |
| `get_patterns` | Get Fiori design patterns |
| `list_libraries` | List available UI5 libraries |
| `get_sample` | Get code samples for components |

## Configuration

```json
{
  "mcpServers": {
    "ui5": {
      "command": "npx",
      "args": ["-y", "@sap/ui5-mcp-server"],
      "env": {}
    }
  }
}
```

## Use Cases
- SAP Fiori application development with correct patterns
- UI5 control and component guidance
- API documentation lookup during development
- Fiori design guideline compliance
- Migration from older UI5 versions
