---
name: Animation & Motion Design
description: Skill for creating stunning UI animations with Framer Motion, GSAP, CSS animations, Lottie, scroll-triggered effects, page transitions, and micro-interactions for premium frontend experiences.
---

# Animation & Motion Design Skill

## Overview
Animation transforms static UIs into **living, breathing experiences**. This skill covers the most effective animation libraries and techniques for modern frontend development. Every animation must be **purposeful** — guiding attention, providing feedback, or creating delight.

## Golden Rules of UI Animation

```
┌──────────────────────────────────────────────────────────────┐
│  ANIMATION PHILOSOPHY                                        │
├──────────────────────────────────────────────────────────────┤
│  1. Every animation MUST have a PURPOSE (feedback, guide,    │
│     orient, delight) — never animate for decoration alone    │
│  2. Keep it FAST — 150-300ms for micro-interactions,         │
│     300-500ms for page transitions, 500-1000ms for reveals   │
│  3. Use EASING — never linear. ease-out for entries,         │
│     ease-in for exits, ease-in-out for state changes         │
│  4. RESPECT prefers-reduced-motion — always                  │
│  5. Animate TRANSFORMS + OPACITY only — never width,         │
│     height, top, left (causes layout thrashing)              │
│  6. STAGGER groups — sequential reveal feels premium         │
│  7. LESS IS MORE — subtle > flashy                           │
│  8. 60 FPS or nothing — never ship janky animations          │
└──────────────────────────────────────────────────────────────┘
```

---

## Library Decision Matrix

| Scenario | Recommended | Why |
|----------|-------------|-----|
| React component animations | **Framer Motion** | Best DX, layout animations, gestures |
| React page transitions | **Framer Motion** + `AnimatePresence` | Exit animations support |
| Scroll-triggered reveals | **Framer Motion** `useInView` or **Intersection Observer** | Native performance |
| Complex timeline sequences | **GSAP** | Most powerful timeline engine |
| SVG path animations | **GSAP** DrawSVG or **Framer Motion** pathLength | Smooth path drawing |
| Lottie/After Effects animations | **lottie-react** or **@lottiefiles/react** | Designer handoff |
| Simple CSS-only animations | **CSS @keyframes** | Zero JS overhead |
| 3D transforms / WebGL | **Three.js** + **React Three Fiber** | 3D scenes |
| Number counting animations | **framer-motion** `useSpring` or **CountUp.js** | Smooth number tween |
| Vanilla JS (no framework) | **GSAP** or **Motion One** | Framework agnostic |

---

## 1. Framer Motion (React — Primary Choice)

### Installation
```bash
npm install framer-motion
```

### Core Concepts

#### Basic Animation
```tsx
import { motion } from 'framer-motion';

// ✅ Animate on mount
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.5, ease: [0.25, 0.46, 0.45, 0.94] }}
>
  <h1>Welcome</h1>
</motion.div>
```

#### Hover & Tap Interactions
```tsx
// ✅ Premium button with hover + tap
<motion.button
  whileHover={{ scale: 1.02, y: -2 }}
  whileTap={{ scale: 0.98 }}
  transition={{ type: 'spring', stiffness: 400, damping: 17 }}
  className="btn-primary"
>
  Get Started
</motion.button>

// ✅ Card lift on hover
<motion.div
  whileHover={{
    y: -8,
    boxShadow: '0 20px 40px rgba(0,0,0,0.12)',
    borderColor: 'rgba(99, 102, 241, 0.3)',
  }}
  transition={{ type: 'spring', stiffness: 300, damping: 20 }}
  className="card"
>
  <h3>Feature Card</h3>
</motion.div>
```

#### Stagger Children (Sequential Reveal)
```tsx
// ✅ MUST USE for lists, grids, dashboard cards
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,       // 80ms between each child
      delayChildren: 0.1,          // slight initial delay
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      ease: [0.25, 0.46, 0.45, 0.94],
    },
  },
};

function FeatureGrid({ features }: { features: Feature[] }) {
  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className="grid grid-cols-3 gap-6"
    >
      {features.map((feature) => (
        <motion.div key={feature.id} variants={itemVariants} className="card">
          <h3>{feature.title}</h3>
          <p>{feature.description}</p>
        </motion.div>
      ))}
    </motion.div>
  );
}
```

#### Page Transitions with AnimatePresence
```tsx
import { AnimatePresence, motion } from 'framer-motion';
import { useLocation } from 'react-router-dom';

// ✅ Smooth page transitions
const pageVariants = {
  initial: { opacity: 0, y: 12 },
  animate: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.4, ease: [0.25, 0.46, 0.45, 0.94] },
  },
  exit: {
    opacity: 0,
    y: -12,
    transition: { duration: 0.3, ease: [0.55, 0, 1, 0.45] },
  },
};

function AnimatedRoutes() {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={location.pathname}
        variants={pageVariants}
        initial="initial"
        animate="animate"
        exit="exit"
      >
        <Routes location={location}>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
        </Routes>
      </motion.div>
    </AnimatePresence>
  );
}
```

#### Scroll-Triggered Animations
```tsx
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

// ✅ Animate when element enters viewport
function ScrollReveal({ children }: { children: React.ReactNode }) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 40 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 40 }}
      transition={{ duration: 0.6, ease: [0.25, 0.46, 0.45, 0.94] }}
    >
      {children}
    </motion.div>
  );
}

// Usage — wrap any section
<ScrollReveal>
  <section className="feature-section">
    <h2>Amazing Feature</h2>
  </section>
</ScrollReveal>
```

#### Animated Number Counter
```tsx
import { motion, useMotionValue, useTransform, animate } from 'framer-motion';
import { useEffect } from 'react';

// ✅ Animated stat counter (e.g., dashboard metrics)
function AnimatedCounter({ value, duration = 2 }: { value: number; duration?: number }) {
  const count = useMotionValue(0);
  const rounded = useTransform(count, (v) => Math.round(v).toLocaleString());

  useEffect(() => {
    const controls = animate(count, value, {
      duration,
      ease: [0.25, 0.46, 0.45, 0.94],
    });
    return controls.stop;
  }, [value, duration, count]);

  return <motion.span>{rounded}</motion.span>;
}

// Usage
<div className="stat-card">
  <AnimatedCounter value={12847} />
  <span className="stat-label">Total Users</span>
</div>
```

#### Layout Animations (Shared Layout)
```tsx
import { motion, LayoutGroup } from 'framer-motion';

// ✅ Smooth tab indicator movement
function TabBar({ tabs, activeTab, onSelect }: TabBarProps) {
  return (
    <LayoutGroup>
      <div className="tab-bar">
        {tabs.map((tab) => (
          <button key={tab.id} onClick={() => onSelect(tab.id)} className="tab">
            {tab.label}
            {activeTab === tab.id && (
              <motion.div
                layoutId="tab-indicator"
                className="tab-indicator"
                transition={{ type: 'spring', stiffness: 500, damping: 30 }}
              />
            )}
          </button>
        ))}
      </div>
    </LayoutGroup>
  );
}
```

#### Modal / Dialog Animation
```tsx
// ✅ Premium modal entrance
const backdropVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
};

const modalVariants = {
  hidden: { opacity: 0, scale: 0.95, y: 10 },
  visible: {
    opacity: 1,
    scale: 1,
    y: 0,
    transition: { type: 'spring', stiffness: 300, damping: 24 },
  },
  exit: {
    opacity: 0,
    scale: 0.95,
    y: 10,
    transition: { duration: 0.2, ease: 'easeIn' },
  },
};

function Modal({ isOpen, onClose, children }: ModalProps) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          className="modal-backdrop"
          variants={backdropVariants}
          initial="hidden"
          animate="visible"
          exit="hidden"
          onClick={onClose}
        >
          <motion.div
            className="modal-content"
            variants={modalVariants}
            initial="hidden"
            animate="visible"
            exit="exit"
            onClick={(e) => e.stopPropagation()}
          >
            {children}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

---

## 2. GSAP (Framework-Agnostic — Complex Animations)

### Installation
```bash
npm install gsap
```

### Timeline Animations
```typescript
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

// ✅ Complex hero section entrance
function animateHero() {
  const tl = gsap.timeline({ defaults: { ease: 'power3.out' } });

  tl.from('.hero-title', { y: 60, opacity: 0, duration: 0.8 })
    .from('.hero-subtitle', { y: 40, opacity: 0, duration: 0.6 }, '-=0.4')
    .from('.hero-cta', { y: 30, opacity: 0, duration: 0.5 }, '-=0.3')
    .from('.hero-image', { x: 60, opacity: 0, duration: 0.8 }, '-=0.5');
}

// ✅ Scroll-triggered section reveals
function setupScrollAnimations() {
  gsap.utils.toArray<HTMLElement>('.reveal-section').forEach((section) => {
    gsap.from(section, {
      scrollTrigger: {
        trigger: section,
        start: 'top 80%',
        end: 'bottom 20%',
        toggleActions: 'play none none reverse',
      },
      y: 60,
      opacity: 0,
      duration: 0.8,
      ease: 'power3.out',
    });
  });
}

// ✅ Staggered grid items on scroll
function animateGrid() {
  gsap.from('.grid-item', {
    scrollTrigger: {
      trigger: '.grid-container',
      start: 'top 75%',
    },
    y: 40,
    opacity: 0,
    duration: 0.6,
    stagger: 0.1,
    ease: 'power2.out',
  });
}
```

### GSAP with React (useGSAP hook)
```tsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';

function HeroSection() {
  const containerRef = useRef<HTMLDivElement>(null);

  useGSAP(() => {
    const tl = gsap.timeline();
    tl.from('.hero-title', { y: 50, opacity: 0, duration: 0.8 })
      .from('.hero-desc', { y: 30, opacity: 0, duration: 0.6 }, '-=0.4');
  }, { scope: containerRef });

  return (
    <div ref={containerRef}>
      <h1 className="hero-title">Build Something Amazing</h1>
      <p className="hero-desc">Start your journey today</p>
    </div>
  );
}
```

---

## 3. CSS-Only Animations (Zero JS Overhead)

### Keyframe Animations
```css
/* ✅ Smooth fade-in-up entrance */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ✅ Pulse glow for attention */
@keyframes pulseGlow {
  0%, 100% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4); }
  50% { box-shadow: 0 0 0 8px rgba(99, 102, 241, 0); }
}

/* ✅ Gradient shift for backgrounds */
@keyframes gradientShift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

/* ✅ Skeleton shimmer loading */
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

/* ✅ Subtle float (for decorative elements) */
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

/* ✅ Spin for loading indicators */
@keyframes spin {
  to { transform: rotate(360deg); }
}
```

### CSS Utility Classes
```css
/* Animation utility classes */
.animate-fade-in-up {
  animation: fadeInUp 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) both;
}

.animate-pulse-glow {
  animation: pulseGlow 2s ease-in-out infinite;
}

.animate-gradient {
  background-size: 200% 200%;
  animation: gradientShift 8s ease infinite;
}

.animate-shimmer {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s ease-in-out infinite;
}

.animate-float {
  animation: float 6s ease-in-out infinite;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

/* Stagger delays for children */
.stagger > *:nth-child(1) { animation-delay: 0ms; }
.stagger > *:nth-child(2) { animation-delay: 80ms; }
.stagger > *:nth-child(3) { animation-delay: 160ms; }
.stagger > *:nth-child(4) { animation-delay: 240ms; }
.stagger > *:nth-child(5) { animation-delay: 320ms; }
.stagger > *:nth-child(6) { animation-delay: 400ms; }

/* ✅ ALWAYS respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### CSS Scroll-Driven Animations (Modern Browsers)
```css
/* ✅ CSS-only scroll reveal (Chrome 115+, no JS needed) */
@keyframes reveal {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.scroll-reveal {
  animation: reveal linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 30%;
}
```

---

## 4. Lottie Animations (Designer Handoff)

### Installation
```bash
npm install lottie-react
# or
npm install @lottiefiles/react-lottie-player
```

### Usage
```tsx
import Lottie from 'lottie-react';
import successAnimation from '@/assets/lottie/success.json';
import loadingAnimation from '@/assets/lottie/loading.json';

// ✅ Success state animation
function SuccessState() {
  return (
    <div className="flex flex-col items-center gap-4">
      <Lottie
        animationData={successAnimation}
        loop={false}
        style={{ width: 200, height: 200 }}
      />
      <h2>Payment Successful!</h2>
    </div>
  );
}

// ✅ Loading state (instead of boring spinner)
function LoadingState() {
  return (
    <Lottie
      animationData={loadingAnimation}
      loop={true}
      style={{ width: 120, height: 120 }}
    />
  );
}
```

**Where to get Lottie files:**
- https://lottiefiles.com (free + premium)
- https://lordicon.com (animated icons)
- Export from After Effects with Bodymovin plugin

---

## 5. Reusable Animation Components Library

```tsx
// ✅ RECOMMENDED: Create a shared animation components library

// components/animations/FadeInUp.tsx
import { motion, type HTMLMotionProps } from 'framer-motion';

interface FadeInUpProps extends HTMLMotionProps<'div'> {
  delay?: number;
  duration?: number;
  children: React.ReactNode;
}

export function FadeInUp({ delay = 0, duration = 0.5, children, ...props }: FadeInUpProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay, duration, ease: [0.25, 0.46, 0.45, 0.94] }}
      {...props}
    >
      {children}
    </motion.div>
  );
}

// components/animations/StaggerContainer.tsx
export function StaggerContainer({
  children,
  staggerDelay = 0.08,
  className,
}: {
  children: React.ReactNode;
  staggerDelay?: number;
  className?: string;
}) {
  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={{
        hidden: { opacity: 0 },
        visible: {
          opacity: 1,
          transition: { staggerChildren: staggerDelay },
        },
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

// components/animations/StaggerItem.tsx
export function StaggerItem({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <motion.div
      variants={{
        hidden: { opacity: 0, y: 20 },
        visible: { opacity: 1, y: 0, transition: { duration: 0.5, ease: [0.25, 0.46, 0.45, 0.94] } },
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

// components/animations/ScrollReveal.tsx
export function ScrollReveal({ children, className }: { children: React.ReactNode; className?: string }) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-80px' });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 40 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.6, ease: [0.25, 0.46, 0.45, 0.94] }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
```

---

## 6. Common Animation Patterns Cheatsheet

| UI Element | Animation | Duration | Easing |
|-----------|-----------|----------|--------|
| Button hover | `translateY(-2px)` + shadow expand | 150ms | ease-out |
| Button press | `scale(0.98)` | 75ms | ease-in |
| Card hover | `translateY(-8px)` + shadow-lg | 250ms | spring(300, 20) |
| Modal enter | `scale(0.95→1)` + `opacity(0→1)` | 300ms | spring(300, 24) |
| Modal exit | `scale(1→0.95)` + `opacity(1→0)` | 200ms | ease-in |
| Dropdown open | `scaleY(0→1)` + `opacity(0→1)` origin-top | 200ms | ease-out |
| Toast enter | `translateX(100%→0)` + `opacity(0→1)` | 300ms | spring |
| Toast exit | `translateX(0→100%)` + opacity | 200ms | ease-in |
| Page enter | `translateY(12→0)` + `opacity(0→1)` | 400ms | ease-out |
| Page exit | `translateY(0→-12)` + `opacity(1→0)` | 300ms | ease-in |
| Skeleton | shimmer gradient shift | 1500ms | ease-in-out, infinite |
| Scroll reveal | `translateY(40→0)` + `opacity(0→1)` | 600ms | ease-out |
| Tab indicator | `layoutId` spring animation | N/A | spring(500, 30) |
| Number count | `useSpring` / `animate` | 2000ms | ease-out |
| Sidebar open | `translateX(-100%→0)` | 300ms | ease-out |
| Sidebar close | `translateX(0→-100%)` | 250ms | ease-in |

---

## Performance Best Practices

1. **Only animate `transform` and `opacity`** — these don't trigger layout recalculation
2. **Use `will-change: transform`** sparingly — only on elements about to animate
3. **Remove `will-change` after animation completes** — keeping it wastes GPU memory
4. **Use `contain: layout`** on animated containers to isolate reflows
5. **Lazy-load heavy animation libraries** — GSAP, Lottie: import dynamically
6. **Test on low-end devices** — animations must be smooth on $200 phones
7. **Kill animations on unmount** — especially GSAP timelines and intervals
8. **Batch DOM reads/writes** — use `requestAnimationFrame` for manual animations
9. **Prefer CSS animations for simple effects** — JS overhead is unnecessary for hover/focus

## Rules Integration
- **UI/UX Rule**: Every animation must follow the timing tokens in `rules/ui-ux-design.md`
- **Accessibility**: Always include `prefers-reduced-motion` media query
- **Performance**: Never animate layout properties (width, height, top, left, margin, padding)
- **SOLID**: Create reusable animation components (FadeInUp, ScrollReveal, Stagger)
