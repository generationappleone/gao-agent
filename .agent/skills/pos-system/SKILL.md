---
name: Point of Sale (POS)
description: Skill for building Point of Sale systems — covering sales transactions, payment processing, inventory sync, receipt printing, cash drawer management, multi-terminal, offline mode, and retail/F&B operations.
---

# Point of Sale (POS) — Development Guide

## Architecture

### Cloud-Hybrid Architecture (Recommended)
```
┌────────────────────────────────┐
│      POS Terminal (Frontend)    │
│  Touchscreen · Offline-First    │
│  Local DB (IndexedDB/SQLite)    │
└──────────────┬─────────────────┘
               │ Sync (online)
┌──────────────┴─────────────────┐
│         POS Backend (Cloud)     │
│  ┌────────┐ ┌────────┐         │
│  │ Sales  │ │Payment │         │
│  │Service │ │Service │         │
│  └────────┘ └────────┘         │
│  ┌────────┐ ┌────────┐         │
│  │Inventory│ │Report │         │
│  │Service │ │Service │         │
│  └────────┘ └────────┘         │
└────────────────────────────────┘
       │          │          │
   Inventory   Accounting   CRM
```

### Offline-First Strategy
- **LocalDB**: IndexedDB (web) or SQLite (mobile) for offline transactions
- **Sync queue**: Store transactions locally, sync when online
- **Conflict resolution**: Server timestamp wins, merge strategies
- **Fallback**: Cash-only payments when offline

---

## Database Schema

```sql
-- POS terminals
CREATE TABLE pos_terminals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    terminal_code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    store_id UUID NOT NULL REFERENCES stores(id),
    device_type ENUM('desktop', 'tablet', 'mobile') DEFAULT 'desktop',
    is_active BOOLEAN DEFAULT TRUE,
    last_sync_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stores/outlets
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    address TEXT,
    phone VARCHAR(20),
    tax_id VARCHAR(50),
    timezone VARCHAR(50) DEFAULT 'Asia/Jakarta',
    currency VARCHAR(3) DEFAULT 'IDR',
    receipt_header TEXT,
    receipt_footer TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- POS sessions (shifts)
CREATE TABLE pos_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    terminal_id UUID NOT NULL REFERENCES pos_terminals(id),
    cashier_id UUID NOT NULL REFERENCES users(id),
    opening_balance DECIMAL(15,2) NOT NULL DEFAULT 0,
    closing_balance DECIMAL(15,2),
    expected_balance DECIMAL(15,2),
    cash_difference DECIMAL(15,2),
    total_sales DECIMAL(15,2) DEFAULT 0,
    total_refunds DECIMAL(15,2) DEFAULT 0,
    total_transactions INTEGER DEFAULT 0,
    status ENUM('open', 'closed') DEFAULT 'open',
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales transactions
CREATE TABLE pos_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_number VARCHAR(50) NOT NULL UNIQUE,
    session_id UUID NOT NULL REFERENCES pos_sessions(id),
    terminal_id UUID NOT NULL REFERENCES pos_terminals(id),
    cashier_id UUID NOT NULL REFERENCES users(id),
    customer_id UUID REFERENCES customers(id),
    transaction_type ENUM('sale', 'refund', 'exchange', 'void') DEFAULT 'sale',
    subtotal DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    discount_type ENUM('percentage', 'fixed') DEFAULT 'fixed',
    tax_amount DECIMAL(15,2) DEFAULT 0,
    service_charge DECIMAL(15,2) DEFAULT 0,
    rounding_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    payment_status ENUM('paid', 'partial', 'void') DEFAULT 'paid',
    notes TEXT,
    is_synced BOOLEAN DEFAULT FALSE,         -- for offline sync
    local_id VARCHAR(100),                    -- offline UUID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Transaction items
CREATE TABLE pos_transaction_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL REFERENCES pos_transactions(id),
    product_id UUID NOT NULL REFERENCES products(id),
    variant_id UUID REFERENCES product_variants(id),
    product_name VARCHAR(255) NOT NULL,       -- snapshot
    sku VARCHAR(100),
    quantity DECIMAL(15,4) NOT NULL,
    unit_price DECIMAL(15,4) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 11,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    subtotal DECIMAL(15,2) NOT NULL,
    cost_price DECIMAL(15,4),                 -- for COGS tracking
    notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments
CREATE TABLE pos_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL REFERENCES pos_transactions(id),
    payment_method ENUM('cash', 'debit_card', 'credit_card', 'e_wallet', 'qris', 'bank_transfer', 'store_credit', 'voucher') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    tendered DECIMAL(15,2),                   -- amount given (for cash)
    change_amount DECIMAL(15,2) DEFAULT 0,    -- change returned
    reference_number VARCHAR(255),            -- card auth code, e-wallet ref
    card_last_four VARCHAR(4),
    payment_provider VARCHAR(100),            -- 'BCA', 'GoPay', 'OVO'
    status ENUM('completed', 'pending', 'failed', 'refunded') DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cash drawer operations
CREATE TABLE cash_drawer_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES pos_sessions(id),
    operation_type ENUM('cash_in', 'cash_out', 'sale', 'refund') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    reason VARCHAR(500),
    performed_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Features

### 1. Sales Interface
- **Quick add**: Barcode scan, search, or touch product grid
- **Product grid**: Visual tiles with images for F&B / retail
- **Quantity adjustment**: +/- buttons, manual entry
- **Discount**: Per-item (% or fixed), per-transaction
- **Hold/recall**: Park transactions, serve later
- **Split payment**: Multiple payment methods per transaction
- **Customer lookup**: By phone, name, or loyalty card

### 2. Payment Methods
| Method | Integration |
|--------|-------------|
| Cash | Cash drawer open signal |
| Debit/Credit Card | Payment terminal (EDC) |
| QRIS | QR code display + payment confirmation |
| E-Wallet | GoPay, OVO, DANA, ShopeePay API |
| Bank Transfer | VA number generation |
| Store Credit | Internal balance system |
| Voucher | Code validation API |

### 3. Receipt
```
══════════════════════════════
        STORE NAME
     Jl. Example No. 123
     Phone: 021-1234567
══════════════════════════════
Date : 19/02/2026  14:30
Trans: TRX-20260219-001
Cashier: John Doe
──────────────────────────────
Item                     Price
──────────────────────────────
Coffee Latte x2      60,000
  Disc 10%           (6,000)
Sandwich x1          35,000
──────────────────────────────
Subtotal             89,000
Tax (11%)             9,790
──────────────────────────────
TOTAL                98,790
──────────────────────────────
Cash                100,000
Change                1,210
══════════════════════════════
     Thank you!
     Please come again
══════════════════════════════
```

### 4. F&B Specific Features
- Table management (dine-in, takeaway, delivery)
- Kitchen display system (KDS) integration
- Order modifiers (extra shot, no sugar, etc.)
- Course management (appetizer → main → dessert)
- Split bill by items or equal portions

### 5. Retail Specific Features
- Barcode scanning (1D/2D)
- Price check
- Weighted items (scale integration)
- Gift card management
- Loyalty points accumulation and redemption
- Layaway/installment

### 6. End-of-Day Reports
```
Z-Report (End of Day)
═══════════════════════════════
Date: 19/02/2026
Terminal: POS-01
Cashier: John Doe
Session: 08:00 - 17:00
───────────────────────────────
Gross Sales:       Rp 5,450,000
Discounts:         Rp   320,000
Net Sales:         Rp 5,130,000
Tax:               Rp   564,300
───────────────────────────────
Payment Breakdown:
  Cash:            Rp 2,800,000
  Debit Card:      Rp 1,200,000
  QRIS:            Rp   930,000
  E-Wallet:        Rp   764,300
───────────────────────────────
Transactions:              87
Avg Transaction:   Rp    62,644
Refunds:           Rp    45,000
───────────────────────────────
Opening Balance:   Rp   500,000
Cash Sales:        Rp 2,800,000
Cash Out:          Rp   100,000
Expected Cash:     Rp 3,200,000
Actual Cash:       Rp 3,195,000
Difference:        Rp    -5,000
═══════════════════════════════
```

---

## Hardware Integration

| Hardware | Protocol | Purpose |
|----------|----------|---------|
| Receipt printer | ESC/POS | Print receipts |
| Cash drawer | RJ-11 (via printer) | Auto-open on cash sale |
| Barcode scanner | USB HID | Product scanning |
| Card terminal (EDC) | Serial/USB | Card payments |
| Customer display | Serial | Show total to customer |
| Weight scale | Serial/USB | Weighted items |
| Label printer | ZPL | Price labels |

---

## API Endpoints

```
# Transactions
POST   /api/v1/pos/transactions              — Create transaction
POST   /api/v1/pos/transactions/:id/void      — Void transaction
POST   /api/v1/pos/transactions/:id/refund    — Refund

# Session
POST   /api/v1/pos/sessions/open              — Open session
POST   /api/v1/pos/sessions/:id/close         — Close session
GET    /api/v1/pos/sessions/:id/report        — Session report

# Products
GET    /api/v1/pos/products?search=coffee     — Product lookup
GET    /api/v1/pos/products/barcode/:code     — Barcode lookup

# Sync
POST   /api/v1/pos/sync/upload               — Upload offline transactions
GET    /api/v1/pos/sync/products              — Download product catalog

# Reports
GET    /api/v1/pos/reports/daily              — Daily summary
GET    /api/v1/pos/reports/z-report           — Z-Report
```

---

## Security

- **PCI DSS compliance**: For card payments — never store full card data
- **Role-based access**: Cashier, supervisor, manager, admin
- **Void/refund authorization**: Require supervisor approval
- **Session locking**: Auto-lock after inactivity
- **Audit trail**: Log all transactions, voids, refunds, cash drawer opens
- **Tamper-proof**: Transaction records must be immutable after creation
