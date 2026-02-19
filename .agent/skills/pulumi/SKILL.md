---
name: Pulumi
description: Skill for Pulumi — Infrastructure as Code using general-purpose programming languages (TypeScript, Python, Go, C#) with Pulumi Cloud API.
---

# Pulumi — IaC with Real Programming Languages

## Overview
Pulumi provides Infrastructure as Code using general-purpose languages (TypeScript, Python, Go, C#, Java) instead of DSLs, with full IDE support and testing.

## Example (TypeScript)
```typescript
import * as aws from "@pulumi/aws";

const bucket = new aws.s3.Bucket("my-bucket", {
    website: { indexDocument: "index.html" }
});

const instance = new aws.ec2.Instance("web-server", {
    ami: "ami-0c55b159cbfafe1f0",
    instanceType: "t2.micro",
    tags: { Name: "WebServer" }
});

export const bucketUrl = bucket.websiteEndpoint;
```

## Pulumi Cloud API
```python
import requests
headers = {"Authorization": f"token {PULUMI_ACCESS_TOKEN}"}

# List stacks
stacks = requests.get("https://api.pulumi.com/api/user/stacks",
    headers=headers)

# Get stack state
state = requests.get(
    f"https://api.pulumi.com/api/stacks/{org}/{project}/{stack}/export",
    headers=headers)
```

## Best Practices
- Use **Pulumi ESC** for environment and secrets management
- Implement **Policy as Code** with Pulumi CrossGuard
- Write **unit tests** for infrastructure using standard testing frameworks
