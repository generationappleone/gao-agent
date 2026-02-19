---
name: MCP Server — Azure Kubernetes Service
description: MCP Server for Azure Kubernetes Service (AKS) — enables AI assistants to manage AKS clusters, deployments, pods, services, and Kubernetes resources on Azure.
---

# MCP Server — Azure Kubernetes Service (AKS)

## Overview
Azure Kubernetes Service MCP Server provides AI assistants with access to AKS clusters for managing Kubernetes workloads, troubleshooting deployments, and monitoring cluster health on Azure.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_clusters` | List AKS clusters in a subscription |
| `get_cluster` | Get cluster details and configuration |
| `list_namespaces` | List Kubernetes namespaces |
| `list_pods` | List pods with status |
| `get_pod_logs` | Get container logs |
| `list_deployments` | List deployments |
| `scale_deployment` | Scale deployment replicas |
| `list_services` | List Kubernetes services |
| `get_events` | Get cluster events |
| `apply_manifest` | Apply a Kubernetes manifest |
| `get_node_status` | Get node health and resources |

## Configuration

```json
{
  "mcpServers": {
    "aks": {
      "command": "npx",
      "args": ["-y", "@azure/aks-mcp-server"],
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

## Use Cases
- AI-assisted Kubernetes troubleshooting on Azure
- Pod and deployment status monitoring
- Container log analysis for error diagnosis
- Cluster scaling and resource management
- Kubernetes manifest generation and deployment
