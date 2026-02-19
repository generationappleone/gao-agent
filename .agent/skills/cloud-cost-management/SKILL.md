---
name: Cloud Cost Management
description: Skill for cloud cost management — AWS Cost Explorer, Azure Cost Management, Google Cloud Billing, CloudHealth, and Apptio Cloudability APIs.
---

# Cloud Cost Management

## AWS Cost Explorer API
```python
import boto3
ce = boto3.client('ce')

# Get monthly costs
costs = ce.get_cost_and_usage(
    TimePeriod={'Start': '2024-01-01', 'End': '2024-02-01'},
    Granularity='MONTHLY',
    Metrics=['UnblendedCost'],
    GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
)
```

## Azure Cost Management API
```bash
az costmanagement query --type ActualCost --timeframe MonthToDate \
  --scope "subscriptions/{sub-id}" \
  --dataset-grouping name=ServiceName type=Dimension
```

## Google Cloud Billing API
```python
from google.cloud import billing_v1
client = billing_v1.CloudBillingClient()
info = client.get_billing_account(name="billingAccounts/BILLING_ID")
```

## Third-Party Platforms
- **CloudHealth** (VMware): Multi-cloud cost optimization, rightsizing, reserved instance management
- **Apptio Cloudability**: Cloud cost analytics, unit economics, showback/chargeback

## Best Practices
- Implement **tagging strategies** for cost allocation
- Use **rightsizing recommendations** for over-provisioned resources
- Configure **budget alerts** with automated responses
- Analyze **reserved instance / savings plan** coverage
