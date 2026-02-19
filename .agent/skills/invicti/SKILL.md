---
name: Invicti
description: Skill for Invicti (formerly Netsparker) — web application security scanner with proof-based scanning, DAST, IAST, and API security testing.
---

# Invicti — Web Application Security Scanner

## Overview
Invicti (formerly Netsparker) is a web application security scanner with Proof-Based Scanning™ technology that automatically verifies vulnerabilities to eliminate false positives.

## API
```python
import requests

headers = {
    "Authorization": "Basic YOUR_API_TOKEN",
    "Content-Type": "application/json"
}
base_url = "https://your-instance.invicti.com/api/1.0"

# Create scan
scan = requests.post(
    f"{base_url}/scans/new",
    headers=headers,
    json={
        "TargetUri": "https://example.com",
        "ProfileId": "Default"
    }
)

# Get scan vulnerabilities
vulns = requests.get(
    f"{base_url}/scans/{scan_id}/vulnerabilities",
    headers=headers
)
```

## Key Features
- **Proof-Based Scanning**: Auto-verifies vulnerabilities
- **IAST Support**: Deeper detection with server-side agent
- **API Scanning**: OpenAPI/Swagger, GraphQL, SOAP
- **CI/CD Integration**: Jenkins, Azure DevOps, GitHub Actions

## Best Practices
- Use **Proof-Based Scanning** to eliminate false positives
- Configure **scan policies** per application risk level
- Enable **incremental scanning** for faster CI/CD scans
