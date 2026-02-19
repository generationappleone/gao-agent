---
name: MCP Server — Miro
description: MCP Server for Miro — enables AI assistants to create and manage boards, sticky notes, shapes, diagrams, and collaborative whiteboard content in Miro.
---

# MCP Server — Miro

## Overview
Miro MCP Server provides AI assistants with access to Miro's collaborative whiteboard platform for creating boards, diagrams, sticky notes, and visual collaboration content.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_boards` | List Miro boards |
| `create_board` | Create a new board |
| `create_sticky_note` | Add a sticky note |
| `create_shape` | Add a shape (rectangle, circle, etc.) |
| `create_text` | Add text to a board |
| `create_connector` | Connect two items |
| `list_items` | List items on a board |
| `update_item` | Update an item's properties |
| `delete_item` | Remove an item |
| `create_frame` | Create a frame/container |

## Configuration

```json
{
  "mcpServers": {
    "miro": {
      "command": "npx",
      "args": ["-y", "@miro/mcp-server"],
      "env": {
        "MIRO_ACCESS_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- AI-generated architecture diagrams
- Brainstorming boards with sticky notes
- User flow and journey mapping
- Sprint retrospective boards
- Mind mapping and ideation
