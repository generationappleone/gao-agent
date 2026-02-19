---
name: Recorded Future
description: Skill for Recorded Future — threat intelligence feed with real-time risk scoring, vulnerability intelligence, and API integration.
---

# Recorded Future — Threat Intelligence

## Overview
Recorded Future provides real-time threat intelligence using AI/ML to analyze billions of data points from the open, deep, and dark web for predictive security intelligence.

## API
```python
import requests
headers = {"X-RFToken": "YOUR_API_TOKEN"}

# IP reputation lookup
ip_intel = requests.get(
    "https://api.recordedfuture.com/v2/ip/1.2.3.4",
    headers=headers
)

# Vulnerability intelligence
vuln = requests.get(
    "https://api.recordedfuture.com/v2/vulnerability/CVE-2024-1234",
    headers=headers
)

# Search threat actors
actors = requests.get(
    "https://api.recordedfuture.com/v2/threatActor/search",
    headers=headers,
    params={"freetext": "APT28"}
)
```

## Best Practices
- Use **risk scores** (0-100) for automated triage decisions
- Integrate **vulnerability intelligence** with patch management
- Enable **SIEM connectors** for real-time IOC matching
