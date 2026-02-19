---
name: Securonix
description: Skill for Securonix — cloud-based SIEM with UEBA (User Entity Behavior Analytics), threat detection, and security analytics.
---

# Securonix — Cloud-Based SIEM + UEBA

## Overview
Securonix is a cloud-based SIEM with built-in UEBA that detects insider threats, advanced attacks, and data compromise through behavioral analytics and machine learning.

## Key Capabilities
- **UEBA**: Behavior-based anomaly detection for users and entities
- **SNYPR**: Analytics-driven threat detection
- **Built-in SOAR**: Automated response playbooks
- **Threat Models**: Pre-built analytics for 350+ threat scenarios
- **Cloud Integration**: Native connectors for AWS, Azure, GCP

## Spotter Query Language
```
-- Find anomalous user behavior
index=activity AND riskScore > 80
| stats count by accountname, riskScore
| sort -riskScore

-- Data exfiltration detection
index=dlp AND violationtype="DataExfiltration"
| stats sum(filesize) as total_size by accountname, destinationaddress
| where total_size > 100000000
```

## API Integration
```bash
# Authentication
curl -X POST 'https://instance.securonix.net/Snypr/ws/token/generate' \
  -d 'username=admin&password=pass&validity=1'

# Get incidents
curl -H "token: <auth_token>" \
  'https://instance.securonix.net/Snypr/ws/incident/get?from=0&max=25'
```

## Best Practices
- Tune **peer group analysis** for accurate anomaly baselines
- Implement **risk scoring** thresholds aligned with business impact
- Use **threat chains** to correlate related anomalies
