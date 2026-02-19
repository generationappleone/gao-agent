---
name: Security Onion
description: Skill for Security Onion — open-source NSM (Network Security Monitoring) with full packet capture, IDS (Snort/Suricata), Zeek, Elasticsearch, and log management.
---

# Security Onion — NSM + Log Management

## Overview
Security Onion is a free, open-source Linux distribution for intrusion detection, enterprise security monitoring, and log management combining Suricata, Zeek, Elasticsearch, and full packet capture.

## Components
- **Suricata/Snort**: IDS/IPS signatures
- **Zeek**: Protocol-level network analysis
- **Elasticsearch + Kibana**: Log storage and visualization
- **PCAP**: Full packet capture and replay
- **Wazuh**: Host-based intrusion detection (HIDS)
- **TheHive/Cortex**: Incident response (optional)

## SOC Dashboard (Security Onion Console)
```
-- Hunt for suspicious DNS
so-hunt --query "event.module:zeek AND event.dataset:dns AND dns.question.name:*.tk"

-- Alert review
so-alert --filter "alert.severity:1"
```

## Best Practices
- Deploy **sensors** at network choke points (tap/span)
- Tune **Suricata rules** to reduce false positives
- Use **Zeek logs** for behavioral analysis beyond signatures
- Configure **PCAP retention** based on storage capacity
