---
name: Apache Kafka
description: Skill for building event-driven architectures with Apache Kafka, covering producers, consumers, topics, partitions, consumer groups, Kafka Streams, and production deployment.
---

# Apache Kafka Skill

## Overview
Apache Kafka is a distributed event streaming platform for high-throughput, fault-tolerant messaging. It uses topics with partitions for parallel processing, consumer groups for scalability, and provides exactly-once semantics. KafkaJS is the recommended Node.js client.

**References**:
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [KafkaJS](https://kafka.js.org/)

---

## Setup

```yaml
services:
  kafka:
    image: confluentinc/cp-kafka:7.6.0
    ports: ["9092:9092"]
    environment:
      KAFKA_NODE_ID: 1
      KAFKA_PROCESS_ROLES: broker,controller
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT
      KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
```

---

## Client Setup

```typescript
import { Kafka, logLevel } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'myapp',
  brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
  logLevel: logLevel.WARN,
  retry: { initialRetryTime: 300, retries: 8 },
});

export const producer = kafka.producer();
export const consumer = kafka.consumer({ groupId: 'myapp-group' });
```

---

## Producer

```typescript
export async function publishEvent(topic: string, key: string, data: object) {
  await producer.send({
    topic,
    messages: [{ key, value: JSON.stringify(data), headers: { timestamp: Date.now().toString() } }],
  });
}

// Usage
await publishEvent('orders', order.id, { type: 'order.created', data: order });
```

---

## Consumer

```typescript
export async function startConsumer(topics: string[], handler: (topic: string, data: any) => Promise<void>) {
  await consumer.subscribe({ topics, fromBeginning: false });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      try {
        const data = JSON.parse(message.value!.toString());
        await handler(topic, data);
      } catch (error) {
        console.error(`Error processing ${topic}:${partition}:`, error);
      }
    },
  });
}

// Start
await producer.connect();
await startConsumer(['orders', 'payments'], async (topic, data) => {
  switch (data.type) {
    case 'order.created': await processOrder(data.data); break;
    case 'payment.completed': await fulfillOrder(data.data); break;
  }
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  await consumer.disconnect();
  await producer.disconnect();
});
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Partitions** | Use message key for partition affinity |
| **Consumer groups** | Scale consumers within a group |
| **Idempotency** | Handle duplicate messages gracefully |
| **Serialization** | JSON with type discriminator field |
| **Error handling** | DLQ topic for failed messages |
| **Retention** | Configure topic retention period |
| **Compaction** | Use log compaction for state topics |
| **Monitoring** | Track consumer lag metrics |
| **Graceful shutdown** | Disconnect on SIGTERM |
| **Replication** | Factor >= 3 for production |

---

## Rules Integration
- **Producer**: Keyed messages for ordering guarantees
- **Consumer**: Group-based with error handling
- **Topics**: Retention, compaction, replication config
- **Patterns**: Event sourcing, CQRS, saga orchestration
