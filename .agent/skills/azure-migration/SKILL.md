---
name: Azure Migration Services
description: Skill for Azure migration services — Azure Migrate, Site Recovery, Database Migration Service, Data Box, Resource Mover, and App Service Migration.
---

# Azure Migration Services

## Overview
Azure provides an integrated migration ecosystem for server migration, database migration, disaster recovery, and physical data transfer.

## Azure Migrate
```bash
# Discover and assess
az migrate assessment create --resource-group myRG --project myProject --name assess1

# Azure Site Recovery (VMware to Azure)
az recoveryservices vault create --name myVault --resource-group myRG --location eastus
```

## Database Migration Service
```bash
# Create migration project
az dms project create --resource-group myRG --service-name myDMS \
  --name myProject --source-platform SQL --target-platform AzureDbForMySql
```

## Services Overview
| Service | Use Case |
|---------|----------|
| **Azure Migrate** | Server discovery, assessment, migration |
| **Site Recovery** | DR & VM migration from on-prem |
| **Database Migration Service** | DB migration with minimal downtime |
| **Data Box** | Physical data transfer (TB/PB) |
| **Resource Mover** | Move resources between Azure regions |
| **App Service Migration Assistant** | ASP.NET/Java web app migration |

## Best Practices
- Use **Azure Migrate Hub** for end-to-end tracking
- Run **assessment** before migration to identify blockers
- Use **Site Recovery** for test migrations without production impact
