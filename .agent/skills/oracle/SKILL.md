---
name: Oracle Database
description: Skill for developing with Oracle Database, covering schema design, PL/SQL, partitioning, performance tuning, and enterprise patterns.
---

# Oracle Database Skill

## Overview
Oracle Database is an enterprise relational database with ACID compliance, PL/SQL, partitioning, advanced indexing, JSON support, and high availability (RAC, Data Guard). Oracle is the standard for enterprise and financial applications.

**References**:
- [Oracle Documentation](https://docs.oracle.com/en/database/)
- [PL/SQL Reference](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/)

---

## Schema Design

```sql
-- Users
CREATE TABLE users (
    id RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    email VARCHAR2(255) NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    name VARCHAR2(100) NOT NULL,
    role VARCHAR2(20) DEFAULT 'user' CHECK (role IN ('user','admin','editor')),
    status VARCHAR2(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

-- Products
CREATE TABLE products (
    id RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    name VARCHAR2(200) NOT NULL,
    slug VARCHAR2(200) NOT NULL UNIQUE,
    description CLOB,
    price NUMBER(10) DEFAULT 0 NOT NULL,
    stock NUMBER(10) DEFAULT 0 NOT NULL,
    category_id RAW(16) REFERENCES categories(id),
    status VARCHAR2(10) DEFAULT 'draft' CHECK (status IN ('draft','active','archived')),
    metadata CLOB CHECK (metadata IS JSON),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_category ON products(category_id);
```

---

## Common Queries

```sql
-- Pagination with OFFSET/FETCH
SELECT p.id, p.name, p.price, c.name AS category_name
FROM products p JOIN categories c ON c.id = p.category_id
WHERE p.status = 'active'
ORDER BY p.created_at DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;

-- Window functions
SELECT FORMAT_DATE(o.created_at, 'YYYY-MM') AS month,
    COUNT(*) AS total_orders, SUM(o.total) AS revenue,
    SUM(SUM(o.total)) OVER (ORDER BY TRUNC(o.created_at, 'MM')) AS running_total
FROM orders o WHERE o.status != 'cancelled'
GROUP BY TRUNC(o.created_at, 'MM')
ORDER BY 1 DESC;

-- JSON queries (Oracle 21c+)
SELECT p.name, JSON_VALUE(p.metadata, '$.color') AS color
FROM products p
WHERE JSON_EXISTS(p.metadata, '$.color');

-- MERGE (Upsert)
MERGE INTO products t USING (SELECT :id AS id, :name AS name, :price AS price FROM DUAL) s
ON (t.id = s.id)
WHEN MATCHED THEN UPDATE SET t.name = s.name, t.price = s.price
WHEN NOT MATCHED THEN INSERT (name, slug, price) VALUES (s.name, :slug, s.price);
```

---

## PL/SQL Procedure

```sql
CREATE OR REPLACE PROCEDURE create_order(
    p_user_id IN RAW, p_items IN CLOB, p_order_id OUT RAW
) AS
    v_subtotal NUMBER := 0;
    v_tax NUMBER;
    v_order_number VARCHAR2(20);
    v_price NUMBER;
    v_qty NUMBER;
BEGIN
    SELECT 'ORD-' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS') INTO v_order_number FROM DUAL;
    p_order_id := SYS_GUID();

    FOR item IN (SELECT * FROM JSON_TABLE(p_items, '$[*]' COLUMNS (
        product_id VARCHAR2(32) PATH '$.productId', quantity NUMBER PATH '$.quantity'
    ))) LOOP
        SELECT price INTO v_price FROM products WHERE id = HEXTORAW(item.product_id) AND stock >= item.quantity FOR UPDATE;
        UPDATE products SET stock = stock - item.quantity WHERE id = HEXTORAW(item.product_id);
        INSERT INTO order_items (order_id, product_id, quantity, unit_price, total)
        VALUES (p_order_id, HEXTORAW(item.product_id), item.quantity, v_price, v_price * item.quantity);
        v_subtotal := v_subtotal + (v_price * item.quantity);
    END LOOP;

    v_tax := ROUND(v_subtotal * 0.11);
    INSERT INTO orders (id, order_number, user_id, subtotal, tax, total)
    VALUES (p_order_id, v_order_number, p_user_id, v_subtotal, v_tax, v_subtotal + v_tax);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **SYS_GUID** | Use RAW(16) with SYS_GUID() for UUIDs |
| **VARCHAR2** | Prefer over CHAR for variable-length strings |
| **CLOB** | Use for large text/JSON data |
| **JSON** | CHECK constraint IS JSON, JSON_VALUE, JSON_TABLE |
| **MERGE** | Use for upsert operations |
| **PL/SQL** | Stored procedures for complex business logic |
| **FOR UPDATE** | Lock rows in transactions |
| **Partitioning** | Range/hash partitions for large tables |
| **Indexes** | B-tree, bitmap, function-based indexes |
| **Sequences** | Use sequences for auto-increment |

---

## Rules Integration
- **Schema**: RAW UUIDs, CHECK constraints, JSON columns
- **Queries**: OFFSET/FETCH, window functions, MERGE
- **PL/SQL**: Stored procedures with transactions
- **Performance**: Indexes, partitioning, explain plans
