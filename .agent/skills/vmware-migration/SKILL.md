---
name: VMware Migration Tools
description: Skill for VMware migration — vSphere Replication, HCX (Hybrid Cloud Extension), and Nutanix Move for workload migration across environments.
---

# VMware Migration & Nutanix Move

## VMware vSphere Replication
```python
import requests
headers = {"vmware-api-session-id": session_id}

# Configure replication for VM
requests.post("https://vr-server/api/rest/vr/replications",
    headers=headers,
    json={"vmId": "vm-123", "targetDatastore": "ds-456", "rpo": 15})
```

## VMware HCX (Hybrid Cloud Extension)
- **Bulk Migration**: Migrate hundreds of VMs with zero downtime
- **vMotion**: Live migration across sites
- **Replication Assisted vMotion**: Combines replication + switchover
- **Network Extension**: Stretch Layer 2 networks across sites

## Nutanix Move
```bash
# Nutanix Move provides automated VM migration from:
# - VMware vSphere → Nutanix AHV
# - AWS → Nutanix
# - Azure → Nutanix
# Web-based UI with cutover scheduling
```

## Best Practices
- Use **HCX** for large-scale datacenter migrations
- Configure **Network Extension** before migrating dependent VMs
- Plan **cutover windows** for minimal business impact
