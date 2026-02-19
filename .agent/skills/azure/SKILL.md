---
name: Microsoft Azure
description: Skill for Microsoft Azure cloud services — covering App Service, Azure Functions, Blob Storage, Cosmos DB, Azure SQL, Key Vault, Azure AD, and Azure CLI.
---

# Microsoft Azure Skill

## Overview
Microsoft Azure is a cloud computing platform providing services for building, deploying, and managing applications.

**Reference**: [Azure Documentation](https://learn.microsoft.com/en-us/azure/)

## Azure CLI
```bash
az login
az account set --subscription "My Subscription"
az group create --name myapp-rg --location southeastasia
```

## App Service (Web Apps)
```bash
az webapp create --resource-group myapp-rg --plan myapp-plan --name myapp-web --runtime "NODE:20-lts"
az webapp config appsettings set --resource-group myapp-rg --name myapp-web --settings NODE_ENV=production DB_HOST=mydb.database.azure.com
az webapp deploy --resource-group myapp-rg --name myapp-web --src-path ./dist.zip --type zip
```

## Azure Functions
```typescript
import { app, HttpRequest, HttpResponseInit } from "@azure/functions";

app.http("getUsers", {
  methods: ["GET"],
  authLevel: "anonymous",
  handler: async (request: HttpRequest): Promise<HttpResponseInit> => {
    const users = await db.users.findMany();
    return { status: 200, jsonBody: { data: users } };
  },
});
```

## Blob Storage
```typescript
import { BlobServiceClient } from "@azure/storage-blob";
const blobService = BlobServiceClient.fromConnectionString(process.env.AZURE_STORAGE_CONNECTION!);
const container = blobService.getContainerClient("uploads");

// Upload
const blockBlob = container.getBlockBlobClient(`${Date.now()}-${filename}`);
await blockBlob.uploadData(buffer, { blobHTTPHeaders: { blobContentType: "image/png" } });

// SAS URL
const sasUrl = await blockBlob.generateSasUrl({ permissions: "r", expiresOn: new Date(Date.now() + 3600000) });
```

## Common Services

| Service | Purpose |
|---------|---------|
| **App Service** | Web app hosting (PaaS) |
| **Azure Functions** | Serverless compute |
| **Blob Storage** | Object/file storage |
| **Cosmos DB** | Multi-model NoSQL |
| **Azure SQL** | Managed SQL Server |
| **Key Vault** | Secrets management |
| **Azure AD / Entra ID** | Identity & auth |
| **Service Bus** | Message queue |
| **Container Apps** | Serverless containers |
| **Azure DevOps** | CI/CD pipelines |

## Best Practices

| Practice | Description |
|----------|-------------|
| **Managed Identity** | Use over connection strings |
| **Key Vault** | Store all secrets and certificates |
| **Resource Groups** | Organize by application/environment |
| **RBAC** | Use role-based access control |
| **Monitoring** | Application Insights for APM |
| **Availability Zones** | Multi-zone for high availability |
| **Tags** | Tag resources for cost management |
| **Bicep/Terraform** | Infrastructure as Code |
