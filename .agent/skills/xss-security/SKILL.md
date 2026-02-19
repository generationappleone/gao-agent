---
name: XSS Security
description: Skill for preventing Cross-Site Scripting (XSS) attacks — covering reflected, stored, and DOM-based XSS, Content Security Policy (CSP), output encoding, input sanitization, and secure coding patterns.
---

# XSS Security Skill

## Overview
**Cross-Site Scripting (XSS)** is the #1 web vulnerability (OWASP Top 10). Attackers inject malicious scripts into web pages viewed by other users. This skill covers prevention techniques for all 3 types of XSS.

---

## XSS Types

| Type | Vector | Example |
|------|--------|---------|
| **Reflected** | URL parameters rendered in page | `?search=<script>alert('xss')</script>` |
| **Stored** | User input saved in DB, rendered to others | Comment with `<img onerror=...>` |
| **DOM-Based** | Client-side JS manipulates DOM unsafely | `document.innerHTML = location.hash` |

---

## 1. Content Security Policy (CSP) — Primary Defense

```typescript
// ✅ REQUIRED: Set CSP header on ALL responses
// middleware/securityHeaders.ts

function getCSPHeader(): string {
  const directives = [
    "default-src 'self'",
    "script-src 'self' 'nonce-{NONCE}'",          // No inline scripts without nonce
    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
    "img-src 'self' data: https: blob:",
    "font-src 'self' https://fonts.gstatic.com",
    "connect-src 'self' https://api.yourdomain.com wss://ws.yourdomain.com",
    "frame-src 'none'",                             // No iframes
    "object-src 'none'",                            // No Flash/Java
    "base-uri 'self'",                              // Prevent <base> tag injection
    "form-action 'self'",                           // Forms submit only to self
    "frame-ancestors 'none'",                       // Cannot be iframed (clickjacking)
    "upgrade-insecure-requests",                    // Force HTTPS
  ];
  return directives.join('; ');
}

// Express middleware
app.use((req, res, next) => {
  const nonce = crypto.randomBytes(16).toString('base64');
  res.locals.nonce = nonce;
  
  res.setHeader('Content-Security-Policy', getCSPHeader().replace('{NONCE}', nonce));
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
  
  next();
});
```

### Meta Tag CSP (for static sites)
```html
<meta http-equiv="Content-Security-Policy" 
  content="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com;">
```

---

## 2. Output Encoding — Context-Aware

```typescript
// ✅ REQUIRED: Encode output based on context

// HTML context — encode HTML entities
function encodeHTML(input: string): string {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}

// Attribute context
function encodeAttribute(input: string): string {
  return input.replace(/[^a-zA-Z0-9,.\-_ ]/g, (char) => {
    return `&#x${char.charCodeAt(0).toString(16).padStart(2, '0')};`;
  });
}

// JavaScript context — JSON encode
function encodeJS(input: string): string {
  return JSON.stringify(input); // Built-in escaping
}

// URL context
function encodeURL(input: string): string {
  return encodeURIComponent(input);
}

// CSS context
function encodeCSS(input: string): string {
  return input.replace(/[^a-zA-Z0-9]/g, (char) => {
    return `\\${char.charCodeAt(0).toString(16).padStart(6, '0')} `;
  });
}
```

---

## 3. React — Built-in XSS Protection

```tsx
// ✅ React auto-escapes expressions — SAFE by default
<p>{userInput}</p>          // ← React escapes this automatically
<p>{comment.body}</p>       // ← Safe, HTML entities encoded

// ❌ DANGEROUS: dangerouslySetInnerHTML bypasses React's protection
<div dangerouslySetInnerHTML={{ __html: userInput }} />  // XSS VULNERABILITY!

// ✅ If you MUST render HTML, sanitize first with DOMPurify
import DOMPurify from 'dompurify';

function SafeHTML({ html }: { html: string }) {
  const sanitized = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li', 'h1', 'h2', 'h3'],
    ALLOWED_ATTR: ['href', 'target', 'rel'],
    ALLOW_DATA_ATTR: false,
  });
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

// ❌ NEVER do this
<a href={userUrl}>Link</a>  // XSS if userUrl = "javascript:alert('xss')"

// ✅ Validate URL protocol
function isSafeUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:', 'mailto:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

<a href={isSafeUrl(userUrl) ? userUrl : '#'}>Link</a>
```

---

## 4. Server-Side Input Sanitization

```typescript
// ✅ Sanitize on INPUT (defense-in-depth, not primary defense)
import DOMPurify from 'isomorphic-dompurify';

// For rich text editors (Quill, TipTap, CKEditor)
function sanitizeRichText(html: string): string {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['p', 'br', 'b', 'i', 'em', 'strong', 'u', 'a', 'ul', 'ol', 'li',
                   'h1', 'h2', 'h3', 'blockquote', 'pre', 'code', 'img'],
    ALLOWED_ATTR: ['href', 'src', 'alt', 'class', 'target', 'rel'],
    FORBID_TAGS: ['script', 'style', 'iframe', 'form', 'input', 'object', 'embed'],
    FORBID_ATTR: ['onerror', 'onload', 'onclick', 'onmouseover', 'onfocus',
                  'style', 'srcset', 'data-*'],
  });
}

// For plain text fields — strip ALL HTML
function sanitizePlainText(input: string): string {
  return DOMPurify.sanitize(input, { ALLOWED_TAGS: [], ALLOWED_ATTR: [] });
}
```

---

## 5. DOM-Based XSS Prevention

```typescript
// ❌ DANGEROUS: Direct DOM manipulation with user input
document.getElementById('output')!.innerHTML = userInput;
element.outerHTML = userInput;
document.write(userInput);
eval(userInput);
setTimeout(userInput, 0);
new Function(userInput);
location.href = userInput;
element.setAttribute('onclick', userInput);

// ✅ SAFE alternatives
document.getElementById('output')!.textContent = userInput;  // textContent is safe
element.setAttribute('data-value', encodeAttribute(userInput));

// ✅ For URLs from user input
const url = new URL(userInput);
if (['http:', 'https:'].includes(url.protocol)) {
  window.location.href = url.toString();
}
```

---

## 6. Cookie Security (Session Hijacking Prevention)

```typescript
// ✅ Secure cookie settings prevent XSS-based session theft
res.cookie('session', token, {
  httpOnly: true,       // Cannot be accessed by JavaScript
  secure: true,         // Only sent over HTTPS
  sameSite: 'strict',   // Not sent in cross-site requests
  maxAge: 30 * 60 * 1000, // 30 minutes
  path: '/',
});
```

---

## XSS Prevention Checklist

```
Headers
□ Content-Security-Policy header set (no 'unsafe-eval', minimal 'unsafe-inline')
□ X-Content-Type-Options: nosniff
□ X-Frame-Options: DENY
□ Referrer-Policy set

Output
□ All user data HTML-encoded in templates
□ Context-aware encoding (HTML, attribute, JS, URL, CSS)
□ React: No dangerouslySetInnerHTML without DOMPurify
□ URLs validated (protocol whitelist: http, https, mailto)

Input
□ Rich text sanitized with DOMPurify + allowlist
□ File uploads validated (type, content, size)
□ JSON responses use application/json Content-Type

DOM
□ No innerHTML with user data (use textContent)
□ No eval(), new Function(), setTimeout(string)
□ No document.write() with user data

Cookies
□ HttpOnly flag set
□ Secure flag set
□ SameSite=Strict or Lax
```

## Rules Integration
- **Developer Security**: XSS prevention in `rules/developer-security.md`
- **CSP**: Part of `skills/waf/` security headers
- **ISO 27001**: A.8.28 secure coding in `skills/iso-27001/`
- **CIS Controls**: Control 16 app security in `skills/cis-controls/`
