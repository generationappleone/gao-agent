---
name: PostgreSQL
description: Skill for designing, developing, and managing PostgreSQL databases, covering schema design, advanced queries, indexing, performance tuning, extensions, and operational best practices.
---

# PostgreSQL Skill

## Overview
PostgreSQL is an advanced open-source relational database. Use this skill for relational data storage with advanced features like JSONB, CTEs, window functions, partitioning, and Row-Level Security.

## Setup & Connection
```bash
# Docker
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=mydb postgres:16-alpine

# Connection string
postgresql://user:password@localhost:5432/mydb?sslmode=require
```

## Schema Design (Following Database Rules)
```sql
-- UUID primary keys, audit columns, soft delete, constraints
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ DEFAULT NULL,
    CONSTRAINT uq_users_email UNIQUE (email)
);

-- Partial index for active records
CREATE INDEX idx_users_email_active ON users (email) WHERE deleted_at IS NULL;
```

## Advanced Features

### JSONB for Semi-Structured Data
```sql
ALTER TABLE products ADD COLUMN metadata JSONB DEFAULT '{}';
CREATE INDEX idx_products_metadata ON products USING GIN (metadata);

-- Query JSONB
SELECT * FROM products WHERE metadata->>'brand' = 'Apple';
SELECT * FROM products WHERE metadata @> '{"color": "red"}';
```

### Common Table Expressions (CTEs)
```sql
WITH monthly_sales AS (
    SELECT date_trunc('month', created_at) AS month, SUM(total_amount) AS revenue
    FROM orders WHERE status = 'completed'
    GROUP BY 1
)
SELECT month, revenue, LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS growth_pct
FROM monthly_sales ORDER BY month;
```

### Row-Level Security
```sql
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON projects
    USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

### Partitioning
```sql
CREATE TABLE events (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

CREATE TABLE events_2026_q1 PARTITION OF events
    FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');
```

## Performance Tuning
```sql
-- Always analyze queries
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT * FROM users WHERE email = 'test@example.com';

-- Key postgresql.conf settings
-- shared_buffers = 25% of RAM
-- effective_cache_size = 75% of RAM
-- work_mem = RAM / max_connections / 4
-- maintenance_work_mem = 512MB-1GB
```

## Useful Extensions
| Extension | Purpose |
|-----------|---------|
| `pgcrypto` | UUID generation, encryption |
| `pg_trgm` | Trigram-based text search |
| `postgis` | Geospatial data |
| `pg_stat_statements` | Query performance analysis |
| `timescaledb` | Time-series optimization |

## Rules Integration
- **Database**: UUID PKs with `gen_random_uuid()`, 3NF normalization, audit columns, soft delete, partial indexes
- **Security**: RLS for multi-tenancy, encrypted connections (sslmode=require), parameterized queries
