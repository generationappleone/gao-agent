---
name: MCP Server — Hugging Face
description: MCP Server for Hugging Face — enables AI assistants to browse models, datasets, spaces, run inference, and access the Hugging Face Hub for AI/ML workflows.
---

# MCP Server — Hugging Face

## Overview
Hugging Face MCP Server provides AI assistants with access to the Hugging Face Hub — the largest AI model repository — enabling model discovery, dataset exploration, inference execution, and space management.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search_models` | Search AI models by task, name, or tag |
| `get_model` | Get model details (architecture, license, metrics) |
| `search_datasets` | Search available datasets |
| `get_dataset` | Get dataset details and preview |
| `run_inference` | Run model inference via Inference API |
| `list_spaces` | List Hugging Face Spaces |
| `get_model_card` | Get model documentation |
| `list_model_files` | List files in a model repository |

## Configuration

```json
{
  "mcpServers": {
    "huggingface": {
      "command": "npx",
      "args": ["-y", "@huggingface/mcp-server"],
      "env": {
        "HF_TOKEN": "hf_..."
      }
    }
  }
}
```

## Use Cases
- AI model discovery and comparison
- Running inference on models without local setup
- Dataset exploration for ML projects
- Model card and documentation review
- Finding pre-trained models for specific tasks
- Fine-tuning workflow guidance
