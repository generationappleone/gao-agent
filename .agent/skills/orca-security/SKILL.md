---
name: Orca Security
description: Skill for Orca Security — agentless cloud security with CNAPP, side-scanning, vulnerability management, and API integration.
---

# Orca Security — Agentless Cloud Security

## Overview
Orca Security provides agentless cloud security using SideScanning™ technology for comprehensive visibility across workloads, configurations, identities, and data without deploying agents.

## API
```python
import requests
headers = {"Authorization": f"Bearer {token}"}

# Get alerts
alerts = requests.get("https://api.orcasecurity.io/api/alerts", headers=headers,
    params={"severity": ["critical", "high"], "status": "open"})

# Get assets
assets = requests.get("https://api.orcasecurity.io/api/assets", headers=headers)
```

## Best Practices
- Use **risk prioritization** based on attack path analysis
- Enable **shift-left** scanning for IaC and container images
- Configure **asset inventory** for complete cloud visibility
