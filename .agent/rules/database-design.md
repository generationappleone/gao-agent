# 🗄️ Database Design — Mandatory Normalization & Best Practices Rule

> **Severity:** STRICT  
> **Scope:** All database schemas, tables, collections, and data models created or modified by the agent  
> **Applies to:** All database engines — PostgreSQL, MySQL, SQL Server, Oracle, SAP HANA, MongoDB, SQLite, CockroachDB, MariaDB, and any others  
> **Objective:** Ensure data integrity, optimal performance, and scalability through normalization principles and industry best practices

---

## Overview

When designing or modifying database structures, the agent **MUST** follow normalization principles and best practices outlined in this document. All primary keys **MUST** use **UUID** (Universally Unique Identifier). The rules are database-agnostic and must be adapted to the specific syntax and features of the target database engine.

---

## 1. 🔑 Primary Key: UUID Requirement

### ✅ MUST do:
- Use **UUID v4** (random) or **UUID v7** (time-sortable) as the primary key for **every table/collection**
- Store UUIDs in the **native UUID type** when available, otherwise use `CHAR(36)` or `BINARY(16)`
- Generate UUIDs at the **application layer** or use database-native UUID functions
- Use UUID v7 when **chronological ordering** is important for performance (e.g., time-series, event logs)

### ❌ MUST NOT do:
- Use auto-increment integers (`SERIAL`, `AUTO_INCREMENT`, `IDENTITY`) as primary keys
- Use natural keys (email, username, SSN) as primary keys
- Use composite primary keys unless absolutely necessary (e.g., junction/pivot tables)
- Store UUIDs as plain `VARCHAR` without length constraints

### 📏 UUID Implementation per Database:

| Database | Native Type | Alternative | UUID Generation Function |
|----------|------------|-------------|--------------------------|
| **PostgreSQL** | `UUID` | — | `gen_random_uuid()` (v4), `uuid_generate_v7()` (extension) |
| **MySQL 8+** | — | `BINARY(16)`, `CHAR(36)` | `UUID()` (v1), application-generated v4/v7 |
| **SQL Server** | `UNIQUEIDENTIFIER` | — | `NEWID()` (v4), `NEWSEQUENTIALID()` (ordered) |
| **Oracle** | `RAW(16)` | `VARCHAR2(36)` | `SYS_GUID()` |
| **SAP HANA** | `NVARCHAR(36)` | `VARBINARY(16)` | `SYSUUID` |
| **MongoDB** | — | Use `_id` with UUID | `UUID()` (v4) |
| **SQLite** | — | `TEXT(36)`, `BLOB(16)` | Application-generated |
| **CockroachDB** | `UUID` | — | `gen_random_uuid()` |

### 📝 UUID Examples:

```sql
-- PostgreSQL
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE
);

-- MySQL
CREATE TABLE users (
    id BINARY(16) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE
);
-- Application layer: UUID.v4() → convert to binary

-- SQL Server
CREATE TABLE users (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    email NVARCHAR(255) NOT NULL UNIQUE
);

-- Oracle
CREATE TABLE users (
    id RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    email VARCHAR2(255) NOT NULL UNIQUE
);
```

```javascript
// MongoDB
{
  _id: UUID(),  // or new UUID() in driver
  email: "user@example.com"
}
```

### ⚡ UUID Performance Considerations:
- Prefer **UUID v7** over UUID v4 for tables with heavy **INSERT** workloads (v7 is time-sortable, reducing B-tree fragmentation)
- For MySQL with `BINARY(16)`, use **ordered UUID** storage (`UUID_TO_BIN(uuid, 1)`) to maintain index efficiency
- Add a **secondary index** on frequently queried columns instead of relying on the UUID primary key for lookups
- For MongoDB, consider using the default `ObjectId` only if UUID is not required — otherwise use UUID

---

## 2. 📐 Normalization Principles

### 2.1 First Normal Form (1NF)

> *"Each column must contain atomic (indivisible) values. No repeating groups or arrays in a single column."*

#### ✅ MUST do:
- Each column holds a **single, atomic value**
- No repeating groups or comma-separated values in a column
- Every row is uniquely identifiable (via UUID primary key)
- Define a clear **data type** for each column

#### ❌ MUST NOT do:
- Store multiple values in one column (e.g., `"tag1,tag2,tag3"`)
- Store JSON arrays as a substitute for proper relational design (unless using a document DB)
- Create columns like `phone1`, `phone2`, `phone3` — use a separate table instead

```sql
-- ❌ FORBIDDEN: Violates 1NF
CREATE TABLE contacts (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    phone_numbers VARCHAR(500)  -- "08123,08456,08789"
);

-- ✅ REQUIRED: Properly normalized
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL
);

CREATE TABLE contact_phones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    phone_type VARCHAR(20) NOT NULL DEFAULT 'mobile'
);
```

### 2.2 Second Normal Form (2NF)

> *"All non-key columns must depend on the entire primary key, not just part of it."*

#### ✅ MUST do:
- Ensure every non-key attribute is **fully functionally dependent** on the primary key
- If using composite keys (e.g., junction tables), no column should depend on only one part of the key
- Extract partial dependencies into separate tables

#### ❌ MUST NOT do:
- Include columns that depend on only part of a composite key

```sql
-- ❌ FORBIDDEN: Violates 2NF (student_name depends only on student_id)
CREATE TABLE enrollments (
    student_id UUID,
    course_id UUID,
    student_name VARCHAR(255),  -- Depends only on student_id!
    enrollment_date TIMESTAMP,
    PRIMARY KEY (student_id, course_id)
);

-- ✅ REQUIRED: Properly normalized
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL
);

CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id),
    course_id UUID NOT NULL REFERENCES courses(id),
    enrollment_date TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, course_id)
);
```

### 2.3 Third Normal Form (3NF)

> *"No non-key column should depend on another non-key column (no transitive dependencies)."*

#### ✅ MUST do:
- Remove **transitive dependencies** — non-key columns must depend only on the primary key
- Extract lookup/reference data into separate tables
- Use foreign keys to reference lookup tables

#### ❌ MUST NOT do:
- Store derived or redundant data that depends on other non-key columns

```sql
-- ❌ FORBIDDEN: Violates 3NF (city and state depend on zip_code, not on id)
CREATE TABLE customers (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    zip_code VARCHAR(10),
    city VARCHAR(100),      -- Depends on zip_code!
    state VARCHAR(100)      -- Depends on zip_code!
);

-- ✅ REQUIRED: Properly normalized
CREATE TABLE zip_codes (
    zip_code VARCHAR(10) PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL
);

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    zip_code VARCHAR(10) NOT NULL REFERENCES zip_codes(zip_code)
);
```

### 2.4 When to Denormalize

Denormalization is **allowed** only when:

1. **Read-heavy workloads** — When JOIN performance is a proven bottleneck (backed by query profiling)
2. **Reporting/analytics tables** — Materialized views, data warehousing, or OLAP scenarios
3. **Caching layers** — Precomputed/aggregated data for dashboards
4. **Document databases** — MongoDB and similar where embedding is the standard pattern

> ⚠️ When denormalizing, the agent **MUST** document the reason and add a comment: `-- DENORMALIZED: [reason]`

---

## 3. 📏 Naming Conventions

### 3.1 General Rules

| Element | Convention | Example |
|---------|-----------|---------|
| **Tables** | `snake_case`, plural | `users`, `order_items`, `product_categories` |
| **Columns** | `snake_case`, singular | `first_name`, `created_at`, `is_active` |
| **Primary Key** | Always `id` | `id UUID PRIMARY KEY` |
| **Foreign Key** | `{referenced_table_singular}_id` | `user_id`, `order_id`, `category_id` |
| **Junction Tables** | `{table1}_{table2}` (alphabetical) | `roles_users`, `orders_products` |
| **Indexes** | `idx_{table}_{column(s)}` | `idx_users_email`, `idx_orders_created_at` |
| **Unique Constraints** | `uq_{table}_{column(s)}` | `uq_users_email` |
| **Check Constraints** | `ck_{table}_{column}` | `ck_orders_total_positive` |
| **Boolean Columns** | Prefix with `is_`, `has_`, `can_` | `is_active`, `has_verified`, `can_edit` |
| **Timestamp Columns** | Suffix with `_at` | `created_at`, `updated_at`, `deleted_at` |

### 3.2 MongoDB/Document DB Naming

| Element | Convention | Example |
|---------|-----------|---------|
| **Collections** | `snake_case`, plural | `users`, `order_items` |
| **Fields** | `camelCase` | `firstName`, `createdAt`, `isActive` |
| **Embedded Documents** | `camelCase`, singular | `address`, `profile` |
| **Reference Fields** | `{referenced_collection_singular}Id` | `userId`, `orderId` |

---

## 4. 🏗️ Table/Collection Structure Best Practices

### 4.1 Mandatory Audit Columns

Every table/collection **MUST** include the following audit columns:

```sql
-- SQL Databases
CREATE TABLE example (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ... business columns ...
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by  UUID REFERENCES users(id),
    updated_by  UUID REFERENCES users(id)
);
```

```javascript
// MongoDB
{
  _id: UUID(),
  // ... business fields ...
  createdAt: ISODate(),
  updatedAt: ISODate(),
  createdBy: UUID(),  // reference to users collection
  updatedBy: UUID()   // reference to users collection
}
```

### 4.2 Soft Delete Pattern

#### ✅ MUST do:
- Implement **soft delete** by default (add `deleted_at` column)
- Use `NULL` for active records and a timestamp for deleted records
- Add a **partial index** on `deleted_at IS NULL` for query performance
- Filter out soft-deleted records in all default queries

```sql
-- Soft delete column
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP DEFAULT NULL;

-- Partial index for active records only
CREATE INDEX idx_users_active ON users (email) WHERE deleted_at IS NULL;

-- Soft delete query
UPDATE users SET deleted_at = NOW(), updated_by = $1 WHERE id = $2;

-- Select active records
SELECT * FROM users WHERE deleted_at IS NULL;
```

#### ❌ MUST NOT do:
- Use hard `DELETE` unless explicitly required (e.g., GDPR data erasure)
- Use a boolean `is_deleted` column (timestamp provides more information)

### 4.3 Data Type Selection

#### ✅ MUST do:
- Use the **most specific and restrictive data type** for each column
- Use `TIMESTAMP WITH TIME ZONE` (or equivalent) for all date/time columns
- Use `DECIMAL` / `NUMERIC` for financial/monetary values (never `FLOAT` / `DOUBLE`)
- Use `TEXT` or `VARCHAR` with appropriate length constraints
- Use `BOOLEAN` for true/false values (not `INT`, `CHAR(1)`, or `VARCHAR`)
- Use `ENUM` or check constraints for columns with a fixed set of values

#### ❌ MUST NOT do:
- Use `FLOAT` or `DOUBLE` for monetary values (precision loss)
- Use `VARCHAR(255)` as a default for all string columns without considering actual needs
- Store dates as strings
- Store booleans as integers or strings
- Use oversized data types (e.g., `BIGINT` when `INT` suffices)

```sql
-- ❌ FORBIDDEN
CREATE TABLE products (
    id UUID PRIMARY KEY,
    price FLOAT,                    -- Precision loss!
    status VARCHAR(255),            -- No constraint!
    is_active INT,                  -- Should be BOOLEAN!
    created_at VARCHAR(50)          -- Should be TIMESTAMP!
);

-- ✅ REQUIRED
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    price DECIMAL(12, 2) NOT NULL CHECK (price >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'active', 'archived')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
```

---

## 5. 🔗 Relationships & Referential Integrity

### 5.1 Foreign Keys

#### ✅ MUST do:
- Define explicit **foreign key constraints** for all relationships (SQL databases)
- Specify **ON DELETE** and **ON UPDATE** behavior explicitly
- Index all foreign key columns for JOIN performance
- Use **UUID** for all foreign key references (consistent with the primary key rule)

#### Recommended Cascade Behaviors:

| Scenario | ON DELETE | ON UPDATE |
|----------|-----------|-----------|
| **Parent owns child** (e.g., order → order_items) | `CASCADE` | `CASCADE` |
| **Reference/lookup** (e.g., user → orders) | `RESTRICT` or `SET NULL` | `CASCADE` |
| **Audit/log reference** (e.g., created_by) | `SET NULL` | `CASCADE` |
| **Soft-deletable parent** | `NO ACTION` (handle in app layer) | `CASCADE` |

```sql
-- ✅ Proper foreign key with cascade behavior
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0)
);

CREATE INDEX idx_order_items_order_id ON order_items (order_id);
CREATE INDEX idx_order_items_product_id ON order_items (product_id);
```

### 5.2 MongoDB References

```javascript
// ✅ MongoDB: Reference pattern (normalized)
// orders collection
{
  _id: UUID(),
  userId: UUID(),       // reference to users collection
  items: [
    {
      productId: UUID(), // reference to products collection
      quantity: 2,
      unitPrice: Decimal128("29.99")
    }
  ],
  createdAt: ISODate()
}

// ✅ MongoDB: Embed pattern (denormalized — only when data is tightly coupled)
// users collection
{
  _id: UUID(),
  name: "John Doe",
  address: {             // Embedded — belongs to user, rarely queried independently
    street: "123 Main St",
    city: "Springfield",
    zipCode: "62704"
  }
}
```

### 5.3 MongoDB Reference Guidelines

| Pattern | Use When |
|---------|----------|
| **Embed** | Data is accessed together, bounded growth, 1:1 or 1:few relationship |
| **Reference** | Data is accessed independently, unbounded growth, many:many relationship |
| **Hybrid** | Embed summary/frequently-read data, reference full data |

---

## 6. 📊 Indexing Strategy

### 6.1 Indexing Rules

#### ✅ MUST do:
- Index all **foreign key columns**
- Index columns used in **WHERE**, **JOIN**, **ORDER BY**, and **GROUP BY** clauses
- Use **composite indexes** for queries that filter on multiple columns (follow the left-prefix rule)
- Use **partial/filtered indexes** for queries on subsets of data (e.g., `WHERE deleted_at IS NULL`)
- Use **unique indexes** to enforce business-level uniqueness constraints
- Consider **covering indexes** for frequently executed read-only queries

#### ❌ MUST NOT do:
- Over-index tables (each index adds write overhead)
- Create redundant indexes (e.g., index on `(a)` when `(a, b)` already exists)
- Index columns with very low cardinality (e.g., boolean columns) unless used in composite indexes
- Ignore index usage in query plans — always verify with `EXPLAIN` / `EXPLAIN ANALYZE`

```sql
-- ✅ Proper indexing strategy
-- Single-column index for common lookups
CREATE INDEX idx_users_email ON users (email) WHERE deleted_at IS NULL;

-- Composite index for multi-column queries
CREATE INDEX idx_orders_user_status ON orders (user_id, status, created_at DESC);

-- Unique constraint
CREATE UNIQUE INDEX uq_users_email ON users (email) WHERE deleted_at IS NULL;

-- Covering index (includes columns to avoid table lookup)
CREATE INDEX idx_products_category ON products (category_id) INCLUDE (name, price);
```

### 6.2 MongoDB Indexing

```javascript
// ✅ MongoDB indexes
db.users.createIndex({ email: 1 }, { unique: true, partialFilterExpression: { deletedAt: null } });
db.orders.createIndex({ userId: 1, status: 1, createdAt: -1 });
db.products.createIndex({ categoryId: 1, name: 1, price: 1 });
```

---

## 7. 🛡️ Data Integrity & Constraints

### ✅ MUST do:
- Add **NOT NULL** to all columns that are logically required
- Add **CHECK constraints** for value validation (ranges, formats, enums)
- Add **UNIQUE constraints** for business-level uniqueness (email, username, code)
- Use **DEFAULT values** where appropriate
- Add **length constraints** on string columns

```sql
-- ✅ Comprehensive constraints
CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    salary DECIMAL(12, 2) NOT NULL CHECK (salary > 0),
    department_id UUID NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    employment_type VARCHAR(20) NOT NULL CHECK (employment_type IN ('full_time', 'part_time', 'contract')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    CONSTRAINT uq_employees_email UNIQUE (email)
);
```

### MongoDB Validation:

```javascript
// ✅ MongoDB schema validation
db.createCollection("employees", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "firstName", "lastName", "salary", "departmentId", "employmentType"],
      properties: {
        _id: { bsonType: "binData" },
        email: { bsonType: "string", pattern: "^.+@.+\\..+$" },
        firstName: { bsonType: "string", maxLength: 100 },
        lastName: { bsonType: "string", maxLength: 100 },
        salary: { bsonType: "decimal", minimum: 0 },
        departmentId: { bsonType: "binData" },
        employmentType: { enum: ["full_time", "part_time", "contract"] },
        isActive: { bsonType: "bool" },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" },
        deletedAt: { bsonType: ["date", "null"] }
      }
    }
  }
});
```

---

## 8. 📈 Scalability Patterns

### 8.1 Partitioning

#### ✅ MUST consider when:
- A table is expected to exceed **10 million rows**
- Queries frequently filter by **date range**, **region**, or **tenant**
- Data has a natural **time-based** lifecycle (logs, events, transactions)

```sql
-- ✅ PostgreSQL: Range partitioning by date
CREATE TABLE events (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

CREATE TABLE events_2026_q1 PARTITION OF events
    FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');

CREATE TABLE events_2026_q2 PARTITION OF events
    FOR VALUES FROM ('2026-04-01') TO ('2026-07-01');
```

### 8.2 Multi-Tenancy

#### ✅ Recommended approaches:

| Strategy | Use When | Implementation |
|----------|----------|----------------|
| **Shared table, tenant column** | Small-medium SaaS, < 1000 tenants | Add `tenant_id UUID NOT NULL` + composite indexes |
| **Schema per tenant** | Medium SaaS, data isolation needed | Separate schema, shared database |
| **Database per tenant** | Enterprise SaaS, strict isolation | Separate database per tenant |

```sql
-- ✅ Shared table with tenant isolation
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Composite index with tenant_id first for tenant-scoped queries
CREATE INDEX idx_documents_tenant ON documents (tenant_id, created_at DESC);

-- Row-Level Security (PostgreSQL)
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON documents
    USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

---

## 9. 🔄 Migration Best Practices

### ✅ MUST do:
- Use a **migration tool** (Flyway, Liquibase, Knex, Prisma Migrate, Alembic, golang-migrate)
- Write migrations that are **idempotent** and **reversible** (include up and down)
- Never modify a migration that has already been applied to production
- Add **new columns as nullable** first, then backfill, then add `NOT NULL` constraint
- Test migrations against a **copy of production data** before applying

### ❌ MUST NOT do:
- Modify database schema directly without a migration file
- Drop columns or tables without a data backup strategy
- Run destructive migrations without a rollback plan
- Apply untested migrations to production

```sql
-- ✅ Safe migration: Add column in 3 steps
-- Step 1: Add nullable column
ALTER TABLE users ADD COLUMN phone VARCHAR(20) DEFAULT NULL;

-- Step 2: Backfill data
UPDATE users SET phone = 'unknown' WHERE phone IS NULL;

-- Step 3: Add NOT NULL constraint (separate migration)
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

---

## 📋 Database Design Checklist

Before completing any database task, the agent **MUST** verify:

### Schema Design
- [ ] All primary keys use **UUID** (v4 or v7)
- [ ] Schema satisfies at least **3NF** (or denormalization is documented)
- [ ] All tables have audit columns (`created_at`, `updated_at`, `created_by`, `updated_by`)
- [ ] Soft delete is implemented (`deleted_at` column)
- [ ] Naming conventions are followed consistently

### Data Integrity
- [ ] All required columns have **NOT NULL** constraints
- [ ] **Foreign keys** are defined with appropriate cascade behavior
- [ ] **CHECK constraints** are added for value validation
- [ ] **UNIQUE constraints** enforce business-level uniqueness
- [ ] Appropriate **data types** are used (no FLOAT for money, no VARCHAR for dates)

### Performance
- [ ] All foreign key columns are **indexed**
- [ ] Columns in frequent WHERE/JOIN/ORDER BY clauses are **indexed**
- [ ] No redundant or unnecessary indexes
- [ ] Partitioning is considered for large tables (> 10M rows)
- [ ] Query plans are reviewed with **EXPLAIN** / **EXPLAIN ANALYZE**

### Scalability
- [ ] Multi-tenancy strategy is defined (if applicable)
- [ ] Partitioning strategy is defined for time-series or high-volume data
- [ ] Connection pooling is configured
- [ ] Read replicas are considered for read-heavy workloads

### Migration
- [ ] Changes are captured in **migration files**
- [ ] Migrations are **reversible** (up and down)
- [ ] Destructive changes have a **rollback plan**
- [ ] Migrations are tested before production deployment

---

## 10. 💡 Real-World Examples

### 10.1 Example: E-Commerce Database (PostgreSQL)

This example demonstrates all rules applied together — UUID PKs, 3NF normalization, audit columns, soft delete, proper constraints, indexes, and foreign keys.

```sql
-- ✅ COMPLETE E-COMMERCE SCHEMA (PostgreSQL)

-- Users table with full audit trail and soft delete
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT true,
    email_verified_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,

    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT ck_users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_users_email ON users (email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_name ON users (last_name, first_name) WHERE deleted_at IS NULL;

-- Addresses table (1NF: separate from users; 3NF: zip_code lookup)
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label VARCHAR(50) NOT NULL DEFAULT 'home',
    street_line_1 VARCHAR(255) NOT NULL,
    street_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    country_code CHAR(2) NOT NULL DEFAULT 'US',
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT ck_addresses_label CHECK (label IN ('home', 'work', 'billing', 'shipping', 'other'))
);

CREATE INDEX idx_addresses_user ON addresses (user_id);

-- Product categories (self-referencing for hierarchy)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL,
    description TEXT,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,

    CONSTRAINT uq_categories_slug UNIQUE (slug)
);

CREATE INDEX idx_categories_parent ON categories (parent_id) WHERE deleted_at IS NULL;

-- Products (3NF: category is a reference, not embedded)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    sku VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2) NOT NULL,
    compare_at_price DECIMAL(12, 2),
    cost_price DECIMAL(12, 2),
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    stock_quantity INT NOT NULL DEFAULT 0,
    low_stock_threshold INT NOT NULL DEFAULT 5,
    weight_grams INT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,

    CONSTRAINT uq_products_sku UNIQUE (sku),
    CONSTRAINT ck_products_price_positive CHECK (price >= 0),
    CONSTRAINT ck_products_stock_non_negative CHECK (stock_quantity >= 0),
    CONSTRAINT ck_products_compare_price CHECK (compare_at_price IS NULL OR compare_at_price >= price)
);

CREATE INDEX idx_products_category ON products (category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_sku ON products (sku) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_price ON products (price) WHERE deleted_at IS NULL AND is_active = true;

-- Product tags (many-to-many via junction table)
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    slug VARCHAR(60) NOT NULL,
    CONSTRAINT uq_tags_slug UNIQUE (slug)
);

-- Junction table (alphabetical: products_tags)
CREATE TABLE products_tags (
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, tag_id)
);

CREATE INDEX idx_products_tags_tag ON products_tags (tag_id);

-- Orders with proper status tracking
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    shipping_address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
    billing_address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(12, 2) NOT NULL,
    tax_amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
    shipping_amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(12, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    notes TEXT,
    placed_at TIMESTAMP WITH TIME ZONE,
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT ck_orders_status CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    CONSTRAINT ck_orders_subtotal CHECK (subtotal >= 0),
    CONSTRAINT ck_orders_total CHECK (total_amount >= 0)
);

CREATE INDEX idx_orders_user ON orders (user_id, created_at DESC);
CREATE INDEX idx_orders_status ON orders (status, created_at DESC);

-- Order items (2NF: product_name is a snapshot, not a dependency)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    product_name VARCHAR(255) NOT NULL,  -- Snapshot at time of order (not a 2NF violation — intentional denormalization)
    product_sku VARCHAR(50) NOT NULL,    -- DENORMALIZED: Preserved for historical accuracy if product changes
    quantity INT NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT ck_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT ck_order_items_price CHECK (unit_price >= 0),
    CONSTRAINT ck_order_items_total CHECK (total_price = quantity * unit_price)
);

CREATE INDEX idx_order_items_order ON order_items (order_id);
CREATE INDEX idx_order_items_product ON order_items (product_id);

-- Payments (separated from orders for SRP — one order can have multiple payments)
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    payment_method VARCHAR(30) NOT NULL,
    payment_provider VARCHAR(30) NOT NULL,
    provider_transaction_id VARCHAR(255),
    amount DECIMAL(12, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT ck_payments_method CHECK (payment_method IN ('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'crypto')),
    CONSTRAINT ck_payments_status CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
    CONSTRAINT ck_payments_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_order ON payments (order_id);
CREATE INDEX idx_payments_status ON payments (status, created_at DESC);
CREATE INDEX idx_payments_provider_tx ON payments (provider_transaction_id) WHERE provider_transaction_id IS NOT NULL;

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### 10.2 Example: SaaS Multi-Tenant with Row-Level Security (PostgreSQL)

```sql
-- ✅ MULTI-TENANT SaaS SCHEMA WITH RLS

-- Tenants (organizations)
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    plan VARCHAR(20) NOT NULL DEFAULT 'free',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_tenants_slug UNIQUE (slug),
    CONSTRAINT ck_tenants_plan CHECK (plan IN ('free', 'starter', 'pro', 'enterprise'))
);

-- Tenant members (users belong to tenants)
CREATE TABLE tenant_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    invited_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT uq_tenant_members UNIQUE (tenant_id, user_id),
    CONSTRAINT ck_members_role CHECK (role IN ('owner', 'admin', 'member', 'viewer'))
);

CREATE INDEX idx_tenant_members_user ON tenant_members (user_id);

-- Tenant-scoped projects (every row belongs to a tenant)
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,

    CONSTRAINT ck_projects_status CHECK (status IN ('active', 'archived', 'paused'))
);

-- Composite index: tenant_id first for tenant-scoped queries
CREATE INDEX idx_projects_tenant ON projects (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Row-Level Security: automatic tenant isolation
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_select ON projects
    FOR SELECT USING (tenant_id = current_setting('app.current_tenant')::UUID);

CREATE POLICY tenant_isolation_insert ON projects
    FOR INSERT WITH CHECK (tenant_id = current_setting('app.current_tenant')::UUID);

CREATE POLICY tenant_isolation_update ON projects
    FOR UPDATE USING (tenant_id = current_setting('app.current_tenant')::UUID);

CREATE POLICY tenant_isolation_delete ON projects
    FOR DELETE USING (tenant_id = current_setting('app.current_tenant')::UUID);

-- Usage in application:
-- SET app.current_tenant = 'tenant-uuid-here';
-- SELECT * FROM projects;  -- Automatically filtered by tenant!
```

### 10.3 Example: MongoDB E-Commerce (Document Design)

```javascript
// ✅ MONGODB SCHEMA: E-Commerce with proper normalization patterns

// --- users collection (reference pattern) ---
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "passwordHash", "firstName", "lastName", "createdAt"],
      properties: {
        _id: { bsonType: "binData" },
        email: { bsonType: "string", pattern: "^.+@.+\\..+$" },
        passwordHash: { bsonType: "string" },
        firstName: { bsonType: "string", maxLength: 100 },
        lastName: { bsonType: "string", maxLength: 100 },
        phone: { bsonType: ["string", "null"] },
        // Embed addresses (bounded, 1:few, always accessed with user)
        addresses: {
          bsonType: "array",
          maxItems: 10,
          items: {
            bsonType: "object",
            required: ["label", "street", "city", "country"],
            properties: {
              id: { bsonType: "binData" },
              label: { enum: ["home", "work", "billing", "shipping"] },
              street: { bsonType: "string" },
              city: { bsonType: "string" },
              state: { bsonType: "string" },
              zipCode: { bsonType: "string" },
              country: { bsonType: "string", maxLength: 2 },
              isDefault: { bsonType: "bool" }
            }
          }
        },
        isActive: { bsonType: "bool" },
        emailVerifiedAt: { bsonType: ["date", "null"] },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" },
        deletedAt: { bsonType: ["date", "null"] }
      }
    }
  }
});

db.users.createIndex({ email: 1 }, { unique: true, partialFilterExpression: { deletedAt: null } });
db.users.createIndex({ lastName: 1, firstName: 1 }, { partialFilterExpression: { deletedAt: null } });

// --- products collection (reference for categories) ---
// Product document example:
{
  _id: UUID(),
  categoryId: UUID(),     // Reference — categories are independent entities
  sku: "PRD-001",
  name: "Wireless Headphones",
  description: "Premium noise-cancelling headphones",
  price: Decimal128("149.99"),
  compareAtPrice: Decimal128("199.99"),
  currency: "USD",
  stockQuantity: 50,
  // Embed tags (bounded, small, frequently read with product)
  tags: ["electronics", "audio", "wireless"],
  // Embed specifications (bounded, 1:1, always accessed together)
  specifications: {
    brand: "AudioPro",
    weight: "250g",
    batteryLife: "30 hours",
    connectivity: "Bluetooth 5.3"
  },
  isActive: true,
  publishedAt: ISODate("2026-01-15T00:00:00Z"),
  createdAt: ISODate(),
  updatedAt: ISODate(),
  createdBy: UUID(),
  deletedAt: null
}

db.products.createIndex({ sku: 1 }, { unique: true });
db.products.createIndex({ categoryId: 1, price: 1 }, { partialFilterExpression: { deletedAt: null, isActive: true } });
db.products.createIndex({ tags: 1 });  // Multikey index for array field
db.products.createIndex({ name: "text", description: "text" });  // Text search index

// --- orders collection (hybrid: embed items, reference user) ---
// Order document example:
{
  _id: UUID(),
  userId: UUID(),          // Reference — user is an independent entity
  orderNumber: "ORD-2026-0001",
  status: "confirmed",
  // Embed items (bounded, always accessed with order, contains snapshot data)
  items: [
    {
      productId: UUID(),   // Reference back to product
      productName: "Wireless Headphones",  // Snapshot — intentional denormalization
      productSku: "PRD-001",               // Snapshot — preserved for history
      quantity: 2,
      unitPrice: Decimal128("149.99"),
      totalPrice: Decimal128("299.98")
    }
  ],
  // Embed shipping address snapshot (data at time of order)
  shippingAddress: {
    street: "123 Main St",
    city: "Springfield",
    state: "IL",
    zipCode: "62704",
    country: "US"
  },
  subtotal: Decimal128("299.98"),
  taxAmount: Decimal128("24.00"),
  shippingAmount: Decimal128("9.99"),
  totalAmount: Decimal128("333.97"),
  currency: "USD",
  placedAt: ISODate("2026-02-19T10:00:00Z"),
  shippedAt: null,
  deliveredAt: null,
  createdAt: ISODate(),
  updatedAt: ISODate()
}

db.orders.createIndex({ userId: 1, createdAt: -1 });
db.orders.createIndex({ status: 1, createdAt: -1 });
db.orders.createIndex({ orderNumber: 1 }, { unique: true });
db.orders.createIndex({ "items.productId": 1 });  // Query orders containing specific product
```

### 10.4 Example: SQL Server Schema

```sql
-- ✅ SQL SERVER: Using UNIQUEIDENTIFIER for UUID

CREATE TABLE departments (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name NVARCHAR(100) NOT NULL,
    code NVARCHAR(10) NOT NULL,
    manager_id UNIQUEIDENTIFIER NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    deleted_at DATETIME2(7) NULL,

    CONSTRAINT uq_departments_code UNIQUE (code),
    CONSTRAINT fk_departments_manager FOREIGN KEY (manager_id)
        REFERENCES employees(id) ON DELETE SET NULL
);

CREATE TABLE employees (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),  -- Ordered UUID for performance
    department_id UNIQUEIDENTIFIER NOT NULL,
    email NVARCHAR(255) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    salary DECIMAL(12, 2) NOT NULL,
    employment_type NVARCHAR(20) NOT NULL,
    hire_date DATE NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    deleted_at DATETIME2(7) NULL,

    CONSTRAINT uq_employees_email UNIQUE (email),
    CONSTRAINT fk_employees_department FOREIGN KEY (department_id)
        REFERENCES departments(id) ON DELETE NO ACTION,
    CONSTRAINT ck_employees_salary CHECK (salary > 0),
    CONSTRAINT ck_employees_type CHECK (employment_type IN ('full_time', 'part_time', 'contract'))
);

CREATE INDEX idx_employees_department ON employees (department_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_employees_email ON employees (email) WHERE deleted_at IS NULL;
CREATE INDEX idx_employees_name ON employees (last_name, first_name) WHERE deleted_at IS NULL;
```

### 10.5 Example: MySQL Schema with Binary UUID

```sql
-- ✅ MYSQL 8+: Using BINARY(16) for UUID with ordered storage

CREATE TABLE products (
    id BINARY(16) PRIMARY KEY,
    category_id BINARY(16) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    stock_quantity INT UNSIGNED NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,

    UNIQUE KEY uq_products_sku (sku),
    KEY idx_products_category (category_id),
    KEY idx_products_price (price),
    CONSTRAINT ck_products_price CHECK (price >= 0),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert with ordered UUID for better index performance
INSERT INTO products (id, category_id, sku, name, price)
VALUES (
    UUID_TO_BIN(UUID(), 1),  -- swap_flag=1 for ordered storage
    UUID_TO_BIN('550e8400-e29b-41d4-a716-446655440000', 1),
    'PRD-001',
    'Wireless Mouse',
    29.99
);

-- Select with UUID conversion
SELECT BIN_TO_UUID(id, 1) AS id, name, price
FROM products
WHERE category_id = UUID_TO_BIN('550e8400-e29b-41d4-a716-446655440000', 1)
  AND deleted_at IS NULL;
```

---

## ⚠️ Exceptions

These rules may be **relaxed** in the following situations, but the agent must **explain the reasoning**:

1. **Prototyping / MVP** — May skip some constraints, but UUID primary keys are still **mandatory**
2. **Legacy database integration** — When working with existing schemas that use auto-increment IDs, maintain consistency with the existing pattern but propose UUID migration
3. **Extreme performance requirements** — If UUID causes measurable performance issues (must be backed by benchmarks), consider ordered UUIDs (v7) or other solutions
4. **Third-party schema requirements** — When integrating with systems that mandate specific key formats
5. **Embedded/IoT databases** — Resource-constrained environments may need simpler schemas

> In all exception cases, the agent must add a comment: `-- EXCEPTION: [reason for deviation from standard]`
