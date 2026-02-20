---
name: Google OAuth
description: Skill for implementing Google OAuth 2.0 authentication — covering Google Cloud Console setup, authorization code flow, ID token verification, React integration, and backend session management.
---

# Google OAuth Skill

## Overview
Google OAuth 2.0 enables users to sign in with their Google account. The recommended approach uses Google Identity Services (GIS) with backend ID token verification.

**References**:
- [Google Identity Documentation](https://developers.google.com/identity)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)

---

## Setup

```env
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REDIRECT_URI=http://localhost:3000/auth/google/callback
```

---

## Backend

```typescript
// src/services/google-auth.service.ts
import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID, process.env.GOOGLE_CLIENT_SECRET, process.env.GOOGLE_REDIRECT_URI);

export function getGoogleAuthUrl(): string {
  return client.generateAuthUrl({ access_type: 'offline', scope: ['openid', 'email', 'profile'], prompt: 'consent' });
}

export async function verifyGoogleIdToken(idToken: string) {
  const ticket = await client.verifyIdToken({ idToken, audience: process.env.GOOGLE_CLIENT_ID });
  const payload = ticket.getPayload();
  if (!payload) throw new Error('Invalid token');
  return { googleId: payload.sub, email: payload.email!, name: payload.name!, avatar: payload.picture };
}

// Route: POST /api/auth/google/verify
router.post('/google/verify', async (req, res) => {
  const googleUser = await verifyGoogleIdToken(req.body.idToken);
  const user = await findOrCreateUser({ email: googleUser.email, name: googleUser.name, provider: 'google', providerId: googleUser.googleId });
  const tokens = generateTokens(user);
  res.json({ ...tokens, user });
});
```

---

## React (Google Identity Services)

```tsx
useEffect(() => {
  const script = document.createElement('script');
  script.src = 'https://accounts.google.com/gsi/client';
  script.async = true;
  document.body.appendChild(script);
  script.onload = () => {
    window.google.accounts.id.initialize({
      client_id: process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID!,
      callback: async (response) => { await loginWithGoogle(response.credential); },
    });
    window.google.accounts.id.renderButton(document.getElementById('google-btn')!, { theme: 'outline', size: 'large' });
  };
}, []);
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **ID token** | Always verify on backend |
| **findOrCreate** | Create user if not exists |
| **GIS library** | Use Google Identity Services v2 |
| **Scopes** | Request only openid, email, profile |
| **HTTPS** | Required for OAuth callbacks |

---

## Rules Integration
- **Backend**: OAuth2Client for ID token verification
- **Frontend**: Google Identity Services button
- **User**: findOrCreate pattern
- **Tokens**: Generate JWT after Google verification
