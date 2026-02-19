---
name: IBM Resilient
description: Skill for IBM Resilient (now IBM SOAR) — incident response automation and orchestration with playbooks, case management, and API integration.
---

# IBM Resilient — Incident Response Automation

## Overview
IBM Resilient (IBM SOAR) provides incident response orchestration and automation with dynamic playbooks, case management, and 300+ integrations for SOC teams.

## API
```python
import resilient

client = resilient.get_client({
    "host": "resilient.example.com",
    "org": "Default",
    "email": "admin@example.com",
    "password": "password"
})

# Create incident
incident = client.post("/incidents", {
    "name": "Malware Detected",
    "description": "Malware found on workstation",
    "severity_code": {"name": "High"},
    "incident_type_ids": [17]  # Malware
})

# Get incidents
incidents = client.get("/incidents?return_level=normal")
```

## Best Practices
- Use **dynamic playbooks** that adapt based on incident type
- Configure **data tables** for structured artifact tracking
- Integrate with **SIEM** for automated incident creation
