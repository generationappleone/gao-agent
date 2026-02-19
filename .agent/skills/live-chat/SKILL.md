---
name: Live Chat
description: Skill for building live chat applications — covering real-time messaging with WebSocket, agent-customer communication, chat routing, typing indicators, file sharing, canned responses, chat history, and analytics.
---

# Live Chat — Development Guide

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐
│  Customer Widget     │     │   Agent Dashboard    │
│  (Embedded JS)       │     │   (React/Vue)        │
└──────────┬──────────┘     └──────────┬──────────┘
           │ WebSocket                  │ WebSocket
           └──────────┬────────────────┘
                      │
┌─────────────────────┴─────────────────────────┐
│              WebSocket Gateway                 │
│    Connection Mgmt · Auth · Load Balance       │
└─────────────────────┬─────────────────────────┘
                      │
┌──────────┬──────────┼──────────┬──────────────┐
│  Chat    │  Routing │ Presence │ Notification  │
│  Service │  Engine  │ Service  │ Service       │
└──────────┘──────────┘──────────┘──────────────┘
                      │
┌─────────────────────┴─────────────────────────┐
│              Data Layer                        │
│  PostgreSQL · Redis (cache/pubsub) · S3       │
└───────────────────────────────────────────────┘
```

---

## Database Schema

```sql
-- Chat conversations
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    channel ENUM('website', 'whatsapp', 'facebook', 'instagram', 'email') DEFAULT 'website',
    status ENUM('waiting', 'active', 'resolved', 'closed') DEFAULT 'waiting',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    subject VARCHAR(500),
    visitor_id UUID,                           -- for anonymous visitors
    customer_id UUID REFERENCES users(id),     -- for logged-in users
    assigned_agent_id UUID REFERENCES users(id),
    department VARCHAR(100),
    tags JSONB DEFAULT '[]',
    visitor_name VARCHAR(255),
    visitor_email VARCHAR(255),
    visitor_ip VARCHAR(45),
    visitor_user_agent TEXT,
    visitor_page_url TEXT,                     -- page where chat was initiated
    visitor_referrer TEXT,
    first_response_at TIMESTAMP NULL,
    resolved_at TIMESTAMP NULL,
    satisfaction_rating INTEGER CHECK (satisfaction_rating BETWEEN 1 AND 5),
    satisfaction_comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Chat messages
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id),
    sender_type ENUM('customer', 'agent', 'system', 'bot') NOT NULL,
    sender_id UUID,                            -- user id for agents
    content TEXT NOT NULL,
    content_type ENUM('text', 'image', 'file', 'audio', 'video', 'system', 'card') DEFAULT 'text',
    metadata JSONB,                            -- file info, card data, etc.
    is_internal BOOLEAN DEFAULT FALSE,         -- internal note (not visible to customer)
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- File attachments
CREATE TABLE chat_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    url TEXT NOT NULL,
    thumbnail_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Canned responses
CREATE TABLE canned_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shortcode VARCHAR(100) NOT NULL UNIQUE,    -- '/greeting', '/pricing'
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100),
    is_shared BOOLEAN DEFAULT TRUE,            -- shared or personal
    created_by UUID REFERENCES users(id),
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Agent availability
CREATE TABLE agent_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    status ENUM('online', 'away', 'busy', 'offline') DEFAULT 'offline',
    max_concurrent_chats INTEGER DEFAULT 5,
    active_chat_count INTEGER DEFAULT 0,
    last_activity_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## WebSocket Events

### Client → Server
```javascript
// Customer events
{ type: 'chat.start', data: { name, email, department, page_url } }
{ type: 'message.send', data: { conversation_id, content, content_type } }
{ type: 'typing.start', data: { conversation_id } }
{ type: 'typing.stop', data: { conversation_id } }
{ type: 'message.read', data: { conversation_id, message_id } }

// Agent events
{ type: 'conversation.accept', data: { conversation_id } }
{ type: 'conversation.transfer', data: { conversation_id, to_agent_id } }
{ type: 'conversation.resolve', data: { conversation_id } }
{ type: 'agent.status', data: { status: 'online|away|busy|offline' } }
```

### Server → Client
```javascript
{ type: 'conversation.created', data: { conversation } }
{ type: 'message.received', data: { message } }
{ type: 'typing.indicator', data: { conversation_id, sender_type, is_typing } }
{ type: 'agent.assigned', data: { conversation_id, agent } }
{ type: 'conversation.resolved', data: { conversation_id } }
{ type: 'queue.position', data: { position, estimated_wait } }
```

---

## Key Features

### 1. Chat Widget (Embeddable)
```html
<!-- Embed snippet for customer websites -->
<script>
  (function(w, d, s) {
    w.LiveChatConfig = {
      organizationId: 'org-uuid',
      color: '#4F46E5',
      position: 'bottom-right',
      greeting: 'Hi! How can we help you?',
      offlineMessage: 'Leave us a message!',
    };
    var js = d.createElement(s);
    js.src = 'https://chat.example.com/widget.js';
    js.async = true;
    d.head.appendChild(js);
  })(window, document, 'script');
</script>
```

### 2. Chat Routing
| Strategy | Description |
|----------|-------------|
| Round-robin | Distribute evenly among available agents |
| Least-busy | Assign to agent with fewest active chats |
| Skill-based | Route by department/expertise |
| Priority-based | VIP customers get priority routing |
| Language-based | Route by customer's language |

### 3. Pre-Chat Form
- Name (required)
- Email (optional)
- Department selector
- Initial message
- Custom fields

### 4. Agent Features
- Multi-conversation management
- Canned responses with `/shortcode`
- Internal notes (not visible to customer)
- Conversation transfer
- Customer info sidebar (history, profile)
- Typing preview (see what customer is typing)

### 5. Post-Chat
- Satisfaction survey (1-5 stars + comment)
- Chat transcript email
- Automatic tagging

---

## KPI Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| First Response Time | Time until first agent reply | < 30 seconds |
| Average Response Time | Average time between messages | < 2 minutes |
| Resolution Time | Total conversation duration | < 15 minutes |
| CSAT Score | Customer satisfaction rating | ≥ 4.0/5.0 |
| First Contact Resolution | % resolved without transfer | ≥ 80% |
| Chat Volume | Chats per hour/day | Track trend |
| Agent Utilization | Active chats / max capacity | 60-80% |
| Queue Wait Time | Time in queue before assignment | < 60 seconds |

---

## API Endpoints

```
# Conversations
GET    /api/v1/conversations                   — List (with filters)
GET    /api/v1/conversations/:id               — Detail with messages
POST   /api/v1/conversations/:id/assign        — Assign agent
POST   /api/v1/conversations/:id/transfer      — Transfer
POST   /api/v1/conversations/:id/resolve       — Resolve
POST   /api/v1/conversations/:id/rate          — Customer rating

# Messages
GET    /api/v1/conversations/:id/messages      — Message history
POST   /api/v1/conversations/:id/messages      — Send message (REST fallback)

# Agents
GET    /api/v1/agents/status                   — Agent availability
PATCH  /api/v1/agents/status                   — Update my status

# Canned Responses
GET    /api/v1/canned-responses                — List
POST   /api/v1/canned-responses                — Create

# Reports
GET    /api/v1/reports/chat-volume              — Volume metrics
GET    /api/v1/reports/agent-performance         — Agent metrics
GET    /api/v1/reports/satisfaction              — CSAT metrics
```

---

## Performance & Scalability

- **WebSocket**: Use sticky sessions or Redis pub/sub for multi-server
- **Message storage**: Partition by conversation_id and date
- **Presence**: Redis for real-time agent/visitor status
- **File uploads**: Direct-to-S3 with presigned URLs
- **Search**: Full-text search on message content for agent dashboard
- **Rate limiting**: Limit messages per second per conversation
