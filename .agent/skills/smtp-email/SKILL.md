---
name: SMTP Email
description: Skill for sending transactional and notification emails via SMTP — covering Nodemailer, Laravel Mail, email templates, SPF/DKIM/DMARC, and email service providers (Gmail, Mailgun, SendGrid, AWS SES).
---

# SMTP Email Skill

## Overview
SMTP (Simple Mail Transfer Protocol) is used for sending transactional emails, notifications, password resets, and marketing emails. Nodemailer is the standard Node.js library. For production, use services like Mailgun, SendGrid, or AWS SES with proper SPF/DKIM/DMARC configuration.

**References**:
- [Nodemailer Documentation](https://nodemailer.com/)
- [SendGrid Documentation](https://docs.sendgrid.com/)
- [Mailgun Documentation](https://documentation.mailgun.com/)

---

## Setup (Nodemailer)

```typescript
// src/lib/mailer.ts
import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: Number(process.env.SMTP_PORT) || 587,
  secure: false, // true for 465
  auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
});

export async function sendEmail(options: { to: string; subject: string; html: string; text?: string }) {
  return transporter.sendMail({
    from: `"${process.env.APP_NAME}" <${process.env.SMTP_FROM}>`,
    to: options.to,
    subject: options.subject,
    html: options.html,
    text: options.text,
  });
}
```

---

## Email Templates

```typescript
// src/emails/templates.ts
export function welcomeEmail(name: string): string {
  return `
    <div style="font-family:'Inter',sans-serif;max-width:600px;margin:0 auto;padding:40px 20px;">
      <h1 style="color:#1e293b;font-size:24px;">Welcome, ${name}!</h1>
      <p style="color:#64748b;font-size:16px;line-height:1.6;">Thank you for joining us. Your account has been created successfully.</p>
      <a href="${process.env.APP_URL}/dashboard" style="display:inline-block;padding:12px 24px;background:#6366f1;color:white;text-decoration:none;border-radius:8px;font-weight:600;">Go to Dashboard</a>
      <p style="color:#94a3b8;font-size:14px;margin-top:32px;">— The ${process.env.APP_NAME} Team</p>
    </div>
  `;
}

export function resetPasswordEmail(name: string, resetUrl: string): string {
  return `
    <div style="font-family:'Inter',sans-serif;max-width:600px;margin:0 auto;padding:40px 20px;">
      <h1 style="color:#1e293b;font-size:24px;">Password Reset</h1>
      <p style="color:#64748b;">Hi ${name}, click below to reset your password. This link expires in 1 hour.</p>
      <a href="${resetUrl}" style="display:inline-block;padding:12px 24px;background:#6366f1;color:white;text-decoration:none;border-radius:8px;">Reset Password</a>
      <p style="color:#94a3b8;font-size:12px;">If you didn't request this, please ignore this email.</p>
    </div>
  `;
}

export function orderConfirmationEmail(order: any): string {
  const itemRows = order.items.map((item: any) => `
    <tr><td style="padding:8px;border-bottom:1px solid #e5e7eb;">${item.name}</td>
    <td style="padding:8px;text-align:center;">${item.quantity}</td>
    <td style="padding:8px;text-align:right;">$${(item.total / 100).toFixed(2)}</td></tr>
  `).join('');

  return `
    <div style="font-family:'Inter',sans-serif;max-width:600px;margin:0 auto;">
      <h1>Order Confirmed</h1>
      <p>Order #${order.orderNumber}</p>
      <table style="width:100%;border-collapse:collapse;">
        <thead><tr><th style="text-align:left;padding:8px;">Product</th><th>Qty</th><th style="text-align:right;">Total</th></tr></thead>
        <tbody>${itemRows}</tbody>
        <tfoot><tr><td colspan="2" style="padding:8px;font-weight:700;">Total</td><td style="padding:8px;text-align:right;font-weight:700;">$${(order.total / 100).toFixed(2)}</td></tr></tfoot>
      </table>
    </div>
  `;
}
```

---

## Usage

```typescript
// Send welcome email
await sendEmail({ to: user.email, subject: 'Welcome to MyApp!', html: welcomeEmail(user.name) });

// Send password reset
await sendEmail({ to: user.email, subject: 'Reset Your Password', html: resetPasswordEmail(user.name, resetUrl) });

// Send order confirmation
await sendEmail({ to: user.email, subject: `Order #${order.orderNumber} Confirmed`, html: orderConfirmationEmail(order) });
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Provider** | Use Mailgun/SendGrid/SES for production |
| **SPF/DKIM/DMARC** | Configure DNS records for deliverability |
| **Templates** | Inline CSS for email client compatibility |
| **Queue** | Queue emails with Bull/RabbitMQ for reliability |
| **Unsubscribe** | Include unsubscribe link in marketing emails |
| **Testing** | Use Mailtrap/Ethereal for development |
| **Rate limiting** | Respect provider sending limits |
| **Text fallback** | Include plain text version |
| **From address** | Use consistent, verified sender address |
| **Error handling** | Retry failed sends, log errors |

---

## Rules Integration
- **Transport**: Nodemailer with SMTP config
- **Templates**: Inline-styled HTML for compatibility
- **Types**: Welcome, reset password, order confirmation
- **Production**: Queue + provider (Mailgun/SendGrid/SES)
