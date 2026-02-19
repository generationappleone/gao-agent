---
name: Stripe / Payment Gateway
description: Skill for implementing payment processing with Stripe — covering Checkout, Payment Intents, subscriptions, webhooks, customer management, invoices, and PCI compliance.
---

# Stripe / Payment Gateway Skill

## Overview
Stripe is the leading payment processing platform for internet businesses. This skill covers Stripe API integration for payments, subscriptions, and billing.

**Reference**: [Stripe Documentation](https://stripe.com/docs)

## Setup
```bash
npm install stripe @stripe/stripe-js @stripe/react-stripe-js
```

## Server-Side (Node.js)
```typescript
import Stripe from "stripe";
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

// Create Payment Intent
app.post("/api/create-payment-intent", async (req, res) => {
  const { amount, currency = "usd" } = req.body;
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(amount * 100), // cents
    currency,
    automatic_payment_methods: { enabled: true },
    metadata: { orderId: req.body.orderId },
  });
  res.json({ clientSecret: paymentIntent.client_secret });
});

// Checkout Session (hosted)
app.post("/api/checkout", async (req, res) => {
  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    line_items: [{ price: "price_xxx", quantity: 1 }],
    success_url: `${process.env.APP_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.APP_URL}/cancel`,
  });
  res.json({ url: session.url });
});

// Subscription
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: "price_monthly_xxx" }],
  payment_behavior: "default_incomplete",
  expand: ["latest_invoice.payment_intent"],
});

// Webhook handler
app.post("/webhook", express.raw({ type: "application/json" }), (req, res) => {
  const sig = req.headers["stripe-signature"]!;
  const event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET!);

  switch (event.type) {
    case "payment_intent.succeeded":
      await handlePaymentSuccess(event.data.object);
      break;
    case "invoice.paid":
      await handleInvoicePaid(event.data.object);
      break;
    case "customer.subscription.deleted":
      await handleSubscriptionCanceled(event.data.object);
      break;
  }
  res.json({ received: true });
});
```

## Client-Side (React)
```tsx
import { loadStripe } from "@stripe/stripe-js";
import { Elements, PaymentElement, useStripe, useElements } from "@stripe/react-stripe-js";

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_KEY!);

function CheckoutForm() {
  const stripe = useStripe();
  const elements = useElements();

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (!stripe || !elements) return;
    const { error } = await stripe.confirmPayment({
      elements, confirmParams: { return_url: `${window.location.origin}/success` },
    });
    if (error) console.error(error.message);
  };

  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      <button disabled={!stripe}>Pay</button>
    </form>
  );
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Webhooks** | Primary source of truth for payment status |
| **Idempotency keys** | Prevent duplicate charges |
| **Server-side amounts** | Never trust client-side pricing |
| **Metadata** | Attach order/user IDs to payments |
| **Test mode** | Use `sk_test_` keys for development |
| **PCI compliance** | Use Stripe Elements — never handle raw card data |
| **Error handling** | Handle all Stripe error types gracefully |
| **Webhook signature** | Always verify webhook signatures |
