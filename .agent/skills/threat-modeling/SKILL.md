---
name: Threat Modeling
description: Skill for threat modeling using STRIDE methodology — covering trust boundary identification, threat enumeration, attack surface analysis, risk scoring, and mitigation strategies for web applications.
---

# Threat Modeling Skill

## Purpose
This skill provides a structured approach to **identifying, classifying, and mitigating threats** to application security using the STRIDE methodology and complementary techniques.

---

## When to Use

- During design phase of new features (proactive)
- During security audits (reactive, via `/context-security`)
- When adding authentication/authorization flows
- When integrating external services or APIs
- When handling sensitive data (PII, financial, health)

---

## STRIDE Methodology

STRIDE categorizes threats into 6 types:

| Category | Threat | Question | Security Property |
|----------|--------|----------|-------------------|
| **S** — Spoofing | Impersonating a user or system | "Can someone pretend to be someone else?" | Authentication |
| **T** — Tampering | Modifying data or code | "Can data be changed without detection?" | Integrity |
| **R** — Repudiation | Denying actions occurred | "Can someone deny performing an action?" | Non-repudiation |
| **I** — Information Disclosure | Exposing data to unauthorized parties | "Can unauthorized people see this data?" | Confidentiality |
| **D** — Denial of Service | Making the system unavailable | "Can someone make the system unusable?" | Availability |
| **E** — Elevation of Privilege | Gaining unauthorized access | "Can someone get more access than allowed?" | Authorization |

---

## Process

### Step 1: Identify Trust Boundaries

Map where trust levels change in the application:

```
┌─────────────────────────────────────────────────────┐
│ EXTERNAL (Untrusted)                                │
│  Users, Third-party APIs, CDN                       │
│                                                     │
│  ═══════════ TRUST BOUNDARY 1 ═══════════════       │
│                                                     │
│  ┌───────────────────────────────────────────┐      │
│  │ DMZ / Edge Layer                          │      │
│  │  Load Balancer, WAF, Reverse Proxy        │      │
│  │                                           │      │
│  │  ═══════════ TRUST BOUNDARY 2 ═══════     │      │
│  │                                           │      │
│  │  ┌─────────────────────────────────┐      │      │
│  │  │ Application Layer               │      │      │
│  │  │  API Server, Auth Service       │      │      │
│  │  │                                 │      │      │
│  │  │  ═══════ TRUST BOUNDARY 3 ═══  │      │      │
│  │  │                                 │      │      │
│  │  │  ┌───────────────────────┐      │      │      │
│  │  │  │ Data Layer            │      │      │      │
│  │  │  │  Database, Cache,     │      │      │      │
│  │  │  │  File Storage         │      │      │      │
│  │  │  └───────────────────────┘      │      │      │
│  │  └─────────────────────────────────┘      │      │
│  └───────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────┘
```

### Step 2: Identify Entry Points

List all ways data enters or leaves the system:

| # | Entry Point | Method | Auth Required | Data Type |
|---|-------------|--------|---------------|-----------|
| 1 | `/api/auth/login` | POST | No | Credentials |
| 2 | `/api/auth/register` | POST | No | PII |
| 3 | `/api/users/:id` | GET | Yes (Bearer) | User data |
| 4 | `/api/upload` | POST | Yes | File binary |
| 5 | WebSocket `/ws` | WS | Yes (Token) | Real-time events |
| 6 | Webhook `/webhook/stripe` | POST | Signature | Payment events |

### Step 3: STRIDE Analysis per Entry Point

For each entry point, evaluate all 6 STRIDE categories:

```markdown
#### Entry Point: POST /api/auth/login

| STRIDE | Threat | Risk | Mitigation |
|--------|--------|------|------------|
| **S** Spoofing | Brute force password attack | High | Rate limiting (5/15min), CAPTCHA after 3 fails |
| **S** Spoofing | Credential stuffing | High | Check haveibeenpwned API, require strong passwords |
| **T** Tampering | Modify request in transit | Medium | HTTPS/TLS enforced |
| **R** Repudiation | Deny login attempt | Medium | Log all auth events with IP, timestamp, user-agent |
| **I** Info Disclosure | Expose valid usernames | Medium | Generic error: "Invalid email or password" |
| **I** Info Disclosure | Timing attack on password check | Low | Constant-time comparison |
| **D** DoS | Flood login endpoint | High | Rate limiting, WAF, queue-based processing |
| **E** Elevation | JWT algorithm confusion | High | Explicit algorithm in verify: `algorithms: ['HS256']` |
```

### Step 4: Risk Scoring

Use the DREAD model for risk prioritization:

| Factor | Score Range | Description |
|--------|------------|-------------|
| **D**amage | 1-3 | How bad if exploited? (3 = catastrophic) |
| **R**eproducibility | 1-3 | How easy to reproduce? (3 = always) |
| **E**xploitability | 1-3 | How easy to exploit? (3 = trivial) |
| **A**ffected Users | 1-3 | How many users affected? (3 = all) |
| **D**iscoverability | 1-3 | How easy to find? (3 = obvious) |

**Risk Score = Sum / 5** → Low (1.0-1.5), Medium (1.6-2.0), High (2.1-2.5), Critical (2.6-3.0)

### Step 5: Common Web Application Threats

#### Authentication Threats
```
- Credential stuffing (leaked password databases)
- Session hijacking (XSS stealing cookies)
- Session fixation (forcing known session ID)
- Password reset poisoning (host header injection)
- JWT secret brute force (weak secrets)
- OAuth redirect manipulation (open redirect)
```

#### Authorization Threats
```
- Insecure Direct Object Reference (IDOR)
- Horizontal privilege escalation (user A accesses user B data)
- Vertical privilege escalation (user becomes admin)
- Missing function-level access control
- Parameter manipulation (changing role in request)
```

#### Data Threats
```
- SQL injection (all forms)
- NoSQL injection (MongoDB operators)
- Mass assignment (unvalidated field binding)
- Server-Side Request Forgery (SSRF)
- XML External Entity (XXE)
- Path traversal (../../etc/passwd)
```

#### Infrastructure Threats
```
- Subdomain takeover (dangling DNS records)
- Cloud metadata exposure (169.254.169.254)
- Container escape (Docker breakout)
- Kubernetes secrets exposure
- Debug endpoints in production
```

### Step 6: Generate Threat Model Document

```markdown
# Threat Model: [Feature/System Name]

## Overview
- **Scope:** [What is being modeled]
- **Date:** [YYYY-MM-DD]
- **Author:** AI Agent + User Review

## Architecture Diagram
[Trust boundary diagram]

## Entry Points
[Table of all entry points]

## STRIDE Analysis
[Per-entry-point threat analysis]

## Risk Matrix
| Threat | STRIDE | DREAD Score | Risk Level | Status |
|--------|--------|-------------|------------|--------|
| [threat] | [S/T/R/I/D/E] | [1.0-3.0] | [C/H/M/L] | [Open/Mitigated] |

## Mitigation Plan
| Priority | Threat | Mitigation | Implementation |
|----------|--------|------------|---------------|
| P1 | [Critical threats] | [How to fix] | [Where to implement] |
| P2 | [High threats] | [How to fix] | [Where to implement] |

## Assumptions
- [Assumption 1]
- [Assumption 2]

## Out of Scope
- [What was not analyzed]
```

---

## Quick STRIDE Scan (for `/context-security`)

When invoked from the security audit workflow, perform a **quick scan** (not full model):

1. Identify major trust boundaries (external → app → db)
2. Check for missing auth/authz on entry points
3. Verify audit logging for sensitive operations
4. Check for denial-of-service vectors (rate limiting, pagination)
5. Verify data classification and encryption

---

## Integration with Rules
- `rules/developer-security.md` — 4-layer security model
- `rules/iso-27000-compliance.md` — Risk assessment requirements
- `rules/production-code-standards.md` — Verify everything exists before using
