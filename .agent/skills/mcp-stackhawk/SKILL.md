---
name: MCP Server — StackHawk
description: MCP Server for StackHawk — enables AI assistants to run DAST scans, view vulnerabilities, and manage application security testing through StackHawk's platform.
---

# MCP Server — StackHawk

## Overview
StackHawk MCP Server provides AI assistants with access to StackHawk's dynamic application security testing (DAST) platform for vulnerability scanning, security analysis, and remediation guidance.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_applications` | List registered applications |
| `run_scan` | Trigger a DAST scan |
| `get_scan_results` | Get scan results with vulnerabilities |
| `list_findings` | List security findings |
| `get_finding` | Get finding details with remediation |
| `list_scans` | List scan history |

## Configuration

```json
{
  "mcpServers": {
    "stackhawk": {
      "command": "npx",
      "args": ["-y", "@stackhawk/mcp-server"],
      "env": {
        "STACKHAWK_API_KEY": "hawk...."
      }
    }
  }
}
```

## Use Cases
- Automated DAST security scanning
- Vulnerability analysis and prioritization
- Security remediation guidance
- CI/CD security gate integration
- Application attack surface analysis
