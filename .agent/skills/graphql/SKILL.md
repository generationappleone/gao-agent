---
name: GraphQL
description: Skill for building GraphQL APIs — covering schema design, queries, mutations, subscriptions, resolvers, Apollo Server/Client, type definitions, pagination, error handling, and security best practices.
---

# GraphQL Skill

## Overview
GraphQL is a query language for APIs that gives clients the power to request exactly the data they need. It uses a strongly-typed schema, resolvers for data fetching, and supports queries, mutations, and subscriptions. Apollo Server is the most popular GraphQL server for Node.js.

**References**:
- [GraphQL Documentation](https://graphql.org/learn/)
- [Apollo Server](https://www.apollographql.com/docs/apollo-server/)
- [Apollo Client](https://www.apollographql.com/docs/react/)

---

## Setup

```bash
npm install @apollo/server graphql
```

```typescript
// src/graphql/server.ts
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { typeDefs } from './schema';
import { resolvers } from './resolvers';
import { createContext } from './context';

const server = new ApolloServer({
  typeDefs,
  resolvers,
  introspection: process.env.NODE_ENV !== 'production',
  formatError: (error) => ({
    message: error.message,
    code: error.extensions?.code,
    path: error.path,
  }),
});

await server.start();

app.use('/graphql', expressMiddleware(server, {
  context: createContext,
}));
```

---

## Schema

```graphql
# src/graphql/schema.graphql
type Query {
  products(input: ProductFilterInput): ProductConnection!
  product(slug: String!): Product!
  categories: [Category!]!
  me: User!
}

type Mutation {
  register(input: RegisterInput!): AuthPayload!
  login(input: LoginInput!): AuthPayload!
  createProduct(input: CreateProductInput!): Product!
  updateProduct(id: ID!, input: UpdateProductInput!): Product!
  deleteProduct(id: ID!): Boolean!
  createOrder(input: CreateOrderInput!): Order!
}

type Subscription {
  orderStatusChanged(orderId: ID!): Order!
  newNotification: Notification!
}

# ── Types ──
type Product {
  id: ID!
  name: String!
  slug: String!
  description: String
  price: Int!
  stock: Int!
  category: Category!
  status: ProductStatus!
  rating: Float!
  ratingCount: Int!
  images: [String!]!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Category {
  id: ID!
  name: String!
  slug: String!
  products(limit: Int): [Product!]!
}

type User {
  id: ID!
  email: String!
  name: String!
  role: Role!
  orders: [Order!]!
  createdAt: DateTime!
}

type Order {
  id: ID!
  orderNumber: String!
  user: User!
  items: [OrderItem!]!
  status: OrderStatus!
  subtotal: Int!
  tax: Int!
  total: Int!
  createdAt: DateTime!
}

type OrderItem {
  id: ID!
  product: Product!
  quantity: Int!
  unitPrice: Int!
  total: Int!
}

type AuthPayload {
  accessToken: String!
  refreshToken: String!
  user: User!
}

# ── Pagination ──
type ProductConnection {
  data: [Product!]!
  total: Int!
  page: Int!
  totalPages: Int!
}

# ── Inputs ──
input ProductFilterInput {
  category: String
  search: String
  status: ProductStatus
  sortBy: SortBy
  page: Int = 1
  limit: Int = 20
}

input CreateProductInput {
  name: String!
  description: String
  price: Int!
  stock: Int!
  categoryId: ID!
  images: [String!]
}

input UpdateProductInput {
  name: String
  description: String
  price: Int
  stock: Int
  status: ProductStatus
}

input CreateOrderInput {
  items: [OrderItemInput!]!
  notes: String
}

input OrderItemInput {
  productId: ID!
  quantity: Int!
}

input RegisterInput {
  email: String!
  password: String!
  name: String!
}

input LoginInput {
  email: String!
  password: String!
}

# ── Enums ──
enum ProductStatus { DRAFT ACTIVE ARCHIVED }
enum OrderStatus { PENDING PROCESSING SHIPPED DELIVERED CANCELLED }
enum Role { USER ADMIN EDITOR }
enum SortBy { NEWEST PRICE_ASC PRICE_DESC RATING }

scalar DateTime
```

---

## Resolvers

```typescript
// src/graphql/resolvers/product.resolver.ts
import { GraphQLError } from 'graphql';

export const productResolvers = {
  Query: {
    products: async (_: any, { input }: any, { dataSources }: Context) => {
      const { category, search, status, sortBy, page = 1, limit = 20 } = input || {};
      return dataSources.productService.list({ category, search, status, sortBy, page, limit });
    },

    product: async (_: any, { slug }: { slug: string }, { dataSources }: Context) => {
      const product = await dataSources.productService.getBySlug(slug);
      if (!product) throw new GraphQLError('Product not found', { extensions: { code: 'NOT_FOUND' } });
      return product;
    },
  },

  Mutation: {
    createProduct: async (_: any, { input }: any, { dataSources, user }: Context) => {
      if (!user || user.role !== 'ADMIN') {
        throw new GraphQLError('Unauthorized', { extensions: { code: 'FORBIDDEN' } });
      }
      return dataSources.productService.create(input);
    },

    createOrder: async (_: any, { input }: any, { dataSources, user }: Context) => {
      if (!user) throw new GraphQLError('Authentication required', { extensions: { code: 'UNAUTHENTICATED' } });

      return dataSources.db.$transaction(async (tx: any) => {
        let subtotal = 0;
        const orderItems = [];

        for (const item of input.items) {
          const product = await tx.product.findUniqueOrThrow({ where: { id: item.productId } });
          if (product.stock < item.quantity) {
            throw new GraphQLError(`Insufficient stock: ${product.name}`, { extensions: { code: 'BAD_USER_INPUT' } });
          }

          await tx.product.update({ where: { id: item.productId }, data: { stock: { decrement: item.quantity } } });

          const total = product.price * item.quantity;
          subtotal += total;
          orderItems.push({ productId: item.productId, quantity: item.quantity, unitPrice: product.price, total });
        }

        const tax = Math.round(subtotal * 0.11);

        return tx.order.create({
          data: {
            orderNumber: `ORD-${Date.now()}`,
            userId: user.id, subtotal, tax, total: subtotal + tax,
            items: { create: orderItems },
          },
          include: { items: { include: { product: true } }, user: true },
        });
      });
    },
  },

  Product: {
    category: (parent: any, _: any, { dataSources }: Context) => {
      return dataSources.categoryService.getById(parent.categoryId);
    },
  },
};
```

---

## Context with Authentication

```typescript
// src/graphql/context.ts
import { verifyAccessToken } from '../services/jwt.service';

export interface Context {
  user: { id: string; email: string; role: string } | null;
  dataSources: DataSources;
}

export async function createContext({ req }: { req: Request }): Promise<Context> {
  let user = null;

  const token = req.headers.authorization?.split(' ')[1];
  if (token) {
    try {
      const payload = verifyAccessToken(token);
      user = { id: payload.sub, email: payload.email, role: payload.role };
    } catch { /* Token invalid, user stays null */ }
  }

  return { user, dataSources: createDataSources() };
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Schema-first** | Define schema in `.graphql` files, implement resolvers |
| **Input types** | Use `input` for mutations, `type` for responses |
| **Pagination** | Connection pattern with `data`, `total`, `page` |
| **Error codes** | Use `extensions.code` (NOT_FOUND, FORBIDDEN, etc.) |
| **N+1 problem** | Use DataLoader for batching field resolvers |
| **Auth context** | Verify JWT in context factory, check in resolvers |
| **Transactions** | Use DB transactions for multi-model mutations |
| **Depth limiting** | Limit query depth to prevent abuse |
| **Introspection** | Disable in production |
| **Validation** | Validate inputs in resolvers, use enums for fixed sets |

---

## Rules Integration
- **Schema**: Types, inputs, enums, connections, scalars
- **Resolvers**: Query/Mutation with auth checks and transactions
- **Context**: JWT verification, data sources injection
- **Pagination**: Connection pattern with total, page, totalPages
- **Security**: Auth guards, error codes, depth limiting
