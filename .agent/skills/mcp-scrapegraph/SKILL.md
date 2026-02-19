---
name: MCP Server — ScrapeGraphAI
description: MCP Server for ScrapeGraphAI — enables AI assistants to perform intelligent web scraping using LLM-powered extraction with natural language instructions.
---

# MCP Server — ScrapeGraphAI

## Overview
ScrapeGraphAI MCP Server provides AI assistants with intelligent web scraping capabilities that use LLMs to understand and extract structured data from web pages based on natural language descriptions.

## Tools Provided

| Tool | Description |
|------|-------------|
| `smart_scrape` | Scrape a URL with natural language extraction instructions |
| `search_scrape` | Search the web and scrape results |
| `local_scrape` | Scrape content from local HTML files |
| `extract_schema` | Extract data matching a JSON schema |

## Configuration

```json
{
  "mcpServers": {
    "scrapegraph": {
      "command": "npx",
      "args": ["-y", "scrapegraph-mcp"],
      "env": {
        "SGAI_API_KEY": "...",
        "OPENAI_API_KEY": "sk-..."
      }
    }
  }
}
```

## Use Cases
- Natural language web data extraction
- Structured data scraping without CSS selectors
- Intelligent content parsing from complex pages
- Multi-page data collection with LLM understanding
- Research automation with contextual scraping
