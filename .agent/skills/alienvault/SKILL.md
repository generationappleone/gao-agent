---
name: AlienVault USM & OTX
description: Skill for AlienVault USM (Unified Security Management) and Open Threat Exchange (OTX) — SIEM, threat monitoring, vulnerability assessment, and threat intelligence sharing.
---

# AlienVault USM & OTX

## Overview
AlienVault USM (now AT&T Cybersecurity) provides SIEM, asset discovery, vulnerability assessment, IDS, and threat intelligence in a unified platform. OTX (Open Threat Exchange) is the world's largest open threat intelligence community.

## USM Capabilities
- **Asset Discovery**: Automated network scanning
- **Vulnerability Assessment**: Built-in OpenVAS scanner
- **SIEM/Log Management**: Log correlation and alerting
- **IDS/IPS**: Network and host intrusion detection
- **Threat Intelligence**: OTX pulse integration

## OTX API
```python
from OTXv2 import OTXv2, IndicatorTypes

otx = OTXv2("YOUR_OTX_API_KEY")

# Get IoC details
indicators = otx.get_indicator_details_full(
    IndicatorTypes.IPv4, "8.8.8.8"
)

# Search pulses (threat intel feeds)
pulses = otx.search_pulses("ransomware")

# Submit IoCs
otx.create_pulse(
    name="Suspicious Activity",
    indicators=[{"indicator": "1.2.3.4", "type": "IPv4"}],
    description="Malicious IPs from incident"
)
```

### OTX API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/api/v1/pulses/subscribed` | Get subscribed threat feeds |
| `/api/v1/indicators/IPv4/{ip}/general` | IP reputation |
| `/api/v1/indicators/domain/{domain}/general` | Domain analysis |
| `/api/v1/indicators/file/{hash}/general` | File hash lookup |
| `/api/v1/search/pulses` | Search threat intelligence |

## Best Practices
- Subscribe to **relevant OTX pulses** for your industry
- Integrate OTX IOCs into **firewall and IDS rules**
- Use **correlation directives** for multi-event threat detection
