---
name: MCP Server — Azure
description: MCP Server for Azure — provides AI assistants with access to Azure cloud services including resource management, Azure AI, Cosmos DB, Storage, Key Vault, and Azure DevOps.
---

# MCP Server — Azure

## Overview
Azure MCP Server enables AI assistants to manage and interact with Microsoft Azure cloud services. This includes resource management, AI services, database operations, and DevOps workflows through Azure's official MCP server implementations.

## Tools Provided (Azure Resource Management)

| Tool | Description |
|------|-------------|
| `list_resources` | List Azure resources in a subscription |
| `get_resource` | Get resource details |
| `create_resource` | Create an Azure resource |
| `delete_resource` | Delete a resource |
| `list_resource_groups` | List resource groups |
| `get_deployment_status` | Check ARM deployment status |

## Azure AI Foundry Tools

| Tool | Description |
|------|-------------|
| `list_projects` | List AI Foundry projects |
| `get_model_catalog` | Browse available AI models |
| `deploy_model` | Deploy an AI model |
| `create_index` | Create a vector search index |
| `evaluate_model` | Run model evaluation |

## Configuration

```json
{
  "mcpServers": {
    "azure": {
      "command": "npx",
      "args": ["-y", "@azure/mcp-server"],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "...",
        "AZURE_TENANT_ID": "...",
        "AZURE_CLIENT_ID": "...",
        "AZURE_CLIENT_SECRET": "..."
      }
    }
  }
}
```

### Azure AI Foundry
```json
{
  "mcpServers": {
    "azure-ai-foundry": {
      "command": "npx",
      "args": ["-y", "@azure/ai-foundry-mcp"],
      "env": {
        "AZURE_AI_FOUNDRY_PROJECT": "your-project-name"
      }
    }
  }
}
```

## Supported Azure Services
- Azure Resource Manager (ARM)
- Azure AI Foundry (model management, evaluation)
- Azure Cosmos DB
- Azure Blob Storage
- Azure Key Vault
- Azure Kubernetes Service (AKS)
- Azure DevOps
- Azure SQL
- Microsoft Sentinel

## Use Cases
- AI-assisted cloud infrastructure management
- Automated Azure resource provisioning
- AI model deployment and evaluation
- Cloud cost analysis and optimization
- Security posture review with Sentinel
- DevOps pipeline management
