---
name: MCP Server — Tavily
description: MCP Server for Tavily — AI-optimized web search, content extraction, site mapping, crawling, and deep research API for real-time, LLM-ready web data retrieval.
---

# MCP Server — Tavily

## Overview
Tavily MCP Server provides AI assistants with production-ready web search and research capabilities. Optimized for LLMs and RAG pipelines, it delivers real-time, contextual web data with built-in content filtering and safety features.

## Tools Provided

| Tool | Description |
|------|-------------|
| `search` | AI-optimized web search with relevancy ranking |
| `extract` | Extract clean content from specific URLs |
| `crawl` | Crawl websites with smart URL navigation |
| `map` | Discover and map all URLs on a website |
| `research` | Deep research with multi-iteration analysis and structured reports |

## Configuration

```json
{
  "mcpServers": {
    "tavily": {
      "command": "npx",
      "args": ["-y", "tavily-mcp@latest"],
      "env": {
        "TAVILY_API_KEY": "tvly-..."
      }
    }
  }
}
```

## Search Parameters
- **Search depth**: `basic` (fast) or `advanced` (thorough)
- **Topic filters**: `general`, `news`, `finance`
- **Time range**: Filter results by recency
- **Domain control**: Include/exclude specific domains
- **Content types**: Include images, raw HTML, or direct answers

## Key Features
- **LLM-optimized**: Results structured and chunked for AI consumption
- **Content filtering**: Strips HTML/CSS noise, maximizes token efficiency
- **Safety**: Blocks PII leakage, prompt injection, and malicious sources
- **Real-time**: Live web data, not cached or stale results
- **Research API**: Multi-iteration deep research in a single call

## Use Cases
- Real-time information retrieval for AI agents
- RAG pipeline data sourcing
- Competitive intelligence gathering
- Documentation and API reference lookup
- News monitoring and trend analysis
- Deep research report generation
