---
name: RabbitMQ
description: Skill for building event-driven architectures with RabbitMQ, covering producers, consumers, topics, partitions, consumer groups, Kafka Streams, and production deployment.
---

# RabbitMQ Skill

## Overview
RabbitMQ is a message broker implementing AMQP protocol. It enables asynchronous communication between services through exchanges, queues, and bindings. RabbitMQ supports topic routing, fanout broadcasting, dead-letter queues, and message acknowledgment for reliable event-driven architectures.

**References**:
- [RabbitMQ Documentation](https://www.rabbitmq.com/docs)
- [RabbitMQ Tutorials](https://www.rabbitmq.com/tutorials)
- [amqplib (Node.js)](https://github.com/amqp-node/amqplib)

---

## Setup

```yaml
# docker-compose.yml
services:
  rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: rabbitmq
    ports:
      - "5672:5672"    # AMQP
      - "15672:15672"  # Management UI
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-admin}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASS:-admin}
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    healthcheck:
      test: ["CMD", "rabbitmqctl", "status"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  rabbitmq_data:
```

```bash
npm install amqplib
npm install -D @types/amqplib
```

---

## Connection Manager

```typescript
// src/lib/rabbitmq.ts
import amqp, { Connection, Channel } from 'amqplib';

class RabbitMQConnection {
  private connection: Connection | null = null;
  private channel: Channel | null = null;
  private url: string;

  constructor(url?: string) {
    this.url = url || process.env.RABBITMQ_URL || 'amqp://admin:admin@localhost:5672';
  }

  async connect(): Promise<Channel> {
    if (this.channel) return this.channel;

    this.connection = await amqp.connect(this.url);
    this.channel = await this.connection.createChannel();
    await this.channel.prefetch(10);

    this.connection.on('error', (err) => {
      console.error('RabbitMQ error:', err.message);
      this.channel = null;
      this.connection = null;
      setTimeout(() => this.connect(), 5000);
    });

    this.connection.on('close', () => {
      console.warn('RabbitMQ connection closed, reconnecting...');
      this.channel = null;
      this.connection = null;
      setTimeout(() => this.connect(), 5000);
    });

    console.log('RabbitMQ connected');
    return this.channel;
  }

  async getChannel(): Promise<Channel> {
    if (!this.channel) await this.connect();
    return this.channel!;
  }

  async close() {
    await this.channel?.close();
    await this.connection?.close();
  }
}

export const rabbitmq = new RabbitMQConnection();
```

---

## Exchange & Queue Topology

```typescript
// src/messaging/topology.ts
export async function setupTopology() {
  const ch = await rabbitmq.getChannel();

  // Topic exchange (route by pattern)
  await ch.assertExchange('app.events', 'topic', { durable: true });

  // Fanout exchange (broadcast to all)
  await ch.assertExchange('app.notifications', 'fanout', { durable: true });

  // Dead letter exchange
  await ch.assertExchange('app.dlx', 'direct', { durable: true });

  // Queues with DLQ
  await ch.assertQueue('order.processing', {
    durable: true,
    arguments: {
      'x-dead-letter-exchange': 'app.dlx',
      'x-dead-letter-routing-key': 'order.failed',
      'x-message-ttl': 300000,  // 5 min TTL
    },
  });

  await ch.assertQueue('email.sending', { durable: true,
    arguments: { 'x-dead-letter-exchange': 'app.dlx', 'x-dead-letter-routing-key': 'email.failed' },
  });

  await ch.assertQueue('order.failed', { durable: true });
  await ch.assertQueue('email.failed', { durable: true });

  // Notification queues
  await ch.assertQueue('notifications.push', { durable: true });
  await ch.assertQueue('notifications.email', { durable: true });

  // Bindings
  await ch.bindQueue('order.processing', 'app.events', 'order.created');
  await ch.bindQueue('order.processing', 'app.events', 'order.updated');
  await ch.bindQueue('email.sending', 'app.events', 'order.created');
  await ch.bindQueue('email.sending', 'app.events', 'user.registered');

  await ch.bindQueue('order.failed', 'app.dlx', 'order.failed');
  await ch.bindQueue('email.failed', 'app.dlx', 'email.failed');

  await ch.bindQueue('notifications.push', 'app.notifications', '');
  await ch.bindQueue('notifications.email', 'app.notifications', '');
}
```

---

## Producer

```typescript
// src/messaging/producer.ts
export async function publishEvent(routingKey: string, data: object, options?: { exchange?: string }) {
  const ch = await rabbitmq.getChannel();
  const exchange = options?.exchange || 'app.events';

  ch.publish(
    exchange, routingKey,
    Buffer.from(JSON.stringify(data)),
    { persistent: true, contentType: 'application/json', timestamp: Date.now() }
  );
}

export async function publishNotification(data: object) {
  await publishEvent('', data, { exchange: 'app.notifications' });
}

// Usage
await publishEvent('order.created', {
  orderId: order.id,
  userId: order.userId,
  total: order.total,
  items: order.items,
});
```

---

## Consumer with Retry

```typescript
// src/messaging/consumers/order.consumer.ts
export async function startOrderConsumer() {
  const ch = await rabbitmq.getChannel();

  await ch.consume('order.processing', async (msg) => {
    if (!msg) return;

    const retryCount = (msg.properties.headers?.['x-retry-count'] as number) || 0;

    try {
      const data = JSON.parse(msg.content.toString());
      console.log(`Processing order: ${data.orderId} (attempt ${retryCount + 1})`);

      await processOrder(data);
      ch.ack(msg);
    } catch (error) {
      console.error('Order processing failed:', error);

      if (retryCount < 3) {
        // Retry with delay
        ch.ack(msg);
        const ch2 = await rabbitmq.getChannel();
        ch2.publish('app.events', msg.fields.routingKey, msg.content, {
          ...msg.properties,
          headers: { ...msg.properties.headers, 'x-retry-count': retryCount + 1 },
        });
      } else {
        // Send to DLQ after max retries
        ch.nack(msg, false, false);
      }
    }
  });
}

// Start email consumer
export async function startEmailConsumer() {
  const ch = await rabbitmq.getChannel();

  await ch.consume('email.sending', async (msg) => {
    if (!msg) return;

    try {
      const data = JSON.parse(msg.content.toString());
      await sendEmail(data);
      ch.ack(msg);
    } catch (error) {
      ch.nack(msg, false, false);  // Send to DLQ
    }
  });
}
```

---

## Application Integration

```typescript
// src/app.ts
import { rabbitmq } from './lib/rabbitmq';
import { setupTopology } from './messaging/topology';
import { startOrderConsumer, startEmailConsumer } from './messaging/consumers';

async function start() {
  await rabbitmq.connect();
  await setupTopology();
  await startOrderConsumer();
  await startEmailConsumer();
  console.log('All consumers started');
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  await rabbitmq.close();
  process.exit(0);
});
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Durable** | Set `durable: true` for exchanges and queues |
| **Persistent** | Use `persistent: true` for messages |
| **Prefetch** | Set `prefetch(10)` to control consumer throughput |
| **Ack/Nack** | Always acknowledge or reject messages |
| **DLQ** | Dead-letter queues for failed messages |
| **Retry** | Custom retry with count header, max 3 attempts |
| **Reconnection** | Auto-reconnect on connection error/close |
| **Topology** | Setup exchanges, queues, bindings at startup |
| **JSON** | Use JSON serialization with contentType header |
| **Graceful shutdown** | Close connection on SIGTERM |

---

## Rules Integration
- **Topology**: Topic + fanout exchanges with DLQ bindings
- **Producer**: Publish events with persistent, typed messages
- **Consumer**: Acknowledge, retry with count, DLQ fallback
- **Reconnection**: Auto-reconnect with backoff on failure
- **Integration**: Setup topology → start consumers at app init
