---
name: Fraud Detection APIs
description: Skill for fraud detection APIs — SEON, Sift, Forter, and Experian for transaction fraud prevention, identity verification, and risk scoring.
---

# Fraud Detection APIs

## SEON Fraud API
```python
import requests
headers = {"X-API-KEY": "YOUR_SEON_KEY"}

# Email analysis (digital footprint)
result = requests.get("https://api.seon.io/SeonRestService/email-api/v2.2/user@example.com",
    headers=headers)
# Returns: fraud_score, social_media_profiles, data_breach_status

# Transaction fraud check
fraud = requests.post("https://api.seon.io/SeonRestService/fraud-api/v2/",
    headers=headers, json={"ip": "1.2.3.4", "email": "user@example.com", "action_type": "purchase"})
```

## Sift Risk API
```python
import sift
client = sift.Client(api_key="YOUR_SIFT_KEY")

# Score a transaction
response = client.score("user123", abuse_types=["payment_abuse", "account_takeover"])
print(f"Risk score: {response.body['scores']['payment_abuse']['score']}")

# Track event
client.track("$transaction", {
    "$user_id": "user123",
    "$amount": 50000,  # microdollars
    "$currency_code": "USD",
    "$payment_method": {"$payment_type": "$credit_card"}
})
```

## Forter Fraud Prevention API
```python
# Pre-authorization fraud decision
decision = requests.post("https://api.forter.com/v2/orders/ORDER_ID",
    auth=("SITE_ID", "SECRET_KEY"),
    json={"orderId": "ORD-123", "totalAmount": {"amountUSD": "99.99"}})
# Returns: approve/decline/not_reviewed
```

## Experian Fraud & Identity API
```python
# CrossCore fraud assessment
result = requests.post("https://api.experian.com/fraud/v1/assessment",
    headers={"Authorization": f"Bearer {token}"},
    json={"header": {"tenantId": "TENANT"}, "payload": {"applicant": {"email": "user@example.com"}}})
```

## Best Practices
- Implement **multi-layer** fraud checks (device + behavioral + identity)
- Use **risk scores** for tiered decisions (auto-approve, review, block)
- Log all fraud decisions for **model training** and audit
