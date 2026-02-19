---
name: Database Migration Tools
description: Skill for database migration tools — MongoDB Atlas Live Migration, Snowflake, Couchbase XDCR, Oracle ZDM, and IBM InfoSphere Data Replication.
---

# Database Migration Tools

## MongoDB Atlas Live Migration
```python
import requests
headers = {"Authorization": f"Bearer {token}"}

# Start live migration
requests.post("https://cloud.mongodb.com/api/atlas/v2/groups/{groupId}/liveMigrations",
    headers=headers, json={
        "source": {"clusterName": "source-cluster", "connectionString": "mongodb://..."},
        "destination": {"clusterName": "dest-cluster"},
        "migrationHosts": ["mig-host.atlas.mongodb.net"]
    })
```

## Snowflake Data Migration
```sql
-- Load data from S3
COPY INTO my_table
FROM @my_s3_stage/data/
FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',' SKIP_HEADER = 1);

-- Replicate database across regions
ALTER DATABASE mydb ENABLE REPLICATION TO ACCOUNTS org.account2;
```

## Couchbase XDCR (Cross Data Center Replication)
```bash
# Create XDCR reference
couchbase-cli xdcr-setup --cluster src:8091 \
  --xdcr-cluster-name=DestCluster \
  --xdcr-hostname=dest:8091

# Create replication
couchbase-cli xdcr-replicate --cluster src:8091 \
  --xdcr-from-bucket=source --xdcr-to-bucket=target \
  --xdcr-cluster-name=DestCluster
```

## Oracle Zero Downtime Migration
```bash
# Register migration
zdmcli add database -sourcesid ORCL -sourcenode src-host \
  -targetnode dest-host -rsp /path/response.rsp
```

## Best Practices
- Always **validate data integrity** after migration
- Use **CDC (Change Data Capture)** for minimal downtime
- Plan **cutover windows** with rollback procedures
- Test migrations in **staging** before production
