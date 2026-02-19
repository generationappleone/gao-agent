---
name: Warehouse Management
description: Skill for building Warehouse Management Systems (WMS) — covering inventory tracking, receiving/putaway, picking/packing, shipping, location management, barcode/RFID, and cycle counting.
---

# Warehouse Management System — Development Guide

## Architecture

```
┌─────────────────────────────────────────────────┐
│           WMS Dashboard (Web + Mobile)            │
│   Inventory · Orders · Receiving · Shipping       │
└───────────────────┬─────────────────────────────┘
                    │ REST API
┌───────────────────┴─────────────────────────────┐
│               WMS Backend                        │
│  ┌───────────┐ ┌───────────┐ ┌───────────────┐  │
│  │ Inventory │ │  Order    │ │  Location     │  │
│  │  Service  │ │  Service  │ │  Service      │  │
│  └───────────┘ └───────────┘ └───────────────┘  │
│  ┌───────────┐ ┌───────────┐ ┌───────────────┐  │
│  │ Receiving │ │ Picking/  │ │  Shipping     │  │
│  │  Service  │ │ Packing   │ │  Service      │  │
│  └───────────┘ └───────────┘ └───────────────┘  │
│  ┌───────────┐ ┌───────────┐ ┌───────────────┐  │
│  │ Barcode   │ │ Reporting │ │  Integration  │  │
│  │  Service  │ │ Service   │ │  Service      │  │
│  └───────────┘ └───────────┘ └───────────────┘  │
└─────────────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┐
        │ ERP       │ E-comm    │ Carrier API
        │ System    │ Platform  │ (JNE, SiCepat)
```

---

## Database Schema

```sql
-- Warehouses
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(10),
    country VARCHAR(100) DEFAULT 'Indonesia',
    contact_person VARCHAR(255),
    contact_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Warehouse locations (zones, aisles, racks, bins)
CREATE TABLE warehouse_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    code VARCHAR(50) NOT NULL,                -- 'A-01-02-03' (zone-aisle-rack-bin)
    zone VARCHAR(50),                          -- 'A', 'B', 'COLD', 'BULK'
    aisle VARCHAR(20),
    rack VARCHAR(20),
    bin_level VARCHAR(20),
    location_type ENUM('storage', 'receiving', 'shipping', 'staging', 'quarantine', 'returns') DEFAULT 'storage',
    max_weight_kg DECIMAL(10,2),
    max_volume_m3 DECIMAL(10,4),
    is_active BOOLEAN DEFAULT TRUE,
    barcode VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(warehouse_id, code)
);

-- Products (inventory items)
CREATE TABLE inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES categories(id),
    unit_of_measure VARCHAR(50) DEFAULT 'unit',
    weight_grams INTEGER,
    length_cm DECIMAL(8,2),
    width_cm DECIMAL(8,2),
    height_cm DECIMAL(8,2),
    barcode VARCHAR(100) UNIQUE,
    min_stock_level INTEGER DEFAULT 0,
    max_stock_level INTEGER,
    reorder_point INTEGER,
    reorder_quantity INTEGER,
    is_lot_tracked BOOLEAN DEFAULT FALSE,
    is_serial_tracked BOOLEAN DEFAULT FALSE,
    is_expiry_tracked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Stock levels (per location)
CREATE TABLE stock_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES inventory_items(id),
    location_id UUID NOT NULL REFERENCES warehouse_locations(id),
    lot_number VARCHAR(100),
    serial_number VARCHAR(100),
    expiry_date DATE,
    quantity_on_hand DECIMAL(15,4) NOT NULL DEFAULT 0,
    quantity_allocated DECIMAL(15,4) NOT NULL DEFAULT 0,  -- reserved for orders
    quantity_available DECIMAL(15,4) GENERATED ALWAYS AS (quantity_on_hand - quantity_allocated) STORED,
    unit_cost DECIMAL(15,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(item_id, location_id, lot_number, serial_number)
);

-- Stock movements (audit trail)
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES inventory_items(id),
    from_location_id UUID REFERENCES warehouse_locations(id),
    to_location_id UUID REFERENCES warehouse_locations(id),
    movement_type ENUM('receive', 'putaway', 'pick', 'transfer', 'adjustment', 'return', 'ship', 'count') NOT NULL,
    reference_type VARCHAR(50),               -- 'purchase_order', 'sale_order', 'transfer_order'
    reference_id UUID,
    lot_number VARCHAR(100),
    serial_number VARCHAR(100),
    quantity DECIMAL(15,4) NOT NULL,
    unit_cost DECIMAL(15,4),
    reason TEXT,
    performed_by UUID NOT NULL REFERENCES users(id),
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Receiving (inbound)
CREATE TABLE receiving_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    receiving_number VARCHAR(50) NOT NULL UNIQUE,
    purchase_order_id UUID,
    supplier_name VARCHAR(255),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    status ENUM('expected', 'receiving', 'quality_check', 'completed', 'cancelled') DEFAULT 'expected',
    expected_date DATE,
    received_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE receiving_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    receiving_order_id UUID NOT NULL REFERENCES receiving_orders(id),
    item_id UUID NOT NULL REFERENCES inventory_items(id),
    expected_quantity DECIMAL(15,4) NOT NULL,
    received_quantity DECIMAL(15,4) DEFAULT 0,
    damaged_quantity DECIMAL(15,4) DEFAULT 0,
    putaway_location_id UUID REFERENCES warehouse_locations(id),
    lot_number VARCHAR(100),
    expiry_date DATE,
    unit_cost DECIMAL(15,4),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pick lists
CREATE TABLE pick_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pick_number VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    pick_type ENUM('single', 'batch', 'wave', 'zone') DEFAULT 'single',
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    assigned_to UUID REFERENCES users(id),
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pick_list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pick_list_id UUID NOT NULL REFERENCES pick_lists(id),
    sale_order_id UUID,
    item_id UUID NOT NULL REFERENCES inventory_items(id),
    location_id UUID NOT NULL REFERENCES warehouse_locations(id),
    quantity_to_pick DECIMAL(15,4) NOT NULL,
    quantity_picked DECIMAL(15,4) DEFAULT 0,
    lot_number VARCHAR(100),
    serial_number VARCHAR(100),
    is_picked BOOLEAN DEFAULT FALSE,
    picked_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cycle counting
CREATE TABLE cycle_counts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    count_number VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    status ENUM('planned', 'in_progress', 'completed', 'approved') DEFAULT 'planned',
    count_type ENUM('full', 'abc', 'location', 'item') NOT NULL,
    assigned_to UUID REFERENCES users(id),
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cycle_count_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cycle_count_id UUID NOT NULL REFERENCES cycle_counts(id),
    item_id UUID NOT NULL REFERENCES inventory_items(id),
    location_id UUID NOT NULL REFERENCES warehouse_locations(id),
    system_quantity DECIMAL(15,4) NOT NULL,     -- expected
    counted_quantity DECIMAL(15,4),              -- actual
    variance DECIMAL(15,4),                      -- difference
    variance_value DECIMAL(15,2),                -- cost impact
    notes TEXT,
    counted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Features

### 1. Inventory Operations
- Real-time stock levels across all locations
- Stock alerts (low stock, overstock, expiring)
- Multi-warehouse support with inter-warehouse transfers
- Lot/batch and serial number tracking
- Expiry date tracking (FEFO — First Expired, First Out)

### 2. Warehouse Processes
```
Receiving → Quality Check → Putaway → Storage → Pick → Pack → Ship
```

### 3. Picking Strategies
| Strategy | Description | Best For |
|----------|-------------|----------|
| **Single Order** | One order at a time | Low volume |
| **Batch** | Multiple orders, consolidated picks | Medium volume |
| **Wave** | Time-based batches | High volume |
| **Zone** | Pickers stay in assigned zones | Large warehouses |
| **Cluster** | Pick multiple orders simultaneously | E-commerce |

### 4. Barcode/RFID Integration
- Generate barcodes for items and locations
- Mobile scanner for receiving, picking, counting
- Barcode validation at every step

### 5. KPI Dashboard
| KPI | Description |
|-----|-------------|
| Order Accuracy | % orders shipped without errors |
| Pick Rate | Items picked per hour per worker |
| Receiving Efficiency | Items received per hour |
| Inventory Accuracy | Physical vs. system count match |
| Order Cycle Time | Time from order to shipment |
| Space Utilization | % of available storage used |
| Stockout Rate | % of times item was unavailable |

---

## API Endpoints

```
# Inventory
GET    /api/v1/inventory?warehouse=WH01&sku=SKU001    — Stock levels
GET    /api/v1/inventory/:sku/movements                 — Movement history
POST   /api/v1/inventory/adjust                         — Stock adjustment

# Receiving
POST   /api/v1/receiving                                — Create receiving order
PATCH  /api/v1/receiving/:id/receive                    — Record receipt
POST   /api/v1/receiving/:id/putaway                    — Putaway to location

# Picking
POST   /api/v1/pick-lists                               — Create pick list
PATCH  /api/v1/pick-lists/:id/pick                      — Record pick
POST   /api/v1/pick-lists/:id/complete                  — Complete pick list

# Shipping
POST   /api/v1/shipments                                — Create shipment
PATCH  /api/v1/shipments/:id/ship                       — Mark as shipped

# Counting
POST   /api/v1/cycle-counts                             — Create count
PATCH  /api/v1/cycle-counts/:id/record                  — Record count
POST   /api/v1/cycle-counts/:id/approve                 — Approve variances
```

---

## Integration Points
- **ERP**: Sync inventory levels, purchase orders, sales orders
- **E-commerce**: Real-time stock sync, order fulfillment
- **Shipping carriers**: Label generation, tracking
- **Accounting**: COGS, inventory valuation
- **Barcode hardware**: Scanners, label printers
