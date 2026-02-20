---
name: TypeScript
description: Skill for TypeScript development — covering type system, generics, utility types, decorators, enums, interfaces, type guards, module patterns, strict mode, and integration with React, Node.js, and build tools.
---

# TypeScript Skill

## Overview
TypeScript is a statically typed superset of JavaScript that compiles to plain JavaScript. It provides type safety, interfaces, generics, utility types, type guards, discriminated unions, and module patterns. TypeScript improves developer experience with IDE support and catches errors at compile time.

**References**:
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)

---

## Configuration

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

## Core Patterns

```typescript
// Interfaces and Types
interface User {
  id: string;
  email: string;
  name: string;
  role: 'user' | 'admin' | 'editor';
  createdAt: Date;
}

type CreateUserInput = Pick<User, 'email' | 'name'> & { password: string };
type UpdateUserInput = Partial<Pick<User, 'name' | 'email'>>;
type UserResponse = Omit<User, 'createdAt'> & { createdAt: string };

// Generics
interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  totalPages: number;
}

interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: string;
}

// Type guards
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && obj !== null && 'email' in obj && 'role' in obj;
}

// Discriminated unions
type Result<T, E = Error> = { success: true; data: T } | { success: false; error: E };

function handleResult<T>(result: Result<T>) {
  if (result.success) {
    console.log(result.data); // Type narrowed to T
  } else {
    console.error(result.error); // Type narrowed to Error
  }
}

// Mapped types
type Nullable<T> = { [K in keyof T]: T[K] | null };
type ReadonlyDeep<T> = { readonly [K in keyof T]: T[K] extends object ? ReadonlyDeep<T[K]> : T[K] };

// Template literal types
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type ApiRoute = `/api/${string}`;

// Enum alternatives (const object)
const OrderStatus = { PENDING: 'pending', PROCESSING: 'processing', SHIPPED: 'shipped', DELIVERED: 'delivered' } as const;
type OrderStatus = typeof OrderStatus[keyof typeof OrderStatus];
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **strict mode** | Always enable `strict: true` |
| **interface vs type** | Interface for objects, type for unions/utilities |
| **Generics** | Reusable types for API responses, pagination |
| **Type guards** | Runtime type checking with `is` keyword |
| **Discriminated unions** | Pattern for Result/Either types |
| **const assertions** | `as const` for literal types |
| **Utility types** | Pick, Omit, Partial, Required, Record |
| **Enums** | Prefer const objects over enums |
| **unknown over any** | Use `unknown` for safe dynamic types |
| **Zod** | Runtime validation + TypeScript inference |

---

## Rules Integration
- **Types**: Interfaces, generics, discriminated unions
- **Config**: Strict mode, path aliases, ES2022 target
- **Patterns**: Result type, type guards, mapped types
- **Validation**: Zod for runtime + compile-time safety
