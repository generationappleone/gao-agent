---
name: Xendit Payment Gateway
description: Skill for Xendit — Southeast Asian payment gateway covering invoices, e-wallets (OVO, DANA, ShopeePay, LinkAja), virtual accounts, QRIS, direct debit, disbursements/payouts, webhook callbacks, and multi-language SDK integration.
---

# Xendit Skill

## Overview
Xendit is a leading Southeast Asian payment gateway supporting invoices, virtual accounts, e-wallets (OVO, DANA, ShopeePay, GoPay), QRIS, credit cards, and disbursements. It provides robust webhook notifications and multi-currency support.

**References**:
- [Xendit API Documentation](https://developers.xendit.co/)
- [Xendit Node SDK](https://github.com/xendit/xendit-node)

---

## Invoice

```typescript
import Xendit from 'xendit-node';
const xendit = new Xendit({ secretKey: process.env.XENDIT_SECRET_KEY! });

// Create invoice
export async function createInvoice(order: Order) {
  const invoice = await xendit.Invoice.createInvoice({
    externalId: order.id,
    amount: order.total,
    description: `Order #${order.orderNumber}`,
    currency: 'IDR',
    customer: { givenNames: order.user.name, email: order.user.email, mobileNumber: order.user.phone },
    customerNotificationPreference: { invoiceCreated: ['email', 'whatsapp'] },
    successRedirectUrl: `${process.env.APP_URL}/orders/${order.id}/success`,
    failureRedirectUrl: `${process.env.APP_URL}/orders/${order.id}/failed`,
    items: order.items.map(item => ({ name: item.name, quantity: item.quantity, price: item.unitPrice })),
  });
  return { invoiceUrl: invoice.invoiceUrl, invoiceId: invoice.id };
}
```

---

## Webhook Handler

```typescript
// POST /api/webhooks/xendit
router.post('/xendit', async (req, res) => {
  const callbackToken = req.headers['x-callback-token'];
  if (callbackToken !== process.env.XENDIT_CALLBACK_TOKEN) return res.status(401).json({ error: 'Unauthorized' });

  const { external_id, status, paid_amount, payment_method, payment_channel } = req.body;

  switch (status) {
    case 'PAID':
      await db.order.update({ where: { id: external_id }, data: { status: 'paid', paidAt: new Date(), paymentMethod: payment_method, paymentChannel: payment_channel } });
      await sendOrderConfirmation(external_id);
      break;
    case 'EXPIRED':
      await db.order.update({ where: { id: external_id }, data: { status: 'expired' } });
      await restoreStock(external_id);
      break;
  }

  res.json({ status: 'ok' });
});
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Callback token** | Verify X-Callback-Token header |
| **Idempotency** | Handle duplicate webhook calls |
| **External ID** | Use order ID as external_id |
| **Currency** | IDR for Indonesian payments |
| **E-wallets** | OVO, DANA, ShopeePay, GoPay support |
| **QRIS** | QR code payment support |
| **Virtual accounts** | BCA, BNI, BRI, Mandiri, Permata |
| **Disbursements** | Automated payouts to vendors |
| **Sandbox** | Test with sandbox API keys |
| **Notifications** | Email + WhatsApp customer notifications |

---

## Rules Integration
- **Invoice**: Create with items, customer, redirects
- **Webhook**: Verify callback token, handle PAID/EXPIRED
- **Payment methods**: E-wallets, VA, QRIS, credit cards
- **Idempotency**: Handle duplicate webhook events
