---
name: Oracle Database
description: Skill for developing with Oracle Database, covering schema design, PL/SQL, partitioning, performance tuning, and enterprise patterns.
---

# Oracle Database Skill

## Overview
Oracle Database is an enterprise-grade relational database. Use this skill for mission-critical applications requiring high availability, advanced partitioning, and PL/SQL stored procedures.

## Setup & Connection
```bash
# Docker (Oracle XE)
docker run -d --name oracle -p 1521:1521 -e ORACLE_PASSWORD=secret container-registry.oracle.com/database/express:21.3.0-xe

# Connection string (JDBC)
jdbc:oracle:thin:@localhost:1521/XEPDB1

# Node.js (oracledb)
const conn = await oracledb.getConnection({
  user: 'myuser', password: 'secret', connectString: 'localhost:1521/XEPDB1'
});
```

## Schema Design
```sql
-- Oracle: UUID with RAW(16) or VARCHAR2(36)
CREATE TABLE users (
    id RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    email VARCHAR2(255) NOT NULL,
    password_hash VARCHAR2(255) NOT NULL,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    is_active NUMBER(1) DEFAULT 1 NOT NULL CHECK (is_active IN (0, 1)),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE INDEX idx_users_email ON users (email) WHERE deleted_at IS NULL;  -- Oracle 21c+
-- For older versions use function-based index:
-- CREATE INDEX idx_users_email ON users (CASE WHEN deleted_at IS NULL THEN email END);
```

## PL/SQL Stored Procedures
```sql
CREATE OR REPLACE PROCEDURE create_order(
    p_user_id    IN RAW,
    p_items      IN SYS.ODCIVARCHAR2LIST,
    p_order_id   OUT RAW,
    p_status     OUT VARCHAR2
) AS
    v_total NUMBER(12,2) := 0;
BEGIN
    p_order_id := SYS_GUID();

    INSERT INTO orders (id, user_id, status, total_amount, created_at, updated_at)
    VALUES (p_order_id, p_user_id, 'pending', 0, SYSTIMESTAMP, SYSTIMESTAMP);

    -- Process items...
    UPDATE orders SET total_amount = v_total, updated_at = SYSTIMESTAMP
    WHERE id = p_order_id;

    p_status := 'SUCCESS';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR: ' || SQLERRM;
        RAISE;
END create_order;
/
```

## Partitioning
```sql
CREATE TABLE events (
    id RAW(16) DEFAULT SYS_GUID() NOT NULL,
    event_type VARCHAR2(50) NOT NULL,
    payload CLOB CHECK (payload IS JSON),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL
) PARTITION BY RANGE (created_at) (
    PARTITION p_2026_q1 VALUES LESS THAN (TIMESTAMP '2026-04-01 00:00:00 +00:00'),
    PARTITION p_2026_q2 VALUES LESS THAN (TIMESTAMP '2026-07-01 00:00:00 +00:00'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);
```

## Performance Tuning
```sql
-- Execution plan
EXPLAIN PLAN FOR SELECT * FROM users WHERE email = 'test@example.com';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- AWR report for performance analysis
@?/rdbms/admin/awrrpt.sql
```

## Key Differences
| Feature | Oracle | PostgreSQL |
|---------|--------|------------|
| UUID | `SYS_GUID()` / `RAW(16)` | `gen_random_uuid()` / `UUID` |
| Boolean | `NUMBER(1)` | Native `BOOLEAN` |
| Auto-update timestamp | Trigger required | Trigger required |
| JSON | `CLOB CHECK (IS JSON)` (21c: native JSON) | Native `JSONB` |
| Sequences | `CREATE SEQUENCE` | `SERIAL` / `GENERATED` |

## Rules Integration
- **Database**: UUID via `SYS_GUID()`, `RAW(16)` storage, audit columns, partitioning for large tables
- **Security**: INVOKER rights, fine-grained access control, VPD, Oracle Data Redaction
