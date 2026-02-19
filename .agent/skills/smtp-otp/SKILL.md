---
name: SMTP OTP
description: Skill for implementing OTP (One-Time Password) via email using SMTP — covering OTP generation, secure storage, rate limiting, verification flow, and integration with authentication systems.
---

# SMTP OTP Skill

## Overview
Email-based OTP (One-Time Password) verification for user authentication, account recovery, and action confirmation. This skill covers secure OTP generation, delivery, and verification.

## OTP Service (Node.js)
```typescript
import crypto from "crypto";
import nodemailer from "nodemailer";

interface OTPRecord {
  code: string;
  email: string;
  expiresAt: Date;
  attempts: number;
  verified: boolean;
}

class OTPService {
  private transporter: nodemailer.Transporter;
  private otpStore: Map<string, OTPRecord> = new Map(); // Use Redis in production

  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: Number(process.env.SMTP_PORT),
      secure: true,
      auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
    });
  }

  // Generate cryptographically secure OTP
  generateCode(length: number = 6): string {
    const max = Math.pow(10, length);
    const randomBytes = crypto.randomInt(0, max);
    return randomBytes.toString().padStart(length, "0");
  }

  async sendOTP(email: string, purpose: string = "verification"): Promise<void> {
    // Rate limiting: max 3 OTPs per email per hour
    const recentCount = this.getRecentOTPCount(email);
    if (recentCount >= 3) throw new Error("Too many OTP requests. Try again later.");

    const code = this.generateCode();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store OTP (use Redis with TTL in production)
    const key = `${email}:${purpose}`;
    this.otpStore.set(key, { code, email, expiresAt, attempts: 0, verified: false });

    // Send email
    await this.transporter.sendMail({
      from: `"MyApp" <${process.env.SMTP_FROM}>`,
      to: email,
      subject: `Your Verification Code: ${code}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Verification Code</h2>
          <p>Your OTP code is:</p>
          <div style="background: #f4f4f4; padding: 20px; text-align: center; font-size: 32px; letter-spacing: 8px; font-weight: bold; border-radius: 8px;">
            ${code}
          </div>
          <p>This code expires in <strong>5 minutes</strong>.</p>
          <p style="color: #666; font-size: 12px;">If you didn't request this code, please ignore this email.</p>
        </div>
      `,
    });
  }

  async verifyOTP(email: string, code: string, purpose: string = "verification"): Promise<boolean> {
    const key = `${email}:${purpose}`;
    const record = this.otpStore.get(key);

    if (!record) throw new Error("No OTP found. Request a new one.");
    if (record.verified) throw new Error("OTP already used.");
    if (record.attempts >= 5) throw new Error("Too many attempts. Request a new OTP.");
    if (new Date() > record.expiresAt) throw new Error("OTP expired. Request a new one.");

    record.attempts++;

    // Timing-safe comparison to prevent timing attacks
    const isValid = crypto.timingSafeEqual(
      Buffer.from(code.padStart(6, "0")),
      Buffer.from(record.code)
    );

    if (isValid) {
      record.verified = true;
      this.otpStore.delete(key);
      return true;
    }

    return false;
  }
}
```

## API Endpoints
```typescript
// POST /api/otp/send
app.post("/api/otp/send", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: "Email required" });
  try {
    await otpService.sendOTP(email);
    res.json({ message: "OTP sent", expiresIn: 300 });
  } catch (error) {
    res.status(429).json({ error: error.message });
  }
});

// POST /api/otp/verify
app.post("/api/otp/verify", async (req, res) => {
  const { email, code } = req.body;
  try {
    const isValid = await otpService.verifyOTP(email, code);
    if (isValid) {
      const token = generateJWT({ email, verified: true });
      res.json({ message: "Verified", token });
    } else {
      res.status(400).json({ error: "Invalid OTP" });
    }
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **`crypto.randomInt`** | Cryptographically secure random numbers |
| **Short expiry** | 5-10 minutes max for OTP validity |
| **Rate limiting** | Max 3-5 OTPs per email per hour |
| **Attempt limiting** | Max 5 verification attempts per OTP |
| **Timing-safe compare** | Use `crypto.timingSafeEqual` against timing attacks |
| **One-time use** | Delete OTP after successful verification |
| **Redis storage** | Use Redis with TTL for OTP storage in production |
| **No info leakage** | Don't reveal if email exists in error messages |
| **Secure transport** | Use TLS for SMTP connection |
| **Audit logging** | Log OTP events for security auditing |
