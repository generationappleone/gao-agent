---
name: DFLabs IncMan SOAR
description: Skill for DFLabs IncMan SOAR — security orchestration, automation, and response platform with case management and playbook automation.
---

# DFLabs IncMan SOAR

## Overview
DFLabs IncMan (now Sumo Logic Cloud SOAR) is a security orchestration, automation, and response platform providing incident management, playbook automation, and integration with security tools.

## Key Capabilities
- **Case Management**: Incident lifecycle tracking
- **Playbook Automation**: Visual playbook builder
- **Integration Hub**: 200+ security tool integrations
- **War Room**: Collaborative investigation workspace
- **Reporting**: Compliance and metrics dashboards

## API
```python
import requests
headers = {"Authorization": f"Bearer {token}"}

# Create incident
incident = requests.post("https://incman/api/incidents",
    headers=headers,
    json={"title": "Malware Alert", "severity": "High", "type": "Malware"})

# Execute playbook
requests.post(f"https://incman/api/incidents/{incident_id}/playbooks/{playbook_id}/execute",
    headers=headers)
```

## Best Practices
- Build **modular playbooks** for different incident types
- Integrate with **SIEM** for automated incident creation
- Track **MTTR** (Mean Time to Respond) metrics
