---
name: DLP Solutions
description: Skill for Data Loss Prevention (DLP) — Symantec DLP, Forcepoint DLP, Varonis, and BigID for data protection, classification, and compliance.
---

# Data Loss Prevention (DLP) Solutions

## Symantec DLP API
```python
import requests
headers = {"Authorization": f"Bearer {token}"}

# Get incidents
incidents = requests.get(
    "https://symantec-dlp/ProtectManager/webservices/v2/incidents",
    headers=headers,
    params={"policyGroup": "PII Protection", "severity": "HIGH"}
)
```

## Forcepoint DLP API
```python
# Get DLP events
events = requests.get(
    "https://forcepoint/api/v1/dlp/events",
    headers={"Authorization": f"Bearer {token}"},
    params={"action": "blocked", "timeRange": "24h"}
)
```

## Varonis API
```python
# Get data alerts
alerts = requests.get("https://varonis/api/alerts",
    headers={"Authorization": f"Bearer {token}"},
    params={"severity": "High", "status": "Open"})

# Get sensitive data locations
sensitive = requests.get("https://varonis/api/datareport/sensitive",
    headers={"Authorization": f"Bearer {token}"})
```

## BigID API
```python
# Data discovery scan results
results = requests.get("https://bigid/api/v1/scanResults",
    headers={"Authorization": f"Bearer {token}"})

# Get PII inventory
pii = requests.get("https://bigid/api/v1/piiInventory",
    headers={"Authorization": f"Bearer {token}"})
```

## Best Practices
- Classify data **before** implementing DLP policies
- Start with **monitoring mode**, then move to **blocking**
- Integrate DLP with **SIEM** for centralized incident visibility
- Map DLP policies to **regulatory requirements** (GDPR, PCI, HIPAA)
