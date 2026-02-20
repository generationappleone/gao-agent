---
name: SEO (Search Engine Optimization)
description: Skill for implementing technical SEO best practices, covering on-page optimization, structured data, Core Web Vitals, meta tags, sitemap generation, and SEO auditing.
---

# SEO Skill

## Overview
SEO (Search Engine Optimization) involves technical and content optimizations to improve search engine visibility. Key areas include meta tags, structured data (JSON-LD), Core Web Vitals, sitemap/robots.txt, semantic HTML, Open Graph, and performance optimization.

**References**:
- [Google Search Central](https://developers.google.com/search/docs)
- [Schema.org](https://schema.org/)
- [Web.dev SEO](https://web.dev/learn/seo)

---

## Meta Tags

```tsx
// Next.js App Router metadata
export const metadata: Metadata = {
  title: { default: 'MyApp - Best Products Online', template: '%s | MyApp' },
  description: 'Discover the best products with free shipping and easy returns.',
  keywords: ['e-commerce', 'online shopping', 'best deals'],
  authors: [{ name: 'MyApp Team' }],
  openGraph: {
    type: 'website', locale: 'en_US', url: 'https://myapp.com',
    title: 'MyApp - Best Products Online',
    description: 'Discover the best products online.',
    images: [{ url: '/og-image.jpg', width: 1200, height: 630, alt: 'MyApp' }],
  },
  twitter: { card: 'summary_large_image', site: '@myapp' },
  robots: { index: true, follow: true },
  alternates: { canonical: 'https://myapp.com' },
};
```

---

## Structured Data (JSON-LD)

```tsx
export function ProductJsonLd({ product }: { product: Product }) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    description: product.description,
    image: product.images,
    offers: {
      '@type': 'Offer',
      price: (product.price / 100).toFixed(2),
      priceCurrency: 'USD',
      availability: product.stock > 0 ? 'https://schema.org/InStock' : 'https://schema.org/OutOfStock',
    },
    aggregateRating: product.ratingCount > 0 ? {
      '@type': 'AggregateRating',
      ratingValue: product.rating,
      reviewCount: product.ratingCount,
    } : undefined,
  };

  return <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />;
}
```

---

## Sitemap & Robots

```typescript
// app/sitemap.ts (Next.js)
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await db.product.findMany({ where: { status: 'active' }, select: { slug: true, updatedAt: true } });
  return [
    { url: 'https://myapp.com', lastModified: new Date(), changeFrequency: 'daily', priority: 1 },
    { url: 'https://myapp.com/products', lastModified: new Date(), changeFrequency: 'daily', priority: 0.9 },
    ...products.map(p => ({
      url: `https://myapp.com/products/${p.slug}`, lastModified: p.updatedAt, changeFrequency: 'weekly' as const, priority: 0.8,
    })),
  ];
}

// app/robots.ts
export default function robots(): MetadataRoute.Robots {
  return { rules: { userAgent: '*', allow: '/', disallow: ['/admin/', '/api/'] }, sitemap: 'https://myapp.com/sitemap.xml' };
}
```

---

## Semantic HTML

```html
<header><nav aria-label="Main navigation">...</nav></header>
<main>
  <article>
    <h1>Product Name</h1><!-- Single H1 per page -->
    <section><h2>Description</h2><p>...</p></section>
    <section><h2>Reviews</h2>...</section>
  </article>
  <aside><h2>Related Products</h2>...</aside>
</main>
<footer>...</footer>
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Title** | Unique, descriptive, 50-60 chars |
| **Meta description** | Compelling summary, 150-160 chars |
| **H1** | Single H1 per page, proper heading hierarchy |
| **Structured data** | JSON-LD for products, articles, breadcrumbs |
| **Sitemap** | Dynamic sitemap with lastModified dates |
| **Canonical** | Set canonical URL to prevent duplicates |
| **Open Graph** | OG tags for social media previews |
| **Semantic HTML** | header, main, article, section, aside, footer |
| **Core Web Vitals** | LCP < 2.5s, FID < 100ms, CLS < 0.1 |
| **Image alt** | Descriptive alt text for all images |

---

## Rules Integration
- **Meta**: Dynamic title/description/OG per page
- **Structured data**: JSON-LD for products, organization
- **Sitemap**: Auto-generated from database content
- **Performance**: Core Web Vitals optimization
- **Semantic**: Proper HTML5 elements and heading hierarchy
