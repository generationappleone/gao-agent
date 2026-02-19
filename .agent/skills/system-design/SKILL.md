---
name: System Design Architecture
description: Skill for designing scalable system architectures — covering design patterns, microservices, event-driven architecture, caching, load balancing, database selection, and system design methodology.
---

# System Design Architecture Skill

## Overview
System design transforms business requirements into **scalable, reliable, and maintainable** technical architectures. This skill covers common patterns, trade-offs, and a systematic approach to designing systems.

---

## System Design Methodology

```
1. Requirements Clarification (5 min)
   → Functional: What does the system DO?
   → Non-functional: Scale, latency, availability, consistency
   → Constraints: Budget, team size, timeline

2. Back-of-Envelope Estimation (5 min)
   → Users: DAU, peak concurrent
   → Storage: Data per user × users × retention
   → Bandwidth: Request size × QPS
   → Compute: CPU/memory per request

3. High-Level Design (10 min)
   → Components, data flow, APIs
   → Client → LB → API → Cache → DB

4. Detailed Design (15 min)
   → Database schema, caching strategy
   → Specific algorithms, data structures

5. Scaling & Trade-offs (10 min)
   → Bottlenecks, single points of failure
   → Horizontal vs vertical scaling
   → Consistency vs availability (CAP theorem)
```

---

## Architecture Patterns

### Monolith
```
✅ Good for: MVPs, small teams, simple domains
❌ Bad for: Large teams, independent deployments

[Client] → [Monolith API + DB]
```

### Microservices
```
✅ Good for: Large teams, independent scaling, polyglot
❌ Bad for: Small teams, simple apps (unnecessary complexity)

[Client] → [API Gateway] → [Service A] → [DB A]
                          → [Service B] → [DB B]
                          → [Service C] → [DB C]
           [Message Queue] ← → [Event Bus]
```

### Event-Driven
```
✅ Good for: Async workflows, loose coupling, auditability
❌ Bad for: Simple CRUD, need for strong consistency

[Service A] → [Event Bus (Kafka/RabbitMQ)] → [Service B]
                                             → [Service C]
                                             → [Audit Log]
```

### CQRS (Command Query Responsibility Segregation)
```
✅ Good for: Read-heavy, different read/write models, event sourcing
Commands (Write) → [Write Model] → [Event Store] → [Read Model] ← Queries (Read)
```

---

## Key Components

### Load Balancer
```
Algorithms: Round Robin, Least Connections, IP Hash, Weighted
Tools: Nginx, HAProxy, AWS ALB/NLB, Cloudflare
Health checks: /health endpoint every 10-30s
```

### Caching
```
Levels:
  L1: Application memory (in-process) — fastest, limited
  L2: Distributed cache (Redis/Memcached) — shared, fast
  L3: CDN (Cloudflare, CloudFront) — static assets, edge

Strategies:
  Cache-Aside: App reads cache first, fetches from DB on miss
  Write-Through: Write to cache + DB simultaneously
  Write-Behind: Write to cache, async write to DB
  Read-Through: Cache fetches from DB automatically

Invalidation:
  TTL: Time-based expiration (simplest)
  Event-based: Invalidate on write (more complex, more accurate)
  Version-based: Cache key includes version number
```

### Database Selection
```
| Need              | Database          | Type        |
|-------------------|-------------------|-------------|
| ACID transactions | PostgreSQL, MySQL | Relational  |
| Flexible schema   | MongoDB           | Document    |
| Key-value cache   | Redis             | In-memory   |
| Time series       | InfluxDB, TimescaleDB | Time series |
| Search            | Elasticsearch     | Search      |
| Graph relations   | Neo4j             | Graph       |
| Wide column       | Cassandra, ScyllaDB | Column    |
| Analytics (OLAP)  | ClickHouse, BigQuery | Column   |
```

### Message Queues
```
| Tool     | Pattern       | Best For              |
|----------|---------------|-----------------------|
| RabbitMQ | Queue + Topic | Task processing       |
| Kafka    | Event stream  | Event sourcing, logs  |
| Redis    | Pub/Sub       | Real-time, simple     |
| SQS      | Queue         | AWS, serverless       |
| NATS     | Pub/Sub       | Microservices, fast   |
```

---

## Scalability Patterns

```
Horizontal Scaling: Add more machines (stateless services)
Vertical Scaling:   Add more resources to one machine
Database Sharding:  Split data across multiple databases
Read Replicas:      Separate read/write databases
CDN:                Cache static assets at edge
Rate Limiting:      Protect from overload
Circuit Breaker:    Prevent cascade failures
Bulkhead:           Isolate failures to one component
```

---

## Non-Functional Requirements Checklist

```
Performance
□ P99 latency target defined
□ Throughput target (QPS/RPS) defined
□ Caching strategy for hot data
□ Database query optimization

Availability
□ SLA target defined (99.9% = 8.7h downtime/year)
□ Multi-region / multi-AZ deployment
□ Health checks and auto-recovery
□ Graceful degradation plan

Scalability
□ Stateless services (horizontal scaling)
□ Auto-scaling policies defined
□ Database scaling strategy (read replicas, sharding)
□ CDN for static content

Security
□ Authentication (OAuth, JWT, API keys)
□ Authorization (RBAC/ABAC)
□ Encryption (TLS, at-rest)
□ WAF and DDoS protection
□ Skills: skills/waf/, skills/ddos-protection/

Observability
□ Structured logging
□ Distributed tracing
□ Metrics and dashboards
□ Alerting on SLA breaches
□ Skills: skills/structured-logging/, skills/opentelemetry/
```

## Best Practices
1. **Start simple, scale when needed** — premature optimization is the root of all evil
2. **Design for failure** — everything fails eventually
3. **Stateless services** — enables horizontal scaling
4. **Cache aggressively** — but invalidate correctly
5. **Async where possible** — decouple with message queues
6. **Monitor everything** — you can't fix what you can't see
