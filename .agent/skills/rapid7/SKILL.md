---
name: Rapid7 InsightVM
description: Skill for Rapid7 InsightVM — vulnerability management with real-time risk scoring, agent-based scanning, API integration, and remediation tracking.
---

# Rapid7 InsightVM — Vulnerability Management

## Overview
Rapid7 InsightVM provides live vulnerability management with real risk scoring, agent/agentless scanning, and integration with InsightConnect for automated remediation.

## API
```python
import requests

headers = {"X-Api-Key": "YOUR_API_KEY"}
base_url = "https://your-instance.insight.rapid7.com/api/3"

# Get sites
sites = requests.get(f"{base_url}/sites", headers=headers)

# Get vulnerabilities for an asset
vulns = requests.get(
    f"{base_url}/assets/{asset_id}/vulnerabilities",
    headers=headers
)

# Start a scan
scan = requests.post(
    f"{base_url}/sites/{site_id}/scans",
    headers=headers,
    json={"engineId": engine_id}
)
```

## Best Practices
- Use **Insight Agent** for continuous, lightweight monitoring
- Configure **Real Risk Score** for prioritization beyond CVSS
- Implement **remediation projects** with SLA tracking
- Use **goals and SLAs** to track vulnerability reduction targets
