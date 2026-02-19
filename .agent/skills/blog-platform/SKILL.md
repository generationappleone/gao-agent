---
name: Blog Platform
description: Skill for building blog platforms — covering post management, Markdown/rich text editor, categories/tags, comments, RSS feeds, SEO optimization, author management, and content scheduling.
---

# Blog Platform — Development Guide

## Architecture Options

| Approach | Tech Stack | Best For |
|----------|-----------|----------|
| **SSG** (Static Site Gen) | Next.js/Gatsby + MDX | Developer blogs, docs |
| **SSR** (Server-Side) | Next.js/Nuxt + DB | Dynamic blogs, multi-author |
| **Traditional** | WordPress/Laravel | Content-heavy, non-technical users |
| **Headless** | Strapi/CMS + React | Multi-channel publishing |

---

## Database Schema

```sql
-- Authors
CREATE TABLE authors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    display_name VARCHAR(255) NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    website_url VARCHAR(500),
    social_links JSONB,         -- {"twitter": "...", "linkedin": "..."}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES authors(id),
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(500) NOT NULL UNIQUE,
    excerpt TEXT,                          -- preview text (max 300 chars)
    content TEXT NOT NULL,                 -- Markdown or HTML
    content_format ENUM('markdown', 'html') DEFAULT 'markdown',
    featured_image_url TEXT,
    featured_image_alt VARCHAR(500),
    status ENUM('draft', 'review', 'scheduled', 'published', 'archived') DEFAULT 'draft',
    visibility ENUM('public', 'private', 'password_protected') DEFAULT 'public',
    password_hash VARCHAR(255),           -- for password-protected posts
    is_featured BOOLEAN DEFAULT FALSE,
    is_pinned BOOLEAN DEFAULT FALSE,
    reading_time_minutes INTEGER,         -- auto-calculated
    word_count INTEGER,                   -- auto-calculated
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    published_at TIMESTAMP NULL,
    scheduled_at TIMESTAMP NULL,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    canonical_url VARCHAR(500),
    og_image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Categories (hierarchical)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7),                     -- hex color for UI badges
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tags (flat)
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Post-Category relationship
CREATE TABLE post_categories (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id),
    PRIMARY KEY (post_id, category_id)
);

-- Post-Tag relationship
CREATE TABLE post_tags (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id),
    PRIMARY KEY (post_id, tag_id)
);

-- Comments (threaded)
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES comments(id),    -- for threaded replies
    user_id UUID REFERENCES users(id),          -- null for guest comments
    author_name VARCHAR(255),                   -- for guest comments
    author_email VARCHAR(255),                  -- for guest comments
    content TEXT NOT NULL,
    status ENUM('pending', 'approved', 'spam', 'trash') DEFAULT 'pending',
    ip_address VARCHAR(45),
    user_agent TEXT,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Post views (analytics)
CREATE TABLE post_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id),
    viewer_id UUID REFERENCES users(id),
    ip_address VARCHAR(45),
    user_agent TEXT,
    referrer VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Features

### 1. Rich Text Editor
- **Markdown**: For developer blogs (MDX support for React components)
- **WYSIWYG**: For non-technical users (TipTap, Quill, CKEditor)
- **Block editor**: Modular content blocks (like Notion/WordPress Gutenberg)
- Features: code blocks with syntax highlighting, image embedding, embed (YouTube, Twitter), table support

### 2. Content Organization
- Hierarchical categories (parent → child)
- Flat tags (unlimited per post)
- Series/collections (ordered set of related posts)
- Archive by date (year/month)

### 3. SEO Features
- Auto-generated slug from title
- Custom meta title and description
- Open Graph and Twitter Card meta tags
- Canonical URL support
- Structured data (JSON-LD Article schema)
- XML sitemap generation
- Auto reading time calculation

### 4. RSS Feed
```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>Blog Title</title>
    <link>https://example.com/blog</link>
    <description>Blog description</description>
    <atom:link href="https://example.com/blog/rss.xml" rel="self" type="application/rss+xml"/>
    <item>
      <title>Post Title</title>
      <link>https://example.com/blog/post-slug</link>
      <description>Post excerpt...</description>
      <pubDate>Wed, 19 Feb 2026 12:00:00 GMT</pubDate>
      <guid>https://example.com/blog/post-slug</guid>
    </item>
  </channel>
</rss>
```

### 5. Comment System
- Threaded replies (max 3 levels deep)
- Moderation queue (auto-approve trusted users)
- Spam detection (Akismet or reCAPTCHA)
- Email notification on reply
- Guest commenting (with name/email)
- Like/reaction on comments

### 6. Content Scheduling
- Schedule posts for future publication
- Cron job or background worker to publish at scheduled time
- Draft → Scheduled → Published workflow

### 7. Search
- Full-text search on title, content, tags
- Search suggestions/autocomplete
- Filter by category, tag, date range, author

---

## API Endpoints

```
# Public
GET    /api/v1/posts?page=1&limit=10&category=tech&tag=react    — List posts
GET    /api/v1/posts/:slug                                       — Single post
GET    /api/v1/posts/:slug/comments                              — Post comments
GET    /api/v1/categories                                         — List categories
GET    /api/v1/tags                                               — List tags
GET    /api/v1/authors/:slug                                      — Author profile
GET    /api/v1/search?q=keyword                                   — Search posts
GET    /blog/rss.xml                                              — RSS feed

# Authenticated (Author)
POST   /api/v1/posts                                              — Create post
PUT    /api/v1/posts/:id                                          — Update post
DELETE /api/v1/posts/:id                                          — Delete post
POST   /api/v1/posts/:id/publish                                  — Publish
POST   /api/v1/media/upload                                       — Upload image

# Authenticated (User)
POST   /api/v1/posts/:slug/comments                               — Add comment
POST   /api/v1/posts/:slug/like                                   — Like post
```

---

## Reading Time Calculation

```javascript
function calculateReadingTime(content) {
  const wordsPerMinute = 200;
  const text = content.replace(/<[^>]*>/g, ''); // strip HTML
  const words = text.trim().split(/\s+/).length;
  return Math.ceil(words / wordsPerMinute);
}
```

## Slug Generation

```javascript
function generateSlug(title) {
  return title
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')    // remove special chars
    .replace(/\s+/g, '-')        // spaces to hyphens
    .replace(/-+/g, '-')         // collapse hyphens
    .trim();
}
```

---

## Performance Best Practices

- **SSG/ISR**: Pre-render popular posts at build time, regenerate on update
- **CDN**: Serve all pages and assets via CDN
- **Image optimization**: WebP format, responsive sizes, lazy loading
- **Caching**: Cache post listings (Redis, 5-min TTL), invalidate on publish
- **Database**: Index on slug, status, published_at, author_id, category
- **Pagination**: Cursor-based for infinite scroll, offset for page numbers
- **View counting**: Batch inserts or use analytics service (not per-request DB write)
