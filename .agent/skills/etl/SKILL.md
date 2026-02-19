---
name: ETL (Extract-Transform-Load)
description: Skill for building ETL/ELT data pipelines — covering extraction patterns, transformation logic, loading strategies, orchestration (Airflow, Prefect), data quality, and error handling.
---

# ETL (Extract-Transform-Load) Skill

## Overview
**ETL** extracts data from sources, transforms it, then loads into a target. **ELT** loads raw data first, then transforms in the warehouse. Modern data stacks prefer ELT with cloud warehouses.

```
ETL: Source → Extract → Transform → Load → Warehouse
ELT: Source → Extract → Load (raw) → Transform (in warehouse)
```

---

## ETL vs ELT

| Aspect | ETL | ELT |
|--------|-----|-----|
| Transform location | Pipeline (external) | In the warehouse |
| Best for | On-premise, complex transforms | Cloud warehouses |
| Tools | Airflow + Python/Spark | dbt + BigQuery/Snowflake |
| Scalability | Limited by pipeline compute | Scales with warehouse |

---

## Extract Patterns

```python
# 1. Full Extract (small/reference tables)
def extract_full(source_table: str) -> pd.DataFrame:
    return pd.read_sql(f"SELECT * FROM {source_table}", source_conn)

# 2. Incremental Extract (large transactional tables)
def extract_incremental(table: str, last_extracted: datetime) -> pd.DataFrame:
    query = f"""
        SELECT * FROM {table}
        WHERE updated_at > %(last_extracted)s
        ORDER BY updated_at
    """
    return pd.read_sql(query, source_conn, params={'last_extracted': last_extracted})

# 3. CDC — Change Data Capture (real-time)
# Use Debezium, AWS DMS, or database triggers
# Captures INSERT, UPDATE, DELETE events from transaction log

# 4. API Extract
import requests

def extract_from_api(endpoint: str, params: dict) -> list[dict]:
    all_data = []
    page = 1
    while True:
        response = requests.get(endpoint, params={**params, 'page': page})
        data = response.json()
        if not data['results']:
            break
        all_data.extend(data['results'])
        page += 1
    return all_data
```

---

## Transform Patterns

```python
import pandas as pd

def transform_sales(raw_df: pd.DataFrame) -> pd.DataFrame:
    df = raw_df.copy()
    
    # 1. Data type casting
    df['created_at'] = pd.to_datetime(df['created_at'])
    df['amount'] = pd.to_numeric(df['amount'], errors='coerce')
    
    # 2. Null handling
    df['category'] = df['category'].fillna('Uncategorized')
    df = df.dropna(subset=['customer_id', 'amount'])  # Required fields
    
    # 3. Deduplication
    df = df.drop_duplicates(subset=['transaction_id'], keep='last')
    
    # 4. Standardization
    df['email'] = df['email'].str.lower().str.strip()
    df['phone'] = df['phone'].str.replace(r'\D', '', regex=True)
    
    # 5. Derived columns
    df['date_key'] = df['created_at'].dt.strftime('%Y%m%d').astype(int)
    df['is_weekend'] = df['created_at'].dt.dayofweek >= 5
    df['amount_category'] = pd.cut(df['amount'], bins=[0, 100000, 500000, float('inf')],
                                    labels=['small', 'medium', 'large'])
    
    # 6. Business rules
    df['net_amount'] = df['amount'] - df['discount'] + df['tax']
    
    # 7. PII handling (mask or encrypt)
    df['email_masked'] = df['email'].apply(lambda x: x[0] + '***@' + x.split('@')[1] if '@' in str(x) else '***')
    
    return df
```

---

## Load Strategies

```python
# 1. Full Load (truncate + insert)
def load_full(df: pd.DataFrame, table: str):
    with engine.connect() as conn:
        conn.execute(f"TRUNCATE TABLE {table}")
        df.to_sql(table, conn, if_exists='append', index=False)

# 2. Incremental/Upsert (merge)
def load_upsert(df: pd.DataFrame, table: str, key_columns: list[str]):
    """Upsert: INSERT new rows, UPDATE existing rows"""
    temp_table = f"stg_{table}"
    df.to_sql(temp_table, engine, if_exists='replace', index=False)
    
    key_match = ' AND '.join([f"t.{k} = s.{k}" for k in key_columns])
    update_cols = [c for c in df.columns if c not in key_columns]
    update_set = ', '.join([f"{c} = s.{c}" for c in update_cols])
    insert_cols = ', '.join(df.columns)
    insert_vals = ', '.join([f"s.{c}" for c in df.columns])
    
    merge_sql = f"""
        MERGE INTO {table} t
        USING {temp_table} s ON {key_match}
        WHEN MATCHED THEN UPDATE SET {update_set}
        WHEN NOT MATCHED THEN INSERT ({insert_cols}) VALUES ({insert_vals})
    """
    with engine.connect() as conn:
        conn.execute(merge_sql)
        conn.execute(f"DROP TABLE IF EXISTS {temp_table}")

# 3. Append-only (event/log data)
def load_append(df: pd.DataFrame, table: str):
    df.to_sql(table, engine, if_exists='append', index=False)
```

---

## Orchestration with Airflow

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'email_on_failure': True,
    'email': ['data-team@company.co.id'],
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='etl_daily_sales',
    default_args=default_args,
    description='Daily sales ETL pipeline',
    schedule_interval='0 2 * * *',  # 2 AM daily
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['etl', 'sales'],
) as dag:

    extract = PythonOperator(
        task_id='extract_sales',
        python_callable=extract_incremental,
        op_kwargs={'table': 'orders', 'last_extracted': '{{ prev_ds }}'},
    )
    
    transform = PythonOperator(
        task_id='transform_sales',
        python_callable=transform_sales,
    )
    
    load = PythonOperator(
        task_id='load_to_warehouse',
        python_callable=load_upsert,
        op_kwargs={'table': 'fact_sales', 'key_columns': ['order_id']},
    )
    
    quality = PythonOperator(
        task_id='quality_check',
        python_callable=run_quality_checks,
    )

    extract >> transform >> load >> quality
```

---

## Data Quality Framework

```python
class DataQualityChecker:
    def __init__(self, df: pd.DataFrame):
        self.df = df
        self.results: list[dict] = []

    def check_not_null(self, columns: list[str]):
        for col in columns:
            nulls = self.df[col].isna().sum()
            self.results.append({
                'check': f'not_null_{col}', 'passed': nulls == 0,
                'detail': f'{nulls} null values found'
            })
        return self

    def check_unique(self, columns: list[str]):
        dupes = self.df.duplicated(subset=columns).sum()
        self.results.append({
            'check': f'unique_{"_".join(columns)}', 'passed': dupes == 0,
            'detail': f'{dupes} duplicates found'
        })
        return self

    def check_row_count(self, min_rows: int, max_rows: int):
        count = len(self.df)
        self.results.append({
            'check': 'row_count', 'passed': min_rows <= count <= max_rows,
            'detail': f'{count} rows (expected {min_rows}-{max_rows})'
        })
        return self

    def validate(self) -> bool:
        failed = [r for r in self.results if not r['passed']]
        if failed:
            raise DataQualityError(f"Failed checks: {failed}")
        return True
```

## Best Practices
1. **Idempotent pipelines** — re-running produces same result
2. **Incremental processing** — extract only what changed
3. **Data quality gates** — validate before loading
4. **Retry with backoff** — transient failures are normal
5. **Audit trail** — log every pipeline run (rows processed, duration, errors)
6. **Separate staging** — load to staging tables first, then promote
7. **Monitor pipeline SLAs** — alert if pipeline misses deadline
8. **Test with production-like data** — unit test transformations
