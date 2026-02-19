---
name: Vectra AI
description: Skill for Vectra AI — network detection and response (NDR/XDR) using AI for detecting cyberattacks across network, cloud, and identity.
---

# Vectra AI — NDR/XDR

## Overview
Vectra AI provides AI-driven NDR/XDR that detects attacker behaviors across network, cloud (AWS, Azure, GCP), SaaS (M365), and identity layers without relying on signatures.

## Key Capabilities
- **Cognito Detect**: AI-driven network threat detection
- **Cognito Recall**: AI-assisted threat hunting
- **Cognito Stream**: Enriched network metadata
- **Attack Signal Intelligence**: Prioritized detections by urgency

## API Integration
```python
import requests

headers = {"Authorization": "Token YOUR_API_TOKEN"}

# Get detections sorted by threat score
detections = requests.get(
    "https://vectra.example.com/api/v2.5/detections",
    headers=headers,
    params={"ordering": "-threat", "state": "active"}
)

# Get hosts with highest urgency
hosts = requests.get(
    "https://vectra.example.com/api/v2.5/hosts",
    headers=headers,
    params={"ordering": "-urgency_score"}
)
```

## Best Practices
- Prioritize response based on **urgency + certainty scores**
- Use **Recall** for retrospective threat hunting
- Integrate with SOAR for **automated containment playbooks**
