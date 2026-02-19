---
name: MCP Server — ContextStream
description: MCP Server for ContextStream — enables AI assistants to stream and manage contextual data pipelines for real-time data processing and analysis.
---

# MCP Server — ContextStream

## Overview
ContextStream MCP Server provides AI assistants with streaming context management capabilities, enabling real-time data pipeline processing and contextual information routing.

## Tools Provided

| Tool | Description |
|------|-------------|
| `create_stream` | Create a new data stream |
| `publish_event` | Publish an event to a stream |
| `consume_stream` | Consume events from a stream |
| `list_streams` | List available streams |
| `get_stream_stats` | Get stream statistics |
| `transform_data` | Apply transformations to stream data |

## Configuration

```json
{
  "mcpServers": {
    "contextstream": {
      "command": "npx",
      "args": ["-y", "contextstream-mcp"],
      "env": {
        "CONTEXTSTREAM_API_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- Real-time data stream management
- Event-driven pipeline orchestration
- Contextual data routing and transformation
- Stream analytics and monitoring
- Data pipeline debugging
