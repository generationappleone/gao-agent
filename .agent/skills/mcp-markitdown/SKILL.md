---
name: MCP Server — MarkItDown
description: MCP Server for MarkItDown — converts documents (PDF, DOCX, PPTX, XLSX, images, audio, HTML, ZIP) to structured, AI-optimized Markdown using Microsoft's MarkItDown library.
---

# MCP Server — MarkItDown

## Overview
MarkItDown MCP Server converts 29+ file formats into structured, AI-optimized Markdown. Built on Microsoft's MarkItDown library, it enables LLMs to process documents, images, audio, and archives through a standardized MCP interface.

## Tools Provided

| Tool | Description |
|------|-------------|
| `convert_to_markdown` | Convert a file (URI) to Markdown. Accepts `http://`, `https://`, `file://`, and `data:` URIs |

## Supported File Formats

| Category | Formats |
|----------|---------|
| **Office Documents** | PDF, DOCX, PPTX, XLSX, XLS |
| **Images** | PNG, JPG, JPEG, GIF, BMP, TIFF, WEBP |
| **Audio** | MP3, WAV, OGG, FLAC |
| **Web** | HTML, XML, RSS |
| **Data** | CSV, JSON, YAML |
| **Archives** | ZIP (recursive processing of contents) |
| **Code** | Source files with syntax highlighting |
| **Other** | Plain text, EPub |

## Configuration

```json
{
  "mcpServers": {
    "markitdown": {
      "command": "npx",
      "args": ["-y", "@microsoft/markitdown-mcp"],
      "env": {}
    }
  }
}
```

### With Azure Document Intelligence (Enhanced PDF)
```json
{
  "mcpServers": {
    "markitdown": {
      "command": "npx",
      "args": ["-y", "@microsoft/markitdown-mcp"],
      "env": {
        "AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT": "https://your-endpoint.cognitiveservices.azure.com/",
        "AZURE_DOCUMENT_INTELLIGENCE_KEY": "your-key"
      }
    }
  }
}
```

### With OpenAI (Image Descriptions)
```json
{
  "mcpServers": {
    "markitdown": {
      "command": "npx",
      "args": ["-y", "@microsoft/markitdown-mcp"],
      "env": {
        "OPENAI_API_KEY": "sk-...",
        "OPENAI_MODEL": "gpt-4o-mini"
      }
    }
  }
}
```

## Advanced Features
- **OCR**: Extracts text from images
- **Audio transcription**: Transcribes speech from audio files
- **LLM-powered image descriptions**: Generates alt-text from images (with OpenAI)
- **EXIF metadata extraction**: Reads image metadata
- **Enhanced PDF processing**: Superior table/layout extraction (with Azure Document Intelligence)
- **Recursive ZIP**: Processes all files within archives

## Use Cases
- Document ingestion for RAG pipelines
- Converting legacy documents for AI analysis
- Extracting structured data from PDFs/spreadsheets
- Processing email attachments
- Building knowledge bases from document archives
