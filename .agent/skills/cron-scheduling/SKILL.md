---
name: Cron / Task Scheduling
description: Skill for task scheduling — covering cron syntax, Node.js schedulers (node-cron, Bull/BullMQ), Laravel scheduler, Python (APScheduler, Celery), and job queue patterns.
---

# Cron / Task Scheduling Skill

## Overview
Task scheduling automates recurring operations (reports, cleanup, notifications). This skill covers cron syntax and scheduling libraries.

## Cron Syntax
```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-7, 0=7=Sunday)
│ │ │ │ │
* * * * *
```

| Expression | Description |
|------------|-------------|
| `* * * * *` | Every minute |
| `0 * * * *` | Every hour |
| `0 0 * * *` | Every day at midnight |
| `0 9 * * 1-5` | Weekdays at 9:00 AM |
| `0 0 1 * *` | First day of month |
| `*/5 * * * *` | Every 5 minutes |
| `0 */2 * * *` | Every 2 hours |
| `0 9,18 * * *` | At 9 AM and 6 PM |
| `0 0 * * 0` | Every Sunday at midnight |
| `30 4 1,15 * *` | 4:30 AM on 1st and 15th |

## Node.js — node-cron
```typescript
import cron from "node-cron";

// Schedule tasks
cron.schedule("0 0 * * *", async () => {
  console.log("Running daily cleanup...");
  await cleanExpiredSessions();
});

cron.schedule("0 9 * * 1", async () => {
  console.log("Sending weekly report...");
  await generateWeeklyReport();
});

cron.schedule("*/30 * * * *", async () => {
  await syncExternalData();
}, { timezone: "Asia/Jakarta" });
```

## Node.js — BullMQ (Production Job Queue)
```typescript
import { Queue, Worker } from "bullmq";
import IORedis from "ioredis";

const connection = new IORedis(process.env.REDIS_URL!);

// Queue
const emailQueue = new Queue("email", { connection });

// Add jobs
await emailQueue.add("welcome", { userId: "123", email: "user@example.com" });
await emailQueue.add("report", { type: "weekly" }, {
  repeat: { pattern: "0 9 * * 1" }, // Every Monday 9 AM
});

// Delayed job
await emailQueue.add("reminder", { orderId: "456" }, { delay: 24 * 60 * 60 * 1000 }); // 24h later

// Worker
const worker = new Worker("email", async (job) => {
  switch (job.name) {
    case "welcome":
      await sendWelcomeEmail(job.data.email);
      break;
    case "report":
      await generateAndSendReport(job.data.type);
      break;
  }
}, {
  connection,
  concurrency: 5,
  limiter: { max: 10, duration: 1000 }, // Rate limit: 10/sec
});

worker.on("completed", (job) => console.log(`Job ${job.id} completed`));
worker.on("failed", (job, err) => console.error(`Job ${job?.id} failed:`, err));
```

## Laravel Scheduler
```php
// app/Console/Kernel.php
protected function schedule(Schedule $schedule) {
    $schedule->command('reports:generate')->dailyAt('09:00');
    $schedule->command('sessions:cleanup')->hourly();
    $schedule->command('backup:run')->daily()->at('02:00');
    $schedule->job(new SyncDataJob)->everyThirtyMinutes();
    $schedule->call(fn() => cache()->flush())->weekly();
}
```

## Python — APScheduler
```python
from apscheduler.schedulers.asyncio import AsyncIOScheduler

scheduler = AsyncIOScheduler(timezone="Asia/Jakarta")

@scheduler.scheduled_job("cron", hour=0, minute=0)
async def daily_cleanup():
    await clean_expired_sessions()

@scheduler.scheduled_job("interval", minutes=30)
async def sync_data():
    await fetch_external_data()

scheduler.start()
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Job queues** | Use BullMQ/Celery for production (not cron for heavy tasks) |
| **Idempotency** | Jobs should be safe to retry |
| **Dead letter queue** | Handle failed jobs explicitly |
| **Monitoring** | Track job completion and failure rates |
| **Timezone** | Always specify timezone explicitly |
| **Concurrency** | Limit concurrent workers per queue |
| **Rate limiting** | Prevent overwhelming external services |
| **Logging** | Log job start, completion, and failures |
| **Health checks** | Monitor scheduler/worker process health |
| **Graceful shutdown** | Complete running jobs before stopping |
