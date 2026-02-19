---
name: Blackberry Cylance
description: Skill for Blackberry Cylance — AI-driven endpoint protection using mathematical models for pre-execution threat prevention.
---

# Blackberry Cylance — AI-Driven Endpoint

## Overview
Blackberry Cylance uses artificial intelligence and machine learning mathematical models to detect and prevent malware and advanced threats before execution — without signatures.

## Key Products
- **CylancePROTECT**: AI-based malware prevention
- **CylanceOPTICS**: EDR with automated detection and response
- **CylanceGATEWAY**: Zero Trust Network Access (ZTNA)
- **CylancePERSONA**: Continuous authentication via behavioral biometrics

## API Integration
```python
import requests
import jwt, time, uuid

# Generate JWT for authentication
claims = {
    "exp": int(time.time()) + 1800,
    "iss": "http://cylance.com",
    "sub": "YOUR_APP_ID",
    "tid": "YOUR_TENANT_ID",
    "jti": str(uuid.uuid4())
}
token = jwt.encode(claims, "YOUR_APP_SECRET", algorithm="HS256")

headers = {"Authorization": f"Bearer {token}"}

# Get devices
devices = requests.get(
    "https://protectapi.cylance.com/devices/v2",
    headers=headers
)

# Get threats
threats = requests.get(
    "https://protectapi.cylance.com/threats/v2",
    headers=headers
)
```

## Best Practices
- Use **Auto Quarantine** for high-confidence threats
- Configure **Script Control** to prevent LOLBin attacks
- Enable **Memory Exploitation** protection
