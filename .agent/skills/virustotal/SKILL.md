---
name: VirusTotal
description: Skill for VirusTotal — malware and file intelligence API for scanning files, URLs, domains, IP addresses, and hash reputation checks.
---

# VirusTotal — Malware & File Intelligence

## Overview
VirusTotal aggregates 70+ antivirus engines, URL/domain scanners, and threat intelligence feeds to analyze files, URLs, IPs, and domains for malicious content.

## API v3
```python
import requests

headers = {"x-apikey": "YOUR_API_KEY"}

# Scan a file
files = {"file": open("suspicious.exe", "rb")}
upload = requests.post(
    "https://www.virustotal.com/api/v3/files",
    headers=headers, files=files
)

# Check file hash reputation
file_report = requests.get(
    "https://www.virustotal.com/api/v3/files/SHA256_HASH",
    headers=headers
)

# URL scan
url_scan = requests.post(
    "https://www.virustotal.com/api/v3/urls",
    headers=headers,
    data={"url": "https://suspicious-site.com"}
)

# IP address report
ip_report = requests.get(
    "https://www.virustotal.com/api/v3/ip_addresses/1.2.3.4",
    headers=headers
)

# Domain report
domain = requests.get(
    "https://www.virustotal.com/api/v3/domains/example.com",
    headers=headers
)
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/api/v3/files` | Upload & scan files |
| `/api/v3/files/{id}` | Get file analysis report |
| `/api/v3/urls` | Submit & scan URLs |
| `/api/v3/ip_addresses/{ip}` | IP reputation |
| `/api/v3/domains/{domain}` | Domain reputation |

## Best Practices
- Use **hash lookups** before full file uploads (saves API quota)
- Implement **VT Intelligence** for threat hunting
- Cache results to respect **API rate limits** (4 req/min free)
