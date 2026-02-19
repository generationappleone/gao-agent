---
name: Google OAuth
description: Skill for implementing Google OAuth 2.0 authentication — covering Google Cloud Console setup, authorization code flow, ID token verification, React integration, and backend session management.
---

# Google OAuth Skill

## Overview
Google OAuth 2.0 / OpenID Connect allows users to sign in with their Google account. This provides secure, trusted authentication without managing passwords. Use for consumer apps, internal tools (Google Workspace), and social login.

---

## Google Cloud Console Setup

```
1. Go to: https://console.cloud.google.com/apis/credentials
2. Create Project → Name your project
3. Configure OAuth Consent Screen:
   - User Type: External (public) or Internal (Google Workspace)
   - App name, support email, logo
   - Scopes: email, profile, openid
   - Test users (if External + Testing status)
4. Create OAuth 2.0 Client ID:
   - Application type: Web application
   - Authorized origins: http://localhost:5173, https://yourdomain.com
   - Authorized redirect URIs: http://localhost:5173/auth/google/callback, https://yourdomain.com/auth/google/callback
5. Copy Client ID and Client Secret
```

---

## Frontend: React Integration

### Option 1: @react-oauth/google (Recommended)
```bash
npm install @react-oauth/google jwt-decode
```

```tsx
// main.tsx — Wrap app with GoogleOAuthProvider
import { GoogleOAuthProvider } from '@react-oauth/google';

<GoogleOAuthProvider clientId={import.meta.env.VITE_GOOGLE_CLIENT_ID}>
  <App />
</GoogleOAuthProvider>
```

```tsx
// components/GoogleLoginButton.tsx
import { GoogleLogin, type CredentialResponse } from '@react-oauth/google';

interface GoogleLoginButtonProps {
  onSuccess: (credential: string) => void;
  onError: () => void;
}

export function GoogleLoginButton({ onSuccess, onError }: GoogleLoginButtonProps) {
  const handleSuccess = (response: CredentialResponse) => {
    if (response.credential) {
      onSuccess(response.credential);
    }
  };

  return (
    <GoogleLogin
      onSuccess={handleSuccess}
      onError={onError}
      theme="outline"
      size="large"
      width="100%"
      text="signin_with"
      shape="rectangular"
      logo_alignment="left"
    />
  );
}

// Usage in LoginPage
function LoginPage() {
  const navigate = useNavigate();

  const handleGoogleLogin = async (credential: string) => {
    try {
      const response = await fetch('/api/auth/google', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ credential }),
      });
      const data = await response.json();
      if (data.token) {
        localStorage.setItem('token', data.token);
        navigate('/dashboard');
      }
    } catch (error) {
      console.error('Google login failed:', error);
    }
  };

  return (
    <div className="login-page">
      <h1>Sign In</h1>
      <GoogleLoginButton
        onSuccess={handleGoogleLogin}
        onError={() => console.error('Google login error')}
      />
    </div>
  );
}
```

### Option 2: Custom Button (One Tap)
```tsx
import { useGoogleOneTapLogin } from '@react-oauth/google';

function App() {
  useGoogleOneTapLogin({
    onSuccess: (response) => {
      // Send response.credential to backend
      handleGoogleLogin(response.credential!);
    },
    onError: () => console.error('One Tap failed'),
    cancel_on_tap_outside: true,
  });

  return <>{/* app content */}</>;
}
```

---

## Backend: Token Verification

### Node.js / Express
```typescript
import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// POST /api/auth/google
async function googleAuth(req: Request, res: Response) {
  const { credential } = req.body;

  try {
    // Verify the Google ID token
    const ticket = await client.verifyIdToken({
      idToken: credential,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    if (!payload) throw new Error('Invalid token payload');

    const { sub: googleId, email, name, picture, email_verified } = payload;

    if (!email_verified) {
      return res.status(400).json({ error: 'Email not verified by Google' });
    }

    // Find or create user
    let user = await userRepo.findByEmail(email!);
    if (!user) {
      user = await userRepo.create({
        email: email!,
        fullName: name || '',
        avatarUrl: picture || null,
        googleId,
        authProvider: 'google',
        emailVerified: true,
      });
    } else if (!user.googleId) {
      // Link Google account to existing user
      await userRepo.update(user.id, { googleId, avatarUrl: picture || user.avatarUrl });
    }

    // Generate app JWT
    const token = generateJWT({ userId: user.id, email: user.email, role: user.role });
    const refreshToken = generateRefreshToken(user.id);

    res.json({
      token,
      refreshToken,
      user: { id: user.id, email: user.email, name: user.fullName, avatar: user.avatarUrl },
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid Google credential' });
  }
}
```

### Laravel
```php
// Using Laravel Socialite
// composer require laravel/socialite

// config/services.php
'google' => [
    'client_id' => env('GOOGLE_CLIENT_ID'),
    'client_secret' => env('GOOGLE_CLIENT_SECRET'),
    'redirect' => env('GOOGLE_REDIRECT_URI'),
],

// Controller
use Laravel\Socialite\Facades\Socialite;

public function redirectToGoogle()
{
    return Socialite::driver('google')->redirect();
}

public function handleGoogleCallback()
{
    $googleUser = Socialite::driver('google')->user();

    $user = User::updateOrCreate(
        ['email' => $googleUser->getEmail()],
        [
            'name' => $googleUser->getName(),
            'google_id' => $googleUser->getId(),
            'avatar' => $googleUser->getAvatar(),
            'email_verified_at' => now(),
        ]
    );

    $token = $user->createToken('auth-token')->plainTextToken;

    return response()->json(['token' => $token, 'user' => $user]);
}
```

---

## Environment Variables
```bash
# Frontend
VITE_GOOGLE_CLIENT_ID=123456789-abc.apps.googleusercontent.com

# Backend
GOOGLE_CLIENT_ID=123456789-abc.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-your-secret
GOOGLE_REDIRECT_URI=https://yourdomain.com/auth/google/callback
```

## Security Checklist
```
□ Verify ID token on backend (NEVER trust frontend-only verification)
□ Validate audience claim matches YOUR client ID
□ Check email_verified is true
□ Use HTTPS for all OAuth redirects
□ Store client secret in environment variable (NEVER in code)
□ Implement CSRF protection for OAuth flow
□ Rate limit the auth endpoint
□ Log all authentication events
```

## Best Practices
1. **Always verify on backend** — frontend token is for UX only
2. **Link accounts** — if user exists with same email, link Google to existing account
3. **Don't store Google tokens** — only store your app's JWT
4. **Use One Tap** for seamless UX on return visits
5. **Handle edge cases** — user denies consent, token expired, network error
6. **Implement logout** — revoke Google session if needed

## Rules Integration
- **Developer Security**: OAuth flow security in `rules/developer-security.md`
- **Keycloak**: Can use Keycloak as broker for Google → `skills/keycloak/`
- **UU PDP**: Consent for data from Google profile → `rules/uu-pdp-compliance.md`
