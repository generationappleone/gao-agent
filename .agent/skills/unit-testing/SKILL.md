---
name: Unit Testing Patterns
description: Skill for writing effective unit tests — covering AAA pattern, mocking, fixtures, test doubles, code coverage, TDD, property-based testing, and frameworks (Jest, Vitest, PHPUnit, pytest).
---

# Unit Testing Skill

## Overview
Unit tests verify individual functions, methods, or components in isolation. They are fast, deterministic, and form the foundation of the testing pyramid. This skill covers patterns and frameworks for TypeScript/JavaScript (Vitest/Jest), with principles applicable to any language.

**References**:
- [Vitest Documentation](https://vitest.dev/)
- [Jest Documentation](https://jestjs.io/)
- [Testing Library](https://testing-library.com/)

---

## Setup (Vitest)

```bash
npm install -D vitest @vitest/coverage-v8 @testing-library/react @testing-library/jest-dom
```

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',  // or 'jsdom' for browser/React
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/**/*.d.ts', 'src/types/**'],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80,
      },
    },
    setupFiles: ['./src/test/setup.ts'],
  },
  resolve: {
    alias: { '@': path.resolve(__dirname, 'src') },
  },
});
```

```typescript
// src/test/setup.ts
import { beforeAll, afterAll, afterEach } from 'vitest';

// Global setup
beforeAll(() => {
  // Start test database, mock server, etc.
});

afterEach(() => {
  vi.restoreAllMocks();
});

afterAll(() => {
  // Cleanup
});
```

---

## AAA Pattern (Arrange-Act-Assert)

```typescript
// src/utils/math.ts
export function calculateDiscount(price: number, percentage: number): number {
  if (price < 0 || percentage < 0 || percentage > 100) {
    throw new Error('Invalid input');
  }
  return Math.round(price * (1 - percentage / 100));
}

// src/utils/math.test.ts
import { describe, it, expect } from 'vitest';
import { calculateDiscount } from './math';

describe('calculateDiscount', () => {
  // ── Happy path ──
  it('should apply 10% discount', () => {
    // Arrange
    const price = 100000;
    const percentage = 10;

    // Act
    const result = calculateDiscount(price, percentage);

    // Assert
    expect(result).toBe(90000);
  });

  it('should apply 0% discount (no change)', () => {
    expect(calculateDiscount(50000, 0)).toBe(50000);
  });

  it('should apply 100% discount (free)', () => {
    expect(calculateDiscount(50000, 100)).toBe(0);
  });

  it('should round to nearest integer', () => {
    expect(calculateDiscount(99, 33)).toBe(66);
  });

  // ── Edge cases ──
  it('should throw for negative price', () => {
    expect(() => calculateDiscount(-100, 10)).toThrow('Invalid input');
  });

  it('should throw for percentage > 100', () => {
    expect(() => calculateDiscount(100, 150)).toThrow('Invalid input');
  });

  it('should throw for negative percentage', () => {
    expect(() => calculateDiscount(100, -10)).toThrow('Invalid input');
  });
});
```

---

## Testing Services (with Mocking)

```typescript
// src/services/product.service.ts
export class ProductService {
  constructor(
    private repository: ProductRepository,
    private cache: CacheService,
  ) {}

  async getProduct(id: string): Promise<Product> {
    const cached = await this.cache.get(`product:${id}`);
    if (cached) return cached;

    const product = await this.repository.findById(id);
    if (!product) throw new NotFoundError(`Product ${id} not found`);

    await this.cache.set(`product:${id}`, product, 3600);
    return product;
  }

  async createProduct(data: CreateProductDto): Promise<Product> {
    const existing = await this.repository.findBySlug(data.slug);
    if (existing) throw new ConflictError('Product with this slug already exists');

    return this.repository.create(data);
  }
}

// src/services/product.service.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { ProductService } from './product.service';

describe('ProductService', () => {
  let service: ProductService;
  let mockRepo: any;
  let mockCache: any;

  beforeEach(() => {
    mockRepo = {
      findById: vi.fn(),
      findBySlug: vi.fn(),
      create: vi.fn(),
    };
    mockCache = {
      get: vi.fn(),
      set: vi.fn(),
    };
    service = new ProductService(mockRepo, mockCache);
  });

  describe('getProduct', () => {
    const product = { id: '1', name: 'Test', price: 100 };

    it('should return cached product if available', async () => {
      mockCache.get.mockResolvedValue(product);

      const result = await service.getProduct('1');

      expect(result).toEqual(product);
      expect(mockCache.get).toHaveBeenCalledWith('product:1');
      expect(mockRepo.findById).not.toHaveBeenCalled();  // Should NOT query DB
    });

    it('should fetch from DB and cache on cache miss', async () => {
      mockCache.get.mockResolvedValue(null);
      mockRepo.findById.mockResolvedValue(product);

      const result = await service.getProduct('1');

      expect(result).toEqual(product);
      expect(mockRepo.findById).toHaveBeenCalledWith('1');
      expect(mockCache.set).toHaveBeenCalledWith('product:1', product, 3600);
    });

    it('should throw NotFoundError when product does not exist', async () => {
      mockCache.get.mockResolvedValue(null);
      mockRepo.findById.mockResolvedValue(null);

      await expect(service.getProduct('999')).rejects.toThrow('Product 999 not found');
    });
  });

  describe('createProduct', () => {
    const input = { name: 'New Product', slug: 'new-product', price: 100 };

    it('should create product when slug is unique', async () => {
      mockRepo.findBySlug.mockResolvedValue(null);
      mockRepo.create.mockResolvedValue({ id: '1', ...input });

      const result = await service.createProduct(input);

      expect(result.id).toBe('1');
      expect(mockRepo.create).toHaveBeenCalledWith(input);
    });

    it('should throw ConflictError when slug already exists', async () => {
      mockRepo.findBySlug.mockResolvedValue({ id: '2', slug: 'new-product' });

      await expect(service.createProduct(input)).rejects.toThrow('slug already exists');
      expect(mockRepo.create).not.toHaveBeenCalled();
    });
  });
});
```

---

## Testing API Routes

```typescript
// src/routes/products.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import request from 'supertest';
import { createApp } from '../app';

describe('GET /api/products', () => {
  const app = createApp();

  it('should return paginated products', async () => {
    const res = await request(app)
      .get('/api/products')
      .query({ page: 1, limit: 10 })
      .expect(200);

    expect(res.body.data).toBeInstanceOf(Array);
    expect(res.body.total).toBeGreaterThanOrEqual(0);
    expect(res.body.page).toBe(1);
  });

  it('should filter by category', async () => {
    const res = await request(app)
      .get('/api/products')
      .query({ category: 'electronics' })
      .expect(200);

    res.body.data.forEach((product: any) => {
      expect(product.category).toBe('electronics');
    });
  });
});

describe('POST /api/products', () => {
  it('should require authentication', async () => {
    await request(app)
      .post('/api/products')
      .send({ name: 'Test' })
      .expect(401);
  });

  it('should create product with valid data', async () => {
    const res = await request(app)
      .post('/api/products')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ name: 'New Product', price: 100, categoryId: 'cat-1' })
      .expect(201);

    expect(res.body.id).toBeDefined();
    expect(res.body.name).toBe('New Product');
  });

  it('should validate required fields', async () => {
    const res = await request(app)
      .post('/api/products')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({})
      .expect(400);

    expect(res.body.error).toBeDefined();
  });
});
```

---

## Mocking Techniques

```typescript
// ── vi.fn() — create mock function ──
const mockFn = vi.fn();
mockFn.mockReturnValue(42);
mockFn.mockResolvedValue({ id: '1' });  // async
mockFn.mockImplementation((x) => x * 2);

// ── vi.mock() — mock module ──
vi.mock('../lib/email', () => ({
  sendEmail: vi.fn().mockResolvedValue({ messageId: '123' }),
}));

// ── vi.spyOn() — spy on existing method ──
const spy = vi.spyOn(console, 'error').mockImplementation(() => {});
// ... test
expect(spy).toHaveBeenCalledWith(expect.stringContaining('error'));

// ── Partial mock (keep original, override specific) ──
vi.mock('../lib/utils', async (importOriginal) => {
  const actual = await importOriginal<typeof import('../lib/utils')>();
  return {
    ...actual,
    getCurrentDate: vi.fn(() => new Date('2024-01-15')),
  };
});

// ── Fake timers ──
vi.useFakeTimers();
vi.setSystemTime(new Date('2024-01-01'));
// ... test time-dependent logic
vi.useRealTimers();
```

---

## React Component Testing

```tsx
// src/components/Counter.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Counter } from './Counter';

describe('Counter', () => {
  it('should render initial count', () => {
    render(<Counter initialCount={5} />);
    expect(screen.getByText('Count: 5')).toBeInTheDocument();
  });

  it('should increment on button click', () => {
    render(<Counter initialCount={0} />);
    fireEvent.click(screen.getByRole('button', { name: /increment/i }));
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
  });

  it('should call onChange callback', () => {
    const onChange = vi.fn();
    render(<Counter initialCount={0} onChange={onChange} />);
    fireEvent.click(screen.getByRole('button', { name: /increment/i }));
    expect(onChange).toHaveBeenCalledWith(1);
  });
});
```

---

## Commands

```bash
# Run all tests
npx vitest

# Run with coverage
npx vitest --coverage

# Run specific file
npx vitest src/services/product.service.test.ts

# Watch mode
npx vitest --watch

# UI mode
npx vitest --ui
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **AAA** | Arrange → Act → Assert structure for every test |
| **Descriptive names** | `should return cached product if available` |
| **One assertion** | Focus each test on one behavior |
| **Mock dependencies** | Inject mocks, don't mock implementation details |
| **Test behavior** | Test what it does, not how it does it |
| **Edge cases** | Test nulls, empties, boundaries, invalid inputs |
| **No implementation** | Don't test private methods directly |
| **Fast tests** | Mock I/O (DB, HTTP, filesystem) |
| **Coverage** | 80%+ lines, but don't chase 100% |
| **CI integration** | Run tests on every PR with coverage gates |

---

## Rules Integration
- **Framework**: Vitest (or Jest) with coverage and globals
- **Patterns**: AAA, mocking (vi.fn/mock/spyOn), fake timers
- **Testing**: Functions, services, API routes, React components
- **Coverage**: v8 provider with thresholds (80%+ lines)
- **CI**: Run on every PR, fail on coverage regression
