---
name: React.js
description: Skill for building modern web applications with React.js, covering project setup, component architecture, state management, hooks, routing, testing, and performance optimization.
---

# React.js Skill

## Overview
React is a JavaScript library for building user interfaces using a component-based architecture. It powers SPAs, SSR applications (via Next.js), dashboards, and interactive UIs. This skill covers React 18+ with functional components, hooks, TypeScript, and modern state management.

**Minimum Version**: React 18+
**References**:
- [Official React Documentation](https://react.dev/)
- [React API Reference](https://react.dev/reference/react)
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [Patterns.dev — React Patterns](https://www.patterns.dev/react)

---

## Project Setup

### Vite (Recommended for SPAs)
```bash
npx -y create-vite@latest ./ --template react-ts
npm install
npm run dev
```

### Next.js (Recommended for Full-Stack)
```bash
npx -y create-next-app@latest ./ --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm
```

### Essential Packages
```bash
# Routing
npm install react-router-dom       # SPA routing (Vite)

# State management (choose one)
npm install zustand                # Simple, lightweight
npm install @tanstack/react-query  # Server state management

# Forms
npm install react-hook-form zod @hookform/resolvers

# UI (choose one)
npm install @mui/material @emotion/react @emotion/styled
npm install @radix-ui/react-dialog @radix-ui/react-dropdown-menu  # Headless

# Utilities
npm install clsx                   # Conditional class names
npm install date-fns               # Date formatting
npm install axios                  # HTTP client (or use native fetch)
```

### Project Structure
```
src/
├── app/                           # App initialization (or pages/ for Next.js)
│   ├── App.tsx                    # Root component
│   ├── router.tsx                 # Route definitions
│   └── providers.tsx              # Context providers wrapper
├── components/                    # Shared UI components
│   ├── ui/                        # Base UI (Button, Input, Modal, etc.)
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   └── Modal.tsx
│   ├── layout/                    # Layout components
│   │   ├── Header.tsx
│   │   ├── Sidebar.tsx
│   │   └── MainLayout.tsx
│   └── common/                    # Shared domain components
│       ├── UserAvatar.tsx
│       └── DataTable.tsx
├── features/                      # Feature modules (domain-driven)
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── types.ts
│   ├── users/
│   │   ├── components/
│   │   │   ├── UserList.tsx
│   │   │   ├── UserForm.tsx
│   │   │   └── UserCard.tsx
│   │   ├── hooks/
│   │   │   ├── useUsers.ts
│   │   │   └── useCreateUser.ts
│   │   ├── services/
│   │   │   └── users.api.ts
│   │   └── types.ts
│   └── dashboard/
│       └── ...
├── hooks/                         # Global custom hooks
│   ├── useDebounce.ts
│   ├── useLocalStorage.ts
│   └── useMediaQuery.ts
├── services/                      # API client setup
│   ├── api-client.ts              # Axios/fetch configuration
│   └── interceptors.ts            # Auth interceptors
├── stores/                        # Zustand stores (global state)
│   └── auth.store.ts
├── types/                         # Shared TypeScript types
│   └── api.types.ts
├── utils/                         # Pure utility functions
│   ├── format.ts
│   └── validation.ts
├── styles/                        # Global styles
│   └── index.css
└── main.tsx                       # Entry point
```

---

## Component Patterns

### Functional Component with TypeScript
```tsx
import { type ReactNode } from 'react';

// ── Typed Props ──
interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
    avatarUrl?: string;
  };
  variant?: 'compact' | 'detailed';
  showActions?: boolean;
  onEdit?: (userId: string) => void;
  onDelete?: (userId: string) => void;
  children?: ReactNode;
}

export function UserCard({
  user,
  variant = 'compact',
  showActions = false,
  onEdit,
  onDelete,
  children,
}: UserCardProps) {
  return (
    <div className={`user-card user-card--${variant}`}>
      <img
        src={user.avatarUrl ?? '/default-avatar.png'}
        alt={`${user.name}'s avatar`}
        className="user-card__avatar"
      />
      <div className="user-card__info">
        <h3>{user.name}</h3>
        <p>{user.email}</p>
      </div>

      {showActions && (
        <div className="user-card__actions">
          <button onClick={() => onEdit?.(user.id)} aria-label={`Edit ${user.name}`}>
            Edit
          </button>
          <button onClick={() => onDelete?.(user.id)} aria-label={`Delete ${user.name}`}>
            Delete
          </button>
        </div>
      )}

      {children}
    </div>
  );
}
```

### Compound Component Pattern
```tsx
// WHY: Flexible API — parent manages state, children render parts
// Usage: <Modal> <Modal.Header>Title</Modal.Header> <Modal.Body>...</Modal.Body> </Modal>

import { createContext, useContext, useState, type ReactNode } from 'react';

interface ModalContextType {
  isOpen: boolean;
  open: () => void;
  close: () => void;
}

const ModalContext = createContext<ModalContextType | null>(null);

function useModalContext() {
  const ctx = useContext(ModalContext);
  if (!ctx) throw new Error('Modal components must be used within <Modal>');
  return ctx;
}

function Modal({ children }: { children: ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <ModalContext.Provider value={{ isOpen, open: () => setIsOpen(true), close: () => setIsOpen(false) }}>
      {children}
    </ModalContext.Provider>
  );
}

function Trigger({ children }: { children: ReactNode }) {
  const { open } = useModalContext();
  return <button onClick={open}>{children}</button>;
}

function Content({ children }: { children: ReactNode }) {
  const { isOpen, close } = useModalContext();
  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={close} role="dialog" aria-modal="true">
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        {children}
        <button onClick={close} aria-label="Close modal" className="modal-close">×</button>
      </div>
    </div>
  );
}

function Header({ children }: { children: ReactNode }) {
  return <div className="modal-header">{children}</div>;
}

function Body({ children }: { children: ReactNode }) {
  return <div className="modal-body">{children}</div>;
}

function Footer({ children }: { children: ReactNode }) {
  return <div className="modal-footer">{children}</div>;
}

// Attach sub-components
Modal.Trigger = Trigger;
Modal.Content = Content;
Modal.Header = Header;
Modal.Body = Body;
Modal.Footer = Footer;

export { Modal };

// Usage
function App() {
  return (
    <Modal>
      <Modal.Trigger>Open Settings</Modal.Trigger>
      <Modal.Content>
        <Modal.Header>Settings</Modal.Header>
        <Modal.Body>Content here...</Modal.Body>
        <Modal.Footer>
          <button>Save</button>
        </Modal.Footer>
      </Modal.Content>
    </Modal>
  );
}
```

### Generic List Component
```tsx
// WHY: Reusable list with type-safe rendering

interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => ReactNode;
  keyExtractor: (item: T) => string;
  emptyMessage?: string;
  loading?: boolean;
  className?: string;
}

export function List<T>({
  items,
  renderItem,
  keyExtractor,
  emptyMessage = 'No items found',
  loading = false,
  className,
}: ListProps<T>) {
  if (loading) return <div className="skeleton-list">Loading...</div>;

  if (items.length === 0) {
    return <p className="text-muted">{emptyMessage}</p>;
  }

  return (
    <ul className={className}>
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>{renderItem(item, index)}</li>
      ))}
    </ul>
  );
}

// Usage (fully typed)
<List
  items={users}
  renderItem={(user) => <UserCard user={user} />}
  keyExtractor={(user) => user.id}
  emptyMessage="No users found"
/>
```

---

## Hooks

### Essential Custom Hooks
```tsx
// ── useDebounce ──
import { useState, useEffect } from 'react';

export function useDebounce<T>(value: T, delay: number = 300): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

// ── useLocalStorage ──
export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    const valueToStore = value instanceof Function ? value(storedValue) : value;
    setStoredValue(valueToStore);
    localStorage.setItem(key, JSON.stringify(valueToStore));
  };

  return [storedValue, setValue] as const;
}

// ── useFetch (with AbortController) ──
export function useFetch<T>(url: string, options?: RequestInit) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const controller = new AbortController();

    async function fetchData() {
      try {
        setLoading(true);
        setError(null);
        const res = await fetch(url, { ...options, signal: controller.signal });

        if (!res.ok) {
          throw new Error(`HTTP ${res.status}: ${res.statusText}`);
        }

        const json = await res.json();
        setData(json);
      } catch (err) {
        if (err instanceof Error && err.name !== 'AbortError') {
          setError(err);
        }
      } finally {
        setLoading(false);
      }
    }

    fetchData();
    return () => controller.abort();
  }, [url]);

  return { data, error, loading };
}

// ── useMediaQuery ──
export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => window.matchMedia(query).matches);

  useEffect(() => {
    const media = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    media.addEventListener('change', handler);
    return () => media.removeEventListener('change', handler);
  }, [query]);

  return matches;
}

const isMobile = useMediaQuery('(max-width: 768px)');
```

---

## State Management

### Zustand (Recommended for Client State)
```tsx
// WHY: Simple, no boilerplate, no providers needed, TypeScript-friendly
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthState {
  user: User | null;
  accessToken: string | null;
  isAuthenticated: boolean;

  // Actions
  login: (user: User, token: string) => void;
  logout: () => void;
  updateProfile: (updates: Partial<User>) => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      isAuthenticated: false,

      login: (user, token) =>
        set({ user, accessToken: token, isAuthenticated: true }),

      logout: () =>
        set({ user: null, accessToken: null, isAuthenticated: false }),

      updateProfile: (updates) =>
        set((state) => ({
          user: state.user ? { ...state.user, ...updates } : null,
        })),
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ user: state.user }),  // Don't persist token
    }
  )
);

// Usage in components
function Header() {
  const { user, logout, isAuthenticated } = useAuthStore();

  if (!isAuthenticated) return <LoginButton />;

  return (
    <header>
      <span>{user?.name}</span>
      <button onClick={logout}>Logout</button>
    </header>
  );
}
```

### React Query / TanStack Query (Server State)
```tsx
// WHY: Handles server state — caching, refetching, pagination, mutations
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { usersApi } from '../services/users.api';

// ── Query (READ) ──
export function useUsers(page: number = 1, search?: string) {
  return useQuery({
    queryKey: ['users', { page, search }],
    queryFn: () => usersApi.list({ page, search }),
    staleTime: 5 * 60 * 1000,           // Cache for 5 minutes
    placeholderData: (prev) => prev,      // Show previous data while fetching
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: ['users', id],
    queryFn: () => usersApi.getById(id),
    enabled: !!id,                        // Only fetch when ID exists
  });
}

// ── Mutation (CREATE/UPDATE/DELETE) ──
export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: usersApi.create,
    onSuccess: () => {
      // Invalidate cache — triggers refetch
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
    onError: (error) => {
      console.error('Failed to create user:', error);
    },
  });
}

export function useDeleteUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => usersApi.delete(id),
    onSuccess: (_, deletedId) => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      // Remove from cache immediately (optimistic)
      queryClient.removeQueries({ queryKey: ['users', deletedId] });
    },
  });
}

// ── Usage in component ──
function UserListPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 300);

  const { data, isLoading, error } = useUsers(page, debouncedSearch);
  const deleteMutation = useDeleteUser();

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div>
      <SearchInput value={search} onChange={setSearch} />
      <List
        items={data?.users ?? []}
        renderItem={(user) => (
          <UserCard
            user={user}
            showActions
            onDelete={() => deleteMutation.mutate(user.id)}
          />
        )}
        keyExtractor={(u) => u.id}
      />
      <Pagination
        currentPage={page}
        totalPages={data?.totalPages ?? 1}
        onPageChange={setPage}
      />
    </div>
  );
}
```

---

## Forms (React Hook Form + Zod)

```tsx
import { useForm, type SubmitHandler } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Schema (single source of truth for validation)
const createUserSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(100),
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  role: z.enum(['admin', 'editor', 'viewer']),
});

type CreateUserForm = z.infer<typeof createUserSchema>;

function CreateUserDialog() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<CreateUserForm>({
    resolver: zodResolver(createUserSchema),
    defaultValues: { role: 'viewer' },
  });

  const createUser = useCreateUser();

  const onSubmit: SubmitHandler<CreateUserForm> = async (data) => {
    await createUser.mutateAsync(data);
    reset();
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <div>
        <label htmlFor="name">Name</label>
        <input id="name" {...register('name')} aria-invalid={!!errors.name} />
        {errors.name && <span role="alert">{errors.name.message}</span>}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input id="email" type="email" {...register('email')} aria-invalid={!!errors.email} />
        {errors.email && <span role="alert">{errors.email.message}</span>}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input id="password" type="password" {...register('password')} aria-invalid={!!errors.password} />
        {errors.password && <span role="alert">{errors.password.message}</span>}
      </div>

      <div>
        <label htmlFor="role">Role</label>
        <select id="role" {...register('role')}>
          <option value="viewer">Viewer</option>
          <option value="editor">Editor</option>
          <option value="admin">Admin</option>
        </select>
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create User'}
      </button>
    </form>
  );
}
```

---

## Error Boundaries

```tsx
import { Component, type ErrorInfo, type ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode | ((error: Error, reset: () => void) => ReactNode);
}

interface State {
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
    // Report to monitoring service (Sentry, Datadog, etc.)
  }

  reset = () => {
    this.setState({ error: null });
  };

  render() {
    if (this.state.error) {
      if (typeof this.props.fallback === 'function') {
        return this.props.fallback(this.state.error, this.reset);
      }
      return this.props.fallback ?? (
        <div role="alert">
          <h2>Something went wrong</h2>
          <p>{this.state.error.message}</p>
          <button onClick={this.reset}>Try again</button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary fallback={(error, reset) => (
  <div>
    <p>Error: {error.message}</p>
    <button onClick={reset}>Retry</button>
  </div>
)}>
  <UserListPage />
</ErrorBoundary>
```

---

## Performance Optimization

```tsx
import { memo, useMemo, useCallback, lazy, Suspense } from 'react';

// ── React.memo (prevent unnecessary re-renders) ──
// WHY: Only re-renders when props actually change
const UserRow = memo(function UserRow({
  user,
  onSelect,
}: {
  user: User;
  onSelect: (id: string) => void;
}) {
  return (
    <tr onClick={() => onSelect(user.id)}>
      <td>{user.name}</td>
      <td>{user.email}</td>
    </tr>
  );
});

// ── useMemo (expensive calculations) ──
function Dashboard({ orders }: { orders: Order[] }) {
  const stats = useMemo(() => ({
    total: orders.length,
    revenue: orders.reduce((sum, o) => sum + o.amount, 0),
    avgOrderValue: orders.length > 0 ? orders.reduce((sum, o) => sum + o.amount, 0) / orders.length : 0,
    statusBreakdown: Object.groupBy(orders, (o) => o.status),
  }), [orders]);

  return <StatsDisplay stats={stats} />;
}

// ── useCallback (stable function references) ──
function UserList() {
  const [selectedId, setSelectedId] = useState<string | null>(null);

  // Stable reference — doesn't change between renders
  const handleSelect = useCallback((id: string) => {
    setSelectedId(id);
  }, []);

  return (
    <table>
      <tbody>
        {users.map((user) => (
          <UserRow key={user.id} user={user} onSelect={handleSelect} />
        ))}
      </tbody>
    </table>
  );
}

// ── Lazy loading (code splitting) ──
const AdminDashboard = lazy(() => import('./features/admin/AdminDashboard'));
const UserSettings = lazy(() => import('./features/settings/UserSettings'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/settings" element={<UserSettings />} />
      </Routes>
    </Suspense>
  );
}
```

---

## API Service Pattern

```typescript
// src/services/api-client.ts
const BASE_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:3000/api/v1';

class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(path: string, options?: RequestInit): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options?.headers,
    };

    // Attach auth token
    const token = useAuthStore.getState().accessToken;
    if (token) {
      (headers as Record<string, string>)['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(url, { ...options, headers });

    if (response.status === 401) {
      // Token expired — attempt refresh
      const refreshed = await this.refreshToken();
      if (refreshed) {
        return this.request<T>(path, options);  // Retry
      }
      useAuthStore.getState().logout();
      throw new Error('Session expired');
    }

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      throw new ApiError(response.status, error.error?.code ?? 'UNKNOWN', error.error?.message ?? 'Request failed');
    }

    return response.json();
  }

  get<T>(path: string) { return this.request<T>(path); }

  post<T>(path: string, data: unknown) {
    return this.request<T>(path, { method: 'POST', body: JSON.stringify(data) });
  }

  patch<T>(path: string, data: unknown) {
    return this.request<T>(path, { method: 'PATCH', body: JSON.stringify(data) });
  }

  delete<T>(path: string) {
    return this.request<T>(path, { method: 'DELETE' });
  }
}

export const api = new ApiClient(BASE_URL);

// src/features/users/services/users.api.ts
export const usersApi = {
  list: (params: { page?: number; search?: string }) =>
    api.get<PaginatedResponse<User>>(`/users?${new URLSearchParams(params as any)}`),

  getById: (id: string) => api.get<{ data: User }>(`/users/${id}`),

  create: (data: CreateUserInput) => api.post<{ data: User }>('/users', data),

  update: (id: string, data: Partial<CreateUserInput>) => api.patch<{ data: User }>(`/users/${id}`, data),

  delete: (id: string) => api.delete<void>(`/users/${id}`),
};
```

---

## Testing

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { UserCard } from '../components/UserCard';
import { CreateUserDialog } from '../features/users/components/CreateUserDialog';

// Test wrapper with providers
function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}

describe('UserCard', () => {
  const mockUser = { id: '1', name: 'John Doe', email: 'john@test.com' };

  it('renders user information', () => {
    render(<UserCard user={mockUser} />);
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@test.com')).toBeInTheDocument();
  });

  it('calls onEdit when edit button clicked', async () => {
    const user = userEvent.setup();
    const handleEdit = vi.fn();

    render(<UserCard user={mockUser} showActions onEdit={handleEdit} />);
    await user.click(screen.getByRole('button', { name: /edit john doe/i }));

    expect(handleEdit).toHaveBeenCalledWith('1');
  });
});

describe('CreateUserDialog', () => {
  it('validates required fields', async () => {
    const user = userEvent.setup();

    render(<CreateUserDialog />, { wrapper: createWrapper() });

    await user.click(screen.getByRole('button', { name: /create user/i }));

    await waitFor(() => {
      expect(screen.getByText(/name must be at least 2 characters/i)).toBeInTheDocument();
    });
  });
});
```

---

## Anti-Patterns

```tsx
// ❌ DON'T: Prop drilling (passing props through many layers)
// ✅ DO: Use context, Zustand, or composition

// ❌ DON'T: Fetch data in useEffect without cleanup
useEffect(() => {
  fetch('/api/users').then(r => r.json()).then(setUsers);  // ❌ Race condition, no abort
}, []);
// ✅ DO: Use React Query or useFetch with AbortController

// ❌ DON'T: Create new functions/objects in render
<UserList onSelect={(id) => handleSelect(id)} />  // ❌ New function every render
// ✅ DO: Use useCallback
const handleSelect = useCallback((id: string) => { /* ... */ }, []);

// ❌ DON'T: Use index as key for dynamic lists
{items.map((item, index) => <Item key={index} />)}  // ❌ Breaks on reorder
// ✅ DO: Use unique, stable identifier
{items.map((item) => <Item key={item.id} />)}

// ❌ DON'T: Large monolithic components (>200 lines)
// ✅ DO: Extract into smaller, focused components and hooks

// ❌ DON'T: Direct DOM manipulation
document.getElementById('app')!.innerHTML = 'wrong';  // ❌
// ✅ DO: Use refs and React state
```

---

## Rules Integration
- **Components**: Functional only, TypeScript props interfaces, compound pattern for complex UI
- **State**: Zustand for client state, React Query for server state, local state with useState
- **Performance**: React.memo for expensive renders, useMemo/useCallback, lazy loading with Suspense
- **Forms**: React Hook Form + Zod validation, accessible labels and aria attributes
- **Testing**: React Testing Library (user-centric queries), Vitest, test behavior not implementation
