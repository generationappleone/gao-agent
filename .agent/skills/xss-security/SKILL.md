---
name: XSS Security
description: Skill for preventing Cross-Site Scripting (XSS) attacks — covering reflected, stored, and DOM-based XSS, Content Security Policy (CSP), output encoding, input sanitization, and secure coding patterns.
---

# XSS Security Skill

## Overview
Cross-Site Scripting (XSS) is a vulnerability that allows attackers to inject malicious scripts into web pages viewed by other users. It's consistently ranked in OWASP Top 10. This skill covers all XSS types, prevention techniques, and security headers.

**References**:
- [OWASP XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Scripting_Prevention_Cheat_Sheet.html)
- [OWASP DOM XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/DOM_based_XSS_Prevention_Cheat_Sheet.html)
- [MDN Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)

---

## XSS Types

| Type | Description | Vector | Example |
|------|-------------|--------|---------|
| **Reflected** | Input reflected in response | URL parameters, search | `?q=<script>alert(1)</script>` |
| **Stored** | Malicious data persisted in DB | Comments, profiles, messages | Comment with `<script>` tag |
| **DOM-based** | Client-side JS manipulates DOM unsafely | `innerHTML`, `document.write` | `element.innerHTML = userInput` |

---

## Output Encoding (Primary Defense)

```typescript
// ── HTML context encoding ──
import { encode } from 'html-entities';

// Server-side: encode before inserting into HTML
const safeHtml = encode(userInput);
// Input: <script>alert('XSS')</script>
// Output: &lt;script&gt;alert(&#39;XSS&#39;)&lt;/script&gt;

// ── JavaScript context encoding ──
// NEVER insert user input into <script> blocks
// ❌ BAD:  <script>var name = "${userInput}";</script>
// ✅ GOOD: Use data attributes + DOM API
// <div id="container" data-name="${encode(userInput)}"></div>
// <script>const name = document.getElementById('container').dataset.name;</script>

// ── URL context encoding ──
const safeUrl = encodeURIComponent(userInput);
// <a href="/search?q=${safeUrl}">Search</a>

// ── CSS context encoding ──
// NEVER insert user input into CSS
// ❌ BAD:  <div style="color: ${userInput}">
// ✅ GOOD: Use allowlists
const allowedColors = ['red', 'blue', 'green', 'black'];
const safeColor = allowedColors.includes(userInput) ? userInput : 'black';
```

---

## React/JSX (Safe by Default)

```tsx
// ✅ SAFE — JSX auto-escapes expressions
function UserProfile({ user }: { user: User }) {
  return (
    <div>
      <h1>{user.name}</h1>           {/* Auto-escaped */}
      <p>{user.bio}</p>              {/* Auto-escaped */}
      <a href={user.website}>{user.website}</a>
    </div>
  );
}

// ❌ DANGEROUS — dangerouslySetInnerHTML bypasses escaping
function UnsafeComponent({ htmlContent }: { htmlContent: string }) {
  // NEVER do this with user input
  return <div dangerouslySetInnerHTML={{ __html: htmlContent }} />;
}

// ✅ SAFE with sanitization — if rich text is needed
import DOMPurify from 'dompurify';

function SafeRichText({ htmlContent }: { htmlContent: string }) {
  const cleanHtml = DOMPurify.sanitize(htmlContent, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li', 'a', 'blockquote', 'code'],
    ALLOWED_ATTR: ['href', 'target', 'rel'],
    ADD_ATTR: ['target'],            // Allow target attribute
    FORBID_TAGS: ['script', 'style', 'iframe', 'form', 'input'],
    FORBID_ATTR: ['onerror', 'onclick', 'onload', 'onmouseover'],
  });

  return <div dangerouslySetInnerHTML={{ __html: cleanHtml }} />;
}

// ❌ DANGEROUS DOM patterns to avoid
// document.getElementById('x').innerHTML = userInput;
// document.write(userInput);
// element.outerHTML = userInput;
// element.insertAdjacentHTML('beforeend', userInput);
// eval(userInput);
// new Function(userInput);
// setTimeout(userInput, 100);
// location.href = userInput;   // javascript: protocol XSS

// ✅ SAFE DOM alternatives
// element.textContent = userInput;      // Safe, no parsing
// element.setAttribute('value', userInput);  // Safe for most attrs
```

---

## URL Validation (Prevent javascript: XSS)

```typescript
// ── Validate URLs to prevent javascript: protocol ──
function isValidUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:', 'mailto:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

// ✅ SAFE link rendering
function SafeLink({ url, children }: { url: string; children: React.ReactNode }) {
  if (!isValidUrl(url)) {
    return <span>{children}</span>;  // Fallback to plain text
  }
  return (
    <a href={url} target="_blank" rel="noopener noreferrer">
      {children}
    </a>
  );
}

// ❌ BAD: <a href={userInput}>Click</a>
// Attack: userInput = "javascript:alert(document.cookie)"
```

---

## Content Security Policy (CSP)

```typescript
// ── Express CSP middleware ──
import helmet from 'helmet';

app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: [
      "'self'",
      // "'nonce-${nonce}'"     // For inline scripts (generate per-request)
      // "'strict-dynamic'"     // Trust scripts loaded by trusted scripts
    ],
    styleSrc: [
      "'self'",
      "'unsafe-inline'",        // Required for most CSS-in-JS
      "https://fonts.googleapis.com",
    ],
    imgSrc: ["'self'", "data:", "https:"],
    fontSrc: ["'self'", "https://fonts.gstatic.com"],
    connectSrc: [
      "'self'",
      "https://api.myapp.com",
      "wss://myapp.com",
    ],
    frameSrc: ["'none'"],                // No iframes
    objectSrc: ["'none'"],               // No Flash/Java
    baseUri: ["'self'"],                 // Prevent base tag injection
    formAction: ["'self'"],              // Forms only submit to self
    upgradeInsecureRequests: [],
  },
}));

// ── CSP with nonce (for inline scripts) ──
import crypto from 'crypto';

app.use((req, res, next) => {
  const nonce = crypto.randomBytes(16).toString('base64');
  res.locals.cspNonce = nonce;
  res.setHeader('Content-Security-Policy',
    `default-src 'self'; script-src 'self' 'nonce-${nonce}'; style-src 'self' 'unsafe-inline'`
  );
  next();
});

// In HTML template: <script nonce="${nonce}">...</script>
```

---

## Cookie Security

```typescript
// ── Secure cookie settings ──
app.use(session({
  cookie: {
    httpOnly: true,          // ✅ Prevent XSS access to cookies
    secure: true,            // ✅ HTTPS only
    sameSite: 'lax',         // ✅ CSRF protection
    maxAge: 24 * 60 * 60 * 1000,
    domain: '.myapp.com',
    path: '/',
  },
}));

// Set cookies with security flags
res.cookie('token', value, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 900000,  // 15 min
});
```

---

## Security Headers

```typescript
// ── All security headers via Helmet ──
import helmet from 'helmet';

app.use(helmet());  // Enables all headers below

// Or individually:
app.use(helmet.xContentTypeOptions());       // X-Content-Type-Options: nosniff
app.use(helmet.xFrameOptions({ action: 'deny' }));  // X-Frame-Options: DENY
app.use(helmet.referrerPolicy({ policy: 'strict-origin-when-cross-origin' }));
app.use(helmet.hsts({ maxAge: 31536000, includeSubDomains: true, preload: true }));
app.use(helmet.permittedCrossDomainPolicies());
app.use(helmet.noSniff());
```

---

## Testing for XSS

```typescript
// Common XSS test payloads (for security testing)
const xssPayloads = [
  '<script>alert("XSS")</script>',
  '<img src=x onerror=alert("XSS")>',
  '<svg onload=alert("XSS")>',
  '"><script>alert("XSS")</script>',
  "' onclick=alert('XSS') '",
  'javascript:alert("XSS")',
  '<iframe src="javascript:alert(1)">',
  '<a href="javascript:alert(1)">click</a>',
  '{{constructor.constructor("alert(1)")()}}',  // Template injection
  '${alert(1)}',                                  // Template literal
];

// Automated XSS test
describe('XSS Prevention', () => {
  for (const payload of xssPayloads) {
    it(`should sanitize: ${payload.substring(0, 30)}...`, async () => {
      const res = await request(app)
        .post('/api/comments')
        .send({ content: payload })
        .expect(201);

      // Verify stored content is safe
      expect(res.body.content).not.toContain('<script');
      expect(res.body.content).not.toContain('onerror');
      expect(res.body.content).not.toContain('javascript:');
    });
  }
});
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Output encoding** | HTML-encode all user data before rendering |
| **CSP** | Strict Content-Security-Policy header |
| **React default** | JSX auto-escapes; never use dangerouslySetInnerHTML |
| **DOMPurify** | Sanitize if rich HTML is required |
| **HttpOnly cookies** | Prevent XSS from stealing session cookies |
| **URL validation** | Check protocol (http/https only), block javascript: |
| **No eval()** | Never eval(), new Function(), or setTimeout(string) |
| **textContent** | Use textContent instead of innerHTML |
| **Helmet** | helmet.js for all security headers |
| **Test payloads** | Automated tests with common XSS vectors |

---

## Rules Integration
- **Output**: HTML encoding (html-entities), React auto-escaping
- **Sanitization**: DOMPurify for rich text with strict allowlists
- **CSP**: Strict policy with nonces for inline scripts
- **Cookies**: HttpOnly, Secure, SameSite flags
- **Testing**: Automated XSS payload testing in integration tests
