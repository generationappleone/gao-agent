---
name: Stripe / Payment Gateway
description: Skill for implementing payment processing with Stripe — covering Checkout, Payment Intents, subscriptions, webhooks, customer management, invoices, and PCI compliance.
---

# Stripe / Payment Gateway Skill

## Overview
Stripe is the leading payment processing platform for internet businesses. It provides APIs for one-time payments (Payment Intents), recurring billing (Subscriptions), hosted checkout (Checkout Sessions), customer management, invoicing, and webhook-driven event processing. Stripe handles PCI compliance.

**References**:
- [Stripe API Documentation](https://stripe.com/docs/api)
- [Stripe Node.js SDK](https://www.npmjs.com/package/stripe)
- [Stripe Elements](https://stripe.com/docs/stripe-js)

---

## Setup

```bash
npm install stripe @stripe/stripe-js @stripe/react-stripe-js
```

```typescript
// src/lib/stripe.ts (Server)
import Stripe from 'stripe';

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
  typescript: true,
});
```

```typescript
// src/lib/stripe-client.ts (Client)
import { loadStripe } from '@stripe/stripe-js';

export const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);
```

---

## Checkout Session (Hosted)

```typescript
// POST /api/checkout
export async function createCheckoutSession(req: Request) {
  const { items, userId, email } = req.body;

  // Find or create customer
  let customer: Stripe.Customer;
  const existing = await stripe.customers.list({ email, limit: 1 });
  if (existing.data.length > 0) {
    customer = existing.data[0];
  } else {
    customer = await stripe.customers.create({ email, metadata: { userId } });
  }

  const session = await stripe.checkout.sessions.create({
    customer: customer.id,
    mode: 'payment',
    payment_method_types: ['card'],
    line_items: items.map((item: any) => ({
      price_data: {
        currency: 'usd',
        product_data: {
          name: item.name,
          description: item.description,
          images: item.images,
        },
        unit_amount: item.price, // In cents
      },
      quantity: item.quantity,
    })),
    success_url: `${process.env.APP_URL}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.APP_URL}/checkout/cancel`,
    metadata: { userId, orderId: item.orderId },
    shipping_address_collection: { allowed_countries: ['US', 'ID'] },
    expires_at: Math.floor(Date.now() / 1000) + 3600, // 1 hour
  });

  return { url: session.url };
}
```

---

## Payment Intent (Custom UI)

```typescript
// POST /api/payment-intent
export async function createPaymentIntent(req: Request) {
  const { amount, currency, orderId, customerId } = req.body;

  const paymentIntent = await stripe.paymentIntents.create({
    amount, // In smallest currency unit (cents)
    currency: currency || 'usd',
    customer: customerId,
    metadata: { orderId },
    automatic_payment_methods: { enabled: true },
  });

  return { clientSecret: paymentIntent.client_secret };
}
```

```tsx
// React: Payment Form
import { Elements, PaymentElement, useStripe, useElements } from '@stripe/react-stripe-js';
import { stripePromise } from '@/lib/stripe-client';

function CheckoutForm() {
  const stripe = useStripe();
  const elements = useElements();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!stripe || !elements) return;

    setLoading(true);
    setError('');

    const { error: submitError } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/checkout/success`,
      },
    });

    if (submitError) {
      setError(submitError.message || 'Payment failed');
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      {error && <p className="error">{error}</p>}
      <button type="submit" disabled={!stripe || loading}>
        {loading ? 'Processing...' : 'Pay Now'}
      </button>
    </form>
  );
}

export function PaymentPage({ clientSecret }: { clientSecret: string }) {
  return (
    <Elements stripe={stripePromise} options={{ clientSecret, appearance: { theme: 'stripe' } }}>
      <CheckoutForm />
    </Elements>
  );
}
```

---

## Subscriptions

```typescript
// Create subscription
export async function createSubscription(customerId: string, priceId: string) {
  const subscription = await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
    payment_behavior: 'default_incomplete',
    payment_settings: { save_default_payment_method: 'on_subscription' },
    expand: ['latest_invoice.payment_intent'],
  });

  const invoice = subscription.latest_invoice as Stripe.Invoice;
  const paymentIntent = invoice.payment_intent as Stripe.PaymentIntent;

  return {
    subscriptionId: subscription.id,
    clientSecret: paymentIntent.client_secret,
  };
}

// Cancel subscription
export async function cancelSubscription(subscriptionId: string) {
  return stripe.subscriptions.update(subscriptionId, {
    cancel_at_period_end: true,
  });
}

// Create pricing products
export async function createPricingPlans() {
  const product = await stripe.products.create({ name: 'Pro Plan', description: 'Full access' });

  const monthly = await stripe.prices.create({
    product: product.id, unit_amount: 2999, currency: 'usd',
    recurring: { interval: 'month' },
  });

  const yearly = await stripe.prices.create({
    product: product.id, unit_amount: 29999, currency: 'usd',
    recurring: { interval: 'year' },
  });

  return { monthly, yearly };
}
```

---

## Webhooks

```typescript
// POST /api/webhooks/stripe
export async function handleStripeWebhook(req: Request) {
  const sig = req.headers['stripe-signature']!;
  const body = req.rawBody; // Raw body required

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, sig, process.env.STRIPE_WEBHOOK_SECRET!);
  } catch (err) {
    console.error('Webhook signature verification failed');
    return { status: 400 };
  }

  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object as Stripe.Checkout.Session;
      await handleCheckoutComplete(session);
      break;
    }
    case 'payment_intent.succeeded': {
      const pi = event.data.object as Stripe.PaymentIntent;
      await handlePaymentSuccess(pi);
      break;
    }
    case 'payment_intent.payment_failed': {
      const pi = event.data.object as Stripe.PaymentIntent;
      await handlePaymentFailed(pi);
      break;
    }
    case 'customer.subscription.updated': {
      const sub = event.data.object as Stripe.Subscription;
      await handleSubscriptionUpdate(sub);
      break;
    }
    case 'customer.subscription.deleted': {
      const sub = event.data.object as Stripe.Subscription;
      await handleSubscriptionCancelled(sub);
      break;
    }
    case 'invoice.payment_failed': {
      const invoice = event.data.object as Stripe.Invoice;
      await handleInvoicePaymentFailed(invoice);
      break;
    }
    default:
      console.log(`Unhandled event: ${event.type}`);
  }

  return { received: true };
}

async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  const orderId = session.metadata?.orderId;
  if (orderId) {
    await db.order.update({
      where: { id: orderId },
      data: {
        status: 'processing',
        payment: {
          create: {
            method: 'stripe',
            amount: session.amount_total!,
            status: 'paid',
            transactionId: session.payment_intent as string,
            paidAt: new Date(),
          },
        },
      },
    });
  }
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Webhook verification** | Always verify `stripe-signature` header |
| **Idempotency** | Handle duplicate webhook events gracefully |
| **Raw body** | Use raw body for webhook signature verification |
| **Amount in cents** | All amounts in smallest currency unit |
| **Customer management** | Find or create customers by email |
| **Metadata** | Attach orderId, userId to sessions/intents |
| **Error handling** | Handle card declines, expired cards |
| **Test mode** | Use `sk_test_` keys in development |
| **Payment Element** | Use Stripe Elements for PCI compliance |
| **Subscriptions** | Use `cancel_at_period_end` for graceful cancellation |

---

## Rules Integration
- **Checkout**: Hosted checkout for simple flows
- **Payment Intent**: Custom UI with Stripe Elements
- **Subscriptions**: Create, cancel, update plans
- **Webhooks**: Event-driven order/subscription updates
- **PCI**: Stripe handles card data, never on your server
