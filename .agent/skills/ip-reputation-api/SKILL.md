---
name: IP Reputation APIs
description: Skill for IP reputation and threat lookup APIs — AbuseIPDB, GreyNoise, IPQualityScore, IPinfo, and Have I Been Pwned for security enrichment.
---

# IP Reputation & Threat Lookup APIs

## AbuseIPDB — IP Blacklist Lookup
```python
import requests
headers = {"Key": "YOUR_ABUSEIPDB_KEY", "Accept": "application/json"}

# Check IP reputation
report = requests.get("https://api.abuseipdb.com/api/v2/check",
    headers=headers, params={"ipAddress": "1.2.3.4", "maxAgeInDays": 90})
# Returns: abuseConfidenceScore (0-100), totalReports, countryCode
```

## GreyNoise — Noise vs Malicious IP
```python
from greynoise import GreyNoise
gn = GreyNoise(api_key="YOUR_KEY")

# IP context
context = gn.ip("1.2.3.4")  # classification: benign/malicious/unknown
# Quick check
gn.quick("1.2.3.4")  # noise: true/false
```

## IPQualityScore — Fraud & IP Risk
```python
result = requests.get(
    f"https://ipqualityscore.com/api/json/ip/YOUR_KEY/1.2.3.4",
    params={"strictness": 1, "allow_public_access_points": True}
)
# Returns: fraud_score, proxy, vpn, tor, bot_status
```

## IPinfo — IP Geolocation & ASN
```python
import ipinfo
handler = ipinfo.getHandler("YOUR_TOKEN")
details = handler.getDetails("8.8.8.8")
print(f"{details.city}, {details.region}, {details.country} | ASN: {details.org}")
```

## Have I Been Pwned — Email Breach Check
```python
headers = {"hibp-api-key": "YOUR_KEY", "user-agent": "MyApp"}
breaches = requests.get(
    "https://haveibeenpwned.com/api/v3/breachedaccount/user@example.com",
    headers=headers
)
# Returns: list of breaches with name, date, dataClasses
```

## Best Practices
- Use multiple sources for **cross-validation** of reputation
- Cache results to **respect rate limits**
- Integrate into **SIEM/SOAR** for automated enrichment
