---
name: Splunk
description: Skill for Splunk — SIEM, log analytics, SPL queries, dashboard creation, alerts, Splunk SOAR (Phantom), REST API, and security operations center (SOC) workflows.
---

# Splunk — SIEM & Log Analytics

## Overview
Splunk is an enterprise-grade SIEM and log analytics platform that collects, indexes, and analyzes machine-generated data. It provides real-time monitoring, alerting, dashboards, and security orchestration (SOAR via Splunk Phantom).

## Architecture
```
┌─────────────────────────────────────────────────────┐
│                   Splunk Platform                    │
├──────────┬──────────┬──────────┬───────────────────┤
│ Forwarder│ Indexer  │ Search   │ Splunk SOAR       │
│ (Data In)│ (Store)  │ Head     │ (Phantom)         │
├──────────┴──────────┴──────────┴───────────────────┤
│  Universal │ Heavy   │ Deployment │ Cluster Master  │
│  Forwarder │ Fwder   │ Server     │ License Master  │
└─────────────────────────────────────────────────────┘
```

## SPL (Search Processing Language)

### Basic Search
```spl
index=main sourcetype=access_combined status=500
| stats count by host, uri_path
| sort -count
| head 20
```

### Security Use Cases
```spl
-- Failed login attempts
index=auth action=failure
| stats count by user, src_ip
| where count > 5
| sort -count

-- Brute force detection
index=auth action=failure
| bin _time span=5m
| stats count by user, src_ip, _time
| where count > 10

-- Data exfiltration (large outbound transfers)
index=network direction=outbound
| stats sum(bytes_out) as total_bytes by src_ip, dest_ip
| where total_bytes > 1073741824
| eval size_gb = round(total_bytes/1073741824, 2)
```

### Dashboard & Alerting
```spl
-- Real-time alert for critical events
index=security severity=critical
| stats count by signature, src_ip, dest_ip
| where count > 3
```

## REST API

### Authentication
```bash
# Token-based auth
curl -k https://splunk:8089/services/auth/login \
  -d username=admin -d password=changeme

# Use token in subsequent requests
curl -k -H "Authorization: Bearer <token>" \
  https://splunk:8089/services/search/jobs
```

### Search Jobs API
```javascript
// Create a search job
const response = await fetch('https://splunk:8089/services/search/jobs', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: 'search=search index=main | head 100&output_mode=json'
});

// Get results
const results = await fetch(
  `https://splunk:8089/services/search/jobs/${sid}/results?output_mode=json`,
  { headers: { 'Authorization': `Bearer ${token}` } }
);
```

### Key API Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/services/search/jobs` | POST | Create search job |
| `/services/search/jobs/{sid}/results` | GET | Get search results |
| `/services/saved/searches` | GET/POST | Manage saved searches |
| `/services/alerts/fired_alerts` | GET | List fired alerts |
| `/services/data/indexes` | GET | List indexes |
| `/services/apps/local` | GET | List installed apps |

## Splunk SOAR (Phantom)
- **Playbooks**: Automated incident response workflows
- **Actions**: Integration with 350+ security tools
- **Cases**: Incident case management
- **Indicators**: IOC management and enrichment

## Configuration
```ini
# inputs.conf - Data inputs
[monitor:///var/log/syslog]
index = main
sourcetype = syslog

# outputs.conf - Forwarding
[tcpout:splunk_indexers]
server = indexer1:9997, indexer2:9997

# transforms.conf - Field extraction
[extract_ip]
REGEX = src_ip=(\d+\.\d+\.\d+\.\d+)
FORMAT = src_ip::$1
```

## Best Practices
- Use **index-time field extraction** sparingly (prefer search-time)
- Implement **role-based access control** (RBAC) for data
- Set **retention policies** per index based on data value
- Use **summary indexing** for expensive searches
- Enable **audit logging** for compliance
- Deploy **forwarders** at the edge, **indexers** centrally
