---
name: MCP Server — Atlassian
description: MCP Server for Atlassian — enables AI assistants to manage Jira issues, Confluence pages, boards, sprints, and Atlassian product workflows.
---

# MCP Server — Atlassian

## Overview
Atlassian MCP Server provides AI assistants with access to Jira and Confluence, enabling issue management, sprint planning, documentation, and Agile workflow automation.

## Tools Provided (Jira)

| Tool | Description |
|------|-------------|
| `search_issues` | Search Jira issues with JQL |
| `create_issue` | Create a new issue (story, bug, task) |
| `update_issue` | Update issue fields |
| `transition_issue` | Move issue through workflow statuses |
| `add_comment` | Add a comment to an issue |
| `get_boards` | List Scrum/Kanban boards |
| `get_sprints` | List sprints for a board |
| `get_sprint_issues` | Get issues in a sprint |

## Tools Provided (Confluence)

| Tool | Description |
|------|-------------|
| `search_content` | Search Confluence pages |
| `get_page` | Get page content |
| `create_page` | Create a new page |
| `update_page` | Update page content |
| `get_spaces` | List spaces |

## Configuration

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@atlassian/mcp-server"],
      "env": {
        "ATLASSIAN_URL": "https://your-domain.atlassian.net",
        "ATLASSIAN_EMAIL": "user@example.com",
        "ATLASSIAN_API_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted sprint planning and issue creation
- Automated bug report creation from error logs
- Confluence documentation generation
- JQL query generation from natural language
- Sprint progress reporting
- Cross-project issue linking and tracking
