---
name: Prisma ORM
description: Skill for type-safe database access with Prisma ORM — covering schema design, migrations, CRUD operations, relations, transactions, raw queries, and integration with Node.js/TypeScript.
---

# Prisma ORM Skill

## Overview
Prisma is a next-generation ORM for Node.js and TypeScript. It provides a declarative schema, type-safe database client, automatic migrations, and powerful query API. Prisma supports PostgreSQL, MySQL, SQLite, SQL Server, MongoDB, and CockroachDB.

**References**:
- [Prisma Documentation](https://www.prisma.io/docs)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [Prisma Client API](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference)

---

## Setup

```bash
npm install prisma @prisma/client
npx prisma init --datasource-provider postgresql
```

---

## Schema

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
  previewFeatures = ["fullTextSearch"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum Role {
  USER
  ADMIN
  EDITOR
}

enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  password      String
  name          String
  role          Role      @default(USER)
  avatarUrl     String?
  emailVerified DateTime?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  orders  Order[]
  reviews Review[]

  @@index([role])
  @@index([createdAt])
  @@map("users")
}

model Category {
  id       String     @id @default(uuid())
  name     String
  slug     String     @unique
  parentId String?
  parent   Category?  @relation("CategoryTree", fields: [parentId], references: [id])
  children Category[] @relation("CategoryTree")
  products Product[]

  @@map("categories")
}

model Product {
  id          String   @id @default(uuid())
  name        String
  slug        String   @unique
  description String?
  price       Int      @default(0)
  stock       Int      @default(0)
  categoryId  String
  category    Category @relation(fields: [categoryId], references: [id])
  status      String   @default("draft")
  rating      Float    @default(0)
  ratingCount Int      @default(0)
  images      String[]
  metadata    Json?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  orderItems OrderItem[]
  reviews    Review[]

  @@index([categoryId])
  @@index([status])
  @@index([price])
  @@index([status, categoryId])
  @@map("products")
}

model Order {
  id          String      @id @default(uuid())
  orderNumber String      @unique
  userId      String
  user        User        @relation(fields: [userId], references: [id])
  status      OrderStatus @default(PENDING)
  subtotal    Int         @default(0)
  tax         Int         @default(0)
  total       Int         @default(0)
  notes       String?
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt

  items    OrderItem[]
  payment  Payment?

  @@index([userId])
  @@index([status])
  @@index([createdAt])
  @@map("orders")
}

model OrderItem {
  id        String  @id @default(uuid())
  orderId   String
  order     Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  productId String
  product   Product @relation(fields: [productId], references: [id])
  quantity  Int     @default(1)
  unitPrice Int
  total     Int

  @@map("order_items")
}

model Payment {
  id            String   @id @default(uuid())
  orderId       String   @unique
  order         Order    @relation(fields: [orderId], references: [id])
  method        String
  amount        Int
  status        String   @default("pending")
  transactionId String?
  paidAt        DateTime?
  createdAt     DateTime @default(now())

  @@map("payments")
}

model Review {
  id        String   @id @default(uuid())
  productId String
  product   Product  @relation(fields: [productId], references: [id])
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  rating    Int
  comment   String?
  createdAt DateTime @default(now())

  @@unique([productId, userId])
  @@map("reviews")
}
```

---

## Client Singleton

```typescript
// src/lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'warn', 'error'] : ['error'],
});

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

---

## CRUD Operations

```typescript
// src/services/product.service.ts
import { prisma } from '@/lib/prisma';
import { Prisma } from '@prisma/client';

// ── List with filters + pagination ──
export async function listProducts(options: {
  category?: string; search?: string; status?: string;
  sortBy?: string; page?: number; limit?: number;
}) {
  const { page = 1, limit = 20 } = options;
  const where: Prisma.ProductWhereInput = {};

  if (options.status) where.status = options.status;
  if (options.category) where.category = { slug: options.category };
  if (options.search) {
    where.OR = [
      { name: { contains: options.search, mode: 'insensitive' } },
      { description: { contains: options.search, mode: 'insensitive' } },
    ];
  }

  const orderBy: Prisma.ProductOrderByWithRelationInput = (() => {
    switch (options.sortBy) {
      case 'price_asc': return { price: 'asc' };
      case 'price_desc': return { price: 'desc' };
      case 'rating': return { rating: 'desc' };
      default: return { createdAt: 'desc' };
    }
  })();

  const [data, total] = await prisma.$transaction([
    prisma.product.findMany({
      where, orderBy,
      skip: (page - 1) * limit,
      take: limit,
      include: { category: { select: { name: true, slug: true } } },
    }),
    prisma.product.count({ where }),
  ]);

  return { data, total, page, totalPages: Math.ceil(total / limit) };
}

// ── Create order with transaction ──
export async function createOrder(userId: string, items: { productId: string; quantity: number }[]) {
  return prisma.$transaction(async (tx) => {
    let subtotal = 0;

    // Validate stock and calculate totals
    const orderItems = await Promise.all(items.map(async (item) => {
      const product = await tx.product.findUniqueOrThrow({ where: { id: item.productId } });

      if (product.stock < item.quantity) {
        throw new Error(`Insufficient stock for ${product.name}`);
      }

      // Decrement stock
      await tx.product.update({
        where: { id: item.productId },
        data: { stock: { decrement: item.quantity } },
      });

      const total = product.price * item.quantity;
      subtotal += total;

      return { productId: item.productId, quantity: item.quantity, unitPrice: product.price, total };
    }));

    const tax = Math.round(subtotal * 0.11);
    const orderNumber = `ORD-${Date.now()}-${Math.random().toString(36).slice(2, 6).toUpperCase()}`;

    return tx.order.create({
      data: {
        orderNumber, userId, subtotal, tax, total: subtotal + tax,
        items: { create: orderItems },
      },
      include: { items: { include: { product: true } } },
    });
  });
}
```

---

## Migration Commands

```bash
# Create migration from schema changes
npx prisma migrate dev --name add_reviews_table

# Apply migrations (production)
npx prisma migrate deploy

# Reset database (dev only)
npx prisma migrate reset

# Generate client
npx prisma generate

# Studio (GUI)
npx prisma studio

# Seed
npx prisma db seed
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Singleton** | Global PrismaClient to prevent connection exhaustion |
| **$transaction** | Use for multi-model writes and stock operations |
| **select/include** | Only fetch fields you need |
| **Prisma.XxxWhereInput** | Use generated types for dynamic filters |
| **@@index** | Add indexes for query patterns |
| **@@map** | Map model names to snake_case table names |
| **@updatedAt** | Auto-update timestamp on changes |
| **Enums** | Use Prisma enums for type-safe status fields |
| **Migrations** | Always use `migrate dev` in development |
| **Seeding** | Use `prisma db seed` for test data |

---

## Rules Integration
- **Schema**: Models with relations, indexes, enums, @@map
- **Client**: Singleton pattern for connection management
- **Queries**: Filtered listing with pagination, dynamic orderBy
- **Transactions**: Order creation with stock validation
- **Migrations**: dev for development, deploy for production
