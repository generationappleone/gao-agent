---
name: ETL (Extract-Transform-Load)
description: Skill for building ETL/ELT data pipelines — covering extraction patterns, transformation logic, loading strategies, orchestration (Airflow, Prefect), data quality, and error handling.
---

# ETL Skill

## Overview
ETL (Extract-Transform-Load) moves data from source systems to target databases/warehouses. Modern ELT loads raw data first, then transforms in the warehouse. Orchestration tools (Airflow, Prefect) manage pipeline scheduling and dependencies.

**References**:
- [Apache Airflow](https://airflow.apache.org/)
- [Prefect](https://docs.prefect.io/)

---

## Node.js ETL Pipeline

```typescript
// Extract
async function extractFromAPI(endpoint: string, params: Record<string, any>) {
  const records: any[] = [];
  let page = 1;
  while (true) {
    const res = await fetch(`${endpoint}?${new URLSearchParams({ ...params, page: String(page) })}`);
    const data = await res.json();
    if (data.data.length === 0) break;
    records.push(...data.data);
    page++;
  }
  return records;
}

// Transform
function transformRecords(records: any[]) {
  return records
    .filter(r => r.status === 'active' && r.email)
    .map(r => ({
      id: r.id,
      name: r.name.trim(),
      email: r.email.toLowerCase(),
      revenue: Math.round(r.total_spent * 100), // dollars to cents
      segment: r.total_spent > 10000 ? 'enterprise' : r.total_spent > 1000 ? 'smb' : 'consumer',
      createdAt: new Date(r.created_at),
    }))
    .filter((r, i, arr) => arr.findIndex(a => a.email === r.email) === i); // dedupe
}

// Load
async function loadToWarehouse(records: any[]) {
  const batchSize = 1000;
  for (let i = 0; i < records.length; i += batchSize) {
    const batch = records.slice(i, i + batchSize);
    await db.$executeRaw`
      INSERT INTO dim_customers (customer_id, name, email, segment, effective_date)
      VALUES ${Prisma.join(batch.map(r => Prisma.sql`(${r.id}, ${r.name}, ${r.email}, ${r.segment}, CURRENT_DATE)`))}
      ON CONFLICT (customer_id) DO UPDATE SET name = EXCLUDED.name, email = EXCLUDED.email, segment = EXCLUDED.segment
    `;
  }
}

// Orchestrate
async function runETL() {
  console.log('ETL started');
  const records = await extractFromAPI('https://api.source.com/customers', { per_page: 100 });
  console.log(`Extracted ${records.length} records`);
  const transformed = transformRecords(records);
  console.log(`Transformed ${transformed.length} records`);
  await loadToWarehouse(transformed);
  console.log('ETL completed');
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Idempotent** | Safe to re-run without duplicates |
| **Batching** | Process in batches for memory efficiency |
| **Deduplication** | Remove duplicates in Transform |
| **Upsert** | INSERT ON CONFLICT for incremental loads |
| **Validation** | Validate data quality in Transform |
| **Logging** | Log counts at each stage |
| **Error handling** | Retry failed batches, dead-letter queue |
| **Scheduling** | Cron or Airflow for automation |
| **Incremental** | Process only new/changed records |
| **Monitoring** | Alert on failures or data anomalies |

---

## Rules Integration
- **Extract**: Paginated API fetching
- **Transform**: Filter, clean, deduplicate, enrich
- **Load**: Batch upsert to warehouse
- **Orchestration**: Scheduled pipelines with monitoring
