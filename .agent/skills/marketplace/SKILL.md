---
name: Marketplace Application
description: Skill for building multi-vendor marketplace applications — covering product catalog, vendor management, cart/checkout, payment processing, reviews/ratings, search, order fulfillment, and admin dashboard.
---

# Marketplace Application — Development Guide

## Architecture Overview

### Recommended Architecture
- **Headless Commerce** — Separate frontend (React/Next.js/Vue) from backend API
- **Microservices** — Independent services for catalog, orders, payments, users
- **API-First** — RESTful or GraphQL APIs for all functionality
- **Event-Driven** — Use message queues (Kafka/RabbitMQ) for async operations

### Core Services

```
┌─────────────┐  ┌──────────────┐  ┌──────────────┐
│  API Gateway │  │  Auth Service │  │ User Service  │
└──────┬──────┘  └──────────────┘  └──────────────┘
       │
├──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Product/     │  │ Order        │  │ Payment      │
│ Catalog Svc  │  │ Service      │  │ Service      │
└──────────────┘  └──────────────┘  └──────────────┘
       │
├──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Search       │  │ Review       │  │ Notification │
│ Service      │  │ Service      │  │ Service      │
└──────────────┘  └──────────────┘  └──────────────┘
       │
├──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Vendor       │  │ Shipping     │  │ Analytics    │
│ Service      │  │ Service      │  │ Service      │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## Database Schema (Core Tables)

### Users & Vendors
```sql
-- Users (buyers + vendors)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('buyer', 'vendor', 'admin') NOT NULL DEFAULT 'buyer',
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Vendor profiles
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    store_name VARCHAR(255) NOT NULL,
    store_slug VARCHAR(255) NOT NULL UNIQUE,
    store_description TEXT,
    store_logo_url TEXT,
    store_banner_url TEXT,
    commission_rate DECIMAL(5,2) DEFAULT 10.00,  -- platform fee %
    bank_account_name VARCHAR(255),
    bank_account_number VARCHAR(50),
    bank_name VARCHAR(100),
    is_approved BOOLEAN DEFAULT FALSE,
    rating_average DECIMAL(3,2) DEFAULT 0,
    total_sales INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Addresses
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    label VARCHAR(50),            -- 'Home', 'Office'
    recipient_name VARCHAR(255),
    phone VARCHAR(20),
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    country VARCHAR(100) DEFAULT 'Indonesia',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);
```

### Product Catalog
```sql
-- Categories (nested set or adjacency list)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    icon_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    category_id UUID NOT NULL REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    short_description VARCHAR(500),
    sku VARCHAR(100),
    price DECIMAL(15,2) NOT NULL,
    compare_at_price DECIMAL(15,2),   -- original price (for discount display)
    cost_price DECIMAL(15,2),         -- COGS
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    low_stock_threshold INTEGER DEFAULT 5,
    weight_grams INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    rating_average DECIMAL(3,2) DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    total_sold INTEGER DEFAULT 0,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Product images
CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    image_url TEXT NOT NULL,
    alt_text VARCHAR(255),
    sort_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product variants (size, color, etc.)
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    name VARCHAR(255) NOT NULL,          -- "Red / Large"
    sku VARCHAR(100),
    price DECIMAL(15,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    weight_grams INTEGER,
    attributes JSONB,                     -- {"color": "Red", "size": "L"}
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Orders & Payments
```sql
-- Shopping cart
CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(255),              -- for guest carts
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL REFERENCES carts(id),
    product_id UUID NOT NULL REFERENCES products(id),
    variant_id UUID REFERENCES product_variants(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) NOT NULL UNIQUE,  -- e.g. "ORD-20260219-001"
    user_id UUID NOT NULL REFERENCES users(id),
    shipping_address_id UUID NOT NULL REFERENCES addresses(id),
    status ENUM('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    subtotal DECIMAL(15,2) NOT NULL,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    coupon_code VARCHAR(50),
    payment_method VARCHAR(50),
    payment_status ENUM('unpaid', 'paid', 'refunded', 'partial_refund') DEFAULT 'unpaid',
    notes TEXT,
    paid_at TIMESTAMP NULL,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Order items (per vendor sub-order)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id),
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    product_id UUID NOT NULL REFERENCES products(id),
    variant_id UUID REFERENCES product_variants(id),
    product_name VARCHAR(255) NOT NULL,   -- snapshot
    variant_name VARCHAR(255),            -- snapshot
    price DECIMAL(15,2) NOT NULL,         -- snapshot
    quantity INTEGER NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    commission_rate DECIMAL(5,2) NOT NULL, -- snapshot of vendor rate
    commission_amount DECIMAL(15,2) NOT NULL,
    vendor_payout DECIMAL(15,2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    tracking_number VARCHAR(255),
    shipping_carrier VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment transactions
CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id),
    payment_gateway VARCHAR(50) NOT NULL,  -- 'midtrans', 'stripe', 'xendit'
    gateway_transaction_id VARCHAR(255),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'IDR',
    status ENUM('pending', 'success', 'failed', 'expired', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_url TEXT,                      -- redirect URL for payment page
    raw_response JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vendor payouts
CREATE TABLE vendor_payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    amount DECIMAL(15,2) NOT NULL,
    status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
    payout_date TIMESTAMP,
    bank_account_name VARCHAR(255),
    bank_account_number VARCHAR(50),
    bank_name VARCHAR(100),
    reference_number VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Reviews & Ratings
```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    user_id UUID NOT NULL REFERENCES users(id),
    order_item_id UUID NOT NULL REFERENCES order_items(id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT TRUE,
    is_approved BOOLEAN DEFAULT TRUE,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    UNIQUE(user_id, order_item_id)  -- one review per purchase
);

CREATE TABLE review_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id),
    image_url TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Features Implementation

### 1. Product Search & Discovery
- Full-text search (Elasticsearch/Meilisearch/Algolia)
- Faceted filtering (category, price range, rating, vendor)
- Autocomplete/suggestions
- Sort by: relevance, price, rating, newest, best-selling
- Pagination (cursor-based for infinite scroll)

### 2. Shopping Cart
- Persistent cart (DB-backed for logged-in users)
- Session-based cart for guests
- Cart merge on login
- Stock validation on add-to-cart and checkout
- Group items by vendor for shipping calculation

### 3. Checkout Flow
```
Cart → Shipping Address → Shipping Method (per vendor) → Payment Method → Review → Place Order
```
- Address selection/creation
- Per-vendor shipping calculation
- Coupon/voucher application
- Order summary with tax breakdown
- Payment gateway integration (Midtrans, Stripe, Xendit)

### 4. Payment Processing
- **Escrow model**: Platform holds payment until buyer confirms delivery
- Support multiple gateways (bank transfer, e-wallet, credit card, COD)
- Webhook handling for payment status updates
- Automatic order cancellation on payment expiry
- Refund processing

### 5. Vendor Dashboard
- Sales analytics (revenue, orders, conversion)
- Product management (CRUD, bulk upload)
- Order management (process, ship, track)
- Payout history and withdrawal requests
- Store settings and branding

### 6. Admin Panel
- Vendor approval and management
- Category management
- Commission rate configuration
- Platform-wide analytics
- Content moderation (products, reviews)
- Coupon/promotion management
- Payout management

### 7. Notifications
- Email: order confirmation, shipping update, payment receipt
- Push: new order (vendor), delivery update (buyer)
- In-app: review reminders, promotion alerts

---

## API Patterns

### Product Listing
```
GET /api/v1/products?category=electronics&sort=price_asc&page=1&limit=20
GET /api/v1/products/search?q=iphone&min_price=1000000&max_price=5000000
GET /api/v1/products/:slug
```

### Cart Operations
```
POST   /api/v1/cart/items          { product_id, variant_id, quantity }
PATCH  /api/v1/cart/items/:id      { quantity }
DELETE /api/v1/cart/items/:id
GET    /api/v1/cart
```

### Order Operations
```
POST   /api/v1/orders              { shipping_address_id, payment_method, coupon_code }
GET    /api/v1/orders
GET    /api/v1/orders/:id
PATCH  /api/v1/orders/:id/cancel
```

### Vendor Operations
```
GET    /api/v1/vendor/dashboard
GET    /api/v1/vendor/orders
PATCH  /api/v1/vendor/orders/:id/ship    { tracking_number, carrier }
GET    /api/v1/vendor/products
POST   /api/v1/vendor/products
```

---

## Security Considerations

- **Payment data**: Never store raw card numbers — use tokenization via payment gateway
- **Rate limiting**: Protect cart and checkout from abuse
- **Stock race conditions**: Use database locks or optimistic concurrency for stock updates
- **Input validation**: Validate all product data, prices, quantities
- **XSS prevention**: Sanitize all user-generated content (product descriptions, reviews)
- **CSRF protection**: On all state-changing operations
- **Vendor isolation**: Vendors can only access their own data
- **Admin audit trail**: Log all admin actions

## Performance Optimization

- **Product images**: CDN delivery, WebP format, responsive sizes
- **Search**: Dedicated search engine (Elasticsearch/Meilisearch), not DB LIKE queries
- **Caching**: Redis for product listings, categories, cart sessions
- **Database indexing**: On slug, category_id, vendor_id, status, created_at
- **Pagination**: Cursor-based for large result sets
- **Background jobs**: Order processing, email sending, image processing
