# 🎨 UI/UX Design — Eye-Catching & User-Centric Design Rule

> **Severity:** STRICT  
> **Scope:** All user interfaces — web, mobile, desktop applications  
> **Objective:** Create visually stunning, psychologically engaging, and highly usable interfaces by combining visual psychology, consistency, and user-centric design principles

---

## Overview

The agent **MUST** produce interfaces that are **visually premium** and **functionally intuitive**. A plain, generic-looking UI is **UNACCEPTABLE**. Every interface must feel modern, polished, and alive — using proven design psychology to guide the user's eye and micro-interactions to create delight.

---

## 1. 🧠 Visual Psychology — Capture Attention & Guide the Eye

### 1.1 Visual Hierarchy (F-Pattern & Z-Pattern)

Users scan pages in predictable patterns. The agent **MUST** structure layouts to align with these patterns.

#### ✅ MUST do:
- Place the **most important content** in the top-left area (primary focal point)
- Use the **F-pattern** for text-heavy pages (articles, dashboards, settings)
- Use the **Z-pattern** for landing pages and marketing pages
- Create a clear **visual hierarchy** using size, weight, color, and spacing

#### 💡 Implementation:

```css
/* ✅ REQUIRED: Visual Hierarchy — size + weight + color establish importance */

/* Level 1: Page title — largest, boldest, draws the eye first */
.heading-display {
  font-size: clamp(2.5rem, 5vw, 4rem);
  font-weight: 800;
  letter-spacing: -0.03em;
  line-height: 1.1;
  background: linear-gradient(135deg, #6366f1, #8b5cf6, #a855f7);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* Level 2: Section heading — clearly subordinate to display */
.heading-section {
  font-size: clamp(1.5rem, 3vw, 2rem);
  font-weight: 700;
  letter-spacing: -0.02em;
  line-height: 1.25;
  color: var(--color-text-primary);
}

/* Level 3: Card/component heading */
.heading-card {
  font-size: 1.125rem;
  font-weight: 600;
  line-height: 1.4;
  color: var(--color-text-primary);
}

/* Body text — comfortable reading */
.body-text {
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.6;
  color: var(--color-text-secondary);
  max-width: 65ch; /* Optimal reading width */
}

/* Supporting text — smallest, lowest hierarchy */
.caption-text {
  font-size: 0.8125rem;
  font-weight: 400;
  line-height: 1.5;
  color: var(--color-text-tertiary);
}
```

### 1.2 Color Psychology — Evoke the Right Emotions

Colors trigger psychological responses. The agent **MUST** choose colors intentionally.

| Color | Psychology | Use For |
|-------|-----------|---------|
| **Blue** | Trust, stability, professionalism | Finance, healthcare, corporate apps |
| **Purple** | Creativity, luxury, innovation | Premium products, creative tools, AI |
| **Green** | Growth, success, nature | Eco, health, success states, money |
| **Orange/Amber** | Energy, warmth, urgency | CTAs, warnings, notifications |
| **Red** | Urgency, danger, passion | Errors, delete actions, sales |
| **Pink** | Playfulness, compassion, youth | Social, lifestyle, wellness |
| **Teal/Cyan** | Clarity, freshness, modernity | Tech, SaaS, dashboards |
| **Dark/Charcoal** | Sophistication, elegance, power | Premium/luxury, dark mode base |

#### ✅ MUST do:
- Use a **curated color palette** — never use raw CSS color names (`red`, `blue`, `green`)
- Design with **HSL** for systematic color generation (adjust lightness/saturation for variants)
- Ensure **60-30-10 rule**: 60% dominant (background), 30% secondary (cards/sections), 10% accent (CTAs)
- Create **4-5 shades** per color for flexibility (50, 100, 200, ..., 900)

#### 💡 Implementation: Design Token System

```css
/* ✅ REQUIRED: Systematic color system using CSS custom properties */

:root {
  /* --- Brand Colors (HSL for easy variant generation) --- */
  --hue-primary: 245;
  --hue-accent: 280;
  --hue-success: 152;
  --hue-warning: 38;
  --hue-danger: 0;
  
  /* Primary palette — 60% usage, trust & professionalism */
  --color-primary-50:  hsl(var(--hue-primary), 100%, 97%);
  --color-primary-100: hsl(var(--hue-primary), 96%, 93%);
  --color-primary-200: hsl(var(--hue-primary), 94%, 86%);
  --color-primary-300: hsl(var(--hue-primary), 92%, 76%);
  --color-primary-400: hsl(var(--hue-primary), 88%, 65%);
  --color-primary-500: hsl(var(--hue-primary), 84%, 55%);  /* Base */
  --color-primary-600: hsl(var(--hue-primary), 80%, 45%);
  --color-primary-700: hsl(var(--hue-primary), 76%, 36%);
  --color-primary-800: hsl(var(--hue-primary), 72%, 28%);
  --color-primary-900: hsl(var(--hue-primary), 68%, 20%);

  /* Accent palette — 10% usage, calls-to-action & highlights */
  --color-accent-400: hsl(var(--hue-accent), 85%, 65%);
  --color-accent-500: hsl(var(--hue-accent), 80%, 55%);
  --color-accent-600: hsl(var(--hue-accent), 75%, 45%);

  /* Semantic colors */
  --color-success-500: hsl(var(--hue-success), 70%, 45%);
  --color-warning-500: hsl(var(--hue-warning), 95%, 55%);
  --color-danger-500:  hsl(var(--hue-danger), 85%, 55%);

  /* --- Neutral palette (cool gray for modern feel) --- */
  --color-gray-50:  hsl(220, 20%, 98%);
  --color-gray-100: hsl(220, 18%, 96%);
  --color-gray-200: hsl(220, 16%, 90%);
  --color-gray-300: hsl(220, 14%, 80%);
  --color-gray-400: hsl(220, 12%, 65%);
  --color-gray-500: hsl(220, 10%, 50%);
  --color-gray-600: hsl(220, 12%, 40%);
  --color-gray-700: hsl(220, 14%, 30%);
  --color-gray-800: hsl(220, 18%, 18%);
  --color-gray-900: hsl(220, 22%, 10%);
  --color-gray-950: hsl(220, 25%, 6%);

  /* --- Semantic text colors --- */
  --color-text-primary:   var(--color-gray-900);
  --color-text-secondary: var(--color-gray-600);
  --color-text-tertiary:  var(--color-gray-400);
  --color-text-inverse:   var(--color-gray-50);

  /* --- Surface colors --- */
  --color-surface-base:     #ffffff;
  --color-surface-raised:   var(--color-gray-50);
  --color-surface-overlay:  rgba(0, 0, 0, 0.5);
  --color-surface-sunken:   var(--color-gray-100);

  /* --- Border colors --- */
  --color-border-default:  var(--color-gray-200);
  --color-border-hover:    var(--color-gray-300);
  --color-border-focus:    var(--color-primary-500);
}

/* ✅ REQUIRED: Dark mode — MUST be provided */
@media (prefers-color-scheme: dark) {
  :root {
    --color-text-primary:   var(--color-gray-50);
    --color-text-secondary: var(--color-gray-400);
    --color-text-tertiary:  var(--color-gray-500);

    --color-surface-base:    var(--color-gray-950);
    --color-surface-raised:  var(--color-gray-900);
    --color-surface-sunken:  hsl(220, 25%, 4%);

    --color-border-default:  var(--color-gray-800);
    --color-border-hover:    var(--color-gray-700);
  }
}

/* Manual dark mode toggle support */
[data-theme="dark"] {
  --color-text-primary:   var(--color-gray-50);
  --color-text-secondary: var(--color-gray-400);
  --color-surface-base:   var(--color-gray-950);
  --color-surface-raised: var(--color-gray-900);
  --color-border-default: var(--color-gray-800);
}
```

### 1.3 Gestalt Principles — How the Brain Groups Visual Elements

#### ✅ MUST apply:

| Principle | Rule | Implementation |
|-----------|------|----------------|
| **Proximity** | Related elements must be **closer together** | Use consistent spacing tokens (8px grid) |
| **Similarity** | Similar elements must **look alike** | Same style for same function (all CTAs look identical) |
| **Continuity** | Elements aligned on a path are **perceived as related** | Use grid alignment, consistent margins |
| **Closure** | Brain completes incomplete shapes | Cards with partial borders, icon containers |
| **Figure-Ground** | Clear distinction between foreground and background | Elevation shadows, contrast, overlays |
| **Common Region** | Elements in a bounded area are **grouped** | Cards, sections, containers with borders |

#### 💡 Implementation: Spacing System (8px Grid)

```css
/* ✅ REQUIRED: Consistent spacing system — based on 8px grid */

:root {
  --space-0:   0;
  --space-1:   0.25rem;  /* 4px  */
  --space-2:   0.5rem;   /* 8px  */
  --space-3:   0.75rem;  /* 12px */
  --space-4:   1rem;     /* 16px */
  --space-5:   1.25rem;  /* 20px */
  --space-6:   1.5rem;   /* 24px */
  --space-8:   2rem;     /* 32px */
  --space-10:  2.5rem;   /* 40px */
  --space-12:  3rem;     /* 48px */
  --space-16:  4rem;     /* 64px */
  --space-20:  5rem;     /* 80px */
  --space-24:  6rem;     /* 96px */

  /* Radius tokens */
  --radius-sm:   0.375rem;   /* 6px — subtle rounding */
  --radius-md:   0.5rem;     /* 8px — default for inputs, cards */
  --radius-lg:   0.75rem;    /* 12px — prominent cards */
  --radius-xl:   1rem;       /* 16px — modals, large cards */
  --radius-2xl:  1.5rem;     /* 24px — floating elements */
  --radius-full: 9999px;     /* Pill shape */

  /* Elevation (layered shadows for depth) */
  --shadow-xs:  0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-sm:  0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1);
  --shadow-md:  0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
  --shadow-lg:  0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  --shadow-xl:  0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
  --shadow-glow: 0 0 20px rgba(99, 102, 241, 0.3);
}

/* Gestalt — Proximity: Related items closer, unrelated items further */
.card {
  padding: var(--space-6);
  border-radius: var(--radius-lg);
  background: var(--color-surface-raised);
  border: 1px solid var(--color-border-default);
  box-shadow: var(--shadow-sm);
}

.card__header {
  margin-bottom: var(--space-4);  /* Closer to card content */
}

.card__body {
  margin-bottom: var(--space-6);  /* Further from footer (different group) */
}

.card__footer {
  padding-top: var(--space-4);
  border-top: 1px solid var(--color-border-default);
}
```

### 1.4 Fitts's Law — Make Targets Easy to Hit

> *The time to reach a target depends on its distance and size.*

#### ✅ MUST do:
- **Primary CTAs** must be large (minimum 44×44px touch target, 48×48px recommended)
- Important actions must be **close to the user's current focus**
- **Destructive actions** (delete, cancel) must be **smaller and further** from primary actions
- Navigation items must have **generous click/tap areas**

```css
/* ✅ REQUIRED: Accessible, easy-to-hit button sizes */

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  font-family: inherit;
}

/* Size variants — all meet minimum touch target (44px) */
.btn-sm {
  height: 2.25rem;   /* 36px — desktop only, use md for mobile */
  padding: 0 var(--space-3);
  font-size: 0.8125rem;
  border-radius: var(--radius-sm);
}

.btn-md {
  height: 2.75rem;    /* 44px — minimum touch target ✅ */
  padding: 0 var(--space-5);
  font-size: 0.875rem;
  border-radius: var(--radius-md);
}

.btn-lg {
  height: 3rem;       /* 48px — comfortable touch target ✅ */
  padding: 0 var(--space-8);
  font-size: 1rem;
  border-radius: var(--radius-md);
}

.btn-xl {
  height: 3.5rem;     /* 56px — prominent CTA ✅ */
  padding: 0 var(--space-10);
  font-size: 1.125rem;
  border-radius: var(--radius-lg);
}
```

---

## 2. ✨ Micro-Interactions & Animation — Make the UI Feel Alive

### 2.1 Animation Principles

#### ✅ MUST do:
- Use **purposeful animations** — every animation must have a reason (feedback, orientation, delight)
- Apply **easing functions** — never use `linear` for UI animations (use `ease-out` or cubic-bezier)
- Keep animations **fast** — 150-300ms for most interactions, 300-500ms for page transitions
- Respect **reduced-motion preferences** (`prefers-reduced-motion`)

#### ❌ MUST NOT do:
- Add animations that **block user interaction** (no 2-second loading spinners before showing content)
- Use **jarring, fast-blinking, or overly bouncy** animations
- Animate **purely for decoration** without improving the UX

### 2.2 Transition & Animation Tokens

```css
/* ✅ REQUIRED: Centralized animation tokens */

:root {
  /* Duration tokens */
  --duration-instant:  75ms;    /* Immediate feedback (ripple, checkbox) */
  --duration-fast:     150ms;   /* Hover states, color changes */
  --duration-normal:   250ms;   /* Most transitions (expand, slide) */
  --duration-slow:     350ms;   /* Complex animations (modal enter) */
  --duration-slower:   500ms;   /* Page transitions */

  /* Easing tokens */
  --ease-default:  cubic-bezier(0.4, 0, 0.2, 1);     /* Standard (Material) */
  --ease-in:       cubic-bezier(0.4, 0, 1, 1);        /* Accelerate (exit) */
  --ease-out:      cubic-bezier(0, 0, 0.2, 1);        /* Decelerate (enter) */
  --ease-in-out:   cubic-bezier(0.4, 0, 0.2, 1);      /* Standard */
  --ease-bounce:   cubic-bezier(0.34, 1.56, 0.64, 1); /* Playful overshoot */
  --ease-spring:   cubic-bezier(0.43, 0.195, 0.02, 1);/* Natural spring */
}

/* ✅ REQUIRED: Respect reduced motion preferences */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

### 2.3 Essential Micro-Interactions

```css
/* ✅ REQUIRED: Button interactions — feel responsive and premium */

.btn-primary {
  background: linear-gradient(135deg, var(--color-primary-500), var(--color-primary-600));
  color: white;
  box-shadow: var(--shadow-sm), 0 1px 2px rgba(99, 102, 241, 0.3);
  transition: all var(--duration-fast) var(--ease-default);
}

.btn-primary:hover {
  background: linear-gradient(135deg, var(--color-primary-400), var(--color-primary-500));
  box-shadow: var(--shadow-md), 0 4px 12px rgba(99, 102, 241, 0.4);
  transform: translateY(-1px);  /* Subtle lift */
}

.btn-primary:active {
  transform: translateY(0) scale(0.98);  /* Press down */
  box-shadow: var(--shadow-xs);
}

.btn-primary:focus-visible {
  outline: 2px solid var(--color-primary-500);
  outline-offset: 2px;
}

/* ✅ REQUIRED: Card hover — subtle lift with shadow expansion */
.card-interactive {
  transition: all var(--duration-normal) var(--ease-default);
}

.card-interactive:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
  border-color: var(--color-primary-200);
}

/* ✅ REQUIRED: Input focus — smooth border + glow */
.input {
  height: 2.75rem;
  padding: 0 var(--space-4);
  border: 1.5px solid var(--color-border-default);
  border-radius: var(--radius-md);
  background: var(--color-surface-base);
  color: var(--color-text-primary);
  font-size: 0.9375rem;
  transition: all var(--duration-fast) var(--ease-default);
}

.input:hover {
  border-color: var(--color-border-hover);
}

.input:focus {
  outline: none;
  border-color: var(--color-primary-500);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

/* ✅ REQUIRED: Skeleton loading — shimmer effect */
.skeleton {
  background: linear-gradient(
    90deg,
    var(--color-gray-200) 25%,
    var(--color-gray-100) 50%,
    var(--color-gray-200) 75%
  );
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s ease-in-out infinite;
  border-radius: var(--radius-md);
}

@keyframes skeleton-shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* ✅ REQUIRED: Page element entrance — stagger animation */
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(16px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-in {
  animation: fade-in-up var(--duration-normal) var(--ease-out) both;
}

/* Stagger children for sequential reveal */
.stagger-children > * {
  animation: fade-in-up var(--duration-normal) var(--ease-out) both;
}
.stagger-children > *:nth-child(1) { animation-delay: 0ms; }
.stagger-children > *:nth-child(2) { animation-delay: 75ms; }
.stagger-children > *:nth-child(3) { animation-delay: 150ms; }
.stagger-children > *:nth-child(4) { animation-delay: 225ms; }
.stagger-children > *:nth-child(5) { animation-delay: 300ms; }
```

---

## 3. 🔤 Typography — The Foundation of Great UI

### 3.1 Font Selection

#### ✅ MUST do:
- Use **modern, professional fonts** from Google Fonts — **NEVER** use browser defaults
- Use **one font family** (two maximum: one for headings, one for body)
- Load fonts **optimally** (`font-display: swap`, preconnect, subset)

#### Recommended Font Pairings

| Use Case | Heading Font | Body Font |
|----------|-------------|-----------|
| **SaaS / Tech** | Inter | Inter |
| **Corporate / Finance** | Plus Jakarta Sans | Inter |
| **Creative / Agency** | Outfit | DM Sans |
| **Editorial / Blog** | Playfair Display | Source Serif 4 |
| **Startup / Modern** | Manrope | Inter |
| **Premium / Luxury** | Cormorant Garamond | Montserrat |

```html
<!-- ✅ REQUIRED: Optimal font loading -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
```

```css
/* ✅ REQUIRED: Typography system */
:root {
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;
  
  /* Type scale (Major Third — 1.25 ratio) */
  --text-xs:   0.75rem;    /* 12px */
  --text-sm:   0.875rem;   /* 14px */
  --text-base: 1rem;       /* 16px */
  --text-lg:   1.125rem;   /* 18px */
  --text-xl:   1.25rem;    /* 20px */
  --text-2xl:  1.5rem;     /* 24px */
  --text-3xl:  1.875rem;   /* 30px */
  --text-4xl:  2.25rem;    /* 36px */
  --text-5xl:  3rem;       /* 48px */
}

body {
  font-family: var(--font-sans);
  font-size: var(--text-base);
  line-height: 1.6;
  color: var(--color-text-primary);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
}
```

---

## 4. 🏗️ Layout & Composition — Structure That Guides

### 4.1 Responsive Layout System

#### ✅ MUST do:
- Design **mobile-first** — start with the smallest screen, progressively enhance
- Use **CSS Grid** for page-level layout and **Flexbox** for component-level layout
- Define consistent **breakpoints** aligned to common device sizes
- Use **container queries** for component-level responsiveness (where supported)

```css
/* ✅ REQUIRED: Responsive breakpoint system */
:root {
  --bp-sm:  640px;   /* Small phones → landscape phones */
  --bp-md:  768px;   /* Tablets */
  --bp-lg:  1024px;  /* Small laptops */
  --bp-xl:  1280px;  /* Desktops */
  --bp-2xl: 1536px;  /* Large desktops */
}

/* ✅ REQUIRED: Container with max-width */
.container {
  width: 100%;
  max-width: 1280px;
  margin-inline: auto;
  padding-inline: var(--space-4);
}

@media (min-width: 768px) {
  .container { padding-inline: var(--space-6); }
}

@media (min-width: 1280px) {
  .container { padding-inline: var(--space-8); }
}
```

### 4.2 Glassmorphism & Premium Surfaces

```css
/* ✅ Premium: Glassmorphism card */
.glass-card {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(16px) saturate(180%);
  -webkit-backdrop-filter: blur(16px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-lg);
}

[data-theme="dark"] .glass-card {
  background: rgba(15, 15, 25, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

/* ✅ Premium: Gradient mesh background */
.bg-mesh {
  background-color: var(--color-surface-base);
  background-image:
    radial-gradient(at 20% 20%, hsla(var(--hue-primary), 80%, 70%, 0.15) 0px, transparent 50%),
    radial-gradient(at 80% 40%, hsla(var(--hue-accent), 80%, 70%, 0.1) 0px, transparent 50%),
    radial-gradient(at 50% 80%, hsla(var(--hue-success), 70%, 60%, 0.08) 0px, transparent 50%);
}

/* ✅ Premium: Subtle border gradient */
.border-gradient {
  position: relative;
  border-radius: var(--radius-lg);
  background: var(--color-surface-raised);
}

.border-gradient::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1px;
  background: linear-gradient(135deg, var(--color-primary-400), var(--color-accent-400));
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}
```

---

## 5. ♿ Accessibility — Inclusive by Default

### 5.1 WCAG 2.1 AA Compliance (Mandatory)

#### ✅ MUST do:
- **Color contrast:** Minimum 4.5:1 for normal text, 3:1 for large text (18px+ bold or 24px+)
- **Keyboard navigation:** All interactive elements must be reachable and usable via keyboard
- **Focus indicators:** Visible, high-contrast focus rings on all interactive elements
- **Screen reader support:** Semantic HTML, ARIA labels, landmark roles
- **Touch targets:** Minimum 44×44px for all interactive elements on mobile
- **Text resizing:** UI must remain functional at 200% browser zoom
- **Motion:** Respect `prefers-reduced-motion`

#### ❌ MUST NOT do:
- Rely **solely on color** to convey information (add icons, text, patterns)
- Remove **focus indicators** for aesthetic reasons
- Use **auto-playing** animations without a pause/stop mechanism
- Create **keyboard traps** (user must be able to tab away from any element)

```css
/* ✅ REQUIRED: Focus indicator — visible and accessible */
:focus-visible {
  outline: 2px solid var(--color-primary-500);
  outline-offset: 2px;
  border-radius: var(--radius-sm);
}

/* ✅ REQUIRED: Skip to content link */
.skip-link {
  position: absolute;
  top: -100%;
  left: var(--space-4);
  padding: var(--space-2) var(--space-4);
  background: var(--color-primary-500);
  color: white;
  border-radius: var(--radius-md);
  z-index: 9999;
  font-weight: 600;
}

.skip-link:focus {
  top: var(--space-4);
}
```

```html
<!-- ✅ REQUIRED: Semantic HTML structure -->
<body>
  <a href="#main-content" class="skip-link">Skip to content</a>
  
  <header role="banner">
    <nav role="navigation" aria-label="Main navigation">
      <!-- Navigation items -->
    </nav>
  </header>

  <main id="main-content" role="main">
    <section aria-labelledby="section-heading">
      <h1 id="section-heading">Page Title</h1>
      <!-- Content -->
    </section>
  </main>

  <footer role="contentinfo">
    <!-- Footer content -->
  </footer>
</body>
```

---

## 6. 🎯 Component Design Standards

### 6.1 Button Hierarchy

Every page should have a clear **button hierarchy** to guide user action:

| Level | Style | Use For |
|-------|-------|---------|
| **Primary** | Solid fill + gradient | Main CTA — one per section maximum |
| **Secondary** | Outlined / subtle fill | Supporting actions |
| **Tertiary/Ghost** | Text only / transparent | Low-priority actions, cancel, back |
| **Destructive** | Red/danger color | Delete, remove, revoke |
| **Icon-only** | Circle/square with icon | Compact actions (close, edit, more) |

### 6.2 Form Design

#### ✅ MUST do:
- Use **floating labels** or **top-aligned labels** (never left-aligned — increases scan time)
- Show **inline validation** feedback as the user types (or on blur)
- Group related fields with **fieldsets** and **legends**
- Use **clear error states** with red borders + icon + descriptive message
- Show **success states** with green borders + check icon
- Use **placeholder text** sparingly — it's not a substitute for labels

### 6.3 Loading & Empty States

#### ✅ MUST do:
- Use **skeleton screens** instead of spinners for content loading
- Provide **meaningful empty states** with illustration + action CTA
- Show **progress indicators** for multi-step processes
- Display **optimistic UI** where possible (show expected result while waiting for server)

---

## 7. 📱 Responsive Design Decision Matrix

| Viewport | Layout Strategy | Navigation |
|----------|----------------|------------|
| **< 640px** (Mobile) | Single column, stacked cards, full-width buttons | Bottom tab bar or hamburger menu |
| **640-1024px** (Tablet) | 2-column grid, collapsible sidebar | Collapsible sidebar or top nav |
| **> 1024px** (Desktop) | Multi-column grid, persistent sidebar | Full sidebar + top nav |

---

## 📋 UI/UX Checklist Before Completing a Task

### Visual Design
- [ ] **Color palette** uses design tokens (no hardcoded hex values)
- [ ] **60-30-10 rule** applied to color usage
- [ ] **Dark mode** supported (via `prefers-color-scheme` or toggle)
- [ ] **Typography** uses a professional font from Google Fonts
- [ ] **Visual hierarchy** is clear — user knows where to look first

### Interactions
- [ ] **Hover states** on all interactive elements
- [ ] **Focus states** visible for keyboard navigation
- [ ] **Active/press states** provide feedback
- [ ] **Loading states** use skeletons, not spinners
- [ ] **Micro-animations** are smooth (150-300ms) with proper easing
- [ ] **Reduced motion** preference is respected

### Accessibility
- [ ] **Color contrast** meets WCAG AA (4.5:1 for text)
- [ ] **Touch targets** are minimum 44×44px
- [ ] **Semantic HTML** is used (headings, landmarks, labels)
- [ ] **Keyboard navigable** — all actions reachable via Tab/Enter/Space
- [ ] **Screen reader friendly** — ARIA labels on icons and interactive elements

### Responsiveness
- [ ] **Mobile-first** approach used
- [ ] Layout works at **320px** width minimum
- [ ] Layout works at **200% zoom**
- [ ] **No horizontal scrolling** at any breakpoint

### Premium Feel
- [ ] **Glassmorphism** or **gradient accents** used where appropriate
- [ ] **Consistent spacing** using 8px grid system
- [ ] **Stagger animations** for list/grid content entrance
- [ ] **Shadow elevation** creates clear content layers
- [ ] UI does NOT look generic, basic, or template-like

---

## ⚠️ Exceptions

These rules may be **relaxed** only in:

1. **CLI tools / terminal apps** — No visual UI required
2. **Admin dashboards** — May prioritize data density over aesthetics, but must still use design tokens and be consistent
3. **User explicitly requests minimal design** — Agent must still ensure accessibility compliance

> ⚠️ **NON-NEGOTIABLE:** Accessibility (WCAG AA) and responsive design are **NEVER** optional, regardless of project type.
