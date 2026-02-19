# Dark & Light Mode — Mandatory Rules

> **Rule Type:** UI/UX Design Standard
> **Applies to:** ALL web applications, admin panels, and frontend projects
> **Skill Reference:** `.agent/skills/dark-light-mode/SKILL.md`

---

## 1. Semantic Design Token Rules (MANDATORY)

### 1.1 — NEVER Use Raw Colors in Components

```
❌ FORBIDDEN:
  background: #ffffff;
  color: #333333;
  border: 1px solid #e0e0e0;
  background: white;
  color: black;
  background-color: rgb(255, 255, 255);

✅ REQUIRED:
  background: var(--color-bg-surface);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border-default);
```

**This rule applies to ALL CSS files, inline styles, and CSS-in-JS.** The only place raw hex/rgb values may appear is in the `:root` and `[data-theme="dark"]` token definitions.

### 1.2 — NEVER Name Tokens by Visual Appearance

```
❌ FORBIDDEN token names:
  --dark-background
  --light-text
  --black-color
  --white-bg
  --gray-border

✅ REQUIRED token names:
  --color-bg-canvas
  --color-text-primary
  --color-border-default
  --color-accent-primary
```

Token names MUST follow the convention: `--color-{category}-{element}-{variant}`

### 1.3 — ALWAYS Define Both Modes

Every color token defined in `:root` (light) MUST also be defined in `[data-theme="dark"]`. No exceptions.

```
❌ FORBIDDEN — Missing dark mode definition:
  :root { --color-bg-canvas: #FAFAFA; }
  /* No [data-theme="dark"] override → broken in dark mode */

✅ REQUIRED — Both modes defined:
  :root { --color-bg-canvas: #FAFAFA; }
  [data-theme="dark"] { --color-bg-canvas: #0A0A0F; }
```

---

## 2. Color Rules

### 2.1 — NEVER Use Pure Black or Pure White

```
❌ FORBIDDEN:
  --color-bg-canvas: #000000;   /* Pure black — causes eye strain */
  --color-bg-surface: #FFFFFF;  /* Pure white as canvas — too harsh */
  background: black;
  color: white;

✅ REQUIRED:
  --color-bg-canvas: #0A0A0F;   /* Dark gray — comfortable for eyes */
  --color-bg-canvas: #FAFAFA;   /* Off-white — softer light mode */
```

- **Dark mode backgrounds:** Use range `#06060A` to `#1E1E28`
- **Light mode backgrounds:** Use range `#F0F0F5` to `#FAFAFA`

### 2.2 — NEVER Simply Invert Colors

Dark mode is NOT light mode with inverted colors. Each color must be intentionally designed.

```
❌ FORBIDDEN approach:
  [data-theme="dark"] { filter: invert(1); }

✅ REQUIRED approach:
  [data-theme="dark"] {
    --color-bg-canvas: #0A0A0F;       /* Deliberately chosen dark gray */
    --color-text-primary: #E8E8ED;     /* Deliberately chosen light text */
    --color-accent-primary: #818CF8;   /* Deliberately desaturated accent */
  }
```

### 2.3 — ALWAYS Desaturate Accent Colors in Dark Mode

Accent/brand colors MUST be lightened (15-20%) and slightly desaturated (10%) for dark mode backgrounds.

```
❌ FORBIDDEN — Same accent in both modes:
  :root { --color-accent-primary: #4F46E5; }
  [data-theme="dark"] { --color-accent-primary: #4F46E5; } /* Same! Too dark on dark bg */

✅ REQUIRED — Adapted accent:
  :root { --color-accent-primary: #4F46E5; }              /* Original brand color */
  [data-theme="dark"] { --color-accent-primary: #818CF8; } /* Lightened + desaturated */
```

### 2.4 — ALWAYS Use Elevation via Lightness in Dark Mode

In dark mode, **higher elevation = lighter surface** (NOT shadows).

```
Layer hierarchy (dark mode):
  sunken:   #06060A  (lowest)
  canvas:   #0A0A0F  (page)
  surface:  #16161D  (card)
  elevated: #1E1E28  (modal/dropdown — LIGHTEST)
```

---

## 3. Accessibility Rules (WCAG 2.1 AA)

### 3.1 — ALWAYS Meet Contrast Ratios

| Element | Minimum Ratio | Check |
|---------|--------------|-------|
| Normal text (< 18px) | ≥ **4.5:1** | Against its background |
| Large text (≥ 18px or ≥ 14px bold) | ≥ **3:1** | Against its background |
| UI elements (icons, borders, inputs) | ≥ **3:1** | Against its background |
| Focus indicators | ≥ **3:1** | Against surrounding colors |

This MUST be verified in **BOTH** light and dark modes.

### 3.2 — ALWAYS Include aria-label on Toggle Button

```
❌ FORBIDDEN:
  <button class="theme-toggle">🌙</button>

✅ REQUIRED:
  <button class="theme-toggle" aria-label="Switch to dark mode" data-theme-toggle>
    <svg class="theme-icon-sun" ...>...</svg>
    <svg class="theme-icon-moon" ...>...</svg>
  </button>
```

### 3.3 — ALWAYS Ensure Focus Ring Visibility

Focus indicators MUST be visible in BOTH modes:

```css
:focus-visible {
  outline: 2px solid var(--color-accent-primary);
  outline-offset: 2px;
}
```

---

## 4. Implementation Rules

### 4.1 — ALWAYS Prevent FOUC (Flash of Unstyled Content)

An inline `<script>` MUST be placed in `<head>` BEFORE any stylesheet:

```html
<head>
  <script>
    (function() {
      var s = localStorage.getItem('theme-preference');
      if (s) document.documentElement.setAttribute('data-theme', s);
      else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)
        document.documentElement.setAttribute('data-theme', 'dark');
      else document.documentElement.setAttribute('data-theme', 'light');
    })();
  </script>
  <link rel="stylesheet" href="styles.css">
</head>
```

### 4.2 — ALWAYS Persist User Preference

User's theme choice MUST be saved to `localStorage` and restored on page load.

```
❌ FORBIDDEN:
  - Theme resets on page refresh
  - Theme doesn't persist across navigation
  - Only system detection, no manual override

✅ REQUIRED:
  - Save to localStorage on toggle
  - Read from localStorage on page load
  - System detection ONLY as fallback when no saved preference
```

### 4.3 — ALWAYS Respect System Preference

When no user preference is saved, the app MUST detect and follow `prefers-color-scheme`:

```javascript
// Auto-detect system preference as fallback
if (!localStorage.getItem('theme-preference')) {
  if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    document.documentElement.setAttribute('data-theme', 'dark');
  }
}
```

### 4.4 — ALWAYS Use `data-theme` Attribute

Theme switching MUST use `data-theme` on `<html>`:

```
❌ FORBIDDEN:
  <body class="dark-mode">
  <html class="dark">
  <div class="theme-dark">

✅ REQUIRED:
  <html data-theme="dark">
  <html data-theme="light">
```

This ensures CSS selectors `[data-theme="dark"]` work consistently with `:root`.

### 4.5 — ALWAYS Add Smooth Transitions

Theme switching MUST have smooth transitions to prevent jarring flash:

```css
*, *::before, *::after {
  transition: background-color 0.3s ease, color 0.2s ease, border-color 0.3s ease, box-shadow 0.3s ease;
}
```

### 4.6 — ALWAYS Update `meta theme-color`

Mobile browser chrome color MUST update when theme changes:

```javascript
document.querySelector('meta[name="theme-color"]')
  ?.setAttribute('content', theme === 'dark' ? '#0A0A0F' : '#FAFAFA');
```

---

## 5. Brand Color Rules

### 5.1 — ALWAYS Adapt Brand Colors to Both Modes

If the user provides a brand color, BOTH light and dark mode variants MUST be generated.

**Generation formula:**

| Token | Light Mode | Dark Mode |
|-------|-----------|-----------|
| `accent-primary` | Brand color as-is | Lighten 15-20%, desaturate 10% |
| `accent-hover` | Darken 10% | Lighten 25% |
| `accent-active` | Darken 20% | Same as light primary |
| `accent-subtle` | Mix with 95% white | Mix with 85% black |
| `accent-text` | Brand color as-is | Lighten 20%, desaturate 10% |

### 5.2 — ALWAYS Verify Brand Color Contrast

After generating brand color variants, verify:
- `accent-primary` on `bg-surface` → ≥ 3:1 in BOTH modes
- `accent-text` on `bg-surface` → ≥ 4.5:1 in BOTH modes
- `text-on-accent` on `accent-primary` → ≥ 4.5:1 in BOTH modes

If contrast fails, adjust the variant (lighter or darker) until it passes.

### 5.3 — NEVER Change Neutral Palette Based on Brand

Brand color only affects the `accent-*` tokens. The neutral palette (`bg-*`, `text-*`, `border-*`) MUST remain the standard values defined in the skill file.

```
❌ FORBIDDEN:
  --color-bg-canvas: #1a0a0a;  /* Tinted with brand red — NO! */

✅ REQUIRED:
  --color-bg-canvas: #0A0A0F;  /* Neutral dark gray — always */
  --color-accent-primary: #FCA5A5; /* Brand red adapted for dark */
```

---

## 6. Media & Image Rules

### 6.1 — ALWAYS Handle Images in Dark Mode

Images (except logos and avatars) MUST have reduced brightness in dark mode:

```css
[data-theme="dark"] img:not([data-no-theme]):not(.logo):not(.avatar) {
  filter: brightness(0.85) contrast(1.05);
}
```

### 6.2 — Provide Alt Logos When Available

If the app has a logo, provide separate light and dark versions:

```html
<img class="logo-light" src="/logo.svg" alt="Logo">
<img class="logo-dark" src="/logo-white.svg" alt="Logo">
```

---

## 7. Testing Rules

### 7.1 — ALWAYS Test Both Modes

Every new component, page, or UI change MUST be visually verified in BOTH light and dark modes before marking complete.

### 7.2 — ALWAYS Test These Scenarios

| # | Scenario | Expected |
|---|----------|----------|
| 1 | Fresh visit (no preference saved) | Follows system preference |
| 2 | Toggle to dark → refresh page | Dark mode persists |
| 3 | Toggle to light → close browser → reopen | Light mode persists |
| 4 | System is dark + no saved pref | Auto dark mode |
| 5 | System changes dark↔light (real-time) | Follows if no saved pref |
| 6 | User sets manual pref → system changes | Manual pref wins |
| 7 | Page load speed | No FOUC / flash |
| 8 | All text readable | Contrast passes WCAG AA |
| 9 | All interactive elements visible | Buttons, inputs, links |
| 10 | Modals/dropdowns correct | Elevated surfaces lighter in dark |

---

## Quick Reference: Decision Tree

```
New component → Uses CSS?
  ├── YES → Uses raw hex/rgb colors?
  │     ├── YES → ❌ VIOLATION! Use design tokens
  │     └── NO  → ✅ OK (uses var(--color-*))
  │
  └── Adds new color?
        ├── YES → Defined in BOTH :root AND [data-theme="dark"]?
        │     ├── YES → ✅ OK
        │     └── NO  → ❌ VIOLATION! Define both modes
        │
        └── NO → ✅ OK (uses existing tokens)
```
