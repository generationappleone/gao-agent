---
name: MCP Server — Serena
description: MCP Server for Serena — AI coding agent toolkit providing semantic code analysis, navigation, and editing through Language Server Protocol (LSP) integration, supporting 30+ programming languages.
---

# MCP Server — Serena

## Overview
Serena MCP Server transforms LLMs into fully-featured coding agents with IDE-like capabilities. By integrating the Language Server Protocol (LSP), it provides deep semantic understanding of codebases — enabling symbol-level analysis, precise navigation, and intelligent code editing across 30+ languages.

## Tools Provided

| Tool | Description |
|------|-------------|
| `find_symbol` | Find symbol definitions across the codebase |
| `find_references` | Find all references to a symbol |
| `get_hover_info` | Get type information and documentation for a symbol |
| `go_to_definition` | Navigate to a symbol's definition |
| `get_completions` | Get code completions at a position |
| `get_diagnostics` | Get compiler errors and warnings |
| `rename_symbol` | Rename a symbol and update all references |
| `read_file` | Read file contents with context |
| `edit_file` | Make precise code insertions/edits |
| `search_workspace` | Search across the entire workspace |
| `get_document_symbols` | Get all symbols in a file (outline) |

## Configuration

```json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": ["serena", "--workspace", "/path/to/project"],
      "env": {}
    }
  }
}
```

## Supported Languages
| Direct Support | Via LSP |
|---------------|---------|
| Python | Ruby |
| Java | C# |
| TypeScript/JavaScript | Scala |
| PHP | Kotlin |
| Go | Swift |
| Rust | Dart |
| C/C++ | And 20+ more |

## Key Capabilities
- **Semantic analysis**: Understands code structure, types, and relationships — not just text
- **Cross-file navigation**: Find definitions and references across entire projects
- **Intelligent refactoring**: Rename symbols with automatic reference updates
- **Compiler integration**: Real-time diagnostics (errors, warnings)
- **Context-aware editing**: Understands code context for precise modifications
- **Open-source & free**: No subscriptions or API keys required

## Use Cases
- Complex codebase refactoring
- Deep-dive debugging with call stack tracing
- Feature implementation in large codebases
- Automated code review with semantic understanding
- Cross-language project navigation
