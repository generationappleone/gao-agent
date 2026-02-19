---
name: Zeek
description: Skill for Zeek (formerly Bro) — network analysis framework for traffic inspection, protocol logging, and security monitoring.
---

# Zeek — Network Analysis Framework

## Overview
Zeek (formerly Bro) is a powerful, open-source network analysis framework that generates detailed protocol logs, detects anomalies, and enables custom scripting for security monitoring.

## Log Types
| Log File | Description |
|----------|-------------|
| `conn.log` | TCP/UDP/ICMP connection summaries |
| `dns.log` | DNS queries and responses |
| `http.log` | HTTP requests and responses |
| `ssl.log` | SSL/TLS handshake details |
| `files.log` | File analysis across protocols |
| `notice.log` | Zeek-generated alerts |
| `weird.log` | Unexpected protocol behaviors |

## Zeek Scripts
```zeek
# Detect DNS tunneling
event dns_request(c: connection, msg: dns_msg, query: string, qtype: count)
{
    if (|query| > 100)
        NOTICE([$note=DNS::Tunneling_Suspected,
                $msg=fmt("Long DNS query from %s: %s", c$id$orig_h, query),
                $conn=c]);
}

# Alert on large file downloads
event file_over_new_connection(f: fa_file, c: connection, is_orig: bool)
{
    if (f$total_bytes > 100000000)
        NOTICE([$note=File::Large_Download,
                $msg=fmt("Large file (%.2f MB) from %s",
                         f$total_bytes/1048576.0, c$id$resp_h),
                $conn=c]);
}
```

## CLI Usage
```bash
# Process a pcap file
zeek -r capture.pcap

# Live capture on interface
zeek -i eth0 local.zeek

# With custom scripts
zeek -i eth0 detect-dns-tunneling.zeek
```

## Best Practices
- Use **Zeek logs + Elasticsearch** for searchable network metadata
- Write **custom scripts** for environment-specific detections
- Enable **file extraction** for malware analysis pipelines
- Use **Intel framework** to match traffic against IOC feeds
