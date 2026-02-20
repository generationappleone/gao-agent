---
name: OpenAI API
description: Skill for integrating OpenAI API — covering chat completions, structured output, function calling, vision, embeddings, assistants API, streaming, and batch processing.
---

# OpenAI API Skill

## Overview
The OpenAI API provides access to GPT-4o, GPT-4o-mini, and other models for text generation, image understanding, embeddings, and more. It supports chat completions, structured output (JSON mode), function calling, streaming, and the Assistants API for stateful conversations.

**References**:
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [OpenAI Node.js SDK](https://www.npmjs.com/package/openai)
- [OpenAI Cookbook](https://cookbook.openai.com/)

---

## Setup

```bash
npm install openai
```

```typescript
// src/lib/openai.ts
import OpenAI from 'openai';

export const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  maxRetries: 3,
  timeout: 60000,
});
```

---

## Chat Completions

```typescript
// ── Basic completion ──
export async function generateText(prompt: string, systemPrompt?: string): Promise<string> {
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: systemPrompt || 'You are a helpful assistant.' },
      { role: 'user', content: prompt },
    ],
    temperature: 0.7,
    max_tokens: 4096,
  });

  return completion.choices[0].message.content || '';
}

// ── Multi-turn conversation ──
export async function chat(messages: Array<{ role: 'system' | 'user' | 'assistant'; content: string }>) {
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages,
    temperature: 0.7,
    max_tokens: 4096,
  });

  return {
    content: completion.choices[0].message.content || '',
    usage: completion.usage,
  };
}
```

---

## Structured Output (JSON)

```typescript
import { zodResponseFormat } from 'openai/helpers/zod';
import { z } from 'zod';

// ── Define schema with Zod ──
const ProductAnalysis = z.object({
  name: z.string().describe('Product name'),
  category: z.string().describe('Product category'),
  price: z.number().describe('Estimated price in USD'),
  features: z.array(z.string()).describe('Key features'),
  pros: z.array(z.string()).describe('Advantages'),
  cons: z.array(z.string()).describe('Disadvantages'),
  sentiment: z.enum(['positive', 'neutral', 'negative']),
  rating: z.number().min(1).max(5).describe('Rating out of 5'),
});

type ProductAnalysisType = z.infer<typeof ProductAnalysis>;

// ── Parse structured response ──
export async function analyzeProduct(description: string): Promise<ProductAnalysisType> {
  const completion = await openai.beta.chat.completions.parse({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: 'You are a product analyst. Analyze the product and return structured data.' },
      { role: 'user', content: `Analyze this product: ${description}` },
    ],
    response_format: zodResponseFormat(ProductAnalysis, 'product_analysis'),
  });

  const parsed = completion.choices[0].message.parsed;
  if (!parsed) throw new Error('Failed to parse response');
  return parsed;
}

// ── Extract multiple items ──
const ItemList = z.object({
  items: z.array(z.object({
    name: z.string(),
    category: z.string(),
    confidence: z.number().min(0).max(1),
  })),
});

export async function categorizeItems(text: string) {
  const completion = await openai.beta.chat.completions.parse({
    model: 'gpt-4o-mini',
    messages: [{ role: 'user', content: `Categorize items in: ${text}` }],
    response_format: zodResponseFormat(ItemList, 'item_list'),
  });

  return completion.choices[0].message.parsed!.items;
}
```

---

## Function Calling

```typescript
// ── Define tools ──
const tools: OpenAI.Chat.Completions.ChatCompletionTool[] = [
  {
    type: 'function',
    function: {
      name: 'getWeather',
      description: 'Get current weather for a location',
      parameters: {
        type: 'object',
        properties: {
          location: { type: 'string', description: 'City name' },
          unit: { type: 'string', enum: ['celsius', 'fahrenheit'], default: 'celsius' },
        },
        required: ['location'],
      },
    },
  },
  {
    type: 'function',
    function: {
      name: 'searchProducts',
      description: 'Search products in catalog',
      parameters: {
        type: 'object',
        properties: {
          query: { type: 'string' },
          category: { type: 'string' },
          maxPrice: { type: 'number' },
        },
        required: ['query'],
      },
    },
  },
];

// ── Execute function calling loop ──
export async function chatWithTools(message: string) {
  const messages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [
    { role: 'system', content: 'You are a helpful shopping assistant.' },
    { role: 'user', content: message },
  ];

  let response = await openai.chat.completions.create({
    model: 'gpt-4o-mini', messages, tools, tool_choice: 'auto',
  });

  // Handle tool calls iteratively
  while (response.choices[0].message.tool_calls) {
    const toolCalls = response.choices[0].message.tool_calls;
    messages.push(response.choices[0].message);

    for (const call of toolCalls) {
      const args = JSON.parse(call.function.arguments);
      let result: any;

      switch (call.function.name) {
        case 'getWeather': result = await getWeather(args); break;
        case 'searchProducts': result = await searchProducts(args); break;
        default: result = { error: 'Unknown function' };
      }

      messages.push({
        role: 'tool',
        tool_call_id: call.id,
        content: JSON.stringify(result),
      });
    }

    response = await openai.chat.completions.create({
      model: 'gpt-4o-mini', messages, tools,
    });
  }

  return response.choices[0].message.content;
}
```

---

## Vision

```typescript
// ── Analyze image ──
export async function analyzeImage(imageUrl: string, prompt: string) {
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{
      role: 'user',
      content: [
        { type: 'text', text: prompt },
        { type: 'image_url', image_url: { url: imageUrl, detail: 'auto' } },
      ],
    }],
    max_tokens: 2048,
  });

  return completion.choices[0].message.content;
}

// ── Base64 image ──
export async function analyzeBase64Image(base64: string, mimeType: string, prompt: string) {
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{
      role: 'user',
      content: [
        { type: 'text', text: prompt },
        { type: 'image_url', image_url: { url: `data:${mimeType};base64,${base64}` } },
      ],
    }],
  });

  return completion.choices[0].message.content;
}
```

---

## Streaming

```typescript
// ── Server-side streaming ──
export async function* streamChat(prompt: string, systemPrompt?: string): AsyncGenerator<string> {
  const stream = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: systemPrompt || 'You are a helpful assistant.' },
      { role: 'user', content: prompt },
    ],
    stream: true,
  });

  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content;
    if (content) yield content;
  }
}

// ── Express SSE endpoint ──
app.get('/api/ai/stream', async (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  const prompt = req.query.prompt as string;

  for await (const chunk of streamChat(prompt)) {
    res.write(`data: ${JSON.stringify({ text: chunk })}\n\n`);
  }

  res.write('data: [DONE]\n\n');
  res.end();
});
```

---

## Embeddings

```typescript
export async function generateEmbedding(text: string): Promise<number[]> {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: text,
  });
  return response.data[0].embedding;
}

export async function generateBatchEmbeddings(texts: string[]): Promise<number[][]> {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: texts,
  });
  return response.data.map(d => d.embedding);
}

// Cosine similarity
export function cosineSimilarity(a: number[], b: number[]): number {
  const dot = a.reduce((sum, val, i) => sum + val * b[i], 0);
  const magA = Math.sqrt(a.reduce((sum, val) => sum + val * val, 0));
  const magB = Math.sqrt(b.reduce((sum, val) => sum + val * val, 0));
  return dot / (magA * magB);
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Model selection** | `gpt-4o-mini` for speed/cost, `gpt-4o` for quality |
| **Structured output** | Use Zod + `zodResponseFormat` for typed JSON |
| **Function calling** | Define tools, handle iterative tool call loops |
| **Streaming** | Use SSE for real-time responses in UI |
| **Temperature** | 0.0 for deterministic, 0.7 for creative |
| **Max tokens** | Set appropriate limits to control cost |
| **Error handling** | Handle rate limits (429), timeouts, safety refusals |
| **System prompt** | Use for persona, constraints, output formatting |
| **Embeddings** | `text-embedding-3-small` for search, `3-large` for accuracy |
| **Retries** | SDK auto-retries on rate limits (configurable) |

---

## Rules Integration
- **Generation**: Chat completions with system prompts
- **Structured**: Zod schemas for typed JSON responses
- **Tools**: Function calling with iterative dispatch loop
- **Multimodal**: Vision (URL + base64 images)
- **Streaming**: AsyncGenerator for SSE endpoints
- **Embeddings**: Single/batch for semantic search and RAG
