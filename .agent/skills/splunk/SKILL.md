---
name: Splunk
description: Skill for Splunk — SIEM, log analytics, SPL queries, dashboard creation, alerts, Splunk SOAR (Phantom), REST API, and security operations center (SOC) workflows.
---

# Splunk Skill

## Overview
Splunk is an enterprise platform for searching, monitoring, and analyzing machine-generated data. It provides SPL (Search Processing Language) for queries, dashboards for visualization, alerts for monitoring, and SOAR integration for automated response.

**References**:
- [Splunk Documentation](https://docs.splunk.com/)
- [SPL Reference](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference)

---

## SPL Queries

```spl
# Search for errors in the last 24 hours
index=myapp sourcetype=application level=ERROR
| timechart span=1h count by source

# Top error messages
index=myapp level=ERROR
| stats count by message
| sort -count
| head 20

# Failed login attempts
index=auth action=login status=failed
| stats count by user, src_ip
| where count > 5
| sort -count

# API response time analysis
index=myapp sourcetype=access_log
| eval response_time_ms = response_time * 1000
| stats avg(response_time_ms) as avg_ms, p95(response_time_ms) as p95_ms, max(response_time_ms) as max_ms by endpoint
| sort -p95_ms

# Suspicious activity detection
index=firewall action=blocked
| stats count by src_ip, dest_port
| where count > 100
| lookup geoip src_ip OUTPUT country
| table src_ip, country, dest_port, count
```

---

## Alerts

```spl
# Alert: High error rate (>5% in 5 minutes)
index=myapp sourcetype=access_log
| eval is_error = if(status >= 500, 1, 0)
| stats count as total, sum(is_error) as errors
| eval error_rate = errors / total * 100
| where error_rate > 5

# Alert: Brute force detection
index=auth action=login status=failed
| stats count by src_ip span=5m
| where count > 10
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **SPL** | Search Processing Language for queries |
| **Index** | Organize data by source and type |
| **Timechart** | Time-based aggregations |
| **Stats** | count, avg, sum, p95 aggregations |
| **Alerts** | Threshold and pattern-based alerting |
| **Dashboards** | XML or Simple XML for visualizations |
| **Lookups** | Enrich data with lookup tables |
| **SOAR** | Automate response with playbooks |
| **Data models** | Accelerated searches with data models |
| **Retention** | Configure index retention policies |

---

## Rules Integration
- **Queries**: SPL for log search and analysis
- **Alerts**: Error rate, brute force detection
- **Dashboards**: Real-time monitoring views
- **SOAR**: Automated incident response
