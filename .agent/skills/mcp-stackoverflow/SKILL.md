---
name: MCP Server — Stack Overflow
description: MCP Server for Stack Overflow — enables AI assistants to search questions, answers, and solutions from Stack Overflow's developer knowledge base.
---

# MCP Server — Stack Overflow

## Overview
Stack Overflow MCP Server provides AI assistants with access to Stack Overflow's vast developer Q&A knowledge base for searching questions, answers, and accepted solutions.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search` | Search Stack Overflow questions |
| `get_question` | Get question with answers and comments |
| `get_answers` | Get answers for a specific question |
| `search_by_tag` | Search by programming language/framework tags |

## Configuration

```json
{
  "mcpServers": {
    "stackoverflow": {
      "command": "npx",
      "args": ["-y", "stackoverflow-mcp"],
      "env": {
        "STACKOVERFLOW_API_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- Finding solutions to programming errors
- Best practice discovery for specific technologies
- API usage examples and patterns
- Debugging assistance with community solutions
- Code snippet discovery
