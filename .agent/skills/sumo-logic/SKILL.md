---
name: Sumo Logic
description: Skill for Sumo Logic — cloud SIEM and analytics platform with log search, metrics, security analytics, API integration, and compliance monitoring.
---

# Sumo Logic — Cloud SIEM & Analytics

## Overview
Sumo Logic is a cloud-native SIEM and analytics platform providing real-time log management, security analytics, and compliance monitoring with machine learning-powered insights.

## Search Query Language
```
-- Error rate by service
_sourceCategory=prod/*/logs error
| json field=_raw "service", "level", "message"
| where level = "ERROR"
| timeslice 5m
| count by _timeslice, service
| transpose row _timeslice column service

-- Security: Failed SSH logins
_sourceCategory=linux/auth "Failed password"
| parse "Failed password for * from * port *" as user, src_ip, port
| count by src_ip, user
| where _count > 5
| sort by _count desc
```

## API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/api/v1/search/jobs` | Create/manage search jobs |
| `/api/v1/collectors` | Manage collectors |
| `/api/v1/dashboards` | Dashboard management |
| `/api/sec/v1/insights` | Security insights |
| `/api/v1/monitors` | Alert monitors |

## Configuration
```json
{
  "api": {
    "endpoint": "https://api.sumologic.com/api",
    "accessId": "your-access-id",
    "accessKey": "your-access-key"
  }
}
```

## Best Practices
- Use **Field Extraction Rules** (FER) for structured parsing
- Implement **Partitions** for faster searches on high-volume data
- Use **Scheduled Views** for expensive recurring queries
- Configure **Cloud SIEM** rules for automated threat detection
