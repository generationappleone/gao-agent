---
name: MCP Server — Rigour
description: MCP Server for Rigour — enables AI assistants to manage testing workflows, visual regression testing, and quality assurance pipelines through Rigour's testing platform.
---

# MCP Server — Rigour

## Overview
Rigour MCP Server provides AI assistants with access to Rigour's automated testing and quality assurance platform for visual regression testing and test pipeline management.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_tests` | List test cases |
| `run_test` | Execute a test |
| `get_results` | Get test results |
| `compare_screenshots` | Compare visual snapshots |
| `list_projects` | List testing projects |
| `get_test_history` | Get test execution history |

## Configuration

```json
{
  "mcpServers": {
    "rigour": {
      "command": "npx",
      "args": ["-y", "@rigour/mcp-server"],
      "env": {
        "RIGOUR_API_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- Visual regression test management
- Automated QA pipeline orchestration
- Screenshot comparison and analysis
- Test result analysis and reporting
- Quality gate enforcement
