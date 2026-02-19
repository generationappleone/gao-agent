---
name: SQL Server
description: Skill for developing with Microsoft SQL Server, covering schema design, T-SQL, query optimization, indexing, and integration with .NET and Node.js applications.
---

# SQL Server Skill

## Overview
Microsoft SQL Server is an enterprise relational database. Use this skill for Windows-centric environments, .NET applications, and enterprise systems requiring Advanced Analytics, SSRS, and SSIS.

## Setup & Connection
```bash
# Docker
docker run -d --name mssql -p 1433:1433 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Pass1" mcr.microsoft.com/mssql/server:2022-latest

# Connection string
Server=localhost,1433;Database=MyDb;User Id=sa;Password=YourStrong@Pass1;Encrypt=True;TrustServerCertificate=True;
```

## Schema Design
```sql
CREATE TABLE users (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(), -- Sequential UUID for index performance
    email NVARCHAR(255) NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    deleted_at DATETIME2(7) NULL,
    CONSTRAINT uq_users_email UNIQUE (email)
);

-- Filtered index (SQL Server equivalent of partial index)
CREATE NONCLUSTERED INDEX idx_users_email_active
ON users (email) WHERE deleted_at IS NULL;

-- Computed column
ALTER TABLE users ADD full_name AS (first_name + N' ' + last_name) PERSISTED;
```

## T-SQL Stored Procedures
```sql
CREATE PROCEDURE dbo.usp_CreateUser
    @Email NVARCHAR(255),
    @PasswordHash NVARCHAR(255),
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @UserId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @UserId = NEWID();

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO users (id, email, password_hash, first_name, last_name)
        VALUES (@UserId, @Email, @PasswordHash, @FirstName, @LastName);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
```

## Window Functions & CTEs
```sql
WITH monthly_sales AS (
    SELECT
        FORMAT(created_at, 'yyyy-MM') AS month,
        SUM(total_amount) AS revenue,
        COUNT(*) AS order_count
    FROM orders
    WHERE status = 'completed'
    GROUP BY FORMAT(created_at, 'yyyy-MM')
)
SELECT
    month, revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
    CAST((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
         / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) AS DECIMAL(5,2)) AS growth_pct
FROM monthly_sales
ORDER BY month;
```

## Performance Tuning
```sql
-- Execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Include actual execution plan (SSMS: Ctrl+M)
-- Query Store (built-in performance monitoring)
ALTER DATABASE MyDb SET QUERY_STORE = ON;
```

## Key Types
| Data | Recommended Type |
|------|-----------------|
| UUID | `UNIQUEIDENTIFIER` |
| String | `NVARCHAR(n)` (Unicode) |
| Boolean | `BIT` |
| Timestamp | `DATETIME2(7)` |
| Money | `DECIMAL(12,2)` (not `MONEY`) |
| JSON | `NVARCHAR(MAX)` + `ISJSON()` |

## Rules Integration
- **Database**: UUID via `NEWSEQUENTIALID()` (clustered) or `NEWID()`, filtered indexes, audit columns
- **Security**: Windows Authentication preferred, TDE encryption, Always Encrypted, Row-Level Security
