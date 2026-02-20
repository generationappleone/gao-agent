---
name: Supabase
description: Skill for building applications with Supabase — covering Auth, Database (PostgreSQL), Realtime subscriptions, Storage, Edge Functions, Row Level Security (RLS), and client SDK.
---

# Supabase Skill

## Overview
Supabase is an open-source Firebase alternative built on PostgreSQL. It provides authentication, database with Row Level Security (RLS), realtime subscriptions, file storage, edge functions, and auto-generated REST/GraphQL APIs. Supabase gives you a full Postgres database with instant APIs.

**References**:
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript)
- [Supabase Dashboard](https://supabase.com/dashboard)

---

## Setup

```bash
npm install @supabase/supabase-js
```

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js';
import type { Database } from '@/types/database';

export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
);

// Server-side client (with service role)
export function createServerClient() {
  return createClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { auth: { persistSession: false } },
  );
}
```

---

## Authentication

```typescript
// src/services/auth.service.ts
import { supabase } from '@/lib/supabase';

// Register
export async function signUp(email: string, password: string, name: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: { data: { name, role: 'user' } },
  });
  if (error) throw error;
  return data;
}

// Login
export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) throw error;
  return data;
}

// OAuth (Google)
export async function signInWithGoogle() {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: { redirectTo: `${window.location.origin}/auth/callback` },
  });
  if (error) throw error;
  return data;
}

// Logout
export async function signOut() {
  await supabase.auth.signOut();
}

// Get session
export async function getSession() {
  const { data: { session } } = await supabase.auth.getSession();
  return session;
}

// Auth state listener
export function onAuthChange(callback: (event: string, session: any) => void) {
  return supabase.auth.onAuthStateChange(callback);
}
```

---

## Database CRUD

```typescript
// src/services/product.service.ts
import { supabase } from '@/lib/supabase';

// ── List with filters + pagination ──
export async function listProducts(options: {
  category?: string; search?: string; sortBy?: string;
  page?: number; limit?: number;
}) {
  const { page = 1, limit = 20 } = options;
  const from = (page - 1) * limit;
  const to = from + limit - 1;

  let query = supabase
    .from('products')
    .select('*, category:categories(name, slug)', { count: 'exact' })
    .eq('status', 'active');

  if (options.category) {
    query = query.eq('categories.slug', options.category);
  }
  if (options.search) {
    query = query.or(`name.ilike.%${options.search}%,description.ilike.%${options.search}%`);
  }

  switch (options.sortBy) {
    case 'price_asc': query = query.order('price', { ascending: true }); break;
    case 'price_desc': query = query.order('price', { ascending: false }); break;
    case 'rating': query = query.order('rating', { ascending: false }); break;
    default: query = query.order('created_at', { ascending: false });
  }

  const { data, count, error } = await query.range(from, to);
  if (error) throw error;

  return {
    data: data || [],
    total: count || 0,
    page,
    totalPages: Math.ceil((count || 0) / limit),
  };
}

// ── Get single ──
export async function getProduct(slug: string) {
  const { data, error } = await supabase
    .from('products')
    .select('*, category:categories(name, slug), reviews(*, user:users(name, avatar_url))')
    .eq('slug', slug)
    .single();

  if (error) throw error;
  return data;
}

// ── Create ──
export async function createProduct(input: CreateProductInput) {
  const { data, error } = await supabase
    .from('products')
    .insert(input)
    .select()
    .single();

  if (error) throw error;
  return data;
}

// ── Update ──
export async function updateProduct(id: string, input: Partial<Product>) {
  const { data, error } = await supabase
    .from('products')
    .update({ ...input, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

// ── Delete ──
export async function deleteProduct(id: string) {
  const { error } = await supabase.from('products').delete().eq('id', id);
  if (error) throw error;
}

// ── RPC (stored procedure) ──
export async function getMonthlyRevenue() {
  const { data, error } = await supabase.rpc('get_monthly_revenue', { months: 12 });
  if (error) throw error;
  return data;
}
```

---

## Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Everyone can read active products
CREATE POLICY "Public read products" ON products
  FOR SELECT USING (status = 'active');

-- Only admins can insert/update/delete products
CREATE POLICY "Admin manage products" ON products
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'admin'
  );

-- Users can only read their own orders
CREATE POLICY "Users read own orders" ON orders
  FOR SELECT USING (
    auth.uid() = user_id
  );

-- Users can create their own orders
CREATE POLICY "Users create orders" ON orders
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

-- Admins can read all orders
CREATE POLICY "Admin read all orders" ON orders
  FOR SELECT USING (
    auth.jwt() ->> 'role' = 'admin'
  );
```

---

## Realtime Subscriptions

```typescript
// ── Subscribe to changes ──
export function subscribeToOrders(userId: string, onUpdate: (order: any) => void) {
  const channel = supabase
    .channel('user-orders')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'orders',
        filter: `user_id=eq.${userId}`,
      },
      (payload) => {
        onUpdate(payload.new);
      }
    )
    .subscribe();

  return () => { supabase.removeChannel(channel); };
}

// ── Presence (online users) ──
export function trackPresence(userId: string) {
  const channel = supabase.channel('online-users');
  channel.on('presence', { event: 'sync' }, () => {
    const state = channel.presenceState();
    console.log('Online:', Object.keys(state).length);
  });
  channel.subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await channel.track({ userId, online_at: new Date().toISOString() });
    }
  });
  return () => { supabase.removeChannel(channel); };
}
```

---

## Storage

```typescript
// ── Upload file ──
export async function uploadFile(bucket: string, path: string, file: File) {
  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(path, file, {
      cacheControl: '3600',
      upsert: false,
      contentType: file.type,
    });

  if (error) throw error;

  const { data: { publicUrl } } = supabase.storage.from(bucket).getPublicUrl(data.path);
  return publicUrl;
}

// ── Delete file ──
export async function deleteFile(bucket: string, path: string) {
  const { error } = await supabase.storage.from(bucket).remove([path]);
  if (error) throw error;
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **RLS** | Always enable Row Level Security on all tables |
| **Typed client** | Generate types with `supabase gen types typescript` |
| **Service role** | Use service role key ONLY on server-side |
| **Anon key** | Safe to expose in client (protected by RLS) |
| **select()** | Select only needed columns and relations |
| **count** | Use `{ count: 'exact' }` for pagination totals |
| **Realtime** | Subscribe to specific table/filter, unsubscribe on cleanup |
| **RPC** | Use stored procedures for complex queries |
| **Storage policies** | Set bucket policies for upload/download access |
| **Error handling** | Always check `error` from every Supabase call |

---

## Rules Integration
- **Auth**: Email/password, OAuth, session management
- **Database**: Type-safe CRUD with filters, pagination, relations
- **RLS**: Row Level Security policies for access control
- **Realtime**: Postgres changes subscriptions, presence
- **Storage**: File upload/delete with public URLs
