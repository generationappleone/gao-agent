---
name: MCP Server — Box
description: MCP Server for Box — enables AI assistants to manage files, folders, collaborations, and content in Box cloud storage platform.
---

# MCP Server — Box

## Overview
Box MCP Server provides AI assistants with access to Box's cloud content management platform for file operations, folder management, sharing, and collaboration.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_files` | List files in a folder |
| `get_file` | Get file details and metadata |
| `upload_file` | Upload a file |
| `download_file` | Download file content |
| `create_folder` | Create a new folder |
| `search` | Search files and folders |
| `share_file` | Create a shared link |
| `list_collaborations` | List file/folder collaborations |
| `add_collaboration` | Add a collaborator |
| `get_file_comments` | Get file comments |

## Configuration

```json
{
  "mcpServers": {
    "box": {
      "command": "npx",
      "args": ["-y", "@box/mcp-server"],
      "env": {
        "BOX_CLIENT_ID": "...",
        "BOX_CLIENT_SECRET": "...",
        "BOX_ACCESS_TOKEN": "..."
      }
    }
  }
}
```

## Use Cases
- Cloud file management automation
- Content search and discovery
- Collaboration and sharing management
- File organization and archival
- Content workflow automation
