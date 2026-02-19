---
name: Invoicing System
description: Skill for building invoicing systems — covering invoice generation, payment tracking, recurring billing, multi-currency support, tax calculation, payment reminders, aging reports, and accounting integration.
---

# Invoicing System — Development Guide

## Architecture

```
┌──────────────────────────────────────────────┐
│            Invoice Dashboard                  │
│  Create · Send · Track · Reports              │
└──────────────────┬───────────────────────────┘
                   │
┌──────────────────┴───────────────────────────┐
│              Invoice Backend                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────────┐  │
│  │ Invoice  │ │ Payment  │ │ Customer     │  │
│  │ Service  │ │ Service  │ │ Service      │  │
│  └──────────┘ └──────────┘ └──────────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────────┐  │
│  │ Tax      │ │ Reminder │ │ Report       │  │
│  │ Engine   │ │ Service  │ │ Service      │  │
│  └──────────┘ └──────────┘ └──────────────┘  │
└──────────────────────────────────────────────┘
    │           │            │
    ▼           ▼            ▼
 Accounting   Payment     Email/SMS
              Gateway     Service
```

---

## Database Schema

```sql
-- Invoice numbering sequences
CREATE TABLE invoice_sequences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prefix VARCHAR(20) NOT NULL DEFAULT 'INV',
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    last_number INTEGER NOT NULL DEFAULT 0,
    format VARCHAR(100) DEFAULT '{prefix}-{year}{month:02d}-{number:04d}',
    UNIQUE(prefix, year, month)
);

-- Invoices
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id UUID NOT NULL REFERENCES customers(id),
    -- Billing details (snapshot at invoice time)
    bill_to_name VARCHAR(255) NOT NULL,
    bill_to_address TEXT,
    bill_to_email VARCHAR(255),
    bill_to_phone VARCHAR(20),
    bill_to_tax_id VARCHAR(50),              -- NPWP

    invoice_type ENUM('standard', 'recurring', 'proforma', 'credit_note', 'debit_note') DEFAULT 'standard',
    status ENUM('draft', 'sent', 'viewed', 'partial', 'paid', 'overdue', 'cancelled', 'written_off') DEFAULT 'draft',

    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    payment_terms INTEGER DEFAULT 30,         -- NET 30

    currency VARCHAR(3) DEFAULT 'IDR',
    exchange_rate DECIMAL(15,6) DEFAULT 1,

    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    discount_type ENUM('percentage', 'fixed') DEFAULT 'fixed',
    discount_value DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    taxable_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    shipping_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    amount_paid DECIMAL(15,2) DEFAULT 0,
    balance_due DECIMAL(15,2) GENERATED ALWAYS AS (total_amount - amount_paid) STORED,

    notes TEXT,
    internal_notes TEXT,
    terms_and_conditions TEXT,
    footer_text TEXT,

    recurring_id UUID REFERENCES recurring_invoices(id),
    related_invoice_id UUID REFERENCES invoices(id),  -- for credit/debit notes

    sent_at TIMESTAMP NULL,
    viewed_at TIMESTAMP NULL,
    paid_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,

    journal_entry_id UUID,                    -- link to accounting
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Invoice line items
CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id),
    product_id UUID REFERENCES products(id),
    description VARCHAR(500) NOT NULL,
    quantity DECIMAL(15,4) NOT NULL DEFAULT 1,
    unit VARCHAR(50) DEFAULT 'unit',
    unit_price DECIMAL(15,4) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 11,         -- PPN 11%
    tax_amount DECIMAL(15,2) DEFAULT 0,
    subtotal DECIMAL(15,2) NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Invoice tax breakdown
CREATE TABLE invoice_taxes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id),
    tax_name VARCHAR(100) NOT NULL,           -- 'PPN 11%', 'PPh 23 2%'
    tax_rate DECIMAL(5,2) NOT NULL,
    taxable_amount DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments received
CREATE TABLE invoice_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id),
    payment_date DATE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method ENUM('bank_transfer', 'cash', 'credit_card', 'e_wallet', 'check', 'other') NOT NULL,
    reference_number VARCHAR(255),
    bank_name VARCHAR(100),
    notes TEXT,
    journal_entry_id UUID,
    recorded_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recurring invoices
CREATE TABLE recurring_invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id),
    template_data JSONB NOT NULL,             -- invoice items template
    frequency ENUM('weekly', 'biweekly', 'monthly', 'quarterly', 'semi_annual', 'annual') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    next_invoice_date DATE NOT NULL,
    payment_terms INTEGER DEFAULT 30,
    auto_send BOOLEAN DEFAULT FALSE,
    status ENUM('active', 'paused', 'completed', 'cancelled') DEFAULT 'active',
    invoices_generated INTEGER DEFAULT 0,
    last_generated_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment reminders
CREATE TABLE payment_reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id),
    reminder_type ENUM('before_due', 'on_due', 'after_due') NOT NULL,
    days_offset INTEGER NOT NULL,             -- -3 (3 days before), 0, 7, 14, 30
    channel ENUM('email', 'sms', 'whatsapp') DEFAULT 'email',
    sent_at TIMESTAMP NULL,
    status ENUM('scheduled', 'sent', 'failed') DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Invoice activity log
CREATE TABLE invoice_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id),
    activity_type ENUM('created', 'updated', 'sent', 'viewed', 'payment_received', 'reminder_sent', 'cancelled', 'written_off') NOT NULL,
    description TEXT,
    performed_by UUID REFERENCES users(id),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Features

### 1. Invoice Generation
- Professional PDF generation (header, logo, itemized, totals, footer)
- Multiple templates/themes
- Custom branding (logo, colors, fonts)
- Multi-currency support with exchange rates
- Tax calculation (PPN, PPh) with tax breakdown
- Automatic sequential numbering

### 2. Invoice Lifecycle
```
Draft → Sent → Viewed → Paid
                └→ Overdue → Reminder → Paid / Written Off
                └→ Partial Payment → Paid
```

### 3. Invoice Template (PDF)
```
╔══════════════════════════════════════════════╗
║  [COMPANY LOGO]                              ║
║  Company Name                    INVOICE      ║
║  Jl. Example No. 123           INV-202602-001║
╠══════════════════════════════════════════════╣
║  Bill To:                Invoice Date: 19/02  ║
║  Customer Name           Due Date: 21/03      ║
║  Customer Address        Payment: NET 30      ║
║  NPWP: 12.345.678.9-012                      ║
╠══════════════════════════════════════════════╣
║  # │ Description      │ Qty │ Price │ Amount ║
║  ──┼──────────────────┼─────┼───────┼────────║
║  1 │ Web Development  │  1  │ 15 jt │ 15 jt ║
║  2 │ UI/UX Design     │  1  │ 8 jt  │ 8 jt  ║
║  3 │ Server Setup     │  2  │ 2 jt  │ 4 jt  ║
╠══════════════════════════════════════════════╣
║                      Subtotal:    Rp 27.000.000║
║                      PPN 11%:     Rp  2.970.000║
║                      ─────────────────────────║
║                      TOTAL:       Rp 29.970.000║
║                      Amount Paid: Rp          0║
║                      BALANCE DUE: Rp 29.970.000║
╠══════════════════════════════════════════════╣
║  Payment Instructions:                        ║
║  Bank BCA 123-456-789 a.n. Company Name       ║
║                                               ║
║  Notes: Thank you for your business           ║
╚══════════════════════════════════════════════╝
```

### 4. Payment Tracking
- Record partial and full payments
- Multiple payment methods
- Auto-update invoice status on payment
- Payment receipt generation
- Payment history per invoice and per customer

### 5. Automated Reminders
```javascript
// Reminder schedule
const defaultReminders = [
  { type: 'before_due', days: -3, message: 'Invoice {number} is due in 3 days' },
  { type: 'on_due', days: 0, message: 'Invoice {number} is due today' },
  { type: 'after_due', days: 7, message: 'Invoice {number} is 7 days overdue' },
  { type: 'after_due', days: 14, message: 'Invoice {number} is 14 days overdue' },
  { type: 'after_due', days: 30, message: 'Final reminder: Invoice {number}' },
];
```

### 6. Aging Report
```
Aging Report as of 19 Feb 2026

Customer     Current  1-30 days  31-60 days  61-90 days  90+ days   Total
──────────── ──────── ────────── ────────── ────────── ────────── ──────────
Customer A   5.0M     2.0M       0          0          0          7.0M
Customer B   0        3.5M       1.0M       0          0          4.5M
Customer C   0        0          0          2.0M       0.5M       2.5M
──────────── ──────── ────────── ────────── ────────── ────────── ──────────
TOTAL        5.0M     5.5M       1.0M       2.0M       0.5M      14.0M
```

### 7. Recurring Invoices
- Schedule automatic invoice generation
- Configurable frequency (weekly to annually)
- Auto-send on generation (optional)
- End date or indefinite

---

## API Endpoints

```
# Invoices
POST   /api/v1/invoices                        — Create invoice
GET    /api/v1/invoices                        — List invoices
GET    /api/v1/invoices/:id                    — Invoice detail
PUT    /api/v1/invoices/:id                    — Update draft invoice
POST   /api/v1/invoices/:id/send               — Send to customer
POST   /api/v1/invoices/:id/duplicate          — Duplicate invoice
GET    /api/v1/invoices/:id/pdf                — Download PDF
POST   /api/v1/invoices/:id/cancel             — Cancel invoice
POST   /api/v1/invoices/:id/credit-note        — Create credit note

# Payments
POST   /api/v1/invoices/:id/payments           — Record payment
GET    /api/v1/invoices/:id/payments           — Payment history
DELETE /api/v1/invoices/:id/payments/:paymentId — Delete payment

# Recurring
POST   /api/v1/recurring-invoices              — Create recurring
GET    /api/v1/recurring-invoices              — List recurring
PATCH  /api/v1/recurring-invoices/:id/pause    — Pause
PATCH  /api/v1/recurring-invoices/:id/resume   — Resume

# Reports
GET    /api/v1/reports/aging                   — Aging report
GET    /api/v1/reports/revenue                 — Revenue summary
GET    /api/v1/reports/outstanding             — Outstanding invoices
GET    /api/v1/reports/tax-summary             — Tax summary

# Public (customer portal)
GET    /api/v1/portal/invoices/:token          — View invoice (public link)
POST   /api/v1/portal/invoices/:token/pay      — Pay online
```

---

## Accounting Integration

### Journal Entries on Invoice Send
```
DR  1120 Accounts Receivable    29,970,000
  CR  4100 Sales Revenue                    27,000,000
  CR  2131 PPN Output Payable               2,970,000
```

### Journal Entries on Payment
```
DR  1112 Bank BCA               29,970,000
  CR  1120 Accounts Receivable              29,970,000
```

---

## Best Practices

- **Invoice numbers**: Sequential, never reused, include year/month
- **Snapshots**: Store customer details and line items as snapshots (don't change if customer data updates)
- **Immutability**: Sent invoices cannot be edited — issue credit notes instead
- **Audit trail**: Log all actions (sent, viewed, paid, cancelled)
- **Tax compliance**: Accurate PPN/PPh calculation with proper tax IDs
- **Online payment**: Include payment links in email invoices
- **PDF archival**: Store generated PDFs for legal compliance
