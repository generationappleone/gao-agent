---
name: MCP Server — Codacy
description: MCP Server for Codacy — enables AI assistants to access code quality analysis, coverage reports, and security issues from Codacy's automated code review platform.
---

# MCP Server — Codacy

## Overview
Codacy MCP Server provides AI assistants with access to Codacy's automated code review platform for code quality analysis, security scanning, and coverage reporting.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_repositories` | List monitored repositories |
| `get_quality` | Get code quality metrics |
| `list_issues` | List code issues by category |
| `get_coverage` | Get code coverage data |
| `get_patterns` | Get active code patterns/rules |
| `get_pull_request_analysis` | Get PR analysis results |

## Configuration

```json
{
  "mcpServers": {
    "codacy": {
      "command": "npx",
      "args": ["-y", "@codacy/mcp-server"],
      "env": {
        "CODACY_API_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- Automated code quality monitoring
- PR quality analysis and review
- Code coverage tracking
- Security issue detection
- Technical debt assessment
