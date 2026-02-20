---
name: Design Patterns
description: Skill for software design patterns — covering GoF patterns (Creational, Structural, Behavioral), architectural patterns (Repository, CQRS, Event-Driven), and practical TypeScript/JavaScript implementations.
---

# Design Patterns Skill

## Overview
Design patterns are proven solutions to common software design problems. They include GoF patterns (Creational, Structural, Behavioral) and architectural patterns (Repository, CQRS, Event-Driven). This skill covers practical TypeScript implementations.

**References**:
- [Refactoring Guru](https://refactoring.guru/design-patterns)
- [Gang of Four Patterns](https://en.wikipedia.org/wiki/Design_Patterns)

---

## Repository Pattern

```typescript
// Generic repository interface
interface IRepository<T> {
  findById(id: string): Promise<T | null>;
  findMany(filter: Partial<T>, options?: { page: number; limit: number }): Promise<{ data: T[]; total: number }>;
  create(data: Omit<T, 'id' | 'createdAt'>): Promise<T>;
  update(id: string, data: Partial<T>): Promise<T>;
  delete(id: string): Promise<void>;
}

// Prisma implementation
class PrismaProductRepo implements IRepository<Product> {
  async findById(id: string) {
    return prisma.product.findUnique({ where: { id }, include: { category: true } });
  }
  async findMany(filter: Partial<Product>, options = { page: 1, limit: 20 }) {
    const [data, total] = await Promise.all([
      prisma.product.findMany({ where: filter as any, skip: (options.page - 1) * options.limit, take: options.limit }),
      prisma.product.count({ where: filter as any }),
    ]);
    return { data, total };
  }
  async create(data) { return prisma.product.create({ data }); }
  async update(id, data) { return prisma.product.update({ where: { id }, data }); }
  async delete(id) { await prisma.product.delete({ where: { id } }); }
}
```

---

## Strategy Pattern

```typescript
interface PaymentStrategy {
  process(amount: number, metadata: Record<string, any>): Promise<PaymentResult>;
}

class StripePayment implements PaymentStrategy {
  async process(amount: number, metadata: Record<string, any>) {
    const intent = await stripe.paymentIntents.create({ amount, currency: 'usd', metadata });
    return { transactionId: intent.id, status: 'pending', clientSecret: intent.client_secret };
  }
}

class MidtransPayment implements PaymentStrategy {
  async process(amount: number, metadata: Record<string, any>) {
    const snap = await midtrans.createTransaction({ transaction_details: { order_id: metadata.orderId, gross_amount: amount } });
    return { transactionId: snap.transaction_id, status: 'pending', redirectUrl: snap.redirect_url };
  }
}

// Usage
const strategies: Record<string, PaymentStrategy> = { stripe: new StripePayment(), midtrans: new MidtransPayment() };
const result = await strategies[method].process(amount, { orderId });
```

---

## Observer Pattern (Event Emitter)

```typescript
class EventBus {
  private listeners = new Map<string, Set<Function>>();

  on(event: string, handler: Function) {
    if (!this.listeners.has(event)) this.listeners.set(event, new Set());
    this.listeners.get(event)!.add(handler);
    return () => this.listeners.get(event)?.delete(handler);
  }

  emit(event: string, data?: any) {
    this.listeners.get(event)?.forEach(handler => handler(data));
  }
}

// Usage
const bus = new EventBus();
bus.on('order.created', (order) => sendConfirmationEmail(order));
bus.on('order.created', (order) => updateInventory(order));
bus.emit('order.created', order);
```

---

## Builder Pattern

```typescript
class QueryBuilder<T> {
  private filters: Record<string, any> = {};
  private sortField = 'createdAt';
  private sortDir: 'asc' | 'desc' = 'desc';
  private _page = 1;
  private _limit = 20;

  where(field: string, value: any) { this.filters[field] = value; return this; }
  orderBy(field: string, dir: 'asc' | 'desc' = 'asc') { this.sortField = field; this.sortDir = dir; return this; }
  page(p: number) { this._page = p; return this; }
  limit(l: number) { this._limit = l; return this; }

  build() {
    return { where: this.filters, orderBy: { [this.sortField]: this.sortDir }, skip: (this._page - 1) * this._limit, take: this._limit };
  }
}

// Usage
const query = new QueryBuilder().where('status', 'active').where('categoryId', catId).orderBy('price', 'asc').page(2).build();
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Repository** | Abstract data access behind interfaces |
| **Strategy** | Swap algorithms at runtime |
| **Observer** | Decouple event producers from consumers |
| **Builder** | Construct complex objects step-by-step |
| **Factory** | Create objects without specifying exact class |
| **Singleton** | Single instance (DB connection, config) |
| **Adapter** | Convert interface to another interface |
| **Decorator** | Add behavior without modifying class |
| **CQRS** | Separate read/write models |
| **Dependency injection** | Inject dependencies via constructor |

---

## Rules Integration
- **Repository**: Data access abstraction
- **Strategy**: Payment, notification, auth strategies
- **Observer**: Event-driven decoupling
- **Builder**: Query construction, config objects
