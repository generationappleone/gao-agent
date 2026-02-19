---
name: New Relic
description: Skill for New Relic — full-stack observability with APM, infrastructure monitoring, logs, browser monitoring, NRQL queries, and REST/NerdGraph API.
---

# New Relic — Full-Stack Observability

## Overview
New Relic provides full-stack observability including APM, infrastructure monitoring, log management, browser monitoring, and synthetics with NRQL query language.

## NRQL (New Relic Query Language)
```sql
-- Error rate by service
SELECT percentage(count(*), WHERE error IS true) as 'Error Rate'
FROM Transaction SINCE 1 hour ago FACET appName

-- Slow transactions
SELECT average(duration) FROM Transaction
WHERE duration > 2 FACET name SINCE 1 hour ago LIMIT 20

-- Infrastructure disk usage
SELECT latest(diskUsedPercent) FROM StorageSample
FACET hostname WHERE diskUsedPercent > 80
```

## NerdGraph API (GraphQL)
```python
import requests
headers = {"Api-Key": "YOUR_API_KEY", "Content-Type": "application/json"}

query = """
{ actor { account(id: YOUR_ACCOUNT_ID) {
  nrql(query: "SELECT count(*) FROM Transaction SINCE 1 hour ago") {
    results
  }
}}}
"""
result = requests.post("https://api.newrelic.com/graphql",
    headers=headers, json={"query": query})
```

## Best Practices
- Use **distributed tracing** across microservices
- Configure **alert policies** with dynamic thresholds
- Implement **SLI/SLO** for service level management
