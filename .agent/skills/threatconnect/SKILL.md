---
name: ThreatConnect
description: Skill for ThreatConnect — threat intelligence and orchestration platform with playbooks, IOC management, and API integration.
---

# ThreatConnect — Threat Intel & Orchestration

## Overview
ThreatConnect combines threat intelligence, analytics, and orchestration/automation (SOAR) in a single platform for security operations.

## API
```python
from threatconnect import ThreatConnect

tc = ThreatConnect(api_aid='YOUR_ACCESS_ID', api_sec='YOUR_SECRET_KEY',
                   api_org='YOUR_ORG', api_url='https://api.threatconnect.com')

# Get indicators
indicators = tc.indicators()
indicators.retrieve()
for indicator in indicators:
    print(f"{indicator.indicator}: {indicator.rating}/{indicator.confidence}")
```

## Best Practices
- Use **ThreatConnect Playbooks** for automated response
- Implement **threat scoring** based on your risk context
- Enable **CAL** (Collective Analytics Layer) for aggregated intel
