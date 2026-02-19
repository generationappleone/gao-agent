---
name: Backup & Disaster Recovery
description: Skill for backup and disaster recovery — Veeam, Zerto, Commvault, Rubrik, and Acronis APIs for data protection and business continuity.
---

# Backup & Disaster Recovery

## Veeam Backup & Replication
```python
import requests
headers = {"Authorization": f"Bearer {token}"}
base = "https://veeam:9419/api/v1"

# Get backup jobs
jobs = requests.get(f"{base}/jobs", headers=headers)

# Start backup job
requests.post(f"{base}/jobs/{job_id}/start", headers=headers)

# Get restore points
points = requests.get(f"{base}/objectRestorePoints", headers=headers)
```

## Zerto Cloud Migration
```python
# Get VPGs (Virtual Protection Groups)
vpgs = requests.get("https://zerto/v1/vpgs",
    headers={"x-zerto-session": session_token})

# Failover test
requests.post("https://zerto/v1/vpgs/{vpg_id}/FailoverTest",
    headers=headers)
```

## Commvault Command Center
```python
# Get backup jobs
requests.get("https://commvault/api/Job?jobFilter=Backup",
    headers={"Authtoken": token})
```

## Rubrik Polaris (CDM API)
```python
# List SLA domains
requests.get("https://rubrik/api/v1/sla_domain",
    headers={"Authorization": f"Bearer {token}"})
```

## Acronis Cyber Protect
```python
# Get backup plans
requests.get("https://cloud.acronis.com/api/backup_management/v1/plans",
    headers={"Authorization": f"Bearer {token}"})
```

## Best Practices
- Follow **3-2-1 backup rule** (3 copies, 2 media, 1 offsite)
- Test **disaster recovery** regularly with non-disruptive failover tests
- Implement **immutable backups** for ransomware protection
