---
name: Web Application Firewall (WAF)
description: Skill for configuring Web Application Firewalls — covering Cloudflare WAF, AWS WAF, ModSecurity, security headers, custom rules, bot protection, and OWASP CRS.
---

# Web Application Firewall (WAF) Skill

## Overview
WAF protects web applications from common attacks (SQL injection, XSS, CSRF, bot abuse). It inspects HTTP requests and applies security rules. Cloudflare WAF, AWS WAF, and ModSecurity are the most common solutions.

**References**:
- [Cloudflare WAF](https://developers.cloudflare.com/waf/)
- [AWS WAF](https://docs.aws.amazon.com/waf/)

---

## Security Headers (Express)

```typescript
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'", 'cdn.jsdelivr.net'],
      styleSrc: ["'self'", "'unsafe-inline'", 'fonts.googleapis.com'],
      imgSrc: ["'self'", 'data:', 'res.cloudinary.com'],
      fontSrc: ["'self'", 'fonts.gstatic.com'],
      connectSrc: ["'self'", 'api.stripe.com'],
      frameSrc: ["'none'"],
    },
  },
  crossOriginEmbedderPolicy: false,
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
}));

// Rate limiting
import rateLimit from 'express-rate-limit';
app.use('/api', rateLimit({ windowMs: 15 * 60 * 1000, max: 100, standardHeaders: true }));
app.use('/api/auth/login', rateLimit({ windowMs: 15 * 60 * 1000, max: 5 }));
```

---

## Nginx Security Headers

```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline';" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;

# Rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
location /api/ { limit_req zone=api burst=20 nodelay; }
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **CSP** | Content Security Policy for XSS prevention |
| **HSTS** | Force HTTPS with preload |
| **Rate limiting** | Limit requests per IP/user |
| **Helmet** | Express middleware for security headers |
| **X-Frame-Options** | Prevent clickjacking |
| **CORS** | Restrict origins, methods, headers |
| **Bot protection** | Challenge suspicious traffic |
| **IP blocking** | Block known malicious IPs |
| **Logging** | Log blocked requests for analysis |
| **OWASP CRS** | Core Rule Set for ModSecurity |

---

## Rules Integration
- **Headers**: CSP, HSTS, X-Frame-Options via Helmet
- **Rate limiting**: Per-endpoint limits
- **Nginx**: Server-level security headers
- **Bot protection**: Challenge/block suspicious traffic
