---
name: MCP Server — Microsoft Enterprise
description: MCP Server for Microsoft Enterprise — enables AI assistants to access Microsoft 365, Graph API, Teams, SharePoint, and enterprise Microsoft services.
---

# MCP Server — Microsoft Enterprise

## Overview
Microsoft Enterprise MCP Server provides AI assistants with access to Microsoft 365 and enterprise services through the Microsoft Graph API, enabling email, calendar, Teams, SharePoint, and OneDrive operations.

## Tools Provided

| Tool | Description |
|------|-------------|
| `send_email` | Send emails via Outlook |
| `list_emails` | List recent emails |
| `create_event` | Create calendar events |
| `list_events` | List calendar events |
| `send_teams_message` | Send a Teams message |
| `list_channels` | List Teams channels |
| `search_sharepoint` | Search SharePoint content |
| `list_files` | List OneDrive files |
| `upload_file` | Upload a file to OneDrive/SharePoint |
| `get_users` | List Azure AD users |

## Configuration

```json
{
  "mcpServers": {
    "microsoft-enterprise": {
      "command": "npx",
      "args": ["-y", "@microsoft/mcp-server-enterprise"],
      "env": {
        "AZURE_TENANT_ID": "...",
        "AZURE_CLIENT_ID": "...",
        "AZURE_CLIENT_SECRET": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted email management and drafting
- Calendar scheduling and meeting coordination
- Teams message automation
- SharePoint content discovery
- OneDrive file management
- Azure AD user management
