---
name: Next.js
description: Skill for building full-stack React applications with Next.js — covering App Router, Server Components, Server Actions, API Routes, middleware, SSR/SSG/ISR, data fetching, authentication, and deployment.
---

# Next.js Skill

## Overview
Next.js is the full-stack React framework for production. It provides Server Components, Server Actions, file-based routing, middleware, and built-in optimizations. This skill covers Next.js 14+ (App Router) as the standard architecture.

**Minimum Version**: Next.js 14+ (App Router)
**References**:
- [Next.js Documentation](https://nextjs.org/docs)
- [App Router Documentation](https://nextjs.org/docs/app)
- [Next.js Examples](https://github.com/vercel/next.js/tree/canary/examples)
- [Vercel Blog](https://vercel.com/blog)

---

## Project Setup

```bash
npx -y create-next-app@latest ./ --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm
```

### Essential Packages
```bash
# Database
npm install prisma @prisma/client
npm install drizzle-orm                    # Alternative ORM

# Auth
npm install next-auth@beta                 # NextAuth.js v5 (App Router native)
npm install jose                           # JWT operations

# Forms & Validation
npm install zod react-hook-form @hookform/resolvers

# State Management
npm install zustand @tanstack/react-query

# UI
npm install clsx tailwind-merge
npm install @radix-ui/react-dialog @radix-ui/react-dropdown-menu

# Dev
npm install -D @types/node prettier
```

### Project Structure
```
src/
├── app/                            # App Router (file-based routing)
│   ├── layout.tsx                  # Root layout (REQUIRED)
│   ├── page.tsx                    # Home page (/)
│   ├── loading.tsx                 # Root loading UI
│   ├── error.tsx                   # Root error UI
│   ├── not-found.tsx               # Global 404 page
│   ├── globals.css                 # Global styles
│   ├── (auth)/                     # Route group (no URL segment)
│   │   ├── login/page.tsx          # /login
│   │   ├── register/page.tsx       # /register
│   │   └── layout.tsx              # Auth-specific layout
│   ├── (dashboard)/                # Protected route group
│   │   ├── layout.tsx              # Dashboard layout (sidebar, header)
│   │   ├── dashboard/page.tsx      # /dashboard
│   │   ├── users/
│   │   │   ├── page.tsx            # /users (list)
│   │   │   ├── new/page.tsx        # /users/new (create form)
│   │   │   └── [id]/
│   │   │       ├── page.tsx        # /users/:id (detail)
│   │   │       └── edit/page.tsx   # /users/:id/edit
│   │   └── settings/page.tsx       # /settings
│   └── api/
│       ├── auth/[...nextauth]/route.ts
│       ├── users/route.ts          # GET /api/users, POST /api/users
│       ├── users/[id]/route.ts     # GET/PUT/DELETE /api/users/:id
│       └── health/route.ts         # Health check
├── components/
│   ├── ui/                         # Base UI components
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── modal.tsx
│   │   └── data-table.tsx
│   ├── layout/                     # Layout components
│   │   ├── header.tsx
│   │   ├── sidebar.tsx
│   │   └── breadcrumb.tsx
│   └── forms/                      # Form components
│       ├── user-form.tsx
│       └── login-form.tsx
├── lib/                            # Utilities and configurations
│   ├── db.ts                       # Prisma client instance
│   ├── auth.ts                     # NextAuth configuration
│   ├── utils.ts                    # Helper functions (cn, formatDate, etc.)
│   └── validations.ts             # Zod schemas
├── services/                       # Data access layer
│   ├── users.service.ts
│   └── orders.service.ts
├── actions/                        # Server Actions
│   ├── users.actions.ts
│   └── auth.actions.ts
├── hooks/                          # Client-side hooks
│   ├── use-users.ts
│   └── use-debounce.ts
├── types/                          # TypeScript types
│   └── index.ts
└── middleware.ts                   # Edge middleware
```

---

## Server vs Client Components

```tsx
// ── Server Component (DEFAULT — no directive needed) ──
// ✅ Can: fetch data, access backend, read env vars, use secrets
// ✅ Can: import Server Components
// ✅ Can: Pass serializable props to Client Components
// ❌ Cannot: useState, useEffect, onClick, browser APIs

// WHY Server Components? They:
// 1. Don't send JavaScript to the browser (smaller bundle)
// 2. Can directly access databases, file system, APIs
// 3. Keep secrets on the server (API keys, DB credentials)

async function UserList() {
  // Direct database access — no API needed
  const users = await prisma.user.findMany({
    where: { isActive: true },
    orderBy: { createdAt: 'desc' },
    take: 50,
  });

  return (
    <div>
      <h1>Users ({users.length})</h1>
      <ul>
        {users.map((user) => (
          <li key={user.id}>
            <span>{user.name}</span>
            {/* Pass data to Client Component for interactivity */}
            <DeleteButton userId={user.id} />
          </li>
        ))}
      </ul>
    </div>
  );
}

// ── Client Component (needs "use client" directive) ──
// WHY: Required for any interactivity, state, effects, or browser APIs
"use client";

import { useState, useTransition } from 'react';
import { deleteUser } from '@/actions/users.actions';

function DeleteButton({ userId }: { userId: string }) {
  const [isPending, startTransition] = useTransition();

  const handleDelete = () => {
    startTransition(async () => {
      await deleteUser(userId);
    });
  };

  return (
    <button onClick={handleDelete} disabled={isPending}>
      {isPending ? 'Deleting...' : 'Delete'}
    </button>
  );
}
```

### Component Decision Tree
```
Is it interactive? (onClick, onChange, useState, useEffect)
├── YES → "use client" (Client Component)
└── NO → Server Component (default)
     │
     ├── Does it fetch data? → async function component
     ├── Does it access DB? → async + direct DB query
     └── Pure rendering? → Regular function component
```

---

## Data Fetching

```tsx
// ── Server Component — direct async/await ──
// WHY: No waterfall, no client-side loading states, instant data

// Page with params
async function UserPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const user = await prisma.user.findUnique({
    where: { id },
    include: { orders: { take: 10, orderBy: { createdAt: 'desc' } } },
  });

  if (!user) {
    notFound();  // Renders not-found.tsx
  }

  return <UserDetail user={user} />;
}

// ── Parallel Data Fetching ──
// WHY: Avoid request waterfalls — fetch independent data simultaneously
async function DashboardPage() {
  // These execute in parallel (NOT sequentially)
  const [users, orders, stats] = await Promise.all([
    prisma.user.count(),
    prisma.order.findMany({ take: 10, orderBy: { createdAt: 'desc' } }),
    getAnalytics(),
  ]);

  return (
    <div className="grid grid-cols-3 gap-6">
      <StatCard title="Total Users" value={users} />
      <RecentOrders orders={orders} />
      <AnalyticsChart stats={stats} />
    </div>
  );
}

// ── Streaming with Suspense ──
// WHY: Show available data immediately, don't block on slow queries
import { Suspense } from 'react';

async function DashboardWithStreaming() {
  return (
    <div>
      {/* Fast query — renders immediately */}
      <Suspense fallback={<StatsSkeleton />}>
        <StatsSection />
      </Suspense>

      {/* Slow query — streams in when ready */}
      <Suspense fallback={<TableSkeleton />}>
        <AnalyticsTable />
      </Suspense>
    </div>
  );
}

// ── Caching Strategies ──
// ISR: Revalidate every 60 seconds
async function ProductPage() {
  const products = await fetch('https://api.example.com/products', {
    next: { revalidate: 60 },  // ISR: rebuild every 60s
  }).then((res) => res.json());

  return <ProductGrid products={products} />;
}

// SSR: Always fresh (no cache)
async function LiveDashboard() {
  const data = await fetch('https://api.example.com/live', {
    cache: 'no-store',  // SSR: always fresh
  }).then((res) => res.json());

  return <LiveChart data={data} />;
}
```

---

## Server Actions

```tsx
// src/actions/users.actions.ts
"use server";

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { auth } from '@/lib/auth';
import { prisma } from '@/lib/db';
import { createUserSchema, updateUserSchema } from '@/lib/validations';

// ── Create User ──
export async function createUser(formData: FormData) {
  // 1. Authentication
  const session = await auth();
  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  // 2. Validation
  const rawData = Object.fromEntries(formData);
  const validated = createUserSchema.safeParse(rawData);

  if (!validated.success) {
    return {
      success: false,
      errors: validated.error.flatten().fieldErrors,
    };
  }

  // 3. Business logic
  const existingUser = await prisma.user.findUnique({
    where: { email: validated.data.email },
  });

  if (existingUser) {
    return {
      success: false,
      errors: { email: ['Email already registered'] },
    };
  }

  // 4. Create
  await prisma.user.create({
    data: {
      ...validated.data,
      password: await hashPassword(validated.data.password),
      createdBy: session.user.id,
    },
  });

  // 5. Revalidate cache and redirect
  revalidatePath('/users');
  redirect('/users');
}

// ── Delete User ──
export async function deleteUser(userId: string) {
  const session = await auth();
  if (!session?.user || session.user.role !== 'admin') {
    throw new Error('Forbidden');
  }

  await prisma.user.update({
    where: { id: userId },
    data: { deletedAt: new Date(), isActive: false },
  });

  revalidatePath('/users');
  return { success: true };
}

// ── Update User (with return value for form feedback) ──
export async function updateUser(
  userId: string,
  _prevState: any,
  formData: FormData,
) {
  const session = await auth();
  if (!session?.user) {
    return { success: false, message: 'Unauthorized' };
  }

  const validated = updateUserSchema.safeParse(Object.fromEntries(formData));
  if (!validated.success) {
    return { success: false, errors: validated.error.flatten().fieldErrors };
  }

  await prisma.user.update({
    where: { id: userId },
    data: validated.data,
  });

  revalidatePath(`/users/${userId}`);
  return { success: true, message: 'User updated successfully' };
}
```

### Using Server Actions with useFormState
```tsx
"use client";

import { useFormState, useFormStatus } from 'react-dom';
import { updateUser } from '@/actions/users.actions';

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Saving...' : 'Save Changes'}
    </button>
  );
}

function EditUserForm({ user }: { user: User }) {
  const updateUserWithId = updateUser.bind(null, user.id);
  const [state, formAction] = useFormState(updateUserWithId, { success: false });

  return (
    <form action={formAction}>
      <input name="name" defaultValue={user.name} />
      {state.errors?.name && <span>{state.errors.name[0]}</span>}

      <input name="email" defaultValue={user.email} />
      {state.errors?.email && <span>{state.errors.email[0]}</span>}

      {state.message && (
        <div className={state.success ? 'text-green-600' : 'text-red-600'}>
          {state.message}
        </div>
      )}

      <SubmitButton />
    </form>
  );
}
```

---

## API Routes (Route Handlers)

```typescript
// src/app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import { auth } from '@/lib/auth';
import { createUserSchema } from '@/lib/validations';

export async function GET(request: NextRequest) {
  const session = await auth();
  if (!session?.user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { searchParams } = new URL(request.url);
  const page = Number(searchParams.get('page')) || 1;
  const perPage = Number(searchParams.get('per_page')) || 20;
  const search = searchParams.get('search');

  const where = {
    deletedAt: null,
    ...(search ? {
      OR: [
        { name: { contains: search, mode: 'insensitive' as const } },
        { email: { contains: search, mode: 'insensitive' as const } },
      ],
    } : {}),
  };

  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip: (page - 1) * perPage,
      take: perPage,
      orderBy: { createdAt: 'desc' },
      select: { id: true, name: true, email: true, role: true, isActive: true, createdAt: true },
    }),
    prisma.user.count({ where }),
  ]);

  return NextResponse.json({
    data: users,
    meta: {
      page,
      perPage,
      total,
      totalPages: Math.ceil(total / perPage),
    },
  });
}

export async function POST(request: NextRequest) {
  const session = await auth();
  if (!session?.user || session.user.role !== 'admin') {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
  }

  const body = await request.json();
  const validated = createUserSchema.safeParse(body);

  if (!validated.success) {
    return NextResponse.json(
      { error: 'Validation failed', details: validated.error.flatten().fieldErrors },
      { status: 422 },
    );
  }

  const user = await prisma.user.create({
    data: {
      ...validated.data,
      password: await hashPassword(validated.data.password),
    },
  });

  return NextResponse.json({ data: user }, { status: 201 });
}
```

---

## Middleware

```typescript
// src/middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { getToken } from 'next-auth/jwt';

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // ── Public routes (skip auth) ──
  const publicRoutes = ['/login', '/register', '/forgot-password', '/api/health'];
  if (publicRoutes.some((route) => pathname.startsWith(route))) {
    return NextResponse.next();
  }

  // ── Protected routes ──
  const token = await getToken({ req: request });

  if (!token && pathname.startsWith('/dashboard')) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('callbackUrl', pathname);
    return NextResponse.redirect(loginUrl);
  }

  // ── Role-based access ──
  if (pathname.startsWith('/admin') && token?.role !== 'admin') {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  // ── Add headers ──
  const response = NextResponse.next();
  response.headers.set('x-request-id', crypto.randomUUID());
  response.headers.set('x-pathname', pathname);

  return response;
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|public).*)',
  ],
};
```

---

## Layouts & Metadata

```tsx
// src/app/layout.tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { Providers } from './providers';
import './globals.css';

const inter = Inter({ subsets: ['latin'], display: 'swap' });

export const metadata: Metadata = {
  title: { default: 'MyApp', template: '%s | MyApp' },
  description: 'Full-stack application built with Next.js',
  metadataBase: new URL('https://myapp.com'),
  openGraph: {
    title: 'MyApp',
    description: 'Full-stack application built with Next.js',
    url: 'https://myapp.com',
    siteName: 'MyApp',
    type: 'website',
  },
  robots: { index: true, follow: true },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.className} suppressHydrationWarning>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}

// src/app/(dashboard)/layout.tsx
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';
import { Sidebar } from '@/components/layout/sidebar';
import { Header } from '@/components/layout/header';

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const session = await auth();
  if (!session?.user) redirect('/login');

  return (
    <div className="flex h-screen">
      <Sidebar user={session.user} />
      <div className="flex flex-col flex-1 overflow-hidden">
        <Header user={session.user} />
        <main className="flex-1 overflow-y-auto p-6">{children}</main>
      </div>
    </div>
  );
}

// ── Dynamic metadata per page ──
export async function generateMetadata({ params }: { params: Promise<{ id: string }> }): Promise<Metadata> {
  const { id } = await params;
  const user = await prisma.user.findUnique({ where: { id } });

  return {
    title: user?.name ?? 'User Not Found',
    description: `Profile page for ${user?.name}`,
  };
}
```

---

## Loading & Error States

```tsx
// src/app/(dashboard)/users/loading.tsx
export default function UsersLoading() {
  return (
    <div className="space-y-4">
      <div className="h-8 w-48 bg-muted animate-pulse rounded" />
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="h-16 bg-muted animate-pulse rounded" />
      ))}
    </div>
  );
}

// src/app/(dashboard)/users/error.tsx
"use client";

import { useEffect } from 'react';

export default function UsersError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Report to error monitoring (Sentry, etc.)
    console.error('Users page error:', error);
  }, [error]);

  return (
    <div className="flex flex-col items-center gap-4 py-20">
      <h2 className="text-xl font-semibold">Something went wrong</h2>
      <p className="text-muted-foreground">{error.message}</p>
      <button onClick={reset} className="btn btn-primary">Try again</button>
    </div>
  );
}
```

---

## Best Practices

| Practice | Description |
|----------|-------------|
| **Server Components by default** | Only add `"use client"` when you need interactivity |
| **Parallel fetching** | Use `Promise.all()` for independent data queries |
| **Server Actions** | Prefer over API routes for mutations from forms |
| **Streaming** | Use `<Suspense>` to stream independent data sections |
| **`loading.tsx`** | Add loading UI for every route segment |
| **`error.tsx`** | Add error boundaries for every route segment |
| **Metadata API** | Use for SEO — title, description, Open Graph |
| **Image optimization** | Always use `next/image` with width/height |
| **Font optimization** | Use `next/font` for self-hosted fonts |
| **Middleware** | Use for auth, redirects, headers at the edge |
| **ISR** | Use `revalidate` for data that changes periodically |
| **Route Groups** | Use `(groupName)` for layout organization without URL changes |
| **Validation** | Zod schemas for Server Action input validation |
| **Prisma client singleton** | Use `globalThis` pattern to prevent multiple instances |

---

## Common Gotchas

| Issue | Cause | Solution |
|-------|-------|----------|
| "use client" on every component | Overusing client components | Only use for interactivity — keep data fetching in Server Components |
| `window is not defined` | Server Component accessing browser API | Move to Client Component or use `typeof window !== 'undefined'` check |
| Stale data after mutation | Not revalidating cache | Use `revalidatePath()` or `revalidateTag()` after mutations |
| Hydration mismatch | Server/client HTML doesn't match | Use `suppressHydrationWarning` for dynamic client-only content |
| Middleware runs on images | Middleware matching too broadly | Add `matcher` config to exclude `_next/static`, `_next/image` |
| Multiple Prisma instances | No singleton in development | Use `globalThis.prisma` pattern |

---

## Rules Integration
- **Architecture**: App Router, Server Components default, Client Components only for interactivity
- **Data Fetching**: Direct DB access in Server Components, parallel with `Promise.all`, streaming with Suspense
- **Mutations**: Server Actions with Zod validation, `revalidatePath()` after changes
- **Auth**: NextAuth.js v5 with middleware protection, role-based access control
- **SEO**: Metadata API on every page, proper heading hierarchy, Open Graph tags
