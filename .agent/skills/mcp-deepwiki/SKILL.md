---
name: MCP Server — DeepWiki
description: MCP Server for DeepWiki — enables AI assistants to access documentation and knowledge from any GitHub repository via DeepWiki's AI-generated wiki system.
---

# MCP Server — DeepWiki

## Overview
DeepWiki MCP Server provides AI assistants with access to DeepWiki's AI-generated documentation for any public GitHub repository, enabling deep understanding of codebases without manual exploration.

## Tools Provided

| Tool | Description |
|------|-------------|
| `get_wiki` | Get AI-generated wiki for a GitHub repository |
| `search_wiki` | Search documentation for specific topics |
| `get_architecture` | Get repository architecture overview |
| `get_api_docs` | Get API documentation for a repository |

## Configuration

```json
{
  "mcpServers": {
    "deepwiki": {
      "command": "npx",
      "args": ["-y", "deepwiki-mcp"],
      "env": {}
    }
  }
}
```

## Use Cases
- Understanding unfamiliar codebases quickly
- Architecture analysis of open-source projects
- API documentation lookup for libraries
- Dependency evaluation and comparison
- Learning new frameworks from their source code
