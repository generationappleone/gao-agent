---
name: Suricata
description: Skill for Suricata — high-performance IDS/IPS and network threat detection engine with multi-threaded architecture and protocol analysis.
---

# Suricata — IDS/IPS & Network Threat Detection

## Overview
Suricata is a high-performance, multi-threaded IDS/IPS engine capable of protocol identification, file extraction, and network security monitoring with Snort-compatible rules.

## Rule Syntax
```
# Alert on DNS queries to suspicious TLDs
alert dns any any -> any any (msg:"Suspicious DNS query to .xyz TLD"; \
  dns.query; content:".xyz"; nocase; endswith; sid:2100001; rev:1;)

# Detect TLS connections with self-signed certs
alert tls any any -> any any (msg:"Self-signed TLS certificate"; \
  tls.cert_subject; content:"CN="; tls.cert_issuer; content:"CN="; \
  tls_cert_self_signed; sid:2100002; rev:1;)

# HTTP file extraction
alert http any any -> any any (msg:"Executable download"; \
  filemagic:"PE32"; filestore; sid:2100003; rev:1;)
```

## Eve JSON Output
```json
{
  "event_type": "alert",
  "src_ip": "192.168.1.100",
  "dest_ip": "10.0.0.1",
  "alert": {
    "signature": "ET MALWARE Win32.Emotet",
    "severity": 1,
    "category": "A Network Trojan was Detected"
  }
}
```

## Configuration (suricata.yaml)
```yaml
af-packet:
  - interface: eth0
    threads: auto
    cluster-type: cluster_flow

outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
      types:
        - alert
        - dns
        - tls
        - http
        - flow
```

## Best Practices
- Use **EVE JSON** output for SIEM integration
- Enable **protocol detection** for all supported protocols
- Tune **threading** based on CPU cores
- Use **file extraction** for malware analysis
