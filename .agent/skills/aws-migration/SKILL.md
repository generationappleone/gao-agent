---
name: AWS Migration Services
description: Skill for AWS migration services — Application Migration Service (MGN), Database Migration Service (DMS), Migration Hub, Snowball, DataSync, and App2Container.
---

# AWS Migration Services

## Overview
AWS provides a comprehensive migration toolkit for lifting-and-shifting servers, migrating databases, transferring large data sets, and containerizing legacy applications.

## Application Migration Service (MGN)
```python
import boto3
mgn = boto3.client('mgn')

# List source servers
servers = mgn.describe_source_servers(filters={})

# Start test migration
mgn.start_test(sourceServerIDs=['s-1234567890abcdef0'])

# Launch cutover
mgn.start_cutover(sourceServerIDs=['s-1234567890abcdef0'])
```

## Database Migration Service (DMS)
```python
dms = boto3.client('dms')

# Create replication task
task = dms.create_replication_task(
    ReplicationTaskIdentifier='mysql-to-aurora',
    SourceEndpointArn='arn:aws:dms:...:endpoint:source',
    TargetEndpointArn='arn:aws:dms:...:endpoint:target',
    ReplicationInstanceArn='arn:aws:dms:...:rep:instance',
    MigrationType='full-load-and-cdc',
    TableMappings='{"rules":[{"rule-type":"selection","rule-action":"include","object-locator":{"schema-name":"%","table-name":"%"}}]}'
)
```

## Other Services
| Service | Use Case |
|---------|----------|
| **Migration Hub** | Central tracking for all migrations |
| **Snowball/Snowball Edge** | Physical data transfer (TB/PB) |
| **DataSync** | Online data transfer to AWS |
| **App2Container** | Containerize Java/.NET apps |
| **EKS Anywhere** | Kubernetes migration to EKS |

## Best Practices
- Use **Migration Hub** as single-pane migration tracker
- Run **DMS validation** to verify data integrity
- Use **CDC (Change Data Capture)** for near-zero downtime DB migration
