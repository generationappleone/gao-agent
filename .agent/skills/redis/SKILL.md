---
name: Redis
description: Skill for using Redis as cache, session store, message broker, and real-time data store, covering data structures, caching patterns, pub/sub, streams, and clustering.
---

# Redis Skill

## Overview
Redis is an in-memory data store used as cache, session store, message broker, and rate limiter. It supports strings, hashes, lists, sets, sorted sets, streams, and pub/sub. Node.js uses the `ioredis` or `redis` client libraries.

**References**:
- [Redis Documentation](https://redis.io/docs/)
- [ioredis](https://github.com/redis/ioredis)

---

## Setup

```typescript
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: Number(process.env.REDIS_PORT) || 6379,
  password: process.env.REDIS_PASSWORD,
  maxRetriesPerRequest: 3,
  retryStrategy: (times) => Math.min(times * 200, 2000),
});

redis.on('error', (err) => console.error('Redis error:', err));
redis.on('connect', () => console.log('Redis connected'));
```

---

## Caching Patterns

```typescript
// Cache-aside pattern
export async function getCached<T>(key: string, fetcher: () => Promise<T>, ttl = 3600): Promise<T> {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const data = await fetcher();
  await redis.setex(key, ttl, JSON.stringify(data));
  return data;
}

// Usage
const products = await getCached('products:active', () => db.product.findMany({ where: { status: 'active' } }), 600);

// Cache invalidation
export async function invalidateCache(pattern: string) {
  const keys = await redis.keys(pattern);
  if (keys.length > 0) await redis.del(...keys);
}

// Rate limiting
export async function rateLimit(key: string, limit: number, windowSeconds: number): Promise<boolean> {
  const current = await redis.incr(key);
  if (current === 1) await redis.expire(key, windowSeconds);
  return current <= limit;
}

// Session store
export async function setSession(sessionId: string, data: object, ttl = 86400) {
  await redis.setex(`session:${sessionId}`, ttl, JSON.stringify(data));
}

export async function getSession(sessionId: string) {
  const data = await redis.get(`session:${sessionId}`);
  return data ? JSON.parse(data) : null;
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **TTL** | Always set expiration on cache keys |
| **Key naming** | Use colons for namespacing: `entity:id:field` |
| **Serialization** | JSON for complex objects |
| **Cache-aside** | Check cache → miss → fetch → store |
| **Invalidation** | Invalidate on write operations |
| **Rate limiting** | Use INCR + EXPIRE for IP/user rate limits |
| **Connection pool** | Reuse single ioredis instance |
| **Error handling** | Graceful degradation if Redis is down |
| **Pub/Sub** | Use separate connection for subscriptions |
| **Memory** | Monitor memory usage, set maxmemory policy |

---

## Rules Integration
- **Cache**: Cache-aside with TTL for database queries
- **Session**: Secure session storage with expiration
- **Rate limiting**: IP/user-based with sliding window
- **Pub/Sub**: Real-time event broadcasting
