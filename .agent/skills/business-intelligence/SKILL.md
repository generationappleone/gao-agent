---
name: Business Intelligence
description: Skill for business intelligence solutions — covering BI architecture, KPI dashboards, reporting, data modeling for BI tools (Metabase, Superset, Power BI, Tableau, Looker), and self-service analytics.
---

# Business Intelligence Skill

## Overview
**Business Intelligence (BI)** transforms raw data into actionable insights through dashboards, reports, and visualizations. This skill covers BI tool selection, KPI design, and building self-service analytics platforms.

---

## BI Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    BI ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Data Sources → ETL/ELT → Data Warehouse → BI Tool → Users │
│                                                             │
│  ┌─────────┐  ┌─────┐  ┌──────────┐  ┌───────┐  ┌──────┐  │
│  │Databases│→ │ ETL │→ │  DWH     │→ │  BI   │→ │Users │  │
│  │APIs     │  │Airflow│ │Star     │  │Metabase│ │Report│  │
│  │Files    │  │dbt   │ │Schema   │  │PowerBI│  │Alerts│  │
│  │Streams  │  │      │ │Parquet  │  │Superset│ │     │  │
│  └─────────┘  └─────┘  └──────────┘  └───────┘  └──────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## BI Tool Comparison

| Tool | Type | Best For | Cost |
|------|------|----------|------|
| **Metabase** | Open-source | Startups, self-hosted, SQL-friendly | Free (OSS) |
| **Apache Superset** | Open-source | Data teams, SQL-heavy, scalable | Free (OSS) |
| **Power BI** | Commercial | Microsoft ecosystem, enterprise | $10/user/mo |
| **Tableau** | Commercial | Visual analytics, complex dashboards | $70/user/mo |
| **Looker** | Commercial (GCP) | LookML modeling, governed analytics | Enterprise pricing |
| **Google Data Studio** | Free | Simple dashboards, Google ecosystem | Free |
| **Redash** | Open-source | SQL-focused, quick dashboards | Free (OSS) |

---

## KPI Dashboard Design

### KPI Categories
```markdown
## Executive Dashboard KPIs

### Revenue & Growth
| KPI | Formula | Target | Frequency |
|-----|---------|--------|-----------|
| Revenue | SUM(sales) | ↑ 15% YoY | Daily |
| MRR | SUM(active_subscriptions × price) | ↑ 10% MoM | Monthly |
| ARPU | Revenue / Active Users | > Rp 50K | Monthly |
| Revenue Growth Rate | (Current - Previous) / Previous × 100 | > 15% | Monthly |

### Customer
| KPI | Formula | Target | Frequency |
|-----|---------|--------|-----------|
| CAC | Marketing Spend / New Customers | < Rp 100K | Monthly |
| LTV | ARPU × Avg Lifetime (months) | > 3× CAC | Quarterly |
| Churn Rate | Lost Customers / Start Customers × 100 | < 5% | Monthly |
| NPS | Promoters% - Detractors% | > 50 | Quarterly |

### Operations
| KPI | Formula | Target | Frequency |
|-----|---------|--------|-----------|
| Uptime | Available Time / Total Time × 100 | > 99.9% | Daily |
| Response Time (P95) | 95th percentile latency | < 500ms | Real-time |
| Error Rate | Errors / Total Requests × 100 | < 0.1% | Real-time |
| Deploy Frequency | Deploys per week | > 5 | Weekly |
```

---

## SQL Patterns for BI

```sql
-- Daily Active Users (DAU)
SELECT DATE(event_time) as date,
       COUNT(DISTINCT user_id) as dau
FROM user_events
WHERE event_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(event_time)
ORDER BY date;

-- Cohort Retention Analysis
WITH cohorts AS (
  SELECT user_id,
         DATE_TRUNC('month', first_login) as cohort_month,
         DATE_TRUNC('month', event_date) as activity_month
  FROM user_activity
),
cohort_sizes AS (
  SELECT cohort_month, COUNT(DISTINCT user_id) as cohort_size
  FROM cohorts GROUP BY cohort_month
)
SELECT c.cohort_month,
       EXTRACT(MONTH FROM AGE(c.activity_month, c.cohort_month)) as months_since,
       COUNT(DISTINCT c.user_id)::FLOAT / cs.cohort_size as retention_rate
FROM cohorts c
JOIN cohort_sizes cs ON c.cohort_month = cs.cohort_month
GROUP BY c.cohort_month, months_since, cs.cohort_size
ORDER BY c.cohort_month, months_since;

-- Funnel Analysis
SELECT step,
       users,
       LAG(users) OVER (ORDER BY step_order) as prev_step_users,
       ROUND(users::NUMERIC / FIRST_VALUE(users) OVER (ORDER BY step_order) * 100, 1) as overall_rate,
       ROUND(users::NUMERIC / LAG(users) OVER (ORDER BY step_order) * 100, 1) as step_rate
FROM (
  SELECT 1 as step_order, 'Visit Homepage' as step, COUNT(DISTINCT user_id) as users FROM events WHERE event = 'page_view'
  UNION ALL
  SELECT 2, 'View Product', COUNT(DISTINCT user_id) FROM events WHERE event = 'product_view'
  UNION ALL
  SELECT 3, 'Add to Cart', COUNT(DISTINCT user_id) FROM events WHERE event = 'add_to_cart'
  UNION ALL
  SELECT 4, 'Checkout', COUNT(DISTINCT user_id) FROM events WHERE event = 'checkout'
  UNION ALL
  SELECT 5, 'Purchase', COUNT(DISTINCT user_id) FROM events WHERE event = 'purchase'
) funnel ORDER BY step_order;
```

---

## Semantic Layer / Metrics Layer

```yaml
# metrics.yml (dbt Metrics / Cube.js / LookML equivalent)
metrics:
  - name: total_revenue
    label: "Total Revenue"
    description: "Sum of all completed order amounts"
    type: sum
    sql: total_amount
    timestamp: created_at
    time_grains: [day, week, month, quarter, year]
    filters:
      - field: status
        operator: "="
        value: "completed"
    dimensions:
      - product_category
      - customer_segment
      - region
```

## Best Practices
1. **Single source of truth** — one data warehouse, one metric definition
2. **Dashboard hierarchy** — Executive → Department → Operational
3. **Max 7 KPIs per dashboard** — focus on what matters
4. **Self-service with guardrails** — let users explore, but govern definitions
5. **Refresh frequency matches decision cadence** — real-time isn't always needed
6. **Mobile-friendly dashboards** — executives check on phones
7. **Alert on anomalies** — proactive, not reactive
