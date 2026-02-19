---
name: MySQL
description: Skill for designing, developing, and managing MySQL databases, covering schema design with binary UUIDs, query optimization, indexing, replication, and best practices.
---

# MySQL Skill

## Overview
MySQL is a widely-used open-source relational database. Use this skill for MySQL 8+ projects. Key difference from PostgreSQL: UUID must be stored as `BINARY(16)` for optimal performance.

## Setup & Connection
```bash
# Docker
docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=secret -e MYSQL_DATABASE=mydb mysql:8.0

# Connection string
mysql://user:password@localhost:3306/mydb?charset=utf8mb4
```

## Schema Design with Binary UUID
```sql
CREATE TABLE users (
    id BINARY(16) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert with ordered binary UUID
INSERT INTO users (id, email, password_hash, first_name, last_name)
VALUES (UUID_TO_BIN(UUID(), 1), 'user@example.com', '$2b$10$...', 'John', 'Doe');

-- Select with UUID conversion
SELECT BIN_TO_UUID(id, 1) AS id, email, first_name FROM users WHERE deleted_at IS NULL;
```

## UUID Helper Functions
```sql
-- Create helper function for cleaner queries
DELIMITER //
CREATE FUNCTION uuid_v4() RETURNS BINARY(16)
DETERMINISTIC
BEGIN
    RETURN UUID_TO_BIN(UUID(), 1);
END //
DELIMITER ;

-- Usage
INSERT INTO users (id, email, ...) VALUES (uuid_v4(), 'user@example.com', ...);
```

## Performance Tuning
```sql
-- Analyze queries
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Key my.cnf settings
-- innodb_buffer_pool_size = 70-80% of RAM
-- innodb_log_file_size = 256M-1G
-- innodb_flush_log_at_trx_commit = 1 (safe) or 2 (faster)
-- max_connections = based on workload
-- sort_buffer_size = 256K-2M
```

## Key Differences from PostgreSQL
| Feature | PostgreSQL | MySQL 8+ |
|---------|-----------|----------|
| UUID type | Native `UUID` | `BINARY(16)` |
| Partial indexes | ✅ `WHERE` clause | ❌ Not supported |
| JSONB | ✅ Native + GIN index | JSON + virtual columns + index |
| CTE (WITH) | ✅ Full support | ✅ Since 8.0 |
| Window functions | ✅ Full support | ✅ Since 8.0 |
| RLS | ✅ Native | ❌ Use views + app layer |

## Rules Integration
- **Database**: Binary UUID with `UUID_TO_BIN(UUID(), 1)`, InnoDB engine, utf8mb4 charset
- **Security**: SSL connections, prepared statements, no GRANT ALL
