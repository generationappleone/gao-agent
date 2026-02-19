---
name: Microsoft Defender for Endpoint
description: Skill for Microsoft Defender for Endpoint — EDR/XDR, Advanced Hunting (KQL), threat analytics, automated investigation, and Microsoft 365 Defender API.
---

# Microsoft Defender for Endpoint — EDR/XDR

## Overview
Microsoft Defender for Endpoint (MDE) is an enterprise EDR/XDR solution within the Microsoft 365 Defender suite, providing endpoint protection, advanced hunting, and automated investigation.

## Advanced Hunting (KQL)
```kql
// Suspicious PowerShell activity
DeviceProcessEvents
| where FileName == "powershell.exe"
| where ProcessCommandLine has_any ("-enc", "-encodedcommand", "bypass")
| project Timestamp, DeviceName, AccountName, ProcessCommandLine
| order by Timestamp desc

// Lateral movement detection
DeviceNetworkEvents
| where RemotePort in (445, 3389, 5985)
| where ActionType == "ConnectionSuccess"
| summarize ConnectionCount = count() by DeviceName, RemoteIP
| where ConnectionCount > 10

// Ransomware file encryption detection
DeviceFileEvents
| where ActionType == "FileCreated"
| where FileName endswith ".encrypted" or FileName endswith ".locked"
| summarize FileCount = count() by DeviceName, bin(Timestamp, 5m)
| where FileCount > 50
```

## Microsoft 365 Defender API
```python
import requests
from msal import ConfidentialClientApplication

# Authenticate via MSAL
app = ConfidentialClientApplication(
    client_id="YOUR_CLIENT_ID",
    client_credential="YOUR_CLIENT_SECRET",
    authority="https://login.microsoftonline.com/YOUR_TENANT_ID"
)
token = app.acquire_token_for_client(
    scopes=["https://api.securitycenter.microsoft.com/.default"]
)
headers = {"Authorization": f"Bearer {token['access_token']}"}

# Get alerts
alerts = requests.get(
    "https://api.securitycenter.microsoft.com/api/alerts",
    headers=headers
)

# Run advanced hunting query
query = requests.post(
    "https://api.securitycenter.microsoft.com/api/advancedqueries/run",
    headers=headers,
    json={"Query": "DeviceProcessEvents | take 10"}
)
```

### Key API Endpoints
| Endpoint | Description |
|----------|-------------|
| `/api/alerts` | Alert management |
| `/api/machines` | Device management |
| `/api/advancedqueries/run` | Run KQL queries |
| `/api/vulnerabilities` | Vulnerability data |
| `/api/incidents` | Incident management |
| `/api/indicators` | Custom IOC management |

## Microsoft Defender for Cloud API
```bash
# List security alerts
az security alert list --resource-group myRG

# Get secure score
az security secure-score list
```

## Best Practices
- Enable **Attack Surface Reduction (ASR)** rules
- Configure **Automated Investigation and Remediation (AIR)**
- Use **Threat & Vulnerability Management (TVM)** proactively
- Integrate with **Microsoft Sentinel** for SIEM correlation
