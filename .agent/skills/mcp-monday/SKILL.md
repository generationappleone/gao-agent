---
name: MCP Server — Monday
description: MCP Server for Monday.com — enables AI assistants to manage boards, items, groups, columns, updates, and automate project management workflows.
---

# MCP Server — Monday.com

## Overview
Monday.com MCP Server provides AI assistants with access to Monday.com project management platform for board management, item creation, status updates, and workflow automation.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_boards` | List all boards |
| `get_board` | Get board details with columns and groups |
| `create_item` | Create a new item on a board |
| `update_item` | Update item column values |
| `list_items` | List items on a board with filters |
| `create_update` | Add an update/comment to an item |
| `change_item_status` | Change an item's status |
| `create_group` | Create a new group on a board |
| `move_item` | Move item to a different group |
| `archive_item` | Archive an item |

## Configuration

```json
{
  "mcpServers": {
    "monday": {
      "command": "npx",
      "args": ["-y", "@mondaycom/mcp-server-monday"],
      "env": {
        "MONDAY_API_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- Automated task creation from requirements
- Sprint progress tracking and reporting
- Status update automation
- Cross-board project coordination
- Meeting action items to Monday.com tasks
