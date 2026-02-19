---
name: Wix & Squarespace
description: Skill for building websites with Wix (Velo) and Squarespace, covering custom code injection, API integrations, design patterns, and e-commerce setup.
---

# Wix & Squarespace Skill

## Overview
Wix and Squarespace are no-code/low-code website builders. This skill covers customization beyond the visual editors: Wix Velo (JavaScript), Squarespace code injection, API integrations, dynamic content, and e-commerce setup.

---

## Part 1: Wix (with Velo)

### Velo Architecture
```
Wix Velo Code Structure:
├── Page Code           # Code attached to specific pages
│   ├── Home.js
│   └── Products.js
├── Site Code           # Runs on every page (masterPage.js)
├── Backend Code        # Server-side Node.js
│   ├── http-functions.js   # HTTP APIs
│   ├── data.js             # Data hooks
│   └── events.js           # Backend events
├── Public Code         # Shared utilities (client & server)
│   └── utils.js
└── packages.json       # npm packages (limited)
```

### Page Code (Client-side)
```javascript
// Home.js — Attached to homepage
import wixData from 'wix-data';
import wixWindow from 'wix-window';
import wixLocation from 'wix-location';

$w.onReady(function () {
  // Dynamic content loading
  loadFeaturedProducts();

  // Event handlers
  $w('#searchButton').onClick(() => {
    const query = $w('#searchInput').value;
    wixLocation.to(`/search?q=${encodeURIComponent(query)}`);
  });

  // Form submission
  $w('#contactForm').onWixFormSubmitted(() => {
    $w('#thankYouMessage').show();
    $w('#contactForm').hide();
  });
});

async function loadFeaturedProducts() {
  try {
    const results = await wixData.query('Products')
      .eq('featured', true)
      .limit(6)
      .descending('_createdDate')
      .find();

    $w('#productsRepeater').data = results.items;
    $w('#productsRepeater').onItemReady(($item, itemData) => {
      $item('#productTitle').text = itemData.title;
      $item('#productPrice').text = `$${itemData.price.toFixed(2)}`;
      $item('#productImage').src = itemData.image;
      $item('#productLink').link = `/product/${itemData.slug}`;
    });
  } catch (error) {
    console.error('Failed to load products:', error);
  }
}
```

### Backend Code (Server-side)
```javascript
// backend/http-functions.js — REST API endpoints
import { ok, badRequest, serverError } from 'wix-http-functions';
import wixData from 'wix-data';

// GET /api/products
export async function get_products(request) {
  try {
    const { items } = await wixData.query('Products')
      .eq('status', 'active')
      .limit(20)
      .find();

    return ok({
      headers: { 'Content-Type': 'application/json' },
      body: { products: items },
    });
  } catch (error) {
    return serverError({ body: { error: error.message } });
  }
}

// POST /api/contact
export async function post_contact(request) {
  try {
    const body = await request.body.json();
    const { name, email, message } = body;

    if (!name || !email || !message) {
      return badRequest({ body: { error: 'All fields required' } });
    }

    await wixData.insert('ContactSubmissions', {
      name, email, message,
      submittedAt: new Date(),
    });

    return ok({ body: { success: true } });
  } catch (error) {
    return serverError({ body: { error: error.message } });
  }
}
```

### Data Hooks
```javascript
// backend/data.js — Collection hooks
export function Products_beforeInsert(item, context) {
  // Auto-generate slug
  item.slug = item.title.toLowerCase().replace(/\s+/g, '-');
  item.createdBy = context.userId;
  return item;
}

export function Products_afterInsert(item, context) {
  // Send notification, trigger workflow
  console.log(`New product created: ${item.title}`);
}

export function Products_beforeUpdate(item, context) {
  item.updatedAt = new Date();
  return item;
}
```

### Wix Velo Best Practices
```javascript
// ✅ Use wixData for database operations (not direct DB access)
// ✅ Sanitize user input before saving
// ✅ Use backend functions for sensitive logic (API keys, etc.)
// ✅ Cache repeated queries with Wix Storage API
// ✅ Use $w.onReady() for all initialization code
// ✅ Suppress dataset errors for better UX

import { session } from 'wix-storage';

// Cache example
async function getCachedData(key, fetchFn, ttlMs = 300000) {
  const cached = session.getItem(key);
  if (cached) {
    const { data, expiry } = JSON.parse(cached);
    if (Date.now() < expiry) return data;
  }
  const data = await fetchFn();
  session.setItem(key, JSON.stringify({ data, expiry: Date.now() + ttlMs }));
  return data;
}
```

---

## Part 2: Squarespace

### Code Injection

#### Header Code Injection
```html
<!-- Settings → Advanced → Code Injection → Header -->

<!-- Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<!-- Custom CSS -->
<style>
  /* Global overrides */
  :root {
    --accent-color: #6366f1;
    --text-primary: #1a1a2e;
    --bg-primary: #ffffff;
  }

  /* Custom button styles */
  .sqs-block-button-element {
    border-radius: 8px !important;
    font-weight: 600 !important;
    letter-spacing: 0.025em !important;
    transition: all 0.3s ease !important;
    box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1) !important;
  }

  .sqs-block-button-element:hover {
    transform: translateY(-2px) !important;
    box-shadow: 0 10px 15px -3px rgba(0,0,0,0.15) !important;
  }

  /* Hide specific elements */
  .header-announcement-bar-wrapper { display: none !important; }

  /* Custom section styling */
  section[data-section-id] .content-wrapper {
    max-width: 1200px;
    margin: 0 auto;
  }

  /* Responsive adjustments */
  @media (max-width: 768px) {
    .sqs-block-image .image-block-outer-wrapper {
      max-width: 100% !important;
    }
  }
</style>

<!-- Meta tags for SEO -->
<meta name="robots" content="index, follow">
<meta property="og:locale" content="en_US">
```

#### Footer Code Injection
```html
<!-- Settings → Advanced → Code Injection → Footer -->

<script>
  // ✅ Custom JavaScript
  document.addEventListener('DOMContentLoaded', function() {

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function(e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
    });

    // Fade-in animation on scroll
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
        }
      });
    }, { threshold: 0.1 });

    document.querySelectorAll('.sqs-block').forEach(block => {
      block.style.opacity = '0';
      block.style.transform = 'translateY(20px)';
      block.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
      observer.observe(block);
    });

    // Dynamic copyright year
    document.querySelectorAll('.footer-block .sqs-block-html').forEach(el => {
      el.innerHTML = el.innerHTML.replace(/\{year\}/g, new Date().getFullYear());
    });
  });
</script>

<!-- Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### Page-Specific Code
```html
<!-- Page Settings → Advanced → Page Header Code Injection -->
<style>
  /* Only applies to this page */
  .page-section:first-child {
    min-height: 80vh;
    display: flex;
    align-items: center;
  }
</style>
```

### Squarespace API (Form Handling)
```javascript
// External form handling with Squarespace
// Use third-party services for advanced form processing

// Example: Send form data to webhook
document.querySelector('form').addEventListener('submit', async function(e) {
  e.preventDefault();
  const formData = new FormData(this);
  const data = Object.fromEntries(formData.entries());

  try {
    await fetch('https://hooks.example.com/webhook', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    // Show success message
  } catch (error) {
    // Show error message
  }
});
```

---

## Comparison Matrix

| Feature | Wix | Squarespace |
|---------|-----|-------------|
| **Custom Code** | Velo (full JS framework) | Code injection (HTML/CSS/JS) |
| **Backend Code** | Yes (Node.js) | No (webhooks/APIs only) |
| **Database** | Built-in CMS collections | Built-in CMS |
| **E-commerce** | Wix Stores / Velo | Squarespace Commerce |
| **Custom APIs** | Yes (http-functions) | No (third-party only) |
| **Hosting** | Included | Included |
| **Custom Domain** | Yes | Yes |
| **Export** | Limited | Limited |
| **Best For** | Interactive apps | Beautiful content sites |

## Rules Integration
- **SEO**: Both platforms have built-in SEO tools; enhance with code injection for structured data
- **UI/UX**: Custom CSS overrides for premium design beyond templates
- **Security**: Both platforms handle hosting security; focus on input validation in custom code
- **Accessibility**: Ensure custom code additions maintain WCAG AA compliance
