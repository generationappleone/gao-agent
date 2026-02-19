---
name: Tailwind CSS
description: Skill for building modern UIs with Tailwind CSS, covering configuration, utility patterns, responsive design, custom components, dark mode, and performance optimization.
---

# Tailwind CSS Skill

## Overview
Tailwind CSS is a utility-first CSS framework. Use this skill for building custom designs rapidly with utility classes. **Always confirm which version (v3 or v4) the project uses before coding.**

## Installation

### Vite Project
```bash
npm install -D tailwindcss @tailwindcss/vite
```

```javascript
// vite.config.js
import tailwindcss from '@tailwindcss/vite';
export default defineConfig({
  plugins: [tailwindcss()],
});
```

```css
/* main.css */
@import "tailwindcss";
```

### Tailwind v3 (Legacy)
```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

## Configuration (tailwind.config.js — v3)
```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx,vue}'],
  darkMode: 'class', // or 'media'
  theme: {
    extend: {
      colors: {
        primary: {
          50:  '#eef2ff', 100: '#e0e7ff', 200: '#c7d2fe', 300: '#a5b4fc',
          400: '#818cf8', 500: '#6366f1', 600: '#4f46e5', 700: '#4338ca',
          800: '#3730a3', 900: '#312e81', 950: '#1e1b4b',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      },
      borderRadius: { '4xl': '2rem' },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: { '0%': { opacity: '0' }, '100%': { opacity: '1' } },
        slideUp: { '0%': { opacity: '0', transform: 'translateY(16px)' }, '100%': { opacity: '1', transform: 'translateY(0)' } },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
};
```

## Common Patterns

### Premium Card
```html
<div class="group relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-6
            shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-xl
            dark:border-gray-800 dark:bg-gray-900">
  <!-- Gradient accent top border -->
  <div class="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500"></div>
  
  <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Card Title</h3>
  <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">Description text that explains...</p>
  
  <button class="mt-4 inline-flex items-center gap-2 rounded-full bg-indigo-500 px-5 py-2.5
                 text-sm font-semibold text-white shadow-md shadow-indigo-500/30
                 transition-all hover:bg-indigo-600 hover:shadow-lg hover:shadow-indigo-500/40
                 active:scale-[0.98] focus-visible:outline-2 focus-visible:outline-offset-2
                 focus-visible:outline-indigo-500">
    Get Started
    <svg class="h-4 w-4 transition-transform group-hover:translate-x-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
    </svg>
  </button>
</div>
```

### Glassmorphism
```html
<div class="rounded-2xl border border-white/20 bg-white/60 p-6 shadow-xl
            backdrop-blur-xl dark:border-white/10 dark:bg-gray-900/60">
  <!-- Glass content -->
</div>
```

### Responsive Dashboard Layout
```html
<div class="flex min-h-screen bg-gray-50 dark:bg-gray-950">
  <!-- Sidebar: hidden on mobile, visible on lg+ -->
  <aside class="hidden w-64 shrink-0 border-r border-gray-200 bg-white p-4 dark:border-gray-800 dark:bg-gray-900 lg:block">
    <nav class="space-y-1">
      <a href="#" class="flex items-center gap-3 rounded-lg bg-indigo-50 px-3 py-2 text-sm font-medium text-indigo-700
                         dark:bg-indigo-500/10 dark:text-indigo-400">
        Dashboard
      </a>
      <a href="#" class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-gray-600
                         hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-800">
        Users
      </a>
    </nav>
  </aside>

  <!-- Main content -->
  <main class="flex-1 p-4 lg:p-8">
    <div class="grid gap-6 sm:grid-cols-2 xl:grid-cols-4">
      <!-- Stat cards -->
    </div>
  </main>
</div>
```

### Form Input
```html
<div>
  <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
  <input type="email" id="email" name="email"
         class="mt-1.5 block w-full rounded-lg border border-gray-300 bg-white px-4 py-2.5
                text-sm text-gray-900 shadow-sm transition-colors
                placeholder:text-gray-400
                hover:border-gray-400
                focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/20
                dark:border-gray-700 dark:bg-gray-900 dark:text-white dark:focus:border-indigo-400"
         placeholder="you@example.com" />
</div>
```

## Dark Mode
```html
<!-- Toggle dark mode -->
<html class="dark">

<!-- Component with dark variants -->
<div class="bg-white text-gray-900 dark:bg-gray-900 dark:text-white">
  <p class="text-gray-500 dark:text-gray-400">Adapts to theme</p>
</div>
```

```javascript
// Dark mode toggle
function toggleDarkMode() {
  document.documentElement.classList.toggle('dark');
  localStorage.setItem('theme',
    document.documentElement.classList.contains('dark') ? 'dark' : 'light'
  );
}

// Init on load
if (localStorage.theme === 'dark' || (!localStorage.theme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
  document.documentElement.classList.add('dark');
}
```

## @apply for Reusable Component Classes
```css
/* Use @apply sparingly — only for highly repeated patterns */
@layer components {
  .btn-primary {
    @apply inline-flex items-center justify-center gap-2 rounded-lg bg-indigo-500 px-5 py-2.5
           text-sm font-semibold text-white shadow-sm transition-all
           hover:bg-indigo-600 hover:shadow-md
           active:scale-[0.98]
           focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500;
  }
}
```

## Performance
- Tailwind auto-purges unused classes in production builds
- Use `@layer` for custom utilities ordering
- Avoid arbitrary values `[123px]` — prefer design tokens in config

## Rules Integration
- **UI/UX**: Always include dark mode variants, use premium shadows, add hover/active/focus states
- **Accessibility**: Include `focus-visible:` outlines, `sr-only` for screen reader text, ARIA labels
- **Dependencies**: Check Tailwind version (v3 vs v4 have different config systems)
