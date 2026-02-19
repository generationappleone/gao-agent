---
name: SMTP Email
description: Skill for sending transactional and notification emails via SMTP — covering Nodemailer, Laravel Mail, email templates, SPF/DKIM/DMARC, and email service providers (Gmail, Mailgun, SendGrid, AWS SES).
---

# SMTP Email Skill

## Overview
Email is critical infrastructure for authentication (verification, password reset), notifications, and transactional communication. This skill covers sending emails via SMTP with proper authentication, templates, and deliverability best practices.

---

## Provider Comparison

| Provider | Free Tier | Best For | SMTP Host |
|----------|-----------|----------|-----------|
| **Gmail/Google Workspace** | 500/day | Small apps, development | `smtp.gmail.com:587` |
| **Mailgun** | 100/day (trial) | Transactional email | `smtp.mailgun.org:587` |
| **SendGrid** | 100/day | Marketing + transactional | `smtp.sendgrid.net:587` |
| **AWS SES** | 62K/month (from EC2) | High volume, AWS ecosystem | `email-smtp.{region}.amazonaws.com:587` |
| **Mailtrap** | 1000/month | Testing/staging | `sandbox.smtp.mailtrap.io:587` |
| **Resend** | 3000/month | Developer-friendly, React Email | `smtp.resend.com:465` |

---

## Node.js — Nodemailer

### Installation
```bash
npm install nodemailer
npm install -D @types/nodemailer
```

### Configuration
```typescript
// lib/email.ts
import nodemailer from 'nodemailer';

interface EmailConfig {
  host: string;
  port: number;
  secure: boolean;
  auth: { user: string; pass: string };
}

function createTransporter(): nodemailer.Transporter {
  const config: EmailConfig = {
    host: process.env.SMTP_HOST!,
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER!,
      pass: process.env.SMTP_PASSWORD!,
    },
  };

  const transporter = nodemailer.createTransport(config);

  // Verify connection on startup
  transporter.verify((error) => {
    if (error) {
      console.error('SMTP connection failed:', error.message);
    } else {
      console.log('SMTP server ready');
    }
  });

  return transporter;
}

export const transporter = createTransporter();
```

### Send Email Function
```typescript
// services/emailService.ts
import { transporter } from '@/lib/email';

interface SendEmailOptions {
  to: string | string[];
  subject: string;
  html: string;
  text?: string;
  from?: string;
  replyTo?: string;
  attachments?: Array<{ filename: string; content: Buffer; contentType: string }>;
}

export async function sendEmail(options: SendEmailOptions): Promise<boolean> {
  try {
    const result = await transporter.sendMail({
      from: options.from || `"${process.env.APP_NAME}" <${process.env.SMTP_FROM}>`,
      to: Array.isArray(options.to) ? options.to.join(', ') : options.to,
      subject: options.subject,
      html: options.html,
      text: options.text || stripHtml(options.html),
      replyTo: options.replyTo,
      attachments: options.attachments,
    });

    console.log(`Email sent: ${result.messageId} to ${options.to}`);
    return true;
  } catch (error) {
    console.error('Email send failed:', error);
    return false;
  }
}

function stripHtml(html: string): string {
  return html.replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim();
}
```

### Usage — Common Email Types
```typescript
// Verification email
await sendEmail({
  to: user.email,
  subject: 'Verifikasi Email Anda',
  html: verificationTemplate({ name: user.fullName, link: verifyUrl }),
});

// Password reset
await sendEmail({
  to: user.email,
  subject: 'Reset Password',
  html: resetPasswordTemplate({ name: user.fullName, link: resetUrl, expiresIn: '1 jam' }),
});

// Welcome email
await sendEmail({
  to: user.email,
  subject: `Selamat datang di ${APP_NAME}!`,
  html: welcomeTemplate({ name: user.fullName }),
});

// Invoice / transactional
await sendEmail({
  to: order.customerEmail,
  subject: `Invoice #${order.invoiceNumber}`,
  html: invoiceTemplate(order),
  attachments: [{ filename: `invoice-${order.invoiceNumber}.pdf`, content: pdfBuffer, contentType: 'application/pdf' }],
});
```

---

## Laravel — Built-in Mail

```php
// .env
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=postmaster@yourdomain.com
MAIL_PASSWORD=your-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME="${APP_NAME}"

// Create Mailable
// php artisan make:mail VerificationMail

// app/Mail/VerificationMail.php
class VerificationMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public readonly User $user,
        public readonly string $verificationUrl,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: 'Verifikasi Email Anda');
    }

    public function content(): Content
    {
        return new Content(view: 'emails.verification');
    }
}

// Send
Mail::to($user->email)->send(new VerificationMail($user, $url));

// Queue (production — always queue emails)
Mail::to($user->email)->queue(new VerificationMail($user, $url));
```

---

## Email Template (Base Layout)

```html
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; background-color: #f8fafc; font-family: 'Inter', -apple-system, sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f8fafc; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 540px; background: #ffffff; border-radius: 12px; border: 1px solid #e2e8f0; overflow: hidden;">
          <!-- Header -->
          <tr>
            <td style="background: linear-gradient(135deg, #6366f1, #8b5cf6); padding: 32px 40px; text-align: center;">
              <h1 style="color: #ffffff; font-size: 20px; font-weight: 700; margin: 0;">APP_NAME</h1>
            </td>
          </tr>
          <!-- Content -->
          <tr>
            <td style="padding: 40px;">
              <!-- CONTENT HERE -->
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="padding: 24px 40px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: center;">
              <p style="color: #94a3b8; font-size: 12px; margin: 0;">
                &copy; 2025 APP_NAME. All rights reserved.<br>
                <a href="{{unsubscribe_url}}" style="color: #6366f1;">Berhenti berlangganan</a>
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

---

## Deliverability — SPF, DKIM, DMARC

```
DNS Records (REQUIRED for production):

1. SPF — Authorize mail servers
   TXT @ "v=spf1 include:mailgun.org include:_spf.google.com ~all"

2. DKIM — Sign emails cryptographically
   TXT mail._domainkey "v=DKIM1; k=rsa; p=YOUR_PUBLIC_KEY"

3. DMARC — Policy for failed checks
   TXT _dmarc "v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com; pct=100"
```

---

## Environment Variables
```bash
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=postmaster@mg.yourdomain.com
SMTP_PASSWORD=your-smtp-password
SMTP_FROM=noreply@yourdomain.com
APP_NAME="Your App"
```

## Best Practices
1. **Always queue emails** in production — never send synchronously in request
2. **Use templates** — consistent branding, no inline HTML in code
3. **Include plain text version** — not just HTML
4. **Set up SPF/DKIM/DMARC** — or emails go to spam
5. **Use Mailtrap for testing** — never test with real SMTP in development
6. **Rate limit email sending** — respect provider limits
7. **Log sends, not content** — log recipient + status, never email body
8. **Handle bounces** — monitor bounce rates, clean email lists
9. **Unsubscribe link** — required by law for marketing emails
10. **Verify SMTP on startup** — fail fast if config is wrong

## Rules Integration
- **SMTP OTP**: OTP delivery via SMTP in `skills/smtp-otp/`
- **Developer Security**: Email credential security in `rules/developer-security.md`
- **UU PDP**: Marketing emails require consent in `rules/uu-pdp-compliance.md`
