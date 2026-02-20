---
name: MySQL
description: Skill for designing, developing, and managing MySQL databases, covering schema design with binary UUIDs, query optimization, indexing, replication, and best practices.
---

# MySQL Skill

## Overview
MySQL is the world's most popular open-source relational database. It provides ACID compliance, InnoDB storage engine, full-text search, JSON support, and replication. MySQL is widely used in web applications, especially with PHP/Laravel and Node.js.

**References**:
- [MySQL 8.0 Documentation](https://dev.mysql.com/doc/refman/8.0/en/)
- [MySQL Performance Tuning](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)

---

## Setup

```yaml
# docker-compose.yml
services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: myapp
      MYSQL_USER: myapp
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    command: >
      --default-authentication-plugin=caching_sha2_password
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci
      --innodb-buffer-pool-size=256M
      --max-connections=200
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  mysql_data:
```

---

## Schema Design

```sql
-- Database setup
CREATE DATABASE IF NOT EXISTS myapp
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE myapp;

-- ── Users ──
CREATE TABLE users (
  id BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID(), TRUE)),
  email VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  role ENUM('user', 'admin', 'editor') NOT NULL DEFAULT 'user',
  status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
  email_verified_at TIMESTAMP NULL,
  avatar_url VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uk_users_email (email),
  KEY idx_users_status (status),
  KEY idx_users_role (role),
  KEY idx_users_created (created_at)
) ENGINE=InnoDB;

-- ── Categories ──
CREATE TABLE categories (
  id BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID(), TRUE)),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  parent_id BINARY(16) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uk_categories_slug (slug),
  KEY idx_categories_parent (parent_id),
  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ── Products ──
CREATE TABLE products (
  id BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID(), TRUE)),
  name VARCHAR(200) NOT NULL,
  slug VARCHAR(200) NOT NULL,
  description TEXT NULL,
  price INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Price in smallest currency unit',
  stock INT UNSIGNED NOT NULL DEFAULT 0,
  category_id BINARY(16) NOT NULL,
  status ENUM('draft', 'active', 'archived') NOT NULL DEFAULT 'draft',
  rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  rating_count INT UNSIGNED NOT NULL DEFAULT 0,
  metadata JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uk_products_slug (slug),
  KEY idx_products_category (category_id),
  KEY idx_products_status (status),
  KEY idx_products_price (price),
  KEY idx_products_rating (rating DESC),
  KEY idx_products_status_category (status, category_id),
  FULLTEXT KEY ft_products_search (name, description),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB;

-- ── Orders ──
CREATE TABLE orders (
  id BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID(), TRUE)),
  order_number VARCHAR(20) NOT NULL,
  user_id BINARY(16) NOT NULL,
  status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
  subtotal INT UNSIGNED NOT NULL DEFAULT 0,
  tax INT UNSIGNED NOT NULL DEFAULT 0,
  total INT UNSIGNED NOT NULL DEFAULT 0,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uk_orders_number (order_number),
  KEY idx_orders_user (user_id),
  KEY idx_orders_status (status),
  KEY idx_orders_created (created_at),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID(), TRUE)),
  order_id BINARY(16) NOT NULL,
  product_id BINARY(16) NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  unit_price INT UNSIGNED NOT NULL,
  total_price INT UNSIGNED NOT NULL,

  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id),
  CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_oi_product FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;
```

---

## UUID Helper Functions

```sql
-- Convert binary UUID to string for display
DELIMITER //
CREATE FUNCTION BIN_TO_UUID_STR(b BINARY(16))
RETURNS VARCHAR(36) DETERMINISTIC
BEGIN
  RETURN BIN_TO_UUID(b, TRUE);
END //
DELIMITER ;

-- Usage
SELECT BIN_TO_UUID(id, TRUE) AS id, name, email FROM users;
```

---

## Common Queries

```sql
-- ── Product listing with filters ──
SELECT
  BIN_TO_UUID(p.id, TRUE) AS id,
  p.name, p.slug, p.price, p.stock, p.rating,
  c.name AS category_name
FROM products p
JOIN categories c ON c.id = p.category_id
WHERE p.status = 'active'
  AND (c.slug = 'electronics' OR 'electronics' IS NULL)
ORDER BY p.created_at DESC
LIMIT 20 OFFSET 0;

-- ── Full-text search ──
SELECT
  BIN_TO_UUID(id, TRUE) AS id, name, price,
  MATCH(name, description) AGAINST('wireless headphones' IN NATURAL LANGUAGE MODE) AS relevance
FROM products
WHERE status = 'active'
  AND MATCH(name, description) AGAINST('wireless headphones' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC
LIMIT 20;

-- ── Monthly revenue report ──
SELECT
  DATE_FORMAT(o.created_at, '%Y-%m') AS month,
  COUNT(DISTINCT o.id) AS total_orders,
  SUM(o.total) AS revenue,
  AVG(o.total) AS avg_order_value,
  COUNT(DISTINCT o.user_id) AS unique_customers
FROM orders o
WHERE o.status NOT IN ('cancelled')
  AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(o.created_at, '%Y-%m')
ORDER BY month DESC;

-- ── JSON queries ──
SELECT name, price,
  JSON_EXTRACT(metadata, '$.color') AS color,
  JSON_EXTRACT(metadata, '$.weight') AS weight
FROM products
WHERE JSON_EXTRACT(metadata, '$.color') = '"red"';

-- ── Upsert (INSERT ... ON DUPLICATE KEY UPDATE) ──
INSERT INTO products (id, name, slug, price, category_id, stock)
VALUES (UUID_TO_BIN(UUID(), TRUE), 'Product', 'product-slug', 100, @cat_id, 50)
ON DUPLICATE KEY UPDATE
  price = VALUES(price),
  stock = VALUES(stock),
  updated_at = CURRENT_TIMESTAMP;
```

---

## Transactions

```sql
-- Create order with stock validation
START TRANSACTION;

-- Check stock
SELECT stock FROM products WHERE id = @product_id FOR UPDATE;

-- Insert order
INSERT INTO orders (id, order_number, user_id, subtotal, tax, total)
VALUES (UUID_TO_BIN(UUID(), TRUE), 'ORD-20240115-001', @user_id, 299000, 29900, 328900);

SET @order_id = LAST_INSERT_ID();

-- Insert items
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price, total_price)
VALUES (UUID_TO_BIN(UUID(), TRUE), @order_id, @product_id, 1, 299000, 299000);

-- Decrement stock
UPDATE products SET stock = stock - 1 WHERE id = @product_id AND stock >= 1;

COMMIT;
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Binary UUID** | Use `BINARY(16)` with `UUID_TO_BIN(UUID(), TRUE)` for ordered UUIDs |
| **utf8mb4** | Always use `utf8mb4` character set for full Unicode support |
| **InnoDB** | Default engine with ACID, row-level locking, FK support |
| **Indexes** | Composite indexes for common query patterns |
| **ENUM** | Use for fixed-set columns (status, role, type) |
| **FULLTEXT** | Full-text indexes for search in InnoDB tables |
| **Transactions** | Use `FOR UPDATE` for stock/balance operations |
| **JSON** | Use JSON column for flexible metadata |
| **Naming** | snake_case for tables/columns, `idx_` prefix for indexes |
| **Timestamps** | `DEFAULT CURRENT_TIMESTAMP`, `ON UPDATE CURRENT_TIMESTAMP` |

---

## Rules Integration
- **Schema**: Binary UUIDs, ENUMs, timestamps, foreign keys, indexes
- **Search**: Full-text indexes for natural language search
- **Queries**: Joins, aggregations, JSON operations, upserts
- **Transactions**: FOR UPDATE locking for stock management
- **Performance**: Composite indexes, EXPLAIN for query plans
