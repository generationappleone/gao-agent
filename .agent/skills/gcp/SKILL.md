---
name: Google Cloud Platform (GCP)
description: Skill for Google Cloud Platform — covering Cloud Run, Cloud Functions, Cloud Storage, Firestore, BigQuery, Pub/Sub, IAM, Cloud SQL, and gcloud CLI.
---

# Google Cloud Platform (GCP) Skill

## Overview
Google Cloud Platform provides cloud computing services for application development, data analytics, and machine learning.

**Reference**: [GCP Documentation](https://cloud.google.com/docs)

## gcloud CLI
```bash
gcloud init
gcloud config set project my-project-id
gcloud config set compute/region asia-southeast1
gcloud auth application-default login
```

## Cloud Run (Containerized Apps)
```bash
# Deploy from Dockerfile
gcloud run deploy my-service \
  --source . \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --set-env-vars "NODE_ENV=production,DB_HOST=10.0.0.1" \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10
```

## Cloud Functions (Serverless)
```typescript
// index.ts
import { HttpFunction } from "@google-cloud/functions-framework";
export const handler: HttpFunction = (req, res) => {
  const { name } = req.body;
  res.json({ message: `Hello, ${name}!` });
};
```

## Cloud Storage
```typescript
import { Storage } from "@google-cloud/storage";
const storage = new Storage();
const bucket = storage.bucket("my-bucket");

// Upload
await bucket.upload("./file.txt", { destination: "uploads/file.txt" });

// Signed URL
const [url] = await bucket.file("uploads/file.txt").getSignedUrl({
  action: "read", expires: Date.now() + 3600 * 1000,
});
```

## Firestore
```typescript
import { Firestore } from "@google-cloud/firestore";
const db = new Firestore();

// Create
await db.collection("users").doc(userId).set({ name, email, createdAt: new Date() });

// Read
const doc = await db.collection("users").doc(userId).get();

// Query
const snapshot = await db.collection("users").where("role", "==", "admin").orderBy("createdAt", "desc").limit(20).get();
```

## Common Services

| Service | Purpose |
|---------|---------|
| **Cloud Run** | Container hosting (serverless) |
| **Cloud Functions** | Event-driven serverless |
| **Cloud Storage** | Object storage (like S3) |
| **Firestore** | NoSQL document database |
| **Cloud SQL** | Managed PostgreSQL/MySQL |
| **BigQuery** | Data warehouse & analytics |
| **Pub/Sub** | Message queue / event streaming |
| **Cloud Build** | CI/CD pipelines |
| **Secret Manager** | Secrets storage |
| **IAM** | Identity & access management |

## Best Practices

| Practice | Description |
|----------|-------------|
| **Service accounts** | Use per-service accounts with least privilege |
| **Secret Manager** | Store secrets, reference in Cloud Run/Functions |
| **VPC** | Use VPC connectors for private resources |
| **Cloud Build** | Automate CI/CD with `cloudbuild.yaml` |
| **Monitoring** | Cloud Monitoring + Error Reporting for alerts |
| **Regions** | Deploy close to users for low latency |
| **IAM** | Minimal roles per service account |
| **Billing alerts** | Set budget alerts to prevent overruns |
