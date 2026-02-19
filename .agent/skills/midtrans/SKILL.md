---
name: Midtrans Payment Gateway
description: Skill for Midtrans — Indonesian payment gateway integration covering Snap API, Core API, payment channels (credit card, bank transfer/VA, e-wallet, QRIS, convenience store), webhook notifications, refunds, and CMS plugins.
---

# Midtrans — Payment Gateway Indonesia

## Overview
Midtrans (by GoTo Financial / Gojek) is Indonesia's leading payment gateway providing a RESTful API for accepting payments via credit/debit cards, bank transfers (Virtual Account), e-wallets (GoPay, ShopeePay, DANA), QRIS, convenience stores, and more.

## Architecture
```
┌──────────────────────────────────────────────┐
│              Your Application                │
├──────────────┬───────────────────────────────┤
│   Frontend   │         Backend               │
│  (Snap.js /  │  (Server-side API calls)      │
│   Custom UI) │                               │
├──────────────┴───────────────────────────────┤
│            Midtrans API Layer                │
├──────────┬───────────┬─────────┬────────────┤
│ Snap API │ Core API  │ Iris API│ Webhook    │
│(Checkout)│(Direct)   │(Payout) │(Notif)     │
├──────────┴───────────┴─────────┴────────────┤
│         Payment Channels                     │
│ Cards │ VA │ GoPay │ QRIS │ Alfamart │ etc  │
└──────────────────────────────────────────────┘
```

## API Keys
```
Environment     | Base URL                              | Keys
----------------|---------------------------------------|------------------
Sandbox (Test)  | https://api.sandbox.midtrans.com      | Sandbox Server Key
Production      | https://api.midtrans.com              | Production Server Key
```

### Authentication
```
Authorization: Basic base64(SERVER_KEY + ":")

# Example: Server Key = "SB-Mid-server-abc123"
# Base64 encode "SB-Mid-server-abc123:" (note trailing colon)
Authorization: Basic U0ItTWlkLXNlcnZlci1hYmMxMjM6
```

## Integration Methods

### 1. Snap API (Recommended — Built-in Payment Page)

#### Backend: Create Transaction Token
```javascript
// Node.js with midtrans-client
const midtransClient = require('midtrans-client');

const snap = new midtransClient.Snap({
    isProduction: false,
    serverKey: 'SB-Mid-server-YOUR_SERVER_KEY',
    clientKey: 'SB-Mid-client-YOUR_CLIENT_KEY'
});

// Create transaction
const parameter = {
    transaction_details: {
        order_id: `ORDER-${Date.now()}`,
        gross_amount: 150000  // IDR 150.000
    },
    item_details: [
        {
            id: 'ITEM-001',
            price: 100000,
            quantity: 1,
            name: 'Premium Plan'
        },
        {
            id: 'ITEM-002',
            price: 50000,
            quantity: 1,
            name: 'Setup Fee'
        }
    ],
    customer_details: {
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com',
        phone: '+6281234567890',
        billing_address: {
            first_name: 'John',
            last_name: 'Doe',
            city: 'Jakarta',
            postal_code: '12345',
            country_code: 'IDN'
        }
    },
    enabled_payments: [
        'credit_card', 'bca_va', 'bni_va', 'bri_va', 'permata_va',
        'gopay', 'shopeepay', 'qris', 'alfamart', 'indomaret'
    ],
    credit_card: {
        secure: true,  // 3DS enabled
        save_card: true
    },
    callbacks: {
        finish: 'https://yoursite.com/payment/finish'
    }
};

const transaction = await snap.createTransaction(parameter);
console.log('Token:', transaction.token);
console.log('Redirect URL:', transaction.redirect_url);
```

#### Frontend: Display Snap Payment Page
```html
<!-- Load Snap.js -->
<script src="https://app.sandbox.midtrans.com/snap/snap.js"
        data-client-key="SB-Mid-client-YOUR_CLIENT_KEY"></script>

<button id="pay-button">Bayar Sekarang</button>

<script>
document.getElementById('pay-button').addEventListener('click', async () => {
    // Get token from your backend
    const response = await fetch('/api/payment/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ orderId: 'ORDER-123', amount: 150000 })
    });
    const { token } = await response.json();

    // Open Snap payment popup
    window.snap.pay(token, {
        onSuccess: function(result) {
            console.log('Payment success:', result);
            window.location.href = '/payment/success?order_id=' + result.order_id;
        },
        onPending: function(result) {
            console.log('Payment pending:', result);
            window.location.href = '/payment/pending?order_id=' + result.order_id;
        },
        onError: function(result) {
            console.log('Payment error:', result);
            alert('Pembayaran gagal. Silakan coba lagi.');
        },
        onClose: function() {
            console.log('Payment popup closed');
        }
    });
});
</script>
```

### 2. Core API (Custom Payment Page)

#### Credit Card Payment
```javascript
const core = new midtransClient.CoreApi({
    isProduction: false,
    serverKey: 'SB-Mid-server-YOUR_SERVER_KEY',
    clientKey: 'SB-Mid-client-YOUR_CLIENT_KEY'
});

// Step 1: Tokenize card (frontend via MidtransNew3ds)
// Step 2: Charge with token
const chargeResponse = await core.charge({
    payment_type: 'credit_card',
    transaction_details: {
        order_id: `ORDER-${Date.now()}`,
        gross_amount: 250000
    },
    credit_card: {
        token_id: 'CARD_TOKEN_FROM_FRONTEND',
        authentication: true  // 3DS
    }
});
```

#### Bank Transfer (Virtual Account)
```javascript
// BCA Virtual Account
const bcaVA = await core.charge({
    payment_type: 'bank_transfer',
    transaction_details: {
        order_id: `VA-${Date.now()}`,
        gross_amount: 500000
    },
    bank_transfer: {
        bank: 'bca',
        va_number: '12345678901'  // optional custom VA number
    }
});
// Response: { va_numbers: [{ bank: "bca", va_number: "12345678901" }] }

// BNI Virtual Account
const bniVA = await core.charge({
    payment_type: 'bank_transfer',
    transaction_details: { order_id: `VA-${Date.now()}`, gross_amount: 300000 },
    bank_transfer: { bank: 'bni' }
});

// BRI Virtual Account
const briVA = await core.charge({
    payment_type: 'bank_transfer',
    transaction_details: { order_id: `VA-${Date.now()}`, gross_amount: 300000 },
    bank_transfer: { bank: 'bri' }
});

// Mandiri Bill Payment
const mandiri = await core.charge({
    payment_type: 'echannel',
    transaction_details: { order_id: `BILL-${Date.now()}`, gross_amount: 300000 },
    echannel: { bill_info1: 'Payment', bill_info2: 'Online Purchase' }
});

// Permata Virtual Account
const permata = await core.charge({
    payment_type: 'permata',
    transaction_details: { order_id: `VA-${Date.now()}`, gross_amount: 300000 }
});
```

#### E-Wallet (GoPay, ShopeePay)
```javascript
// GoPay
const gopayCharge = await core.charge({
    payment_type: 'gopay',
    transaction_details: {
        order_id: `GOPAY-${Date.now()}`,
        gross_amount: 100000
    },
    gopay: {
        enable_callback: true,
        callback_url: 'https://yoursite.com/callback'
    }
});
// Response contains: actions[].url for QR code / deep link

// ShopeePay
const shopeepay = await core.charge({
    payment_type: 'shopeepay',
    transaction_details: {
        order_id: `SPAY-${Date.now()}`,
        gross_amount: 75000
    },
    shopeepay: {
        callback_url: 'https://yoursite.com/callback'
    }
});
```

#### QRIS (Universal QR)
```javascript
const qris = await core.charge({
    payment_type: 'qris',
    transaction_details: {
        order_id: `QRIS-${Date.now()}`,
        gross_amount: 50000
    }
});
// Response: actions[0].url = QR code image URL
```

#### Convenience Store
```javascript
// Alfamart
const alfamart = await core.charge({
    payment_type: 'cstore',
    transaction_details: { order_id: `ALF-${Date.now()}`, gross_amount: 50000 },
    cstore: { store: 'alfamart', message: 'Pembayaran Order #123' }
});
// Response: payment_code for customer to show at Alfamart

// Indomaret
const indomaret = await core.charge({
    payment_type: 'cstore',
    transaction_details: { order_id: `INDO-${Date.now()}`, gross_amount: 50000 },
    cstore: { store: 'indomaret', message: 'Pembayaran Order #123' }
});
```

## Webhook Notification Handler

### Node.js / Express
```javascript
const crypto = require('crypto');

app.post('/api/midtrans/notification', async (req, res) => {
    const notification = req.body;

    // Verify signature
    const { order_id, status_code, gross_amount, signature_key } = notification;
    const serverKey = process.env.MIDTRANS_SERVER_KEY;
    const hash = crypto
        .createHash('sha512')
        .update(`${order_id}${status_code}${gross_amount}${serverKey}`)
        .digest('hex');

    if (hash !== signature_key) {
        return res.status(403).json({ error: 'Invalid signature' });
    }

    // Process based on transaction status
    const { transaction_status, fraud_status } = notification;

    switch (transaction_status) {
        case 'capture':
            if (fraud_status === 'accept') {
                await updateOrderStatus(order_id, 'PAID');
            } else if (fraud_status === 'challenge') {
                await updateOrderStatus(order_id, 'CHALLENGE');
            }
            break;

        case 'settlement':
            await updateOrderStatus(order_id, 'PAID');
            break;

        case 'pending':
            await updateOrderStatus(order_id, 'PENDING');
            break;

        case 'deny':
        case 'cancel':
        case 'expire':
            await updateOrderStatus(order_id, 'FAILED');
            break;

        case 'refund':
        case 'partial_refund':
            await updateOrderStatus(order_id, 'REFUNDED');
            break;
    }

    res.status(200).json({ status: 'ok' });
});
```

### Laravel / PHP
```php
use Midtrans\Config;
use Midtrans\Notification;

Config::$serverKey = env('MIDTRANS_SERVER_KEY');
Config::$isProduction = env('MIDTRANS_IS_PRODUCTION', false);

Route::post('/midtrans/notification', function (Request $request) {
    $notification = new Notification();

    $orderId = $notification->order_id;
    $transactionStatus = $notification->transaction_status;
    $fraudStatus = $notification->fraud_status;

    $order = Order::where('order_id', $orderId)->firstOrFail();

    if ($transactionStatus == 'settlement' ||
        ($transactionStatus == 'capture' && $fraudStatus == 'accept')) {
        $order->update(['status' => 'paid', 'paid_at' => now()]);
    } elseif (in_array($transactionStatus, ['deny', 'cancel', 'expire'])) {
        $order->update(['status' => 'failed']);
    }

    return response()->json(['status' => 'ok']);
});
```

## Transaction Status Check
```javascript
// Check transaction status
const status = await snap.transaction.status('ORDER-123');
console.log(`Status: ${status.transaction_status}`);

// Cancel transaction
await snap.transaction.cancel('ORDER-123');

// Refund (for credit card / GoPay)
const refund = await core.transaction.refund('ORDER-123', {
    refund_key: `REFUND-${Date.now()}`,
    amount: 50000,  // Partial refund
    reason: 'Customer request'
});
```

## Payment Channels Summary
| Payment Type | `payment_type` | Popular Banks/Providers |
|-------------|----------------|-------------------------|
| Credit/Debit Card | `credit_card` | Visa, Mastercard, JCB, AMEX |
| Bank Transfer (VA) | `bank_transfer` | BCA, BNI, BRI, CIMB, Mandiri |
| E-Wallet | `gopay`, `shopeepay` | GoPay, ShopeePay |
| QRIS | `qris` | All QRIS-enabled e-wallets |
| Convenience Store | `cstore` | Alfamart, Indomaret |
| Cardless Credit | `akulaku` | Akulaku |

## SDKs & Libraries
| Language | Package |
|----------|---------|
| Node.js | `npm install midtrans-client` |
| PHP | `composer require midtrans/midtrans-php` |
| Python | `pip install midtransclient` |
| Go | `github.com/midtrans/midtrans-go` |
| Ruby | `gem install midtrans` |
| Java | Maven: `com.midtrans:java-library` |

## CMS Plugins
- **WordPress WooCommerce**: Official plugin available
- **Magento 2**: Official extension
- **PrestaShop**: Official module
- **OpenCart**: Community plugin

## Configuration
```env
# .env
MIDTRANS_SERVER_KEY=SB-Mid-server-YOUR_SERVER_KEY
MIDTRANS_CLIENT_KEY=SB-Mid-client-YOUR_CLIENT_KEY
MIDTRANS_IS_PRODUCTION=false
MIDTRANS_MERCHANT_ID=YOUR_MERCHANT_ID

# Webhook URL (set in Midtrans Dashboard > Settings > Configuration)
# https://yoursite.com/api/midtrans/notification
```

## Best Practices

### Security
- **Never expose Server Key** on frontend — use Client Key only
- Always **verify webhook signature** (SHA512) before processing
- Enable **3D Secure** for credit card transactions
- Use **HTTPS** for all API communications and webhook endpoints
- Implement **idempotency** — handle duplicate notifications gracefully

### Implementation
- Start with **Sandbox** environment for development and testing
- Use **Snap API** for faster integration (pre-built UI)
- Use **Core API** only when you need fully custom payment UI
- Always handle **all transaction statuses** in webhook handler
- Implement **retry logic** for API calls with exponential backoff
- Store **transaction_id** and **order_id** for reconciliation

### Testing
- Use Midtrans **test card numbers**: `4811 1111 1111 1114` (3DS)
- Use **Sandbox VA numbers** for testing bank transfers
- Test **all payment channels** before going production
- Verify **webhook delivery** using Midtrans Dashboard log
