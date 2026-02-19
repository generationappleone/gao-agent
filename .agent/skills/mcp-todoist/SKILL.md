---
name: MCP Server — Todoist
description: MCP Server for Todoist — enables AI assistants to manage tasks, projects, labels, and comments in Todoist for personal and team productivity.
---

# MCP Server — Todoist

## Overview
Todoist MCP Server provides AI assistants with access to Todoist task management, enabling task creation, project management, and productivity workflow automation.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_tasks` | List tasks with filters |
| `create_task` | Create a new task with due date and priority |
| `update_task` | Update task properties |
| `complete_task` | Mark a task as complete |
| `delete_task` | Delete a task |
| `list_projects` | List all projects |
| `create_project` | Create a new project |
| `list_labels` | List available labels |
| `add_comment` | Add a comment to a task |
| `get_task` | Get task details |

## Configuration

```json
{
  "mcpServers": {
    "todoist": {
      "command": "npx",
      "args": ["-y", "todoist-mcp-server"],
      "env": {
        "TODOIST_API_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted task creation from meeting notes
- Project planning and task breakdown
- Priority-based task management
- Daily standup task summaries
- Cross-project task organization
