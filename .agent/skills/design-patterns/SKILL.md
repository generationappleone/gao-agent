---
name: Design Patterns
description: Skill for software design patterns — covering GoF patterns (Creational, Structural, Behavioral), architectural patterns (Repository, CQRS, Event-Driven), and practical TypeScript/JavaScript implementations.
---

# Design Patterns Skill

## Overview
Design patterns are proven solutions to recurring software design problems. This skill covers Gang of Four patterns and modern architectural patterns.

**Reference**: Design Patterns: Elements of Reusable Object-Oriented Software (GoF)

## Creational Patterns

### Factory Method
```typescript
interface Logger { log(message: string): void; }

class ConsoleLogger implements Logger { log(msg: string) { console.log(msg); } }
class FileLogger implements Logger { log(msg: string) { fs.appendFileSync("app.log", msg + "\n"); } }

class LoggerFactory {
  static create(type: "console" | "file"): Logger {
    switch (type) {
      case "console": return new ConsoleLogger();
      case "file": return new FileLogger();
      default: throw new Error(`Unknown logger type: ${type}`);
    }
  }
}
```

### Builder
```typescript
class QueryBuilder {
  private table = "";
  private conditions: string[] = [];
  private orderField = "";
  private limitCount = 0;

  from(table: string) { this.table = table; return this; }
  where(condition: string) { this.conditions.push(condition); return this; }
  orderBy(field: string) { this.orderField = field; return this; }
  limit(count: number) { this.limitCount = count; return this; }

  build(): string {
    let query = `SELECT * FROM ${this.table}`;
    if (this.conditions.length) query += ` WHERE ${this.conditions.join(" AND ")}`;
    if (this.orderField) query += ` ORDER BY ${this.orderField}`;
    if (this.limitCount) query += ` LIMIT ${this.limitCount}`;
    return query;
  }
}

const query = new QueryBuilder().from("users").where("active = true").orderBy("name").limit(20).build();
```

### Singleton
```typescript
class Database {
  private static instance: Database;
  private constructor() { /* connect */ }
  static getInstance(): Database {
    if (!Database.instance) Database.instance = new Database();
    return Database.instance;
  }
}
```

## Structural Patterns

### Repository
```typescript
interface Repository<T> {
  findById(id: string): Promise<T | null>;
  findAll(filter?: Partial<T>): Promise<T[]>;
  create(data: Omit<T, "id">): Promise<T>;
  update(id: string, data: Partial<T>): Promise<T>;
  delete(id: string): Promise<void>;
}

class UserRepository implements Repository<User> {
  constructor(private db: PrismaClient) {}
  async findById(id: string) { return this.db.user.findUnique({ where: { id } }); }
  async findAll(filter?: Partial<User>) { return this.db.user.findMany({ where: filter }); }
  async create(data: Omit<User, "id">) { return this.db.user.create({ data }); }
  async update(id: string, data: Partial<User>) { return this.db.user.update({ where: { id }, data }); }
  async delete(id: string) { await this.db.user.delete({ where: { id } }); }
}
```

### Adapter
```typescript
interface PaymentGateway {
  charge(amount: number, currency: string): Promise<PaymentResult>;
}

class StripeAdapter implements PaymentGateway {
  constructor(private stripe: Stripe) {}
  async charge(amount: number, currency: string) {
    const intent = await this.stripe.paymentIntents.create({ amount: amount * 100, currency });
    return { id: intent.id, status: intent.status };
  }
}
```

## Behavioral Patterns

### Observer / Event Emitter
```typescript
class EventBus {
  private listeners = new Map<string, Function[]>();

  on(event: string, callback: Function) {
    const handlers = this.listeners.get(event) || [];
    handlers.push(callback);
    this.listeners.set(event, handlers);
  }

  emit(event: string, data?: any) {
    this.listeners.get(event)?.forEach(cb => cb(data));
  }

  off(event: string, callback: Function) {
    const handlers = this.listeners.get(event) || [];
    this.listeners.set(event, handlers.filter(cb => cb !== callback));
  }
}
```

### Strategy
```typescript
interface SortStrategy<T> { sort(data: T[]): T[]; }

class QuickSort<T> implements SortStrategy<T> { sort(data: T[]) { /* ... */ return data; } }
class MergeSort<T> implements SortStrategy<T> { sort(data: T[]) { /* ... */ return data; } }

class Sorter<T> {
  constructor(private strategy: SortStrategy<T>) {}
  setStrategy(strategy: SortStrategy<T>) { this.strategy = strategy; }
  sort(data: T[]) { return this.strategy.sort(data); }
}
```

## Pattern Selection Guide

| Problem | Pattern |
|---------|---------|
| Create objects without specifying class | **Factory** |
| Build complex objects step by step | **Builder** |
| Single shared instance | **Singleton** |
| Decouple data access from business logic | **Repository** |
| Adapt incompatible interfaces | **Adapter** |
| React to state changes | **Observer** |
| Swap algorithms at runtime | **Strategy** |
| Add behavior without modifying class | **Decorator** |
| Simplify complex subsystem | **Facade** |
| Undo/redo operations | **Command** |
