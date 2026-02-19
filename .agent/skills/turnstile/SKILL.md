---
name: Turnstile
description: Skill for implementing Cloudflare Turnstile — a privacy-friendly CAPTCHA alternative covering frontend widget, backend verification, React integration, and invisible mode.
---

# Cloudflare Turnstile Skill

## Overview
**Cloudflare Turnstile** is a privacy-friendly, GDPR/UU PDP-compliant CAPTCHA alternative. Unlike reCAPTCHA, it doesn't track users or use cookies for advertising. It verifies humans with invisible challenges — no puzzles.

**Advantages over reCAPTCHA:**
- ✅ No user tracking or data collection
- ✅ No CAPTCHAs to solve (invisible by default)
- ✅ Privacy-compliant (GDPR, UU PDP)
- ✅ Free for unlimited use
- ✅ Faster user experience

---

## Cloudflare Dashboard Setup

```
1. Go to: https://dash.cloudflare.com → Turnstile
2. Add Site:
   - Site name: Your App
   - Domain: yourdomain.com, localhost
   - Widget Type: Managed (recommended) or Invisible
3. Copy Site Key and Secret Key
```

---

## Frontend: Vanilla HTML/JS

```html
<!-- Add Turnstile script -->
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>

<!-- Widget container -->
<form id="login-form" method="POST" action="/api/auth/login">
  <input type="email" name="email" required />
  <input type="password" name="password" required />
  
  <!-- Turnstile widget -->
  <div class="cf-turnstile"
    data-sitekey="0x4AAAAAAA..."
    data-callback="onTurnstileSuccess"
    data-theme="auto"
    data-size="normal"
    data-language="id">
  </div>
  
  <button type="submit">Login</button>
</form>

<script>
function onTurnstileSuccess(token) {
  document.getElementById('login-form').querySelector('[name="cf-turnstile-response"]').value = token;
}
</script>
```

---

## Frontend: React Integration

### Option 1: react-turnstile (Recommended)
```bash
npm install react-turnstile
```

```tsx
import { Turnstile } from 'react-turnstile';

interface LoginFormProps {
  onSubmit: (data: { email: string; password: string; turnstileToken: string }) => void;
}

export function LoginForm({ onSubmit }: LoginFormProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [turnstileToken, setTurnstileToken] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!turnstileToken) return; // Wait for Turnstile
    onSubmit({ email, password, turnstileToken });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
      
      <Turnstile
        sitekey={import.meta.env.VITE_TURNSTILE_SITE_KEY}
        onVerify={(token) => setTurnstileToken(token)}
        onExpire={() => setTurnstileToken('')}
        theme="auto"
        language="id"
      />
      
      <button type="submit" disabled={!turnstileToken}>Login</button>
    </form>
  );
}
```

### Option 2: Invisible Mode
```tsx
import { Turnstile } from 'react-turnstile';
import { useRef } from 'react';

export function InvisibleTurnstile({ onVerify }: { onVerify: (token: string) => void }) {
  const turnstileRef = useRef<any>(null);

  const triggerVerification = () => {
    turnstileRef.current?.execute();
  };

  return (
    <>
      <Turnstile
        ref={turnstileRef}
        sitekey={import.meta.env.VITE_TURNSTILE_SITE_KEY}
        onVerify={onVerify}
        execution="execute"  // Manual trigger
        appearance="interaction-only"
      />
      <button onClick={triggerVerification}>Submit</button>
    </>
  );
}
```

---

## Backend: Server-Side Verification

### Node.js / Express
```typescript
// ✅ REQUIRED: Always verify Turnstile token on backend
async function verifyTurnstile(token: string, ip: string): Promise<boolean> {
  const response = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      secret: process.env.TURNSTILE_SECRET_KEY,
      response: token,
      remoteip: ip,
    }),
  });

  const data = await response.json();
  return data.success === true;
}

// Middleware
export function requireTurnstile(req: Request, res: Response, next: NextFunction) {
  const token = req.body.turnstileToken || req.body['cf-turnstile-response'];
  if (!token) return res.status(400).json({ error: 'CAPTCHA verification required' });

  verifyTurnstile(token, req.ip || '').then((valid) => {
    if (!valid) return res.status(403).json({ error: 'CAPTCHA verification failed' });
    next();
  });
}

// Usage
app.post('/api/auth/login', requireTurnstile, loginHandler);
app.post('/api/auth/register', requireTurnstile, registerHandler);
app.post('/api/contact', requireTurnstile, contactHandler);
```

### Laravel
```php
// Verify in Form Request or middleware
public function rules(): array
{
    return [
        'email' => 'required|email',
        'password' => 'required',
        'turnstileToken' => 'required|string',
    ];
}

protected function passedValidation(): void
{
    $response = Http::post('https://challenges.cloudflare.com/turnstile/v0/siteverify', [
        'secret' => config('services.turnstile.secret'),
        'response' => $this->turnstileToken,
        'remoteip' => $this->ip(),
    ]);

    if (!$response->json('success')) {
        throw ValidationException::withMessages([
            'turnstile' => 'CAPTCHA verification failed.',
        ]);
    }
}
```

---

## Environment Variables
```bash
# Frontend
VITE_TURNSTILE_SITE_KEY=0x4AAAAAAA...

# Backend
TURNSTILE_SECRET_KEY=0x4AAAAAAA...

# Testing (Cloudflare provides test keys)
# Site key (always passes): 1x00000000000000000000AA
# Site key (always fails):  2x00000000000000000000AB
# Secret (always passes):   1x0000000000000000000000000000000AA
# Secret (always fails):    2x0000000000000000000000000000000AA
```

## Where to Use Turnstile
```
□ Login form
□ Registration form
□ Password reset request
□ Contact / feedback forms
□ Comment submission
□ File upload endpoints
□ Any public-facing form that could be abused by bots
```

## Rules Integration
- **DDoS Protection**: Bot mitigation layer in `skills/ddos-protection/`
- **WAF**: Part of Cloudflare ecosystem in `skills/waf/`
- **Developer Security**: Form protection in `rules/developer-security.md`
- **UU PDP**: Privacy-friendly alternative in `rules/uu-pdp-compliance.md`
