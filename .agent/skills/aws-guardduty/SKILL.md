---
name: AWS GuardDuty
description: Skill for AWS GuardDuty — cloud threat detection service with ML-based anomaly detection, API automation, and Security Hub integration.
---

# AWS GuardDuty — Cloud Threat Detection

## Overview
AWS GuardDuty is a managed threat detection service using machine learning to monitor AWS accounts, workloads, and data for malicious activity.

## API (boto3)
```python
import boto3

gd = boto3.client('guardduty')

# Get detector
detectors = gd.list_detectors()
detector_id = detectors['DetectorIds'][0]

# Get findings
findings = gd.list_findings(
    DetectorId=detector_id,
    FindingCriteria={
        'Criterion': {
            'severity': {'Gte': 7},
            'type': {'Eq': ['Recon:EC2/PortProbeUnprotectedPort']}
        }
    }
)

# Get finding details
details = gd.get_findings(
    DetectorId=detector_id,
    FindingIds=findings['FindingIds']
)
```

## Google Cloud Security Command Center
```python
from google.cloud import securitycenter_v1

client = securitycenter_v1.SecurityCenterClient()
org = "organizations/123456789"

# List findings
findings = client.list_findings(
    request={"parent": f"{org}/sources/-",
             "filter": 'severity="CRITICAL" AND state="ACTIVE"'}
)
```

## Best Practices
- Enable **GuardDuty** on all AWS accounts + regions
- Feed findings into **Security Hub** for centralized view
- Automate remediation via **EventBridge + Lambda**
