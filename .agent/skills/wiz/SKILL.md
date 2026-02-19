---
name: Wiz
description: Skill for Wiz — cloud security posture management (CSPM) with vulnerability management, IaC scanning, runtime protection, and API.
---

# Wiz — Cloud Security Posture Management

## Overview
Wiz provides agentless cloud security across AWS, Azure, GCP, and Kubernetes with CSPM, CWPP, vulnerability management, and IaC scanning in a unified graph.

## API
```python
import requests
headers = {"Authorization": f"Bearer {access_token}"}

# Get issues
issues = requests.get("https://api.wiz.io/v1/issues", headers=headers,
    params={"severity": "CRITICAL", "status": "OPEN"})

# Get resources
resources = requests.get("https://api.wiz.io/v1/graph/resources", headers=headers)
```

## Best Practices
- Use **Security Graph** for contextual risk prioritization
- Enable **IaC scanning** in CI/CD pipelines
- Implement **guardrails** for real-time misconfiguration prevention
