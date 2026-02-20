---
name: Microsoft Azure
description: Skill for Microsoft Azure cloud services — covering App Service, Azure Functions, Blob Storage, Cosmos DB, Azure SQL, Key Vault, Azure AD, and Azure CLI.
---

# Microsoft Azure Skill

## Overview
Microsoft Azure is a cloud computing platform for building, deploying, and managing applications. Key services include App Service (web hosting), Azure Functions (serverless), Blob Storage (files), Cosmos DB (NoSQL), Azure SQL, Key Vault (secrets), and Azure AD (identity).

**References**:
- [Azure Documentation](https://learn.microsoft.com/en-us/azure/)
- [Azure SDK for JavaScript](https://github.com/Azure/azure-sdk-for-js)

---

## Blob Storage

```typescript
import { BlobServiceClient } from '@azure/storage-blob';

const blobService = BlobServiceClient.fromConnectionString(process.env.AZURE_STORAGE_CONNECTION_STRING!);
const container = blobService.getContainerClient('uploads');

export async function uploadBlob(name: string, data: Buffer, contentType: string) {
  const blob = container.getBlockBlobClient(name);
  await blob.upload(data, data.length, { blobHTTPHeaders: { blobContentType: contentType } });
  return blob.url;
}

export async function deleteBlob(name: string) {
  await container.getBlockBlobClient(name).delete();
}

export async function generateSasUrl(name: string, expiresMinutes = 60) {
  const blob = container.getBlockBlobClient(name);
  const { BlobSASPermissions, generateBlobSASQueryParameters, StorageSharedKeyCredential } = await import('@azure/storage-blob');
  // Generate SAS token for temporary access
  return blob.url + '?' + generateBlobSASQueryParameters({
    containerName: 'uploads', blobName: name,
    permissions: BlobSASPermissions.parse('r'),
    expiresOn: new Date(Date.now() + expiresMinutes * 60 * 1000),
  }, blobService.credential as StorageSharedKeyCredential).toString();
}
```

---

## Azure Functions

```typescript
import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';

app.http('getProducts', {
  methods: ['GET'],
  authLevel: 'anonymous',
  route: 'products',
  handler: async (request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> => {
    const products = await db.product.findMany({ where: { status: 'active' } });
    return { status: 200, jsonBody: { data: products } };
  },
});
```

---

## Key Vault

```typescript
import { SecretClient } from '@azure/keyvault-secrets';
import { DefaultAzureCredential } from '@azure/identity';

const credential = new DefaultAzureCredential();
const vault = new SecretClient(`https://${process.env.KEY_VAULT_NAME}.vault.azure.net`, credential);

export async function getSecret(name: string): Promise<string> {
  const secret = await vault.getSecret(name);
  return secret.value!;
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Managed Identity** | Use DefaultAzureCredential, avoid keys |
| **Blob Storage** | SAS tokens for temporary access |
| **Key Vault** | Store secrets, certificates, keys |
| **App Service** | Deployment slots for zero-downtime |
| **Functions** | Serverless with HTTP/timer/queue triggers |
| **Cosmos DB** | Partition key design for scalability |
| **Azure AD** | OIDC for authentication |
| **Resource Groups** | Organize related resources |
| **Tags** | Tag resources for cost management |
| **Azure CLI** | `az` commands for automation |

---

## Rules Integration
- **Storage**: Blob upload/download with SAS tokens
- **Compute**: Azure Functions with HTTP triggers
- **Secrets**: Key Vault with managed identity
- **Security**: DefaultAzureCredential, Azure AD
