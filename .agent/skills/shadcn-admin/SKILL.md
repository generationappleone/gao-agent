---
name: Shadcn Admin
description: Skill for building admin dashboards with Shadcn Admin, a modern React admin template using shadcn/ui, Tailwind CSS, and Next.js with dark mode and responsive layout.
---

# Shadcn Admin Skill

## Overview
Shadcn Admin is a modern, open-source admin dashboard built with shadcn/ui (Radix UI primitives), Tailwind CSS, and React (Next.js). It combines the accessibility of Radix with the flexibility of Tailwind for premium admin interfaces.

## Installation
```bash
git clone https://github.com/satnaing/shadcn-admin.git
cd shadcn-admin
npm install
npm run dev
```

## Project Structure
```
src/
├── app/                       # Next.js app router
│   ├── (auth)/                # Auth layout group
│   │   ├── sign-in/
│   │   └── sign-up/
│   ├── (dashboard)/           # Dashboard layout group
│   │   ├── layout.tsx         # Sidebar + header layout
│   │   ├── page.tsx           # Dashboard home
│   │   ├── users/
│   │   ├── settings/
│   │   └── tasks/
│   └── layout.tsx             # Root layout
├── components/
│   ├── ui/                    # shadcn/ui components
│   ├── layout/
│   │   ├── sidebar.tsx        # Collapsible sidebar
│   │   ├── header.tsx         # Top navigation
│   │   ├── user-nav.tsx       # User dropdown
│   │   └── theme-toggle.tsx   # Dark mode switch
│   ├── dashboard/             # Dashboard-specific components
│   └── data-table/            # TanStack Table components
├── hooks/                     # Custom hooks
│   ├── use-sidebar-toggle.ts
│   └── use-check-active-nav.ts
├── lib/
│   ├── utils.ts               # cn() helper
│   └── menu-list.ts           # Sidebar menu items
└── data/                      # Mock data & schemas
```

## Layout Pattern
```tsx
// (dashboard)/layout.tsx — Standard Shadcn Admin layout
import { Sidebar } from '@/components/layout/sidebar';
import { Header } from '@/components/layout/header';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <div className="flex w-full flex-col">
        <Header />
        <main className="flex-1 space-y-4 p-4 pt-6 md:p-8">{children}</main>
      </div>
    </div>
  );
}
```

## Key Components

### Dashboard Stats
```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

<div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
  <Card>
    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
      <CardTitle className="text-sm font-medium text-muted-foreground">Total Revenue</CardTitle>
      <DollarSign className="h-4 w-4 text-muted-foreground" />
    </CardHeader>
    <CardContent>
      <div className="text-2xl font-bold">$45,231.89</div>
      <p className="text-xs text-muted-foreground">
        <span className="text-emerald-500">+20.1%</span> from last month
      </p>
    </CardContent>
  </Card>
</div>
```

### Data Table with TanStack
```tsx
import { DataTable } from '@/components/data-table';
import { columns } from './columns';

// Columns definition with sorting, filtering, row actions
const columns: ColumnDef<User>[] = [
  { id: 'select', header: ({ table }) => <Checkbox ... />, cell: ({ row }) => <Checkbox ... /> },
  { accessorKey: 'name', header: ({ column }) => <DataTableColumnHeader column={column} title="Name" /> },
  { accessorKey: 'email', header: 'Email' },
  { accessorKey: 'status', header: 'Status', cell: ({ row }) => <Badge variant={...}>{row.getValue('status')}</Badge> },
  { id: 'actions', cell: ({ row }) => <DataTableRowActions row={row} /> },
];

<DataTable columns={columns} data={users} filterColumn="email" />
```

### Sidebar with Collapsible Groups
```tsx
const menuList = [
  { groupLabel: 'Dashboard', menus: [
    { href: '/', label: 'Dashboard', icon: LayoutDashboard },
  ]},
  { groupLabel: 'Management', menus: [
    { href: '/users', label: 'Users', icon: Users, submenus: [
      { href: '/users', label: 'All Users' },
      { href: '/users/create', label: 'Add User' },
    ]},
    { href: '/settings', label: 'Settings', icon: Settings },
  ]},
];
```

## Theming
```css
/* globals.css — CSS variables for theming */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --primary: 245 58% 51%;
    --primary-foreground: 210 40% 98%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --border: 214.3 31.8% 91.4%;
    --sidebar-background: 222.2 84% 4.9%;
    --sidebar-foreground: 210 40% 98%;
  }
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 6%;
    --sidebar-background: 222.2 84% 3%;
  }
}
```

## Rules Integration
- **UI/UX**: Uses shadcn/ui components — inherits Radix accessibility + Tailwind styling
- **Accessibility**: Fully keyboard navigable, screen reader support from Radix primitives
- **SOLID**: Feature-based organization, components are composable and customizable
