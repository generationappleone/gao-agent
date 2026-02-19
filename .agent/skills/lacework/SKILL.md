---
name: Lacework
description: Skill for Lacework — cloud security platform with CNAPP, runtime threat detection, compliance, and API integration.
---

# Lacework — Cloud Security (CNAPP)

## Overview
Lacework provides Cloud-Native Application Protection Platform (CNAPP) combining CSPM, CWPP, CIEM, and runtime threat detection with behavioral analytics.

## API
```python
import requests
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

# Get alerts
alerts = requests.get("https://account.lacework.net/api/v2/Alerts", headers=headers)

# Run compliance report
report = requests.get("https://account.lacework.net/api/v2/Compliance", headers=headers,
    params={"reportType": "AWS_CIS_14"})
```

## Best Practices
- Use **Polygraph** behavioral analytics for anomaly detection
- Enable **agentless scanning** for complete cloud visibility
- Configure **compliance frameworks** (CIS, SOC2, PCI) for continuous assessment
