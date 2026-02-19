---
name: Vue.js
description: Skill for building reactive web applications with Vue.js 3 — covering Composition API, reactivity, components, Pinia state management, Vue Router, composables, and Nuxt.js integration.
---

# Vue.js Skill

## Overview
Vue.js is a progressive JavaScript framework for building user interfaces. This skill covers Vue 3 with the Composition API as the standard approach.

**Reference**: [Vue.js Documentation](https://vuejs.org/guide/introduction.html)

## Project Setup
```bash
npx -y create-vue@latest ./  # Select: TypeScript, Router, Pinia, ESLint, Prettier
# OR with Vite
npx -y create-vite@latest ./ --template vue-ts
```

## Component Structure (Composition API + `<script setup>`)
```vue
<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import type { User } from "@/types";

// Props
const props = defineProps<{
  userId: string;
  title?: string;
}>();

// Emits
const emit = defineEmits<{
  submit: [user: User];
  cancel: [];
}>();

// Reactive state
const name = ref("");
const users = ref<User[]>([]);
const loading = ref(false);

// Computed
const filteredUsers = computed(() =>
  users.value.filter(u => u.name.includes(name.value))
);

// Methods
async function fetchUsers() {
  loading.value = true;
  try {
    const res = await fetch("/api/users");
    users.value = await res.json();
  } finally {
    loading.value = false;
  }
}

// Lifecycle
onMounted(() => fetchUsers());
</script>

<template>
  <div class="user-list">
    <h2>{{ props.title ?? "Users" }}</h2>
    <input v-model="name" placeholder="Search..." />
    <div v-if="loading">Loading...</div>
    <ul v-else>
      <li v-for="user in filteredUsers" :key="user.id">
        {{ user.name }}
      </li>
    </ul>
    <button @click="emit('cancel')">Cancel</button>
  </div>
</template>

<style scoped>
.user-list { padding: 1rem; }
</style>
```

## State Management (Pinia)
```typescript
// stores/user.ts
import { defineStore } from "pinia";
import { ref, computed } from "vue";

export const useUserStore = defineStore("user", () => {
  const users = ref<User[]>([]);
  const loading = ref(false);
  const currentUser = ref<User | null>(null);

  const activeUsers = computed(() => users.value.filter(u => u.active));

  async function fetchUsers() {
    loading.value = true;
    try {
      const res = await fetch("/api/users");
      users.value = await res.json();
    } finally {
      loading.value = false;
    }
  }

  function setCurrentUser(user: User) {
    currentUser.value = user;
  }

  return { users, loading, currentUser, activeUsers, fetchUsers, setCurrentUser };
});
```

## Routing (Vue Router)
```typescript
// router/index.ts
import { createRouter, createWebHistory } from "vue-router";

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", component: () => import("@/views/Home.vue") },
    { path: "/users", component: () => import("@/views/Users.vue") },
    { path: "/users/:id", component: () => import("@/views/UserDetail.vue"), props: true },
    { path: "/dashboard", component: () => import("@/views/Dashboard.vue"), meta: { requiresAuth: true } },
    { path: "/:pathMatch(.*)*", component: () => import("@/views/NotFound.vue") },
  ],
});

// Navigation guard
router.beforeEach((to) => {
  const auth = useAuthStore();
  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { path: "/login", query: { redirect: to.fullPath } };
  }
});

export default router;
```

## Composables (Custom Hooks)
```typescript
// composables/useFetch.ts
import { ref, watchEffect } from "vue";

export function useFetch<T>(url: string) {
  const data = ref<T | null>(null);
  const error = ref<Error | null>(null);
  const loading = ref(true);

  watchEffect(async () => {
    loading.value = true;
    try {
      const res = await fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      data.value = await res.json();
    } catch (e) {
      error.value = e instanceof Error ? e : new Error(String(e));
    } finally {
      loading.value = false;
    }
  });

  return { data, error, loading };
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **`<script setup>`** | Always use for cleaner, more performant components |
| **Composition API** | Preferred over Options API for new projects |
| **Pinia** | Official state management — replaces Vuex |
| **TypeScript** | Always use with `lang="ts"` |
| **Composables** | Extract reusable logic into `composables/` |
| **`<style scoped>`** | Scope CSS to prevent leaking styles |
| **Lazy routes** | Use dynamic `import()` for route components |
| **`v-model`** | For two-way binding on inputs and custom components |
| **`defineProps`** | Type-safe props with generic syntax |
| **`shallowRef`** | For large objects/arrays that don't need deep reactivity |
