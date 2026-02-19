---
name: MCP Server — JFrog
description: MCP Server for JFrog — enables AI assistants to manage Artifactory repositories, search artifacts, manage builds, and interact with JFrog platform services.
---

# MCP Server — JFrog

## Overview
JFrog MCP Server provides AI assistants with access to JFrog Artifactory and the JFrog platform for artifact management, repository operations, build management, and security scanning.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_repositories` | List Artifactory repositories |
| `search_artifacts` | Search for artifacts (packages, containers) |
| `get_artifact_info` | Get artifact metadata and properties |
| `deploy_artifact` | Deploy an artifact to a repository |
| `list_builds` | List build records |
| `get_build_info` | Get build details |
| `scan_artifact` | Scan artifact for vulnerabilities (Xray) |
| `get_storage_info` | Get storage usage information |

## Configuration

```json
{
  "mcpServers": {
    "jfrog": {
      "command": "npx",
      "args": ["-y", "@jfrog/mcp-server"],
      "env": {
        "JFROG_URL": "https://your-instance.jfrog.io",
        "JFROG_ACCESS_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- Artifact repository management
- Package search and discovery
- Build information tracking
- Vulnerability scanning with JFrog Xray
- Docker image management
- Release artifact promotion
