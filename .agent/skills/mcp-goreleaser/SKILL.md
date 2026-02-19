---
name: MCP Server — GoReleaser
description: MCP Server for GoReleaser — enables AI assistants to manage Go binary releases, cross-compilation, changelog generation, and release automation with GoReleaser.
---

# MCP Server — GoReleaser

## Overview
GoReleaser MCP Server provides AI assistants with access to GoReleaser's release automation for Go projects, including cross-compilation, artifact management, and changelog generation.

## Tools Provided

| Tool | Description |
|------|-------------|
| `release` | Create a new release |
| `build` | Build binaries for target platforms |
| `check_config` | Validate GoReleaser configuration |
| `generate_changelog` | Generate changelog from commits |
| `list_releases` | List previous releases |

## Configuration

```json
{
  "mcpServers": {
    "goreleaser": {
      "command": "npx",
      "args": ["-y", "goreleaser-mcp"],
      "env": {
        "GITHUB_TOKEN": "ghp_..."
      }
    }
  }
}
```

## Use Cases
- Go binary release automation
- Cross-platform build management
- Changelog generation from git history
- Release configuration validation
- Multi-platform artifact distribution
