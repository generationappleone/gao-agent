---
name: JavaScript
description: Skill for modern JavaScript development, covering ES2024+ features, Node.js backend, module systems, async patterns, error handling, testing, and tooling best practices.
---

# JavaScript Skill

## Overview
Modern JavaScript (ES2024+) provides powerful features for both frontend and backend development. Key features include optional chaining, nullish coalescing, top-level await, structuredClone, Array.at(), Object.groupBy(), Promise.withResolvers(), and module patterns.

**References**:
- [MDN JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [TC39 Proposals](https://github.com/tc39/proposals)

---

## Modern Features

```javascript
// Optional chaining + nullish coalescing
const city = user?.address?.city ?? 'Unknown';
const name = user?.profile?.name ?? 'Anonymous';

// Object.groupBy (ES2024)
const grouped = Object.groupBy(products, (p) => p.category);
// { electronics: [...], fashion: [...] }

// Array.at() for negative indexing
const last = items.at(-1);
const secondLast = items.at(-2);

// structuredClone for deep copy
const clone = structuredClone(originalObject);

// Promise.withResolvers
const { promise, resolve, reject } = Promise.withResolvers();

// Top-level await
const config = await fetch('/api/config').then(r => r.json());

// Logical assignment
user.name ??= 'Anonymous';  // assign if null/undefined
user.role ||= 'user';       // assign if falsy
user.score &&= user.score * 2;  // assign if truthy
```

---

## Async Patterns

```javascript
// Promise.all for parallel
const [products, categories, user] = await Promise.all([
  fetchProducts(),
  fetchCategories(),
  fetchUser(userId),
]);

// Promise.allSettled for independent operations
const results = await Promise.allSettled([
  sendEmail(user),
  updateAnalytics(event),
  notifySlack(message),
]);
const errors = results.filter(r => r.status === 'rejected');

// Async iteration
async function* paginate(url) {
  let page = 1;
  while (true) {
    const res = await fetch(`${url}?page=${page}`);
    const data = await res.json();
    if (data.length === 0) break;
    yield data;
    page++;
  }
}

for await (const batch of paginate('/api/users')) {
  await processBatch(batch);
}

// AbortController for timeouts
async function fetchWithTimeout(url, timeoutMs = 5000) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { signal: controller.signal });
    return await res.json();
  } finally {
    clearTimeout(timeout);
  }
}
```

---

## Module Patterns

```javascript
// Named exports (preferred)
export function formatPrice(amount) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount / 100);
}

export function formatDate(date) {
  return new Intl.DateTimeFormat('en-US', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(date));
}

// Dynamic import for code splitting
const { Chart } = await import('chart.js');
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **const/let** | Never use `var`, prefer `const` |
| **Arrow functions** | Use for callbacks, keep `function` for methods |
| **Destructuring** | Extract values from objects/arrays |
| **Template literals** | Use backticks for string interpolation |
| **Optional chaining** | `?.` for safe property access |
| **Nullish coalescing** | `??` instead of `||` for defaults |
| **Promise.all** | Parallel async operations |
| **for...of** | Iterate arrays (not `for...in`) |
| **structuredClone** | Deep copy instead of JSON parse/stringify |
| **Intl** | Use Intl API for formatting |

---

## Rules Integration
- **Modern**: ES2024+ features for clean, readable code
- **Async**: Promise.all, allSettled, async generators
- **Modules**: Named exports, dynamic imports
- **Formatting**: Intl API for locale-aware formatting
