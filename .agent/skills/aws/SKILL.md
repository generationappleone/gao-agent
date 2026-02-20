---
name: AWS Services
description: Skill for Amazon Web Services — covering EC2, S3, Lambda, RDS, CloudFront, IAM, API Gateway, DynamoDB, SQS, SNS, ECS/Fargate, and AWS CLI patterns.
---

# AWS Services Skill

## Overview
Amazon Web Services (AWS) is the leading cloud platform providing compute (EC2, Lambda), storage (S3), databases (RDS, DynamoDB), networking (VPC, CloudFront), messaging (SQS, SNS), containers (ECS/Fargate), and IAM for security.

**References**:
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS SDK for JavaScript v3](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)

---

## S3 (File Storage)

```typescript
import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3 = new S3Client({ region: process.env.AWS_REGION });
const BUCKET = process.env.AWS_S3_BUCKET!;

export async function uploadFile(key: string, body: Buffer, contentType: string) {
  await s3.send(new PutObjectCommand({ Bucket: BUCKET, Key: key, Body: body, ContentType: contentType }));
  return `https://${BUCKET}.s3.amazonaws.com/${key}`;
}

export async function getPresignedUrl(key: string, expiresIn = 3600) {
  return getSignedUrl(s3, new GetObjectCommand({ Bucket: BUCKET, Key: key }), { expiresIn });
}

export async function deleteFile(key: string) {
  await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
}
```

---

## Lambda

```typescript
// handler.ts
import { APIGatewayProxyHandler } from 'aws-lambda';

export const handler: APIGatewayProxyHandler = async (event) => {
  const body = JSON.parse(event.body || '{}');
  return { statusCode: 200, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ message: 'Success', data: body }) };
};
```

---

## SQS (Message Queue)

```typescript
import { SQSClient, SendMessageCommand, ReceiveMessageCommand, DeleteMessageCommand } from '@aws-sdk/client-sqs';

const sqs = new SQSClient({ region: process.env.AWS_REGION });
const QUEUE_URL = process.env.SQS_QUEUE_URL!;

export async function sendMessage(data: object) {
  await sqs.send(new SendMessageCommand({ QueueUrl: QUEUE_URL, MessageBody: JSON.stringify(data) }));
}

export async function receiveMessages() {
  const { Messages } = await sqs.send(new ReceiveMessageCommand({ QueueUrl: QUEUE_URL, MaxNumberOfMessages: 10, WaitTimeSeconds: 20 }));
  return Messages?.map(m => ({ id: m.MessageId, body: JSON.parse(m.Body!), receipt: m.ReceiptHandle })) || [];
}
```

---

## DynamoDB

```typescript
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, QueryCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const ddb = DynamoDBDocumentClient.from(client);

export async function getItem(pk: string, sk: string) {
  const { Item } = await ddb.send(new GetCommand({ TableName: 'MyTable', Key: { PK: pk, SK: sk } }));
  return Item;
}

export async function putItem(item: Record<string, any>) {
  await ddb.send(new PutCommand({ TableName: 'MyTable', Item: item }));
}

export async function queryItems(pk: string) {
  const { Items } = await ddb.send(new QueryCommand({ TableName: 'MyTable', KeyConditionExpression: 'PK = :pk', ExpressionAttributeValues: { ':pk': pk } }));
  return Items;
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **IAM** | Least privilege, use roles not access keys |
| **S3** | Presigned URLs for secure access |
| **Lambda** | Keep functions small, use layers |
| **SQS** | Long polling, DLQ for failures |
| **DynamoDB** | Single-table design, partition key strategy |
| **Secrets** | Use AWS Secrets Manager, never hardcode |
| **VPC** | Private subnets for databases |
| **CloudFront** | CDN for static assets and API caching |
| **Tags** | Tag all resources for cost tracking |
| **SDK v3** | Use modular imports |

---

## Rules Integration
- **Storage**: S3 upload/download with presigned URLs
- **Compute**: Lambda handlers for serverless functions  
- **Messaging**: SQS send/receive with long polling
- **Database**: DynamoDB single-table design
- **Security**: IAM roles, Secrets Manager, VPC
