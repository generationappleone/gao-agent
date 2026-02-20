---
name: Data Warehouse
description: Skill for designing Data Warehouse solutions — covering dimensional modeling (star/snowflake schema), fact/dimension tables, slowly changing dimensions, ETL pipelines, and modern cloud data warehouses.
---

# Data Warehouse Skill

## Overview
A data warehouse is an optimized analytical database using dimensional modeling (star/snowflake schema) with fact and dimension tables. It supports business intelligence, reporting, and analytics via SQL. Modern cloud warehouses include Snowflake, BigQuery, and Redshift.

**References**:
- [Kimball Dimensional Modeling](https://www.kimballgroup.com/)
- [Snowflake](https://docs.snowflake.com/)

---

## Star Schema

```sql
-- Dimension: Customers
CREATE TABLE dim_customers (
    customer_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(36) NOT NULL,
    name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    segment VARCHAR(50),  -- Enterprise, SMB, Consumer
    effective_date DATE,
    expiry_date DATE DEFAULT '9999-12-31',
    is_current BOOLEAN DEFAULT TRUE
);

-- Dimension: Products
CREATE TABLE dim_products (
    product_key INT PRIMARY KEY AUTO_INCREMENT,
    product_id VARCHAR(36),
    name VARCHAR(200),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    unit_price DECIMAL(10,2)
);

-- Dimension: Date
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,  -- YYYYMMDD
    full_date DATE,
    day_of_week VARCHAR(10),
    month_name VARCHAR(10),
    quarter INT,
    year INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN
);

-- Fact: Sales
CREATE TABLE fact_sales (
    sale_key BIGINT PRIMARY KEY AUTO_INCREMENT,
    date_key INT REFERENCES dim_date(date_key),
    customer_key INT REFERENCES dim_customers(customer_key),
    product_key INT REFERENCES dim_products(product_key),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    total_amount DECIMAL(12,2),
    tax_amount DECIMAL(10,2),
    order_id VARCHAR(36)
);

CREATE INDEX idx_fact_sales_date ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_key);
```

---

## Analytical Queries

```sql
-- Monthly revenue with YoY comparison
SELECT d.year, d.month_name,
    SUM(f.total_amount) AS revenue,
    LAG(SUM(f.total_amount)) OVER (ORDER BY d.year, MONTH(d.full_date)) AS prev_month,
    ROUND((SUM(f.total_amount) - LAG(SUM(f.total_amount)) OVER (ORDER BY d.year, MONTH(d.full_date))) / LAG(SUM(f.total_amount)) OVER (ORDER BY d.year, MONTH(d.full_date)) * 100, 1) AS growth_pct
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY d.year, d.month_name, MONTH(d.full_date)
ORDER BY d.year DESC, MONTH(d.full_date) DESC;

-- Top customers by revenue
SELECT c.name, c.segment, SUM(f.total_amount) AS total_revenue, COUNT(DISTINCT f.order_id) AS orders
FROM fact_sales f JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.customer_key ORDER BY total_revenue DESC LIMIT 20;
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Star schema** | Fact tables surrounded by dimensions |
| **Surrogate keys** | Auto-increment keys, not business keys |
| **SCD Type 2** | Track dimension history with dates |
| **Date dimension** | Pre-populated date lookup table |
| **Grain** | Define lowest level of detail per fact |
| **Indexes** | Index foreign keys in fact tables |
| **Aggregations** | Pre-aggregate for common queries |
| **Partitioning** | Partition facts by date |
| **ETL** | Scheduled data loading from sources |
| **Quality** | Data validation and reconciliation |

---

## Rules Integration
- **Schema**: Star schema with fact and dimension tables
- **SCD**: Slowly Changing Dimensions for history
- **Queries**: Analytical SQL with window functions
- **ETL**: Scheduled pipeline from operational sources
