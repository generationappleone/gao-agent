---
name: Wazuh
description: Skill for Wazuh — open-source XDR, SIEM, and HIDS platform with agent-based monitoring, vulnerability detection, compliance, and API integration.
---

# Wazuh — Open-Source XDR/SIEM/HIDS

## Overview
Wazuh is a free, open-source security platform providing XDR, SIEM, and Host-based Intrusion Detection (HIDS) with centralized log analysis, vulnerability detection, and compliance monitoring.

## Key Capabilities
- **Intrusion Detection**: File integrity monitoring, rootkit detection
- **Log Analysis**: Syslog, Windows events, application logs
- **Vulnerability Detection**: CVE scanning on agents
- **Compliance**: PCI DSS, GDPR, HIPAA, NIST dashboards
- **Container Security**: Docker and Kubernetes monitoring
- **Cloud Security**: AWS, Azure, GCP log analysis

## Rules & Decoders
```xml
<!-- Custom rule for failed SSH login -->
<rule id="100001" level="10">
  <if_sid>5710</if_sid>
  <match>Failed password</match>
  <description>SSH brute force detected</description>
  <group>authentication_failed,</group>
</rule>

<!-- Decoder for custom log format -->
<decoder name="custom_app">
  <parent>json</parent>
  <plugin_decoder>JSON_Decoder</plugin_decoder>
</decoder>
```

## API
```python
import requests

# Authenticate
auth = requests.post("https://wazuh:55000/security/user/authenticate",
    auth=("wazuh-wui", "wazuh-wui"), verify=False)
token = auth.json()["data"]["token"]
headers = {"Authorization": f"Bearer {token}"}

# Get agents
agents = requests.get("https://wazuh:55000/agents",
    headers=headers, verify=False)

# Get alerts
alerts = requests.get("https://wazuh:55000/alerts",
    headers=headers, params={"limit": 50, "sort": "-timestamp"}, verify=False)

# Get vulnerability inventory
vulns = requests.get(f"https://wazuh:55000/vulnerability/{agent_id}",
    headers=headers, verify=False)
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/agents` | Agent management |
| `/alerts` | Alert queries |
| `/vulnerability/{agent_id}` | Agent vulnerability inventory |
| `/sca/{agent_id}` | Security Configuration Assessment |
| `/rootcheck/{agent_id}` | Rootkit detection results |
| `/syscheck/{agent_id}` | File integrity monitoring |
| `/rules` | Rule management |
| `/decoders` | Decoder management |

## Best Practices
- Deploy **agents** on all critical systems
- Customize **rules** based on your threat model
- Enable **SCA (Security Configuration Assessment)** for CIS benchmarks
- Integrate with **Elasticsearch + Kibana** for visualization
- Use **active response** for automated threat containment
