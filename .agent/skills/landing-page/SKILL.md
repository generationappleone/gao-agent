---
name: Landing Page
description: Skill for building high-converting landing pages — covering hero sections, value propositions, CTAs, social proof, form optimization, responsive design, performance, SEO, and A/B testing patterns.
---

# Landing Page — Conversion-Optimized Development Guide

## Core Principles

### The 5-Second Rule
Visitors must understand **what you offer** and **why it matters** within 5 seconds of landing.

### Single Focus
Every landing page has **ONE primary goal** and **ONE CTA**. Remove all distractions (nav bars, social links, footer links).

---

## Page Structure

### Recommended Section Order
```
1. Hero Section          — Headline + subheadline + CTA + hero image/video
2. Social Proof Bar      — Logos, trust badges, "As seen in"
3. Problem/Pain          — Describe the problem you solve
4. Solution/Benefits     — How your product solves it (3-4 key benefits)
5. How It Works          — 3-step process or feature showcase
6. Social Proof          — Testimonials, reviews, case studies
7. Pricing/Offer         — Clear pricing or offer details
8. FAQ                   — Address common objections
9. Final CTA             — Repeat the primary call to action
10. Footer (minimal)     — Legal links only (privacy, terms)
```

---

## Hero Section

### Essential Elements
```html
<section class="hero">
  <!-- Headline: Specific, benefit-driven, under 10 words -->
  <h1>Ship Features 10x Faster with AI</h1>

  <!-- Subheadline: Expand on HOW, 1-2 sentences -->
  <p>Our AI-powered platform generates production-ready code
     from your design files in seconds, not days.</p>

  <!-- Primary CTA: Action-driven text, contrasting color -->
  <a href="#signup" class="cta-primary">Start Free Trial</a>

  <!-- Microcopy: Reduce friction -->
  <span class="microcopy">No credit card required · Free for 14 days</span>

  <!-- Hero Image/Video: Show the product in action -->
  <img src="/hero-dashboard.webp" alt="AI code generation dashboard" />
</section>
```

### CTA Best Practices
| Do | Don't |
|----|-------|
| "Start Free Trial" | "Submit" |
| "Get My Free Report" | "Download" |
| "See Plans & Pricing" | "Learn More" |
| Use contrasting color | Blend with page |
| Include microcopy | Leave CTA alone |
| Repeat CTA 2-3 times | Single CTA only |

---

## Social Proof Patterns

### Types (Use at Least 2)
1. **Client Logos** — "Trusted by 500+ companies"
2. **Testimonials** — Real quotes with photo, name, title, company
3. **Statistics** — "10,000+ users", "99.9% uptime", "4.9★ rating"
4. **Reviews** — Star ratings from G2, Capterra, Trustpilot
5. **Case Studies** — "Company X increased revenue by 40%"
6. **Trust Badges** — Security certifications, payment badges

### Testimonial Template
```html
<blockquote class="testimonial">
  <p>"Specific result or benefit they experienced..."</p>
  <footer>
    <img src="/avatar.webp" alt="Jane Smith" />
    <cite>
      <strong>Jane Smith</strong>
      <span>CTO, TechCorp</span>
    </cite>
  </footer>
</blockquote>
```

---

## Form Optimization

### Rules
- **Minimum fields**: Only ask for what you absolutely need
- **Single column**: Never use multi-column forms
- **Labels above inputs**: Not inline placeholders
- **Real-time validation**: Show errors as user types
- **Progress indicator**: For multi-step forms
- **Trust signals**: Lock icon, "We never share your email"

### Optimal Field Count by Goal
| Goal | Max Fields |
|------|-----------|
| Newsletter | 1 (email) |
| Lead magnet | 2 (name, email) |
| Free trial | 3 (name, email, password) |
| Quote request | 5-7 (name, email, company, needs) |
| Demo booking | 4-5 (name, email, company, role) |

---

## Design Tokens

```css
:root {
  /* Typography */
  --font-heading: 'Inter', sans-serif;
  --font-body: 'Inter', sans-serif;

  /* Hero */
  --hero-min-height: 80vh;
  --hero-padding: 6rem 2rem;

  /* CTA */
  --cta-padding: 1rem 2.5rem;
  --cta-radius: 0.5rem;
  --cta-font-weight: 600;
  --cta-font-size: 1.125rem;

  /* Section Spacing */
  --section-padding: 5rem 2rem;
  --section-max-width: 1200px;
  --section-gap: 3rem;

  /* Transitions */
  --transition-cta: 200ms ease;
  --transition-hover: 150ms ease;
}
```

---

## Performance Checklist

| Metric | Target | How |
|--------|--------|-----|
| LCP (Largest Contentful Paint) | < 2.5s | Optimize hero image, preload fonts |
| FID (First Input Delay) | < 100ms | Defer non-critical JS |
| CLS (Cumulative Layout Shift) | < 0.1 | Set explicit dimensions on images |
| Page size | < 1MB | Compress images (WebP), minify CSS/JS |
| Time to Interactive | < 3s | Code split, lazy load below fold |
| Mobile Score | > 90 | Test with Lighthouse |

### Image Optimization
```html
<!-- Hero image: preload for LCP -->
<link rel="preload" as="image" href="/hero.webp" />

<!-- Below-fold images: lazy load -->
<img loading="lazy" src="/feature.webp" alt="Feature screenshot" />

<!-- Responsive images -->
<picture>
  <source media="(max-width: 768px)" srcset="/hero-mobile.webp" />
  <source media="(min-width: 769px)" srcset="/hero-desktop.webp" />
  <img src="/hero-desktop.webp" alt="Hero" />
</picture>
```

---

## SEO Requirements

```html
<head>
  <title>Product Name — Clear Benefit Statement</title>
  <meta name="description" content="Compelling 150-160 char description with primary keyword" />
  <meta name="robots" content="index, follow" />
  <link rel="canonical" href="https://example.com/landing" />

  <!-- Open Graph -->
  <meta property="og:title" content="Product Name — Benefit" />
  <meta property="og:description" content="Social sharing description" />
  <meta property="og:image" content="https://example.com/og-image.jpg" />
  <meta property="og:type" content="website" />

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Product Name — Benefit" />
  <meta name="twitter:description" content="Social sharing description" />
  <meta name="twitter:image" content="https://example.com/twitter-image.jpg" />

  <!-- Schema.org -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Product",
    "name": "Product Name",
    "description": "Product description",
    "offers": {
      "@type": "Offer",
      "price": "29.00",
      "priceCurrency": "USD"
    }
  }
  </script>
</head>
```

---

## Responsive Breakpoints

```css
/* Mobile first */
.hero h1 { font-size: 2rem; }
.hero p  { font-size: 1rem; }

@media (min-width: 768px) {
  .hero h1 { font-size: 3rem; }
  .hero p  { font-size: 1.25rem; }
}

@media (min-width: 1024px) {
  .hero { display: grid; grid-template-columns: 1fr 1fr; }
  .hero h1 { font-size: 3.5rem; }
}
```

---

## Conversion Optimization

### A/B Testing Priorities (High Impact First)
1. **Headline** — Test value prop wording
2. **CTA text** — Test action verbs
3. **CTA color** — Test contrast vs. harmony
4. **Hero image** — Product screenshot vs. lifestyle
5. **Social proof placement** — Above vs. below fold
6. **Form fields** — Fewer vs. more fields
7. **Page length** — Long-form vs. short-form

### Analytics Setup
```javascript
// Track key conversion events
analytics.track('page_view', { page: 'landing' });
analytics.track('cta_click', { button: 'hero_cta', variant: 'A' });
analytics.track('form_start', { form: 'signup' });
analytics.track('form_submit', { form: 'signup' });
analytics.track('scroll_depth', { depth: '50%' });
```

---

## Common Mistakes to Avoid

| Mistake | Fix |
|---------|-----|
| Multiple competing CTAs | Single primary CTA repeated 2-3x |
| Navigation bar present | Remove or minimize navigation |
| Generic stock photos | Use real product screenshots or custom illustrations |
| Headline describes features | Headline describes benefits/outcomes |
| No social proof | Add testimonials, logos, or statistics |
| Slow loading | Optimize images, defer scripts, use CDN |
| No mobile optimization | Mobile-first design, touch-friendly CTAs |
| No urgency | Add ethical urgency (limited time, spots remaining) |
| Form asks too much | Reduce to minimum required fields |
| CTA blends in | Use high-contrast color for CTA button |
