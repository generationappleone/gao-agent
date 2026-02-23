---
name: TailAdmin
description: Skill for building admin dashboards with TailAdmin, a free Tailwind CSS admin template for React, Next.js, and Vue, covering layout, components, and customization.
---

# TailAdmin React Skill

## Overview

TailAdmin is a **free and open-source admin dashboard template** built with **React 19**, **TypeScript**, and **Tailwind CSS v4**. It provides pre-built dashboard UI components, charts (ApexCharts), authentication pages, and a modern layout system for building data-driven back-end interfaces.

### Key Features

| Feature | Free | PRO |
|---------|------|-----|
| Unique Dashboards | 1 (Ecommerce) | 7 (Analytics, CRM, Marketing, SaaS, Stocks, Logistics, Ecommerce) |
| Dashboard Components | 35+ | 500+ |
| UI Elements | 50+ | 500+ |
| Charts | Line, Bar (ApexCharts) | 10+ chart types |
| Pre-built Pages | Profile, 404, Auth | Settings, Invoice, Pricing, FAQ, Teams, Mail, Chat, AI Pages |
| Dark Mode | ✅ | ✅ |
| Figma Design File | Basic | Complete |
| TypeScript | ✅ Full | ✅ Full |

### Version History
- **v2.1.0** (Dec 30, 2025) — Date Picker fixes in Charts
- **v2.0.2** (Mar 25, 2025) — Upgraded to React 19
- **v2.0.1** (Feb 27, 2025) — Migrated to Tailwind CSS v4
- **v2.0.0** (Feb 2025) — Complete redesign, collapsible sidebar, calendar, chat, ApexCharts migration
- **v1.3.7** (Jun 2024) — DefaultLayout refactor, ClickOutside component

### Available Versions

| Framework | Repository |
|-----------|-----------|
| React (Vite) | `TailAdmin/free-react-tailwind-admin-dashboard` |
| Next.js | `TailAdmin/free-nextjs-admin-dashboard` |
| Vue.js | `TailAdmin/free-vue-admin-dashboard` |
| Angular | Available on tailadmin.com |
| Laravel (Blade) | Available on tailadmin.com |
| HTML | Available on tailadmin.com |

---

## 1. Installation

### Prerequisites
- Node.js **18.x** or later (recommended: **20.x+**)

### Setup

```bash
# Clone repository
git clone https://github.com/TailAdmin/free-react-tailwind-admin-dashboard.git
cd free-react-tailwind-admin-dashboard

# Install dependencies
npm install

# Start development server
npm run dev
# → Open http://localhost:5173

# Build for production
npm run build

# Preview production build
npm run preview
```

> ⚠️ **Windows Users:** If you encounter issues when cloning, place the repository near the root drive (e.g., `C:\Projects\`).

### Tech Stack Bundled

| Tool | Version | Purpose |
|------|---------|---------|
| React | 19.x | UI library |
| TypeScript | 5.x | Type safety |
| Vite | 6.x | Build tool & dev server |
| Tailwind CSS | v4 | Utility-first CSS |
| React Router DOM | 7.x | Client-side routing |
| ApexCharts | 4.x | Interactive charts |
| react-apexcharts | 1.x | React wrapper for ApexCharts |
| Flatpickr | 4.x | Date/time picker |
| Jsvectormap | 1.x | Interactive maps |

---

## 2. Project Structure

```
free-react-tailwind-admin-dashboard/
├── public/                    ← Static assets
│   └── images/
│       ├── logo/              ← Brand logos (dark/light variants)
│       ├── user/              ← User avatar images
│       ├── cards/             ← Dashboard card images
│       └── country/           ← Country flag icons
├── src/
│   ├── components/            ← All reusable components
│   │   ├── Auth/              ← SignIn, SignUp form components
│   │   ├── Charts/            ← ApexCharts wrapper components
│   │   │   ├── ChartOne.tsx   ← Line + Area chart
│   │   │   ├── ChartTwo.tsx   ← Bar chart
│   │   │   └── ChartThree.tsx ← Donut chart
│   │   ├── Datatables/        ← Data table components
│   │   ├── Dropdowns/         ← Notification, User, Message dropdowns
│   │   ├── Header/            ← Top navigation header
│   │   │   ├── index.tsx
│   │   │   └── DropdownUser.tsx
│   │   ├── Sidebar/           ← Left sidebar navigation
│   │   │   ├── index.tsx
│   │   │   └── SidebarItem.tsx
│   │   ├── Tables/            ← Table variations
│   │   ├── Modals/            ← Modal dialog components
│   │   ├── Cards/             ← Various card components
│   │   ├── Buttons/           ← Button variants
│   │   ├── Alerts/            ← Alert/notification components
│   │   ├── Badges/            ← Badge components
│   │   ├── Breadcrumbs/       ← Breadcrumb navigation
│   │   ├── Pagination/        ← Pagination controls
│   │   ├── Tooltips/          ← Tooltip component
│   │   ├── Tabs/              ← Tab navigation
│   │   ├── Progress/          ← Progress bar
│   │   ├── Avatars/           ← Avatar components
│   │   ├── Popovers/          ← Popover component
│   │   ├── Carousel/          ← Image carousel
│   │   ├── Accordion/         ← Collapsible accordion
│   │   ├── Testimonials/      ← Testimonial cards
│   │   ├── common/            ← Shared utilities
│   │   │   ├── ComponentCard.tsx   ← Component showcase wrapper
│   │   │   └── PageBreadcrumb.tsx  ← Page-level breadcrumb
│   │   └── ui/                ← Base UI primitives
│   │       ├── button/
│   │       ├── dropdown/
│   │       ├── input/
│   │       ├── label/
│   │       ├── select/
│   │       ├── switch/
│   │       ├── textarea/
│   │       └── table/
│   ├── context/               ← React Context providers
│   │   ├── SidebarContext.tsx  ← Sidebar open/close state
│   │   └── ThemeContext.tsx    ← Dark/light mode state
│   ├── hooks/                 ← Custom React hooks
│   │   └── useClickOutside.ts ← Click outside detection
│   ├── layout/                ← Layout wrapper
│   │   └── AppLayout.tsx      ← Main layout (Sidebar + Header + Content)
│   ├── pages/                 ← Route-level page components
│   │   ├── Dashboard/
│   │   │   └── EcommerceDashboard.tsx
│   │   ├── AuthPages/
│   │   │   ├── SignIn.tsx
│   │   │   └── SignUp.tsx
│   │   ├── Profile.tsx
│   │   ├── Calendar.tsx       ← FullCalendar integration (v2)
│   │   ├── Chat.tsx           ← Chat interface (v2)
│   │   ├── Tables.tsx
│   │   ├── Charts.tsx
│   │   ├── Forms/
│   │   │   ├── FormElements.tsx
│   │   │   └── FormLayout.tsx
│   │   ├── UIElements/        ← Component showcase pages
│   │   │   ├── Alerts.tsx
│   │   │   ├── Badges.tsx
│   │   │   ├── Buttons.tsx
│   │   │   ├── Modals.tsx
│   │   │   └── ...more
│   │   ├── OtherPages/
│   │   │   ├── NotFound.tsx   ← 404 page
│   │   │   └── BlankPage.tsx
│   │   └── Settings.tsx
│   ├── styles/                ← Global CSS
│   │   └── index.css          ← Tailwind directives + custom styles
│   ├── App.tsx                ← Root component with Router
│   ├── main.tsx               ← Entry point
│   └── types/                 ← TypeScript type definitions
│       └── index.ts
├── index.html
├── package.json
├── tsconfig.json
├── tailwind.config.ts         ← Tailwind CSS configuration (if v3)
├── postcss.config.js
└── vite.config.ts             ← Vite bundler configuration
```

---

## 3. Layout Architecture

### 3.1 AppLayout — Main Layout Structure

```tsx
// src/layout/AppLayout.tsx
import React, { useState, useEffect } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import { useSidebar } from '../context/SidebarContext';

const AppLayout: React.FC = () => {
  const { isOpen, isCollapsed } = useSidebar();

  return (
    <div className="flex h-screen overflow-hidden">
      {/* ===== Sidebar Start ===== */}
      <Sidebar />
      {/* ===== Sidebar End ===== */}

      {/* ===== Content Area Start ===== */}
      <div className="relative flex flex-1 flex-col overflow-y-auto overflow-x-hidden">
        {/* ===== Header Start ===== */}
        <Header />
        {/* ===== Header End ===== */}

        {/* ===== Main Content Start ===== */}
        <main>
          <div className="mx-auto max-w-(--breakpoint-2xl) p-4 md:p-6 2xl:p-10">
            <Outlet />
          </div>
        </main>
        {/* ===== Main Content End ===== */}
      </div>
      {/* ===== Content Area End ===== */}
    </div>
  );
};

export default AppLayout;
```

### 3.2 Sidebar Component

```tsx
// src/components/Sidebar/index.tsx
import React, { useRef, useEffect, useCallback, useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { useSidebar } from '../../context/SidebarContext';

// Navigation items definition
interface NavItem {
  label: string;
  icon: React.ReactNode;
  path?: string;           // For simple links
  children?: {             // For dropdown groups
    label: string;
    path: string;
  }[];
}

const navItems: NavItem[] = [
  {
    label: 'Dashboard',
    icon: <DashboardIcon />,
    path: '/',
  },
  {
    label: 'Users',
    icon: <UsersIcon />,
    children: [
      { label: 'All Users', path: '/users' },
      { label: 'Add User', path: '/users/create' },
    ],
  },
  {
    label: 'Settings',
    icon: <SettingsIcon />,
    path: '/settings',
  },
];

const Sidebar: React.FC = () => {
  const { isOpen, toggleSidebar, isMobile } = useSidebar();
  const { pathname } = useLocation();
  const sidebarRef = useRef<HTMLElement>(null);

  return (
    <aside
      ref={sidebarRef}
      className={`
        fixed left-0 top-0 z-[9999] flex h-screen
        w-[290px] flex-col overflow-y-hidden
        bg-gray-900 text-gray-300 duration-300 ease-linear
        dark:bg-gray-800
        lg:static lg:translate-x-0
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
      `}
    >
      {/* Logo */}
      <div className="flex items-center justify-between gap-2 px-6 py-5.5 lg:py-6.5">
        <NavLink to="/">
          <img src="/images/logo/logo.svg" alt="Logo" className="dark:hidden" />
          <img src="/images/logo/logo-dark.svg" alt="Logo" className="hidden dark:block" />
        </NavLink>

        {/* Close button (mobile only) */}
        <button
          onClick={toggleSidebar}
          className="block lg:hidden"
          aria-label="Close sidebar"
        >
          <svg className="fill-current" width="20" height="18" viewBox="0 0 20 18">
            {/* Close icon SVG */}
          </svg>
        </button>
      </div>

      {/* Navigation Menu */}
      <div className="no-scrollbar flex flex-col overflow-y-auto duration-300 ease-linear">
        <nav className="mt-5 px-4 py-4 lg:mt-9 lg:px-6">
          <div>
            <h3 className="mb-4 ml-4 text-sm font-semibold text-gray-400 uppercase">
              MENU
            </h3>
            <ul className="mb-6 flex flex-col gap-1.5">
              {navItems.map((item) => (
                <SidebarItem key={item.label} item={item} pathname={pathname} />
              ))}
            </ul>
          </div>
        </nav>
      </div>
    </aside>
  );
};

export default Sidebar;
```

### 3.3 Sidebar Item Component (with Dropdown)

```tsx
// src/components/Sidebar/SidebarItem.tsx
import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';

interface SidebarItemProps {
  item: NavItem;
  pathname: string;
}

const SidebarItem: React.FC<SidebarItemProps> = ({ item, pathname }) => {
  const isActive = item.path
    ? pathname === item.path
    : item.children?.some((child) => pathname === child.path);

  const [open, setOpen] = useState(isActive);

  // Simple link (no children)
  if (item.path && !item.children) {
    return (
      <li>
        <NavLink
          to={item.path}
          className={({ isActive }) => `
            group relative flex items-center gap-2.5 rounded-sm
            px-4 py-2 font-medium duration-300 ease-in-out
            hover:bg-gray-800 dark:hover:bg-gray-700
            ${isActive
              ? 'bg-gray-800 text-white dark:bg-gray-700'
              : 'text-gray-400'
            }
          `}
        >
          {item.icon}
          {item.label}
        </NavLink>
      </li>
    );
  }

  // Dropdown group (with children)
  return (
    <li>
      <button
        onClick={() => setOpen(!open)}
        className={`
          group relative flex w-full items-center gap-2.5 rounded-sm
          px-4 py-2 font-medium duration-300 ease-in-out
          hover:bg-gray-800 dark:hover:bg-gray-700
          ${isActive ? 'bg-gray-800 text-white' : 'text-gray-400'}
        `}
      >
        {item.icon}
        {item.label}
        {/* Dropdown arrow */}
        <svg
          className={`absolute right-4 top-1/2 -translate-y-1/2 fill-current transition-transform ${
            open ? 'rotate-180' : ''
          }`}
          width="20"
          height="20"
          viewBox="0 0 20 20"
        >
          <path d="M4.41 6.41L8 9.99l3.59-3.58L13 7.82l-5 5-5-5z" />
        </svg>
      </button>

      {/* Dropdown content */}
      <div className={`translate transform overflow-hidden ${!open && 'hidden'}`}>
        <ul className="mb-5.5 mt-4 flex flex-col gap-2.5 pl-6">
          {item.children?.map((child) => (
            <li key={child.path}>
              <NavLink
                to={child.path}
                className={({ isActive }) => `
                  group relative flex items-center gap-2.5 rounded-md px-4
                  font-medium duration-300 ease-in-out
                  hover:text-white
                  ${isActive ? 'text-white' : 'text-gray-400'}
                `}
              >
                {child.label}
              </NavLink>
            </li>
          ))}
        </ul>
      </div>
    </li>
  );
};

export default SidebarItem;
```

### 3.4 SidebarContext

```tsx
// src/context/SidebarContext.tsx
import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface SidebarContextType {
  isOpen: boolean;
  isCollapsed: boolean;
  isMobile: boolean;
  toggleSidebar: () => void;
  toggleCollapse: () => void;
}

const SidebarContext = createContext<SidebarContextType | undefined>(undefined);

export const SidebarProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [isOpen, setIsOpen] = useState(false);       // Mobile: drawer state
  const [isCollapsed, setIsCollapsed] = useState(false); // Desktop: collapsed state
  const [isMobile, setIsMobile] = useState(window.innerWidth < 1024);

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth < 1024);
      if (window.innerWidth >= 1024) {
        setIsOpen(false); // Close mobile drawer on desktop
      }
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const toggleSidebar = () => setIsOpen(!isOpen);
  const toggleCollapse = () => setIsCollapsed(!isCollapsed);

  return (
    <SidebarContext.Provider value={{ isOpen, isCollapsed, isMobile, toggleSidebar, toggleCollapse }}>
      {children}
    </SidebarContext.Provider>
  );
};

export const useSidebar = () => {
  const ctx = useContext(SidebarContext);
  if (!ctx) throw new Error('useSidebar must be used within SidebarProvider');
  return ctx;
};
```

### 3.5 Header Component

```tsx
// src/components/Header/index.tsx
import React from 'react';
import { useSidebar } from '../../context/SidebarContext';
import DropdownUser from './DropdownUser';
import DropdownNotification from './DropdownNotification';
import DarkModeSwitcher from './DarkModeSwitcher';

const Header: React.FC = () => {
  const { toggleSidebar } = useSidebar();

  return (
    <header className="sticky top-0 z-999 flex w-full bg-white shadow-sm dark:bg-gray-800 dark:shadow-none">
      <div className="flex flex-grow items-center justify-between px-4 py-4 md:px-6 2xl:px-11">
        {/* Hamburger Toggle (mobile) */}
        <div className="flex items-center gap-2 sm:gap-4 lg:hidden">
          <button
            onClick={toggleSidebar}
            aria-label="Toggle sidebar"
            className="z-99999 block rounded-sm border border-stroke bg-white p-1.5 shadow-sm dark:border-gray-700 dark:bg-gray-800 lg:hidden"
          >
            <span className="relative block h-5.5 w-5.5 cursor-pointer">
              {/* Hamburger lines */}
              <span className="absolute left-0 top-0 block h-full w-full">
                <span className="relative top-0 left-0 my-1 block h-0.5 w-0 rounded-sm bg-black delay-[0] duration-200 ease-in-out dark:bg-white" />
                <span className="relative top-0 left-0 my-1 block h-0.5 w-0 rounded-sm bg-black delay-150 duration-200 ease-in-out dark:bg-white" />
                <span className="relative top-0 left-0 my-1 block h-0.5 w-0 rounded-sm bg-black delay-200 duration-200 ease-in-out dark:bg-white" />
              </span>
            </span>
          </button>
        </div>

        {/* Search Bar */}
        <div className="hidden sm:block">
          <div className="relative">
            <button className="absolute left-0 top-1/2 -translate-y-1/2">
              <svg className="fill-body hover:fill-primary dark:fill-bodydark dark:hover:fill-primary" width="20" height="20">
                {/* Search icon */}
              </svg>
            </button>
            <input
              type="text"
              placeholder="Type to search..."
              className="w-full bg-transparent pl-9 pr-4 font-medium focus:outline-none xl:w-125"
            />
          </div>
        </div>

        {/* Header Right: Dark Mode + Notifications + User */}
        <div className="flex items-center gap-3 2xsm:gap-7">
          <DarkModeSwitcher />
          <DropdownNotification />
          <DropdownUser />
        </div>
      </div>
    </header>
  );
};

export default Header;
```

---

## 4. Routing

```tsx
// src/App.tsx
import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AppLayout from './layout/AppLayout';
import SignIn from './pages/AuthPages/SignIn';
import SignUp from './pages/AuthPages/SignUp';
import EcommerceDashboard from './pages/Dashboard/EcommerceDashboard';
import Profile from './pages/Profile';
import Calendar from './pages/Calendar';
import Tables from './pages/Tables';
import Charts from './pages/Charts';
import FormElements from './pages/Forms/FormElements';
import NotFound from './pages/OtherPages/NotFound';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Auth routes — tanpa layout */}
        <Route path="/auth/signin" element={<SignIn />} />
        <Route path="/auth/signup" element={<SignUp />} />

        {/* Dashboard routes — with AppLayout */}
        <Route element={<AppLayout />}>
          <Route index element={<EcommerceDashboard />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/calendar" element={<Calendar />} />
          <Route path="/tables" element={<Tables />} />
          <Route path="/charts" element={<Charts />} />
          <Route path="/forms/elements" element={<FormElements />} />
          <Route path="/forms/layout" element={<FormLayout />} />
          <Route path="/ui/alerts" element={<Alerts />} />
          <Route path="/ui/buttons" element={<Buttons />} />
          <Route path="/ui/modals" element={<Modals />} />
          <Route path="/settings" element={<Settings />} />
        </Route>

        {/* 404 */}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
```

---

## 5. Dark Mode Implementation

```tsx
// src/context/ThemeContext.tsx
import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

type Theme = 'light' | 'dark';

interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [theme, setTheme] = useState<Theme>(() => {
    // 1. Check localStorage
    const saved = localStorage.getItem('color-theme') as Theme | null;
    if (saved) return saved;
    // 2. Check system preference
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) return 'dark';
    // 3. Default
    return 'light';
  });

  useEffect(() => {
    // Apply theme to <html> element
    const root = document.documentElement;
    if (theme === 'dark') {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    localStorage.setItem('color-theme', theme);
  }, [theme]);

  const toggleTheme = () => setTheme(prev => prev === 'light' ? 'dark' : 'light');

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
};
```

```tsx
// DarkModeSwitcher component
import { useTheme } from '../../context/ThemeContext';

const DarkModeSwitcher: React.FC = () => {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      onClick={toggleTheme}
      className="flex items-center justify-center rounded-full bg-gray-100 p-2 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600"
      aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
    >
      {theme === 'light' ? (
        <svg className="h-5 w-5 text-gray-700" /* Moon icon */> ... </svg>
      ) : (
        <svg className="h-5 w-5 text-yellow-400" /* Sun icon */> ... </svg>
      )}
    </button>
  );
};
```

**Tailwind dark: prefix usage:**
```tsx
// Always use the dark: prefix for all elements
<div className="bg-white dark:bg-gray-800">
  <h1 className="text-gray-900 dark:text-white">Title</h1>
  <p className="text-gray-600 dark:text-gray-400">Description</p>
  <div className="border border-gray-200 dark:border-gray-700">
    Content
  </div>
</div>
```

---

## 6. Charts (ApexCharts)

### 6.1 Line + Area Chart

```tsx
// src/components/Charts/ChartOne.tsx
import React, { useState } from 'react';
import ReactApexChart from 'react-apexcharts';
import { ApexOptions } from 'apexcharts';

const ChartOne: React.FC = () => {
  const options: ApexOptions = {
    legend: {
      show: true,
      position: 'top',
      horizontalAlign: 'left',
    },
    colors: ['#3C50E0', '#80CAEE'],
    chart: {
      fontFamily: 'Satoshi, sans-serif',
      height: 335,
      type: 'area',
      toolbar: { show: false },
      dropShadow: {
        enabled: true,
        color: '#623CEA14',
        top: 10,
        blur: 4,
        left: 0,
        opacity: 0.1,
      },
    },
    responsive: [{
      breakpoint: 1024,
      options: { chart: { height: 300 } },
    }],
    stroke: {
      width: [2, 2],
      curve: 'smooth',
    },
    grid: {
      xaxis: { lines: { show: true } },
      yaxis: { lines: { show: true } },
    },
    dataLabels: { enabled: false },
    markers: {
      size: 4,
      colors: '#fff',
      strokeColors: ['#3056D3', '#80CAEE'],
      strokeWidth: 3,
      hover: { sizeOffset: 5 },
    },
    xaxis: {
      type: 'category',
      categories: ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr'],
      axisBorder: { show: false },
      axisTicks: { show: false },
    },
    yaxis: {
      title: { style: { fontSize: '0px' } },
      min: 0,
      max: 100,
    },
  };

  const series = [
    { name: 'Product One', data: [23, 11, 22, 27, 13, 22, 37, 21] },
    { name: 'Product Two', data: [30, 25, 36, 30, 45, 35, 64, 52] },
  ];

  return (
    <div className="rounded-sm border border-stroke bg-white px-5 pb-5 pt-7.5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-8">
      <div className="flex flex-wrap items-start justify-between gap-3 sm:flex-nowrap">
        <div className="flex w-full flex-wrap gap-3 sm:gap-5">
          <div className="flex min-w-47.5">
            <span className="mr-2 mt-1 flex h-4 w-4 items-center justify-center rounded-full border border-primary">
              <span className="block h-2.5 w-2.5 rounded-full bg-primary" />
            </span>
            <div className="w-full">
              <p className="font-semibold text-primary">Total Revenue</p>
              <p className="text-sm font-medium">12.04.2025 - 12.05.2025</p>
            </div>
          </div>
        </div>
      </div>

      <div id="chartOne" className="-ml-5">
        <ReactApexChart
          options={options}
          series={series}
          type="area"
          height={350}
        />
      </div>
    </div>
  );
};

export default ChartOne;
```

### 6.2 Bar Chart

```tsx
// src/components/Charts/ChartTwo.tsx
import ReactApexChart from 'react-apexcharts';

const options: ApexOptions = {
  colors: ['#3C50E0', '#80CAEE'],
  chart: {
    fontFamily: 'Satoshi, sans-serif',
    type: 'bar',
    height: 335,
    stacked: true,
    toolbar: { show: false },
    zoom: { enabled: false },
  },
  plotOptions: {
    bar: {
      horizontal: false,
      borderRadius: 4,
      columnWidth: '25%',
      borderRadiusApplication: 'end',
      borderRadiusWhenStacked: 'last',
    },
  },
  dataLabels: { enabled: false },
  xaxis: {
    categories: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  },
  legend: {
    position: 'top',
    horizontalAlign: 'left',
    fontFamily: 'Satoshi',
    fontWeight: 500,
    fontSize: '14px',
    markers: { radius: 99 },
  },
  fill: { opacity: 1 },
};

const series = [
  { name: 'Sales', data: [44, 55, 41, 67, 22, 43, 65] },
  { name: 'Revenue', data: [13, 23, 20, 8, 13, 27, 33] },
];

<ReactApexChart options={options} series={series} type="bar" height={350} />
```

### 6.3 Donut Chart

```tsx
// src/components/Charts/ChartThree.tsx
const options: ApexOptions = {
  chart: { fontFamily: 'Satoshi, sans-serif', type: 'donut' },
  colors: ['#3C50E0', '#6577F3', '#8FD0EF', '#0FADCF'],
  labels: ['Desktop', 'Tablet', 'Mobile', 'Unknown'],
  legend: {
    show: false,
    position: 'bottom',
  },
  plotOptions: {
    pie: {
      donut: {
        size: '65%',
        background: 'transparent',
      },
    },
  },
  dataLabels: { enabled: false },
  responsive: [{
    breakpoint: 2600,
    options: { chart: { width: 380 } },
  }],
};

const series = [65, 34, 12, 56];

<ReactApexChart options={options} series={series} type="donut" height={350} />
```

---

## 7. UI Component Patterns

### 7.1 ComponentCard Wrapper

```tsx
// src/components/common/ComponentCard.tsx
// Used to wrap example components on showcase pages

interface ComponentCardProps {
  title: string;
  desc?: string;
  children: React.ReactNode;
  className?: string;
}

const ComponentCard: React.FC<ComponentCardProps> = ({ title, desc, children, className }) => {
  return (
    <div className={`rounded-2xl border border-gray-200 bg-white dark:border-gray-700 dark:bg-gray-800 ${className}`}>
      <div className="border-b border-gray-200 px-6 py-5 dark:border-gray-700">
        <h3 className="text-base font-medium text-gray-800 dark:text-white/90">{title}</h3>
        {desc && <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{desc}</p>}
      </div>
      <div className="p-6">{children}</div>
    </div>
  );
};
```

### 7.2 Button Variants

```tsx
{/* Primary */}
<button className="inline-flex items-center justify-center rounded-lg bg-primary px-5 py-3 text-center font-medium text-white hover:bg-opacity-90">
  Primary Button
</button>

{/* Outline */}
<button className="inline-flex items-center justify-center rounded-lg border border-primary px-5 py-3 text-center font-medium text-primary hover:bg-primary hover:text-white transition">
  Outline Button
</button>

{/* Danger */}
<button className="inline-flex items-center justify-center rounded-lg bg-red-500 px-5 py-3 text-center font-medium text-white hover:bg-red-600 transition">
  Danger Button
</button>

{/* With icon */}
<button className="inline-flex items-center gap-2 rounded-lg bg-primary px-5 py-3 font-medium text-white hover:bg-opacity-90">
  <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
  </svg>
  Add Item
</button>

{/* Loading */}
<button className="inline-flex items-center gap-2 rounded-lg bg-primary px-5 py-3 font-medium text-white opacity-70 cursor-not-allowed" disabled>
  <svg className="h-5 w-5 animate-spin" viewBox="0 0 24 24">
    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
  </svg>
  Processing...
</button>
```

### 7.3 Alert Component

```tsx
// Alert variants
<div className="flex w-full rounded-lg border-l-6 border-green-500 bg-green-100 px-7 py-8 dark:bg-green-500/10">
  <div className="mr-5 flex h-9 w-9 items-center justify-center rounded-full bg-green-500">
    <svg className="h-5 w-5 text-white" /* check icon */ />
  </div>
  <div className="w-full">
    <h5 className="mb-3 text-lg font-semibold text-green-800 dark:text-green-300">
      Success Alert
    </h5>
    <p className="leading-relaxed text-green-700 dark:text-green-200">
      Your operation was completed successfully!
    </p>
  </div>
</div>

{/* Warning */}
<div className="flex w-full rounded-lg border-l-6 border-yellow-500 bg-yellow-100 px-7 py-8 dark:bg-yellow-500/10">
  ...
</div>

{/* Error */}
<div className="flex w-full rounded-lg border-l-6 border-red-500 bg-red-100 px-7 py-8 dark:bg-red-500/10">
  ...
</div>
```

### 7.4 Table Component

```tsx
// Data table with sorting/filtering capability
<div className="rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
  <div className="px-4 py-6 md:px-6 xl:px-7.5">
    <h4 className="text-xl font-semibold text-black dark:text-white">Top Products</h4>
  </div>

  {/* Table header */}
  <div className="grid grid-cols-6 border-t border-stroke px-4 py-4.5 dark:border-strokedark sm:grid-cols-8 md:px-6 2xl:px-7.5">
    <div className="col-span-3 flex items-center">
      <p className="font-medium">Product Name</p>
    </div>
    <div className="col-span-2 hidden items-center sm:flex">
      <p className="font-medium">Category</p>
    </div>
    <div className="col-span-1 flex items-center">
      <p className="font-medium">Price</p>
    </div>
    <div className="col-span-1 flex items-center">
      <p className="font-medium">Sold</p>
    </div>
    <div className="col-span-1 flex items-center">
      <p className="font-medium">Profit</p>
    </div>
  </div>

  {/* Table rows */}
  {products.map((product, key) => (
    <div
      className="grid grid-cols-6 border-t border-stroke px-4 py-4.5 dark:border-strokedark sm:grid-cols-8 md:px-6 2xl:px-7.5"
      key={key}
    >
      <div className="col-span-3 flex items-center">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
          <div className="h-12.5 w-15 rounded-md">
            <img src={product.image} alt={product.name} />
          </div>
          <p className="text-sm text-black dark:text-white">{product.name}</p>
        </div>
      </div>
      <div className="col-span-2 hidden items-center sm:flex">
        <p className="text-sm text-black dark:text-white">{product.category}</p>
      </div>
      <div className="col-span-1 flex items-center">
        <p className="text-sm text-black dark:text-white">${product.price}</p>
      </div>
      <div className="col-span-1 flex items-center">
        <p className="text-sm text-black dark:text-white">{product.sold}</p>
      </div>
      <div className="col-span-1 flex items-center">
        <p className="text-sm text-meta-3">${product.profit}</p>
      </div>
    </div>
  ))}
</div>
```

### 7.5 Modal Dialog

```tsx
// src/components/Modals/Modal.tsx
import React, { useRef, useEffect } from 'react';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  showCloseButton?: boolean;
}

const Modal: React.FC<ModalProps> = ({ isOpen, onClose, title, children, showCloseButton = true }) => {
  const modalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }
    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = '';
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[99999] flex items-center justify-center overflow-y-auto bg-black/60">
      <div
        ref={modalRef}
        className="relative w-full max-w-lg rounded-2xl bg-white p-6 shadow-2xl dark:bg-gray-800 mx-4"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-xl font-semibold text-gray-800 dark:text-white">{title}</h3>
          {showCloseButton && (
            <button
              onClick={onClose}
              className="flex h-8 w-8 items-center justify-center rounded-full text-gray-500 hover:bg-gray-100 hover:text-gray-700 dark:hover:bg-gray-700 dark:hover:text-gray-300"
            >
              <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          )}
        </div>

        {/* Body */}
        <div className="custom-scrollbar max-h-[70vh] overflow-y-auto">
          {children}
        </div>
      </div>
    </div>
  );
};

export default Modal;
```

### 7.6 Form Elements

```tsx
{/* Text Input */}
<div className="mb-4">
  <label className="mb-2.5 block font-medium text-black dark:text-white">Full Name</label>
  <div className="relative">
    <input
      type="text"
      placeholder="Enter your full name"
      className="w-full rounded-lg border border-stroke bg-transparent py-4 pl-6 pr-10 text-black outline-none focus:border-primary focus-visible:shadow-none dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
    />
    <span className="absolute right-4 top-4">
      <svg className="fill-current" width="22" height="22" /* user icon */ />
    </span>
  </div>
</div>

{/* Select Dropdown */}
<div className="mb-4">
  <label className="mb-2.5 block font-medium text-black dark:text-white">Role</label>
  <select className="w-full rounded-lg border border-stroke bg-transparent py-4 pl-6 pr-10 text-black outline-none focus:border-primary dark:border-form-strokedark dark:bg-form-input dark:text-white">
    <option value="">Select role</option>
    <option value="admin">Admin</option>
    <option value="editor">Editor</option>
    <option value="viewer">Viewer</option>
  </select>
</div>

{/* Toggle Switch */}
<label className="flex cursor-pointer select-none items-center">
  <div className="relative">
    <input type="checkbox" className="sr-only" checked={enabled} onChange={() => setEnabled(!enabled)} />
    <div className={`block h-8 w-14 rounded-full ${enabled ? 'bg-primary' : 'bg-gray-300 dark:bg-gray-600'}`} />
    <div className={`absolute left-1 top-1 h-6 w-6 rounded-full bg-white transition ${enabled ? 'translate-x-full' : ''}`} />
  </div>
  <span className="ml-3 text-sm font-medium text-black dark:text-white">Active Status</span>
</label>
```

---

## 8. Tailwind CSS Customization

### 8.1 tailwind.config.ts

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class', // Enable class-based dark mode
  theme: {
    extend: {
      colors: {
        // Brand Colors
        primary: '#3C50E0',
        secondary: '#80CAEE',
        
        // Sidebar
        'sidebar-bg': '#1C2434',
        'sidebar-menu': '#DEE4EE',
        
        // Body
        body: '#64748B',
        bodydark: '#AEB7C0',
        bodydark1: '#DEE4EE',
        bodydark2: '#8A99AF',
        
        // Stroke (borders)
        stroke: '#E2E8F0',
        strokedark: '#2E3A47',
        
        // Form
        'form-strokedark': '#3d4d60',
        'form-input': '#1d2a39',
        
        // Box
        boxdark: '#24303F',
        'boxdark-2': '#1A222C',
        
        // Meta colors (specific status indicators)
        'meta-1': '#DC3545',
        'meta-2': '#EFF2F7',
        'meta-3': '#10B981',
        'meta-4': '#313D4A',
        'meta-5': '#259AE6',
        'meta-6': '#FFBA00',
        'meta-7': '#FF6766',
        'meta-8': '#F0950C',
        'meta-9': '#E5E7EB',
        'meta-10': '#0FADCF',
      },
      fontSize: {
        'title-md': ['1.125rem', '1.375rem'],
        'title-md2': ['1.625rem', '1.875rem'],
        'title-lg': ['1.75rem', '2.125rem'],
        'title-xl': ['2.25rem', '2.75rem'],
        'title-xl2': ['2.625rem', '3.25rem'],
        'title-xxl': ['2.75rem', '3.375rem'],
      },
      spacing: {
        4.5: '1.125rem',
        5.5: '1.375rem',
        6.5: '1.625rem',
        7.5: '1.875rem',
        8.5: '2.125rem',
        9.5: '2.375rem',
        10.5: '2.625rem',
        11: '2.75rem',
        11.5: '2.875rem',
        12.5: '3.125rem',
        13: '3.25rem',
        14: '3.5rem',
        15: '3.75rem',
        // ... more custom spacing
      },
      maxWidth: {
        2.5: '0.625rem',
        3: '0.75rem',
        // ... 
      },
      zIndex: {
        999: '999',
        9999: '9999',
        99999: '99999',
      },
      opacity: {
        65: '.65',
      },
      boxShadow: {
        default: '0px 8px 13px -3px rgba(0, 0, 0, 0.07)',
        card: '0px 1px 3px rgba(0, 0, 0, 0.12)',
        'card-2': '0px 1px 2px rgba(0, 0, 0, 0.05)',
        switcher: '0px 2px 4px rgba(0, 0, 0, 0.2), inset 0px 2px 2px #FFFFFF, inset 0px -1px 1px rgba(0, 0, 0, 0.1)',
      },
      dropShadow: {
        1: '0px 1px 0px #E2E8F0',
        2: '0px 1px 4px rgba(0, 0, 0, 0.12)',
      },
      keyframes: {
        rotating: {
          '0%, 100%': { transform: 'rotate(360deg)' },
          '50%': { transform: 'rotate(0deg)' },
        },
      },
      animation: {
        'ping-once': 'ping 5s cubic-bezier(0, 0, 0.2, 1)',
        rotating: 'rotating 30s linear infinite',
        'spin-1.5': 'spin 1.5s linear infinite',
        'spin-2': 'spin 2s linear infinite',
        'spin-3': 'spin 3s linear infinite',
      },
    },
  },
  plugins: [],
};

export default config;
```

### 8.2 Custom CSS Classes

```css
/* src/styles/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom scrollbar */
.custom-scrollbar::-webkit-scrollbar {
  width: 5px;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 5px;
  background-color: rgba(100, 116, 139, 0.5);
}

/* No scrollbar (sidebar) */
.no-scrollbar::-webkit-scrollbar {
  display: none;
}
.no-scrollbar {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

/* Chat scrollbar */
.chat-height {
  height: calc(100vh - 300px);
}

/* Shadow defaults */
@layer components {
  .shadow-default {
    @apply shadow-[0px_8px_13px_-3px_rgba(0,_0,_0,_0.07)];
  }
}
```

---

## 9. Page Breadcrumb Pattern

```tsx
// src/components/common/PageBreadcrumb.tsx
import React from 'react';

interface BreadcrumbProps {
  pageTitle: string;
  pagePaths?: { label: string; path?: string }[];
}

const PageBreadcrumb: React.FC<BreadcrumbProps> = ({ pageTitle, pagePaths = [] }) => {
  return (
    <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <h2 className="text-title-md2 font-semibold text-black dark:text-white">
        {pageTitle}
      </h2>
      <nav>
        <ol className="flex items-center gap-2">
          <li>
            <a href="/" className="font-medium text-gray-500 hover:text-primary dark:text-gray-400">
              Dashboard /
            </a>
          </li>
          {pagePaths.map((crumb, idx) => (
            <li key={idx}>
              {crumb.path ? (
                <a href={crumb.path} className="font-medium text-gray-500 hover:text-primary">
                  {crumb.label} /
                </a>
              ) : (
                <span className="font-medium text-primary">{crumb.label}</span>
              )}
            </li>
          ))}
        </ol>
      </nav>
    </div>
  );
};
```

---

## 10. Hooks

### 10.1 useClickOutside

```tsx
// src/hooks/useClickOutside.ts
import { useEffect, useRef } from 'react';

const useClickOutside = <T extends HTMLElement>(callback: () => void) => {
  const ref = useRef<T>(null);

  useEffect(() => {
    const handleClick = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        callback();
      }
    };

    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, [callback]);

  return ref;
};

export default useClickOutside;

// Usage:
const dropdownRef = useClickOutside<HTMLDivElement>(() => setOpen(false));
<div ref={dropdownRef}>{/* dropdown content */}</div>
```

---

## 11. Adding New Pages — Recipe

```
1. Create a page component:
   src/pages/NewFeature/NewFeaturePage.tsx

2. Use consistent layout:
   import PageBreadcrumb from '../../components/common/PageBreadcrumb';
   import ComponentCard from '../../components/common/ComponentCard';

   const NewFeaturePage = () => (
     <>
       <PageBreadcrumb pageTitle="New Feature" />
       <ComponentCard title="Content">
         ...
       </ComponentCard>
     </>
   );

3. Register route in App.tsx:
   <Route path="/new-feature" element={<NewFeaturePage />} />

4. Add menu item in Sidebar:
   { label: 'New Feature', icon: <FeatureIcon />, path: '/new-feature' }

5. Ensure dark mode: use the dark: prefix on ALL elements.
```

---

## 12. Auth Pages Pattern

```tsx
// src/pages/AuthPages/SignIn.tsx
const SignIn: React.FC = () => {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gray-100 px-4 dark:bg-gray-900">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="mb-10 text-center">
          <img src="/images/logo/logo.svg" alt="Logo" className="mx-auto h-10 dark:hidden" />
          <img src="/images/logo/logo-dark.svg" alt="Logo" className="mx-auto hidden h-10 dark:block" />
        </div>

        {/* Card */}
        <div className="rounded-2xl bg-white p-8 shadow-xl dark:bg-gray-800">
          <h2 className="mb-1 text-2xl font-bold text-gray-900 dark:text-white">Sign In</h2>
          <p className="mb-6 text-sm text-gray-500 dark:text-gray-400">
            Enter your credentials to access your dashboard
          </p>

          <form>
            <div className="mb-4">
              <label className="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
              <input
                type="email"
                className="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-3 text-gray-900 outline-none focus:border-primary dark:border-gray-600 dark:text-white"
                placeholder="you@example.com"
              />
            </div>
            <div className="mb-6">
              <label className="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">Password</label>
              <input
                type="password"
                className="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-3 text-gray-900 outline-none focus:border-primary dark:border-gray-600 dark:text-white"
                placeholder="Enter your password"
              />
            </div>
            <button type="submit" className="w-full rounded-lg bg-primary px-5 py-3 font-medium text-white hover:bg-opacity-90 transition">
              Sign In
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};
```

---

## 13. Customization Tips

### Change Brand Colors
```typescript
// tailwind.config.ts → theme.extend.colors
primary: '#your-brand-color',    // Main CTA, active states
secondary: '#your-secondary',    // Secondary actions
```

### Change Sidebar Color
```typescript
// tailwind.config.ts
'sidebar-bg': '#1C2434',        // Background
'sidebar-menu': '#DEE4EE',      // Menu text
```

### Add Custom Font
```css
/* src/styles/index.css */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

/* Then in tailwind.config.ts: */
fontFamily: {
  satoshi: ['Satoshi', 'sans-serif'],
  inter: ['Inter', 'sans-serif'],
},
```

---

## 14. Resources

| Resource | URL |
|----------|-----|
| Live Demo | https://react-demo.tailadmin.com/ |
| GitHub (Free) | https://github.com/TailAdmin/free-react-tailwind-admin-dashboard |
| Documentation | https://tailadmin.com/docs |
| PRO Version | https://tailadmin.com/pricing |
| Next.js Version | https://github.com/TailAdmin/free-nextjs-admin-dashboard |
| Vue.js Version | https://github.com/TailAdmin/free-vue-admin-dashboard |
| Update Logs | https://tailadmin.com/docs/update-logs |

---

*This skill covers TailAdmin v2.x for React.js with Tailwind CSS v4. Check the GitHub repository for the latest updates.*
