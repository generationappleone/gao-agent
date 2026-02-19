---
name: Redis
description: Skill for using Redis as cache, session store, message broker, and real-time data store, covering data structures, caching patterns, pub/sub, streams, and clustering.
---

# Redis Skill

## Overview
Redis is an in-memory data store used for caching, session management, pub/sub messaging, rate limiting, and real-time analytics. This skill covers data structures, caching patterns, and production configurations.

## Installation
```bash
# Docker (recommended)
docker run -d --name redis -p 6379:6379 redis:7-alpine \
  redis-server --requirepass yourpassword --maxmemory 256mb --maxmemory-policy allkeys-lru

# Ubuntu/Debian
sudo apt install redis-server
sudo systemctl enable redis-server

# macOS
brew install redis && brew services start redis
```

## Data Structures & Commands

### Strings (Cache/Counters)
```bash
SET user:123:name "John Doe" EX 3600       # Set with 1hr TTL
GET user:123:name                            # Get value
INCR page:home:views                         # Increment counter
INCRBY api:rate:user:123 1                   # Increment by N
SETEX session:abc123 1800 '{"userId":"123"}' # Set with TTL (30min)
MGET key1 key2 key3                          # Multi-get
```

### Hashes (Objects)
```bash
HSET user:123 name "John" email "john@example.com" role "admin"
HGET user:123 name                           # Get single field
HGETALL user:123                             # Get all fields
HDEL user:123 role                           # Delete field
HINCRBY user:123 loginCount 1               # Increment field
```

### Lists (Queues)
```bash
LPUSH queue:emails '{"to":"user@example.com","subject":"Welcome"}'
RPOP queue:emails                            # Consume from queue
LRANGE queue:emails 0 -1                     # View all items
LLEN queue:emails                            # Queue length
```

### Sets (Unique Collections)
```bash
SADD online:users "user:123" "user:456"
SISMEMBER online:users "user:123"            # Check membership
SMEMBERS online:users                        # All members
SCARD online:users                           # Count
SREM online:users "user:123"                 # Remove
```

### Sorted Sets (Leaderboards/Rankings)
```bash
ZADD leaderboard 1500 "player:1" 2300 "player:2" 1800 "player:3"
ZREVRANGE leaderboard 0 9 WITHSCORES        # Top 10
ZRANK leaderboard "player:1"                 # Player rank
ZINCRBY leaderboard 100 "player:1"          # Add score
```

## Caching Patterns

### Cache-Aside (Lazy Loading)
```typescript
import Redis from 'ioredis';

const redis = new Redis({ host: 'localhost', port: 6379, password: 'yourpassword' });

async function getUser(userId: string): Promise<User> {
  const cacheKey = `user:${userId}`;

  // 1. Check cache
  const cached = await redis.get(cacheKey);
  if (cached) return JSON.parse(cached);

  // 2. Cache miss → query database
  const user = await db.users.findById(userId);
  if (!user) throw new NotFoundError('User not found');

  // 3. Store in cache with TTL
  await redis.setex(cacheKey, 3600, JSON.stringify(user)); // 1 hour

  return user;
}

// Invalidate on update
async function updateUser(userId: string, data: UpdateUserDto): Promise<User> {
  const user = await db.users.update(userId, data);
  await redis.del(`user:${userId}`);  // Invalidate cache
  return user;
}
```

### Write-Through Cache
```typescript
async function createOrder(data: CreateOrderDto): Promise<Order> {
  const order = await db.orders.create(data);
  // Write to cache immediately
  await redis.setex(`order:${order.id}`, 7200, JSON.stringify(order));
  return order;
}
```

## Session Store
```typescript
// Express session with Redis
import session from 'express-session';
import RedisStore from 'connect-redis';

app.use(session({
  store: new RedisStore({ client: redis, prefix: 'sess:' }),
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true,
    httpOnly: true,
    sameSite: 'strict',
    maxAge: 30 * 60 * 1000, // 30 minutes
  },
}));
```

## Rate Limiting
```typescript
async function rateLimit(userId: string, limit: number = 100, window: number = 60): Promise<boolean> {
  const key = `rate:${userId}`;
  const current = await redis.incr(key);

  if (current === 1) {
    await redis.expire(key, window);  // Set window on first request
  }

  return current <= limit;  // true = allowed, false = rate limited
}
```

## Pub/Sub
```typescript
// Publisher
const publisher = new Redis();
await publisher.publish('notifications', JSON.stringify({
  type: 'order.created',
  data: { orderId: '123', userId: '456' },
}));

// Subscriber
const subscriber = new Redis();
subscriber.subscribe('notifications');
subscriber.on('message', (channel, message) => {
  const event = JSON.parse(message);
  console.log(`[${channel}] ${event.type}`, event.data);
});
```

## Redis Streams (Event Sourcing)
```bash
# Add to stream
XADD events * type "order.created" orderId "123" amount "99.99"

# Read from stream (consumer group)
XGROUP CREATE events mygroup 0 MKSTREAM
XREADGROUP GROUP mygroup consumer1 COUNT 10 BLOCK 5000 STREAMS events >

# Acknowledge processed
XACK events mygroup <message-id>
```

## Production Configuration
```conf
# redis.conf
bind 127.0.0.1
port 6379
requirepass your_secure_password

# Memory
maxmemory 1gb
maxmemory-policy allkeys-lru

# Persistence
save 900 1       # Save if 1+ key changed in 900s
save 300 10      # Save if 10+ keys changed in 300s
appendonly yes   # AOF persistence
appendfsync everysec

# Security
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command CONFIG ""
```

## Commands Quick Reference
```bash
redis-cli -a password                    # Connect
INFO memory                              # Memory usage
INFO keyspace                            # Key stats
DBSIZE                                   # Total keys
KEYS "user:*"                            # Find keys (dev only!)
SCAN 0 MATCH "user:*" COUNT 100         # Production key scan
TTL key                                  # Time to live
PERSIST key                              # Remove TTL
FLUSHDB                                  # Clear current DB (dev only!)
MONITOR                                  # Real-time command log
```

## Rules Integration
- **Security**: Require password, bind to localhost, disable dangerous commands
- **ISO 27001**: Cache sensitive data with short TTL, encrypt at rest if needed
- **Dependencies**: Use `ioredis` (Node.js), `redis-py` (Python), `StackExchange.Redis` (.NET)
