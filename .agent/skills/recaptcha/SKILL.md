---
name: reCAPTCHA Google
description: Skill for implementing Google reCAPTCHA v2 and v3 — covering frontend widget, backend verification, React integration, score-based decisions, and fallback strategies.
---

# Google reCAPTCHA Skill

## Overview
**Google reCAPTCHA** protects forms from bots and abuse. **v3** runs invisibly with a score (0.0-1.0), while **v2** shows the "I'm not a robot" checkbox. Use v3 as primary, fallback to v2 for suspicious scores.

---

## Version Comparison

| Feature | reCAPTCHA v2 | reCAPTCHA v3 |
|---------|-------------|-------------|
| User interaction | Checkbox / image puzzle | Invisible (no interaction) |
| Output | Pass/fail | Score (0.0 to 1.0) |
| UX impact | Friction | None |
| Use case | High-security forms | All forms (background) |
| Privacy | Tracks user behavior | Tracks user behavior |

> ⚠️ **Privacy Note:** reCAPTCHA collects browsing data. For UU PDP/GDPR compliance, consider **Cloudflare Turnstile** (`skills/turnstile/`) as a privacy-friendly alternative.

---

## Google Console Setup

```
1. Go to: https://www.google.com/recaptcha/admin
2. Register a new site:
   - Label: Your App
   - reCAPTCHA type: v3 (recommended) or v2 Checkbox
   - Domains: yourdomain.com, localhost
3. Copy Site Key and Secret Key
```

---

## reCAPTCHA v3 (Invisible — Recommended)

### Frontend: Vanilla JS
```html
<script src="https://www.google.com/recaptcha/api.js?render=YOUR_SITE_KEY"></script>

<script>
async function submitForm(action) {
  const token = await grecaptcha.execute('YOUR_SITE_KEY', { action });
  
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: document.getElementById('email').value,
      password: document.getElementById('password').value,
      recaptchaToken: token,
      recaptchaAction: action,
    }),
  });
}
</script>
```

### Frontend: React
```bash
npm install react-google-recaptcha-v3
```

```tsx
// main.tsx — Wrap app
import { GoogleReCaptchaProvider } from 'react-google-recaptcha-v3';

<GoogleReCaptchaProvider reCaptchaKey={import.meta.env.VITE_RECAPTCHA_SITE_KEY}>
  <App />
</GoogleReCaptchaProvider>
```

```tsx
// hooks/useRecaptcha.ts
import { useGoogleReCaptcha } from 'react-google-recaptcha-v3';
import { useCallback } from 'react';

export function useRecaptcha() {
  const { executeRecaptcha } = useGoogleReCaptcha();

  const getToken = useCallback(async (action: string): Promise<string | null> => {
    if (!executeRecaptcha) return null;
    return executeRecaptcha(action);
  }, [executeRecaptcha]);

  return { getToken };
}
```

```tsx
// Usage in form
function LoginForm() {
  const { getToken } = useRecaptcha();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const recaptchaToken = await getToken('login');
    if (!recaptchaToken) return;

    await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, recaptchaToken }),
    });
  };

  return <form onSubmit={handleSubmit}>{/* fields */}</form>;
}
```

---

## reCAPTCHA v2 (Checkbox — Fallback)

```bash
npm install react-google-recaptcha
```

```tsx
import ReCAPTCHA from 'react-google-recaptcha';

function LoginForm() {
  const [recaptchaToken, setRecaptchaToken] = useState<string | null>(null);
  const recaptchaRef = useRef<ReCAPTCHA>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!recaptchaToken) return;
    // Submit with token
    // Reset after submission
    recaptchaRef.current?.reset();
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" required />
      <input type="password" required />
      <ReCAPTCHA
        ref={recaptchaRef}
        sitekey={import.meta.env.VITE_RECAPTCHA_V2_SITE_KEY}
        onChange={(token) => setRecaptchaToken(token)}
        onExpired={() => setRecaptchaToken(null)}
        theme="light"
        hl="id"
      />
      <button type="submit" disabled={!recaptchaToken}>Login</button>
    </form>
  );
}
```

---

## Backend: Server-Side Verification

```typescript
// ✅ REQUIRED: Always verify on backend — NEVER trust frontend only

interface RecaptchaResponse {
  success: boolean;
  score?: number;        // v3 only (0.0 to 1.0)
  action?: string;       // v3 only
  challenge_ts: string;
  hostname: string;
  'error-codes'?: string[];
}

async function verifyRecaptcha(token: string, expectedAction?: string): Promise<{ valid: boolean; score?: number }> {
  const response = await fetch('https://www.google.com/recaptcha/api/siteverify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      secret: process.env.RECAPTCHA_SECRET_KEY!,
      response: token,
    }),
  });

  const data: RecaptchaResponse = await response.json();

  if (!data.success) return { valid: false };

  // v3: Check score and action
  if (data.score !== undefined) {
    if (expectedAction && data.action !== expectedAction) return { valid: false };
    return { valid: data.score >= 0.5, score: data.score };
  }

  // v2: Just pass/fail
  return { valid: true };
}

// Middleware
export function requireRecaptcha(action?: string) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const token = req.body.recaptchaToken;
    if (!token) return res.status(400).json({ error: 'reCAPTCHA required' });

    const result = await verifyRecaptcha(token, action);
    if (!result.valid) {
      return res.status(403).json({
        error: 'reCAPTCHA verification failed',
        requireV2: result.score !== undefined && result.score < 0.5, // Suggest v2 fallback
      });
    }

    next();
  };
}

// Usage
app.post('/api/auth/login', requireRecaptcha('login'), loginHandler);
app.post('/api/auth/register', requireRecaptcha('register'), registerHandler);
```

### Score-Based Decision
```typescript
// ✅ v3 score interpretation
// 1.0 = Very likely human
// 0.9 = Likely human
// 0.7 = Probably human
// 0.5 = Uncertain (threshold)
// 0.3 = Probably bot
// 0.1 = Very likely bot
// 0.0 = Definitely bot

if (score >= 0.7) {
  // Allow action
} else if (score >= 0.3) {
  // Show v2 checkbox as fallback
} else {
  // Block request
}
```

---

## Environment Variables
```bash
# Frontend
VITE_RECAPTCHA_SITE_KEY=6Lc...        # v3
VITE_RECAPTCHA_V2_SITE_KEY=6Ld...     # v2 (fallback)

# Backend
RECAPTCHA_SECRET_KEY=6Lc...            # v3
RECAPTCHA_V2_SECRET_KEY=6Ld...         # v2 (fallback)

# Testing keys (Google provides these)
# v2 Site key (always passes): 6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
# v2 Secret (always passes):   6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe
```

## Best Practices
1. **Use v3 as primary** — invisible, no user friction
2. **Fallback to v2** when v3 score < 0.5 — show checkbox
3. **Always verify on backend** — frontend token is meaningless alone
4. **Set appropriate threshold** — 0.5 default, adjust based on false positives
5. **Log scores** for monitoring — detect trends in bot attacks
6. **Use action parameter** in v3 — prevents token reuse across forms
7. **Consider privacy** — reCAPTCHA tracks users; for UU PDP, prefer Turnstile

## Rules Integration
- **Turnstile**: Privacy-friendly alternative in `skills/turnstile/`
- **DDoS Protection**: Bot prevention layer in `skills/ddos-protection/`
- **WAF**: Bot protection in `skills/waf/`
- **UU PDP**: Privacy consent needed for reCAPTCHA tracking in `rules/uu-pdp-compliance.md`
