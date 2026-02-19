---
name: Dark & Light Mode
description: Skill for implementing dark and light mode theming — covering CSS design tokens, semantic color system, toggle logic, system preference detection, FOUC prevention, accessibility (WCAG), media handling, and brand color integration.
---

# Dark & Light Mode Skill

## Overview
Dark & light mode is a core feature of modern web applications. This skill provides a complete, production-ready approach using **semantic CSS design tokens**, user preference persistence, system detection, and brand color flexibility.

**Reference**: [Material Design 3 — Color System](https://m3.material.io/styles/color/system/overview)

---

## 1. Architecture: Semantic Design Token System

### 1.1 Token Naming Convention

Tokens use semantic names that describe **purpose**, NOT visual appearance.

```
--color-{category}-{element}-{variant}
```

| Segment | Values | Example |
|---------|--------|---------|
| `category` | `bg`, `text`, `border`, `accent`, `status` | `--color-bg-surface` |
| `element` | `canvas`, `surface`, `elevated`, `primary`, `muted` | `--color-text-primary` |
| `variant` | `hover`, `active`, `subtle`, `strong` | `--color-accent-hover` |

**Rules:**
- ❌ NEVER: `--dark-bg`, `--light-text`, `--black`, `--white`
- ✅ ALWAYS: `--color-bg-canvas`, `--color-text-primary`, `--color-accent-primary`

### 1.2 Token Categories

| Category | Tokens | Purpose |
|----------|--------|---------|
| **Background** | `canvas`, `surface`, `elevated`, `sunken`, `overlay` | Page, card, modal, inset backgrounds |
| **Text** | `primary`, `secondary`, `muted`, `inverse`, `on-accent` | Text hierarchy |
| **Border** | `default`, `strong`, `subtle` | Dividers, card borders, input borders |
| **Accent** | `primary`, `hover`, `active`, `subtle` | Brand CTA, links, active states |
| **Status** | `success`, `warning`, `danger`, `info` | Alerts, badges, validation |
| **Shadow** | `sm`, `md`, `lg`, `xl` | Elevation — shadows for light, lighter surfaces for dark |

---

## 2. Complete CSS Implementation

### 2.1 Default Light Mode + Dark Mode Tokens

```css
/* =================================================================== */
/* DESIGN TOKENS — Semantic Color System                               */
/* =================================================================== */
/* ⚠️ RULE: All UI components MUST use these tokens.                   */
/* ⚠️ RULE: NEVER use raw hex/rgb colors directly in components.       */
/* =================================================================== */

:root {
  /* ─────────────────────────────── */
  /* LIGHT MODE (DEFAULT)            */
  /* ─────────────────────────────── */

  /* Backgrounds — Layer hierarchy: canvas < sunken < surface < elevated */
  --color-bg-canvas:         #FAFAFA;     /* Page background */
  --color-bg-surface:        #FFFFFF;     /* Card, section background */
  --color-bg-elevated:       #FFFFFF;     /* Modal, dropdown, popover */
  --color-bg-sunken:         #F0F0F5;     /* Inset areas, code blocks */
  --color-bg-overlay:        rgba(0, 0, 0, 0.5);  /* Backdrop behind modals */

  /* Text — Hierarchy: primary > secondary > muted */
  --color-text-primary:      #1A1A2E;     /* Main body text */
  --color-text-secondary:    #4A4A68;     /* Supporting text */
  --color-text-muted:        #8888A0;     /* Placeholder, hint text */
  --color-text-inverse:      #FAFAFA;     /* Text on dark surfaces */
  --color-text-on-accent:    #FFFFFF;     /* Text on accent-colored buttons */

  /* Borders */
  --color-border-default:    #E2E2EA;     /* Standard borders */
  --color-border-strong:     #C8C8D4;     /* Emphasized borders */
  --color-border-subtle:     #F0F0F5;     /* Very light dividers */

  /* Accent — Brand Primary Color */
  /* 💡 CUSTOMIZE: Replace with user's brand color */
  --color-accent-primary:    #4F46E5;     /* Primary brand color (CTA, links) */
  --color-accent-hover:      #4338CA;     /* Hover state */
  --color-accent-active:     #3730A3;     /* Active/pressed state */
  --color-accent-subtle:     #EEF2FF;     /* Subtle background tint */
  --color-accent-text:       #4F46E5;     /* Accent used as text color */

  /* Status Colors */
  --color-success:           #10B981;
  --color-success-subtle:    #ECFDF5;
  --color-warning:           #F59E0B;
  --color-warning-subtle:    #FFFBEB;
  --color-danger:            #EF4444;
  --color-danger-subtle:     #FEF2F2;
  --color-info:              #3B82F6;
  --color-info-subtle:       #EFF6FF;

  /* Shadows — Visible in light mode */
  --shadow-sm:     0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md:     0 4px 6px rgba(0, 0, 0, 0.07);
  --shadow-lg:     0 10px 25px rgba(0, 0, 0, 0.1);
  --shadow-xl:     0 20px 50px rgba(0, 0, 0, 0.15);

  /* Border Radius */
  --radius-sm:     6px;
  --radius-md:     10px;
  --radius-lg:     16px;
  --radius-xl:     24px;
  --radius-full:   9999px;

  /* Transitions */
  --transition-theme:  background-color 0.3s ease, color 0.2s ease, border-color 0.3s ease, box-shadow 0.3s ease;
}

/* ─────────────────────────────── */
/* DARK MODE                       */
/* ─────────────────────────────── */

[data-theme="dark"] {
  /* Backgrounds — Elevation = lighter surface (NOT shadows) */
  --color-bg-canvas:         #0A0A0F;
  --color-bg-surface:        #16161D;
  --color-bg-elevated:       #1E1E28;     /* ↑ Lighter = more elevated */
  --color-bg-sunken:         #06060A;
  --color-bg-overlay:        rgba(0, 0, 0, 0.7);

  /* Text */
  --color-text-primary:      #E8E8ED;
  --color-text-secondary:    #A0A0B8;
  --color-text-muted:        #6B6B82;
  --color-text-inverse:      #1A1A2E;
  --color-text-on-accent:    #FFFFFF;

  /* Borders */
  --color-border-default:    #2A2A38;
  --color-border-strong:     #3D3D4F;
  --color-border-subtle:     #1A1A24;

  /* Accent — Desaturated for dark mode (10-20% lighter) */
  /* 💡 CUSTOMIZE: Auto-generate from brand color */
  --color-accent-primary:    #818CF8;     /* Lighter/desaturated version */
  --color-accent-hover:      #A5B4FC;
  --color-accent-active:     #6366F1;
  --color-accent-subtle:     #1E1B4B;     /* Dark tinted background */
  --color-accent-text:       #A5B4FC;

  /* Status Colors — Lightened for dark backgrounds */
  --color-success:           #34D399;
  --color-success-subtle:    #064E3B;
  --color-warning:           #FBBF24;
  --color-warning-subtle:    #78350F;
  --color-danger:            #F87171;
  --color-danger-subtle:     #7F1D1D;
  --color-info:              #60A5FA;
  --color-info-subtle:       #1E3A5F;

  /* Shadows — Stronger in dark mode because less visible */
  --shadow-sm:     0 1px 2px rgba(0, 0, 0, 0.3);
  --shadow-md:     0 4px 6px rgba(0, 0, 0, 0.4);
  --shadow-lg:     0 10px 25px rgba(0, 0, 0, 0.5);
  --shadow-xl:     0 20px 50px rgba(0, 0, 0, 0.6);
}

/* ─────────────────────────────── */
/* SYSTEM PREFERENCE AUTO-DETECT   */
/* ─────────────────────────────── */

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    /* Same as [data-theme="dark"] — copy all dark variables here */
    --color-bg-canvas:       #0A0A0F;
    --color-bg-surface:      #16161D;
    --color-bg-elevated:     #1E1E28;
    --color-bg-sunken:       #06060A;
    --color-bg-overlay:      rgba(0, 0, 0, 0.7);
    --color-text-primary:    #E8E8ED;
    --color-text-secondary:  #A0A0B8;
    --color-text-muted:      #6B6B82;
    --color-text-inverse:    #1A1A2E;
    --color-text-on-accent:  #FFFFFF;
    --color-border-default:  #2A2A38;
    --color-border-strong:   #3D3D4F;
    --color-border-subtle:   #1A1A24;
    --color-accent-primary:  #818CF8;
    --color-accent-hover:    #A5B4FC;
    --color-accent-active:   #6366F1;
    --color-accent-subtle:   #1E1B4B;
    --color-accent-text:     #A5B4FC;
    --color-success:         #34D399;
    --color-success-subtle:  #064E3B;
    --color-warning:         #FBBF24;
    --color-warning-subtle:  #78350F;
    --color-danger:          #F87171;
    --color-danger-subtle:   #7F1D1D;
    --color-info:            #60A5FA;
    --color-info-subtle:     #1E3A5F;
    --shadow-sm:   0 1px 2px rgba(0, 0, 0, 0.3);
    --shadow-md:   0 4px 6px rgba(0, 0, 0, 0.4);
    --shadow-lg:   0 10px 25px rgba(0, 0, 0, 0.5);
    --shadow-xl:   0 20px 50px rgba(0, 0, 0, 0.6);
  }
}
```

### 2.2 Global Smooth Transition

```css
/* Smooth transition when switching themes — prevents jarring flash */
*,
*::before,
*::after {
  transition: var(--transition-theme);
}

/* Except for elements that should NOT transition (e.g., animations) */
.no-theme-transition,
.no-theme-transition *,
.no-theme-transition *::before,
.no-theme-transition *::after {
  transition: none !important;
}
```

### 2.3 Component Usage Example

```css
/* ✅ CORRECT — Using tokens */
.card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-md);
  color: var(--color-text-primary);
}

.card:hover {
  border-color: var(--color-accent-primary);
  box-shadow: var(--shadow-lg);
}

.card__title {
  color: var(--color-text-primary);
  font-weight: 600;
}

.card__description {
  color: var(--color-text-secondary);
}

.card__meta {
  color: var(--color-text-muted);
}

/* ❌ WRONG — Hardcoded colors */
.card-bad {
  background: #ffffff;
  color: #333333;
  border: 1px solid #e0e0e0;
}
```

---

## 3. Theme Toggle (JavaScript)

### 3.1 ThemeManager Class

```javascript
/**
 * ThemeManager — Handles dark/light mode with:
 * 1. User preference persistence (localStorage)
 * 2. System preference detection (prefers-color-scheme)
 * 3. FOUC prevention (inline script in <head>)
 * 4. Real-time system preference change listener
 */
class ThemeManager {
  static STORAGE_KEY = 'theme-preference';
  static THEMES = ['light', 'dark'];

  /**
   * Initialize theme on page load.
   * Priority: Saved preference > System preference > Light (default)
   */
  static init() {
    const saved = localStorage.getItem(this.STORAGE_KEY);

    if (saved && this.THEMES.includes(saved)) {
      this.apply(saved);
    } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      this.apply('dark');
    } else {
      this.apply('light');
    }

    // Listen for system preference changes (real-time)
    window.matchMedia('(prefers-color-scheme: dark)')
      .addEventListener('change', (e) => {
        // Only auto-switch if user hasn't set a manual preference
        if (!localStorage.getItem(this.STORAGE_KEY)) {
          this.apply(e.matches ? 'dark' : 'light');
        }
      });

    // Bind toggle button(s)
    document.querySelectorAll('[data-theme-toggle]').forEach(btn => {
      btn.addEventListener('click', () => this.toggle());
    });
  }

  /**
   * Apply theme to document
   */
  static apply(theme) {
    document.documentElement.setAttribute('data-theme', theme);

    // Update meta theme-color for mobile browsers
    const metaThemeColor = document.querySelector('meta[name="theme-color"]');
    if (metaThemeColor) {
      metaThemeColor.setAttribute('content', theme === 'dark' ? '#0A0A0F' : '#FAFAFA');
    }

    // Update toggle button icon state
    document.querySelectorAll('[data-theme-toggle]').forEach(btn => {
      btn.setAttribute('aria-label', `Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`);
    });
  }

  /**
   * Toggle between light and dark
   */
  static toggle() {
    const current = document.documentElement.getAttribute('data-theme') || 'light';
    const next = current === 'dark' ? 'light' : 'dark';
    this.apply(next);
    localStorage.setItem(this.STORAGE_KEY, next);
  }

  /**
   * Get current theme
   */
  static current() {
    return document.documentElement.getAttribute('data-theme') || 'light';
  }

  /**
   * Remove saved preference (follow system)
   */
  static resetToSystem() {
    localStorage.removeItem(this.STORAGE_KEY);
    const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    this.apply(systemDark ? 'dark' : 'light');
  }
}

document.addEventListener('DOMContentLoaded', () => ThemeManager.init());
```

### 3.2 React Hook

```tsx
import { useState, useEffect, useCallback } from 'react';

type Theme = 'light' | 'dark';
const STORAGE_KEY = 'theme-preference';

export function useTheme() {
  const [theme, setTheme] = useState<Theme>(() => {
    if (typeof window === 'undefined') return 'light';
    const saved = localStorage.getItem(STORAGE_KEY) as Theme | null;
    if (saved) return saved;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  });

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    const meta = document.querySelector('meta[name="theme-color"]');
    meta?.setAttribute('content', theme === 'dark' ? '#0A0A0F' : '#FAFAFA');
  }, [theme]);

  const toggle = useCallback(() => {
    setTheme(prev => {
      const next = prev === 'dark' ? 'light' : 'dark';
      localStorage.setItem(STORAGE_KEY, next);
      return next;
    });
  }, []);

  return { theme, toggle, isDark: theme === 'dark' };
}
```

---

## 4. FOUC Prevention

**CRITICAL:** Place this inline `<script>` in `<head>` BEFORE any stylesheet:

```html
<head>
  <!-- FOUC Prevention — Must be BEFORE CSS -->
  <script>
    (function() {
      var s = localStorage.getItem('theme-preference');
      if (s) {
        document.documentElement.setAttribute('data-theme', s);
      } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.setAttribute('data-theme', 'dark');
      } else {
        document.documentElement.setAttribute('data-theme', 'light');
      }
    })();
  </script>

  <meta name="theme-color" content="#FAFAFA">
  <link rel="stylesheet" href="styles.css">
</head>
```

---

## 5. Toggle Button (HTML + CSS)

```html
<button data-theme-toggle class="theme-toggle" aria-label="Toggle dark mode" title="Toggle theme">
  <svg class="theme-icon-sun" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
  </svg>
  <svg class="theme-icon-moon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
  </svg>
</button>
```

```css
.theme-toggle {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg-elevated);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-md);
  padding: 8px 10px;
  cursor: pointer;
  color: var(--color-text-secondary);
  transition: var(--transition-theme);
}
.theme-toggle:hover {
  background: var(--color-accent-subtle);
  color: var(--color-accent-primary);
  border-color: var(--color-accent-primary);
}
.theme-toggle:focus-visible {
  outline: 2px solid var(--color-accent-primary);
  outline-offset: 2px;
}

/* Icon visibility based on current theme */
[data-theme="light"] .theme-icon-sun  { display: none; }
[data-theme="light"] .theme-icon-moon { display: block; }
[data-theme="dark"]  .theme-icon-sun  { display: block; }
[data-theme="dark"]  .theme-icon-moon { display: none; }
```

---

## 6. Media & Image Handling

```css
/* Reduce brightness of images in dark mode */
[data-theme="dark"] img:not([data-no-theme]):not(.logo):not(.avatar) {
  filter: brightness(0.85) contrast(1.05);
  transition: filter 0.3s ease;
}

/* Swap logos per theme */
.logo-light { display: block; }
.logo-dark  { display: none; }
[data-theme="dark"] .logo-light { display: none; }
[data-theme="dark"] .logo-dark  { display: block; }

/* SVG icons — automatically adapt via currentColor */
.icon {
  color: var(--color-text-secondary);
}
```

---

## 7. Brand Color Integration

When the user specifies a brand color, generate the full palette automatically:

### 7.1 Brand Color Mapping Table

Given a brand primary color (e.g., `#E63946` red), generate:

| Token | Light Mode | Dark Mode | Rule |
|-------|-----------|-----------|------|
| `--color-accent-primary` | Brand color as-is | Lighten 15-20%, desaturate 10% | Readable on dark bg |
| `--color-accent-hover` | Darken 10% | Lighten 25% | Visible hover state |
| `--color-accent-active` | Darken 20% | Same as primary | Pressed state |
| `--color-accent-subtle` | Brand + 95% white mix | Brand + 85% black mix | Tinted background |
| `--color-accent-text` | Brand color as-is | Lighten 20%, desaturate 10% | Readable as text |

### 7.2 Brand Color Examples

```css
/* ── Example: Blue Brand (#2563EB) ── */
:root {
  --color-accent-primary: #2563EB;
  --color-accent-hover:   #1D4ED8;
  --color-accent-active:  #1E40AF;
  --color-accent-subtle:  #EFF6FF;
  --color-accent-text:    #2563EB;
}
[data-theme="dark"] {
  --color-accent-primary: #60A5FA;  /* Lightened */
  --color-accent-hover:   #93C5FD;
  --color-accent-active:  #3B82F6;
  --color-accent-subtle:  #1E3A5F;
  --color-accent-text:    #93C5FD;
}

/* ── Example: Green Brand (#059669) ── */
:root {
  --color-accent-primary: #059669;
  --color-accent-hover:   #047857;
  --color-accent-active:  #065F46;
  --color-accent-subtle:  #ECFDF5;
  --color-accent-text:    #059669;
}
[data-theme="dark"] {
  --color-accent-primary: #34D399;
  --color-accent-hover:   #6EE7B7;
  --color-accent-active:  #10B981;
  --color-accent-subtle:  #064E3B;
  --color-accent-text:    #6EE7B7;
}

/* ── Example: Red Brand (#E63946) ── */
:root {
  --color-accent-primary: #E63946;
  --color-accent-hover:   #DC2626;
  --color-accent-active:  #B91C1C;
  --color-accent-subtle:  #FEF2F2;
  --color-accent-text:    #DC2626;
}
[data-theme="dark"] {
  --color-accent-primary: #FCA5A5;
  --color-accent-hover:   #FECACA;
  --color-accent-active:  #F87171;
  --color-accent-subtle:  #7F1D1D;
  --color-accent-text:    #FECACA;
}

/* ── Example: Purple Brand (#7C3AED) ── */
:root {
  --color-accent-primary: #7C3AED;
  --color-accent-hover:   #6D28D9;
  --color-accent-active:  #5B21B6;
  --color-accent-subtle:  #F5F3FF;
  --color-accent-text:    #7C3AED;
}
[data-theme="dark"] {
  --color-accent-primary: #A78BFA;
  --color-accent-hover:   #C4B5FD;
  --color-accent-active:  #8B5CF6;
  --color-accent-subtle:  #2E1065;
  --color-accent-text:    #C4B5FD;
}

/* ── Example: Orange Brand (#EA580C) ── */
:root {
  --color-accent-primary: #EA580C;
  --color-accent-hover:   #C2410C;
  --color-accent-active:  #9A3412;
  --color-accent-subtle:  #FFF7ED;
  --color-accent-text:    #EA580C;
}
[data-theme="dark"] {
  --color-accent-primary: #FB923C;
  --color-accent-hover:   #FDBA74;
  --color-accent-active:  #F97316;
  --color-accent-subtle:  #7C2D12;
  --color-accent-text:    #FDBA74;
}
```

---

## 8. Framework-Specific Integration

### 8.1 Next.js / React

```tsx
// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: `
          (function() {
            var s = localStorage.getItem('theme-preference');
            if (s) document.documentElement.setAttribute('data-theme', s);
            else if (window.matchMedia('(prefers-color-scheme: dark)').matches)
              document.documentElement.setAttribute('data-theme', 'dark');
            else document.documentElement.setAttribute('data-theme', 'light');
          })();
        ` }} />
      </head>
      <body>{children}</body>
    </html>
  );
}
```

### 8.2 Laravel Blade

```blade
{{-- resources/views/layouts/app.blade.php --}}
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <script>
      (function() {
        var s = localStorage.getItem('theme-preference');
        if (s) document.documentElement.setAttribute('data-theme', s);
        else if (window.matchMedia('(prefers-color-scheme: dark)').matches)
          document.documentElement.setAttribute('data-theme', 'dark');
        else document.documentElement.setAttribute('data-theme', 'light');
      })();
    </script>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    @yield('content')
</body>
</html>
```

### 8.3 Vue.js

```typescript
// composables/useTheme.ts
import { ref, onMounted, watchEffect } from 'vue';

type Theme = 'light' | 'dark';
const STORAGE_KEY = 'theme-preference';
const theme = ref<Theme>('light');

export function useTheme() {
  onMounted(() => {
    const saved = localStorage.getItem(STORAGE_KEY) as Theme | null;
    if (saved) theme.value = saved;
    else if (window.matchMedia('(prefers-color-scheme: dark)').matches) theme.value = 'dark';
  });

  watchEffect(() => {
    document.documentElement.setAttribute('data-theme', theme.value);
  });

  const toggle = () => {
    theme.value = theme.value === 'dark' ? 'light' : 'dark';
    localStorage.setItem(STORAGE_KEY, theme.value);
  };

  return { theme, toggle, isDark: computed(() => theme.value === 'dark') };
}
```

---

## 9. Accessibility Checklist

| # | Check | Standard | How to Verify |
|---|-------|----------|--------------|
| 1 | Text contrast (normal) | ≥ 4.5:1 (WCAG AA) | Chrome DevTools → Inspect color |
| 2 | Text contrast (large) | ≥ 3:1 (WCAG AA) | ≥18px or ≥14px bold |
| 3 | UI element contrast | ≥ 3:1 | Borders, icons, focus rings |
| 4 | Toggle has `aria-label` | ARIA | Screen reader announces purpose |
| 5 | Focus ring visible | Both modes | `outline` on `:focus-visible` |
| 6 | No pure black background | UX | Use `#0A0A0F`-`#1A1A2E` range |
| 7 | No pure white background | UX | Use `#FAFAFA`-`#F8F9FA` range |
| 8 | Smooth transition | UX | No jarring flash on toggle |
| 9 | System preference respected | UX | `prefers-color-scheme` media query |
| 10 | Preference persists | UX | `localStorage` + FOUC prevention |

---

## 10. Best Practices Summary

| # | Practice | Detail |
|---|----------|--------|
| 1 | **Semantic tokens** | Name by purpose, not appearance |
| 2 | **No raw colors** | All components use CSS variables only |
| 3 | **Light = default** | `:root` is always light mode |
| 4 | **`data-theme` attribute** | Toggle via `document.documentElement.setAttribute` |
| 5 | **FOUC prevention** | Inline `<script>` in `<head>` before CSS |
| 6 | **System detection** | `prefers-color-scheme` media query as fallback |
| 7 | **localStorage** | Persist user choice across sessions |
| 8 | **Desaturate in dark** | Accent colors 10-20% lighter/desaturated |
| 9 | **Elevation via lightness** | Darker bg = lower; lighter bg = elevated |
| 10 | **Shadows stronger in dark** | Increase opacity for dark mode shadows |
| 11 | **Test both modes** | Every component must look correct in both |
| 12 | **`meta theme-color`** | Update for mobile browser chrome color |
| 13 | **Brand color adaptive** | Generate light/dark variants from brand color |
