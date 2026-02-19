---
name: CMS Development
description: Skill for building Content Management Systems — covering headless/traditional/hybrid architectures, content modeling, RBAC, versioning, media management, API design, SEO, and editorial workflows.
---

# CMS Development — Architecture & Implementation Guide

## Architecture Types

### When to Use Which
| Type | Best For | Trade-offs |
|------|----------|------------|
| **Traditional (Coupled)** | Simple sites, blogs, small business | Easy setup, limited scalability |
| **Headless** | Multi-channel delivery, SPAs, mobile apps | Full flexibility, needs frontend dev |
| **Decoupled** | Complex sites needing preview + API | Balanced flexibility/usability |
| **Hybrid** | Enterprises needing both approaches | Most versatile, most complex |

### Headless CMS Architecture (Recommended)
```
┌──────────────────────────────────────────────────┐
│                  Admin Panel                      │
│         (Content Editor Interface)                │
└───────────────────┬──────────────────────────────┘
                    │ REST / GraphQL API
┌───────────────────┴──────────────────────────────┐
│               CMS Backend                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │
│  │ Content  │ │  Media   │ │  User/Permission │  │
│  │ Service  │ │ Service  │ │    Service       │  │
│  └──────────┘ └──────────┘ └──────────────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │
│  │ Workflow │ │  Search  │ │   Webhook        │  │
│  │ Engine   │ │ Service  │ │   Service        │  │
│  └──────────┘ └──────────┘ └──────────────────┘  │
└───────────────────┬──────────────────────────────┘
                    │ API
┌───────────────────┴──────────────────────────────┐
│              Frontend Consumers                   │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐ │
│  │  Web   │  │ Mobile │  │  IoT   │  │ Kiosk  │ │
│  │  App   │  │  App   │  │Device  │  │Display │ │
│  └────────┘  └────────┘  └────────┘  └────────┘ │
└──────────────────────────────────────────────────┘
```

---

## Content Modeling

### Core Principles
1. **Model real content types** — Articles, Products, Events — NOT "pages"
2. **Separate content from layout** — Store structure and data, NOT presentation
3. **Atomic content blocks** — Reusable, composable components
4. **COPE** (Create Once, Publish Everywhere) — Content works across all channels

### Database Schema
```sql
-- Content types (dynamic schema)
CREATE TABLE content_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,       -- 'article', 'product', 'event'
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    fields_schema JSONB NOT NULL,             -- field definitions
    is_singleton BOOLEAN DEFAULT FALSE,       -- single-instance types (settings)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Content entries
CREATE TABLE contents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type_id UUID NOT NULL REFERENCES content_types(id),
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(500) NOT NULL,
    data JSONB NOT NULL,                      -- actual content fields
    status ENUM('draft', 'review', 'scheduled', 'published', 'archived') DEFAULT 'draft',
    author_id UUID NOT NULL REFERENCES users(id),
    published_at TIMESTAMP NULL,
    scheduled_at TIMESTAMP NULL,
    locale VARCHAR(10) DEFAULT 'id',          -- i18n support
    version INTEGER DEFAULT 1,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    og_image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    UNIQUE(content_type_id, slug, locale)
);

-- Content versions (audit trail)
CREATE TABLE content_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_id UUID NOT NULL REFERENCES contents(id),
    version INTEGER NOT NULL,
    data JSONB NOT NULL,
    changed_by UUID NOT NULL REFERENCES users(id),
    change_summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Media library
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    url TEXT NOT NULL,
    alt_text VARCHAR(500),
    caption TEXT,
    width INTEGER,
    height INTEGER,
    folder VARCHAR(255) DEFAULT '/',
    uploaded_by UUID NOT NULL REFERENCES users(id),
    metadata JSONB,                           -- EXIF, custom tags
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Taxonomies (tags, categories)
CREATE TABLE taxonomies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL,                -- 'tag', 'category'
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    parent_id UUID REFERENCES taxonomies(id),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(type, slug)
);

CREATE TABLE content_taxonomies (
    content_id UUID NOT NULL REFERENCES contents(id),
    taxonomy_id UUID NOT NULL REFERENCES taxonomies(id),
    PRIMARY KEY (content_id, taxonomy_id)
);
```

### Field Type System
```json
{
  "fields": [
    { "name": "title", "type": "text", "required": true, "max_length": 255 },
    { "name": "body", "type": "richtext", "required": true },
    { "name": "excerpt", "type": "textarea", "max_length": 500 },
    { "name": "featured_image", "type": "media", "allowed_types": ["image/*"] },
    { "name": "gallery", "type": "media_gallery", "max_items": 10 },
    { "name": "author", "type": "relation", "related_type": "author" },
    { "name": "tags", "type": "taxonomy", "taxonomy_type": "tag", "multiple": true },
    { "name": "publish_date", "type": "datetime" },
    { "name": "is_featured", "type": "boolean", "default": false },
    { "name": "seo", "type": "component", "component": "seo_meta" },
    { "name": "sections", "type": "dynamic_zone", "components": ["hero", "text_block", "cta"] }
  ]
}
```

---

## Editorial Workflow

### Status Flow
```
Draft → In Review → Approved → Scheduled → Published → Archived
  ↑        │                                    │
  └────────┘ (Rejected → back to Draft)         │
  └─────────────────────────────────────────────┘ (Unpublished)
```

### Roles & Permissions (RBAC)
| Role | Create | Edit Own | Edit All | Publish | Delete | Settings |
|------|--------|----------|----------|---------|--------|----------|
| Author | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Editor | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Admin | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Super Admin | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## API Design

### REST Endpoints
```
# Content
GET    /api/v1/contents?type=article&status=published&locale=id   — List
GET    /api/v1/contents/:slug                                      — Single
POST   /api/v1/contents                                            — Create
PUT    /api/v1/contents/:id                                        — Update
DELETE /api/v1/contents/:id                                        — Soft delete
POST   /api/v1/contents/:id/publish                                — Publish
POST   /api/v1/contents/:id/unpublish                              — Unpublish

# Media
POST   /api/v1/media/upload                                        — Upload
GET    /api/v1/media                                               — List
DELETE /api/v1/media/:id                                           — Delete

# Taxonomies
GET    /api/v1/taxonomies?type=category                            — List
POST   /api/v1/taxonomies                                          — Create
```

### Webhook Events
```json
{
  "event": "content.published",
  "content_type": "article",
  "content_id": "uuid",
  "timestamp": "2026-02-19T12:00:00Z",
  "data": { ... }
}
```
Events: `content.created`, `content.updated`, `content.published`, `content.unpublished`, `content.deleted`, `media.uploaded`

---

## Performance & Caching

### Caching Strategy
```
CDN (Edge Cache)
  └── API Response Cache (Redis, 5-15 min TTL)
       └── Database Query Cache
            └── Database (PostgreSQL)
```

### Cache Invalidation
- Invalidate on content publish/unpublish
- Invalidate on taxonomy change
- Use webhook to notify CDN/frontend of changes
- Consider stale-while-revalidate pattern

### Content Delivery
- Static site generation (SSG) for high-traffic pages
- Incremental Static Regeneration (ISR) for dynamic content
- CDN for all media assets
- Image transformation on-the-fly (resize, format conversion)

---

## Security Best Practices

- **Authentication**: JWT + refresh token for API, session-based for admin
- **Authorization**: RBAC with granular permissions per content type
- **Input sanitization**: Sanitize all rich text content (prevent stored XSS)
- **Media validation**: Validate file types, scan for malware
- **Rate limiting**: On API endpoints and file uploads
- **Audit logging**: Track all content changes with who/what/when
- **Content versioning**: Never truly delete — soft delete + version history
- **CORS**: Restrict API access to known frontend domains
