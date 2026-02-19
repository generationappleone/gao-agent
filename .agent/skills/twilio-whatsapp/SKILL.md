---
name: Twilio / WhatsApp API
description: Skill for communication APIs — covering Twilio SMS, Voice, WhatsApp Business API, Verify (OTP), webhooks, and message templates.
---

# Twilio / WhatsApp API Skill

## Overview
Twilio provides cloud communication APIs for SMS, Voice, and WhatsApp messaging. This skill covers common integration patterns.

**Reference**: [Twilio Documentation](https://www.twilio.com/docs)

## Setup
```bash
npm install twilio
```
```typescript
import twilio from "twilio";
const client = twilio(process.env.TWILIO_ACCOUNT_SID!, process.env.TWILIO_AUTH_TOKEN!);
```

## SMS
```typescript
// Send SMS
const message = await client.messages.create({
  body: "Your verification code is: 123456",
  from: process.env.TWILIO_PHONE_NUMBER!,
  to: "+6281234567890",
});

// Receive SMS (webhook)
app.post("/webhook/sms", (req, res) => {
  const { From, Body } = req.body;
  console.log(`SMS from ${From}: ${Body}`);
  const twiml = new twilio.twiml.MessagingResponse();
  twiml.message("Thanks for your message!");
  res.type("text/xml").send(twiml.toString());
});
```

## WhatsApp Business API
```typescript
// Send WhatsApp message (template)
const message = await client.messages.create({
  from: "whatsapp:+14155238886",     // Twilio sandbox or your number
  to: "whatsapp:+6281234567890",
  contentSid: "HX...",               // Pre-approved template SID
  contentVariables: JSON.stringify({ "1": "John", "2": "12345" }),
});

// Send WhatsApp free-form (within 24h window)
const message = await client.messages.create({
  from: "whatsapp:+14155238886",
  to: "whatsapp:+6281234567890",
  body: "Your order has been shipped! 🚀",
});

// Receive WhatsApp (webhook)
app.post("/webhook/whatsapp", (req, res) => {
  const { From, Body, MediaUrl0 } = req.body;
  console.log(`WhatsApp from ${From}: ${Body}`);
  if (MediaUrl0) console.log(`Media: ${MediaUrl0}`);
  res.sendStatus(200);
});
```

## Verify (OTP)
```typescript
// Send OTP
const verification = await client.verify.v2.services(process.env.TWILIO_VERIFY_SID!)
  .verifications.create({ to: "+6281234567890", channel: "sms" }); // or "whatsapp"

// Verify OTP
const check = await client.verify.v2.services(process.env.TWILIO_VERIFY_SID!)
  .verificationChecks.create({ to: "+6281234567890", code: "123456" });

if (check.status === "approved") console.log("OTP verified!");
```

## Voice Call
```typescript
const call = await client.calls.create({
  url: "https://example.com/twiml/greeting.xml",
  from: process.env.TWILIO_PHONE_NUMBER!,
  to: "+6281234567890",
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Webhook validation** | Verify Twilio request signatures |
| **Rate limiting** | Respect messaging rate limits |
| **Templates** | Pre-approve WhatsApp templates |
| **Error handling** | Handle Twilio error codes (30000+) |
| **Opt-in/out** | Implement unsubscribe for compliance |
| **Logging** | Log message SIDs for tracking |
| **Test credentials** | Use test credentials in development |
| **Fallback** | Implement SMS fallback for WhatsApp |
