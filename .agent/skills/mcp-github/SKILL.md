---
name: MCP Server — GitHub
description: MCP Server for GitHub — provides AI assistants with repository management, issue tracking, pull request workflows, code search, Actions management, and GitHub API access.
---

# MCP Server — GitHub

## Overview
GitHub MCP Server enables AI assistants to interact with GitHub repositories, issues, pull requests, Actions, and the broader GitHub API through a standardized MCP interface.

## Tools Provided

| Tool | Description |
|------|-------------|
| `create_repository` | Create a new GitHub repository |
| `search_repositories` | Search for repositories |
| `get_repository` | Get repository details |
| `list_branches` | List repository branches |
| `create_branch` | Create a new branch |
| `get_file_contents` | Read file contents from a repo |
| `create_or_update_file` | Create or update a file |
| `push_files` | Push multiple files in one commit |
| `create_issue` | Create a new issue |
| `list_issues` | List and filter issues |
| `update_issue` | Update an issue |
| `add_issue_comment` | Add a comment to an issue |
| `create_pull_request` | Create a pull request |
| `list_pull_requests` | List pull requests |
| `merge_pull_request` | Merge a pull request |
| `get_pull_request_diff` | Get PR diff content |
| `search_code` | Search code across repositories |
| `list_commits` | List recent commits |
| `get_workflow_runs` | List GitHub Actions runs |
| `trigger_workflow` | Trigger a GitHub Actions workflow |
| `create_release` | Create a new release |

## Configuration

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..."
      }
    }
  }
}
```

## Required Token Scopes
- `repo` — Full repository access
- `workflow` — GitHub Actions
- `admin:org` — Organization management (optional)
- `gist` — Gist creation (optional)

## Use Cases
- AI-assisted PR creation and review
- Automated issue management and triage
- Repository scaffolding and setup
- Code search across organization repos
- Release management automation
- CI/CD workflow triggering and monitoring
