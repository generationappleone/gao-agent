---
name: Microsoft Purview
description: Skill for Microsoft Purview — data governance, compliance, DLP, information protection, eDiscovery, and API integration.
---

# Microsoft Purview — Data Governance & DLP

## Overview
Microsoft Purview (formerly Azure Purview + Microsoft 365 Compliance) provides unified data governance, data loss prevention (DLP), information protection, and compliance management.

## Key Components
- **Data Loss Prevention (DLP)**: Policy-based data protection
- **Information Protection**: Sensitivity labels and encryption
- **Data Lifecycle Management**: Retention policies
- **eDiscovery**: Legal hold and content search
- **Compliance Manager**: Regulatory assessment tracking

## API (Microsoft Graph)
```python
import requests
headers = {"Authorization": f"Bearer {token}"}

# Get DLP policies
policies = requests.get(
    "https://graph.microsoft.com/v1.0/informationProtection/policy/labels",
    headers=headers
)

# Get sensitivity labels
labels = requests.get(
    "https://graph.microsoft.com/beta/security/informationProtection/sensitivityLabels",
    headers=headers
)
```

## Best Practices
- Implement **sensitivity labels** across M365
- Configure **DLP policies** for PII/financial data
- Use **Compliance Manager** for regulatory tracking
