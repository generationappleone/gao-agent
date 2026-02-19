---
name: MCP Server — Elasticsearch
description: MCP Server for Elasticsearch — enables AI assistants to search, index, query, and manage Elasticsearch clusters with full Query DSL support.
---

# MCP Server — Elasticsearch

## Overview
Elasticsearch MCP Server provides AI assistants with access to Elasticsearch for full-text search, data analytics, log exploration, and cluster management.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search` | Execute search queries with Query DSL |
| `index_document` | Index a document |
| `get_document` | Retrieve a document by ID |
| `delete_document` | Delete a document |
| `list_indices` | List all indices with metadata |
| `get_mapping` | Get index mapping/schema |
| `create_index` | Create an index with mappings |
| `bulk_index` | Bulk index multiple documents |
| `aggregate` | Run aggregation queries |
| `cluster_health` | Get cluster health status |

## Configuration

```json
{
  "mcpServers": {
    "elasticsearch": {
      "command": "npx",
      "args": ["-y", "@elastic/mcp-server-elasticsearch"],
      "env": {
        "ELASTICSEARCH_URL": "http://localhost:9200",
        "ELASTICSEARCH_API_KEY": "..."
      }
    }
  }
}
```

## Use Cases
- AI-assisted log analysis and troubleshooting
- Natural language to Elasticsearch Query DSL conversion
- Index management and schema design
- Real-time data exploration and analytics
- Search optimization and relevancy tuning
