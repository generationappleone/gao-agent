---
name: MCP Server — PubNub
description: MCP Server for PubNub — enables AI assistants to manage real-time messaging channels, publish messages, manage users, and access PubNub's real-time communication platform.
---

# MCP Server — PubNub

## Overview
PubNub MCP Server provides AI assistants with access to PubNub's real-time messaging infrastructure for publishing messages, managing channels, and monitoring real-time communication.

## Tools Provided

| Tool | Description |
|------|-------------|
| `publish` | Publish a message to a channel |
| `subscribe` | Subscribe to channel updates |
| `list_channels` | List active channels |
| `get_channel_members` | Get channel membership |
| `get_presence` | Get online/offline status |
| `get_history` | Get message history |
| `manage_users` | Manage PubNub users |

## Configuration

```json
{
  "mcpServers": {
    "pubnub": {
      "command": "npx",
      "args": ["-y", "@pubnub/mcp-server"],
      "env": {
        "PUBNUB_SUBSCRIBE_KEY": "sub-c-...",
        "PUBNUB_PUBLISH_KEY": "pub-c-...",
        "PUBNUB_SECRET_KEY": "sec-c-..."
      }
    }
  }
}
```

## Use Cases
- Real-time messaging integration management
- Channel and user administration
- Message history retrieval and analysis
- Presence monitoring for chat applications
- Real-time notification management
