---
name: Gemini AI API
description: Skill for integrating Google Gemini AI API — covering text generation, multimodal (vision, audio), structured output, function calling, streaming, embeddings, and safety settings.
---

# Gemini AI API Skill

## Overview
**Google Gemini** is a multimodal AI model family. This skill covers API integration for text generation, vision, structured output, function calling, and embeddings using the official SDK.

---

## Setup

```bash
# Python
pip install google-generativeai

# Node.js
npm install @google/generative-ai
```

```bash
# Environment variable
GEMINI_API_KEY=AIzaSy...
```

---

## Python SDK

### Text Generation
```python
import google.generativeai as genai

genai.configure(api_key=os.environ['GEMINI_API_KEY'])

model = genai.GenerativeModel('gemini-2.0-flash')

# Simple generation
response = model.generate_content("Jelaskan tentang UU PDP Indonesia")
print(response.text)

# With system instruction
model = genai.GenerativeModel(
    'gemini-2.0-flash',
    system_instruction="Kamu adalah asisten hukum Indonesia. Jawab dalam Bahasa Indonesia yang formal."
)

# With generation config
response = model.generate_content(
    "Apa itu data pribadi spesifik?",
    generation_config=genai.GenerationConfig(
        temperature=0.3,
        top_p=0.95,
        top_k=40,
        max_output_tokens=1024,
    ),
)
```

### Multimodal (Vision)
```python
import PIL.Image

model = genai.GenerativeModel('gemini-2.0-flash')

image = PIL.Image.open('receipt.jpg')
response = model.generate_content([
    "Extract all items, quantities, and prices from this receipt. Return as JSON.",
    image,
])
print(response.text)

# Multiple images
response = model.generate_content([
    "Compare these two product designs and explain the differences.",
    PIL.Image.open('design_a.png'),
    PIL.Image.open('design_b.png'),
])
```

### Structured Output
```python
import typing_extensions as typing

class Product(typing.TypedDict):
    name: str
    category: str
    price: float
    description: str

model = genai.GenerativeModel('gemini-2.0-flash')
response = model.generate_content(
    "Create a product listing for a premium batik shirt",
    generation_config=genai.GenerationConfig(
        response_mime_type="application/json",
        response_schema=Product,
    ),
)

import json
product = json.loads(response.text)
```

### Streaming
```python
response = model.generate_content("Write a long article about AI in Indonesia", stream=True)

for chunk in response:
    print(chunk.text, end='', flush=True)
```

### Chat
```python
chat = model.start_chat(history=[])
response = chat.send_message("Siapa presiden Indonesia pertama?")
print(response.text)

response = chat.send_message("Apa kontribusi terbesarnya?")
print(response.text)  # Maintains context
```

### Function Calling
```python
def get_weather(city: str) -> dict:
    """Get current weather for a city."""
    # API call to weather service
    return {"city": city, "temp": 30, "condition": "Cerah"}

model = genai.GenerativeModel(
    'gemini-2.0-flash',
    tools=[get_weather],
)

response = model.generate_content("Bagaimana cuaca di Jakarta hari ini?")
# Model will call get_weather("Jakarta") and incorporate the result
```

### Embeddings
```python
result = genai.embed_content(
    model="models/text-embedding-004",
    content="Data pribadi adalah informasi tentang individu",
    task_type="retrieval_document",
)
embedding = result['embedding']  # 768-dim vector
```

---

## Node.js SDK

```typescript
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);
const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

// Text generation
const result = await model.generateContent('Explain REST API best practices');
console.log(result.response.text());

// Streaming
const streamResult = await model.generateContentStream('Write documentation for...');
for await (const chunk of streamResult.stream) {
  process.stdout.write(chunk.text());
}

// Chat
const chat = model.startChat({ history: [] });
const response = await chat.sendMessage('Hello!');
console.log(response.response.text());
```

---

## Safety Settings

```python
from google.generativeai.types import HarmCategory, HarmBlockThreshold

model = genai.GenerativeModel(
    'gemini-2.0-flash',
    safety_settings={
        HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
    },
)
```

---

## Model Selection

| Model | Best For | Speed | Quality |
|-------|----------|-------|---------|
| `gemini-2.0-flash` | General purpose, fast | ⚡ Fast | Good |
| `gemini-2.0-flash-lite` | Cost-efficient, simple tasks | ⚡⚡ Fastest | Adequate |
| `gemini-2.5-pro` | Complex reasoning, coding | 🐢 Slower | Best |
| `gemini-2.5-flash` | Balanced performance | ⚡ Fast | Very Good |
| `text-embedding-004` | Vector embeddings, RAG | ⚡ Fast | N/A |

## Best Practices
1. **Use `gemini-2.0-flash` as default** — fast, good quality, cost-effective
2. **Structured output** for data extraction — use `response_schema`
3. **System instructions** for consistent behavior
4. **Streaming for UX** — show tokens as they generate
5. **Rate limiting** — implement retry with exponential backoff
6. **Cache responses** — for identical prompts, cache to reduce API calls
7. **Monitor costs** — track token usage per feature
