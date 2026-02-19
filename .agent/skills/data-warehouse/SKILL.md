---
name: Data Warehouse
description: Skill for designing Data Warehouse solutions — covering dimensional modeling (star/snowflake schema), fact/dimension tables, slowly changing dimensions, ETL pipelines, and modern cloud data warehouses.
---

# Data Warehouse Skill

## Overview
A **Data Warehouse (DWH)** is a centralized repository of structured, historical data optimized for analytical queries (OLAP). Unlike operational databases (OLTP), a DWH uses **dimensional modeling** for fast aggregation and reporting.

---

## OLTP vs OLAP

| Aspect | OLTP (Operational) | OLAP (Warehouse) |
|--------|-------------------|-------------------|
| Purpose | Day-to-day transactions | Analytics & reporting |
| Schema | Normalized (3NF) | Denormalized (star/snowflake) |
| Queries | Simple, row-level CRUD | Complex aggregations, JOINs |
| Data | Current state | Historical + current |
| Users | Application users | Analysts, BI tools |
| Volume | Moderate | Very large (TB-PB) |
| Optimization | Write-optimized | Read-optimized |

---

## Dimensional Modeling

### Star Schema (Recommended)
```
                    ┌──────────────┐
                    │ dim_product  │
                    │──────────────│
                    │ product_key  │
                    │ name         │
                    │ category     │
                    │ brand        │
                    └──────┬───────┘
                           │
┌──────────────┐  ┌───────┴────────┐  ┌──────────────┐
│  dim_date    │──│  fact_sales    │──│ dim_customer │
│──────────────│  │────────────────│  │──────────────│
│ date_key     │  │ sale_id        │  │ customer_key │
│ date         │  │ date_key    (FK)│  │ name         │
│ day_of_week  │  │ product_key (FK)│  │ segment      │
│ month        │  │ customer_key(FK)│  │ city         │
│ quarter      │  │ store_key   (FK)│  │ region       │
│ year         │  │ quantity       │  └──────────────┘
│ is_weekend   │  │ unit_price     │
│ is_holiday   │  │ total_amount   │  ┌──────────────┐
└──────────────┘  │ discount       │──│  dim_store   │
                  │ tax            │  │──────────────│
                  └────────────────┘  │ store_key    │
                                      │ store_name   │
                                      │ city         │
                                      │ region       │
                                      └──────────────┘
```

### Fact Tables
```sql
-- ✅ Fact table: Measures + foreign keys to dimensions
CREATE TABLE fact_sales (
  sale_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  date_key       INT NOT NULL REFERENCES dim_date(date_key),
  product_key    INT NOT NULL REFERENCES dim_product(product_key),
  customer_key   INT NOT NULL REFERENCES dim_customer(customer_key),
  store_key      INT NOT NULL REFERENCES dim_store(store_key),

  -- Measures (numeric, aggregatable)
  quantity       INT NOT NULL,
  unit_price     DECIMAL(12,2) NOT NULL,
  discount       DECIMAL(12,2) DEFAULT 0,
  tax            DECIMAL(12,2) DEFAULT 0,
  total_amount   DECIMAL(12,2) NOT NULL,

  -- Audit
  etl_loaded_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for common query patterns
CREATE INDEX idx_fact_sales_date ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_key);
```

### Dimension Tables
```sql
-- ✅ Dimension table: Descriptive attributes
CREATE TABLE dim_date (
  date_key       INT PRIMARY KEY,      -- YYYYMMDD format
  full_date      DATE NOT NULL,
  day_of_week    VARCHAR(10),
  day_of_month   INT,
  month          INT,
  month_name     VARCHAR(10),
  quarter        INT,
  year           INT,
  is_weekend     BOOLEAN,
  is_holiday     BOOLEAN,
  fiscal_year    INT,
  fiscal_quarter INT
);

CREATE TABLE dim_product (
  product_key     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id      VARCHAR(50) NOT NULL,  -- Natural/business key
  name            VARCHAR(200),
  category        VARCHAR(100),
  subcategory     VARCHAR(100),
  brand           VARCHAR(100),
  unit_cost       DECIMAL(12,2),

  -- SCD Type 2 columns
  effective_from  DATE NOT NULL,
  effective_to    DATE DEFAULT '9999-12-31',
  is_current      BOOLEAN DEFAULT TRUE
);
```

---

## Slowly Changing Dimensions (SCD)

| Type | Strategy | Use When |
|------|----------|----------|
| **SCD 0** | No changes | Reference data (country codes) |
| **SCD 1** | Overwrite | No history needed (fix typos) |
| **SCD 2** | Add new row | Need full history (product price changes) |
| **SCD 3** | Add column | Track previous value only |
| **SCD 4** | Separate history table | Heavy change tracking |

```sql
-- SCD Type 2: Track history with effective dates
-- When product price changes:
UPDATE dim_product SET effective_to = CURRENT_DATE, is_current = FALSE
WHERE product_id = 'PROD-001' AND is_current = TRUE;

INSERT INTO dim_product (product_id, name, category, brand, unit_cost, effective_from)
VALUES ('PROD-001', 'Widget A', 'Electronics', 'BrandX', 150000, CURRENT_DATE);
```

---

## Modern Cloud Data Warehouses

| Platform | Best For | Key Feature |
|----------|----------|-------------|
| **BigQuery** (GCP) | Serverless analytics | Pay-per-query, ML built-in |
| **Snowflake** | Multi-cloud, data sharing | Separate compute & storage |
| **Redshift** (AWS) | AWS ecosystem | RA3 nodes, Spectrum for S3 |
| **Synapse** (Azure) | Azure ecosystem | Dedicated + serverless pools |
| **ClickHouse** | Real-time analytics | Column-oriented, fast inserts |
| **DuckDB** | Local/embedded analytics | In-process, Parquet native |

---

## Common Query Patterns

```sql
-- Monthly sales trend
SELECT d.year, d.month, d.month_name,
       SUM(f.total_amount) as revenue,
       COUNT(DISTINCT f.customer_key) as unique_customers
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2025
GROUP BY d.year, d.month, d.month_name
ORDER BY d.month;

-- Top products by region
SELECT p.category, s.region,
       SUM(f.total_amount) as revenue,
       RANK() OVER (PARTITION BY s.region ORDER BY SUM(f.total_amount) DESC) as rank
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY p.category, s.region;
```

## Best Practices
1. **Star schema** over snowflake for simplicity and performance
2. **Surrogate keys** in dimensions (not natural keys)
3. **Date dimension** pre-populated for 10+ years
4. **SCD Type 2** for dimensions that change and need history
5. **Incremental loads** — don't reload everything daily
6. **Aggregate tables** for frequently-run expensive queries
7. **Partition fact tables** by date for query performance
8. **Data quality checks** before loading into warehouse
