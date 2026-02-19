---
name: OpenAI API
description: Skill for integrating OpenAI API — covering chat completions, structured output, function calling, vision, embeddings, assistants API, streaming, and batch processing.
---

# OpenAI API Skill

## Overview
**OpenAI API** provides access to GPT-4o, GPT-4o-mini, o1, DALL-E, Whisper, and embedding models. This skill covers API integration patterns for chat, vision, structured output, function calling, and assistants.

---

## Setup

```bash
# Python
pip install openai

# Node.js
npm install openai
```

```bash
# Environment variable
OPENAI_API_KEY=sk-...
```

---

## Python SDK

### Chat Completion
```python
from openai import OpenAI

client = OpenAI()  # Reads OPENAI_API_KEY from env

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": "You are a helpful assistant. Respond in Bahasa Indonesia."},
        {"role": "user", "content": "Jelaskan tentang UU PDP Indonesia"},
    ],
    temperature=0.3,
    max_tokens=1024,
)

print(response.choices[0].message.content)
```

### Structured Output (Recommended)
```python
from pydantic import BaseModel

class ProductAnalysis(BaseModel):
    name: str
    category: str
    sentiment: str  # positive, negative, neutral
    key_features: list[str]
    price_range: str
    recommendation: str

response = client.beta.chat.completions.parse(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": "Analyze the product review and extract structured data."},
        {"role": "user", "content": review_text},
    ],
    response_format=ProductAnalysis,
)

result: ProductAnalysis = response.choices[0].message.parsed
print(f"Sentiment: {result.sentiment}")
print(f"Features: {result.key_features}")
```

### Vision (Image Analysis)
```python
import base64

def encode_image(image_path: str) -> str:
    with open(image_path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "Extract all text from this receipt image as JSON"},
            {"type": "image_url", "image_url": {
                "url": f"data:image/jpeg;base64,{encode_image('receipt.jpg')}",
                "detail": "high",
            }},
        ],
    }],
)
```

### Function Calling (Tool Use)
```python
import json

tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "city": {"type": "string", "description": "City name"},
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
                "required": ["city"],
            },
        },
    },
]

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "What's the weather in Jakarta?"}],
    tools=tools,
    tool_choice="auto",
)

# Handle tool calls
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    args = json.loads(tool_call.function.arguments)
    result = get_weather(**args)  # Your function
    
    # Send result back
    follow_up = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "user", "content": "What's the weather in Jakarta?"},
            response.choices[0].message,
            {"role": "tool", "tool_call_id": tool_call.id, "content": json.dumps(result)},
        ],
    )
```

### Streaming
```python
stream = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Write an article about AI"}],
    stream=True,
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end='', flush=True)
```

### Embeddings
```python
response = client.embeddings.create(
    model="text-embedding-3-small",
    input="Data pribadi adalah informasi tentang individu",
)
embedding = response.data[0].embedding  # 1536-dim vector
```

---

## Node.js SDK

```typescript
import OpenAI from 'openai';

const openai = new OpenAI();  // Reads OPENAI_API_KEY

// Chat completion
const completion = await openai.chat.completions.create({
  model: 'gpt-4o-mini',
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' },
    { role: 'user', content: 'Hello!' },
  ],
});

console.log(completion.choices[0].message.content);

// Streaming
const stream = await openai.chat.completions.create({
  model: 'gpt-4o-mini',
  messages: [{ role: 'user', content: 'Write a poem' }],
  stream: true,
});

for await (const chunk of stream) {
  process.stdout.write(chunk.choices[0]?.delta?.content || '');
}

// Structured output with Zod
import { zodResponseFormat } from 'openai/helpers/zod';
import { z } from 'zod';

const ProductSchema = z.object({
  name: z.string(),
  category: z.string(),
  price: z.number(),
});

const result = await openai.beta.chat.completions.parse({
  model: 'gpt-4o-mini',
  messages: [{ role: 'user', content: 'Generate a product' }],
  response_format: zodResponseFormat(ProductSchema, 'product'),
});
```

---

## Model Selection

| Model | Best For | Cost | Speed |
|-------|----------|------|-------|
| `gpt-4o-mini` | General purpose, cost-efficient | $ | ⚡ Fast |
| `gpt-4o` | Complex reasoning, multimodal | $$$ | Medium |
| `o1` | Deep reasoning, math, code | $$$$ | 🐢 Slow |
| `o3-mini` | Reasoning, balanced | $$ | Medium |
| `text-embedding-3-small` | Embeddings, RAG | $ | ⚡ Fast |
| `text-embedding-3-large` | High-quality embeddings | $$ | Fast |

## Best Practices
1. **Use `gpt-4o-mini` as default** — 90% of tasks, lowest cost
2. **Structured output** for reliability — Pydantic/Zod schemas
3. **System message** for consistent behavior
4. **Streaming for UX** — show response as it generates
5. **Retry with backoff** — handle rate limits (429)
6. **Cache identical requests** — reduce API costs
7. **Monitor token usage** — track costs per feature
8. **Never expose API key in frontend** — always proxy through backend
