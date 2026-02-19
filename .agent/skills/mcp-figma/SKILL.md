---
name: MCP Server — Figma
description: MCP Server for Figma — enables AI assistants to access Figma design files, inspect components, extract design tokens, and translate designs to code.
---

# MCP Server — Figma

## Overview
Figma MCP Server provides AI assistants with access to Figma design files, enabling design inspection, component analysis, design token extraction, and design-to-code workflows.

## Tools Provided

| Tool | Description |
|------|-------------|
| `get_file` | Get a Figma file structure |
| `get_node` | Get a specific node (frame, component, etc.) |
| `get_components` | List components in a file |
| `get_styles` | Get color, text, and effect styles |
| `get_images` | Export nodes as images |
| `get_comments` | List comments on a file |
| `get_component_sets` | Get component variant sets |
| `search_nodes` | Search for nodes by name |

## Configuration

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "figma-mcp-server"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "figd_..."
      }
    }
  }
}
```

## Use Cases
- Design-to-code translation with accurate specs
- Design token extraction for design systems
- Component inventory and documentation
- Design review and feedback automation
- Style guide generation from Figma files
- Responsive breakpoint analysis
