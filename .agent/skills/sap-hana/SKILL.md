---
name: SAP HANA
description: Skill for developing with SAP HANA database, covering schema design, CDS views, SQLScript, calculation views, performance optimization, and integration patterns.
---

# SAP HANA Skill

## Overview
SAP HANA is an in-memory, column-oriented relational database. Use this skill for enterprise applications requiring real-time analytics, high-performance OLAP/OLTP workloads, and SAP ecosystem integration.

## Setup & Connection
```bash
# Docker (SAP HANA Express)
docker run -d --name hana -p 39017:39017 -p 39041:39041 \
  -e AGREE_TO_SAP_LICENSE=Y \
  store/saplabs/hanaexpress:2.00.072.00.20231123.1

# Connection (JDBC)
jdbc:sap://localhost:39017/?databaseName=HXE&encrypt=true

# Node.js (@sap/hana-client)
const conn = hana.createConnection();
conn.connect({ host: 'localhost', port: 39017, uid: 'SYSTEM', pwd: 'secret' });
```

## Schema Design
```sql
-- SAP HANA: UUID with NVARCHAR(36) or VARBINARY(16)
CREATE SCHEMA MY_APP;

CREATE COLUMN TABLE MY_APP.USERS (
    ID NVARCHAR(36) PRIMARY KEY DEFAULT SYSUUID,
    EMAIL NVARCHAR(255) NOT NULL,
    PASSWORD_HASH NVARCHAR(255) NOT NULL,
    FIRST_NAME NVARCHAR(100) NOT NULL,
    LAST_NAME NVARCHAR(100) NOT NULL,
    IS_ACTIVE BOOLEAN NOT NULL DEFAULT TRUE,
    CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DELETED_AT TIMESTAMP DEFAULT NULL,
    UNIQUE (EMAIL)
);

-- Column table (default) for analytics, row table for transactional
CREATE ROW TABLE MY_APP.SESSIONS (
    ID NVARCHAR(36) PRIMARY KEY DEFAULT SYSUUID,
    USER_ID NVARCHAR(36) NOT NULL REFERENCES MY_APP.USERS(ID),
    TOKEN NVARCHAR(500) NOT NULL,
    EXPIRES_AT TIMESTAMP NOT NULL,
    CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

## SQLScript (Stored Procedures)
```sql
CREATE PROCEDURE MY_APP.GET_USER_ORDERS(
    IN iv_user_id NVARCHAR(36),
    OUT et_result TABLE (
        ORDER_ID NVARCHAR(36),
        TOTAL_AMOUNT DECIMAL(12, 2),
        STATUS NVARCHAR(20),
        CREATED_AT TIMESTAMP
    )
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
READS SQL DATA
AS
BEGIN
    et_result = SELECT
        o.ID AS ORDER_ID,
        o.TOTAL_AMOUNT,
        o.STATUS,
        o.CREATED_AT
    FROM MY_APP.ORDERS o
    WHERE o.USER_ID = :iv_user_id
      AND o.DELETED_AT IS NULL
    ORDER BY o.CREATED_AT DESC;
END;
```

## CDS Views (Core Data Services)
```sql
-- CDS for reusable data models
@AbapCatalog.sqlViewName: 'ZV_ORDERS'
@Analytics.dataCategory: #CUBE
define view Z_ORDERS_ANALYTICS as select from MY_APP.ORDERS {
    key ID,
    USER_ID,
    @Semantics.amount.currencyCode: 'CURRENCY'
    TOTAL_AMOUNT,
    CURRENCY,
    STATUS,
    @Semantics.calendar.yearMonth: true
    LEFT(CAST(CREATED_AT AS NVARCHAR(7)), 7) as ORDER_MONTH,
    1 as ORDER_COUNT
}
```

## Performance Best Practices
- Use **COLUMN tables** for analytics/reporting (default)
- Use **ROW tables** for high-frequency transactional workloads
- Leverage **in-memory computing** — avoid unnecessary disk persistence
- Use `PARTITION BY` for large tables (hash, range, round-robin)
- Prefer SQL over SQLScript for simple queries (optimizer works better)
- Use `WITH HINT(NO_CS_JOIN)` sparingly for join optimization

## Key Differences
| Feature | SAP HANA | PostgreSQL |
|---------|----------|------------|
| Storage | In-memory (columnar) | Disk-based (row) |
| UUID | `SYSUUID` / `NVARCHAR(36)` | `gen_random_uuid()` / `UUID` |
| Stored procs | SQLScript | PL/pgSQL |
| Partitioning | Hash, Range, Round-Robin | Range, List, Hash |
| Full-text search | Built-in | `pg_trgm` extension |

## Rules Integration
- **Database**: UUID via `SYSUUID`, UPPER_SNAKE_CASE for tables/columns, audit columns
- **Security**: SQL SECURITY INVOKER, parameterized queries, schema-level access control
