---
name: Cortex XSOAR
description: Skill for Palo Alto Cortex XSOAR — SOAR automation platform with playbooks, incident management, threat intelligence, and 700+ integrations.
---

# Cortex XSOAR — SOAR Automation Platform

## Overview
Palo Alto Cortex XSOAR (formerly Demisto) is a SOAR platform providing playbook automation, incident management, case management, and 700+ third-party integrations.

## Playbook Automation
```yaml
# Example playbook for phishing investigation
- name: Phishing Investigation
  tasks:
    - name: Extract Indicators
      script: ExtractIndicators
      args:
        text: ${incident.details}
    - name: Enrich IP
      script: IPReputation
      args:
        ip: ${indicators.ip}
    - name: Check URL
      script: URLReputation
      args:
        url: ${indicators.url}
    - name: Decision
      type: condition
      conditions:
        - field: reputation
          operator: greaterThan
          value: 2
      thenDo: Quarantine Email
      elseDo: Close Incident
```

## API
```python
import requests

headers = {"Authorization": "YOUR_API_KEY", "Content-Type": "application/json"}

# Create incident
incident = requests.post(
    "https://xsoar/incidents",
    headers=headers,
    json={"name": "Suspicious Login", "type": "Authentication", "severity": 3}
)

# Run playbook
requests.post(
    f"https://xsoar/incidents/{incident_id}/playbook",
    headers=headers,
    json={"playbookId": "Phishing_Investigation"}
)
```

## Best Practices
- Build **modular sub-playbooks** for reusable automation blocks
- Implement **War Room** for collaborative incident response
- Use **indicator lifecycle management** for IOC tracking
