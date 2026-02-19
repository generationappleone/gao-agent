---
name: Google Cloud Migration
description: Skill for Google Cloud migration services — Migrate to VMs, Database Migration Service, Transfer Appliance, Storage Transfer, and Anthos Migration.
---

# Google Cloud Migration Services

## Overview
Google Cloud provides migration tools for VM migration, database migration, data transfer, and application modernization to GCP.

## Services
| Service | Use Case |
|---------|----------|
| **Migrate to Virtual Machines** | VM migration from on-prem/other clouds |
| **Database Migration Service** | MySQL/PostgreSQL/SQL Server to Cloud SQL/AlloyDB |
| **Transfer Appliance** | Physical data transfer (TB/PB) |
| **Storage Transfer Service** | Online cloud-to-cloud data transfer |
| **Anthos** | Hybrid/multi-cloud modernization |

## Database Migration Service
```bash
# Create migration job
gcloud database-migration migration-jobs create my-job \
  --source=my-source-connection \
  --destination=my-cloud-sql \
  --type=CONTINUOUS
```

## Storage Transfer
```bash
# Transfer from AWS S3 to GCS
gcloud transfer jobs create \
  s3://source-bucket gs://destination-bucket \
  --source-creds-file=aws-creds.json
```

## Best Practices
- Use **Migrate to VMs** for lift-and-shift with minimal changes
- Enable **CDC** for database migrations with minimal downtime
- Use **Anthos** for hybrid cloud workload management
