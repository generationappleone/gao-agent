---
name: DDoS Protection
description: Skill for implementing DDoS protection and mitigation — covering rate limiting, Cloudflare, AWS Shield, Nginx configuration, application-level defenses, and incident response.
---

# DDoS Protection Skill

## Overview
**Distributed Denial of Service (DDoS)** attacks overwhelm applications with traffic to make them unavailable. Defense requires multiple layers: CDN/WAF (edge), infrastructure (cloud), and application-level (code).

---

## Defense Layers

```
┌──────────────────────────────────────────────────────────────┐
│ Layer 1: EDGE — CDN/WAF (Cloudflare, AWS CloudFront)        │
│   → Absorbs volumetric attacks (L3/L4)                       │
│   → Blocks malicious IPs, bot traffic                        │
│   → Rate limiting at edge                                    │
├──────────────────────────────────────────────────────────────┤
│ Layer 2: INFRASTRUCTURE — Cloud Provider                     │
│   → AWS Shield, GCP Cloud Armor, Azure DDoS Protection       │
│   → Auto-scaling to absorb traffic                           │
│   → Network firewall rules                                   │
├──────────────────────────────────────────────────────────────┤
│ Layer 3: SERVER — Nginx/Load Balancer                        │
│   → Connection limits, request rate limiting                 │
│   → Timeout configuration                                    │
│   → Request size limits                                      │
├──────────────────────────────────────────────────────────────┤
│ Layer 4: APPLICATION — Your Code                             │
│   → API rate limiting per user/IP                            │
│   → CAPTCHA for public endpoints                             │
│   → Circuit breakers, graceful degradation                   │
│   → Resource usage limits (query depth, payload size)        │
└──────────────────────────────────────────────────────────────┘
```

---

## 1. Application-Level Rate Limiting

### Express.js
```typescript
// ✅ REQUIRED: Rate limiting on ALL public endpoints
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

// General API rate limiter
const apiLimiter = rateLimit({
  store: new RedisStore({ sendCommand: (...args) => redis.call(...args) }),
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100,                    // 100 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests. Please try again later.' },
  keyGenerator: (req) => req.ip || 'unknown',
});

// Strict limiter for auth endpoints
const authLimiter = rateLimit({
  store: new RedisStore({ sendCommand: (...args) => redis.call(...args) }),
  windowMs: 15 * 60 * 1000,
  max: 10,                     // 10 attempts per 15 min
  message: { error: 'Too many login attempts. Please try again later.' },
});

// Apply
app.use('/api/', apiLimiter);
app.use('/api/auth/', authLimiter);
```

### Laravel
```php
// routes/api.php
Route::middleware('throttle:60,1')->group(function () {
    Route::get('/users', [UserController::class, 'index']);
});

Route::middleware('throttle:5,15')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/otp/send', [AuthController::class, 'sendOtp']);
});
```

---

## 2. Nginx Rate Limiting

```nginx
# /etc/nginx/nginx.conf

http {
    # Define rate limit zones
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
    limit_req_zone $binary_remote_addr zone=general:10m rate=30r/s;
    
    # Connection limits
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

    server {
        # General pages
        location / {
            limit_req zone=general burst=50 nodelay;
            limit_conn conn_limit 20;
        }
        
        # API endpoints
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            limit_conn conn_limit 10;
            
            # Request size limit (prevent large payload attacks)
            client_max_body_size 10m;
            client_body_timeout 10s;
            client_header_timeout 10s;
        }

        # Auth endpoints (strict)
        location /api/auth/ {
            limit_req zone=login burst=5 nodelay;
            limit_conn conn_limit 5;
        }
        
        # Block common attack patterns
        location ~* \.(env|git|svn|htaccess|htpasswd|ini|log|bak|sql)$ {
            deny all;
        }
    }
}
```

---

## 3. Cloudflare DDoS Protection

```
Setup Checklist:
□ Enable Cloudflare proxy (orange cloud) for DNS records
□ Set SSL/TLS to "Full (Strict)"
□ Enable "Under Attack Mode" (during active attack)
□ Configure Rate Limiting rules:
  - /api/* → 100 req/min per IP → Block
  - /api/auth/* → 10 req/min per IP → Challenge
□ Enable Bot Fight Mode
□ Configure WAF managed rules
□ Set Browser Integrity Check: ON
□ Challenge Passage: 30 minutes
□ Enable "I'm Under Attack" page (emergency)

// Cloudflare Page Rules
*yourdomain.com/api/*
  → Cache Level: Bypass
  → Security Level: High
  → Rate Limiting: Active
```

---

## 4. Application-Level Defenses

### Payload Size Limits
```typescript
// ✅ Limit request body size
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// ✅ Limit file uploads
app.use(multer({ limits: { fileSize: 10 * 1024 * 1024 } }).any()); // 10MB max
```

### Query Complexity Limits (GraphQL)
```typescript
// ✅ Limit query depth to prevent deep nesting attacks
import depthLimit from 'graphql-depth-limit';
import { createComplexityLimitRule } from 'graphql-validation-complexity';

const server = new ApolloServer({
  validationRules: [
    depthLimit(5),                    // Max 5 levels deep
    createComplexityLimitRule(1000),   // Max complexity score
  ],
});
```

### Graceful Degradation
```typescript
// ✅ Circuit breaker for external services
// When under load, disable non-essential features

function isUnderHighLoad(): boolean {
  const cpuUsage = process.cpuUsage();
  const memUsage = process.memoryUsage();
  return memUsage.heapUsed / memUsage.heapTotal > 0.9; // 90%+ memory
}

app.use((req, res, next) => {
  if (isUnderHighLoad()) {
    // Disable non-essential features
    if (req.path.includes('/analytics') || req.path.includes('/recommendations')) {
      return res.status(503).json({ error: 'Service temporarily degraded' });
    }
  }
  next();
});
```

### Health Check Endpoint
```typescript
// ✅ REQUIRED: Health check (used by load balancers)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});
```

---

## 5. Monitoring & Alerting

```
Alert Rules:
- Request rate > 10x normal baseline → WARNING
- Error rate > 5% → WARNING  
- Error rate > 20% → CRITICAL
- Response time p95 > 5s → WARNING
- CPU > 80% sustained → WARNING
- Memory > 90% → CRITICAL
- Rate limit 429 responses > 100/min → DDoS indicator
```

---

## DDoS Response Checklist

```
During Active Attack:
□ Enable Cloudflare "Under Attack Mode"
□ Enable stricter rate limiting
□ Block suspicious IP ranges (geofencing if needed)
□ Enable CAPTCHA on all public endpoints
□ Scale up infrastructure (auto-scaling)
□ Disable non-essential features (graceful degradation)
□ Monitor and log attack patterns
□ Communicate status to stakeholders
□ Contact cloud provider DDoS response team

Post-Attack:
□ Analyze attack patterns and vectors
□ Update WAF rules based on findings
□ Review and tighten rate limits
□ Document incident for compliance
□ Update incident response playbook
```

## Rules Integration
- **Developer Security**: Rate limiting requirements in `rules/developer-security.md`
- **WAF**: Web Application Firewall in `skills/waf/`
- **NIST CSF**: PR.IR resilience in `skills/nist-csf/`
- **CIS Controls**: Control 13 network defense in `skills/cis-controls/`
