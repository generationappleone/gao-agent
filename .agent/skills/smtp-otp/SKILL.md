---
name: SMTP OTP
description: Skill for implementing OTP (One-Time Password) via email using SMTP — covering OTP generation, secure storage, rate limiting, verification flow, and integration with authentication systems.
---

# SMTP OTP Skill

## Overview
Email-based OTP provides a second factor of authentication or passwordless login by sending a time-limited code to the user's email address. This skill covers secure OTP generation, delivery via SMTP, verification, and rate limiting.

---

## OTP Generation

```typescript
import crypto from 'crypto';

interface OtpConfig {
  length: number;         // 6 digits default
  expiresInMinutes: number;  // 5 minutes default
  maxAttempts: number;    // 3 attempts default
}

const DEFAULT_CONFIG: OtpConfig = {
  length: 6,
  expiresInMinutes: 5,
  maxAttempts: 3,
};

// ✅ Cryptographically secure OTP generation
function generateOTP(length: number = 6): string {
  const max = Math.pow(10, length);
  const min = Math.pow(10, length - 1);
  const randomInt = crypto.randomInt(min, max);
  return randomInt.toString();
}

// ❌ NEVER use Math.random() for OTP — it's predictable!
```

---

## Database Schema

```sql
CREATE TABLE otp_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  email VARCHAR(255) NOT NULL,
  code_hash VARCHAR(255) NOT NULL,      -- Store HASHED, never plain
  purpose VARCHAR(30) NOT NULL,          -- 'login', 'verify_email', 'reset_password', 'two_factor'
  attempts INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_purpose CHECK (purpose IN ('login', 'verify_email', 'reset_password', 'two_factor'))
);

CREATE INDEX idx_otp_email ON otp_codes(email, purpose) WHERE used_at IS NULL;
```

---

## Service Implementation

```typescript
import bcrypt from 'bcrypt';
import { generateOTP } from './utils';
import { sendEmail } from './emailService';

interface OtpResult {
  success: boolean;
  message: string;
  retryAfter?: number;  // seconds
}

class OtpService {
  // Send OTP
  async sendOtp(email: string, purpose: string): Promise<OtpResult> {
    // 1. Rate limiting — max 3 OTPs per email per 15 minutes
    const recentCount = await db.queryOne<{ count: number }>(`
      SELECT COUNT(*) as count FROM otp_codes
      WHERE email = $1 AND purpose = $2 AND created_at > NOW() - INTERVAL '15 minutes'
    `, [email, purpose]);

    if (recentCount && recentCount.count >= 3) {
      return { success: false, message: 'Too many OTP requests. Try again later.', retryAfter: 900 };
    }

    // 2. Invalidate previous OTPs
    await db.execute(`
      UPDATE otp_codes SET used_at = NOW()
      WHERE email = $1 AND purpose = $2 AND used_at IS NULL
    `, [email, purpose]);

    // 3. Generate & store
    const code = generateOTP(6);
    const codeHash = await bcrypt.hash(code, 10);
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    await db.execute(`
      INSERT INTO otp_codes (email, code_hash, purpose, max_attempts, expires_at)
      VALUES ($1, $2, $3, 3, $4)
    `, [email, codeHash, purpose, expiresAt]);

    // 4. Send email
    await sendEmail({
      to: email,
      subject: `Your verification code: ${code}`,
      html: getOtpEmailTemplate(code, purpose),
    });

    return { success: true, message: 'OTP sent successfully' };
  }

  // Verify OTP
  async verifyOtp(email: string, code: string, purpose: string): Promise<OtpResult> {
    const otp = await db.queryOne<OtpRecord>(`
      SELECT * FROM otp_codes
      WHERE email = $1 AND purpose = $2 AND used_at IS NULL
      ORDER BY created_at DESC LIMIT 1
    `, [email, purpose]);

    if (!otp) return { success: false, message: 'No OTP found. Request a new one.' };
    if (new Date() > otp.expires_at) return { success: false, message: 'OTP expired. Request a new one.' };
    if (otp.attempts >= otp.max_attempts) return { success: false, message: 'Too many attempts. Request a new one.' };

    // Increment attempts
    await db.execute('UPDATE otp_codes SET attempts = attempts + 1 WHERE id = $1', [otp.id]);

    // Verify
    const isValid = await bcrypt.compare(code, otp.code_hash);
    if (!isValid) {
      return { success: false, message: `Invalid code. ${otp.max_attempts - otp.attempts - 1} attempts remaining.` };
    }

    // Mark as used
    await db.execute('UPDATE otp_codes SET used_at = NOW() WHERE id = $1', [otp.id]);

    return { success: true, message: 'OTP verified successfully' };
  }
}
```

---

## Email Templates

```typescript
function getOtpEmailTemplate(code: string, purpose: string): string {
  const purposeText: Record<string, string> = {
    login: 'login ke akun Anda',
    verify_email: 'verifikasi email Anda',
    reset_password: 'reset password Anda',
    two_factor: 'verifikasi dua langkah',
  };

  return `
    <div style="font-family: 'Inter', -apple-system, sans-serif; max-width: 460px; margin: 0 auto; padding: 40px 24px;">
      <h2 style="color: #0f172a; font-size: 20px; margin-bottom: 16px;">Kode Verifikasi</h2>
      <p style="color: #475569; font-size: 14px; line-height: 1.6;">
        Gunakan kode berikut untuk ${purposeText[purpose] || purpose}:
      </p>
      <div style="background: #f8fafc; border: 2px solid #e2e8f0; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
        <span style="font-size: 32px; font-weight: 700; letter-spacing: 8px; color: #6366f1;">${code}</span>
      </div>
      <p style="color: #94a3b8; font-size: 13px;">
        Kode ini berlaku selama <strong>5 menit</strong>. Jangan bagikan kode ini kepada siapapun.
      </p>
      <hr style="border: none; border-top: 1px solid #f1f5f9; margin: 24px 0;" />
      <p style="color: #cbd5e1; font-size: 12px;">
        Jika Anda tidak meminta kode ini, abaikan email ini.
      </p>
    </div>
  `;
}
```

---

## API Endpoints

```typescript
// POST /api/auth/otp/send
router.post('/otp/send', rateLimiter({ max: 5, windowMs: 15 * 60 * 1000 }), async (req, res) => {
  const { email, purpose } = req.body;
  const result = await otpService.sendOtp(email, purpose);
  res.status(result.success ? 200 : 429).json(result);
});

// POST /api/auth/otp/verify
router.post('/otp/verify', rateLimiter({ max: 10, windowMs: 15 * 60 * 1000 }), async (req, res) => {
  const { email, code, purpose } = req.body;
  const result = await otpService.verifyOtp(email, code, purpose);
  if (result.success && purpose === 'login') {
    const user = await userRepo.findByEmail(email);
    const token = generateJWT({ userId: user!.id });
    return res.json({ ...result, token });
  }
  res.status(result.success ? 200 : 400).json(result);
});
```

---

## Security Rules

```
1. ✅ Store OTP HASHED (bcrypt) — never plain text
2. ✅ Expire after 5 minutes maximum
3. ✅ Max 3 verification attempts per OTP
4. ✅ Rate limit OTP requests (3 per 15 min per email)
5. ✅ Rate limit verify endpoint (10 per 15 min per IP)
6. ✅ Invalidate previous OTPs when new one is generated
7. ✅ Use crypto.randomInt() — never Math.random()
8. ✅ Log OTP events (sent, verified, failed) without the code
9. ❌ Never return the OTP in API response
10. ❌ Never log the OTP code
```

## Rules Integration
- **Developer Security**: OTP security patterns in `rules/developer-security.md`
- **SMTP Email**: Email sending infrastructure in `skills/smtp-email/`
- **Keycloak**: Can use Keycloak for OTP if centralized IAM in `skills/keycloak/`
