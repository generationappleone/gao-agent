---
name: Xendit Payment Gateway
description: Skill for Xendit — Southeast Asian payment gateway covering invoices, e-wallets (OVO, DANA, ShopeePay, LinkAja), virtual accounts, QRIS, direct debit, disbursements/payouts, webhook callbacks, and multi-language SDK integration.
---

# Xendit — Payment Gateway Indonesia & SEA

## Overview
Xendit is a leading Southeast Asian payment gateway (Indonesia, Philippines) providing APIs for accepting payments (e-wallets, VA, cards, QRIS), sending payouts/disbursements, and managing invoices.

## Authentication
```
Authorization: Basic base64(SECRET_KEY + ":")
# Use xnd_development_ keys for Sandbox, xnd_production_ for live
```

## 1. Invoice API (Easiest Integration)

```javascript
const Xendit = require('xendit-node');
const x = new Xendit({ secretKey: 'xnd_development_YOUR_SECRET_KEY' });
const { Invoice } = x;
const invoiceClient = new Invoice({});

const invoice = await invoiceClient.createInvoice({
    externalID: `INV-${Date.now()}`,
    amount: 250000,
    description: 'Premium Subscription',
    payerEmail: 'customer@example.com',
    customer: {
        given_names: 'John', surname: 'Doe',
        email: 'customer@example.com', mobile_number: '+6281234567890'
    },
    successRedirectURL: 'https://yoursite.com/payment/success',
    failureRedirectURL: 'https://yoursite.com/payment/failed',
    currency: 'IDR',
    items: [{ name: 'Premium Plan', quantity: 1, price: 250000 }],
    paymentMethods: [
        'BCA', 'BNI', 'BRI', 'MANDIRI', 'OVO', 'DANA',
        'SHOPEEPAY', 'QRIS', 'CREDIT_CARD', 'ALFAMART'
    ],
    invoiceDuration: 86400
});
console.log('Invoice URL:', invoice.invoice_url);
```

## 2. E-Wallet API
```javascript
const charge = await fetch('https://api.xendit.co/ewallets/charges', {
    method: 'POST',
    headers: {
        'Authorization': 'Basic ' + btoa('SECRET_KEY:'),
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        reference_id: `EWALLET-${Date.now()}`,
        currency: 'IDR', amount: 75000,
        checkout_method: 'ONE_TIME_PAYMENT',
        channel_code: 'ID_OVO',  // ID_DANA, ID_SHOPEEPAY, ID_LINKAJA, ID_GOPAY
        channel_properties: { mobile_number: '+6281234567890' }
    })
});
```

## 3. Virtual Account API
```javascript
const va = await fetch('https://api.xendit.co/callback_virtual_accounts', {
    method: 'POST',
    headers: { 'Authorization': 'Basic ' + btoa('SECRET_KEY:'), 'Content-Type': 'application/json' },
    body: JSON.stringify({
        external_id: `VA-${Date.now()}`,
        bank_code: 'BCA',  // BCA, BNI, BRI, MANDIRI, PERMATA, CIMB, BSI
        name: 'John Doe', expected_amount: 500000,
        is_closed: true, is_single_use: true,
        expiration_date: new Date(Date.now() + 86400000).toISOString()
    })
});
```

## 4. QRIS API
```javascript
const qris = await fetch('https://api.xendit.co/qr_codes', {
    method: 'POST',
    headers: { 'Authorization': 'Basic ' + btoa('SECRET_KEY:'), 'Content-Type': 'application/json', 'api-version': '2022-07-31' },
    body: JSON.stringify({
        reference_id: `QRIS-${Date.now()}`, type: 'DYNAMIC',
        currency: 'IDR', amount: 100000
    })
});
```

## 5. Disbursement / Payout API
```javascript
// Single payout
const payout = await fetch('https://api.xendit.co/disbursements', {
    method: 'POST',
    headers: { 'Authorization': 'Basic ' + btoa('SECRET_KEY:'), 'Content-Type': 'application/json', 'X-IDEMPOTENCY-KEY': `DISB-${Date.now()}` },
    body: JSON.stringify({
        external_id: `PAYOUT-${Date.now()}`, amount: 1000000,
        bank_code: 'BCA', account_holder_name: 'John Doe',
        account_number: '1234567890', description: 'Salary payment'
    })
});

// Batch disbursement
const batch = await fetch('https://api.xendit.co/batch_disbursements', {
    method: 'POST',
    headers: { 'Authorization': 'Basic ' + btoa('SECRET_KEY:'), 'Content-Type': 'application/json' },
    body: JSON.stringify({
        reference: `BATCH-${Date.now()}`,
        disbursements: [
            { amount: 500000, bank_code: 'BCA', bank_account_name: 'Employee A', bank_account_number: '111', description: 'Gaji' },
            { amount: 750000, bank_code: 'BNI', bank_account_name: 'Employee B', bank_account_number: '222', description: 'Gaji' }
        ]
    })
});
```

## Webhook Handler

### Node.js / Express
```javascript
app.post('/api/xendit/webhook', (req, res) => {
    const callbackToken = req.headers['x-callback-token'];
    if (callbackToken !== process.env.XENDIT_CALLBACK_TOKEN) {
        return res.status(403).json({ error: 'Invalid callback token' });
    }

    const event = req.body;
    switch (event.status) {
        case 'PAID': case 'SETTLED': handlePaid(event); break;
        case 'EXPIRED': handleExpired(event); break;
        case 'SUCCEEDED': handleEwalletSuccess(event); break;
        case 'COMPLETED': handleDisbursementDone(event); break;
    }
    res.status(200).json({ status: 'ok' });
});
```

### Laravel / PHP
```php
Route::post('/xendit/webhook', function (Request $request) {
    if ($request->header('x-callback-token') !== config('xendit.callback_token')) {
        return response()->json(['error' => 'Unauthorized'], 403);
    }
    $event = $request->all();
    if ($event['status'] === 'PAID') {
        Order::where('external_id', $event['external_id'])
            ->update(['status' => 'paid', 'paid_at' => now()]);
    }
    return response()->json(['status' => 'ok']);
});
```

## SDKs & Libraries
| Language | Package |
|----------|---------|
| Node.js | `npm install xendit-node` |
| PHP | `composer require xendit/xendit-php` |
| Python | `pip install xendit-python` |
| Go | `github.com/xendit/xendit-go` |
| Java | Maven: `com.xendit:xendit-java` |

## Configuration
```env
XENDIT_SECRET_KEY=xnd_development_YOUR_SECRET_KEY
XENDIT_PUBLIC_KEY=xnd_public_development_YOUR_PUBLIC_KEY
XENDIT_CALLBACK_TOKEN=YOUR_CALLBACK_VERIFICATION_TOKEN
```

## Best Practices
- **Store Secret Key** server-side only — never expose on frontend
- Always **verify x-callback-token** header in webhooks
- Use **X-IDEMPOTENCY-KEY** for disbursements to prevent duplicates
- Use **Invoice API** for fastest integration (pre-built payment page)
- Handle **all webhook statuses** — don't rely on redirect URLs alone
- Test with `xnd_development_` keys before switching to production
