---
name: Google Cloud Platform (GCP)
description: Skill for Google Cloud Platform — covering Cloud Run, Cloud Functions, Cloud Storage, Firestore, BigQuery, Pub/Sub, IAM, Cloud SQL, and gcloud CLI.
---

# Google Cloud Platform (GCP) Skill

## Overview
Google Cloud Platform provides compute (Cloud Run, Cloud Functions), storage (Cloud Storage), databases (Firestore, Cloud SQL, BigQuery), messaging (Pub/Sub), and IAM. GCP excels in data analytics, AI/ML, and container workloads.

**References**:
- [GCP Documentation](https://cloud.google.com/docs)
- [Google Cloud Node.js Client](https://github.com/googleapis/google-cloud-node)

---

## Cloud Storage

```typescript
import { Storage } from '@google-cloud/storage';

const storage = new Storage();
const bucket = storage.bucket(process.env.GCS_BUCKET!);

export async function uploadFile(destPath: string, data: Buffer, contentType: string) {
  const file = bucket.file(destPath);
  await file.save(data, { contentType, resumable: false });
  await file.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${destPath}`;
}

export async function getSignedUrl(path: string, expiresMinutes = 60) {
  const [url] = await bucket.file(path).getSignedUrl({
    action: 'read', expires: Date.now() + expiresMinutes * 60 * 1000,
  });
  return url;
}

export async function deleteFile(path: string) {
  await bucket.file(path).delete();
}
```

---

## Cloud Functions

```typescript
import { HttpFunction } from '@google-cloud/functions-framework';

export const getProducts: HttpFunction = async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') { res.status(204).send(''); return; }
  const products = await db.product.findMany({ where: { status: 'active' } });
  res.json({ data: products });
};
```

---

## Pub/Sub

```typescript
import { PubSub } from '@google-cloud/pubsub';

const pubsub = new PubSub();

export async function publishMessage(topicName: string, data: object) {
  const topic = pubsub.topic(topicName);
  await topic.publishMessage({ json: data });
}

export function subscribeToTopic(subscriptionName: string, handler: (data: any) => Promise<void>) {
  const subscription = pubsub.subscription(subscriptionName);
  subscription.on('message', async (message) => {
    try {
      await handler(JSON.parse(message.data.toString()));
      message.ack();
    } catch { message.nack(); }
  });
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Service Accounts** | Use per-service SA with minimal roles |
| **Cloud Run** | Container-based serverless, auto-scaling |
| **Cloud Storage** | Signed URLs for temporary access |
| **Pub/Sub** | Async messaging between services |
| **BigQuery** | Analytics and data warehouse queries |
| **Firestore** | Document DB with real-time subscriptions |
| **IAM** | Principle of least privilege |
| **Secret Manager** | Store API keys and credentials |
| **gcloud CLI** | `gcloud` commands for automation |
| **Cloud SQL** |PostgreSQL/MySQL managed databases |

---

## Rules Integration
- **Storage**: Cloud Storage upload/signed URLs
- **Compute**: Cloud Functions/Cloud Run
- **Messaging**: Pub/Sub publish/subscribe
- **Security**: Service accounts, IAM, Secret Manager
