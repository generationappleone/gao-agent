---
name: Sales & Purchase Management
description: Skill for building Sales and Purchase management modules — covering quotations, sales orders, purchase orders, supplier management, approval workflows, and ERP integration.
---

# Sales & Purchase Management — Development Guide

## Architecture

```
┌─────────────────────────────────────────────────┐
│            Sales & Purchase Dashboard             │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│                  Core Services                   │
│  ┌──────────┐ ┌──────────┐ ┌────────────────┐   │
│  │ Sales    │ │ Purchase │ │ Customer/      │   │
│  │ Service  │ │ Service  │ │ Supplier Svc   │   │
│  └──────────┘ └──────────┘ └────────────────┘   │
│  ┌──────────┐ ┌──────────┐ ┌────────────────┐   │
│  │ Approval │ │ Pricing  │ │ Report         │   │
│  │ Workflow │ │ Engine   │ │ Service        │   │
│  └──────────┘ └──────────┘ └────────────────┘   │
└─────────────────────────────────────────────────┘
    │             │              │
    ▼             ▼              ▼
 Inventory    Accounting     Warehouse
```

---

## Database Schema

### Sales Module
```sql
-- Customers
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    company_name VARCHAR(255),
    tax_id VARCHAR(50),                       -- NPWP
    billing_address TEXT,
    shipping_address TEXT,
    credit_limit DECIMAL(15,2) DEFAULT 0,
    payment_terms INTEGER DEFAULT 30,         -- days
    customer_group VARCHAR(100),              -- 'retail', 'wholesale', 'enterprise'
    discount_rate DECIMAL(5,2) DEFAULT 0,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Sales quotations
CREATE TABLE sales_quotations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quotation_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id UUID NOT NULL REFERENCES customers(id),
    salesperson_id UUID REFERENCES users(id),
    status ENUM('draft', 'sent', 'accepted', 'rejected', 'expired', 'converted') DEFAULT 'draft',
    valid_until DATE,
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'IDR',
    terms_and_conditions TEXT,
    notes TEXT,
    sent_at TIMESTAMP NULL,
    accepted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

CREATE TABLE sales_quotation_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quotation_id UUID NOT NULL REFERENCES sales_quotations(id),
    product_id UUID NOT NULL REFERENCES products(id),
    description VARCHAR(500),
    quantity DECIMAL(15,4) NOT NULL,
    unit_price DECIMAL(15,4) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 11,         -- PPN 11%
    subtotal DECIMAL(15,2) NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales orders
CREATE TABLE sales_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) NOT NULL UNIQUE,
    quotation_id UUID REFERENCES sales_quotations(id),
    customer_id UUID NOT NULL REFERENCES customers(id),
    salesperson_id UUID REFERENCES users(id),
    status ENUM('draft', 'confirmed', 'processing', 'shipped', 'delivered', 'invoiced', 'cancelled') DEFAULT 'draft',
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    delivery_date DATE,
    shipping_address TEXT,
    subtotal DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'IDR',
    payment_terms INTEGER DEFAULT 30,
    payment_status ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid',
    notes TEXT,
    confirmed_at TIMESTAMP NULL,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

CREATE TABLE sales_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES sales_orders(id),
    product_id UUID NOT NULL REFERENCES products(id),
    description VARCHAR(500),
    quantity DECIMAL(15,4) NOT NULL,
    quantity_shipped DECIMAL(15,4) DEFAULT 0,
    quantity_invoiced DECIMAL(15,4) DEFAULT 0,
    unit_price DECIMAL(15,4) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 11,
    subtotal DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Purchase Module
```sql
-- Suppliers
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    company_name VARCHAR(255),
    tax_id VARCHAR(50),
    address TEXT,
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    bank_account_name VARCHAR(255),
    payment_terms INTEGER DEFAULT 30,
    lead_time_days INTEGER DEFAULT 7,
    rating DECIMAL(3,2) DEFAULT 0,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Purchase requests (internal)
CREATE TABLE purchase_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_number VARCHAR(50) NOT NULL UNIQUE,
    requested_by UUID NOT NULL REFERENCES users(id),
    department VARCHAR(100),
    status ENUM('draft', 'submitted', 'approved', 'rejected', 'converted') DEFAULT 'draft',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    reason TEXT,
    required_date DATE,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Purchase orders
CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_number VARCHAR(50) NOT NULL UNIQUE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    purchase_request_id UUID REFERENCES purchase_requests(id),
    status ENUM('draft', 'sent', 'confirmed', 'partial_received', 'received', 'invoiced', 'cancelled') DEFAULT 'draft',
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expected_delivery_date DATE,
    shipping_address TEXT,
    subtotal DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'IDR',
    payment_terms INTEGER DEFAULT 30,
    payment_status ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid',
    terms_and_conditions TEXT,
    notes TEXT,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP NULL,
    sent_at TIMESTAMP NULL,
    received_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_id UUID NOT NULL REFERENCES purchase_orders(id),
    product_id UUID NOT NULL REFERENCES products(id),
    description VARCHAR(500),
    quantity DECIMAL(15,4) NOT NULL,
    quantity_received DECIMAL(15,4) DEFAULT 0,
    quantity_invoiced DECIMAL(15,4) DEFAULT 0,
    unit_price DECIMAL(15,4) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 11,
    subtotal DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Approval Workflow
```sql
CREATE TABLE approval_workflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_type VARCHAR(50) NOT NULL,       -- 'purchase_order', 'purchase_request'
    min_amount DECIMAL(15,2) DEFAULT 0,
    max_amount DECIMAL(15,2),
    approver_role VARCHAR(100) NOT NULL,       -- 'manager', 'finance_director', 'ceo'
    approval_level INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE approval_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_type VARCHAR(50) NOT NULL,
    document_id UUID NOT NULL,
    approver_id UUID NOT NULL REFERENCES users(id),
    approval_level INTEGER NOT NULL,
    action ENUM('approved', 'rejected', 'returned') NOT NULL,
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Process Flows

### Sales Flow
```
Lead → Quotation → Sales Order → Delivery Order → Invoice → Payment
```

### Purchase Flow
```
Purchase Request → Approval → Quotation from Suppliers → Purchase Order → Goods Receipt → Invoice Matching → Payment
```

### Three-Way Matching (Purchase)
```
Purchase Order (what we ordered)
   + Goods Receipt Note (what we received)
   + Supplier Invoice (what they charge)
   = Verified for Payment
```

---

## API Endpoints

```
# Sales
POST   /api/v1/quotations              — Create quotation
POST   /api/v1/quotations/:id/send     — Send to customer
POST   /api/v1/quotations/:id/convert  — Convert to sales order
GET    /api/v1/sales-orders             — List sales orders
POST   /api/v1/sales-orders             — Create sales order
PATCH  /api/v1/sales-orders/:id/confirm — Confirm order

# Purchase
POST   /api/v1/purchase-requests        — Create PR
POST   /api/v1/purchase-requests/:id/submit  — Submit for approval
POST   /api/v1/purchase-orders          — Create PO
POST   /api/v1/purchase-orders/:id/send — Send to supplier
POST   /api/v1/purchase-orders/:id/receive — Record goods receipt

# Approval
POST   /api/v1/approvals/:id/approve    — Approve
POST   /api/v1/approvals/:id/reject     — Reject
GET    /api/v1/approvals/pending         — My pending approvals
```

---

## Integration Points
- **Inventory**: Stock reservation on SO confirm, stock increase on PO receive
- **Accounting**: Journal entries on invoicing and payment
- **Warehouse**: Delivery orders trigger picking, GRN triggers putaway
- **COGS**: Update product cost on purchase receipt
