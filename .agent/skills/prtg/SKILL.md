---
name: PRTG Network Monitor
description: Skill for PRTG Network Monitor — network traffic monitoring, device discovery, bandwidth analysis, and alerting with 200+ sensor types.
---

# PRTG Network Monitor — Traffic & Device Monitoring

## Overview
PRTG is a comprehensive network monitoring solution with 200+ sensor types covering SNMP, WMI, packet sniffing, flow analysis, and cloud monitoring.

## Sensor Types
| Sensor | Monitors |
|--------|----------|
| Ping | Host availability & latency |
| SNMP Traffic | Interface bandwidth |
| NetFlow/sFlow | Traffic flow analysis |
| HTTP | Web server response |
| WMI | Windows performance counters |
| SQL | Database query execution |
| Cloud | AWS, Azure, Google Cloud metrics |

## API
```bash
# Get sensor data
curl "https://prtg/api/table.json?\
  content=sensors&columns=objid,device,sensor,status,lastvalue\
  &username=admin&passhash=YOUR_HASH"

# Pause a sensor
curl "https://prtg/api/pause.htm?id=SENSOR_ID&action=0&username=admin&passhash=YOUR_HASH"

# Get historical data
curl "https://prtg/api/historicdata.json?\
  id=SENSOR_ID&avg=3600&sdate=2024-01-01&edate=2024-01-31\
  &username=admin&passhash=YOUR_HASH"
```

## Best Practices
- Use **auto-discovery** for initial network mapping
- Set **channel limits** based on normal baselines
- Implement **dependencies** between parent/child devices
- Use **maps** for NOC dashboard visualization
