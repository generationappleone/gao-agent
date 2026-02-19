---
name: MCP Server — Desktop Commander
description: MCP Server for Desktop Commander — provides AI assistants with secure file system access, terminal command execution, process management, and system automation capabilities.
---

# MCP Server — Desktop Commander

## Overview
Desktop Commander MCP Server gives AI assistants controlled access to the local file system, terminal, and running processes. It enables file manipulation, command execution, and system automation through a secure MCP interface with path validation and safety controls.

## Tools Provided

| Tool | Description |
|------|-------------|
| `read_file` | Read file contents with optional line range |
| `write_file` | Create or overwrite files |
| `edit_file` | Make targeted edits with search/replace |
| `list_directory` | List directory contents with metadata |
| `create_directory` | Create directories (with parents) |
| `move_file` | Move or rename files/directories |
| `delete_file` | Delete files or directories |
| `search_files` | Search for files by name pattern |
| `search_content` | Search file contents (grep-like) |
| `execute_command` | Run terminal commands with timeout |
| `list_processes` | List running system processes |
| `kill_process` | Terminate a running process |
| `get_file_info` | Get file metadata (size, permissions, dates) |

## Configuration

```json
{
  "mcpServers": {
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@anthropics/desktop-commander-mcp"],
      "env": {
        "ALLOWED_DIRECTORIES": "/home/user/projects,/tmp"
      }
    }
  }
}
```

## Security Features
- **Path validation**: Restricts access to allowed directories only
- **Command allowlist**: Optional whitelist of permitted commands
- **Timeout protection**: Commands auto-terminate after configurable timeout
- **Read-only mode**: Optional read-only file system access
- **Audit logging**: All operations logged for review

## Use Cases
- AI-assisted local development workflows
- Automated file organization and processing
- System administration tasks
- Build script execution and monitoring
- Log file analysis and monitoring
- Project scaffolding and boilerplate generation
