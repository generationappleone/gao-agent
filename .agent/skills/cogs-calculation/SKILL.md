---
name: COGS Calculation
description: Skill for implementing Cost of Goods Sold (COGS) calculation — covering inventory valuation methods (FIFO, LIFO, Weighted Average), manufacturing COGS, SaaS COGS, margin analysis, and financial reporting.
---

# COGS Calculation — Implementation Guide

## Core Formulas

### Basic COGS (Retail/Trading)
```
COGS = Beginning Inventory + Purchases − Ending Inventory
```

### Manufacturing COGS
```
COGS = Beginning Finished Goods
     + Cost of Goods Manufactured (COGM)
     − Ending Finished Goods

COGM = Direct Materials Used
     + Direct Labor
     + Manufacturing Overhead
     + Beginning WIP
     − Ending WIP

Direct Materials Used = Beginning Raw Materials
                      + Raw Material Purchases
                      − Ending Raw Materials
```

### SaaS COGS
```
SaaS COGS = Hosting & Infrastructure Costs
          + Customer Support Costs (direct)
          + Third-Party Software Licenses
          + Payment Processing Fees
          + Data Communication Costs
          + DevOps/Site Reliability Costs (direct)
```

---

## Inventory Valuation Methods

### 1. FIFO (First-In, First-Out)
Oldest inventory sold first. Best when prices are rising.

```javascript
function calculateCOGS_FIFO(purchases, quantitySold) {
  let remaining = quantitySold;
  let cogs = 0;
  const inventoryLayers = [...purchases]; // clone

  for (const layer of inventoryLayers) {
    if (remaining <= 0) break;

    const unitsFromLayer = Math.min(remaining, layer.quantity);
    cogs += unitsFromLayer * layer.unitCost;
    layer.quantity -= unitsFromLayer;
    remaining -= unitsFromLayer;
  }

  return {
    cogs,
    remainingInventory: inventoryLayers.filter(l => l.quantity > 0)
  };
}

// Example
const purchases = [
  { date: '2026-01-01', quantity: 100, unitCost: 10000 },
  { date: '2026-01-15', quantity: 150, unitCost: 12000 },
  { date: '2026-02-01', quantity: 200, unitCost: 11000 },
];
const result = calculateCOGS_FIFO(purchases, 180);
// COGS = (100 × 10000) + (80 × 12000) = 1,960,000
```

### 2. LIFO (Last-In, First-Out)
Newest inventory sold first. Best when prices are falling.

```javascript
function calculateCOGS_LIFO(purchases, quantitySold) {
  let remaining = quantitySold;
  let cogs = 0;
  const inventoryLayers = [...purchases].reverse(); // newest first

  for (const layer of inventoryLayers) {
    if (remaining <= 0) break;

    const unitsFromLayer = Math.min(remaining, layer.quantity);
    cogs += unitsFromLayer * layer.unitCost;
    layer.quantity -= unitsFromLayer;
    remaining -= unitsFromLayer;
  }

  return { cogs };
}
```

### 3. Weighted Average Cost (WAC)
Average cost of all inventory. Simplest method.

```javascript
function calculateCOGS_WeightedAverage(purchases, quantitySold) {
  const totalCost = purchases.reduce((sum, p) => sum + (p.quantity * p.unitCost), 0);
  const totalUnits = purchases.reduce((sum, p) => sum + p.quantity, 0);
  const weightedAvgCost = totalCost / totalUnits;

  return {
    cogs: quantitySold * weightedAvgCost,
    weightedAvgCost,
    endingInventoryValue: (totalUnits - quantitySold) * weightedAvgCost
  };
}
```

---

## Database Schema

```sql
-- Products (for COGS tracking)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    category_id UUID REFERENCES categories(id),
    unit_of_measure VARCHAR(50) DEFAULT 'unit',
    costing_method ENUM('fifo', 'lifo', 'weighted_average') DEFAULT 'weighted_average',
    current_cost DECIMAL(15,4) DEFAULT 0,      -- latest weighted avg cost
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory lots (for FIFO/LIFO tracking)
CREATE TABLE inventory_lots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    lot_number VARCHAR(100),
    purchase_order_id UUID REFERENCES purchase_orders(id),
    quantity_received DECIMAL(15,4) NOT NULL,
    quantity_remaining DECIMAL(15,4) NOT NULL,
    unit_cost DECIMAL(15,4) NOT NULL,         -- cost per unit at purchase
    landed_cost DECIMAL(15,4) DEFAULT 0,      -- freight, duties, etc.
    total_cost DECIMAL(15,4) NOT NULL,
    received_date DATE NOT NULL,
    expiry_date DATE,
    warehouse_id UUID REFERENCES warehouses(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COGS transactions (journal entries)
CREATE TABLE cogs_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    transaction_type ENUM('sale', 'adjustment', 'write_off', 'return') NOT NULL,
    reference_type VARCHAR(50),               -- 'sale_order', 'adjustment'
    reference_id UUID,                        -- links to sale_order, etc.
    quantity DECIMAL(15,4) NOT NULL,
    unit_cost DECIMAL(15,4) NOT NULL,
    total_cogs DECIMAL(15,2) NOT NULL,
    costing_method ENUM('fifo', 'lifo', 'weighted_average') NOT NULL,
    lot_id UUID REFERENCES inventory_lots(id), -- for FIFO/LIFO
    notes TEXT,
    transaction_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COGS summary (per period)
CREATE TABLE cogs_period_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    beginning_inventory_qty DECIMAL(15,4) NOT NULL,
    beginning_inventory_value DECIMAL(15,2) NOT NULL,
    purchases_qty DECIMAL(15,4) DEFAULT 0,
    purchases_value DECIMAL(15,2) DEFAULT 0,
    cogs_qty DECIMAL(15,4) DEFAULT 0,
    cogs_value DECIMAL(15,2) DEFAULT 0,
    adjustments_value DECIMAL(15,2) DEFAULT 0,
    ending_inventory_qty DECIMAL(15,4) NOT NULL,
    ending_inventory_value DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, period_start, period_end)
);
```

---

## Key Reports

### 1. Gross Profit Report
```
Revenue                          Rp 100,000,000
− COGS                           Rp  60,000,000
─────────────────────────────────────────────────
= Gross Profit                   Rp  40,000,000
  Gross Margin                         40.00%
```

### 2. COGS Breakdown
```
Beginning Inventory              Rp  15,000,000
+ Purchases                     Rp  55,000,000
+ Freight-In                    Rp   2,000,000
+ Direct Labor                  Rp   8,000,000
─────────────────────────────────────────────────
= Goods Available for Sale       Rp  80,000,000
− Ending Inventory               Rp  20,000,000
─────────────────────────────────────────────────
= COGS                          Rp  60,000,000
```

### 3. Product Profitability
```
| Product    | Revenue     | COGS        | Gross Profit | Margin |
|------------|-------------|-------------|--------------|--------|
| Product A  | 50,000,000  | 28,000,000  | 22,000,000   | 44%    |
| Product B  | 30,000,000  | 20,000,000  | 10,000,000   | 33%    |
| Product C  | 20,000,000  | 12,000,000  |  8,000,000   | 40%    |
```

---

## Landed Cost Calculation

```javascript
function calculateLandedCost(purchasePrice, additionalCosts) {
  const {
    freightCost = 0,
    insuranceCost = 0,
    customsDuty = 0,
    handlingFee = 0,
    otherCosts = 0,
  } = additionalCosts;

  const totalLandedCost = purchasePrice + freightCost + insuranceCost
                        + customsDuty + handlingFee + otherCosts;

  return {
    totalLandedCost,
    landedCostPerUnit: totalLandedCost / quantity,
    breakdown: { purchasePrice, freightCost, insuranceCost, customsDuty, handlingFee, otherCosts }
  };
}
```

---

## Best Practices

- **Consistency**: Use the same costing method throughout the fiscal year
- **Real-time tracking**: Update COGS on every sale, not just at period end
- **Landed costs**: Include freight, insurance, duties in unit cost
- **Separation**: Clearly distinguish COGS from operating expenses
- **Audit trail**: Every COGS transaction must be traceable
- **Period close**: Generate COGS summary at month/quarter/year end
- **Integration**: COGS feeds into General Ledger, Income Statement
