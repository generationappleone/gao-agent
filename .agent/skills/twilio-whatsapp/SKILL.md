---
name: Twilio / WhatsApp API
description: Skill for communication APIs — covering Twilio SMS, Voice, WhatsApp Business API, Verify (OTP), webhooks, and message templates.
---

# Twilio / WhatsApp API Skill

## Overview
Twilio is a cloud communications platform providing SMS, Voice, WhatsApp, and Verify (OTP) APIs. It enables sending transactional messages, OTP verification, two-way conversations, and programmable voice calls from applications.

**References**:
- [Twilio Documentation](https://www.twilio.com/docs)
- [Twilio Node.js SDK](https://www.twilio.com/docs/libraries/reference/twilio-node/)
- [WhatsApp Business API](https://www.twilio.com/docs/whatsapp)
- [Twilio Verify](https://www.twilio.com/docs/verify)

---

## Setup

```bash
npm install twilio
```

```typescript
// src/lib/twilio.ts
import Twilio from 'twilio';

const client = Twilio(process.env.TWILIO_ACCOUNT_SID!, process.env.TWILIO_AUTH_TOKEN!);

export { client };

// Environment variables:
// TWILIO_ACCOUNT_SID=ACxxxxxxxx
// TWILIO_AUTH_TOKEN=xxxxxxxxxx
// TWILIO_PHONE_NUMBER=+1234567890
// TWILIO_WHATSAPP_NUMBER=+14155238886
// TWILIO_VERIFY_SERVICE_SID=VAxxxxxxxx
```

---

## SMS

```typescript
// ── Send SMS ──
async function sendSms(to: string, body: string) {
  const message = await client.messages.create({
    to,                                    // '+6281234567890'
    from: process.env.TWILIO_PHONE_NUMBER!,
    body,
    statusCallback: 'https://api.myapp.com/webhooks/twilio/status', // Optional
  });

  console.log(`SMS sent: ${message.sid} → ${message.status}`);
  return message.sid;
}

// ── Send SMS with media (MMS) ──
async function sendMms(to: string, body: string, mediaUrl: string) {
  const message = await client.messages.create({
    to,
    from: process.env.TWILIO_PHONE_NUMBER!,
    body,
    mediaUrl: [mediaUrl],
  });
  return message.sid;
}

// ── Notification examples ──
await sendSms('+6281234567890', 'Your order #12345 has been shipped! Track at https://myapp.com/track/12345');
await sendSms('+6281234567890', 'Your verification code is: 123456. Valid for 5 minutes.');
```

---

## WhatsApp

```typescript
// ── Send WhatsApp message ──
async function sendWhatsApp(to: string, body: string) {
  const message = await client.messages.create({
    to: `whatsapp:${to}`,                 // 'whatsapp:+6281234567890'
    from: `whatsapp:${process.env.TWILIO_WHATSAPP_NUMBER!}`,
    body,
    statusCallback: 'https://api.myapp.com/webhooks/twilio/whatsapp-status',
  });

  console.log(`WhatsApp sent: ${message.sid}`);
  return message.sid;
}

// ── Send WhatsApp template message ──
async function sendWhatsAppTemplate(to: string, templateSid: string, variables: Record<string, string>) {
  const message = await client.messages.create({
    to: `whatsapp:${to}`,
    from: `whatsapp:${process.env.TWILIO_WHATSAPP_NUMBER!}`,
    contentSid: templateSid,
    contentVariables: JSON.stringify(variables),
  });

  return message.sid;
}

// ── Send WhatsApp with media ──
async function sendWhatsAppMedia(to: string, body: string, mediaUrl: string) {
  const message = await client.messages.create({
    to: `whatsapp:${to}`,
    from: `whatsapp:${process.env.TWILIO_WHATSAPP_NUMBER!}`,
    body,
    mediaUrl: [mediaUrl],
  });

  return message.sid;
}

// Usage
await sendWhatsApp('+6281234567890', 'Your order #12345 has been confirmed! 📦');
await sendWhatsAppTemplate('+6281234567890', 'HXxxxxxx', { '1': 'John', '2': 'ORD-12345' });
```

---

## Verify (OTP)

```typescript
// ── Send OTP ──
async function sendOtp(to: string, channel: 'sms' | 'whatsapp' | 'email' = 'sms') {
  const verification = await client.verify.v2
    .services(process.env.TWILIO_VERIFY_SERVICE_SID!)
    .verifications.create({
      to,                              // '+6281234567890' or 'john@example.com'
      channel,                         // 'sms', 'whatsapp', 'email'
    });

  console.log(`OTP sent via ${channel}: ${verification.status}`);
  return verification.status;          // 'pending'
}

// ── Verify OTP ──
async function verifyOtp(to: string, code: string): Promise<boolean> {
  try {
    const check = await client.verify.v2
      .services(process.env.TWILIO_VERIFY_SERVICE_SID!)
      .verificationChecks.create({ to, code });

    return check.status === 'approved';
  } catch (error) {
    // Code expired or invalid
    return false;
  }
}

// ── API Routes ──
// POST /api/auth/send-otp
export async function handleSendOtp(req: Request) {
  const { phone, channel } = await req.json();

  // Rate limiting
  const rateLimitKey = `otp:${phone}`;
  const attempts = await redis.incr(rateLimitKey);
  if (attempts === 1) await redis.expire(rateLimitKey, 3600); // 1 hour window
  if (attempts > 5) {
    return json({ error: 'Too many OTP requests. Try again later.' }, { status: 429 });
  }

  await sendOtp(phone, channel || 'sms');
  return json({ message: 'OTP sent successfully' });
}

// POST /api/auth/verify-otp
export async function handleVerifyOtp(req: Request) {
  const { phone, code } = await req.json();

  const isValid = await verifyOtp(phone, code);
  if (!isValid) {
    return json({ error: 'Invalid or expired OTP' }, { status: 400 });
  }

  // Generate session/JWT
  const user = await findOrCreateUser(phone);
  const tokens = generateTokenPair(user);

  return json({ ...tokens, user });
}
```

---

## Webhooks

```typescript
// src/webhooks/twilio.ts
import { validateRequest } from 'twilio';

// ── Webhook middleware (verify Twilio signature) ──
function verifyTwilioWebhook(req: Request, authToken: string): boolean {
  const signature = req.headers.get('x-twilio-signature')!;
  const url = `${process.env.BASE_URL}${req.url}`;
  const params = Object.fromEntries(new URLSearchParams(await req.text()));

  return validateRequest(authToken, signature, url, params);
}

// ── Incoming SMS webhook ──
// POST /webhooks/twilio/sms
export async function handleIncomingSms(req: Request) {
  const body = Object.fromEntries(new URLSearchParams(await req.text()));
  const { From, Body, MessageSid } = body;

  console.log(`SMS from ${From}: ${Body}`);

  // Auto-reply
  const twiml = `<?xml version="1.0" encoding="UTF-8"?>
    <Response>
      <Message>Thanks for your message! We'll get back to you shortly.</Message>
    </Response>`;

  return new Response(twiml, {
    headers: { 'Content-Type': 'text/xml' },
  });
}

// ── Message status webhook ──
// POST /webhooks/twilio/status
export async function handleStatusCallback(req: Request) {
  const body = Object.fromEntries(new URLSearchParams(await req.text()));
  const { MessageSid, MessageStatus, To, ErrorCode } = body;

  console.log(`Message ${MessageSid} → ${MessageStatus}`);

  // Status: queued → sent → delivered (or failed/undelivered)
  if (MessageStatus === 'failed' || MessageStatus === 'undelivered') {
    console.error(`Delivery failed: ${ErrorCode}`);
    await logDeliveryFailure(MessageSid, ErrorCode);
  }

  return new Response('OK');
}

// ── Incoming WhatsApp webhook ──
// POST /webhooks/twilio/whatsapp
export async function handleIncomingWhatsApp(req: Request) {
  const body = Object.fromEntries(new URLSearchParams(await req.text()));
  const { From, Body, NumMedia, MediaUrl0 } = body;

  const phone = From.replace('whatsapp:', '');
  console.log(`WhatsApp from ${phone}: ${Body}`);

  if (NumMedia && parseInt(NumMedia) > 0) {
    console.log(`Media attachment: ${MediaUrl0}`);
  }

  // Process and respond
  const reply = await processWhatsAppMessage(phone, Body);

  const twiml = `<?xml version="1.0" encoding="UTF-8"?>
    <Response><Message>${reply}</Message></Response>`;

  return new Response(twiml, { headers: { 'Content-Type': 'text/xml' } });
}
```

---

## Notification Service

```typescript
// src/services/notification.service.ts
class NotificationService {
  async sendOrderConfirmation(order: Order, user: User) {
    const message = `Hi ${user.firstName}! Your order #${order.orderNumber} has been confirmed. Total: $${order.totalAmount}. Track at https://myapp.com/orders/${order.id}`;

    // Send via preferred channel
    if (user.whatsappOptIn && user.phone) {
      await sendWhatsApp(user.phone, message);
    } else if (user.phone) {
      await sendSms(user.phone, message);
    }
  }

  async sendShippingUpdate(order: Order, user: User, trackingNumber: string) {
    const message = `📦 Your order #${order.orderNumber} has shipped!\nTracking: ${trackingNumber}\nTrack at https://myapp.com/track/${trackingNumber}`;

    if (user.whatsappOptIn && user.phone) {
      await sendWhatsApp(user.phone, message);
    }
  }
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Verify for OTP** | Use Twilio Verify instead of custom OTP via SMS |
| **Rate limiting** | Limit OTP requests (max 5/hour per phone) |
| **Webhook verification** | Always verify Twilio signature on webhooks |
| **Error handling** | Handle `21608` (unsubscribed), `21610` (blacklisted) |
| **Templates** | WhatsApp requires pre-approved templates for outbound |
| **Status callbacks** | Track delivery status via webhooks |
| **E.164 format** | Always use international format: `+6281234567890` |
| **Opt-in** | Obtain explicit consent before sending WhatsApp messages |

---

## Rules Integration
- **SMS**: Send via `client.messages.create`, track delivery via status callbacks
- **WhatsApp**: Prefix with `whatsapp:`, use templates for outbound, handle media
- **OTP**: Twilio Verify for send/check, rate limiting, session creation
- **Webhooks**: TwiML responses for incoming, signature verification
- **Security**: Rate limiting, opt-in tracking, E.164 phone format
