---
name: MCP Server — Prompts.chat
description: MCP Server for Prompts.chat — provides AI assistants with access to a curated library of high-quality prompts and prompt templates for various AI use cases.
---

# MCP Server — Prompts.chat

## Overview
Prompts.chat MCP Server provides AI assistants with access to a curated collection of high-quality prompt templates, enabling effective prompt engineering for various AI tasks and roles.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_prompts` | List available prompt templates |
| `get_prompt` | Get a specific prompt template |
| `search_prompts` | Search prompts by category or keyword |
| `get_categories` | List prompt categories |

## Configuration

```json
{
  "mcpServers": {
    "prompts-chat": {
      "command": "npx",
      "args": ["-y", "prompts-chat-mcp"],
      "env": {}
    }
  }
}
```

## Use Cases
- Prompt template discovery for AI tasks
- Role-based prompt selection (developer, writer, analyst)
- Prompt engineering best practices
- Task-specific prompt optimization
- AI workflow template management
