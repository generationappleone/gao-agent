---
name: DOKU Payment Gateway
description: Skill for DOKU — Indonesia's pioneer payment gateway covering Checkout API, Direct API, virtual accounts, e-wallets, QRIS, credit cards, convenience stores, SNAP BI compliance, and webhook notification handling.
---

# DOKU — Payment Gateway Indonesia

## Overview
DOKU (founded 2007) is Indonesia's pioneer payment gateway, licensed by Bank Indonesia as a Payment System Service Provider (PJSP) and PCI DSS Level 1 certified. It supports credit/debit cards, bank transfers (VA), e-wallets, QRIS, and convenience store payments.

## Architecture
```
┌──────────────────────────────────────────────┐
│              Your Application                │
├──────────────┬───────────────────────────────┤
│   Frontend   │         Backend               │
│(DOKU Checkout│  (DOKU API + Signature)        │
│  or Custom)  │                               │
├──────────────┴───────────────────────────────┤
│              DOKU API Layer                  │
├──────────┬──────────┬─────────┬─────────────┤
│ Checkout │ Direct   │e-Invoice│ SNAP BI     │
│   API    │   API    │   API   │ Compliance  │
├──────────┴──────────┴─────────┴─────────────┤
│         Payment Channels                     │
│ Cards│ VA │ OVO│ DANA│ QRIS│ Alfamart│ etc  │
└──────────────────────────────────────────────┘
```

## Authentication & Signature

### Generate Request Signature
```javascript
const crypto = require('crypto');

function generateSignature(clientId, requestId, requestTimestamp, requestTarget, body, secretKey) {
    // Component signature
    const digest = crypto.createHash('sha256')
        .update(JSON.stringify(body))
        .digest('base64');

    const componentSignature = `Client-Id:${clientId}\n` +
        `Request-Id:${requestId}\n` +
        `Request-Timestamp:${requestTimestamp}\n` +
        `Request-Target:${requestTarget}\n` +
        `Digest:${digest}`;

    const signature = crypto.createHmac('sha256', secretKey)
        .update(componentSignature)
        .digest('base64');

    return `HMACSHA256=${signature}`;
}

// Usage
const clientId = 'YOUR_CLIENT_ID';
const secretKey = 'YOUR_SECRET_KEY';
const requestId = crypto.randomUUID();
const timestamp = new Date().toISOString();
```

### Request Headers
```javascript
const headers = {
    'Client-Id': clientId,
    'Request-Id': requestId,
    'Request-Timestamp': timestamp,
    'Signature': generateSignature(clientId, requestId, timestamp, '/checkout/v1/payment', body, secretKey),
    'Content-Type': 'application/json'
};
```

## Integration Methods

### 1. Checkout API (Built-in Payment Page)

```javascript
// Backend: Generate payment URL
const body = {
    order: {
        amount: 150000,
        invoice_number: `INV-${Date.now()}`,
        currency: 'IDR',
        callback_url: 'https://yoursite.com/api/doku/callback',
        line_items: [
            { name: 'Premium Plan', price: 100000, quantity: 1 },
            { name: 'Setup Fee', price: 50000, quantity: 1 }
        ]
    },
    payment: {
        payment_due_date: 60  // minutes
    },
    customer: {
        id: 'CUST-001',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '081234567890',
        country: 'ID'
    }
};

const response = await fetch('https://api-sandbox.doku.com/checkout/v1/payment', {
    method: 'POST',
    headers: headers,
    body: JSON.stringify(body)
});

const result = await response.json();
// Redirect customer to result.response.payment.url
```

### 2. Direct API (Custom Payment Page)

#### Virtual Account
```javascript
const vaBody = {
    order: {
        amount: 500000,
        invoice_number: `VA-${Date.now()}`
    },
    virtual_account_info: {
        billing_type: 'FIX_BILL',
        expired_time: 60,  // minutes
        reusable_status: false,
        info1: 'Pembayaran Order',
        info2: 'Premium Subscription'
    },
    customer: {
        name: 'John Doe',
        email: 'john@example.com'
    }
};

// BCA VA
const bcaVA = await fetch('https://api-sandbox.doku.com/bca-virtual-account/v2/payment-code', {
    method: 'POST', headers, body: JSON.stringify(vaBody)
});

// BNI VA
const bniVA = await fetch('https://api-sandbox.doku.com/bni-virtual-account/v2/payment-code', {
    method: 'POST', headers, body: JSON.stringify(vaBody)
});

// BRI VA
const briVA = await fetch('https://api-sandbox.doku.com/bri-virtual-account/v2/payment-code', {
    method: 'POST', headers, body: JSON.stringify(vaBody)
});

// Mandiri VA
const mandiriVA = await fetch('https://api-sandbox.doku.com/mandiri-virtual-account/v2/payment-code', {
    method: 'POST', headers, body: JSON.stringify(vaBody)
});
```

#### E-Wallet
```javascript
// OVO
const ovoBody = {
    order: { amount: 75000, invoice_number: `OVO-${Date.now()}` },
    ovo_info: { ovo_id: '081234567890' },
    customer: { name: 'John Doe', email: 'john@example.com' }
};
const ovo = await fetch('https://api-sandbox.doku.com/ovo-emoney/v1/payment', {
    method: 'POST', headers, body: JSON.stringify(ovoBody)
});

// DANA
const danaBody = {
    order: { amount: 75000, invoice_number: `DANA-${Date.now()}` },
    dana_info: { callback_url: 'https://yoursite.com/callback', redirect_url: 'https://yoursite.com/redirect' },
    customer: { name: 'John Doe', email: 'john@example.com' }
};
const dana = await fetch('https://api-sandbox.doku.com/dana-emoney/v1/payment', {
    method: 'POST', headers, body: JSON.stringify(danaBody)
});

// ShopeePay
const shopee = await fetch('https://api-sandbox.doku.com/shopeepay-emoney/v1/payment', {
    method: 'POST', headers, body: JSON.stringify({
        order: { amount: 50000, invoice_number: `SPAY-${Date.now()}` },
        shopeepay_info: { redirect_url: 'https://yoursite.com/redirect' },
        customer: { name: 'John Doe', email: 'john@example.com' }
    })
});
```

#### Credit Card
```javascript
const ccBody = {
    order: { amount: 250000, invoice_number: `CC-${Date.now()}` },
    credit_card_info: {
        payment_type: 'SALE',
        support_3d_secure: true,  // Enable 3DS
        callback_url: 'https://yoursite.com/api/doku/cc-callback'
    },
    customer: { name: 'John Doe', email: 'john@example.com' }
};
const cc = await fetch('https://api-sandbox.doku.com/credit-card/v1/payment', {
    method: 'POST', headers, body: JSON.stringify(ccBody)
});
```

#### QRIS
```javascript
const qris = await fetch('https://api-sandbox.doku.com/qris/v1/payment', {
    method: 'POST', headers,
    body: JSON.stringify({
        order: { amount: 100000, invoice_number: `QRIS-${Date.now()}` },
        customer: { name: 'John Doe', email: 'john@example.com' }
    })
});
// Response: qris_url (QR code image)
```

## Webhook Notification Handler

### Node.js / Express
```javascript
app.post('/api/doku/notification', (req, res) => {
    const notification = req.body;

    // Verify signature from DOKU
    const receivedSignature = req.headers['signature'];
    const expectedSignature = generateNotificationSignature(
        req.headers['client-id'],
        req.headers['request-id'],
        req.headers['request-timestamp'],
        '/api/doku/notification',
        notification,
        process.env.DOKU_SECRET_KEY
    );

    if (receivedSignature !== expectedSignature) {
        return res.status(403).json({ error: 'Invalid signature' });
    }

    const { service, acquirer, order, transaction } = notification;
    const invoiceNumber = order.invoice_number;
    const transactionStatus = transaction.status;

    switch (transactionStatus) {
        case 'SUCCESS':
            updateOrderStatus(invoiceNumber, 'paid');
            break;
        case 'FAILED':
            updateOrderStatus(invoiceNumber, 'failed');
            break;
        case 'VOIDED':
            updateOrderStatus(invoiceNumber, 'voided');
            break;
    }

    res.status(200).json({ status: 'ok' });
});
```

### Laravel / PHP
```php
Route::post('/doku/notification', function (Request $request) {
    // Verify DOKU signature
    $signature = $request->header('Signature');
    $expectedSignature = generateDokuSignature(
        $request->header('Client-Id'),
        $request->header('Request-Id'),
        $request->header('Request-Timestamp'),
        '/doku/notification',
        $request->getContent(),
        config('doku.secret_key')
    );

    if ($signature !== $expectedSignature) {
        return response()->json(['error' => 'Unauthorized'], 403);
    }

    $data = $request->all();
    $invoiceNumber = $data['order']['invoice_number'];
    $status = $data['transaction']['status'];

    if ($status === 'SUCCESS') {
        Order::where('invoice_number', $invoiceNumber)
            ->update(['status' => 'paid', 'paid_at' => now()]);
    }

    return response()->json(['status' => 'ok']);
});
```

## SNAP BI Compliance
DOKU supports Bank Indonesia's SNAP (Standar Nasional Open API Pembayaran) standard:

```javascript
// SNAP SDK simplifies BI-compliant integration
const DokuSnap = require('doku-nodejs-library');

const snap = new DokuSnap({
    isProduction: false,
    clientId: 'YOUR_CLIENT_ID',
    secretKey: 'YOUR_SECRET_KEY',
    privateKey: 'YOUR_PRIVATE_KEY'  // RSA private key for SNAP
});

// Generate B2B access token (SNAP standard)
const token = await snap.generateB2BAccessToken();

// Create VA with SNAP standard
const vaResult = await snap.createVirtualAccount({
    partnerServiceId: '   12345',
    customerNo: '67890',
    virtualAccountNo: '   1234567890',
    totalAmount: { value: '500000.00', currency: 'IDR' },
    virtualAccountName: 'John Doe'
});
```

## Payment Channels
| Channel | Type | API Endpoint |
|---------|------|-------------|
| BCA VA | Virtual Account | `/bca-virtual-account/v2/payment-code` |
| BNI VA | Virtual Account | `/bni-virtual-account/v2/payment-code` |
| BRI VA | Virtual Account | `/bri-virtual-account/v2/payment-code` |
| Mandiri VA | Virtual Account | `/mandiri-virtual-account/v2/payment-code` |
| OVO | E-Wallet | `/ovo-emoney/v1/payment` |
| DANA | E-Wallet | `/dana-emoney/v1/payment` |
| ShopeePay | E-Wallet | `/shopeepay-emoney/v1/payment` |
| LinkAja | E-Wallet | `/linkaja-emoney/v1/payment` |
| Credit Card | Card | `/credit-card/v1/payment` |
| QRIS | QR Payment | `/qris/v1/payment` |
| Alfamart | Store | `/alfamart/v1/payment-code` |

## SDKs
| Language | Package |
|----------|---------|
| Node.js | `npm install doku-nodejs-library` |
| PHP | `composer require doku/doku-php-library` |
| Python | `pip install doku-python-library` |
| Java | Maven: `com.doku:doku-java-library` |
| Ruby | `gem install doku-ruby-library` |

## Configuration
```env
DOKU_CLIENT_ID=YOUR_CLIENT_ID
DOKU_SECRET_KEY=YOUR_SECRET_KEY
DOKU_IS_PRODUCTION=false
# Sandbox: https://api-sandbox.doku.com
# Production: https://api.doku.com
```

## Best Practices
- Always **verify notification signatures** (HMAC-SHA256)
- Enable **3D Secure** for all credit card transactions
- Use **SNAP BI SDK** for Bank Indonesia compliance
- Implement **idempotent** order processing for duplicate notifications
- Test with **Sandbox** environment before going production
- Store **invoice_number** as your primary order reference
- Set appropriate **payment_due_date** for VA and checkout flows
