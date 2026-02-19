---
name: MCP Server — Chroma
description: MCP Server for Chroma — enables AI assistants to manage vector embeddings, create collections, perform similarity search, and build RAG pipelines with ChromaDB.
---

# MCP Server — Chroma

## Overview
Chroma MCP Server provides AI assistants with access to ChromaDB, an open-source AI-native vector database, for embedding storage, similarity search, and retrieval-augmented generation (RAG) workflows.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_collections` | List all collections |
| `create_collection` | Create a new vector collection |
| `delete_collection` | Delete a collection |
| `add_documents` | Add documents with embeddings |
| `query` | Similarity search with optional filters |
| `get_documents` | Retrieve documents by ID |
| `update_documents` | Update existing documents |
| `delete_documents` | Delete documents from a collection |
| `count` | Get document count in a collection |

## Configuration

```json
{
  "mcpServers": {
    "chroma": {
      "command": "npx",
      "args": ["-y", "chroma-mcp-server"],
      "env": {
        "CHROMA_URL": "http://localhost:8000"
      }
    }
  }
}
```

## Use Cases
- RAG pipeline vector storage and retrieval
- Semantic search across documents
- Knowledge base construction
- Document similarity matching
- AI memory and context management
