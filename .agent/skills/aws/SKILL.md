---
name: AWS Services
description: Skill for Amazon Web Services — covering EC2, S3, Lambda, RDS, CloudFront, IAM, API Gateway, DynamoDB, SQS, SNS, ECS/Fargate, and AWS CLI patterns.
---

# AWS Services Skill

## Overview
Amazon Web Services is the leading cloud platform. This skill covers core AWS services commonly used in application development and deployment.

**Reference**: [AWS Documentation](https://docs.aws.amazon.com/)

## AWS CLI Configuration
```bash
aws configure
# AWS Access Key ID: AKIA...
# AWS Secret Access Key: ...
# Default region name: ap-southeast-1
# Default output format: json
```

## S3 (Object Storage)
```bash
aws s3 mb s3://my-bucket-name
aws s3 cp ./file.txt s3://my-bucket/uploads/
aws s3 sync ./dist s3://my-bucket/static/ --delete
aws s3 ls s3://my-bucket/ --recursive
```
```typescript
// Node.js SDK v3
import { S3Client, PutObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const s3 = new S3Client({ region: "ap-southeast-1" });

// Upload
await s3.send(new PutObjectCommand({
  Bucket: "my-bucket", Key: `uploads/${filename}`, Body: fileBuffer, ContentType: "image/png",
}));

// Pre-signed URL (temporary access)
const url = await getSignedUrl(s3, new GetObjectCommand({ Bucket: "my-bucket", Key: "file.pdf" }), { expiresIn: 3600 });
```

## Lambda (Serverless Functions)
```typescript
// handler.ts
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    const body = JSON.parse(event.body || "{}");
    const result = await processData(body);
    return { statusCode: 200, headers: { "Content-Type": "application/json" }, body: JSON.stringify(result) };
  } catch (error) {
    return { statusCode: 500, body: JSON.stringify({ error: "Internal server error" }) };
  }
};
```

## IAM Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::my-bucket/*"
    },
    {
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"],
      "Resource": "arn:aws:dynamodb:*:*:table/MyTable"
    }
  ]
}
```

## Common Services Quick Reference

| Service | Purpose | Use Case |
|---------|---------|----------|
| **EC2** | Virtual servers | Application hosting |
| **S3** | Object storage | File uploads, static hosting |
| **RDS** | Managed databases | PostgreSQL, MySQL |
| **Lambda** | Serverless functions | API handlers, event processing |
| **API Gateway** | API management | REST/WebSocket APIs |
| **CloudFront** | CDN | Static asset delivery |
| **DynamoDB** | NoSQL database | Key-value, high throughput |
| **SQS** | Message queue | Async task processing |
| **SNS** | Pub/Sub | Notifications, fan-out |
| **ECS/Fargate** | Container orchestration | Docker deployments |
| **Cognito** | Authentication | User pools, social login |
| **Secrets Manager** | Secret storage | API keys, DB passwords |
| **CloudWatch** | Monitoring | Logs, metrics, alarms |

## Best Practices

| Practice | Description |
|----------|-------------|
| **Least privilege** | IAM policies with minimum permissions |
| **No hardcoded keys** | Use IAM roles, not access keys |
| **Encryption** | Enable at-rest encryption for S3, RDS, DynamoDB |
| **VPC** | Deploy resources in private subnets |
| **Tags** | Tag all resources for cost tracking |
| **Multi-AZ** | Enable for RDS, ECS for high availability |
| **CloudWatch** | Set alarms for critical metrics |
| **Secrets Manager** | Store secrets, never in code or env files |
| **Cost alerts** | Set billing alarms to prevent surprises |
| **Infrastructure as Code** | Use Terraform or CloudFormation |
