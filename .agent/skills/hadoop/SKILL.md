---
name: Hadoop
description: Skill for big data processing with Apache Hadoop ecosystem — covering HDFS, MapReduce, YARN, Hive, Spark on Hadoop, HBase, and cluster management.
---

# Hadoop Skill

## Overview
**Apache Hadoop** is an open-source framework for distributed storage and processing of large datasets across clusters. The modern Hadoop ecosystem includes HDFS (storage), YARN (resource management), and tools like Hive, Spark, and HBase.

---

## Hadoop Ecosystem

```
┌──────────────────────────────────────────────────────────────┐
│                   HADOOP ECOSYSTEM                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Processing: │ Spark │ MapReduce │ Tez │ Flink │             │
│  SQL:        │ Hive  │ Impala    │ Presto │ Trino │          │
│  NoSQL:      │ HBase │ Cassandra │                           │
│  Streaming:  │ Kafka │ Spark Streaming │ Storm │             │
│  Ingestion:  │ Sqoop │ Flume     │ NiFi  │                   │
│  Orchestration: │ Oozie │ Airflow │ Luigi │                  │
│  Resource:   │ YARN  │ Mesos     │ Kubernetes │              │
│  Storage:    │ HDFS  │ S3        │ Azure Blob │              │
│  Governance: │ Atlas │ Ranger    │                            │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## HDFS (Hadoop Distributed File System)

```bash
# Basic HDFS commands
hdfs dfs -ls /user/data/                    # List files
hdfs dfs -mkdir -p /user/data/raw/          # Create directory
hdfs dfs -put local_file.csv /user/data/raw/ # Upload file
hdfs dfs -get /user/data/output/ ./local/   # Download
hdfs dfs -cat /user/data/raw/sample.csv     # View file
hdfs dfs -rm -r /user/data/tmp/             # Remove directory
hdfs dfs -du -h /user/data/                 # Disk usage
hdfs dfs -chmod 750 /user/data/sensitive/   # Permissions

# File info
hdfs dfs -stat "%b %n %o %r" /user/data/file.parquet
# Size, Name, Block size, Replication factor
```

### HDFS Architecture
```
NameNode (Master): Manages filesystem metadata, stores file→block mapping
DataNode (Workers): Store actual data blocks (128MB default)
Replication: Each block replicated 3x across DataNodes

Write path: Client → NameNode → DataNode1 → DataNode2 → DataNode3
Read path:  Client → NameNode (get block locations) → Nearest DataNode
```

---

## Hive (SQL on Hadoop)

```sql
-- Create external table on HDFS data
CREATE EXTERNAL TABLE IF NOT EXISTS sales (
    transaction_id STRING,
    customer_id STRING,
    product_id STRING,
    amount DECIMAL(12, 2),
    quantity INT,
    transaction_date DATE
)
PARTITIONED BY (year INT, month INT)
STORED AS PARQUET
LOCATION '/user/data/silver/sales/';

-- Add partitions
MSCK REPAIR TABLE sales;  -- Auto-discover partitions

-- Query with partition pruning
SELECT product_id, SUM(amount) as total_revenue
FROM sales
WHERE year = 2025 AND month = 1
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 20;

-- Insert into partitioned table
INSERT INTO TABLE sales PARTITION (year=2025, month=2)
SELECT transaction_id, customer_id, product_id, amount, quantity, transaction_date
FROM staging_sales
WHERE transaction_date >= '2025-02-01' AND transaction_date < '2025-03-01';
```

---

## Spark on Hadoop

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("SalesAnalytics") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .enableHiveSupport() \
    .getOrCreate()

# Read from HDFS
df = spark.read.parquet("hdfs:///user/data/silver/sales/")

# Transformations
from pyspark.sql.functions import col, sum, count, avg, window

daily_summary = df \
    .groupBy("transaction_date", "product_id") \
    .agg(
        sum("amount").alias("total_revenue"),
        count("transaction_id").alias("order_count"),
        avg("amount").alias("avg_order_value"),
    ) \
    .orderBy(col("total_revenue").desc())

# Write to HDFS
daily_summary.write \
    .partitionBy("year", "month") \
    .mode("overwrite") \
    .parquet("hdfs:///user/data/gold/daily_sales_summary/")

# Write to Hive table
daily_summary.write.saveAsTable("gold.daily_sales_summary", mode="overwrite")
```

---

## HBase (NoSQL on Hadoop)

```
Use cases: Real-time reads/writes on Hadoop data
Schema design: Row key design is CRITICAL

Row key design tips:
  ✅ Distribute evenly (avoid hotspotting)
  ✅ Include most-queried field first
  ✅ Reverse timestamps for recent-first queries
  ❌ Don't use sequential IDs (hotspot on one region)
```

---

## Modern Alternatives

| Hadoop Component | Modern Alternative | Why |
|-----------------|-------------------|-----|
| HDFS | S3/GCS/ADLS | Cheaper, managed, elastic |
| MapReduce | Spark, Flink | Faster, easier API |
| Hive | BigQuery, Snowflake, Trino | Serverless, faster |
| YARN | Kubernetes | Container-native, universal |
| HBase | DynamoDB, Cassandra | Managed, easier ops |
| Sqoop | Debezium, Airbyte | CDC, real-time, modern |

> **Note:** Many organizations are migrating from on-premise Hadoop to cloud data lakes (S3 + Spark/Databricks + Delta Lake). Consider cloud-native alternatives for new projects.

## Best Practices
1. **Partition wisely** — Hive partitions should have 100MB-1GB per partition
2. **Columnar format** — use Parquet or ORC, never CSV for analytics
3. **Compress** — Snappy for speed, GZIP for size
4. **Avoid small files** — combine small files (CombineFileInputFormat)
5. **Spark over MapReduce** — Spark is 10-100x faster
6. **Monitor cluster health** — Ambari, Cloudera Manager, Ganglia
