---
name: Snort
description: Skill for Snort — open-source network IDS/IPS with rule-based detection, packet analysis, and real-time traffic inspection.
---

# Snort — Network IDS/IPS

## Overview
Snort is the most widely deployed open-source IDS/IPS, performing real-time traffic analysis and packet logging with a flexible rule-based detection engine.

## Rule Syntax
```
# Basic rule structure
# action proto src_ip src_port -> dst_ip dst_port (options)

# Detect SSH brute force
alert tcp any any -> $HOME_NET 22 (msg:"SSH brute force attempt"; \
  flow:to_server,established; content:"SSH-"; threshold:type both, \
  track by_src, count 5, seconds 60; sid:1000001; rev:1;)

# Detect SQL injection in HTTP
alert tcp any any -> $HOME_NET $HTTP_PORTS (msg:"SQL Injection attempt"; \
  flow:to_server,established; content:"UNION"; nocase; content:"SELECT"; \
  nocase; sid:1000002; rev:1;)

# Detect outbound C2 beacon
alert tcp $HOME_NET any -> $EXTERNAL_NET any (msg:"Possible C2 beacon"; \
  flow:to_server,established; dsize:<64; threshold:type both, \
  track by_src, count 10, seconds 300; sid:1000003; rev:1;)
```

## Configuration
```yaml
# snort.conf key settings
var HOME_NET [192.168.1.0/24,10.0.0.0/8]
var EXTERNAL_NET !$HOME_NET
var HTTP_PORTS [80,443,8080,8443]
config detection: search-method ac-bnfa
```

## Best Practices
- Keep **VRT/ET rules** updated regularly
- Use **threshold** and **suppress** to manage alert volume
- Implement in **inline (IPS)** mode for active blocking
- Monitor Snort **performance stats** for packet drops
