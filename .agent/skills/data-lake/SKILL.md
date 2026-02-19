---
name: Data Lake
description: Skill for designing and implementing Data Lake architectures — covering medallion architecture (Bronze/Silver/Gold), partitioning, file formats (Parquet, Delta, Iceberg), data governance, and cloud implementations.
---

# Data Lake Skill

## Overview
A **Data Lake** stores raw, unstructured, and semi-structured data at any scale. Unlike a data warehouse (structured, schema-on-write), a data lake uses **schema-on-read** — data is stored as-is and structured when queried.

---

## Medallion Architecture (Bronze → Silver → Gold)

```
┌──────────────────────────────────────────────────────────────┐
│                    DATA LAKE LAYERS                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   BRONZE    │→ │   SILVER    │→ │    GOLD     │          │
│  │  (Raw/Land) │  │ (Cleansed)  │  │ (Business)  │          │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤          │
│  │ Raw ingestion│  │ Deduplicated│  │ Aggregated  │          │
│  │ As-is from  │  │ Validated   │  │ Business    │          │
│  │ source      │  │ Standardized│  │ ready       │          │
│  │ Append-only │  │ Conformed   │  │ Optimized   │          │
│  │ Immutable   │  │ Enriched    │  │ for queries │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
│                                                              │
│  Format: JSON,CSV  Format: Parquet  Format: Parquet/Delta    │
│  Schema: None       Schema: Inferred Schema: Enforced        │
│  Quality: Raw       Quality: Clean   Quality: Business-ready │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
data-lake/
├── bronze/                          # Raw data (landing zone)
│   ├── transactions/
│   │   ├── year=2025/month=01/day=15/
│   │   │   ├── batch_001.json
│   │   │   └── batch_002.json
│   │   └── year=2025/month=01/day=16/
│   ├── user_events/
│   │   └── year=2025/month=01/
│   └── external_apis/
│       └── exchange_rates/
├── silver/                          # Cleansed & conformed
│   ├── transactions/
│   │   └── year=2025/month=01/
│   │       └── part-00000.parquet
│   ├── users/
│   └── products/
├── gold/                            # Business aggregates
│   ├── daily_sales_summary/
│   ├── customer_360/
│   ├── product_performance/
│   └── revenue_by_region/
└── _metadata/
    ├── schemas/                     # Schema definitions
    ├── lineage/                     # Data lineage tracking
    └── quality/                     # Quality check results
```

---

## File Formats

| Format | Use Case | Pros | Cons |
|--------|----------|------|------|
| **JSON/CSV** | Bronze (raw ingestion) | Human-readable, universal | Slow queries, no schema |
| **Parquet** | Silver/Gold (analytics) | Columnar, compressed, fast | Not human-readable |
| **Delta Lake** | All layers (Databricks) | ACID transactions, time travel | Requires Delta runtime |
| **Apache Iceberg** | All layers (open) | Schema evolution, partition evolution | Newer ecosystem |
| **ORC** | Hive ecosystem | Good compression, fast reads | Less universal than Parquet |

---

## Partitioning Strategy

```python
# ✅ Partition by common query dimensions
# Time-based (most common)
s3://data-lake/silver/transactions/year=2025/month=01/day=15/

# Category-based
s3://data-lake/gold/sales/region=java/category=electronics/

# Rules:
# 1. Partition on frequently filtered columns
# 2. Avoid too many partitions (>10K = overhead)
# 3. Avoid too few partitions (1 partition = no benefit)
# 4. Target 100MB-1GB per partition file
# 5. Use Hive-style partitioning: key=value/
```

---

## Cloud Implementations

### AWS (S3 + Glue + Athena)
```
Storage:    Amazon S3
Catalog:    AWS Glue Data Catalog
Query:      Amazon Athena (serverless SQL)
ETL:        AWS Glue (Spark-based)
Governance: AWS Lake Formation
```

### GCP (GCS + BigQuery)
```
Storage:    Google Cloud Storage
Catalog:    BigQuery + Data Catalog
Query:      BigQuery (serverless)
ETL:        Dataflow / Dataproc
Governance: Dataplex
```

### Azure (ADLS + Synapse)
```
Storage:    Azure Data Lake Storage Gen2
Catalog:    Azure Purview
Query:      Azure Synapse Analytics
ETL:        Azure Data Factory
Governance: Microsoft Purview
```

---

## Data Quality Checks

```python
# ✅ Quality checks at each layer transition
class DataQualityCheck:
    def check_bronze_to_silver(self, df):
        """Validate before promoting to Silver"""
        checks = {
            'no_nulls_in_keys': df[self.key_columns].notna().all().all(),
            'valid_dates': pd.to_datetime(df['created_at'], errors='coerce').notna().all(),
            'no_duplicates': not df.duplicated(subset=self.key_columns).any(),
            'row_count_reasonable': len(df) > 0 and len(df) < 10_000_000,
            'schema_matches': set(df.columns) == set(self.expected_columns),
        }
        
        failed = [k for k, v in checks.items() if not v]
        if failed:
            raise DataQualityError(f"Quality checks failed: {failed}")
        
        return True
```

---

## Data Governance

```
1. Data Catalog     → Register all datasets with metadata
2. Data Lineage     → Track data flow from source to gold
3. Access Control   → RBAC on lake zones (who can read bronze? gold?)
4. Data Quality     → Automated checks at each layer
5. Retention Policy → Auto-archive/delete per policy
6. PII Management   → Tag PII fields, encrypt, mask
7. Audit Trail      → Log all data access and transformations
```

## Best Practices
1. **Immutable bronze** — never modify raw data, append-only
2. **Parquet for analytics** — columnar format for fast queries
3. **Partition wisely** — by date is almost always correct
4. **Schema evolution** — use Delta/Iceberg for schema changes
5. **Separate compute from storage** — scale independently
6. **Data quality gates** — validate before promoting layers
7. **Metadata first** — catalog everything before it becomes a data swamp
