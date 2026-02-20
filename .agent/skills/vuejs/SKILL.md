---
name: Vue.js
description: Skill for building reactive web applications with Vue.js 3 — covering Composition API, reactivity, components, Pinia state management, Vue Router, composables, and Nuxt.js integration.
---

# Vue.js Skill

## Overview
Vue.js 3 is a progressive JavaScript framework for building reactive user interfaces. It provides the Composition API with `ref`/`reactive`, components with `<script setup>`, Pinia for state management, Vue Router for SPA routing, and composables for logic reuse.

**References**:
- [Vue.js Documentation](https://vuejs.org/)
- [Pinia](https://pinia.vuejs.org/)
- [Vue Router](https://router.vuejs.org/)

---

## Setup

```bash
npm create vue@latest myapp -- --typescript --router --pinia --eslint
cd myapp && npm install
npm run dev
```

---

## Component (script setup)

```vue
<!-- src/components/ProductCard.vue -->
<script setup lang="ts">
import type { Product } from '@/types';

const props = defineProps<{ product: Product }>();
const emit = defineEmits<{ addToCart: [product: Product] }>();

const isAdding = ref(false);

async function handleAdd() {
  isAdding.value = true;
  emit('addToCart', props.product);
  setTimeout(() => isAdding.value = false, 500);
}
</script>

<template>
  <div class="card">
    <img :src="product.images[0]" :alt="product.name" />
    <div class="body">
      <h3>{{ product.name }}</h3>
      <p class="price">${{ product.price.toLocaleString() }}</p>
      <div class="rating">★ {{ product.rating.toFixed(1) }}</div>
      <button @click="handleAdd" :disabled="isAdding">
        {{ isAdding ? 'Adding...' : 'Add to Cart' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.card { border: 1px solid #e5e7eb; border-radius: 1rem; overflow: hidden; transition: box-shadow 0.2s; }
.card:hover { box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
.price { color: #6366f1; font-weight: 700; }
button { width: 100%; padding: 0.75rem; background: #6366f1; color: white; border: none; border-radius: 0.5rem; cursor: pointer; }
</style>
```

---

## Pinia Store

```typescript
// src/stores/cart.ts
import { defineStore } from 'pinia';

interface CartItem { productId: string; name: string; price: number; quantity: number; }

export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([]);
  const total = computed(() => items.value.reduce((sum, i) => sum + i.price * i.quantity, 0));
  const count = computed(() => items.value.reduce((sum, i) => sum + i.quantity, 0));

  function add(product: Product) {
    const existing = items.value.find(i => i.productId === product.id);
    if (existing) { existing.quantity++; }
    else { items.value.push({ productId: product.id, name: product.name, price: product.price, quantity: 1 }); }
  }

  function remove(productId: string) { items.value = items.value.filter(i => i.productId !== productId); }
  function clear() { items.value = []; }

  return { items, total, count, add, remove, clear };
}, { persist: true });
```

---

## Composables

```typescript
// src/composables/useProducts.ts
export function useProducts() {
  const products = ref<Product[]>([]);
  const loading = ref(false);
  const error = ref('');

  async function fetchProducts(params?: { search?: string; category?: string; page?: number }) {
    loading.value = true;
    error.value = '';
    try {
      const query = new URLSearchParams(params as any).toString();
      const res = await fetch(`/api/products?${query}`);
      const data = await res.json();
      products.value = data.data;
    } catch (e) {
      error.value = (e as Error).message;
    } finally {
      loading.value = false;
    }
  }

  return { products, loading, error, fetchProducts };
}
```

---

## Vue Router

```typescript
// src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: () => import('@/views/HomeView.vue') },
    { path: '/products', component: () => import('@/views/ProductsView.vue') },
    { path: '/products/:slug', component: () => import('@/views/ProductDetailView.vue'), props: true },
    { path: '/dashboard', component: () => import('@/views/DashboardView.vue'), meta: { requiresAuth: true } },
  ],
});

router.beforeEach((to) => {
  const auth = useAuthStore();
  if (to.meta.requiresAuth && !auth.isAuthenticated) return '/login';
});

export default router;
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **script setup** | Use `<script setup>` for concise Composition API |
| **defineProps/Emits** | Type-safe props and events |
| **ref/reactive** | ref for primitives, reactive for objects |
| **computed** | Derived state with automatic tracking |
| **Pinia** | Composable-style stores with persist plugin |
| **Composables** | Reusable logic with `use*` prefix |
| **Router** | Lazy-loaded routes with navigation guards |
| **Scoped CSS** | Component-scoped styles by default |
| **v-model** | Two-way binding for form inputs |
| **watch/watchEffect** | Side effects on reactive changes |

---

## Rules Integration
- **Components**: script setup + defineProps/Emits
- **State**: Pinia stores with computed/actions
- **Composables**: Reusable async data fetching logic
- **Router**: Lazy routes with auth guards
- **Reactivity**: ref, reactive, computed, watch
