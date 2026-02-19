---
name: MCP Server — ARM
description: MCP Server for ARM — enables AI assistants to access ARM architecture documentation, instruction sets, and development resources for embedded and IoT development.
---

# MCP Server — ARM

## Overview
ARM MCP Server provides AI assistants with access to ARM architecture documentation, instruction set references, and development resources for embedded systems, IoT, and mobile processor development.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search_docs` | Search ARM documentation |
| `get_instruction` | Get ARM instruction details |
| `get_register_info` | Get register information |
| `get_architecture` | Get architecture specifications |

## Configuration

```json
{
  "mcpServers": {
    "arm": {
      "command": "npx",
      "args": ["-y", "@arm/mcp-server"],
      "env": {}
    }
  }
}
```

## Use Cases
- ARM assembly instruction lookup
- Embedded systems development guidance
- Architecture-specific optimization
- IoT firmware development support
- Processor feature comparison
