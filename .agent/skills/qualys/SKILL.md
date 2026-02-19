---
name: Qualys
description: Skill for Qualys — cloud-based vulnerability management, compliance scanning (VMDR), web app scanning, and API integration.
---

# Qualys — Cloud Vulnerability & Compliance

## Overview
Qualys is a cloud-based security and compliance platform providing vulnerability management (VMDR), web application scanning, policy compliance, and cloud security posture assessment.

## VMDR API
```python
import requests

base_url = "https://qualysapi.qualys.com"
auth = ("username", "password")

# Launch vulnerability scan
scan = requests.post(
    f"{base_url}/api/2.0/fo/scan/",
    auth=auth,
    data={
        "action": "launch",
        "scan_title": "Weekly VM Scan",
        "ip": "10.0.0.0/24",
        "option_title": "Standard Scan"
    }
)

# Get host detections
detections = requests.get(
    f"{base_url}/api/2.0/fo/asset/host/vm/detection/",
    auth=auth,
    params={
        "action": "list",
        "severities": "4,5",
        "status": "New,Active,Re-Opened"
    }
)
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/api/2.0/fo/scan/` | Vulnerability scan management |
| `/api/2.0/fo/asset/host/vm/detection/` | Host vulnerability detections |
| `/api/2.0/fo/compliance/scan/` | Compliance scan management |
| `/api/2.0/fo/knowledge_base/vuln/` | Vulnerability knowledge base |
| `/qps/rest/2.0/search/was/webapp` | Web app scanning |

## Best Practices
- Use **Qualys Cloud Agent** for continuous visibility
- Implement **VMDR prioritization** based on TruRisk score
- Configure **patch management** integration for auto-remediation
