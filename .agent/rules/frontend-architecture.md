# 🏗️ Frontend Architecture — Consistent, Scalable, Premium

> **Severity:** STRICT
> **Scope:** All frontend applications — React, Next.js, Vue, vanilla JS
> **Objective:** Ensure every frontend codebase is architecturally consistent, maintainable, performant, and produces a premium user experience

---

## 1. Project Structure (Feature-Based)

### ✅ REQUIRED: Feature-Based Architecture

```
src/
├── features/                 # Feature modules (each self-contained)
│   ├── auth/
│   │   ├── components/       # Auth-specific components
│   │   ├── hooks/            # Auth hooks (useAuth, useLogin)
│   │   ├── services/         # Auth API calls
│   │   ├── types/            # Auth TypeScript types
│   │   ├── utils/            # Auth-specific utilities
│   │   └── index.ts          # Public API barrel export
│   ├── dashboard/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   ├── types/
│   │   └── index.ts
│   └── users/
│       ├── components/
│       ├── hooks/
│       ├── services/
│       ├── types/
│       └── index.ts
├── shared/                   # Shared across all features
│   ├── components/           # Reusable UI components (Button, Card, Modal)
│   │   └── ui/               # Base UI primitives (if using shadcn/ui)
│   ├── hooks/                # Shared custom hooks
│   ├── services/             # API client, HTTP wrapper
│   ├── types/                # Shared TypeScript types
│   ├── utils/                # Helper functions
│   ├── constants/            # App-wide constants
│   └── animations/           # Reusable animation components
├── layouts/                  # Page layouts (Sidebar, Dashboard, Auth)
├── pages/ or app/            # Route pages (thin — compose features)
├── providers/                # Context providers (Theme, Auth, Toast)
├── styles/                   # Global styles, design tokens
│   ├── globals.css           # CSS reset + design tokens
│   └── animations.css        # Animation keyframes + utilities
├── config/                   # App configuration
│   └── env.ts                # Validated environment variables
└── lib/                      # Third-party wrappers
    └── api-client.ts         # Configured HTTP client (axios/ky/fetch)
```

### Rules
```
Rule: Features NEVER import from other features directly.
      Shared code goes in shared/. Features only import from shared/.
      Pages compose features — they don't contain business logic.
```

| ❌ WRONG | ✅ RIGHT |
|----------|---------|
| `features/users` imports from `features/auth` | Both import from `shared/` |
| Business logic in page components | Pages compose feature components |
| API calls inside components | API calls in `services/`, consumed via hooks |
| Types scattered across files | Types centralized in `types/` per feature |
| Utility functions in component files | Utilities in `utils/` |

---

## 2. Component Architecture

### 2.1 Component Categories

| Category | Location | Responsibility | Examples |
|----------|----------|---------------|----------|
| **UI Primitives** | `shared/components/ui/` | Unstyled or base-styled atoms | Button, Input, Badge, Card |
| **Shared Components** | `shared/components/` | Composed reusable components | DataTable, StatCard, EmptyState |
| **Feature Components** | `features/*/components/` | Feature-specific UI | UserForm, LoginPanel |
| **Layout Components** | `layouts/` | Page structure | DashboardLayout, AuthLayout |
| **Page Components** | `pages/` or `app/` | Route entry, compose features | DashboardPage, UsersPage |

### 2.2 Component Rules

```
Rule: Components should be THIN. Extract logic into hooks,
      API calls into services, types into types/.
      A component only holds JSX + style logic.
```

```tsx
// ❌ BAD: Fat component with API calls + business logic
function UsersPage() {
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetch('/api/users').then(r => r.json()).then(setUsers);
  }, []);
  const filteredUsers = users.filter(u => u.isActive);
  // ... 200 lines of JSX
}

// ✅ GOOD: Thin component — logic in hooks, API in services
function UsersPage() {
  const { users, isLoading, error } = useUsers();
  const { filteredUsers } = useUserFilters(users);

  if (isLoading) return <UsersTableSkeleton />;
  if (error) return <ErrorState error={error} />;
  if (!filteredUsers.length) return <EmptyState />;

  return <UsersTable users={filteredUsers} />;
}
```

### 2.3 Component File Structure

```tsx
// ✅ REQUIRED: Standard component file structure

// 1. Imports (grouped: react → third-party → local)
import { useState, useMemo } from 'react';
import { motion } from 'framer-motion';
import { useUsers } from '../hooks/useUsers';
import type { User } from '../types';

// 2. Types/Interfaces
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
  onDelete: (id: string) => void;
  isCompact?: boolean;
}

// 3. Component (named export preferred)
export function UserCard({ user, onEdit, onDelete, isCompact = false }: UserCardProps) {
  // hooks first
  const [isHovered, setIsHovered] = useState(false);

  // derived state / memos
  const displayName = useMemo(() => `${user.firstName} ${user.lastName}`, [user]);

  // event handlers
  const handleEdit = () => onEdit(user.id);

  // render
  return (
    <article className="user-card" aria-label={`User ${displayName}`}>
      {/* JSX */}
    </article>
  );
}
```

---

## 3. State Management Decision Tree

```
Is it server state (API data)?
├── YES → Use TanStack Query (React Query)
│         ├── GET requests → useQuery
│         ├── POST/PUT/DELETE → useMutation
│         └── Optimistic updates → onMutate + rollback
└── NO → Is it used by multiple components?
    ├── NO → useState or useReducer (local)
    └── YES → How complex?
        ├── Simple (theme, sidebar open) → React Context
        ├── Medium (filters, UI state) → Zustand
        └── Complex enterprise (many reducers) → Redux Toolkit
```

### Rules
```
Rule: NEVER put server state (API data) in global state (Redux/Zustand).
      Use TanStack Query for ALL API data. It handles caching, refetching,
      loading states, error states, and optimistic updates.
```

---

## 4. Data Fetching Pattern

### Required: HTTP Client Wrapper
```typescript
// lib/api-client.ts — centralized HTTP client
const API_BASE = import.meta.env.VITE_API_URL || '/api';

interface ApiResponse<T> {
  data: T;
  error: null;
  meta?: { total: number; page: number; perPage: number };
}

interface ApiError {
  data: null;
  error: { code: string; message: string; details?: Record<string, string[]> };
}

export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit,
): Promise<T> {
  const url = `${API_BASE}${endpoint}`;
  const response = await fetch(url, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: 'Network error' }));
    throw new ApiRequestError(response.status, error.error?.message || 'Request failed');
  }

  return response.json();
}
```

### Required: Service Layer
```typescript
// features/users/services/userService.ts
import { apiClient } from '@/lib/api-client';
import type { User, CreateUserInput, UpdateUserInput } from '../types';

export const userService = {
  getAll: (params?: { page?: number; search?: string }) =>
    apiClient<{ data: User[]; meta: { total: number } }>('/users', { params }),

  getById: (id: string) =>
    apiClient<{ data: User }>(`/users/${id}`),

  create: (data: CreateUserInput) =>
    apiClient<{ data: User }>('/users', { method: 'POST', body: JSON.stringify(data) }),

  update: (id: string, data: UpdateUserInput) =>
    apiClient<{ data: User }>(`/users/${id}`, { method: 'PUT', body: JSON.stringify(data) }),

  delete: (id: string) =>
    apiClient<void>(`/users/${id}`, { method: 'DELETE' }),
};
```

### Required: Custom Hook
```typescript
// features/users/hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { userService } from '../services/userService';

export function useUsers(params?: { page?: number; search?: string }) {
  return useQuery({
    queryKey: ['users', params],
    queryFn: () => userService.getAll(params),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: userService.create,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
  });
}
```

---

## 5. Error Handling UI

### Required: Error Boundary
```tsx
// shared/components/ErrorBoundary.tsx
import { Component, type ErrorInfo, type ReactNode } from 'react';

interface Props { children: ReactNode; fallback?: ReactNode; }
interface State { hasError: boolean; error: Error | null; }

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo): void {
    console.error('ErrorBoundary caught:', error, info);
  }

  render(): ReactNode {
    if (this.state.hasError) {
      return this.props.fallback || <DefaultErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

### Required: Error States
```
Rule: Every data-fetching component MUST handle 4 states:
      1. Loading → Skeleton screen (never spinner)
      2. Error → Error message + retry button
      3. Empty → Empty state with illustration + CTA
      4. Success → Actual content with animations
```

---

## 6. Performance Standards

### Required Performance Budgets

| Metric | Target | Tool |
|--------|--------|------|
| **FCP** (First Contentful Paint) | < 1.5s | Lighthouse |
| **LCP** (Largest Contentful Paint) | < 2.5s | Lighthouse |
| **FID** (First Input Delay) | < 100ms | Lighthouse |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Lighthouse |
| **TTI** (Time to Interactive) | < 3.5s | Lighthouse |
| **Bundle Size** (gzipped) | < 200KB initial | Bundleanalyzer |

### Required Optimizations
```
1. Code splitting — React.lazy() + Suspense for routes
2. Image optimization — next/image or vite-imagetools, WebP/AVIF format
3. Font optimization — font-display: swap, preconnect, subset
4. Virtualization — react-window for lists > 50 items
5. Memoization — React.memo for expensive re-renders
6. Dynamic imports — lazy load heavy libraries (chart, map, editor)
7. Prefetch — prefetch links on hover for instant navigation
```

---

## 7. Routing Conventions

| Pattern | Convention | Example |
|---------|-----------|---------|
| List page | `/[resource]` | `/users` |
| Detail page | `/[resource]/[id]` | `/users/abc-123` |
| Create page | `/[resource]/new` | `/users/new` |
| Edit page | `/[resource]/[id]/edit` | `/users/abc-123/edit` |
| Nested resource | `/[parent]/[id]/[child]` | `/users/abc-123/orders` |
| Settings | `/settings/[section]` | `/settings/profile` |
| Auth pages | `/login`, `/register`, `/forgot-password` | — |

---

## 8. Dark Mode (Mandatory)

```
Rule: ALL frontend applications MUST support dark mode.
      Use CSS custom properties for theming.
      Support both system preference and manual toggle.
```

```typescript
// hooks/useTheme.ts
export function useTheme() {
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window === 'undefined') return 'light';
    return localStorage.getItem('theme') as 'light' | 'dark'
      || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  });

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
  }, [theme]);

  const toggle = () => setTheme(prev => prev === 'light' ? 'dark' : 'light');

  return { theme, toggle, setTheme };
}
```

---

## 9. Frontend Checklist

### Before Shipping ANY Frontend Feature

```
Architecture
□ Feature is in its own directory under features/
□ No cross-feature imports (only shared/)
□ Components are thin, logic is in hooks
□ API calls are in services, not components
□ Types are in types/ directory

State Management
□ Server state uses TanStack Query (not Redux/Zustand)
□ Global UI state uses Zustand or Context
□ Local state uses useState/useReducer
□ No prop drilling > 2 levels deep

UI/UX
□ Loading → skeleton screens (not spinners)
□ Error → meaningful error + retry
□ Empty → illustration + CTA
□ Animations → stagger entrance, hover effects
□ Dark mode → works correctly
□ Mobile → responsive down to 320px
□ Icons → consistent library + aria-labels

Performance
□ Routes are code-split (React.lazy)
□ Images are optimized (WebP, lazy loading)
□ Heavy libs are dynamically imported
□ Lists > 50 items use virtualization
□ No unnecessary re-renders (React DevTools Profiler)
□ Bundle size < 200KB gzipped (initial load)

Accessibility
□ Semantic HTML (header, main, nav, section)
□ All images have alt text
□ All forms have labels
□ All icon buttons have aria-label
□ Keyboard navigable (Tab, Enter, Escape)
□ Color contrast ≥ 4.5:1
□ Focus indicators visible
```

---

## ⚠️ Violations

| Violation | Severity |
|-----------|----------|
| API call inside component (not in service) | 🟠 HIGH |
| Cross-feature import | 🔴 CRITICAL |
| Missing loading/error/empty states | 🟠 HIGH |
| No dark mode support | 🟠 HIGH |
| Spinner instead of skeleton | 🟡 MEDIUM |
| No code splitting on routes | 🟡 MEDIUM |
| Business logic in page component | 🟠 HIGH |
| Prop drilling > 2 levels | 🟡 MEDIUM |
| Server state in Redux/Zustand | 🟠 HIGH |
