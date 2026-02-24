---
description: "Generate professional UI/UX with design intelligence. Use for any frontend work — landing pages, dashboards, components, or full applications."
---

# Context UI/UX — Design Intelligence + Professional Frontend

## Purpose
This workflow generates a **complete design system** and implements **professional UI** using the ui-ux-pro-max skill's design intelligence database. It covers everything from design tokens to implementation with accessibility verification.

> **Auto-activates** when other workflows (plan, work) detect frontend work.

---

## Activation
The user triggers this workflow by:
- Using `/context-ui-ux` followed by what they need (page, component, dashboard)
- Using `/context-ui-ux --redesign` to redesign existing UI
- Any request involving frontend/UI work (auto-detected by other workflows)

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 1: Requirements Analysis

### Step 1.1 — Read Design Skill
// turbo
Read `skills/ui-ux-pro-max/SKILL.md` and follow its complete process.

### Step 1.2 — Validate Python
// turbo
```bash
python3 --version 2>&1 || python --version 2>&1
```
If not installed, guide user to install Python 3.x.

### Step 1.3 — Read Project Context
// turbo
```
1. .agent/context/ARCHITECTURE.md     ← Frontend framework
2. .agent/context/DEPENDENCIES.md     ← UI libraries available
3. .agent/rules/ui-ux-design.md       ← UI/UX standards (MANDATORY)
4. .agent/rules/deep-thinking.md      ← Quality & completeness standards (MANDATORY)
5. .agent/rules/dark-light-mode.md    ← Dark/light mode standards (if applicable)
```

### Step 1.3b — Read Stack-Specific Skills
// turbo
Based on the detected frontend framework, read the relevant skill:
- **React**: `skills/reactjs/SKILL.md`
- **Next.js**: `skills/nextjs/SKILL.md`
- **Vue.js**: `skills/vuejs/SKILL.md`
- **Angular**: `skills/angular/SKILL.md`
- **Svelte**: `skills/svelte/SKILL.md`
- **Bootstrap**: `skills/bootstrap/SKILL.md`
- **Tailwind CSS**: `skills/tailwindcss/SKILL.md`
- **Material UI**: `skills/material-ui/SKILL.md`
- **Chakra UI**: `skills/chakra-ui/SKILL.md`
- **shadcn/ui**: `skills/shadcn-ui/SKILL.md`

Also consider if the UI involves:
- **Charts/Dashboards**: Read `skills/data-visualization/SKILL.md`
- **SEO**: Read `skills/seo/SKILL.md`
- **Accessibility**: Read `skills/accessibility-testing/SKILL.md`

### Step 1.4 — Extract Design Requirements

From the user request, identify:

```markdown
### Design Requirements

| Attribute | Value |
|-----------|-------|
| **Product Type** | SaaS / E-commerce / Portfolio / Dashboard / Landing / Blog |
| **Industry** | Healthcare / Fintech / Gaming / Education / Enterprise / etc. |
| **Style Keywords** | Minimal / Playful / Professional / Luxurious / Bold / etc. |
| **Target Users** | Developers / Business users / General public / etc. |
| **Tech Stack** | React + Tailwind / Vue + Vuetify / Next.js + shadcn / etc. |
| **Dark Mode** | Required / Optional / Not needed |
| **Responsive** | Desktop-first / Mobile-first / Both |
| **Accessibility** | WCAG 2.1 AA (default) / AAA / Basic |
| **Brand Colors** | [user-specified or generate] |
```

---

## Phase 2: Design System Generation

### Step 2.1 — Generate Design System
// turbo
```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<product_type> <industry> <keywords>" --design-system -p "<Project Name>"
```

### Step 2.2 — Persist Design System (Recommended)
```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system --persist -p "<Project Name>"
```

### Step 2.3 — Supplement Searches
// turbo
```bash
# Get style-specific details
python3 skills/ui-ux-pro-max/scripts/search.py "<keyword>" --domain <domain>

# Get stack-specific patterns
python3 skills/ui-ux-pro-max/scripts/search.py "<keyword>" --stack <stack>
```

### Step 2.4 — Present Design System

Show the complete design system for approval:

```markdown
### 🎨 Design System Generated

**Pattern:** [Neo-Brutalist / Glassmorphism / Material / Organic / etc.]
**Color Palette:** [Primary, Secondary, Accent, Neutrals]
**Typography:** [Heading font + Body font from Google Fonts]
**Spacing Scale:** [4, 8, 12, 16, 24, 32, 48, 64, 96]
**Border Radius:** [Sharp / Rounded / Pill]
**Shadows:** [Subtle / Medium / Dramatic]
**Animations:** [Type + Duration + Easing]

Does this design direction look good? (approve / adjust / different style)
```

---

## Phase 3: Architecture Verification

### Step 3.1 — Check Architecture
// turbo
Read `skills/architecture-enforcement/SKILL.md` to verify correct file placement for the frontend framework.

### Step 3.2 — Check for Dark/Light Mode Skill
// turbo
If dark mode is required, read `skills/dark-light-mode/SKILL.md` for:
- CSS custom properties (design tokens)
- System preference detection
- FOUC prevention
- Toggle component

### Step 3.3 — Check for Animation Skill
// turbo
If animations are needed, read `skills/animation-motion/SKILL.md` for:
- Micro-interactions
- Page transitions
- Scroll-triggered effects
- Loading states

### Step 3.4 — Check Icon Library
// turbo
Read `skills/icon-libraries/SKILL.md` for consistent icon usage:
- Lucide React (recommended for React)
- Heroicons (for Tailwind projects)
- Phosphor Icons (for versatile needs)

---

## Phase 4: Implementation

### Step 4.1 — Create Design Token System

Implement CSS custom properties or framework-specific tokens:

```css
:root {
  /* Colors */
  --color-primary: hsl(222, 84%, 58%);
  --color-secondary: hsl(262, 83%, 58%);
  --color-accent: hsl(38, 92%, 50%);
  --color-background: hsl(0, 0%, 100%);
  --color-surface: hsl(0, 0%, 98%);
  --color-text: hsl(222, 47%, 11%);
  --color-text-muted: hsl(215, 16%, 47%);

  /* Typography */
  --font-heading: 'Inter', sans-serif;
  --font-body: 'Inter', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;

  /* Spacing */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;
  --space-2xl: 3rem;

  /* Borders & Shadows */
  --radius-sm: 0.375rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.07);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-normal: 250ms ease;
  --transition-slow: 350ms cubic-bezier(0.4, 0, 0.2, 1);
}

[data-theme="dark"] {
  --color-background: hsl(222, 47%, 8%);
  --color-surface: hsl(222, 47%, 12%);
  --color-text: hsl(0, 0%, 95%);
  --color-text-muted: hsl(215, 16%, 65%);
}
```

### Step 4.2 — Build Components

Implement components following the design system:
- Apply recommended pattern, style, colors, typography
- Follow stack-specific guidelines
- Use framework best practices
- Include micro-interactions (hover, focus, active states)
- Implement responsive breakpoints

### Step 4.3 — Responsive Implementation

Test at standard breakpoints:
```css
/* Mobile first */
@media (min-width: 640px)  { /* sm  — Small devices */ }
@media (min-width: 768px)  { /* md  — Tablets */ }
@media (min-width: 1024px) { /* lg  — Laptops */ }
@media (min-width: 1280px) { /* xl  — Desktops */ }
@media (min-width: 1536px) { /* 2xl — Large screens */ }
```

### Step 4.4 — Accessibility Implementation

Follow WCAG 2.1 AA standards:
- Color contrast ≥ 4.5:1 (normal text), ≥ 3:1 (large text)
- All interactive elements keyboard-focusable
- Semantic HTML (proper heading hierarchy, landmarks)
- ARIA labels on interactive elements
- Focus indicators visible
- Alt text on all images
- Form labels associated with inputs
- Skip navigation link

---

## Phase 5: Pre-Delivery Checklist

### Step 5.1 — Visual Quality Check

| Check | Standard | Status |
|-------|----------|--------|
| No emoji as icons | Use icon library (Lucide, Heroicons) | ✅/❌ |
| Consistent icon set | Single library throughout | ✅/❌ |
| No browser default fonts | Google Fonts or system stack | ✅/❌ |
| No plain colors | Curated palette from design system | ✅/❌ |
| No unstyled scrollbars | Custom or hidden where appropriate | ✅/❌ |
| Images optimized | WebP format, lazy loading | ✅/❌ |
| Loading states | Skeleton screens or spinners | ✅/❌ |
| Empty states | Illustrated empty state messages | ✅/❌ |
| Error states | User-friendly error displays | ✅/❌ |

### Step 5.2 — Interaction Quality Check

| Check | Standard | Status |
|-------|----------|--------|
| cursor: pointer on clickables | All buttons, links, interactive elements | ✅/❌ |
| Hover states | Visual feedback on hover | ✅/❌ |
| Active/pressed states | Visual feedback on click | ✅/❌ |
| Focus states | Visible focus ring (keyboard nav) | ✅/❌ |
| Transitions | Smooth (150-350ms, ease/cubic-bezier) | ✅/❌ |
| No layout shift | Content doesn't jump on load/interaction | ✅/❌ |
| Touch targets | ≥ 44x44px on mobile | ✅/❌ |

### Step 5.3 — Theme Quality Check

| Check | Standard | Status |
|-------|----------|--------|
| Light mode | All text readable, contrast verified | ✅/❌ |
| Dark mode | All text readable, no pure white/black | ✅/❌ |
| Theme toggle | Smooth transition, no FOUC | ✅/❌ |
| System preference | Respects prefers-color-scheme | ✅/❌ |
| Persisted choice | Saved to localStorage | ✅/❌ |

### Step 5.4 — Layout Quality Check

| Check | Standard | Status |
|-------|----------|--------|
| Mobile (320px) | No horizontal scroll, readable | ✅/❌ |
| Tablet (768px) | Proper layout adjustment | ✅/❌ |
| Desktop (1440px) | Full layout, no wasted space | ✅/❌ |
| Max-width container | Content doesn't stretch to edges | ✅/❌ |
| Consistent spacing | Using design token spacing scale | ✅/❌ |

### Step 5.5 — Accessibility Final Check

| Check | WCAG Criterion | Status |
|-------|---------------|--------|
| Color contrast (normal) | 1.4.3 — ≥ 4.5:1 | ✅/❌ |
| Color contrast (large) | 1.4.3 — ≥ 3:1 | ✅/❌ |
| Keyboard navigation | 2.1.1 — All interactive elements | ✅/❌ |
| Focus visible | 2.4.7 — Focus indicator | ✅/❌ |
| Alt text | 1.1.1 — All images | ✅/❌ |
| Heading hierarchy | 1.3.1 — h1→h2→h3 (no skip) | ✅/❌ |
| Form labels | 1.3.1 — All inputs labeled | ✅/❌ |
| ARIA landmarks | 1.3.1 — main, nav, footer | ✅/❌ |
| Skip navigation | 2.4.1 — Skip to main content | ✅/❌ |
| Language attribute | 3.1.1 — lang on html | ✅/❌ |

---

## Phase 6: Handoff

### Step 6.1 — Summary Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 UI/UX IMPLEMENTATION COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Design:       [Pattern name] — [Style description]
Components:   [N] components created/updated
Pages:        [N] pages created/updated
Responsive:   ✅ 320px → 1536px verified
Dark Mode:    ✅ Implemented / ⬜ N/A
Accessibility: ✅ WCAG 2.1 AA compliant
Animations:   ✅ [N] micro-interactions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 6.2 — Suggest Next Steps

```markdown
Next Steps:
🔍 /context-review — Code review for implementation quality
🧪 /context-test   — Run E2E + accessibility tests
📝 /context-docs   — Update documentation
🚀 /context-deploy — Deploy the UI changes
```

---

## When to Use
- Building landing pages or marketing sites
- Creating dashboards or admin panels
- Designing new UI components or pages
- Redesigning existing frontend
- Any request involving frontend/UI work
- When other workflows detect frontend tasks

## When to Skip
- Backend-only work with no UI
- CLI tools or API-only services
- Minor text or copy changes (no visual impact)
