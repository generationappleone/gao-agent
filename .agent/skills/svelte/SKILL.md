---
name: Svelte / SvelteKit
description: Skill for building web applications with Svelte and SvelteKit — covering reactivity, components, stores, SvelteKit routing, server-side rendering, form actions, and load functions.
---

# Svelte / SvelteKit Skill

## Overview
Svelte is a compiler-based UI framework with no virtual DOM. SvelteKit is its full-stack framework for production apps.

**Reference**: [Svelte Documentation](https://svelte.dev/docs)

## Project Setup
```bash
npx -y sv create ./ --template minimal --types ts
```

## Component Syntax
```svelte
<script lang="ts">
  // Props (Svelte 5 runes)
  let { name, count = 0 }: { name: string; count?: number } = $props();

  // Reactive state
  let message = $state("Hello");
  let doubled = $derived(count * 2);

  // Effect
  $effect(() => {
    console.log(`Count changed to ${count}`);
  });

  async function handleClick() {
    count++;
  }
</script>

<h1>{message}, {name}!</h1>
<p>Count: {count} (doubled: {doubled})</p>
<button onclick={handleClick}>Increment</button>

{#if count > 10}
  <p>Count is high!</p>
{:else}
  <p>Keep clicking</p>
{/if}

{#each items as item (item.id)}
  <li>{item.name}</li>
{/each}

{#await fetchData()}
  <p>Loading...</p>
{:then data}
  <p>{data.name}</p>
{:catch error}
  <p>Error: {error.message}</p>
{/await}

<style>
  h1 { color: #333; }
</style>
```

## SvelteKit Routing
```
src/routes/
├── +layout.svelte          # Root layout
├── +page.svelte            # / (home)
├── +page.server.ts         # Server load function
├── about/+page.svelte      # /about
├── users/
│   ├── +page.svelte        # /users
│   ├── +page.server.ts     # Server data
│   └── [id]/
│       ├── +page.svelte    # /users/:id
│       └── +page.server.ts
└── api/
    └── users/+server.ts    # API endpoint
```

## Load Functions & Form Actions
```typescript
// routes/users/+page.server.ts
import type { PageServerLoad, Actions } from "./$types";

export const load: PageServerLoad = async ({ fetch, params }) => {
  const res = await fetch("/api/users");
  const users = await res.json();
  return { users };
};

export const actions: Actions = {
  create: async ({ request }) => {
    const data = await request.formData();
    const name = data.get("name") as string;
    await db.user.create({ data: { name } });
    return { success: true };
  },
};
```

## API Endpoints
```typescript
// routes/api/users/+server.ts
import { json } from "@sveltejs/kit";
import type { RequestHandler } from "./$types";

export const GET: RequestHandler = async () => {
  const users = await db.user.findMany();
  return json(users);
};

export const POST: RequestHandler = async ({ request }) => {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return json(user, { status: 201 });
};
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Svelte 5 runes** | Use `$state`, `$derived`, `$effect`, `$props` |
| **`+page.server.ts`** | Server-side data loading |
| **Form actions** | Progressive enhancement for forms |
| **`$effect.pre`** | For DOM-related side effects |
| **Stores** | Use `$state` in `.svelte.ts` files for shared state |
| **CSS scoped** | Styles are component-scoped by default |
| **Preloading** | Use `data-sveltekit-preload-data` for instant nav |
| **Error pages** | Add `+error.svelte` for error boundaries |
