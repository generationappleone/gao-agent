---
name: Shodan
description: Skill for Shodan — Internet-wide device search engine and API for discovering exposed services, vulnerabilities, and attack surface mapping.
---

# Shodan — Internet Asset Search & Intelligence

## Overview
Shodan is the search engine for Internet-connected devices, providing visibility into exposed services, vulnerabilities, and the global attack surface.

## API
```python
import shodan
api = shodan.Shodan('YOUR_API_KEY')

# Search for exposed devices
results = api.search('apache country:ID port:80')
for result in results['matches']:
    print(f"{result['ip_str']}:{result['port']} - {result.get('org', 'N/A')}")

# Host information
host = api.host('8.8.8.8')
print(f"OS: {host.get('os', 'N/A')}")
for item in host['data']:
    print(f"Port {item['port']}: {item.get('product', 'unknown')}")

# Search for vulnerabilities
vulns = api.search('vuln:CVE-2021-44228')

# Monitor alerts
alert = api.create_alert('My Network', '203.0.113.0/24')
```

### API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/shodan/host/{ip}` | Host information |
| `/shodan/host/search` | Search for devices |
| `/dns/resolve` | DNS resolution |
| `/tools/httpheaders` | HTTP headers of caller |
| `/api-info` | API subscription info |

## Best Practices
- Use **Shodan Monitor** for continuous attack surface monitoring
- Enable **alerts** for new exposed services in your IP ranges
- Check your organization's exposure **before attackers do**
