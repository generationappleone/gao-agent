---
name: Network Security Appliances
description: Skill for network security appliance APIs — Cisco ACI, Fortinet FortiManager, Palo Alto PAN-OS, Cloudflare, and Equinix Fabric.
---

# Network Security Appliance APIs

## Cisco ACI API
```python
import requests

# Authenticate
auth = requests.post("https://apic/api/aaaLogin.json",
    json={"aaaUser": {"attributes": {"name": "admin", "pwd": "pass"}}})
token = auth.json()["imdata"][0]["aaaLogin"]["attributes"]["token"]
cookies = {"APIC-cookie": token}

# Get tenants
tenants = requests.get("https://apic/api/node/class/fvTenant.json", cookies=cookies)
```

## Fortinet FortiManager API
```python
# Execute API
result = requests.post("https://fortimanager/jsonrpc", json={
    "method": "get",
    "params": [{"url": "/pm/config/adom/root/pkg/default/firewall/policy"}],
    "session": session_token
})
```

## Palo Alto PAN-OS API
```python
# Get security rules
rules = requests.get(
    f"https://firewall/restapi/v10.2/Policies/SecurityRules?location=vsys&vsys=vsys1",
    headers={"X-PAN-KEY": api_key}
)
```

## Cloudflare API
```python
headers = {"Authorization": f"Bearer {CF_TOKEN}"}
# DNS records
requests.get("https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records",
    headers=headers)
# Firewall rules
requests.get("https://api.cloudflare.com/client/v4/zones/{zone_id}/firewall/rules",
    headers=headers)
```

## Equinix Fabric API
```python
# Get connections
requests.get("https://api.equinix.com/fabric/v4/connections",
    headers={"Authorization": f"Bearer {token}"})
```

## Best Practices
- Use **infrastructure-as-code** for firewall rule management
- Implement **change management** for policy modifications
- Enable **log forwarding** to SIEM for all security appliances
