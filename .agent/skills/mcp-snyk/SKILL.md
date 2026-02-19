---
name: MCP Server — Snyk
description: MCP Server for Snyk — enables AI assistants to scan for vulnerabilities, analyze dependencies, review container security, and manage security issues in Snyk.
---

# MCP Server — Snyk

## Overview
Snyk MCP Server provides AI assistants with access to Snyk's security platform for vulnerability scanning, dependency analysis, container security, and infrastructure as code scanning.

## Tools Provided

| Tool | Description |
|------|-------------|
| `test_project` | Scan a project for vulnerabilities |
| `list_issues` | List security issues |
| `get_issue` | Get vulnerability details and remediation |
| `list_projects` | List monitored projects |
| `list_organizations` | List Snyk organizations |
| `get_dependencies` | Get project dependency tree |
| `get_license_issues` | Check license compliance |
| `test_container` | Scan container images |

## Configuration

```json
{
  "mcpServers": {
    "snyk": {
      "command": "npx",
      "args": ["-y", "@snyk/mcp-server"],
      "env": {
        "SNYK_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- Automated vulnerability scanning during development
- Dependency risk assessment
- Container image security analysis
- License compliance checking
- Remediation guidance for known CVEs
