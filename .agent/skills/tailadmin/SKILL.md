---
name: TailAdmin
description: Skill for building admin dashboards with TailAdmin, a free Tailwind CSS admin template for React, Next.js, and Vue, covering layout, components, and customization.
---

# TailAdmin Skill

## Overview
TailAdmin is a free, open-source admin dashboard template built with Tailwind CSS. Available for React (Next.js), Vue (Nuxt), and HTML. Features 200+ UI components, pre-built dashboard pages, and dark mode.

## Installation

### React / Next.js
```bash
git clone https://github.com/TailAdmin/free-nextjs-admin-dashboard.git
cd free-nextjs-admin-dashboard
npm install
npm run dev
```

### Vue / Nuxt
```bash
git clone https://github.com/TailAdmin/free-vue-admin-dashboard.git
cd free-vue-admin-dashboard
npm install
npm run dev
```

## Project Structure
```
src/
├── app/                    # Next.js app router pages
├── components/
│   ├── Charts/             # ApexCharts components
│   ├── DataTables/         # Table components
│   ├── Forms/              # Form elements
│   ├── Header/             # Top navigation bar
│   ├── Sidebar/            # Sidebar navigation
│   ├── Tables/             # Data table variations
│   └── ui/                 # Base UI components
├── context/                # React context (sidebar state)
├── hooks/                  # Custom hooks
└── styles/                 # Global CSS
```

## Key Features
- **Dashboard pages**: Analytics, Marketing, CRM, Stocks, E-commerce
- **Components**: Charts (ApexCharts), Data tables, Forms, Authentication pages
- **Layout**: Collapsible sidebar, top navbar, responsive
- **Dark mode**: Full dark mode support via Tailwind `dark:` prefix
- **Auth pages**: Sign in, Sign up, Reset password, Two-step verification

## Customization
```tsx
// Customize sidebar navigation items
const menuItems = [
  { label: 'Dashboard', icon: <DashboardIcon />, path: '/' },
  { label: 'Users', icon: <UsersIcon />, path: '/users',
    children: [
      { label: 'All Users', path: '/users' },
      { label: 'Add User', path: '/users/create' },
    ]
  },
];

// Customize theme colors in tailwind.config.ts
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#6366f1',
        'body-bg': '#f1f5f9',
        'body-bg-dark': '#0f172a',
        'sidebar-bg': '#1e293b',
      },
    },
  },
};
```

## Dashboard Layout Pattern
```tsx
// Standard TailAdmin layout structure
<div className="flex h-screen overflow-hidden">
  {/* Sidebar */}
  <Sidebar sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />

  {/* Content area */}
  <div className="relative flex flex-1 flex-col overflow-y-auto overflow-x-hidden">
    {/* Header */}
    <Header sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />

    {/* Main content */}
    <main className="mx-auto max-w-screen-2xl p-4 md:p-6 2xl:p-10">
      {children}
    </main>
  </div>
</div>
```

## Rules Integration
- **UI/UX**: Extend TailAdmin's components with custom brand colors and animations
- **Accessibility**: Add ARIA labels and keyboard navigation to custom components
- **Dependencies**: Built on Next.js + Tailwind CSS — check version compatibility
