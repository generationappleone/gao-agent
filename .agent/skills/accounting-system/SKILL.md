---
name: Accounting System
description: Skill for building accounting systems — covering chart of accounts, double-entry bookkeeping, general ledger, journal entries, financial statements (P&L, balance sheet, cash flow), accounts receivable/payable, bank reconciliation, and tax reporting.
---

# Accounting System — Development Guide

## Core Principle: Double-Entry Bookkeeping

Every financial transaction records **equal debits and credits**. The accounting equation must always balance:

```
Assets = Liabilities + Equity
```

### Debit/Credit Rules
| Account Type | Debit (increase) | Credit (increase) |
|-------------|-------------------|---------------------|
| **Asset** | ✅ Increases | Decreases |
| **Liability** | Decreases | ✅ Increases |
| **Equity** | Decreases | ✅ Increases |
| **Revenue** | Decreases | ✅ Increases |
| **Expense** | ✅ Increases | Decreases |

---

## Chart of Accounts (COA)

### Standard Account Numbering
```
1xxx — Assets
  1100 — Current Assets
    1110 — Cash & Bank
      1111 — Petty Cash
      1112 — Bank BCA
      1113 — Bank Mandiri
    1120 — Accounts Receivable
    1130 — Inventory
    1140 — Prepaid Expenses
  1200 — Fixed Assets
    1210 — Equipment
    1211 — Accumulated Depreciation — Equipment
    1220 — Vehicles
    1230 — Building

2xxx — Liabilities
  2100 — Current Liabilities
    2110 — Accounts Payable
    2120 — Accrued Expenses
    2130 — Tax Payable (PPN, PPh)
    2140 — Unearned Revenue
  2200 — Long-Term Liabilities
    2210 — Bank Loans
    2220 — Bonds Payable

3xxx — Equity
  3100 — Owner's Capital / Share Capital
  3200 — Retained Earnings
  3300 — Current Year Earnings
  3400 — Dividends

4xxx — Revenue
  4100 — Sales Revenue
  4200 — Service Revenue
  4300 — Other Income
  4400 — Interest Income

5xxx — Cost of Goods Sold
  5100 — COGS — Materials
  5200 — COGS — Labor
  5300 — COGS — Overhead

6xxx — Operating Expenses
  6100 — Salary & Wages
  6200 — Rent Expense
  6300 — Utilities
  6400 — Depreciation Expense
  6500 — Marketing & Advertising
  6600 — Office Supplies
  6700 — Insurance
  6800 — Professional Services

7xxx — Other Expenses
  7100 — Interest Expense
  7200 — Bank Charges
  7300 — Loss on Asset Disposal

8xxx — Tax Expense
  8100 — Income Tax Expense
```

---

## Database Schema

```sql
-- Chart of Accounts
CREATE TABLE chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_code VARCHAR(20) NOT NULL UNIQUE,
    account_name VARCHAR(255) NOT NULL,
    account_type ENUM('asset', 'liability', 'equity', 'revenue', 'expense', 'cogs') NOT NULL,
    parent_id UUID REFERENCES chart_of_accounts(id),
    normal_balance ENUM('debit', 'credit') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,          -- prevent deletion
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Fiscal periods
CREATE TABLE fiscal_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fiscal_year INTEGER NOT NULL,
    period_number INTEGER NOT NULL,           -- 1-12
    period_name VARCHAR(50) NOT NULL,         -- 'January 2026'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('open', 'closed', 'locked') DEFAULT 'open',
    closed_by UUID REFERENCES users(id),
    closed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(fiscal_year, period_number)
);

-- Journal entries (header)
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_number VARCHAR(50) NOT NULL UNIQUE,
    entry_date DATE NOT NULL,
    fiscal_period_id UUID NOT NULL REFERENCES fiscal_periods(id),
    entry_type ENUM('manual', 'sales', 'purchase', 'payment', 'receipt', 'adjustment', 'closing') NOT NULL,
    description TEXT NOT NULL,
    reference_type VARCHAR(50),               -- 'invoice', 'payment', 'purchase_order'
    reference_id UUID,
    total_debit DECIMAL(15,2) NOT NULL,
    total_credit DECIMAL(15,2) NOT NULL,
    status ENUM('draft', 'posted', 'reversed') DEFAULT 'draft',
    is_reversing BOOLEAN DEFAULT FALSE,
    reversed_entry_id UUID REFERENCES journal_entries(id),
    posted_by UUID REFERENCES users(id),
    posted_at TIMESTAMP NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    CHECK (total_debit = total_credit)        -- enforce balance
);

-- Journal entry lines (detail)
CREATE TABLE journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id),
    account_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    description VARCHAR(500),
    cost_center VARCHAR(100),                 -- department, project
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (
      (debit_amount > 0 AND credit_amount = 0) OR
      (credit_amount > 0 AND debit_amount = 0)
    )
);

-- General Ledger (materialized view or denormalized)
CREATE TABLE general_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id),
    entry_date DATE NOT NULL,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    balance DECIMAL(15,2) NOT NULL,           -- running balance
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Accounts Receivable
CREATE TABLE accounts_receivable (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id UUID NOT NULL REFERENCES customers(id),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    amount_paid DECIMAL(15,2) DEFAULT 0,
    balance_due DECIMAL(15,2) GENERATED ALWAYS AS (total_amount - amount_paid) STORED,
    status ENUM('draft', 'sent', 'partial', 'paid', 'overdue', 'written_off') DEFAULT 'draft',
    journal_entry_id UUID REFERENCES journal_entries(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Accounts Payable
CREATE TABLE accounts_payable (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bill_number VARCHAR(50) NOT NULL UNIQUE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    bill_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    amount_paid DECIMAL(15,2) DEFAULT 0,
    balance_due DECIMAL(15,2) GENERATED ALWAYS AS (total_amount - amount_paid) STORED,
    status ENUM('draft', 'approved', 'partial', 'paid', 'overdue') DEFAULT 'draft',
    journal_entry_id UUID REFERENCES journal_entries(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bank reconciliation
CREATE TABLE bank_reconciliations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bank_account_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    statement_date DATE NOT NULL,
    statement_balance DECIMAL(15,2) NOT NULL,
    book_balance DECIMAL(15,2) NOT NULL,
    reconciled_balance DECIMAL(15,2),
    status ENUM('in_progress', 'completed') DEFAULT 'in_progress',
    reconciled_by UUID REFERENCES users(id),
    reconciled_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Journal Entry Examples

### 1. Sales Transaction
```
DR  1120 Accounts Receivable    1,110,000
  CR  4100 Sales Revenue                    1,000,000
  CR  2130 PPN Output                         110,000
```

### 2. Purchase with Payment
```
DR  1130 Inventory              5,000,000
DR  2130 PPN Input                550,000
  CR  1112 Bank BCA                         5,550,000
```

### 3. Salary Payment
```
DR  6100 Salary Expense         10,000,000
  CR  2130 PPh 21 Payable                     500,000
  CR  1112 Bank BCA                         9,500,000
```

### 4. Depreciation
```
DR  6400 Depreciation Expense      416,667
  CR  1211 Accum Depr — Equipment           416,667
```

---

## Financial Statements

### Income Statement (P&L)
```
Revenue
  Sales Revenue                   100,000,000
  Service Revenue                  20,000,000
  Total Revenue                                120,000,000

Cost of Goods Sold
  COGS — Materials                 45,000,000
  COGS — Labor                     15,000,000
  Total COGS                                   (60,000,000)

Gross Profit                                    60,000,000

Operating Expenses
  Salary & Wages                   20,000,000
  Rent                              5,000,000
  Utilities                         2,000,000
  Depreciation                      3,000,000
  Marketing                         4,000,000
  Total OpEx                                   (34,000,000)

Operating Income                                26,000,000

Other Income/(Expense)
  Interest Income                   1,000,000
  Interest Expense                 (2,000,000)
  Total Other                                   (1,000,000)

Net Income Before Tax                           25,000,000
  Income Tax (22%)                              (5,500,000)
Net Income                                      19,500,000
```

### Balance Sheet
```
ASSETS
  Current Assets
    Cash & Bank                    50,000,000
    Accounts Receivable            30,000,000
    Inventory                      25,000,000
    Prepaid Expenses                3,000,000
  Total Current Assets                        108,000,000

  Fixed Assets
    Equipment                      20,000,000
    Less: Accum. Depreciation      (5,000,000)
  Total Fixed Assets                           15,000,000

TOTAL ASSETS                                  123,000,000

LIABILITIES
  Current Liabilities
    Accounts Payable               15,000,000
    Tax Payable                     5,500,000
    Accrued Expenses                2,500,000
  Total Current Liabilities                    23,000,000

EQUITY
  Owner's Capital                  80,500,000
  Retained Earnings                19,500,000
  Total Equity                                100,000,000

TOTAL LIABILITIES + EQUITY                    123,000,000
```

---

## API Endpoints

```
# Chart of Accounts
GET    /api/v1/accounts                        — List accounts
POST   /api/v1/accounts                        — Create account
GET    /api/v1/accounts/:id/ledger             — Account ledger

# Journal Entries
POST   /api/v1/journal-entries                 — Create entry
POST   /api/v1/journal-entries/:id/post        — Post entry
POST   /api/v1/journal-entries/:id/reverse     — Reverse entry
GET    /api/v1/journal-entries                  — List entries

# Reports
GET    /api/v1/reports/trial-balance           — Trial Balance
GET    /api/v1/reports/income-statement        — P&L
GET    /api/v1/reports/balance-sheet           — Balance Sheet
GET    /api/v1/reports/cash-flow               — Cash Flow Statement
GET    /api/v1/reports/aging-receivable        — AR Aging
GET    /api/v1/reports/aging-payable           — AP Aging
GET    /api/v1/reports/general-ledger          — GL Detail

# Bank Reconciliation
POST   /api/v1/bank-reconciliation             — Start reconciliation
PATCH  /api/v1/bank-reconciliation/:id/match   — Match transactions
```

---

## Key Rules

- **Immutability**: Posted journal entries CANNOT be edited — only reversed and re-entered
- **Balance enforcement**: Every journal entry must have equal debits and credits (DB constraint)
- **Period control**: Cannot post to closed fiscal periods
- **Audit trail**: Every action logged with who/what/when
- **Approval workflow**: Journal entries above threshold require approval
- **Month-end close**: Generate closing entries, lock period
- **Year-end close**: Transfer net income to retained earnings
