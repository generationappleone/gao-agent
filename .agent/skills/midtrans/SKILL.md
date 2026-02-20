---
name: Midtrans Payment Gateway
description: Skill for Midtrans — Indonesian payment gateway integration covering Snap API, Core API, payment channels (credit card, bank transfer/VA, e-wallet, QRIS, convenience store), webhook notifications, refunds, and CMS plugins.
---

# Midtrans Skill

## Overview
Midtrans is Indonesia's leading payment gateway supporting Snap (hosted checkout), Core API, GoPay, ShopeePay, QRIS, virtual accounts (BCA, BNI, BRI, Mandiri), credit cards, convenience stores (Indomaret, Alfamart), and recurring payments.

**References**:
- [Midtrans Documentation](https://docs.midtrans.com/)
- [Midtrans Node SDK](https://github.com/Midtrans/midtrans-nodejs-client)

---

## Snap Transaction

```typescript
import midtransClient from 'midtrans-client';

const snap = new midtransClient.Snap({
  isProduction: process.env.NODE_ENV === 'production',
  serverKey: process.env.MIDTRANS_SERVER_KEY!,
  clientKey: process.env.MIDTRANS_CLIENT_KEY!,
});

export async function createSnapTransaction(order: Order) {
  const parameter = {
    transaction_details: { order_id: order.id, gross_amount: order.total },
    customer_details: { first_name: order.user.name, email: order.user.email, phone: order.user.phone },
    item_details: order.items.map(item => ({
      id: item.productId, price: item.unitPrice, quantity: item.quantity, name: item.name.slice(0, 50),
    })),
    callbacks: { finish: `${process.env.APP_URL}/orders/${order.id}` },
  };

  const transaction = await snap.createTransaction(parameter);
  return { token: transaction.token, redirectUrl: transaction.redirect_url };
}
```

---

## Webhook (Notification Handler)

```typescript
const core = new midtransClient.CoreApi({
  isProduction: process.env.NODE_ENV === 'production',
  serverKey: process.env.MIDTRANS_SERVER_KEY!,
});

router.post('/midtrans', async (req, res) => {
  const notification = await core.transaction.notification(req.body);
  const { order_id, transaction_status, fraud_status, payment_type } = notification;

  if (transaction_status === 'capture' && fraud_status === 'accept' || transaction_status === 'settlement') {
    await db.order.update({ where: { id: order_id }, data: { status: 'paid', paidAt: new Date(), paymentMethod: payment_type } });
    await sendOrderConfirmation(order_id);
  } else if (['deny', 'cancel', 'expire'].includes(transaction_status)) {
    await db.order.update({ where: { id: order_id }, data: { status: 'cancelled' } });
    await restoreStock(order_id);
  }

  res.json({ status: 'ok' });
});
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Snap** | Hosted checkout for quick integration |
| **Core API** | Custom checkout flow |
| **Server key** | Never expose server key to frontend |
| **Notification** | Use notification handler for verification |
| **fraud_status** | Check `accept` before confirming |
| **Sandbox** | Test with sandbox credentials |
| **GoPay** | E-wallet with QR and deeplink |
| **QRIS** | Universal QR standard |
| **VA** | BCA, BNI, BRI, Mandiri virtual accounts |
| **Idempotency** | Handle duplicate notifications |

---

## Rules Integration
- **Snap**: Hosted checkout with redirect
- **Webhook**: Core API notification verification
- **Status**: Handle capture/settlement/deny/cancel
- **Payment types**: VA, e-wallet, QRIS, cards, stores
