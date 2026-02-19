---
name: React.js
description: Skill for building modern web applications with React.js, covering project setup, component architecture, state management, hooks, routing, testing, and performance optimization.
---

# React.js Skill

## Overview
React is a JavaScript library for building user interfaces. Use this skill for SPAs, SSR apps (Next.js), and component-driven UI development.

## Project Setup

### Vite (Recommended for SPAs)
```bash
npx -y create-vite@latest ./ --template react-ts
npm install
```

### Next.js (Recommended for SSR/SSG)
```bash
npx -y create-next-app@latest ./ --typescript --tailwind --eslint --app --src-dir
```

## Directory Structure (Feature-Based)
```
src/
├── features/               # Feature modules (SRP)
│   ├── auth/
│   │   ├── components/     # Auth-specific components
│   │   ├── hooks/          # Auth hooks (useAuth, useLogin)
│   │   ├── services/       # Auth API calls
│   │   ├── types/          # Auth TypeScript types
│   │   └── index.ts        # Public API barrel export
│   └── users/
│       ├── components/
│       ├── hooks/
│       ├── services/
│       └── types/
├── shared/
│   ├── components/         # Reusable UI components
│   ├── hooks/              # Shared custom hooks
│   ├── services/           # API client, utilities
│   ├── types/              # Shared types/interfaces
│   └── utils/              # Helper functions
├── layouts/                # Page layouts
├── pages/ or app/          # Route pages
├── providers/              # Context providers
└── styles/                 # Global styles
```

## Component Patterns

### Functional Components with TypeScript
```tsx
// ✅ REQUIRED: Typed props, single responsibility
interface UserCardProps {
  user: User;
  onEdit: (userId: string) => void;
  onDelete: (userId: string) => void;
  isLoading?: boolean;
}

export function UserCard({ user, onEdit, onDelete, isLoading = false }: UserCardProps) {
  if (isLoading) return <UserCardSkeleton />;

  return (
    <article className="user-card" role="article" aria-label={`User ${user.name}`}>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <div className="user-card__actions">
        <button onClick={() => onEdit(user.id)} aria-label={`Edit ${user.name}`}>Edit</button>
        <button onClick={() => onDelete(user.id)} aria-label={`Delete ${user.name}`}>Delete</button>
      </div>
    </article>
  );
}
```

### Custom Hooks (DIP — Abstract Data Fetching)
```tsx
// ✅ REQUIRED: Encapsulate logic in custom hooks
function useUsers() {
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    async function fetchUsers() {
      try {
        setIsLoading(true);
        const data = await userService.getAll({ signal: controller.signal });
        setUsers(data);
      } catch (err) {
        if (err instanceof Error && err.name !== 'AbortError') {
          setError(err);
        }
      } finally {
        setIsLoading(false);
      }
    }

    fetchUsers();
    return () => controller.abort();
  }, []);

  return { users, isLoading, error };
}
```

## State Management

### Decision Matrix
| Scenario | Solution |
|----------|----------|
| Local component state | `useState` |
| Complex local state | `useReducer` |
| Shared state (small) | React Context + `useReducer` |
| Server state (API) | TanStack Query (React Query) |
| Global client state | Zustand or Jotai |
| Complex enterprise state | Redux Toolkit |

### TanStack Query (Recommended for API State)
```tsx
function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => userService.getAll(),
    staleTime: 5 * 60 * 1000,
  });
}

function useCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateUserDto) => userService.create(data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
  });
}
```

## Performance Optimization
- Use `React.memo()` for expensive components that receive stable props
- Use `useMemo()` for expensive computations
- Use `useCallback()` for callback props passed to memoized children
- Implement **code splitting** with `React.lazy()` and `Suspense`
- Use **virtualization** (react-window / react-virtuoso) for long lists

## Testing
```tsx
import { render, screen, fireEvent } from '@testing-library/react';

describe('UserCard', () => {
  it('renders user info and handles edit click', () => {
    const onEdit = vi.fn();
    render(<UserCard user={mockUser} onEdit={onEdit} onDelete={vi.fn()} />);

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    fireEvent.click(screen.getByLabelText('Edit John Doe'));
    expect(onEdit).toHaveBeenCalledWith(mockUser.id);
  });
});
```

## Rules Integration
- **SOLID**: Feature-based structure, custom hooks for logic (SRP), interfaces for services (DIP)
- **Security**: Sanitize user inputs, no `dangerouslySetInnerHTML` with raw data, env vars for secrets
- **Dependencies**: Check React version compatibility, use Bundlephobia for size checks
