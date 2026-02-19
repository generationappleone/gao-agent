---
name: Icon Libraries
description: Skill for using consistent, beautiful icons with Lucide, Heroicons, Phosphor Icons, and React Icons — covering selection, sizing, accessibility, and integration patterns.
---

# Icon Libraries Skill

## Overview
Icons are the **visual language** of your UI. Consistent, well-chosen icons improve usability, guide the eye, and make interfaces feel polished.

## Library Decision Matrix

| Scenario | Recommended | Package | Icons |
|----------|-------------|---------|-------|
| React + shadcn/ui | **Lucide React** | `lucide-react` | 1500+ |
| React + Tailwind | **Heroicons** | `@heroicons/react` | 300+ |
| React (most variety) | **Phosphor Icons** | `@phosphor-icons/react` | 7000+ |
| React (multi-library) | **React Icons** | `react-icons` | 40,000+ |
| Vanilla HTML/CSS | **Lucide** CDN | `lucide` | 1500+ |

**Priority:** Lucide → Phosphor → Heroicons → React Icons

---

## 1. Lucide React (Primary)

```bash
npm install lucide-react
```

```tsx
import { Home, Users, Settings, Search, Bell, X, Plus, Loader2 } from 'lucide-react';

// ✅ Default sizing (20px)
<Home className="h-5 w-5" />
<Users className="h-5 w-5 text-gray-500" />

// ✅ Icon button
<button aria-label="Close dialog">
  <X className="h-5 w-5" />
</button>

// ✅ Icon with text
<button className="inline-flex items-center gap-2">
  <Plus className="h-4 w-4" aria-hidden="true" />
  <span>Add Item</span>
</button>

// ✅ Loading spinner
<Loader2 className="h-5 w-5 animate-spin text-indigo-500" />
```

### Dynamic Icon Rendering
```tsx
import { icons, type LucideIcon } from 'lucide-react';

function DynamicIcon({ name, className = 'h-5 w-5' }: { name: keyof typeof icons; className?: string }) {
  const IconComponent = icons[name] as LucideIcon;
  if (!IconComponent) return null;
  return <IconComponent className={className} />;
}
```

## 2. Heroicons (Tailwind Ecosystem)

```bash
npm install @heroicons/react
```

```tsx
import { HomeIcon } from '@heroicons/react/24/outline';       // Outline (default)
import { HomeIcon as HomeIconSolid } from '@heroicons/react/24/solid';  // Solid (active)
import { HomeIcon as HomeIconMini } from '@heroicons/react/20/solid';   // Mini (compact)

// ✅ Active/inactive state
{isActive ? <HomeIconSolid className="h-5 w-5 text-indigo-600" /> : <HomeIcon className="h-5 w-5 text-gray-400" />}
```

## 3. Phosphor Icons (Most Variety — 6 Weights)

```bash
npm install @phosphor-icons/react
```

```tsx
import { House, Users, Gear } from '@phosphor-icons/react';

<House weight="thin" size={24} />       // Thinnest
<House weight="light" size={24} />
<House weight="regular" size={24} />    // Default
<House weight="bold" size={24} />
<House weight="fill" size={24} />       // Solid
<House weight="duotone" size={24} />    // Two-tone (unique!)
```

## 4. React Icons (Aggregator)

```bash
npm install react-icons
```

```tsx
import { FiHome, FiUsers } from 'react-icons/fi';       // Feather
import { FaGithub, FaTwitter } from 'react-icons/fa';   // Font Awesome
import { SiReact } from 'react-icons/si';               // Simple Icons (brands)
```

> ⚠️ Import from specific sub-packages (`react-icons/fi`) to avoid bundling everything.

---

## 5. Icon Sizing Standards

| Token | Size | Use For |
|-------|------|---------|
| `icon-xs` | 14px / `h-3.5 w-3.5` | Inline indicators, badges |
| `icon-sm` | 16px / `h-4 w-4` | Compact buttons, table actions |
| `icon-md` | 20px / `h-5 w-5` | **Default** — navigation, forms |
| `icon-lg` | 24px / `h-6 w-6` | Section headers |
| `icon-xl` | 32px / `h-8 w-8` | Empty states, feature cards |
| `icon-2xl` | 48px / `h-12 w-12` | Hero sections |

```css
:root {
  --icon-xs:  0.875rem;
  --icon-sm:  1rem;
  --icon-md:  1.25rem;  /* DEFAULT */
  --icon-lg:  1.5rem;
  --icon-xl:  2rem;
  --icon-2xl: 3rem;
}
```

---

## 6. Accessibility (MANDATORY)

| Situation | Rule |
|-----------|------|
| Icon-only button | **MUST** have `aria-label` |
| Icon with visible text | Icon gets `aria-hidden="true"` |
| Status indicators | `role="img"` + `aria-label` |
| Decorative icons | `aria-hidden="true"` |
| Loading spinners | `aria-label="Loading"` + `role="status"` |

```tsx
// ❌ BAD
<button><X className="h-5 w-5" /></button>

// ✅ GOOD
<button aria-label="Close"><X className="h-5 w-5" /></button>

// ✅ Decorative icon hidden from screen reader
<span className="inline-flex items-center gap-2">
  <CheckCircle className="h-5 w-5 text-green-500" aria-hidden="true" />
  Success
</span>
```

---

## 7. Common Patterns

### Navigation with Active State
```tsx
import { Home, Users, Settings, BarChart3, type LucideIcon } from 'lucide-react';

interface NavItem { label: string; href: string; icon: LucideIcon; }

const navItems: NavItem[] = [
  { label: 'Dashboard', href: '/', icon: Home },
  { label: 'Users', href: '/users', icon: Users },
  { label: 'Analytics', href: '/analytics', icon: BarChart3 },
  { label: 'Settings', href: '/settings', icon: Settings },
];

function Sidebar({ currentPath }: { currentPath: string }) {
  return (
    <nav className="space-y-1">
      {navItems.map((item) => {
        const isActive = currentPath === item.href;
        const Icon = item.icon;
        return (
          <a key={item.href} href={item.href}
            className={`flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors
              ${isActive
                ? 'bg-indigo-50 text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-400'
                : 'text-gray-600 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-800'}`}>
            <Icon className={`h-5 w-5 ${isActive ? 'text-indigo-600' : 'text-gray-400'}`} aria-hidden="true" />
            {item.label}
          </a>
        );
      })}
    </nav>
  );
}
```

### Empty State
```tsx
import { Inbox, Plus } from 'lucide-react';

function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="rounded-2xl bg-gray-100 p-5 dark:bg-gray-800">
        <Inbox className="h-10 w-10 text-gray-400" aria-hidden="true" />
      </div>
      <h3 className="mt-4 text-lg font-semibold">No items yet</h3>
      <p className="mt-1.5 max-w-sm text-sm text-gray-500">Get started by creating your first item.</p>
      <button className="mt-6 inline-flex items-center gap-2 rounded-lg bg-indigo-500 px-4 py-2.5 text-sm font-semibold text-white">
        <Plus className="h-4 w-4" aria-hidden="true" />
        Create Item
      </button>
    </div>
  );
}
```

---

## Best Practices

1. **Pick ONE icon library per project** — no mixing styles
2. **Use `h-5 w-5` (20px) as default** — works for most UI
3. **Always `aria-hidden="true"` on decorative icons**
4. **Always `aria-label` on icon-only buttons**
5. **Tree-shake imports** — never import entire library
6. **Color with `text-*` classes** — not inline props
7. **Match icon weight to text weight** — light with light, bold with bold
8. **Animate sparingly** — spinning loaders ✅, bouncing everything ❌

## Rules Integration
- **UI/UX Rule**: Follow visual hierarchy from `rules/ui-ux-design.md`
- **Accessibility**: WCAG 2.1 AA — icon-only elements MUST have text alternative
- **Performance**: Tree-shake, lazy-load icon-heavy pages
- **Consistency**: One library + consistent sizing across all components
