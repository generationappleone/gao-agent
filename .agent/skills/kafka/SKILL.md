---
name: Apache Kafka
description: Skill for building event-driven architectures with Apache Kafka, covering producers, consumers, topics, partitions, consumer groups, Kafka Streams, and production deployment.
---

# Apache Kafka Skill

## Overview
Apache Kafka is a distributed event streaming platform for high-throughput, fault-tolerant messaging. Use for event-driven architecture, real-time data pipelines, and microservice communication.

## Core Concepts
```
Producer → Topic → Consumer
           │
           ├── Partition 0: [msg1, msg4, msg7, ...]
           ├── Partition 1: [msg2, msg5, msg8, ...]
           └── Partition 2: [msg3, msg6, msg9, ...]

Consumer Group: Multiple consumers sharing partitions
Broker: Kafka server node
Cluster: Multiple brokers
Offset: Position of consumer in a partition
```

## Docker Setup
```yaml
# docker-compose.yml
services:
  kafka:
    image: confluentinc/cp-kafka:7.6.0
    hostname: kafka
    container_name: kafka
    ports:
      - "9092:9092"
    environment:
      KAFKA_NODE_ID: 1
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: 'CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,HOST:PLAINTEXT'
      KAFKA_ADVERTISED_LISTENERS: 'PLAINTEXT://kafka:29092,HOST://localhost:9092'
      KAFKA_PROCESS_ROLES: 'broker,controller'
      KAFKA_CONTROLLER_QUORUM_VOTERS: '1@kafka:29093'
      KAFKA_LISTENERS: 'PLAINTEXT://kafka:29092,CONTROLLER://kafka:29093,HOST://0.0.0.0:9092'
      KAFKA_INTER_BROKER_LISTENER_NAME: 'PLAINTEXT'
      KAFKA_CONTROLLER_LISTENER_NAMES: 'CONTROLLER'
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
      KAFKA_LOG_RETENTION_HOURS: 168
      KAFKA_NUM_PARTITIONS: 3
      KAFKA_DEFAULT_REPLICATION_FACTOR: 1
    volumes:
      - kafka-data:/var/lib/kafka/data

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: kafka-ui
    ports:
      - "8080:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:29092

volumes:
  kafka-data:
```

## Topic Management
```bash
# Create topic
kafka-topics --bootstrap-server localhost:9092 \
  --create --topic orders \
  --partitions 6 --replication-factor 3

# List topics
kafka-topics --bootstrap-server localhost:9092 --list

# Describe topic
kafka-topics --bootstrap-server localhost:9092 --describe --topic orders

# Delete topic
kafka-topics --bootstrap-server localhost:9092 --delete --topic old-topic
```

## Producer (Node.js — KafkaJS)
```typescript
import { Kafka, Partitioners } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'order-service',
  brokers: ['localhost:9092'],
  retry: { retries: 5 },
});

const producer = kafka.producer({
  createPartitioner: Partitioners.DefaultPartitioner,
  idempotent: true,  // Exactly-once semantics
});

async function publishOrderCreated(order: Order): Promise<void> {
  await producer.connect();

  await producer.send({
    topic: 'orders',
    messages: [{
      key: order.id,                     // Partition by order ID
      value: JSON.stringify({
        eventType: 'order.created',
        timestamp: new Date().toISOString(),
        data: {
          orderId: order.id,
          userId: order.userId,
          total: order.total,
          items: order.items,
        },
      }),
      headers: {
        'event-type': 'order.created',
        'source': 'order-service',
        'correlation-id': generateCorrelationId(),
      },
    }],
  });
}
```

## Consumer (Node.js — KafkaJS)
```typescript
const consumer = kafka.consumer({
  groupId: 'notification-service',
  sessionTimeout: 30000,
  heartbeatInterval: 10000,
});

async function startConsumer(): Promise<void> {
  await consumer.connect();
  await consumer.subscribe({ topics: ['orders'], fromBeginning: false });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const event = JSON.parse(message.value!.toString());
      const eventType = message.headers?.['event-type']?.toString();

      console.log(`[${topic}:${partition}] ${eventType}`, event.data);

      switch (eventType) {
        case 'order.created':
          await sendOrderConfirmationEmail(event.data);
          break;
        case 'order.shipped':
          await sendShipmentNotification(event.data);
          break;
        default:
          console.warn(`Unhandled event type: ${eventType}`);
      }
    },
  });
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  await consumer.disconnect();
  process.exit(0);
});
```

## Event Schema (Best Practice)
```typescript
// Define event contracts
interface KafkaEvent<T = unknown> {
  eventId: string;           // UUID — unique per event
  eventType: string;         // e.g., "order.created"
  source: string;            // Producing service name
  timestamp: string;         // ISO 8601
  correlationId: string;     // Request tracing
  data: T;                   // Event payload
  metadata?: Record<string, string>;
}

interface OrderCreatedEvent {
  orderId: string;
  userId: string;
  total: number;
  currency: string;
  items: Array<{ productId: string; quantity: number; price: number }>;
}

// Usage
const event: KafkaEvent<OrderCreatedEvent> = {
  eventId: crypto.randomUUID(),
  eventType: 'order.created',
  source: 'order-service',
  timestamp: new Date().toISOString(),
  correlationId: req.headers['x-correlation-id'],
  data: { orderId: '123', userId: '456', total: 99.99, currency: 'USD', items: [] },
};
```

## Topic Naming Convention
```
<domain>.<entity>.<action>

Examples:
├── orders.order.created
├── orders.order.shipped
├── payments.payment.processed
├── users.user.registered
├── notifications.email.sent
└── inventory.stock.updated
```

## Production Configuration
| Setting | Recommendation |
|---------|---------------|
| `replication.factor` | 3 (minimum for production) |
| `min.insync.replicas` | 2 |
| `acks` | `all` (producer — strongest guarantee) |
| `enable.idempotence` | `true` (producer) |
| `auto.offset.reset` | `earliest` or `latest` depending on use case |
| `max.poll.records` | 500 (consumer batch size) |
| `retention.ms` | 604800000 (7 days default) |
| `cleanup.policy` | `delete` or `compact` |
| `partitions` | ~throughput/1000 (rough guide) |

## Rules Integration
- **Security**: SASL/SSL authentication, ACLs for topic access control
- **ISO 27001**: Event audit trails, data retention policies, encryption in transit
- **SOLID**: Event-driven decoupling follows DIP — services depend on events, not each other
