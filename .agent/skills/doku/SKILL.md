---
name: DOKU Payment Gateway
description: Skill for DOKU — Indonesia's pioneer payment gateway covering Checkout API, Direct API, virtual accounts, e-wallets, QRIS, credit cards, convenience stores, SNAP BI compliance, and webhook notification handling.
---

# DOKU Payment Gateway Skill

## Overview
DOKU is Indonesia's pioneer digital payment platform, providing a comprehensive payment gateway with virtual accounts, e-wallets (OVO, DANA, ShopeePay, LinkAja, GoPay), QRIS, credit/debit cards, and convenience store payments. It supports both Checkout (hosted) and Direct (API) integration methods, with SNAP BI compliance.

**References**:
- [DOKU API Documentation](https://developers.doku.com/)
- [DOKU Dashboard](https://dashboard.doku.com/)
- [SNAP BI Standard](https://apidevportal.bi.go.id/)

---

## Setup

```typescript
// src/lib/doku.ts
import crypto from 'crypto';

const DOKU_CLIENT_ID = process.env.DOKU_CLIENT_ID!;
const DOKU_SECRET_KEY = process.env.DOKU_SECRET_KEY!;
const DOKU_BASE_URL = process.env.DOKU_BASE_URL || 'https://api-sandbox.doku.com'; // or https://api.doku.com

// ── Generate signature ──
function generateSignature(
  clientId: string,
  requestId: string,
  timestamp: string,
  requestTarget: string,
  body: string,
  secretKey: string,
): string {
  // Digest body
  const digest = crypto.createHash('sha256').update(body).digest('base64');

  // Component signature
  const componentSignature = `Client-Id:${clientId}\nRequest-Id:${requestId}\nRequest-Timestamp:${timestamp}\nRequest-Target:${requestTarget}\nDigest:${digest}`;

  // HMAC-SHA256
  const signature = crypto
    .createHmac('sha256', secretKey)
    .update(componentSignature)
    .digest('base64');

  return `HMACSHA256=${signature}`;
}

// ── DOKU API client ──
async function dokuApi(
  method: string,
  path: string,
  body: object,
): Promise<any> {
  const requestId = crypto.randomUUID();
  const timestamp = new Date().toISOString();
  const bodyString = JSON.stringify(body);

  const signature = generateSignature(
    DOKU_CLIENT_ID,
    requestId,
    timestamp,
    path,
    bodyString,
    DOKU_SECRET_KEY,
  );

  const res = await fetch(`${DOKU_BASE_URL}${path}`, {
    method,
    headers: {
      'Client-Id': DOKU_CLIENT_ID,
      'Request-Id': requestId,
      'Request-Timestamp': timestamp,
      'Signature': signature,
      'Content-Type': 'application/json',
    },
    body: bodyString,
  });

  const data = await res.json();

  if (!res.ok) {
    throw new Error(`DOKU API error: ${data.message?.en || JSON.stringify(data)}`);
  }

  return data;
}
```

---

## Checkout API (Hosted Payment Page)

```typescript
// ── Create Checkout ──
async function createCheckout(order: Order, customer: Customer) {
  const response = await dokuApi('POST', '/checkout/v1/payment', {
    order: {
      invoice_number: order.orderNumber,
      amount: order.totalAmount,
      currency: 'IDR',
      callback_url: `${process.env.API_URL}/webhooks/doku`,
      callback_url_cancel: `${process.env.FRONTEND_URL}/orders/${order.id}/cancelled`,
      language: 'ID',
      auto_redirect: true,
      disable_retry_payment: false,
      line_items: order.items.map(item => ({
        name: item.name,
        quantity: item.quantity,
        price: item.price,
      })),
    },
    payment: {
      payment_due_date: 60,  // minutes
      payment_method_types: [
        'VIRTUAL_ACCOUNT_BCA',
        'VIRTUAL_ACCOUNT_BNI',
        'VIRTUAL_ACCOUNT_BRI',
        'VIRTUAL_ACCOUNT_MANDIRI',
        'VIRTUAL_ACCOUNT_PERMATA',
        'EMONEY_OVO',
        'EMONEY_DANA',
        'EMONEY_SHOPEE_PAY',
        'EMONEY_LINK_AJA',
        'QRIS',
        'CREDIT_CARD',
        'ALFAMART',
        'INDOMARET',
      ],
    },
    customer: {
      id: customer.id,
      name: `${customer.firstName} ${customer.lastName}`,
      email: customer.email,
      phone: customer.phone,
      country: 'ID',
    },
    additional_info: {
      allow_tenor: [0, 3, 6, 12],  // Credit card installment options
      close_redirect: `${process.env.FRONTEND_URL}/orders/${order.id}`,
    },
  });

  // Save payment URL
  await db.order.update({
    where: { id: order.id },
    data: {
      dokuInvoiceNumber: order.orderNumber,
      paymentUrl: response.response.payment.url,
      paymentStatus: 'PENDING',
    },
  });

  return {
    paymentUrl: response.response.payment.url,
    invoiceNumber: order.orderNumber,
    expiredAt: response.response.payment.expired_date,
  };
}
```

---

## Direct API — Virtual Account

```typescript
// ── Create Virtual Account ──
async function createVirtualAccount(order: Order, bankCode: string) {
  // Map bank code to path
  const bankPaths: Record<string, string> = {
    BCA: '/bca-virtual-account/v2/payment-code',
    BNI: '/bni-virtual-account/v2/payment-code',
    BRI: '/bri-virtual-account/v2/payment-code',
    MANDIRI: '/mandiri-virtual-account/v2/payment-code',
    PERMATA: '/permata-virtual-account/v2/payment-code',
    CIMB: '/cimb-virtual-account/v2/payment-code',
    BSI: '/bsi-virtual-account/v2/payment-code',
  };

  const response = await dokuApi('POST', bankPaths[bankCode], {
    order: {
      invoice_number: order.orderNumber,
      amount: order.totalAmount,
    },
    virtual_account_info: {
      expired_time: 60,       // minutes
      reusable_status: false,  // Single-use
      info1: `Order ${order.orderNumber}`,
    },
    customer: {
      name: order.customerName,
      email: order.customerEmail,
    },
  });

  return {
    vaNumber: response.virtual_account_info.virtual_account_number,
    bankCode,
    amount: order.totalAmount,
    expiredAt: response.virtual_account_info.expired_date,
    howToPay: response.virtual_account_info.how_to_pay_api,
  };
}
```

---

## Direct API — E-Wallet

```typescript
// ── Create E-Wallet Payment ──
async function createEwalletPayment(order: Order, walletType: string) {
  const walletPaths: Record<string, string> = {
    OVO: '/ovo-emoney/v1/payment',
    DANA: '/dana-emoney/v1/payment',
    SHOPEE_PAY: '/shopee-pay-emoney/v1/payment',
    LINK_AJA: '/linkaja-emoney/v1/payment',
  };

  const payload: any = {
    order: {
      invoice_number: order.orderNumber,
      amount: order.totalAmount,
    },
    customer: {
      name: order.customerName,
      email: order.customerEmail,
    },
  };

  // OVO requires phone number
  if (walletType === 'OVO') {
    payload.ovo_info = {
      ovo_id: order.customerPhone,  // OVO registered phone
    };
  } else {
    payload.additional_info = {
      success_payment_url: `${process.env.FRONTEND_URL}/orders/${order.id}/success`,
      failed_payment_url: `${process.env.FRONTEND_URL}/orders/${order.id}/failed`,
    };
  }

  const response = await dokuApi('POST', walletPaths[walletType], payload);

  return {
    paymentUrl: response.response?.payment?.url,     // For DANA/ShopeePay/LinkAja
    status: response.response?.order?.status || 'PENDING',
  };
}
```

---

## Direct API — QRIS

```typescript
// ── Create QRIS Payment ──
async function createQrisPayment(order: Order) {
  const response = await dokuApi('POST', '/qris/v1/payment-code', {
    order: {
      invoice_number: order.orderNumber,
      amount: order.totalAmount,
    },
    customer: {
      name: order.customerName,
      email: order.customerEmail,
    },
    qris_info: {
      expired_time: 30,  // minutes
    },
  });

  return {
    qrContent: response.qris_info.qris_content,  // QR string for rendering
    qrUrl: response.qris_info.qris_url,           // QR image URL
    expiredAt: response.qris_info.expired_date,
  };
}
```

---

## Webhooks (Notification)

```typescript
// src/webhooks/doku.ts

// ── Verify DOKU notification signature ──
function verifyDokuSignature(req: Request): boolean {
  const clientId = req.headers['client-id'] as string;
  const requestId = req.headers['request-id'] as string;
  const timestamp = req.headers['request-timestamp'] as string;
  const signature = req.headers['signature'] as string;
  const requestTarget = req.path;
  const body = JSON.stringify(req.body);

  const expectedSignature = generateSignature(
    DOKU_CLIENT_ID,
    requestId,
    timestamp,
    requestTarget,
    body,
    DOKU_SECRET_KEY,
  );

  return signature === expectedSignature;
}

// ── Notification handler ──
// POST /webhooks/doku
app.post('/webhooks/doku', async (req, res) => {
  // Verify signature
  if (!verifyDokuSignature(req)) {
    console.error('Invalid DOKU webhook signature');
    return res.status(403).json({ error: 'Invalid signature' });
  }

  const { order, transaction, channel } = req.body;
  const invoiceNumber = order?.invoice_number;
  const transactionStatus = transaction?.status;
  const amount = transaction?.amount;

  console.log(`DOKU notification: ${invoiceNumber} → ${transactionStatus} (${channel?.id})`);

  switch (transactionStatus) {
    case 'SUCCESS':
      await db.order.update({
        where: { orderNumber: invoiceNumber },
        data: {
          paymentStatus: 'PAID',
          paidAmount: parseInt(amount),
          paymentChannel: channel?.id,
          paidAt: new Date(),
        },
      });
      await sendPaymentConfirmation(invoiceNumber);
      break;

    case 'FAILED':
      await db.order.update({
        where: { orderNumber: invoiceNumber },
        data: { paymentStatus: 'FAILED' },
      });
      break;

    case 'EXPIRED':
      await db.order.update({
        where: { orderNumber: invoiceNumber },
        data: { paymentStatus: 'EXPIRED' },
      });
      await restoreStock(invoiceNumber);
      break;
  }

  // DOKU expects 200 OK response
  res.status(200).json({ message: 'Notification received' });
});
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Signature verification** | Always verify HMAC-SHA256 signature on webhooks |
| **Checkout API** | Use Checkout for multi-channel (simplest integration) |
| **Direct API** | Use Direct for custom UI and specific payment flows |
| **Idempotency** | Unique `invoice_number` per order, handle duplicate callbacks |
| **Expiration** | Set reasonable expiry (60min VA, 30min QRIS, 15min OVO) |
| **Sandbox testing** | Use `api-sandbox.doku.com` for development |
| **Error handling** | Handle timeout, insufficient balance, channel unavailable |
| **Logging** | Log all API calls and webhook notifications |
| **SNAP compliance** | Follow SNAP BI standard for signature format |
| **Retry** | DOKU retries notifications up to 5 times on failure |

---

## Rules Integration
- **Checkout**: Hosted payment page supporting all channels
- **Direct**: VA (BCA/BNI/BRI/Mandiri), E-wallet (OVO/DANA/ShopeePay), QRIS, Cards
- **Signature**: HMAC-SHA256 with Client-Id, Request-Id, timestamp, digest
- **Webhooks**: Signature verification, idempotent processing, status updates
- **SNAP BI**: Compliance with Bank Indonesia API standard
