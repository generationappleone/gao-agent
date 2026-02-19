---
name: Social Media Platform
description: Skill for building social media platforms — covering user profiles, feeds/timeline, posts/stories, likes/comments/shares, friend/follow system, notifications, messaging, content moderation, and newsfeed algorithms.
---

# Social Media Platform — Development Guide

## Architecture

```
┌──────────────────────────────────────────────┐
│           Frontend (React/Next.js)            │
│  Feed · Profile · Stories · Messaging · Search│
└──────────────────┬───────────────────────────┘
                   │
┌──────────────────┴───────────────────────────┐
│              API Gateway                      │
│    Auth · Rate Limit · Load Balance           │
└──────────────────┬───────────────────────────┘
                   │
┌────────┬─────────┼────────┬──────────────────┐
│ User   │  Post   │  Feed  │  Notification    │
│Service │ Service │ Service│  Service         │
└────────┘─────────┘────────┘──────────────────┘
│ Social │  Media  │  Search│  Messaging       │
│ Graph  │ Service │ Service│  Service         │
└────────┘─────────┘────────┘──────────────────┘
                   │
┌──────────────────┴───────────────────────────┐
│              Data Layer                       │
│  PostgreSQL · Redis · Elasticsearch · S3/CDN │
│  Message Queue (Kafka) · Graph DB (optional) │
└──────────────────────────────────────────────┘
```

---

## Database Schema

```sql
-- User profiles
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    username VARCHAR(30) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    cover_photo_url TEXT,
    website VARCHAR(500),
    location VARCHAR(255),
    date_of_birth DATE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT TRUE,
    follower_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    post_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Follow/Friendship system
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id),
    following_id UUID NOT NULL REFERENCES users(id),
    status ENUM('active', 'blocked', 'muted') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CHECK(follower_id != following_id)
);

-- Posts
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    content TEXT,
    post_type ENUM('text', 'image', 'video', 'link', 'poll', 'story', 'reel') DEFAULT 'text',
    visibility ENUM('public', 'followers', 'private', 'close_friends') DEFAULT 'public',
    location VARCHAR(255),
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    save_count INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_edited BOOLEAN DEFAULT FALSE,
    original_post_id UUID REFERENCES posts(id),    -- for reposts/shares
    parent_post_id UUID REFERENCES posts(id),       -- for quote tweets
    expires_at TIMESTAMP NULL,                      -- for stories
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Post media
CREATE TABLE post_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id),
    media_type ENUM('image', 'video', 'gif') NOT NULL,
    url TEXT NOT NULL,
    thumbnail_url TEXT,
    width INTEGER,
    height INTEGER,
    duration_seconds INTEGER,                       -- for videos
    alt_text VARCHAR(500),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Likes
CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    likeable_type ENUM('post', 'comment', 'story') NOT NULL,
    likeable_id UUID NOT NULL,
    reaction_type ENUM('like', 'love', 'laugh', 'wow', 'sad', 'angry') DEFAULT 'like',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, likeable_type, likeable_id)
);

-- Comments (threaded)
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id),
    user_id UUID NOT NULL REFERENCES users(id),
    parent_id UUID REFERENCES comments(id),         -- for replies
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    reply_count INTEGER DEFAULT 0,
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Hashtags
CREATE TABLE hashtags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    post_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_hashtags (
    post_id UUID NOT NULL REFERENCES posts(id),
    hashtag_id UUID NOT NULL REFERENCES hashtags(id),
    PRIMARY KEY (post_id, hashtag_id)
);

-- User mentions
CREATE TABLE mentions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES posts(id),
    comment_id UUID REFERENCES comments(id),
    mentioned_user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Saved/Bookmarks
CREATE TABLE saved_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    post_id UUID NOT NULL REFERENCES posts(id),
    collection_name VARCHAR(255) DEFAULT 'All Posts',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id)
);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    actor_id UUID NOT NULL REFERENCES users(id),
    type ENUM('like', 'comment', 'follow', 'mention', 'share', 'message', 'story_reaction') NOT NULL,
    reference_type VARCHAR(50),                     -- 'post', 'comment', 'story'
    reference_id UUID,
    content TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stories
CREATE TABLE stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    media_url TEXT NOT NULL,
    media_type ENUM('image', 'video') NOT NULL,
    duration_seconds INTEGER DEFAULT 5,
    stickers JSONB DEFAULT '[]',
    view_count INTEGER DEFAULT 0,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE story_views (
    story_id UUID NOT NULL REFERENCES stories(id),
    viewer_id UUID NOT NULL REFERENCES users(id),
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (story_id, viewer_id)
);

-- Content reports
CREATE TABLE content_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES users(id),
    content_type ENUM('post', 'comment', 'user', 'story', 'message') NOT NULL,
    content_id UUID NOT NULL,
    reason ENUM('spam', 'harassment', 'hate_speech', 'nudity', 'violence', 'misinformation', 'other') NOT NULL,
    description TEXT,
    status ENUM('pending', 'reviewed', 'actioned', 'dismissed') DEFAULT 'pending',
    reviewed_by UUID REFERENCES users(id),
    action_taken VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Features

### 1. Newsfeed Algorithm
```
Feed Generation Approaches:
  a) Pull Model — Query posts from followed users on request (simple, slow)
  b) Push Model (Fan-out) — Write post to all followers' feeds on publish (fast reads)
  c) Hybrid — Push for users with few followers, pull for celebrities

Ranking Factors:
  - Recency (time decay)
  - Engagement (likes, comments, shares)
  - Relationship strength (interaction frequency)
  - Content type preference
  - Trending/viral boost
```

### 2. Social Graph
- Follow/unfollow
- Block/mute
- Close friends list
- Mutual followers
- Friend suggestions (common connections, interests)

### 3. Content Moderation
- Automated: AI-based image/text moderation
- Manual: Report queue for human moderators
- Policies: Community guidelines enforcement
- Actions: Warning, content removal, account suspension

### 4. Messaging (DMs)
- One-on-one and group chats
- Media sharing
- Message reactions
- Read receipts
- Disappearing messages
- Message requests (from non-followers)

### 5. Discovery
- Explore page (trending content)
- Hashtag pages
- User search with suggestions
- Location-based discovery
- Topic/interest-based recommendations

---

## API Endpoints

```
# Feed
GET    /api/v1/feed                              — Personal feed
GET    /api/v1/feed/explore                      — Explore/discover

# Posts
POST   /api/v1/posts                             — Create post
GET    /api/v1/posts/:id                         — Get post
DELETE /api/v1/posts/:id                         — Delete post
POST   /api/v1/posts/:id/like                    — Like
DELETE /api/v1/posts/:id/like                    — Unlike
POST   /api/v1/posts/:id/share                   — Share/repost
POST   /api/v1/posts/:id/save                    — Bookmark
GET    /api/v1/posts/:id/comments                — Comments

# Comments
POST   /api/v1/comments                          — Create comment
DELETE /api/v1/comments/:id                      — Delete comment

# Social Graph
POST   /api/v1/users/:id/follow                  — Follow
DELETE /api/v1/users/:id/follow                  — Unfollow
POST   /api/v1/users/:id/block                   — Block
GET    /api/v1/users/:id/followers                — Followers list
GET    /api/v1/users/:id/following                — Following list

# Profile
GET    /api/v1/users/:username                   — Public profile
PUT    /api/v1/me/profile                        — Update profile

# Stories
POST   /api/v1/stories                           — Create story
GET    /api/v1/stories/feed                      — Stories feed
POST   /api/v1/stories/:id/view                  — Mark as viewed

# Search
GET    /api/v1/search?q=keyword&type=users,posts,hashtags

# Notifications
GET    /api/v1/notifications                     — My notifications
POST   /api/v1/notifications/read-all            — Mark all read

# Reports
POST   /api/v1/reports                           — Report content
```

---

## Scalability Patterns

- **CDN**: All media (images, videos) served via CDN
- **Fan-out on write**: Pre-compute feeds for active users
- **Caching**: Redis for feeds, counters, user sessions
- **Sharding**: Shard by user_id for horizontal scaling
- **Async processing**: Media upload, notification, feed generation via queues
- **Counter caching**: Denormalized like/comment counts on posts table
- **Rate limiting**: Per-user per-endpoint throttling
- **Image processing**: Resize, compress, generate thumbnails async
