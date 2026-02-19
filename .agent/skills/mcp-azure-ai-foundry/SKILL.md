---
name: MCP Server — Azure AI Foundry
description: MCP Server for Azure AI Foundry — enables AI assistants to manage AI projects, deploy models, create vector indexes, evaluate models, and access the Azure AI model catalog.
---

# MCP Server — Azure AI Foundry

## Overview
Azure AI Foundry MCP Server provides AI assistants with access to Azure's comprehensive AI/ML platform for model management, deployment, evaluation, and vector index creation.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_projects` | List AI Foundry projects |
| `get_model_catalog` | Browse available AI models |
| `deploy_model` | Deploy an AI model |
| `create_index` | Create a vector search index |
| `evaluate_model` | Run model evaluation with test data |
| `list_deployments` | List model deployments |
| `get_connections` | Get data connections |
| `list_compute` | List compute resources |

## Configuration

```json
{
  "mcpServers": {
    "azure-ai-foundry": {
      "command": "npx",
      "args": ["-y", "@azure/ai-foundry-mcp"],
      "env": {
        "AZURE_AI_FOUNDRY_PROJECT": "your-project",
        "AZURE_TENANT_ID": "...",
        "AZURE_CLIENT_ID": "...",
        "AZURE_CLIENT_SECRET": "..."
      }
    }
  }
}
```

## Use Cases
- AI model catalog browsing and selection
- Model deployment to Azure endpoints
- Vector index creation for RAG
- Model performance evaluation
- AI project lifecycle management
