---
name: Cloud Service Ordering
description: Skill for building cloud service ordering platforms — covering service catalog, provisioning automation, subscription management, usage metering, billing integration, and self-service portal.
---

# Cloud Service Ordering — Development Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│              Client Portal (Frontend)            │
│   Self-Service Dashboard · Service Catalog       │
└───────────────────┬─────────────────────────────┘
                    │ REST/GraphQL API
┌───────────────────┴─────────────────────────────┐
│                API Gateway                       │
│   Auth · Rate Limit · Routing · Load Balancing   │
└───────────────────┬─────────────────────────────┘
                    │
┌──────────┬────────┼────────┬──────────┬─────────┐
│ Catalog  │ Order  │ Provis.│ Billing  │ User    │
│ Service  │ Service│ Engine │ Service  │ Service │
└──────────┘────────┘────────┘──────────┘─────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│          Infrastructure Layer                    │
│  Cloud APIs (AWS/GCP/Azure) · IaC (Terraform)   │
│  Container Orchestration (K8s) · Monitoring      │
└─────────────────────────────────────────────────┘
```

---

## Database Schema

```sql
-- Service catalog
CREATE TABLE service_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    short_description VARCHAR(500),
    category ENUM('compute', 'storage', 'database', 'networking', 'security', 'platform', 'saas') NOT NULL,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    specifications JSONB,          -- {"cpu_options": [...], "ram_options": [...]}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Pricing plans
CREATE TABLE pricing_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id UUID NOT NULL REFERENCES service_catalog(id),
    name VARCHAR(255) NOT NULL,             -- 'Basic', 'Pro', 'Enterprise'
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    billing_cycle ENUM('hourly', 'daily', 'monthly', 'annually', 'one_time') NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'IDR',
    setup_fee DECIMAL(15,2) DEFAULT 0,
    features JSONB,                          -- ["10GB Storage", "2 vCPU", "SSL"]
    resource_limits JSONB,                   -- {"cpu": 2, "ram_gb": 4, "storage_gb": 50}
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customer orders
CREATE TABLE service_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id),
    service_id UUID NOT NULL REFERENCES service_catalog(id),
    plan_id UUID NOT NULL REFERENCES pricing_plans(id),
    status ENUM('pending', 'approved', 'provisioning', 'active', 'suspended', 'cancelled', 'failed') DEFAULT 'pending',
    configuration JSONB,                     -- customer-selected options
    hostname VARCHAR(255),
    ip_address VARCHAR(45),
    region VARCHAR(100),
    provisioning_data JSONB,                 -- infra details (instance ID, etc.)
    approved_at TIMESTAMP NULL,
    provisioned_at TIMESTAMP NULL,
    suspended_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancellation_reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Subscriptions
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    order_id UUID NOT NULL REFERENCES service_orders(id),
    plan_id UUID NOT NULL REFERENCES pricing_plans(id),
    status ENUM('trial', 'active', 'past_due', 'cancelled', 'expired') DEFAULT 'active',
    current_period_start TIMESTAMP NOT NULL,
    current_period_end TIMESTAMP NOT NULL,
    trial_ends_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Usage metering
CREATE TABLE usage_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id),
    metric_type VARCHAR(100) NOT NULL,       -- 'bandwidth_gb', 'api_calls', 'storage_gb'
    quantity DECIMAL(15,4) NOT NULL,
    unit VARCHAR(50) NOT NULL,               -- 'GB', 'calls', 'hours'
    recorded_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Provisioning tasks
CREATE TABLE provisioning_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES service_orders(id),
    task_type VARCHAR(100) NOT NULL,          -- 'create_vm', 'configure_dns', 'install_ssl'
    status ENUM('pending', 'running', 'completed', 'failed', 'retrying') DEFAULT 'pending',
    attempt_count INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    input_data JSONB,
    output_data JSONB,
    error_message TEXT,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Features

### 1. Service Catalog
- Categorized service listing with filtering
- Service detail page with specs, pricing tiers
- Feature comparison matrix across plans
- Service availability by region

### 2. Order Flow
```
Browse Catalog → Select Plan → Configure → Review → Payment → Provisioning → Active
```

### 3. Automated Provisioning
- **IaC integration**: Terraform/Pulumi for infrastructure
- **Task queue**: Background workers for async provisioning
- **Retry logic**: Automatic retry with exponential backoff
- **Status tracking**: Real-time provisioning progress
- **Rollback**: Auto-cleanup on partial failure

### 4. Self-Service Portal
- Service dashboard (active services, status, usage)
- Upgrade/downgrade plan
- Service restart/stop/start
- Resource monitoring (CPU, RAM, bandwidth)
- Support ticket creation
- Billing and invoice history

### 5. Usage Metering & Billing
- Real-time usage tracking
- Usage-based pricing calculation
- Overage charges
- Invoice generation at billing cycle
- Multiple payment methods
- Auto-renewal and dunning management

---

## API Endpoints

```
# Catalog
GET    /api/v1/catalog                           — List services
GET    /api/v1/catalog/:slug                     — Service detail
GET    /api/v1/catalog/:slug/plans               — Pricing plans

# Orders
POST   /api/v1/orders                            — Place order
GET    /api/v1/orders                            — My orders
GET    /api/v1/orders/:id                        — Order detail
GET    /api/v1/orders/:id/provisioning-status    — Provisioning progress

# Subscriptions
GET    /api/v1/subscriptions                     — My subscriptions
PATCH  /api/v1/subscriptions/:id/upgrade         — Upgrade plan
PATCH  /api/v1/subscriptions/:id/downgrade       — Downgrade plan
POST   /api/v1/subscriptions/:id/cancel          — Cancel

# Usage
GET    /api/v1/subscriptions/:id/usage           — Usage statistics

# Admin
GET    /api/v1/admin/orders                      — All orders
PATCH  /api/v1/admin/orders/:id/approve          — Approve order
PATCH  /api/v1/admin/orders/:id/provision        — Trigger provisioning
```

---

## Security Considerations

- **Resource isolation**: Each customer's resources must be isolated (separate VPCs, namespaces)
- **API key management**: Secure generation, rotation, and revocation
- **Provisioning security**: IaC templates validated and versioned
- **Billing integrity**: Tamper-proof usage records, audit trail
- **Access control**: RBAC for admin operations, customer isolation
- **Rate limiting**: On all API endpoints, especially provisioning triggers
