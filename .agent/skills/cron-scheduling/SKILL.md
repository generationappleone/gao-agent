---
name: Cron / Task Scheduling
description: Skill for task scheduling — covering cron syntax, Node.js schedulers (node-cron, Bull/BullMQ), Laravel scheduler, Python (APScheduler, Celery), and job queue patterns.
---

# Cron / Task Scheduling Skill

## Overview
Task scheduling automates recurring operations like email digests, report generation, data cleanup, and subscription billing. Node.js uses node-cron for in-process scheduling and BullMQ for distributed job queues backed by Redis.

**References**:
- [node-cron](https://github.com/node-cron/node-cron)
- [BullMQ](https://docs.bullmq.io/)

---

## node-cron

```typescript
import cron from 'node-cron';

// Daily report at 6 AM
cron.schedule('0 6 * * *', async () => {
  console.log('Generating daily report...');
  const report = await generateDailyReport();
  await sendEmail({ to: 'admin@myapp.com', subject: 'Daily Report', html: report });
});

// Every 5 minutes: cleanup expired sessions
cron.schedule('*/5 * * * *', async () => {
  await db.session.deleteMany({ where: { expiresAt: { lt: new Date() } } });
});

// Monthly billing (1st of each month at midnight)
cron.schedule('0 0 1 * *', async () => {
  const subscriptions = await db.subscription.findMany({ where: { status: 'active' } });
  for (const sub of subscriptions) await processSubscriptionBilling(sub);
});
```

---

## BullMQ (Distributed Queues)

```typescript
import { Queue, Worker } from 'bullmq';

const connection = { host: process.env.REDIS_HOST, port: Number(process.env.REDIS_PORT) };

// Queue
const emailQueue = new Queue('email', { connection });
const orderQueue = new Queue('order-processing', { connection });

// Add jobs
await emailQueue.add('welcome', { userId: user.id, email: user.email }, { attempts: 3, backoff: { type: 'exponential', delay: 1000 } });
await orderQueue.add('process', { orderId: order.id }, { delay: 5000 }); // delayed job

// Repeatable (cron-like)
await emailQueue.add('digest', {}, { repeat: { pattern: '0 8 * * *' } }); // daily at 8 AM

// Worker
const emailWorker = new Worker('email', async (job) => {
  switch (job.name) {
    case 'welcome': await sendWelcomeEmail(job.data.email); break;
    case 'digest': await sendDigestEmail(); break;
  }
}, { connection, concurrency: 5 });

emailWorker.on('completed', (job) => console.log(`Job ${job.id} completed`));
emailWorker.on('failed', (job, err) => console.error(`Job ${job?.id} failed:`, err.message));
```

---

## Cron Syntax

```
* * * * *
│ │ │ │ │
│ │ │ │ └── Day of week (0-7, Sun=0,7)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)

*/5 * * * *    Every 5 minutes
0 * * * *      Every hour
0 6 * * *      Daily at 6 AM
0 0 * * 0      Weekly on Sunday
0 0 1 * *      Monthly on 1st
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **node-cron** | In-process for simple schedules |
| **BullMQ** | Distributed queues with Redis |
| **Retries** | Configure attempts + backoff |
| **Idempotency** | Jobs should be safe to retry |
| **Concurrency** | Limit concurrent workers |
| **Monitoring** | Bull Board for queue UI |
| **Dead letter** | Handle permanently failed jobs |
| **Delayed jobs** | Schedule jobs for future execution |
| **Repeatable** | Cron-like repeatable jobs |
| **Logging** | Log job start, completion, failure |

---

## Rules Integration
- **Cron**: node-cron for in-process schedules
- **Queues**: BullMQ for distributed job processing
- **Retries**: Exponential backoff with attempt limits
- **Monitoring**: Bull Board dashboard
