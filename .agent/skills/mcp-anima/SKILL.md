---
name: MCP Server — Anima
description: MCP Server for Anima — enables AI assistants to convert designs to code, manage design-to-development workflows, and generate production-ready frontend code from design files.
---

# MCP Server — Anima

## Overview
Anima MCP Server provides AI assistants with design-to-code capabilities, converting Figma, Sketch, and Adobe XD designs into production-ready frontend code (React, Vue, HTML/CSS).

## Tools Provided

| Tool | Description |
|------|-------------|
| `convert_design` | Convert a design file to code |
| `get_project` | Get project details |
| `list_screens` | List design screens |
| `get_code` | Get generated code for a screen |
| `list_components` | List detected components |
| `get_design_tokens` | Extract design tokens |

## Configuration

```json
{
  "mcpServers": {
    "anima": {
      "command": "npx",
      "args": ["-y", "@animaapp/mcp-server"],
      "env": {
        "ANIMA_ACCESS_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- Design-to-React/Vue code generation
- Design token extraction from Figma
- Component-level code generation
- Frontend scaffolding from designs
- Design system documentation
