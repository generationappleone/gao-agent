---
name: Gemini AI API
description: Skill for integrating Google Gemini AI API — covering text generation, multimodal (vision, audio), structured output, function calling, streaming, embeddings, and safety settings.
---

# Gemini AI API Skill

## Overview
Google Gemini is a family of multimodal AI models that can process text, images, audio, and video. The Gemini API provides text generation, structured output, function calling, embeddings, and streaming. Gemini 2.0 Flash is the recommended model for most use cases.

**References**:
- [Gemini API Documentation](https://ai.google.dev/gemini-api/docs)
- [Google AI SDK for JavaScript](https://www.npmjs.com/package/@google/generative-ai)
- [Gemini API Cookbook](https://github.com/google-gemini/cookbook)

---

## Setup

```bash
npm install @google/generative-ai
```

```typescript
// src/lib/gemini.ts
import { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

// Default model
export const gemini = genAI.getGenerativeModel({
  model: 'gemini-2.0-flash',
  generationConfig: {
    temperature: 0.7,
    topP: 0.95,
    topK: 40,
    maxOutputTokens: 8192,
  },
  safetySettings: [
    { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
    { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
    { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
    { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
  ],
});

export { genAI };
```

---

## Text Generation

```typescript
// ── Simple generation ──
export async function generateText(prompt: string): Promise<string> {
  const result = await gemini.generateContent(prompt);
  return result.response.text();
}

// ── With system instruction ──
export async function generateWithSystem(systemPrompt: string, userPrompt: string): Promise<string> {
  const model = genAI.getGenerativeModel({
    model: 'gemini-2.0-flash',
    systemInstruction: systemPrompt,
  });

  const result = await model.generateContent(userPrompt);
  return result.response.text();
}

// Usage
const summary = await generateWithSystem(
  'You are a helpful assistant that summarizes text concisely.',
  'Summarize this article: ...'
);
```

---

## Structured Output (JSON)

```typescript
import { SchemaType } from '@google/generative-ai';

// ── Extract structured data ──
export async function extractProductInfo(description: string) {
  const model = genAI.getGenerativeModel({
    model: 'gemini-2.0-flash',
    generationConfig: {
      responseMimeType: 'application/json',
      responseSchema: {
        type: SchemaType.OBJECT,
        properties: {
          name: { type: SchemaType.STRING, description: 'Product name' },
          category: { type: SchemaType.STRING, description: 'Product category' },
          price: { type: SchemaType.NUMBER, description: 'Price in USD' },
          features: {
            type: SchemaType.ARRAY,
            items: { type: SchemaType.STRING },
            description: 'Key features',
          },
          sentiment: {
            type: SchemaType.STRING,
            enum: ['positive', 'neutral', 'negative'],
            description: 'Overall sentiment',
          },
        },
        required: ['name', 'category', 'price', 'features', 'sentiment'],
      },
    },
  });

  const result = await model.generateContent(`Extract product info from: ${description}`);
  return JSON.parse(result.response.text());
}

// ── Analyze array of items ──
export async function categorizeItems(items: string[]) {
  const model = genAI.getGenerativeModel({
    model: 'gemini-2.0-flash',
    generationConfig: {
      responseMimeType: 'application/json',
      responseSchema: {
        type: SchemaType.ARRAY,
        items: {
          type: SchemaType.OBJECT,
          properties: {
            item: { type: SchemaType.STRING },
            category: { type: SchemaType.STRING },
            confidence: { type: SchemaType.NUMBER },
          },
        },
      },
    },
  });

  const result = await model.generateContent(`Categorize these items: ${items.join(', ')}`);
  return JSON.parse(result.response.text());
}
```

---

## Multimodal (Vision)

```typescript
import fs from 'fs';

// ── Analyze image ──
export async function analyzeImage(imagePath: string, prompt: string) {
  const imageData = fs.readFileSync(imagePath);
  const base64 = imageData.toString('base64');
  const mimeType = imagePath.endsWith('.png') ? 'image/png' : 'image/jpeg';

  const result = await gemini.generateContent([
    { text: prompt },
    { inlineData: { data: base64, mimeType } },
  ]);

  return result.response.text();
}

// ── Analyze image from URL ──
export async function analyzeImageUrl(imageUrl: string, prompt: string) {
  const response = await fetch(imageUrl);
  const buffer = await response.arrayBuffer();
  const base64 = Buffer.from(buffer).toString('base64');

  const result = await gemini.generateContent([
    { text: prompt },
    { inlineData: { data: base64, mimeType: 'image/jpeg' } },
  ]);

  return result.response.text();
}

// Usage
const description = await analyzeImage('./product.jpg', 'Describe this product in detail for an e-commerce listing.');
```

---

## Function Calling

```typescript
// ── Define tools ──
const tools = [{
  functionDeclarations: [
    {
      name: 'getWeather',
      description: 'Get current weather for a location',
      parameters: {
        type: SchemaType.OBJECT,
        properties: {
          location: { type: SchemaType.STRING, description: 'City name' },
          unit: { type: SchemaType.STRING, enum: ['celsius', 'fahrenheit'] },
        },
        required: ['location'],
      },
    },
    {
      name: 'searchProducts',
      description: 'Search products in the catalog',
      parameters: {
        type: SchemaType.OBJECT,
        properties: {
          query: { type: SchemaType.STRING },
          category: { type: SchemaType.STRING },
          maxPrice: { type: SchemaType.NUMBER },
        },
        required: ['query'],
      },
    },
  ],
}];

// ── Use function calling ──
export async function chatWithTools(message: string) {
  const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash', tools });
  const chat = model.startChat();

  const result = await chat.sendMessage(message);
  const response = result.response;

  // Check for function calls
  const functionCalls = response.functionCalls();
  if (functionCalls) {
    const results = await Promise.all(functionCalls.map(async (fc) => {
      switch (fc.name) {
        case 'getWeather': return { name: fc.name, response: await getWeather(fc.args as any) };
        case 'searchProducts': return { name: fc.name, response: await searchProducts(fc.args as any) };
        default: return { name: fc.name, response: { error: 'Unknown function' } };
      }
    }));

    // Send function results back
    const finalResult = await chat.sendMessage(
      results.map(r => ({ functionResponse: { name: r.name, response: r.response } }))
    );

    return finalResult.response.text();
  }

  return response.text();
}
```

---

## Streaming

```typescript
// ── Server-side streaming ──
export async function* streamGenerate(prompt: string): AsyncGenerator<string> {
  const result = await gemini.generateContentStream(prompt);

  for await (const chunk of result.stream) {
    const text = chunk.text();
    if (text) yield text;
  }
}

// ── Express SSE endpoint ──
app.get('/api/ai/stream', async (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  const prompt = req.query.prompt as string;

  for await (const chunk of streamGenerate(prompt)) {
    res.write(`data: ${JSON.stringify({ text: chunk })}\n\n`);
  }

  res.write('data: [DONE]\n\n');
  res.end();
});
```

---

## Chat (Multi-turn)

```typescript
export async function createChat(systemInstruction?: string) {
  const model = genAI.getGenerativeModel({
    model: 'gemini-2.0-flash',
    systemInstruction: systemInstruction || 'You are a helpful assistant.',
  });

  const chat = model.startChat({
    history: [],
    generationConfig: { maxOutputTokens: 4096, temperature: 0.7 },
  });

  return {
    send: async (message: string) => {
      const result = await chat.sendMessage(message);
      return result.response.text();
    },
    stream: async function* (message: string) {
      const result = await chat.sendMessageStream(message);
      for await (const chunk of result.stream) {
        yield chunk.text();
      }
    },
  };
}
```

---

## Embeddings

```typescript
export async function generateEmbedding(text: string): Promise<number[]> {
  const model = genAI.getGenerativeModel({ model: 'text-embedding-004' });
  const result = await model.embedContent(text);
  return result.embedding.values;
}

export async function generateBatchEmbeddings(texts: string[]): Promise<number[][]> {
  const model = genAI.getGenerativeModel({ model: 'text-embedding-004' });
  const result = await model.batchEmbedContents({
    requests: texts.map(text => ({ content: { parts: [{ text }], role: 'user' } })),
  });
  return result.embeddings.map(e => e.values);
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Model selection** | `gemini-2.0-flash` for speed, `gemini-2.0-pro` for quality |
| **Structured output** | Use `responseSchema` for reliable JSON extraction |
| **System instruction** | Set context and behavior at model level |
| **Safety settings** | Configure harm thresholds per use case |
| **Streaming** | Use `generateContentStream` for real-time responses |
| **Function calling** | Define tools for grounding AI with real data |
| **Error handling** | Handle rate limits, safety blocks, quota errors |
| **Temperature** | 0.0-0.3 for factual, 0.7-1.0 for creative |
| **Token limits** | Monitor input/output tokens for cost control |
| **Embeddings** | Use `text-embedding-004` for semantic search/RAG |

---

## Rules Integration
- **Generation**: Text, structured JSON, multimodal (vision)
- **Interaction**: Chat (multi-turn), function calling, streaming
- **Embeddings**: Single and batch for search/RAG pipelines
- **Safety**: Configurable harm thresholds per category
- **Output**: JSON schema for structured, typed responses
