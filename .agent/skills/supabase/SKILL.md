---
name: Supabase
description: Skill for building applications with Supabase — covering Auth, Database (PostgreSQL), Realtime subscriptions, Storage, Edge Functions, Row Level Security (RLS), and client SDK.
---

# Supabase Skill

## Overview
Supabase is an open-source Firebase alternative built on PostgreSQL, providing Auth, Database, Realtime, Storage, and Edge Functions.

**Reference**: [Supabase Documentation](https://supabase.com/docs)

## Setup
```bash
npm install @supabase/supabase-js
```
```typescript
import { createClient } from "@supabase/supabase-js";
const supabase = createClient(process.env.SUPABASE_URL!, process.env.SUPABASE_ANON_KEY!);
```

## Authentication
```typescript
// Sign up
const { data, error } = await supabase.auth.signUp({ email, password });

// Sign in
await supabase.auth.signInWithPassword({ email, password });

// OAuth
await supabase.auth.signInWithOAuth({ provider: "google", options: { redirectTo: window.location.origin } });

// Session listener
supabase.auth.onAuthStateChange((event, session) => {
  if (event === "SIGNED_IN") console.log("User:", session?.user);
});

// Get current user
const { data: { user } } = await supabase.auth.getUser();
```

## Database (PostgreSQL via Client)
```typescript
// Select
const { data: users } = await supabase.from("users").select("id, name, email, posts(title, content)").eq("role", "admin").order("created_at", { ascending: false }).range(0, 19);

// Insert
const { data } = await supabase.from("users").insert({ name, email }).select().single();

// Update
await supabase.from("users").update({ name: "New Name" }).eq("id", userId);

// Delete
await supabase.from("users").delete().eq("id", userId);

// RPC (stored procedures)
const { data } = await supabase.rpc("get_user_stats", { user_id: userId });
```

## Realtime Subscriptions
```typescript
const channel = supabase.channel("messages").on("postgres_changes", {
  event: "INSERT", schema: "public", table: "messages", filter: `room_id=eq.${roomId}`,
}, (payload) => {
  console.log("New message:", payload.new);
}).subscribe();

// Cleanup
supabase.removeChannel(channel);
```

## Storage
```typescript
const { data } = await supabase.storage.from("avatars").upload(`${userId}/avatar.png`, file, { contentType: "image/png", upsert: true });
const { data: { publicUrl } } = supabase.storage.from("avatars").getPublicUrl(`${userId}/avatar.png`);
```

## Row Level Security (RLS)
```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users read own data" ON users FOR SELECT USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users update own data" ON users FOR UPDATE USING (auth.uid() = id);

-- Anyone can read public posts
CREATE POLICY "Public posts readable" ON posts FOR SELECT USING (published = true);

-- Authors can manage their posts
CREATE POLICY "Authors manage posts" ON posts FOR ALL USING (auth.uid() = author_id);
```

## Edge Functions
```typescript
// supabase/functions/hello/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  const { name } = await req.json();
  return new Response(JSON.stringify({ message: `Hello, ${name}!` }), {
    headers: { "Content-Type": "application/json" },
  });
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **RLS always on** | Never disable Row Level Security in production |
| **Service role key** | Only use on server — never expose to client |
| **Type generation** | Use `supabase gen types` for type-safe queries |
| **Migrations** | Use `supabase db diff` for schema changes |
| **Edge Functions** | Use for server-side logic with secrets |
| **Realtime** | Unsubscribe channels on component unmount |
| **Storage policies** | Set bucket policies for access control |
| **Database functions** | Use `rpc()` for complex server-side queries |
