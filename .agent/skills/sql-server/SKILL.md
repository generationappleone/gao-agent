---
name: SQL Server
description: Skill for developing with Microsoft SQL Server, covering schema design, T-SQL, query optimization, indexing, and integration with .NET and Node.js applications.
---

# SQL Server Skill

## Overview
Microsoft SQL Server is an enterprise relational database with ACID compliance, T-SQL language, stored procedures, Window Functions, JSON support, full-text search, and high availability features. SQL Server is the standard database for .NET applications and enterprise environments.

**References**:
- [SQL Server Documentation](https://learn.microsoft.com/en-us/sql/sql-server/)
- [T-SQL Reference](https://learn.microsoft.com/en-us/sql/t-sql/language-reference)

---

## Setup

```yaml
# docker-compose.yml
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: sqlserver
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_SA_PASSWORD: ${SA_PASSWORD}
      MSSQL_PID: Developer
    ports:
      - "1433:1433"
    volumes:
      - mssql_data:/var/opt/mssql

volumes:
  mssql_data:
```

---

## Schema Design

```sql
USE master;
GO
CREATE DATABASE MyApp;
GO
USE MyApp;
GO

-- Users
CREATE TABLE users (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    email NVARCHAR(255) NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    name NVARCHAR(100) NOT NULL,
    role NVARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin','editor')),
    status NVARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive','suspended')),
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT uk_users_email UNIQUE (email)
);

CREATE INDEX idx_users_role ON users(role);

-- Categories
CREATE TABLE categories (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    name NVARCHAR(100) NOT NULL,
    slug NVARCHAR(100) NOT NULL,
    parent_id UNIQUEIDENTIFIER NULL REFERENCES categories(id),
    CONSTRAINT uk_categories_slug UNIQUE (slug)
);

-- Products
CREATE TABLE products (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    name NVARCHAR(200) NOT NULL,
    slug NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NULL,
    price INT NOT NULL DEFAULT 0,
    stock INT NOT NULL DEFAULT 0,
    category_id UNIQUEIDENTIFIER NOT NULL REFERENCES categories(id),
    status NVARCHAR(10) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','active','archived')),
    rating DECIMAL(3,2) NOT NULL DEFAULT 0,
    rating_count INT NOT NULL DEFAULT 0,
    metadata NVARCHAR(MAX) NULL,  -- JSON
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT uk_products_slug UNIQUE (slug)
);

CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_status_category ON products(status, category_id);

-- Orders
CREATE TABLE orders (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    order_number NVARCHAR(20) NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL REFERENCES users(id),
    status NVARCHAR(12) NOT NULL DEFAULT 'pending',
    subtotal INT NOT NULL DEFAULT 0,
    tax INT NOT NULL DEFAULT 0,
    total INT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT uk_orders_number UNIQUE (order_number)
);

CREATE TABLE order_items (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    order_id UNIQUEIDENTIFIER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UNIQUEIDENTIFIER NOT NULL REFERENCES products(id),
    quantity INT NOT NULL DEFAULT 1,
    unit_price INT NOT NULL,
    total INT NOT NULL
);
```

---

## Common Queries

```sql
-- Paginated listing with ROW_NUMBER
SELECT * FROM (
    SELECT p.*, c.name AS category_name,
           ROW_NUMBER() OVER (ORDER BY p.created_at DESC) AS row_num
    FROM products p
    JOIN categories c ON c.id = p.category_id
    WHERE p.status = 'active'
) AS t
WHERE row_num BETWEEN 1 AND 20;

-- OFFSET/FETCH (SQL Server 2012+)
SELECT p.id, p.name, p.price, c.name AS category_name
FROM products p
JOIN categories c ON c.id = p.category_id
WHERE p.status = 'active'
ORDER BY p.created_at DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;

-- Monthly revenue with Window Functions
SELECT
    FORMAT(o.created_at, 'yyyy-MM') AS month,
    COUNT(*) AS total_orders,
    SUM(o.total) AS revenue,
    AVG(o.total) AS avg_order_value,
    SUM(SUM(o.total)) OVER (ORDER BY FORMAT(o.created_at, 'yyyy-MM')) AS running_total
FROM orders o
WHERE o.status != 'cancelled'
  AND o.created_at >= DATEADD(MONTH, -12, GETUTCDATE())
GROUP BY FORMAT(o.created_at, 'yyyy-MM')
ORDER BY month DESC;

-- JSON queries
SELECT name, price,
    JSON_VALUE(metadata, '$.color') AS color,
    JSON_VALUE(metadata, '$.weight') AS weight
FROM products
WHERE ISJSON(metadata) = 1
  AND JSON_VALUE(metadata, '$.color') = 'red';

-- MERGE (Upsert)
MERGE INTO products AS target
USING (VALUES (@id, @name, @slug, @price)) AS source(id, name, slug, price)
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET name = source.name, price = source.price, updated_at = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (name, slug, price) VALUES (source.name, source.slug, source.price);
```

---

## Stored Procedures

```sql
CREATE PROCEDURE sp_CreateOrder
    @UserId UNIQUEIDENTIFIER,
    @Items NVARCHAR(MAX),  -- JSON array
    @OrderId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Subtotal INT = 0;
        DECLARE @OrderNumber NVARCHAR(20) = 'ORD-' + FORMAT(GETUTCDATE(), 'yyyyMMddHHmmss');
        SET @OrderId = NEWID();

        -- Process items from JSON
        DECLARE @ItemTable TABLE (ProductId UNIQUEIDENTIFIER, Quantity INT);
        INSERT INTO @ItemTable (ProductId, Quantity)
        SELECT JSON_VALUE(value, '$.productId'), JSON_VALUE(value, '$.quantity')
        FROM OPENJSON(@Items);

        -- Validate stock and create order items
        DECLARE @ProductId UNIQUEIDENTIFIER, @Qty INT, @Price INT;
        DECLARE item_cursor CURSOR FOR SELECT ProductId, Quantity FROM @ItemTable;
        OPEN item_cursor;
        FETCH NEXT FROM item_cursor INTO @ProductId, @Qty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @Price = price FROM products WITH (UPDLOCK) WHERE id = @ProductId AND stock >= @Qty;
            IF @Price IS NULL RAISERROR('Insufficient stock', 16, 1);

            UPDATE products SET stock = stock - @Qty WHERE id = @ProductId;

            INSERT INTO order_items (order_id, product_id, quantity, unit_price, total)
            VALUES (@OrderId, @ProductId, @Qty, @Price, @Price * @Qty);

            SET @Subtotal = @Subtotal + (@Price * @Qty);
            FETCH NEXT FROM item_cursor INTO @ProductId, @Qty;
        END;

        CLOSE item_cursor;
        DEALLOCATE item_cursor;

        DECLARE @Tax INT = ROUND(@Subtotal * 0.11, 0);

        INSERT INTO orders (id, order_number, user_id, subtotal, tax, total)
        VALUES (@OrderId, @OrderNumber, @UserId, @Subtotal, @Tax, @Subtotal + @Tax);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **NEWSEQUENTIALID** | Use for clustered PK to reduce fragmentation |
| **NVARCHAR** | Use for Unicode support (not VARCHAR) |
| **DATETIME2** | Prefer over DATETIME for precision |
| **CHECK constraints** | Enforce status/role values at DB level |
| **OFFSET/FETCH** | Standard pagination syntax |
| **Window Functions** | Running totals, ROW_NUMBER, RANK |
| **MERGE** | Use for upsert operations |
| **JSON** | JSON_VALUE, OPENJSON for semi-structured data |
| **TRY/CATCH** | Structured error handling in procedures |
| **UPDLOCK** | Use for stock validation in transactions |

---

## Rules Integration
- **Schema**: UNIQUEIDENTIFIER, CHECK constraints, indexes
- **Queries**: OFFSET/FETCH, window functions, JSON queries
- **Procedures**: Stored procs with transactions and error handling
- **Performance**: Indexes, UPDLOCK, query optimization
- **JSON**: JSON_VALUE, OPENJSON for flexible data
