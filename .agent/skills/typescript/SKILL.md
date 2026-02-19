---
name: TypeScript
description: Skill for TypeScript development — covering type system, generics, utility types, decorators, enums, interfaces, type guards, module patterns, strict mode, and integration with React, Node.js, and build tools.
---

# TypeScript Skill

## Overview
TypeScript is a typed superset of JavaScript that compiles to plain JavaScript. This skill covers the TypeScript type system, advanced patterns, and best practices following official TypeScript documentation standards.

**Reference**: [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)

## Configuration (tsconfig.json)
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/utils/*": ["./src/utils/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

## Core Types
```typescript
// Primitives
const name: string = "John";
const age: number = 30;
const active: boolean = true;
const id: bigint = 100n;
const sym: symbol = Symbol("key");

// Special types
const nothing: null = null;
const notDefined: undefined = undefined;
const anything: unknown = getExternalData();  // ✅ safer than any
const neverReturn: never = throwError();      // function never returns

// ❌ NEVER use `any` — use `unknown` instead
// let data: any;    ← BAD
let data: unknown;   // ← GOOD, forces type checking before use
```

## Interfaces & Types
```typescript
// Interface — preferred for object shapes (extensible)
interface User {
  readonly id: string;
  name: string;
  email: string;
  age?: number;              // optional
  role: "admin" | "user";    // union literal
}

// Type alias — preferred for unions, intersections, utility types
type ID = string | number;
type Status = "active" | "inactive" | "pending";
type Coordinate = [number, number];  // tuple

// Extending
interface Admin extends User {
  permissions: string[];
}

// Intersection
type AdminUser = User & { permissions: string[] };

// Index signature
interface Dictionary<T> {
  [key: string]: T;
}

// Mapped types
type Readonly<T> = { readonly [K in keyof T]: T[K] };
type Optional<T> = { [K in keyof T]?: T[K] };
```

## Generics
```typescript
// Generic function
function getFirst<T>(arr: T[]): T | undefined {
  return arr[0];
}

// Generic with constraint
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Generic interface
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
  timestamp: string;
}

// Generic class
class Repository<T extends { id: string }> {
  private items: Map<string, T> = new Map();

  findById(id: string): T | undefined {
    return this.items.get(id);
  }

  save(item: T): void {
    this.items.set(item.id, item);
  }
}

// Generic with default
interface PaginatedResult<T, M = Record<string, unknown>> {
  data: T[];
  meta: M;
  total: number;
}
```

## Utility Types
```typescript
// Built-in utility types
type UserPartial = Partial<User>;           // All properties optional
type UserRequired = Required<User>;         // All properties required
type UserReadonly = Readonly<User>;          // All properties readonly
type UserPick = Pick<User, "id" | "name">;  // Pick specific properties
type UserOmit = Omit<User, "age">;          // Omit specific properties
type UserRecord = Record<string, User>;     // Key-value record

// Extract & Exclude
type NumOrStr = string | number | boolean;
type OnlyStr = Extract<NumOrStr, string>;      // string
type NoStr = Exclude<NumOrStr, string>;        // number | boolean

// ReturnType & Parameters
type FnReturn = ReturnType<typeof myFunction>;
type FnParams = Parameters<typeof myFunction>;

// NonNullable
type MaybeStr = string | null | undefined;
type DefiniteStr = NonNullable<MaybeStr>;      // string

// Awaited (unwrap Promise)
type ResolvedData = Awaited<Promise<User>>;    // User
```

## Type Guards & Narrowing
```typescript
// typeof guard
function process(value: string | number) {
  if (typeof value === "string") {
    return value.toUpperCase();  // TypeScript knows it's string
  }
  return value.toFixed(2);       // TypeScript knows it's number
}

// instanceof guard
function handleError(error: unknown) {
  if (error instanceof Error) {
    console.error(error.message);
  }
}

// Custom type guard (type predicate)
interface Cat { meow(): void; }
interface Dog { bark(): void; }

function isCat(animal: Cat | Dog): animal is Cat {
  return "meow" in animal;
}

// Discriminated union
interface Circle { kind: "circle"; radius: number; }
interface Square { kind: "square"; side: number; }
type Shape = Circle | Square;

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle": return Math.PI * shape.radius ** 2;
    case "square": return shape.side ** 2;
  }
}

// Assertion function
function assertDefined<T>(val: T | null | undefined, msg: string): asserts val is T {
  if (val == null) throw new Error(msg);
}
```

## Enums
```typescript
// String enum (preferred)
enum Status {
  Active = "ACTIVE",
  Inactive = "INACTIVE",
  Pending = "PENDING",
}

// Const enum (inlined at compile time)
const enum Direction {
  Up = "UP",
  Down = "DOWN",
  Left = "LEFT",
  Right = "RIGHT",
}

// ✅ Alternative: use `as const` object (tree-shakeable)
const STATUS = {
  Active: "ACTIVE",
  Inactive: "INACTIVE",
  Pending: "PENDING",
} as const;
type StatusType = (typeof STATUS)[keyof typeof STATUS]; // "ACTIVE" | "INACTIVE" | "PENDING"
```

## Async Patterns
```typescript
// Async function with typed return
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return response.json() as Promise<User>;
}

// Generic async wrapper
async function tryCatch<T>(fn: () => Promise<T>): Promise<[T, null] | [null, Error]> {
  try {
    const data = await fn();
    return [data, null];
  } catch (error) {
    return [null, error instanceof Error ? error : new Error(String(error))];
  }
}
```

## Decorators (Stage 3)
```typescript
// Class decorator
function Injectable(target: new (...args: any[]) => any) {
  // register in DI container
}

// Method decorator
function Log(target: any, key: string, descriptor: PropertyDescriptor) {
  const original = descriptor.value;
  descriptor.value = function (...args: any[]) {
    console.log(`Calling ${key} with`, args);
    return original.apply(this, args);
  };
}

@Injectable
class UserService {
  @Log
  findById(id: string): User | undefined {
    // ...
  }
}
```

## Module Patterns
```typescript
// Named exports (preferred)
export interface User { id: string; name: string; }
export function createUser(name: string): User { /* ... */ }
export const MAX_USERS = 100;

// Re-export (barrel file)
// src/models/index.ts
export { User } from "./user";
export { Product } from "./product";
export { Order } from "./order";

// Type-only imports
import type { User } from "./models";
import { type User, createUser } from "./models";
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **`strict: true`** | Always enable strict mode in tsconfig |
| **No `any`** | Use `unknown` for truly unknown types |
| **Prefer `interface`** | For object shapes; use `type` for unions/utilities |
| **Use `as const`** | Over enums for tree-shakeability |
| **Discriminated unions** | For type-safe state machines |
| **Exhaustive checks** | Use `never` in switch default for compile-time safety |
| **Type-only imports** | Use `import type` for types not used at runtime |
| **Readonly by default** | Mark properties `readonly` unless mutation is needed |
| **Generic constraints** | Use `extends` to constrain generics |
| **Avoid type assertions** | Prefer type guards over `as` casts |
