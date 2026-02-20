---
name: Svelte / SvelteKit
description: Skill for building web applications with Svelte and SvelteKit — covering reactivity, components, stores, SvelteKit routing, server-side rendering, form actions, and load functions.
---

# Svelte / SvelteKit Skill

## Overview
Svelte is a compiler-based UI framework that generates efficient vanilla JavaScript at build time — no virtual DOM. SvelteKit is the full-stack framework for Svelte, providing file-based routing, server-side rendering, API routes, form actions, and data loading. Svelte 5 introduces runes (`$state`, `$derived`, `$effect`) for reactivity.

**References**:
- [Svelte Documentation](https://svelte.dev/docs)
- [SvelteKit Documentation](https://kit.svelte.dev/docs)
- [Svelte 5 Runes](https://svelte.dev/docs/svelte/what-are-runes)

---

## Setup

```bash
npx -y sv create myapp
# Select: SvelteKit, TypeScript, Prettier, ESLint
cd myapp && npm install
npm run dev
```

---

## Svelte 5 Runes (Reactivity)

```svelte
<!-- src/lib/components/Counter.svelte -->
<script lang="ts">
  let count = $state(0);
  let doubled = $derived(count * 2);

  $effect(() => {
    console.log('Count changed:', count);
  });

  function increment() { count++; }
  function decrement() { count--; }
</script>

<div class="counter">
  <button onclick={decrement}>-</button>
  <span>{count} (doubled: {doubled})</span>
  <button onclick={increment}>+</button>
</div>

<style>
  .counter { display: flex; gap: 1rem; align-items: center; }
  button { padding: 0.5rem 1rem; border-radius: 0.5rem; cursor: pointer; }
</style>
```

---

## Component with Props

```svelte
<!-- src/lib/components/ProductCard.svelte -->
<script lang="ts">
  import type { Product } from '$lib/types';

  interface Props {
    product: Product;
    onAddToCart?: (product: Product) => void;
  }

  let { product, onAddToCart }: Props = $props();

  let isAdding = $state(false);

  async function handleAddToCart() {
    isAdding = true;
    onAddToCart?.(product);
    setTimeout(() => isAdding = false, 500);
  }
</script>

<div class="card">
  <img src={product.images[0]} alt={product.name} />
  <div class="body">
    <h3>{product.name}</h3>
    <p class="price">${product.price.toLocaleString()}</p>
    <div class="rating">★ {product.rating.toFixed(1)} ({product.ratingCount})</div>
    <button onclick={handleAddToCart} disabled={isAdding}>
      {isAdding ? 'Adding...' : 'Add to Cart'}
    </button>
  </div>
</div>

<style>
  .card { border: 1px solid #e5e7eb; border-radius: 1rem; overflow: hidden; transition: box-shadow 0.2s; }
  .card:hover { box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
  img { width: 100%; height: 200px; object-fit: cover; }
  .body { padding: 1rem; }
  h3 { font-size: 1.1rem; font-weight: 600; }
  .price { color: #6366f1; font-weight: 700; font-size: 1.2rem; }
  .rating { color: #f59e0b; font-size: 0.875rem; }
  button { width: 100%; padding: 0.75rem; background: #6366f1; color: white; border: none; border-radius: 0.5rem; cursor: pointer; }
  button:hover { background: #4f46e5; }
  button:disabled { opacity: 0.6; }
</style>
```

---

## SvelteKit Page with Load Function

```typescript
// src/routes/products/+page.server.ts
import type { PageServerLoad } from './$types';
import { db } from '$lib/server/db';

export const load: PageServerLoad = async ({ url }) => {
  const page = Number(url.searchParams.get('page')) || 1;
  const search = url.searchParams.get('search') || '';
  const category = url.searchParams.get('category') || '';
  const limit = 20;

  const where: any = { status: 'active' };
  if (category) where.categoryId = category;
  if (search) where.name = { contains: search, mode: 'insensitive' };

  const [products, total, categories] = await Promise.all([
    db.product.findMany({ where, skip: (page - 1) * limit, take: limit, include: { category: true }, orderBy: { createdAt: 'desc' } }),
    db.product.count({ where }),
    db.category.findMany({ orderBy: { name: 'asc' } }),
  ]);

  return {
    products, categories,
    pagination: { page, total, totalPages: Math.ceil(total / limit) },
  };
};
```

```svelte
<!-- src/routes/products/+page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';
  import ProductCard from '$lib/components/ProductCard.svelte';

  let { data }: { data: PageData } = $props();
  let searchQuery = $state('');

  function handleSearch(e: SubmitEvent) {
    e.preventDefault();
    const url = new URL(window.location.href);
    url.searchParams.set('search', searchQuery);
    url.searchParams.set('page', '1');
    window.location.href = url.toString();
  }
</script>

<svelte:head>
  <title>Products | MyApp</title>
  <meta name="description" content="Browse our product catalog" />
</svelte:head>

<div class="container">
  <h1>Products</h1>

  <form onsubmit={handleSearch} class="search-bar">
    <input bind:value={searchQuery} placeholder="Search products..." />
    <button type="submit">Search</button>
  </form>

  <div class="grid">
    {#each data.products as product (product.id)}
      <ProductCard {product} />
    {/each}
  </div>

  {#if data.products.length === 0}
    <p class="empty">No products found</p>
  {/if}

  <nav class="pagination">
    {#if data.pagination.page > 1}
      <a href="?page={data.pagination.page - 1}">Previous</a>
    {/if}
    <span>Page {data.pagination.page} of {data.pagination.totalPages}</span>
    {#if data.pagination.page < data.pagination.totalPages}
      <a href="?page={data.pagination.page + 1}">Next</a>
    {/if}
  </nav>
</div>
```

---

## Form Actions

```typescript
// src/routes/products/create/+page.server.ts
import type { Actions } from './$types';
import { fail, redirect } from '@sveltejs/kit';
import { db } from '$lib/server/db';

export const actions: Actions = {
  default: async ({ request, locals }) => {
    const user = locals.user;
    if (!user || user.role !== 'admin') return fail(403, { error: 'Unauthorized' });

    const formData = await request.formData();
    const name = formData.get('name') as string;
    const price = Number(formData.get('price'));
    const categoryId = formData.get('categoryId') as string;
    const description = formData.get('description') as string;

    // Validation
    const errors: Record<string, string> = {};
    if (!name || name.length < 2) errors.name = 'Name must be at least 2 characters';
    if (!price || price < 0) errors.price = 'Price must be positive';
    if (!categoryId) errors.categoryId = 'Category is required';

    if (Object.keys(errors).length > 0) {
      return fail(400, { errors, values: { name, price, categoryId, description } });
    }

    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-');

    await db.product.create({
      data: { name, slug, price: Math.round(price * 100), categoryId, description },
    });

    throw redirect(303, '/products');
  },
};
```

```svelte
<!-- src/routes/products/create/+page.svelte -->
<script lang="ts">
  import type { ActionData } from './$types';
  import { enhance } from '$app/forms';

  let { form }: { form: ActionData } = $props();
</script>

<h1>Create Product</h1>

<form method="POST" use:enhance>
  <label>
    Name
    <input name="name" value={form?.values?.name ?? ''} required />
    {#if form?.errors?.name}<span class="error">{form.errors.name}</span>{/if}
  </label>

  <label>
    Price
    <input name="price" type="number" step="0.01" value={form?.values?.price ?? ''} required />
    {#if form?.errors?.price}<span class="error">{form.errors.price}</span>{/if}
  </label>

  <label>
    Description
    <textarea name="description">{form?.values?.description ?? ''}</textarea>
  </label>

  {#if form?.error}
    <p class="error">{form.error}</p>
  {/if}

  <button type="submit">Create Product</button>
</form>
```

---

## Stores

```typescript
// src/lib/stores/cart.svelte.ts
import { getContext, setContext } from 'svelte';

class CartStore {
  items = $state<CartItem[]>([]);
  total = $derived(this.items.reduce((sum, item) => sum + item.price * item.quantity, 0));
  count = $derived(this.items.reduce((sum, item) => sum + item.quantity, 0));

  add(product: Product) {
    const existing = this.items.find(i => i.productId === product.id);
    if (existing) {
      existing.quantity++;
    } else {
      this.items.push({ productId: product.id, name: product.name, price: product.price, quantity: 1 });
    }
  }

  remove(productId: string) {
    this.items = this.items.filter(i => i.productId !== productId);
  }

  clear() { this.items = []; }
}

const CART_KEY = Symbol('cart');
export function setCartStore() { return setContext(CART_KEY, new CartStore()); }
export function getCartStore() { return getContext<CartStore>(CART_KEY); }
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Runes** | Use `$state`, `$derived`, `$effect` (Svelte 5) |
| **$props** | Use `$props()` for type-safe component props |
| **Load functions** | Server-side data fetching in `+page.server.ts` |
| **Form actions** | Progressive enhancement with `use:enhance` |
| **Scoped styles** | CSS is scoped to component by default |
| **Stores** | Class-based stores with `$state` and context API |
| **SEO** | Use `<svelte:head>` for meta tags |
| **#each with key** | Always use `(item.id)` key in `#each` blocks |
| **Validation** | Server-side validation in form actions |
| **Error handling** | Use `fail()` to return validation errors |

---

## Rules Integration
- **Reactivity**: Svelte 5 runes ($state, $derived, $effect)
- **Components**: Props with $props(), scoped styles
- **Routing**: File-based with load functions and form actions
- **Stores**: Class-based with context API
- **SSR**: Server-side rendering with progressive enhancement
