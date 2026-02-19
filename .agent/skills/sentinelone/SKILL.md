---
name: SentinelOne Singularity
description: Skill for SentinelOne Singularity — EDR/XDR endpoint protection, threat detection, automated response, and REST API integration.
---

# SentinelOne Singularity — EDR/XDR

## Overview
SentinelOne Singularity is an AI-powered XDR platform providing autonomous endpoint protection, detection, and response with automated remediation and rollback capabilities.

## Deep Visibility Query Language
```sql
-- Suspicious PowerShell execution
EventType = "Process Creation" AND
  SrcProcName = "powershell.exe" AND
  SrcProcCmdLine ContainsCIS "-encodedcommand"

-- Detect persistence mechanisms
EventType = "Registry Value Modified" AND
  RegistryPath Contains "CurrentVersion\Run"

-- Network connections to known bad IPs
EventType = "DNS Resolved" AND
  DnsResponse In ("malicious-domain.com")
```

## REST API
```python
import requests

base_url = "https://your-instance.sentinelone.net"
headers = {
    "Authorization": "ApiToken YOUR_API_TOKEN",
    "Content-Type": "application/json"
}

# Get threats
threats = requests.get(
    f"{base_url}/web/api/v2.1/threats",
    headers=headers,
    params={"limit": 50, "resolved": False}
)

# Get agents
agents = requests.get(
    f"{base_url}/web/api/v2.1/agents",
    headers=headers,
    params={"isActive": True}
)

# Initiate threat mitigation
requests.post(
    f"{base_url}/web/api/v2.1/threats/mitigate/kill",
    headers=headers,
    json={"filter": {"ids": ["threat_id"]}}
)
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/web/api/v2.1/threats` | Threat management |
| `/web/api/v2.1/agents` | Agent management |
| `/web/api/v2.1/activities` | Activity logs |
| `/web/api/v2.1/groups` | Group management |
| `/web/api/v2.1/exclusions` | Exclusion management |

## Best Practices
- Configure **Storyline Active Response (STAR)** rules
- Use **automated remediation** (kill, quarantine, rollback)
- Implement **network quarantine** for compromised endpoints
- Enable **Deep Visibility** for advanced threat hunting
