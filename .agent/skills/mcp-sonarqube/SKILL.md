---
name: MCP Server — SonarQube
description: MCP Server for SonarQube — enables AI assistants to analyze code quality, view issues, check quality gates, manage rules, and inspect security hotspots in SonarQube/SonarCloud.
---

# MCP Server — SonarQube

## Overview
SonarQube MCP Server provides AI assistants with access to SonarQube/SonarCloud for code quality analysis, security scanning, technical debt management, and quality gate monitoring.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_projects` | List SonarQube projects |
| `get_issues` | Get code issues (bugs, vulnerabilities, code smells) |
| `get_quality_gate` | Check quality gate status |
| `get_metrics` | Get project metrics (coverage, duplications, etc.) |
| `get_hotspots` | List security hotspots |
| `get_rules` | List active quality rules |
| `search_issues` | Search issues with advanced filters |
| `get_measures` | Get specific metric measures |

## Configuration

```json
{
  "mcpServers": {
    "sonarqube": {
      "command": "npx",
      "args": ["-y", "@sonarsource/mcp-server-sonarqube"],
      "env": {
        "SONARQUBE_URL": "http://localhost:9000",
        "SONARQUBE_TOKEN": "sqa_..."
      }
    }
  }
}
```

### SonarCloud
```json
{
  "mcpServers": {
    "sonarcloud": {
      "command": "npx",
      "args": ["-y", "@sonarsource/mcp-server-sonarqube"],
      "env": {
        "SONARQUBE_URL": "https://sonarcloud.io",
        "SONARQUBE_TOKEN": "...",
        "SONARQUBE_ORG": "your-org"
      }
    }
  }
}
```

## Use Cases
- AI-assisted code quality improvement
- Automated issue triage and fix suggestions
- Quality gate monitoring before releases
- Security vulnerability analysis
- Technical debt assessment and prioritization
