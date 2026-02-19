---
name: Prisma ORM
description: Skill for type-safe database access with Prisma ORM — covering schema design, migrations, CRUD operations, relations, transactions, raw queries, and integration with Node.js/TypeScript.
---

# Prisma ORM Skill

## Overview
Prisma is a next-generation ORM for Node.js and TypeScript providing type-safe database access, migrations, and a visual database browser.

**Reference**: [Prisma Documentation](https://www.prisma.io/docs)

## Schema (prisma/schema.prisma)
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  role      Role     @default(USER)
  posts     Post[]
  profile   Profile?
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
  @@index([email])
}

model Post {
  id        String   @id @default(uuid())
  title     String
  content   String?
  published Boolean  @default(false)
  authorId  String   @map("author_id")
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  tags      Tag[]
  createdAt DateTime @default(now()) @map("created_at")

  @@map("posts")
  @@index([authorId])
}

model Profile {
  id     String @id @default(uuid())
  bio    String?
  avatar String?
  userId String @unique @map("user_id")
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("profiles")
}

model Tag {
  id    String @id @default(uuid())
  name  String @unique
  posts Post[]

  @@map("tags")
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

## CRUD Operations
```typescript
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

// Create
const user = await prisma.user.create({
  data: { name: "John", email: "john@example.com", profile: { create: { bio: "Developer" } } },
  include: { profile: true },
});

// Read
const users = await prisma.user.findMany({
  where: { role: "ADMIN", name: { contains: "john", mode: "insensitive" } },
  include: { posts: { where: { published: true }, take: 5 } },
  orderBy: { createdAt: "desc" },
  skip: 0, take: 20,
});

const user = await prisma.user.findUnique({ where: { email: "john@example.com" } });

// Update
await prisma.user.update({ where: { id: userId }, data: { name: "Jane" } });

// Upsert
await prisma.user.upsert({
  where: { email: "john@example.com" },
  update: { name: "John Updated" },
  create: { name: "John", email: "john@example.com" },
});

// Delete
await prisma.user.delete({ where: { id: userId } });

// Transaction
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { name: "Author", email: "author@example.com" } }),
  prisma.post.create({ data: { title: "First Post", authorId: "..." } }),
]);

// Interactive transaction
await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id: userId } });
  if (!user) throw new Error("User not found");
  await tx.post.create({ data: { title: "New Post", authorId: user.id } });
});
```

## Migrations
```bash
npx prisma migrate dev --name init          # Create migration
npx prisma migrate deploy                    # Apply in production
npx prisma db push                           # Push schema (dev only)
npx prisma generate                          # Regenerate client
npx prisma studio                            # Visual database browser
npx prisma db seed                           # Run seed script
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **`@@map`** | Map to snake_case table/column names |
| **`@default(uuid())`** | UUID primary keys |
| **`@updatedAt`** | Auto-update timestamps |
| **`onDelete: Cascade`** | Define referential actions |
| **Transactions** | Use for multi-model operations |
| **`select` over `include`** | Select only needed fields |
| **Middleware** | Use for soft delete, audit logging |
| **Connection pooling** | Use `?connection_limit=5` in URL |
| **Seeding** | Create `prisma/seed.ts` for test data |
| **Type safety** | Leverage generated types everywhere |
