---
name: Data Lake
description: Skill for designing and implementing Data Lake architectures — covering medallion architecture (Bronze/Silver/Gold), partitioning, file formats (Parquet, Delta, Iceberg), data governance, and cloud implementations.
---

# Data Lake Skill

## Overview
A data lake stores raw, semi-structured, and structured data at scale. The medallion architecture (Bronze/Silver/Gold) organizes data by quality level. Modern data lakes use Parquet/Delta Lake/Iceberg formats for efficient storage and querying.

**References**:
- [Delta Lake](https://delta.io/)
- [Apache Iceberg](https://iceberg.apache.org/)
- [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)

---

## Medallion Architecture

```
Bronze (Raw)         → Silver (Cleaned)         → Gold (Business-Ready)
─────────────────    ─────────────────────────    ────────────────────────
Raw ingested data    Deduplicated, validated      Aggregated, enriched
JSON, CSV, logs      Typed columns, normalized    Business metrics
Append-only          Schema enforcement           Star schema / KPIs
Full fidelity        Data quality rules           Dashboard-ready
```

---

## Data Pipeline (Python)

```python
# Bronze: Ingest raw data
def ingest_bronze(source_path: str, bronze_path: str):
    df = spark.read.json(source_path)
    df = df.withColumn("_ingested_at", current_timestamp())
    df = df.withColumn("_source_file", input_file_name())
    df.write.mode("append").partitionBy("_ingested_date").parquet(bronze_path)

# Silver: Clean and validate
def process_silver(bronze_path: str, silver_path: str):
    df = spark.read.parquet(bronze_path)
    df = df.dropDuplicates(["id"])
    df = df.filter(col("email").rlike("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$"))
    df = df.withColumn("price", col("price").cast("decimal(10,2)"))
    df = df.withColumn("_processed_at", current_timestamp())
    df.write.mode("overwrite").partitionBy("category").parquet(silver_path)

# Gold: Business aggregations
def build_gold_metrics(silver_path: str, gold_path: str):
    df = spark.read.parquet(silver_path)
    monthly = df.groupBy(year("created_at").alias("year"), month("created_at").alias("month")).agg(
        count("id").alias("total_orders"), sum("total").alias("revenue"), avg("total").alias("avg_order_value")
    )
    monthly.write.mode("overwrite").parquet(f"{gold_path}/monthly_revenue")
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Medallion** | Bronze (raw) → Silver (clean) → Gold (business) |
| **Parquet** | Columnar format for analytics |
| **Partitioning** | Partition by date, category |
| **Schema evolution** | Delta Lake for schema changes |
| **Data quality** | Validate at Silver layer |
| **Deduplication** | Remove duplicates at Silver |
| **Lineage** | Track data transformations |
| **Governance** | Catalog, access control, encryption |
| **Retention** | Archive/delete old Bronze data |
| **Incremental** | Process only new data |

---

## Rules Integration
- **Architecture**: Medallion (Bronze/Silver/Gold)
- **Pipeline**: Ingest → clean → aggregate
- **Format**: Parquet for columnar storage
- **Quality**: Validation and deduplication at Silver
