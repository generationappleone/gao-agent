---
name: MCP Server — Firecrawl
description: MCP Server for Firecrawl — AI-powered web scraping, crawling, search, site mapping, and structured data extraction with JavaScript rendering, anti-bot bypass, and batch processing.
---

# MCP Server — Firecrawl

## Overview
Firecrawl MCP Server transforms web data into clean, LLM-ready formats. It handles JavaScript-heavy sites, anti-bot mechanisms, and provides structured data extraction through natural language — all via standardized MCP interface.

## Tools Provided

| Tool | Description |
|------|-------------|
| `scrape` | Extract content from a single URL → Markdown, HTML, JSON, or screenshot |
| `crawl` | Recursively scan entire websites, collecting data from all URLs |
| `search` | Search the web and retrieve full content from results |
| `map` | Discover all indexed URLs of a website quickly |
| `extract` | Extract structured data from pages using LLM + JSON schema |
| `batch_scrape` | Process multiple URLs concurrently |

## Configuration

```json
{
  "mcpServers": {
    "firecrawl": {
      "command": "npx",
      "args": ["-y", "firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "fc-..."
      }
    }
  }
}
```

### Self-Hosted
```json
{
  "mcpServers": {
    "firecrawl": {
      "command": "npx",
      "args": ["-y", "firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "fc-...",
        "FIRECRAWL_API_URL": "http://localhost:3002"
      }
    }
  }
}
```

## Key Capabilities
- **JavaScript rendering**: Handles SPAs and dynamic content
- **Anti-bot bypass**: Built-in proxy, CAPTCHA solving, rate limit management
- **Content filtering**: Exclude tags, specify CSS selectors
- **Custom headers**: Crawl authenticated pages
- **Configurable depth**: Control crawl breadth and depth
- **Output formats**: Markdown, HTML, JSON, structured data, screenshots
- **Batch processing**: Concurrent scraping with automatic retries
- **Mobile emulation**: Scrape mobile versions of sites

## Use Cases
- AI training data collection from web sources
- Competitive intelligence gathering
- Documentation website crawling for RAG
- Research workflow automation
- Structured data extraction (pricing, reviews, contacts)
- Web content monitoring and change detection
