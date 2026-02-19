---
name: Elastic Security (ELK Stack)
description: Skill for Elastic Security — SIEM and security analytics built on the ELK Stack (Elasticsearch, Logstash, Kibana) with detection rules, timeline investigation, and API.
---

# Elastic Security — SIEM + Analytics (ELK Stack)

## Overview
Elastic Security provides SIEM, endpoint protection, and threat hunting built on the Elastic Stack (Elasticsearch, Logstash, Kibana, Beats) with pre-built detection rules and ML anomaly detection.

## Detection Rules (KQL/EQL)
```
-- KQL: Suspicious PowerShell
process.name: "powershell.exe" and process.args: ("-enc" or "-encodedcommand" or "bypass")

-- EQL: Process injection sequence
sequence by host.name with maxspan=5m
  [process where process.name == "explorer.exe"]
  [library where dll.name == "amsi.dll"]
  [process where process.name == "powershell.exe" and process.parent.name == "explorer.exe"]
```

## API
```python
import requests
headers = {"Authorization": f"ApiKey {api_key}", "kbn-xsrf": "true"}

# Get security alerts
alerts = requests.post("https://kibana:5601/api/detection_engine/signals/search",
    headers=headers,
    json={"query": {"match_all": {}}, "size": 50})

# Create detection rule
requests.post("https://kibana:5601/api/detection_engine/rules",
    headers=headers,
    json={
        "name": "Suspicious PowerShell",
        "type": "query",
        "query": 'process.name: "powershell.exe" and process.args: "-enc"',
        "severity": "high",
        "risk_score": 73,
        "index": ["winlogbeat-*"]
    })

# Elasticsearch search
requests.post("https://elasticsearch:9200/filebeat-*/_search",
    headers=headers,
    json={"query": {"match": {"event.category": "authentication"}}})
```

## Best Practices
- Use **Elastic Agent** for unified data collection
- Enable **ML anomaly detection** jobs for behavioral analysis
- Import **Elastic prebuilt rules** and customize thresholds
- Use **Timeline** for interactive investigation
