---
name: OpenNMS
description: Skill for OpenNMS — enterprise-grade open-source network monitoring with service polling, SNMP collection, event management, and topology discovery.
---

# OpenNMS — Enterprise Network Monitoring

## Overview
OpenNMS is a free, enterprise-grade network monitoring platform supporting service polling, performance data collection via SNMP, event/alarm correlations, and automated topology discovery.

## Key Features
- **Service Polling**: HTTP, HTTPS, ICMP, DNS, SMTP, etc.
- **SNMP Data Collection**: Performance metrics from network devices
- **Event Management**: Syslog, SNMP traps, internal events
- **Topology Discovery**: Layer 2/3 network topology mapping
- **Alarms & Notifications**: Escalation policies and integrations

## REST API
```bash
# Get nodes
curl -u admin:admin \
  'http://opennms:8980/opennms/api/v2/nodes'

# Get alarms
curl -u admin:admin \
  'http://opennms:8980/opennms/api/v2/alarms?_s=severity==CRITICAL'

# Acknowledge alarm
curl -u admin:admin -X PUT \
  'http://opennms:8980/opennms/api/v2/alarms/42' \
  -H 'Content-Type: application/json' \
  -d '{"ackUser":"admin"}'
```

## Best Practices
- Use **provisioning requisitions** for managed device groups
- Configure **threshold-based alerts** for performance anomalies
- Enable **Minion** for distributed monitoring across sites
