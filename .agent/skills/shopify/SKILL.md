---
name: Shopify
description: Skill for Shopify development, covering Liquid templating, theme development, Shopify CLI, Storefront API, custom sections, app development, and Hydrogen (headless).
---

# Shopify Skill

## Overview
Shopify is an e-commerce platform powering millions of stores. This skill covers theme development with Liquid, Storefront API, custom sections, app creation, and Hydrogen headless commerce.

## Theme Structure (Online Store 2.0)
```
my-theme/
├── assets/                  # CSS, JS, images
│   ├── base.css
│   └── theme.js
├── config/
│   └── settings_schema.json # Theme settings definition
├── layout/
│   ├── theme.liquid         # Main layout
│   └── password.liquid      # Password page layout
├── locales/
│   └── en.default.json      # Translations
├── sections/                # Reusable page sections
│   ├── header.liquid
│   ├── footer.liquid
│   ├── hero-banner.liquid
│   ├── featured-products.liquid
│   └── newsletter.liquid
├── snippets/                # Reusable partials
│   ├── product-card.liquid
│   ├── price.liquid
│   └── icon-cart.liquid
├── templates/               # Page templates (JSON for OS 2.0)
│   ├── index.json           # Homepage
│   ├── product.json         # Product page
│   ├── collection.json      # Collection page
│   ├── cart.json            # Cart page
│   └── page.json            # Generic page
└── templates/customers/
    ├── login.liquid
    └── account.liquid
```

## Liquid Templating

### Layout (theme.liquid)
```liquid
<!DOCTYPE html>
<html lang="{{ request.locale.iso_code }}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{ page_title }}{% unless page_title contains shop.name %} — {{ shop.name }}{% endunless %}</title>
  <meta name="description" content="{{ page_description | escape }}">
  <link rel="canonical" href="{{ canonical_url }}">

  {{ 'base.css' | asset_url | stylesheet_tag }}
  {{ content_for_header }}
</head>
<body>
  {% sections 'header-group' %}
  <main id="MainContent" role="main">
    {{ content_for_layout }}
  </main>
  {% sections 'footer-group' %}

  {{ 'theme.js' | asset_url | script_tag }}
</body>
</html>
```

### Section (hero-banner.liquid)
```liquid
{% comment %} sections/hero-banner.liquid {% endcomment %}
<section class="hero-banner" style="background-image: url('{{ section.settings.image | image_url: width: 1920 }}')">
  <div class="hero-content">
    {% if section.settings.heading != blank %}
      <h1 class="hero-title">{{ section.settings.heading }}</h1>
    {% endif %}

    {% if section.settings.subheading != blank %}
      <p class="hero-subtitle">{{ section.settings.subheading }}</p>
    {% endif %}

    {% if section.settings.button_text != blank %}
      <a href="{{ section.settings.button_link }}" class="btn btn-primary">
        {{ section.settings.button_text }}
      </a>
    {% endif %}
  </div>
</section>

{% schema %}
{
  "name": "Hero Banner",
  "tag": "section",
  "class": "hero-section",
  "settings": [
    {
      "type": "image_picker",
      "id": "image",
      "label": "Background Image"
    },
    {
      "type": "text",
      "id": "heading",
      "label": "Heading",
      "default": "Welcome to our store"
    },
    {
      "type": "richtext",
      "id": "subheading",
      "label": "Subheading"
    },
    {
      "type": "text",
      "id": "button_text",
      "label": "Button Text",
      "default": "Shop Now"
    },
    {
      "type": "url",
      "id": "button_link",
      "label": "Button Link"
    }
  ],
  "presets": [
    {
      "name": "Hero Banner"
    }
  ]
}
{% endschema %}
```

### Product Card Snippet
```liquid
{% comment %} snippets/product-card.liquid {% endcomment %}
<div class="product-card">
  <a href="{{ product.url }}">
    {% if product.featured_image %}
      {{ product.featured_image | image_url: width: 400 | image_tag:
        class: 'product-card__image',
        loading: 'lazy',
        widths: '200, 400, 600'
      }}
    {% endif %}

    <div class="product-card__info">
      <h3 class="product-card__title">{{ product.title }}</h3>
      <p class="product-card__price">{{ product.price | money }}</p>

      {% if product.compare_at_price > product.price %}
        <s class="product-card__compare-price">{{ product.compare_at_price | money }}</s>
        <span class="product-card__badge">Sale</span>
      {% endif %}
    </div>
  </a>

  {% if product.available %}
    <form method="post" action="/cart/add">
      <input type="hidden" name="id" value="{{ product.variants.first.id }}">
      <button type="submit" class="btn btn-add-to-cart">Add to Cart</button>
    </form>
  {% else %}
    <button class="btn btn-sold-out" disabled>Sold Out</button>
  {% endif %}
</div>
```

## Storefront API (Headless)
```graphql
# GraphQL query for products
query Products($first: Int!) {
  products(first: $first) {
    edges {
      node {
        id
        title
        handle
        description
        priceRange {
          minVariantPrice {
            amount
            currencyCode
          }
        }
        images(first: 1) {
          edges {
            node {
              url
              altText
            }
          }
        }
        variants(first: 5) {
          edges {
            node {
              id
              title
              priceV2 { amount currencyCode }
              availableForSale
            }
          }
        }
      }
    }
  }
}
```

## Shopify CLI
```bash
# Install Shopify CLI
npm install -g @shopify/cli @shopify/theme

# Theme development
shopify theme init                    # Create new theme
shopify theme dev --store=mystore     # Live development (hot reload)
shopify theme push                    # Deploy theme
shopify theme pull                    # Download theme

# App development
shopify app init                      # Create new app
shopify app dev                       # Start dev server
shopify app deploy                    # Deploy app
```

## Key Liquid Filters
```liquid
{{ product.price | money }}                           → $19.99
{{ product.title | upcase }}                          → MY PRODUCT
{{ product.description | strip_html | truncate: 100 }} → First 100 chars...
{{ 'now' | date: '%Y-%m-%d' }}                        → 2026-02-19
{{ product.images[0] | image_url: width: 800 }}       → Optimized image URL
{{ 'cart' | routes.cart_url }}                         → /cart
{{ product.title | handleize }}                       → my-product-title
```

## Rules Integration
- **SEO**: Canonical URLs, meta tags, structured data (JSON-LD built into Shopify)
- **Security**: CSRF via form tokens, Content Security Policy in theme
- **UI/UX**: Responsive images with `image_url`, lazy loading, accessible markup
- **Performance**: Section rendering, lazy loading, CDN-served assets
