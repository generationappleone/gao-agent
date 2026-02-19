---
name: Web Application Firewall (WAF)
description: Skill for configuring Web Application Firewalls — covering Cloudflare WAF, AWS WAF, ModSecurity, security headers, custom rules, bot protection, and OWASP CRS.
---

# Web Application Firewall (WAF) Skill

## Overview
A **WAF** inspects HTTP/HTTPS traffic and blocks malicious requests before they reach your application. It protects against OWASP Top 10 (SQLi, XSS, SSRF, etc.), bots, and zero-day exploits.

---

## WAF Comparison

| WAF | Type | Best For | Pricing |
|-----|------|----------|---------|
| **Cloudflare WAF** | Cloud | Most projects, easy setup | Free tier + Pro ($20/mo) |
| **AWS WAF** | Cloud | AWS ecosystem | Pay per rule + request |
| **ModSecurity** | Self-hosted | Full control, open-source | Free |
| **Nginx App Protect** | Self-hosted | Nginx-based infrastructure | Commercial |
| **Azure WAF** | Cloud | Azure ecosystem | Pay per policy + request |

---

## 1. Cloudflare WAF (Recommended)

### Setup
```
1. Add site to Cloudflare → Change nameservers
2. Enable proxy (orange cloud) for DNS A/CNAME records
3. SSL/TLS → Full (Strict)
4. Security → WAF → Managed Rules → Enable

Managed Rulesets:
□ Cloudflare Managed Ruleset — ON (blocks known attacks)
□ Cloudflare OWASP Core Ruleset — ON (OWASP Top 10)
□ Cloudflare Leaked Credentials Detection — ON
```

### Custom Rules (Examples)
```
// Block requests from specific countries (if needed)
Rule: (ip.geoip.country in {"CN" "RU"}) and not (cf.client.bot)
Action: Block

// Block access to admin paths from non-office IPs
Rule: (http.request.uri.path contains "/admin") and not (ip.src in {1.2.3.0/24})
Action: Block

// Challenge suspicious user agents
Rule: (http.user_agent contains "curl") or (http.user_agent contains "wget") or (http.user_agent eq "")
Action: Managed Challenge

// Rate limit API
Rule: (http.request.uri.path matches "^/api/")
Action: Rate limit (100 req per 1 min per IP)
Exceeds → Block for 10 min

// Block SQL injection patterns
Rule: (http.request.uri.query contains "UNION SELECT") or
      (http.request.uri.query contains "1=1") or
      (http.request.uri.query contains "OR 1=1")
Action: Block
```

---

## 2. AWS WAF

### Web ACL Rules
```json
// aws waf create-web-acl
{
  "Name": "production-waf",
  "Rules": [
    {
      "Name": "AWSManagedRulesCommonRuleSet",
      "Priority": 1,
      "OverrideAction": { "None": {} },
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesCommonRuleSet"
        }
      }
    },
    {
      "Name": "AWSManagedRulesSQLiRuleSet",
      "Priority": 2,
      "OverrideAction": { "None": {} },
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesSQLiRuleSet"
        }
      }
    },
    {
      "Name": "RateLimitRule",
      "Priority": 3,
      "Action": { "Block": {} },
      "Statement": {
        "RateBasedStatement": {
          "Limit": 2000,
          "AggregateKeyType": "IP"
        }
      }
    }
  ]
}
```

### Recommended AWS Managed Rule Groups
```
□ AWSManagedRulesCommonRuleSet — General protection
□ AWSManagedRulesSQLiRuleSet — SQL injection
□ AWSManagedRulesKnownBadInputsRuleSet — Known malicious input
□ AWSManagedRulesLinuxRuleSet — LFI/command injection
□ AWSManagedRulesBotControlRuleSet — Bot management
□ AWSManagedRulesATPRuleSet — Account takeover prevention
```

---

## 3. Security Headers (Application-Level WAF)

```typescript
// ✅ REQUIRED: Security headers on EVERY response
// middleware/securityHeaders.ts

export function securityHeaders(req: Request, res: Response, next: NextFunction) {
  // Prevent XSS
  res.setHeader('Content-Security-Policy',
    "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
    "img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com; " +
    "connect-src 'self' https://api.yourdomain.com; frame-src 'none'; object-src 'none'");
  
  // Force HTTPS
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
  
  // Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff');
  
  // Prevent clickjacking
  res.setHeader('X-Frame-Options', 'DENY');
  
  // Control referrer info
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Disable browser features
  res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=(), payment=()');
  
  // Prevent cross-origin data leaks
  res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
  res.setHeader('Cross-Origin-Resource-Policy', 'same-origin');
  
  next();
}
```

### Laravel Security Headers
```php
// app/Http/Middleware/SecurityHeaders.php
public function handle($request, Closure $next)
{
    $response = $next($request);
    
    $response->headers->set('Content-Security-Policy', "default-src 'self'");
    $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    $response->headers->set('X-Content-Type-Options', 'nosniff');
    $response->headers->set('X-Frame-Options', 'DENY');
    $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
    $response->headers->set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    
    return $response;
}
```

---

## 4. Bot Protection

```
Detection Signals:
→ Missing or suspicious User-Agent
→ No JavaScript execution (headless bot)
→ Abnormal request patterns (too fast, too regular)
→ Known bot IP ranges (datacenter IPs)
→ TLS fingerprinting (JA3/JA4)

Mitigation:
→ Cloudflare Bot Fight Mode / Super Bot Fight Mode
→ CAPTCHA challenges (Turnstile, reCAPTCHA)
→ JavaScript challenges (proof of browser)
→ Honeypot fields in forms
→ Skills: skills/turnstile/, skills/recaptcha/
```

---

## WAF Deployment Checklist

```
Setup
□ WAF enabled in front of all public endpoints
□ OWASP Core Rule Set (CRS) enabled
□ SQL injection rules enabled
□ XSS rules enabled
□ Rate limiting configured
□ Bot protection enabled

Security Headers
□ Content-Security-Policy set
□ Strict-Transport-Security set (HSTS)
□ X-Content-Type-Options: nosniff
□ X-Frame-Options: DENY
□ Referrer-Policy configured
□ Permissions-Policy configured

Monitoring
□ WAF logs enabled and monitored
□ Alert on high block rate (potential attack)
□ Alert on high pass rate (potential bypass)
□ Regular rule review (monthly)
□ False positive tuning
```

## Rules Integration
- **XSS Security**: CSP and encoding in `skills/xss-security/`
- **DDoS Protection**: Rate limiting layer in `skills/ddos-protection/`
- **Developer Security**: Security headers in `rules/developer-security.md`
- **NIST CSF**: PR.PS platform security in `skills/nist-csf/`
