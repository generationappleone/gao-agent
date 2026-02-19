---
name: VMware Carbon Black
description: Skill for VMware Carbon Black — endpoint detection and response (EDR), threat hunting, and cloud-native endpoint protection.
---

# VMware Carbon Black — Endpoint Detection

## Overview
VMware Carbon Black (now part of Broadcom) provides cloud-native endpoint protection with EDR, next-gen AV, and audit/remediation capabilities.

## Query Syntax
```
-- Suspicious process execution
process_name:powershell.exe AND cmdline:*-bypass* AND cmdline:*-encoded*

-- Registry persistence
regmod_name:*\CurrentVersion\Run\*

-- File modification (ransomware-like behavior)
filemod_count:[100 TO *] AND process_name:*.exe
```

## API
```python
from cbapi import CbEnterpriseResponseAPI

cb = CbEnterpriseResponseAPI(
    url="https://cb-server",
    token="YOUR_API_TOKEN"
)

# Search processes
processes = cb.select(Process).where("process_name:cmd.exe")
for proc in processes:
    print(f"{proc.hostname} - {proc.cmdline}")

# Get alerts
alerts = cb.select(Alert).where("status:unresolved")
```

## Best Practices
- Use **watchlists** for continuous threat hunting
- Configure **Live Response** for remote investigation
- Enable **USB device blocking** policies
