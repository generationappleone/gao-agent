---
name: RabbitMQ
description: Skill for message queuing with RabbitMQ — covering exchanges, queues, bindings, consumers, producers, dead letter queues, retries, and integration patterns.
---

# RabbitMQ Skill

## Overview
RabbitMQ is an open-source message broker implementing AMQP protocol for reliable asynchronous messaging.

**Reference**: [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)

## Node.js Integration (amqplib)
```typescript
import amqp from "amqplib";

// Producer
async function publishMessage(queue: string, message: object) {
  const connection = await amqp.connect(process.env.RABBITMQ_URL!);
  const channel = await connection.createChannel();
  await channel.assertQueue(queue, { durable: true });
  channel.sendToQueue(queue, Buffer.from(JSON.stringify(message)), { persistent: true, contentType: "application/json" });
  await channel.close();
  await connection.close();
}

// Consumer
async function consumeMessages(queue: string, handler: (msg: any) => Promise<void>) {
  const connection = await amqp.connect(process.env.RABBITMQ_URL!);
  const channel = await connection.createChannel();
  await channel.assertQueue(queue, { durable: true });
  await channel.prefetch(10); // Process 10 at a time

  channel.consume(queue, async (msg) => {
    if (!msg) return;
    try {
      const data = JSON.parse(msg.content.toString());
      await handler(data);
      channel.ack(msg);          // Success
    } catch (error) {
      channel.nack(msg, false, false); // Reject + dead letter
    }
  });
}
```

## Exchange Patterns
```typescript
// Direct exchange — route by exact key
await channel.assertExchange("orders", "direct", { durable: true });
channel.publish("orders", "order.created", Buffer.from(JSON.stringify(order)));

// Topic exchange — route by pattern
await channel.assertExchange("events", "topic", { durable: true });
channel.publish("events", "user.profile.updated", Buffer.from(JSON.stringify(event)));
// Consumer binds: "user.#" (all user events) or "*.profile.*" (all profile events)

// Fanout exchange — broadcast to all queues
await channel.assertExchange("notifications", "fanout", { durable: true });
```

## Dead Letter Queue
```typescript
// Main queue with DLX
await channel.assertQueue("orders", {
  durable: true,
  arguments: {
    "x-dead-letter-exchange": "dlx",
    "x-dead-letter-routing-key": "orders.failed",
    "x-message-ttl": 300000, // 5 minutes
  },
});

// Dead letter queue
await channel.assertExchange("dlx", "direct", { durable: true });
await channel.assertQueue("orders.dead-letter", { durable: true });
await channel.bindQueue("orders.dead-letter", "dlx", "orders.failed");
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Durable queues** | Use `durable: true` for message persistence |
| **Persistent messages** | Set `persistent: true` in publish options |
| **Prefetch** | Limit concurrent messages per consumer |
| **ACK/NACK** | Always acknowledge or reject messages |
| **Dead letter queues** | Handle failed messages gracefully |
| **Connection pooling** | Reuse connections, create channels per operation |
| **Idempotency** | Design consumers to handle duplicate messages |
| **Monitoring** | Use management plugin for queue monitoring |
