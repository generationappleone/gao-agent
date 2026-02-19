---
name: Trend Micro XDR
description: Skill for Trend Micro Vision One XDR — extended detection and response across endpoints, email, servers, cloud, and network.
---

# Trend Micro XDR — Extended Detection & Response

## Overview
Trend Micro Vision One provides XDR capabilities correlating data across endpoints, email, servers, cloud workloads, and network layers for comprehensive threat detection.

## Search Queries
```
-- Suspicious process execution
eventSubId:2 AND processCmd:*powershell* AND processCmd:*-enc*

-- Lateral movement via SMB
eventId:3 AND request:*\\C$* AND dst:internal_range

-- Email-borne threats
mailMsgSubject:*invoice* AND mailSenderDomain!=company.com AND det:malware
```

## API Integration
```python
import requests

headers = {
    "Authorization": "Bearer YOUR_API_TOKEN",
    "TMV1-Filter": "(riskLevel eq 'high')"
}

# Get workbench alerts
alerts = requests.get(
    "https://api.xdr.trendmicro.com/v3.0/workbench/alerts",
    headers=headers
)

# Search endpoint activity data
search = requests.post(
    "https://api.xdr.trendmicro.com/v3.0/search/endpointActivities",
    headers=headers,
    json={
        "fields": ["endpointHostName", "processCmd"],
        "top": 50
    }
)
```

## Best Practices
- Correlate detections across **multiple security layers**
- Use **Workbench** for investigation and response
- Enable **Response Actions** for automated containment
