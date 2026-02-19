---
name: Microsoft Sentinel
description: Skill for Microsoft Sentinel — cloud-native SIEM and SOAR with KQL queries, analytics rules, playbooks (Logic Apps), and Threat Intelligence integration.
---

# Microsoft Sentinel — Cloud SIEM + SOAR

## Overview
Microsoft Sentinel is Azure's cloud-native SIEM and SOAR solution providing intelligent security analytics, threat detection, automated response via Logic Apps playbooks, and integration with Microsoft 365 Defender.

## KQL (Kusto Query Language)
```kql
// Failed sign-in attempts
SigninLogs
| where ResultType != 0
| summarize FailedAttempts = count() by UserPrincipalName, IPAddress, bin(TimeGenerated, 1h)
| where FailedAttempts > 5
| order by FailedAttempts desc

// Suspicious process execution
SecurityEvent
| where EventID == 4688
| where CommandLine has_any ("powershell", "cmd.exe")
| where CommandLine has_any ("-enc", "-bypass", "IEX", "downloadstring")
| project TimeGenerated, Computer, Account, CommandLine

// Data exfiltration detection
OfficeActivity
| where Operation in ("FileSyncDownloadedFull", "FileDownloaded")
| summarize DownloadCount = count(), TotalSize = sum(OfficeObjectId) by UserId, bin(TimeGenerated, 1h)
| where DownloadCount > 100
```

## Analytics Rules
```json
{
  "displayName": "Multiple failed logins followed by success",
  "severity": "High",
  "query": "SigninLogs | where ResultType != 0 | summarize FailCount = count() by UserPrincipalName, IPAddress | where FailCount > 5 | join (SigninLogs | where ResultType == 0) on UserPrincipalName, IPAddress",
  "queryFrequency": "PT5M",
  "triggerOperator": "GreaterThan",
  "triggerThreshold": 0
}
```

## REST API
```python
import requests
headers = {"Authorization": f"Bearer {token}"}

# List incidents
incidents = requests.get(
    f"https://management.azure.com/subscriptions/{sub_id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{ws}/providers/Microsoft.SecurityInsights/incidents?api-version=2023-11-01",
    headers=headers
)

# Run KQL query
query = requests.post(
    f"https://api.loganalytics.io/v1/workspaces/{workspace_id}/query",
    headers=headers,
    json={"query": "SecurityEvent | take 10"}
)
```

## Best Practices
- Use **Fusion** detection for multi-stage attack correlation
- Implement **SOAR playbooks** via Logic Apps for automated response
- Enable **UEBA** for user and entity behavioral analytics
- Configure **data connectors** for all Microsoft and third-party sources
