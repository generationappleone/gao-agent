---
name: Tailwind CSS
description: Skill for building modern UIs with Tailwind CSS, covering configuration, utility patterns, responsive design, custom components, dark mode, and performance optimization.
---

# Tailwind CSS Skill

## Overview
Tailwind CSS is a utility-first CSS framework for building custom designs rapidly. It provides utility classes for layout, spacing, typography, colors, shadows, transitions, and responsive design. Tailwind v3+ includes JIT compilation, dark mode, and arbitrary values.

**References**:
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Tailwind CSS v4](https://tailwindcss.com/blog/tailwindcss-v4)

---

## Configuration

```javascript
// tailwind.config.js
export default {
  content: ['./src/**/*.{js,ts,jsx,tsx,html}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: { 50: '#eef2ff', 100: '#e0e7ff', 500: '#6366f1', 600: '#4f46e5', 700: '#4338ca', 900: '#312e81' },
      },
      fontFamily: { sans: ['Inter', 'sans-serif'] },
      borderRadius: { xl: '1rem', '2xl': '1.5rem' },
      boxShadow: { soft: '0 2px 15px rgba(0,0,0,0.08)' },
    },
  },
  plugins: [require('@tailwindcss/forms'), require('@tailwindcss/typography')],
};
```

---

## Common Patterns

```html
<!-- Dashboard Stats Card -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
  <div class="bg-white dark:bg-gray-800 rounded-2xl border border-gray-100 dark:border-gray-700 p-6 shadow-soft">
    <div class="flex justify-between items-start">
      <div>
        <p class="text-sm text-gray-500 dark:text-gray-400">Revenue</p>
        <p class="text-2xl font-bold mt-1">$45,231</p>
      </div>
      <div class="bg-brand-50 dark:bg-brand-900/30 p-2 rounded-xl">
        <svg class="w-5 h-5 text-brand-500">...</svg>
      </div>
    </div>
    <p class="text-xs text-green-600 mt-3">↑ 20.1% vs last month</p>
  </div>
</div>

<!-- Button variants -->
<button class="px-6 py-2.5 bg-brand-500 hover:bg-brand-600 text-white font-semibold rounded-xl transition-colors">
  Primary
</button>
<button class="px-6 py-2.5 border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-xl transition-colors">
  Secondary
</button>

<!-- Table -->
<div class="overflow-x-auto rounded-2xl border border-gray-100 dark:border-gray-700">
  <table class="w-full text-left">
    <thead class="bg-gray-50 dark:bg-gray-800">
      <tr>
        <th class="px-6 py-3 text-xs font-medium text-gray-500 uppercase">Product</th>
        <th class="px-6 py-3 text-xs font-medium text-gray-500 uppercase">Status</th>
      </tr>
    </thead>
    <tbody class="divide-y divide-gray-100 dark:divide-gray-700">
      <tr class="hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors">
        <td class="px-6 py-4 font-semibold">Product Name</td>
        <td class="px-6 py-4"><span class="px-2 py-1 text-xs font-medium bg-green-100 text-green-700 rounded-full">Active</span></td>
      </tr>
    </tbody>
  </table>
</div>

<!-- Form -->
<div class="space-y-4">
  <div>
    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
    <input class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 dark:bg-gray-800 rounded-xl focus:ring-2 focus:ring-brand-500 focus:border-transparent outline-none" />
  </div>
</div>
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Utility-first** | Compose designs with utility classes |
| **Responsive** | Mobile-first: sm:, md:, lg:, xl: |
| **Dark mode** | Use dark: variant with class strategy |
| **Custom colors** | Extend theme with brand colors |
| **@apply** | Extract repeated patterns (use sparingly) |
| **Arbitrary values** | `w-[calc(100%-2rem)]` when needed |
| **Plugins** | @tailwindcss/forms, @tailwindcss/typography |
| **Component classes** | Extract with @apply for complex components |
| **Transitions** | transition-colors, transition-all |
| **Purge** | Content config ensures unused CSS is removed |

---

## Rules Integration
- **Config**: Extended theme with brand colors, fonts, shadows
- **Responsive**: Grid with responsive breakpoints
- **Dark mode**: class-based dark variant
- **Components**: Cards, tables, forms, buttons with utilities
