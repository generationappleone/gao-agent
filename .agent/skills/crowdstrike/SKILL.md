---
name: CrowdStrike Falcon
description: Skill for CrowdStrike Falcon — EDR/XDR endpoint detection, threat hunting, real-time response, Falcon API, and incident management.
---

# CrowdStrike Falcon — EDR/XDR

## Overview
CrowdStrike Falcon is a cloud-native EDR/XDR platform providing endpoint protection, threat hunting, real-time response, and threat intelligence through a lightweight agent.

## Falcon Query Language (FQL)
```
-- Find suspicious processes
event_type:ProcessRollup2 AND FileName:powershell.exe AND CommandLine:*-encoded*

-- Detect lateral movement
event_type:NetworkConnection AND RemotePort:445 AND LocalAddressIP4!=RemoteAddressIP4

-- Ransomware indicators
event_type:FileWrite AND FileName:*.encrypted
```

## Falcon API (OAuth 2.0)
```python
import requests

# Authenticate
auth = requests.post(
    'https://api.crowdstrike.com/oauth2/token',
    data={
        'client_id': 'YOUR_CLIENT_ID',
        'client_secret': 'YOUR_CLIENT_SECRET'
    }
)
token = auth.json()['access_token']
headers = {'Authorization': f'Bearer {token}'}

# Get detections
detections = requests.get(
    'https://api.crowdstrike.com/detects/queries/detects/v1',
    headers=headers,
    params={'filter': "status:'new'", 'limit': 50}
)

# Get host details
hosts = requests.get(
    'https://api.crowdstrike.com/devices/queries/devices/v1',
    headers=headers,
    params={'filter': "platform_name:'Windows'"}
)
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/detects/queries/detects/v1` | Query detections |
| `/devices/queries/devices/v1` | Query host devices |
| `/incidents/queries/incidents/v1` | Query incidents |
| `/real-time-response/entities/sessions/v1` | RTR sessions |
| `/iocs/entities/indicators/v1` | Manage custom IOCs |
| `/intel/queries/indicators/v1` | Threat intel indicators |

## Real-Time Response (RTR)
```bash
# Start RTR session to a host
# Get file listing
ls C:\Users\
# Run script
runscript -CloudFile="CollectArtifacts"
# Kill process
kill <pid>
```

## Best Practices
- Enable **Fusion SOAR** workflows for automated response
- Use **custom IOCs** to block known bad indicators
- Configure **prevention policies** per host group
- Leverage **Falcon OverWatch** for managed threat hunting
