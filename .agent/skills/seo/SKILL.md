---
name: SEO (Search Engine Optimization)
description: Skill for implementing technical SEO best practices, covering on-page optimization, structured data, Core Web Vitals, meta tags, sitemap generation, and SEO auditing.
---

# SEO Skill

## Overview
Technical SEO ensures search engines can crawl, index, and rank your pages effectively. This skill covers on-page SEO, structured data, performance optimization, and programmatic SEO implementation.

## 1. HTML Meta Tags (Essential)

### ✅ REQUIRED on Every Page
```html
<head>
  <!-- Primary Meta Tags -->
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Primary Keyword — Brand Name</title>
  <meta name="description" content="Compelling 150-160 char description with target keyword. Include a call to action." />
  <meta name="robots" content="index, follow" />
  <link rel="canonical" href="https://example.com/current-page" />

  <!-- Open Graph (Facebook, LinkedIn) -->
  <meta property="og:type" content="website" />
  <meta property="og:title" content="Page Title for Social" />
  <meta property="og:description" content="Social-optimized description (up to 300 chars)" />
  <meta property="og:image" content="https://example.com/og-image-1200x630.jpg" />
  <meta property="og:url" content="https://example.com/current-page" />
  <meta property="og:site_name" content="Brand Name" />
  <meta property="og:locale" content="en_US" />

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Page Title for Twitter" />
  <meta name="twitter:description" content="Twitter description (up to 200 chars)" />
  <meta name="twitter:image" content="https://example.com/og-image-1200x630.jpg" />
  <meta name="twitter:site" content="@brand_handle" />

  <!-- Alternate Languages (i18n) -->
  <link rel="alternate" hreflang="en" href="https://example.com/en/page" />
  <link rel="alternate" hreflang="id" href="https://example.com/id/page" />
  <link rel="alternate" hreflang="x-default" href="https://example.com/page" />

  <!-- Favicon -->
  <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
  <link rel="manifest" href="/site.webmanifest" />
  <meta name="theme-color" content="#6366f1" />

  <!-- Preconnect for Performance -->
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://cdn.example.com" />
  <link rel="dns-prefetch" href="https://analytics.example.com" />
</head>
```

## 2. Structured Data (JSON-LD)

### Organization
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Company Name",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png",
  "sameAs": [
    "https://twitter.com/company",
    "https://linkedin.com/company/company-name"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "+1-555-555-5555",
    "contactType": "customer service"
  }
}
</script>
```

### Article / Blog Post
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Article Title (max 110 chars)",
  "description": "Brief article summary",
  "image": "https://example.com/article-image.jpg",
  "author": { "@type": "Person", "name": "Author Name" },
  "publisher": {
    "@type": "Organization",
    "name": "Publisher",
    "logo": { "@type": "ImageObject", "url": "https://example.com/logo.png" }
  },
  "datePublished": "2026-02-19",
  "dateModified": "2026-02-19"
}
</script>
```

### FAQ Page
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is your return policy?",
      "acceptedAnswer": { "@type": "Answer", "text": "We offer 30-day returns..." }
    },
    {
      "@type": "Question",
      "name": "How long does shipping take?",
      "acceptedAnswer": { "@type": "Answer", "text": "Standard shipping is 3-5 days..." }
    }
  ]
}
</script>
```

### Breadcrumb
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com" },
    { "@type": "ListItem", "position": 2, "name": "Products", "item": "https://example.com/products" },
    { "@type": "ListItem", "position": 3, "name": "Product Name" }
  ]
}
</script>
```

## 3. Semantic HTML Structure

```html
<!-- ✅ REQUIRED: Proper heading hierarchy -->
<body>
  <header>
    <nav aria-label="Main navigation"><!-- Primary nav --></nav>
  </header>

  <main>
    <article>
      <h1>Single H1 Per Page — Primary Keyword</h1>  <!-- Only ONE h1 -->
      <p>Introduction paragraph with target keyword naturally included.</p>

      <section>
        <h2>Section Heading — Secondary Keyword</h2>
        <p>Content with related terms and entities.</p>

        <h3>Subsection — Long-tail Keyword</h3>
        <p>Detailed content...</p>
      </section>

      <section>
        <h2>Another Section</h2>
        <!-- Content -->
      </section>
    </article>

    <aside>
      <nav aria-label="Related content"><!-- Sidebar links --></nav>
    </aside>
  </main>

  <footer>
    <nav aria-label="Footer navigation"><!-- Secondary nav --></nav>
  </footer>
</body>
```

## 4. Image Optimization

```html
<!-- ✅ REQUIRED: Optimized images -->
<img
  src="/images/product-hero.webp"
  alt="Descriptive alt text with keyword — Product Name in action"
  width="800"
  height="600"
  loading="lazy"
  decoding="async"
  fetchpriority="low"
/>

<!-- Hero/LCP image — NO lazy loading -->
<img
  src="/images/hero.webp"
  alt="Hero description"
  width="1200"
  height="630"
  fetchpriority="high"
/>

<!-- Responsive with srcset -->
<picture>
  <source srcset="/images/hero-800.avif 800w, /images/hero-1200.avif 1200w" type="image/avif" />
  <source srcset="/images/hero-800.webp 800w, /images/hero-1200.webp 1200w" type="image/webp" />
  <img src="/images/hero-1200.jpg" alt="Hero" width="1200" height="630" />
</picture>
```

## 5. Core Web Vitals Optimization

| Metric | Target | Strategy |
|--------|--------|----------|
| **LCP** (Largest Contentful Paint) | < 2.5s | Preload hero image, use CDN, optimize fonts, SSR |
| **FID/INP** (Interaction to Next Paint) | < 200ms | Defer non-critical JS, code-split, web workers |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Set explicit `width`/`height` on images/videos, font-display: swap |

```html
<!-- ✅ Preload LCP image -->
<link rel="preload" as="image" href="/hero.webp" fetchpriority="high" />

<!-- ✅ Preload critical font -->
<link rel="preload" as="font" type="font/woff2" href="/fonts/inter-var.woff2" crossorigin />

<!-- ✅ Defer non-critical CSS -->
<link rel="preload" as="style" href="/non-critical.css" onload="this.rel='stylesheet'" />
<noscript><link rel="stylesheet" href="/non-critical.css" /></noscript>
```

## 6. Sitemap & Robots.txt

### sitemap.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2026-02-19</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://example.com/products</loc>
    <lastmod>2026-02-18</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
```

### robots.txt
```text
User-Agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Disallow: /private/

Sitemap: https://example.com/sitemap.xml
```

### Programmatic Sitemap (Next.js)
```typescript
// app/sitemap.ts
import { MetadataRoute } from 'next';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const posts = await getAllPosts();

  const postUrls = posts.map((post) => ({
    url: `https://example.com/blog/${post.slug}`,
    lastModified: post.updatedAt,
    changeFrequency: 'weekly' as const,
    priority: 0.7,
  }));

  return [
    { url: 'https://example.com', lastModified: new Date(), changeFrequency: 'daily', priority: 1 },
    { url: 'https://example.com/products', lastModified: new Date(), changeFrequency: 'weekly', priority: 0.8 },
    ...postUrls,
  ];
}
```

## 7. Next.js / React SEO

```tsx
// app/layout.tsx — Root metadata
import { Metadata } from 'next';

export const metadata: Metadata = {
  metadataBase: new URL('https://example.com'),
  title: { default: 'Brand Name', template: '%s | Brand Name' },
  description: 'Site-wide description',
  openGraph: { type: 'website', siteName: 'Brand Name', locale: 'en_US' },
  twitter: { card: 'summary_large_image', site: '@brand' },
  robots: { index: true, follow: true },
  alternates: { canonical: '/' },
};

// app/blog/[slug]/page.tsx — Dynamic metadata
export async function generateMetadata({ params }): Promise<Metadata> {
  const post = await getPost(params.slug);
  return {
    title: post.title,
    description: post.excerpt,
    openGraph: { title: post.title, description: post.excerpt, images: [post.image] },
    alternates: { canonical: `/blog/${params.slug}` },
  };
}
```

## 8. SEO Checklist

### On-Page
- [ ] Unique `<title>` (50-60 chars) with primary keyword
- [ ] Unique `<meta description>` (150-160 chars) with CTA
- [ ] Single `<h1>` with primary keyword
- [ ] Heading hierarchy (h1 > h2 > h3, no skipping)
- [ ] Canonical URL on every page
- [ ] Internal linking (2-5 relevant links per page)
- [ ] Alt text on all images (descriptive, with keyword where natural)
- [ ] URL structure: `/category/page-title` (lowercase, hyphens)

### Technical
- [ ] Mobile-responsive (passes Google Mobile-Friendly test)
- [ ] HTTPS enforced
- [ ] Core Web Vitals pass (LCP < 2.5s, INP < 200ms, CLS < 0.1)
- [ ] sitemap.xml submitted to Search Console
- [ ] robots.txt properly configured
- [ ] Structured data validates (schema.org, Google Rich Results Test)
- [ ] No broken links (404s)
- [ ] Images in WebP/AVIF with responsive srcset

### Performance
- [ ] Fonts preloaded with `font-display: swap`
- [ ] Critical CSS inlined or preloaded
- [ ] JavaScript deferred/async
- [ ] Images lazy-loaded (except LCP)
- [ ] CDN for static assets

## Rules Integration
- **UI/UX**: SEO requires fast load times — aligns with performance in UI/UX rule
- **Accessibility**: Semantic HTML and alt text serve both SEO and accessibility (WCAG)
- **Security**: HTTPS is mandatory for both SEO ranking and security compliance
