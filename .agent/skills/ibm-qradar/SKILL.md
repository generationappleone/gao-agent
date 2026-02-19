---
name: IBM QRadar
description: Skill for IBM QRadar — enterprise SIEM with offense management, log correlation, AQL queries, network flow analysis, API integration, and SOC operations.
---

# IBM QRadar — Enterprise SIEM

## Overview
IBM QRadar is an enterprise SIEM that provides real-time log correlation, offense management, network flow analysis, and threat detection with advanced analytics.

## AQL (Ariel Query Language)
```sql
-- Recent authentication failures
SELECT sourceip, username, COUNT(*) as attempts
FROM events
WHERE category = 'Authentication' AND eventdirection = 'L2R'
  AND LOGSOURCETYPENAME(logsourceid) LIKE '%Authentication%'
  AND qid = 28000002
GROUP BY sourceip, username
HAVING COUNT(*) > 5
ORDER BY attempts DESC
LAST 24 HOURS

-- Top talkers network flows
SELECT sourceip, destinationip, SUM(sourcebytes) as total_bytes
FROM flows
WHERE flowdirection = 'L2R'
GROUP BY sourceip, destinationip
ORDER BY total_bytes DESC
LAST 1 HOURS

-- Malware activity detection
SELECT sourceip, destinationip, eventcount, category
FROM events
WHERE category IN ('Malware', 'Suspicious Activity')
LAST 7 DAYS
```

## REST API

### Authentication
```bash
curl -k -S -X POST \
  -H 'Content-Type: application/json' \
  -H 'Version: 19.0' \
  -H 'SEC: <api_token>' \
  'https://qradar:443/api/ariel/searches'
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/api/ariel/searches` | Execute AQL queries |
| `/api/siem/offenses` | List/manage offenses |
| `/api/siem/local_destination_addresses` | Destination addresses |
| `/api/config/event_sources/log_source_management/log_sources` | Log sources |
| `/api/reference_data/sets` | Reference data sets |
| `/api/analytics/rules` | Custom rules |

### Search API Example
```python
import requests

headers = {
    'SEC': 'your-api-token',
    'Content-Type': 'application/json',
    'Version': '19.0'
}

# Create AQL search
search = requests.post(
    'https://qradar/api/ariel/searches',
    headers=headers,
    params={'query_expression': "SELECT * FROM events LAST 1 HOURS LIMIT 100"},
    verify=False
)
search_id = search.json()['search_id']

# Get results
results = requests.get(
    f'https://qradar/api/ariel/searches/{search_id}/results',
    headers=headers,
    verify=False
)
```

## Best Practices
- Tune **offense rules** to reduce false positives
- Use **reference sets** for whitelisting/blacklisting
- Implement **custom properties** for business context
- Set up **flow sources** for network visibility
- Configure **log source extensions** (LSX) for custom parsing
