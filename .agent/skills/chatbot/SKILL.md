---
name: Chatbot Development
description: Skill for building chatbots — covering rule-based and AI/NLP chatbots, intent recognition, dialog management, conversation flows, LLM integration, multi-channel deployment, human handoff, and analytics.
---

# Chatbot Development — Architecture & Implementation Guide

## Chatbot Types

| Type | Technology | Best For | Complexity |
|------|-----------|----------|------------|
| **Rule-Based** | Decision trees, keyword matching | FAQ, simple workflows | Low |
| **NLP/Intent-Based** | Intent classification + entities | Customer service, booking | Medium |
| **LLM-Powered** | GPT/Gemini + RAG | Complex conversations, knowledge base | High |
| **Hybrid** | Rules + AI fallback | Best of both worlds | Medium-High |

---

## Architecture

### LLM-Powered Chatbot (Recommended)
```
┌─────────────────────────────────────────────────┐
│               Chat Channels                      │
│  Website · WhatsApp · FB Messenger · Telegram    │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Channel Gateway                     │
│       Normalize messages across channels         │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│           Conversation Engine                    │
│  ┌──────────┐ ┌──────────┐ ┌────────────────┐   │
│  │  NLU     │ │  Dialog  │ │  Response      │   │
│  │  Engine  │ │  Manager │ │  Generator     │   │
│  └──────────┘ └──────────┘ └────────────────┘   │
│  ┌──────────┐ ┌──────────┐ ┌────────────────┐   │
│  │ Context  │ │  Action  │ │  Human         │   │
│  │ Manager  │ │  Handler │ │  Handoff       │   │
│  └──────────┘ └──────────┘ └────────────────┘   │
└───────────────────┬─────────────────────────────┘
                    │
┌──────────┬────────┼────────┬────────────────────┐
│ Knowledge│  LLM   │  CRM   │  External          │
│ Base/RAG │  API   │ System │  Services           │
└──────────┘────────┘────────┘────────────────────┘
```

---

## Database Schema

```sql
-- Bot configurations
CREATE TABLE chatbots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    personality TEXT,                          -- system prompt / persona
    language VARCHAR(10) DEFAULT 'id',
    model_provider ENUM('openai', 'gemini', 'anthropic', 'custom') DEFAULT 'openai',
    model_name VARCHAR(100) DEFAULT 'gpt-4o-mini',
    temperature DECIMAL(3,2) DEFAULT 0.7,
    max_tokens INTEGER DEFAULT 1000,
    welcome_message TEXT,
    fallback_message TEXT DEFAULT 'Sorry, I don''t understand. Could you rephrase that?',
    handoff_message TEXT DEFAULT 'I will connect you with one of our agents.',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Intents (for rule-based/NLP)
CREATE TABLE intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chatbot_id UUID NOT NULL REFERENCES chatbots(id),
    name VARCHAR(100) NOT NULL,               -- 'greeting', 'order_status', 'refund'
    description TEXT,
    priority INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(chatbot_id, name)
);

-- Training phrases (for intent classification)
CREATE TABLE training_phrases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    intent_id UUID NOT NULL REFERENCES intents(id),
    phrase TEXT NOT NULL,
    language VARCHAR(10) DEFAULT 'id',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Intent responses
CREATE TABLE intent_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    intent_id UUID NOT NULL REFERENCES intents(id),
    response_type ENUM('text', 'buttons', 'carousel', 'image', 'quick_reply', 'action') DEFAULT 'text',
    content JSONB NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conversation flows (dialog trees)
CREATE TABLE conversation_flows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chatbot_id UUID NOT NULL REFERENCES chatbots(id),
    name VARCHAR(255) NOT NULL,
    trigger_intent VARCHAR(100),
    flow_data JSONB NOT NULL,                 -- node-based flow definition
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chat sessions
CREATE TABLE chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chatbot_id UUID NOT NULL REFERENCES chatbots(id),
    channel ENUM('website', 'whatsapp', 'telegram', 'facebook', 'api') NOT NULL,
    visitor_id VARCHAR(255),
    user_id UUID REFERENCES users(id),
    context JSONB DEFAULT '{}',               -- conversation context/variables
    current_flow_id UUID REFERENCES conversation_flows(id),
    current_node_id VARCHAR(100),
    status ENUM('active', 'handoff', 'closed') DEFAULT 'active',
    handoff_agent_id UUID REFERENCES users(id),
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chat messages
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES chat_sessions(id),
    role ENUM('user', 'assistant', 'system') NOT NULL,
    content TEXT NOT NULL,
    content_type ENUM('text', 'image', 'file', 'buttons', 'carousel') DEFAULT 'text',
    metadata JSONB,
    intent_detected VARCHAR(100),
    confidence_score DECIMAL(5,4),
    tokens_used INTEGER,
    response_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Knowledge base documents (for RAG)
CREATE TABLE knowledge_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chatbot_id UUID NOT NULL REFERENCES chatbots(id),
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    source_url VARCHAR(500),
    chunk_index INTEGER DEFAULT 0,
    embedding VECTOR(1536),                   -- for pgvector
    metadata JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Features

### 1. Natural Language Understanding (NLU)
```javascript
// Intent classification pipeline
async function processMessage(message, session) {
  // 1. Preprocess
  const cleaned = preprocessText(message);

  // 2. Check active flow (priority over intent)
  if (session.current_flow_id) {
    return await continueFlow(session, message);
  }

  // 3. Intent classification
  const intent = await classifyIntent(cleaned);

  // 4. Entity extraction
  const entities = await extractEntities(cleaned);
  // e.g., { order_id: "ORD-123", product: "laptop" }

  // 5. Generate response
  if (intent.confidence > 0.8) {
    return await handleIntent(intent, entities, session);
  }

  // 6. Fallback to LLM
  return await generateLLMResponse(message, session);
}
```

### 2. Context Management
```javascript
// Session context tracks conversation state
const context = {
  user_name: "Budi",
  order_id: "ORD-20260219-001",
  current_topic: "order_tracking",
  previous_intents: ["greeting", "order_status"],
  variables: { ... },
  turn_count: 5,
};
```

### 3. Conversation Flow Builder
```json
{
  "flow": "order_tracking",
  "nodes": [
    {
      "id": "ask_order_id",
      "type": "question",
      "message": "Could I have your order number, please?",
      "variable": "order_id",
      "validation": "^ORD-\\d{8}-\\d{3}$",
      "on_invalid": "Order number format: ORD-XXXXXXXX-XXX",
      "next": "lookup_order"
    },
    {
      "id": "lookup_order",
      "type": "action",
      "action": "api_call",
      "endpoint": "/api/orders/{order_id}",
      "on_success": "show_status",
      "on_failure": "order_not_found"
    },
    {
      "id": "show_status",
      "type": "response",
      "message": "Order {order_id} is currently in status: {order_status}",
      "next": "ask_more_help"
    }
  ]
}
```

### 4. Rich Message Types
```json
// Buttons
{
  "type": "buttons",
  "text": "How can I help you?",
  "buttons": [
    { "label": "Check Order Status", "value": "order_status" },
    { "label": "Request a Refund", "value": "refund" },
    { "label": "Talk to an Agent", "value": "human_handoff" }
  ]
}

// Carousel
{
  "type": "carousel",
  "items": [
    {
      "title": "Basic Plan",
      "subtitle": "$9.99/month",
      "image": "https://...",
      "buttons": [{ "label": "Select", "value": "select_basic" }]
    }
  ]
}

// Quick replies
{
  "type": "quick_reply",
  "text": "Has the issue been resolved?",
  "replies": ["Yes, thank you", "Not yet, I need more help"]
}
```

### 5. Human Handoff
```
Bot detects handoff trigger:
  - User says "talk to an agent" / "speak to human"
  - Confidence below threshold (< 0.3) for 3 consecutive turns
  - Sentiment is very negative
  - Complex issue detected (refund, complaint)

Flow:
  Bot → "I will connect you with one of our agents."
  → Check agent availability
  → If available: Transfer to live chat (with conversation history)
  → If unavailable: Collect contact info, create support ticket
```

### 6. RAG (Retrieval-Augmented Generation)
```javascript
async function generateRAGResponse(query, session) {
  // 1. Generate embedding for query
  const queryEmbedding = await embedText(query);

  // 2. Search knowledge base (vector similarity)
  const relevantDocs = await db.query(
    `SELECT content, title FROM knowledge_documents
     WHERE chatbot_id = $1
     ORDER BY embedding <-> $2
     LIMIT 5`,
    [session.chatbot_id, queryEmbedding]
  );

  // 3. Build prompt with context
  const prompt = buildRAGPrompt(query, relevantDocs, session.context);

  // 4. Generate response with LLM
  const response = await llm.generate(prompt);

  return response;
}
```

---

## API Endpoints

```
# Bot Management
GET    /api/v1/chatbots                  — List bots
POST   /api/v1/chatbots                  — Create bot
PUT    /api/v1/chatbots/:id              — Update bot config

# Intents & Training
GET    /api/v1/chatbots/:id/intents      — List intents
POST   /api/v1/chatbots/:id/intents      — Create intent
POST   /api/v1/chatbots/:id/train        — Train model

# Knowledge Base
POST   /api/v1/chatbots/:id/knowledge    — Upload document
DELETE /api/v1/chatbots/:id/knowledge/:docId — Remove document

# Chat (Public)
POST   /api/v1/chat/start                — Start session
POST   /api/v1/chat/message              — Send message
POST   /api/v1/chat/end                  — End session

# Analytics
GET    /api/v1/chatbots/:id/analytics    — Bot performance
GET    /api/v1/chatbots/:id/conversations — Conversation logs
```

---

## Best Practices

- **Personality**: Define a clear bot persona (name, tone, language style)
- **Transparency**: Always disclose it's a bot, not a human
- **Fallback**: Graceful fallback when bot doesn't understand
- **Escalation**: Easy path to human agent
- **Testing**: Test with real user queries, not just training data
- **Analytics**: Track intent accuracy, handoff rate, satisfaction
- **Continuous improvement**: Review failed conversations weekly
- **Multi-language**: Support Bahasa Indonesia and English at minimum
