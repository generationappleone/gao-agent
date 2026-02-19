---
name: MCP Server — Microsoft Learn
description: MCP Server for Microsoft Learn — provides AI assistants with access to Microsoft documentation, tutorials, API references, and learning paths for Azure, .NET, M365, and other Microsoft technologies.
---

# MCP Server — Microsoft Learn

## Overview
Microsoft Learn MCP Server gives AI assistants access to Microsoft's official documentation and learning resources, ensuring accurate and up-to-date technical guidance for Microsoft technologies.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search_docs` | Search Microsoft Learn documentation |
| `get_article` | Get a specific documentation article |
| `get_api_reference` | Get API reference documentation |
| `list_learning_paths` | Browse available learning paths |
| `get_code_samples` | Get code examples for a topic |

## Configuration

```json
{
  "mcpServers": {
    "microsoft-learn": {
      "command": "npx",
      "args": ["-y", "@microsoft/learn-mcp-server"],
      "env": {}
    }
  }
}
```

## Covered Topics
- Azure cloud services (all services)
- .NET / ASP.NET Core / C#
- Microsoft 365 (Graph API, Teams, SharePoint)
- Power Platform
- Visual Studio / VS Code
- Windows development
- SQL Server / Azure SQL
- TypeScript
- Microsoft Security

## Use Cases
- Accurate Microsoft API usage in code generation
- Learning path recommendations for developers
- Azure service configuration guidance
- .NET best practices and patterns
- Microsoft security compliance documentation
