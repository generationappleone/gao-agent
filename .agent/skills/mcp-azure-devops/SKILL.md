---
name: MCP Server — Azure DevOps
description: MCP Server for Azure DevOps — enables AI assistants to manage work items, pipelines, repositories, pull requests, and boards in Azure DevOps projects.
---

# MCP Server — Azure DevOps

## Overview
Azure DevOps MCP Server provides AI assistants with access to Azure DevOps services including work item tracking, CI/CD pipelines, Git repositories, pull requests, and Agile boards.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_projects` | List Azure DevOps projects |
| `get_work_items` | Query work items (bugs, tasks, stories) |
| `create_work_item` | Create a new work item |
| `update_work_item` | Update work item fields |
| `list_pipelines` | List CI/CD pipelines |
| `trigger_pipeline` | Run a pipeline |
| `get_pipeline_status` | Get pipeline run status and logs |
| `list_repositories` | List Git repositories |
| `create_pull_request` | Create a PR |
| `list_pull_requests` | List PRs with filters |
| `get_pull_request` | Get PR details and diff |
| `approve_pull_request` | Approve a PR |
| `get_boards` | Get Agile board configuration |
| `list_sprints` | List sprints with items |

## Configuration

```json
{
  "mcpServers": {
    "azure-devops": {
      "command": "npx",
      "args": ["-y", "@microsoft/azure-devops-mcp"],
      "env": {
        "AZURE_DEVOPS_ORG_URL": "https://dev.azure.com/your-org",
        "AZURE_DEVOPS_PAT": "your-personal-access-token"
      }
    }
  }
}
```

## Use Cases
- Automated work item creation from requirements
- Sprint planning assistance
- CI/CD pipeline monitoring and troubleshooting
- Pull request creation and management
- Agile board updates and reporting
- Cross-project work item queries
