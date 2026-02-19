---
name: Next.js
description: Skill for building full-stack React applications with Next.js — covering App Router, Server Components, Server Actions, API Routes, middleware, SSR/SSG/ISR, data fetching, authentication, and deployment.
---

# Next.js Skill

## Overview
Next.js is the React framework for production. This skill covers Next.js 14+ with the App Router as the standard architecture.

**Reference**: [Next.js Documentation](https://nextjs.org/docs)

## Project Setup
```bash
npx -y create-next-app@latest ./ --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm
```

## App Router Structure
```
src/
├── app/
│   ├── layout.tsx          # Root layout (required)
│   ├── page.tsx            # Home page (/)
│   ├── loading.tsx         # Loading UI
│   ├── error.tsx           # Error UI
│   ├── not-found.tsx       # 404 page
│   ├── globals.css         # Global styles
│   ├── dashboard/
│   │   ├── layout.tsx      # Nested layout
│   │   ├── page.tsx        # /dashboard
│   │   └── [id]/
│   │       └── page.tsx    # /dashboard/:id
│   └── api/
│       └── users/
│           └── route.ts    # API Route: /api/users
├── components/
│   ├── ui/                 # Reusable UI components
│   └── layout/             # Layout components
├── lib/                    # Utilities, configs
├── types/                  # TypeScript types
└── middleware.ts           # Edge middleware
```

## Server vs Client Components
```tsx
// Server Component (default — no directive needed)
// ✅ Can: fetch data, access backend, read files, use secrets
// ❌ Cannot: useState, useEffect, onClick, browser APIs
async function UserList() {
  const users = await db.user.findMany(); // Direct DB access
  return (
    <ul>
      {users.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  );
}

// Client Component (needs "use client" directive)
"use client";
import { useState } from "react";

function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

## Data Fetching
```tsx
// Server Component — direct async/await
async function ProductPage({ params }: { params: { id: string } }) {
  const product = await fetch(`https://api.example.com/products/${params.id}`, {
    cache: "force-cache",       // SSG (default)
    // cache: "no-store",       // SSR (dynamic)
    // next: { revalidate: 60 } // ISR (60 seconds)
  }).then(res => res.json());

  return <ProductDetail product={product} />;
}

// Parallel data fetching
async function Dashboard() {
  const [users, orders, stats] = await Promise.all([
    fetchUsers(),
    fetchOrders(),
    fetchStats(),
  ]);
  return <DashboardView users={users} orders={orders} stats={stats} />;
}
```

## Server Actions
```tsx
// app/actions.ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function createUser(formData: FormData) {
  const name = formData.get("name") as string;
  const email = formData.get("email") as string;

  // Validate
  if (!name || !email) throw new Error("Missing fields");

  // Save to DB
  await db.user.create({ data: { name, email } });

  revalidatePath("/users");
  redirect("/users");
}

// Usage in Server Component
function CreateForm() {
  return (
    <form action={createUser}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit">Create</button>
    </form>
  );
}
```

## API Routes (Route Handlers)
```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const page = Number(searchParams.get("page")) || 1;

  const users = await db.user.findMany({ skip: (page - 1) * 20, take: 20 });
  return NextResponse.json({ data: users, page });
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return NextResponse.json(user, { status: 201 });
}

// Dynamic route: app/api/users/[id]/route.ts
export async function GET(_: NextRequest, { params }: { params: { id: string } }) {
  const user = await db.user.findUnique({ where: { id: params.id } });
  if (!user) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json(user);
}
```

## Middleware
```typescript
// src/middleware.ts
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  const token = request.cookies.get("session")?.value;

  // Protect routes
  if (request.nextUrl.pathname.startsWith("/dashboard") && !token) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  // Add headers
  const response = NextResponse.next();
  response.headers.set("x-request-id", crypto.randomUUID());
  return response;
}

export const config = {
  matcher: ["/dashboard/:path*", "/api/:path*"],
};
```

## Layouts & Metadata
```tsx
// app/layout.tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: { default: "MyApp", template: "%s | MyApp" },
  description: "Full-stack application built with Next.js",
  openGraph: { title: "MyApp", description: "..." },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

// Dynamic metadata per page
export async function generateMetadata({ params }: { params: { id: string } }): Promise<Metadata> {
  const product = await fetchProduct(params.id);
  return { title: product.name, description: product.description };
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Server Components default** | Only add `"use client"` when you need interactivity |
| **Parallel fetching** | Use `Promise.all()` for independent data |
| **Server Actions** | Prefer over API routes for mutations from forms |
| **`loading.tsx`** | Add loading UI for every route segment |
| **`error.tsx`** | Add error boundaries for every route segment |
| **Metadata API** | Use for SEO — title, description, Open Graph |
| **Image optimization** | Always use `next/image` with width/height |
| **Font optimization** | Use `next/font` for self-hosted fonts |
| **Middleware** | Use for auth, redirects, headers at the edge |
| **ISR** | Use `revalidate` for data that changes periodically |
