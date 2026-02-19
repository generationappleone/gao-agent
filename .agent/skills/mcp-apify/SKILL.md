---
name: MCP Server — Apify
description: MCP Server for Apify — enables AI assistants to run web scrapers (Actors), manage datasets, access the Apify platform for data extraction and automation at scale.
---

# MCP Server — Apify

## Overview
Apify MCP Server connects AI assistants to the Apify web scraping and automation platform. It provides access to 2,000+ pre-built scrapers (Actors) for extracting data from popular websites and services.

## Tools Provided

| Tool | Description |
|------|-------------|
| `run_actor` | Execute an Apify Actor (scraper/automation) |
| `get_actor_run` | Check status of a running Actor |
| `get_dataset` | Retrieve scraped data from a dataset |
| `list_actors` | Browse available Actors on Apify Store |
| `search_actors` | Search for Actors by keyword |
| `get_key_value_store` | Access key-value store data |

## Configuration

```json
{
  "mcpServers": {
    "apify": {
      "command": "npx",
      "args": ["-y", "@apify/mcp-server-apify"],
      "env": {
        "APIFY_API_TOKEN": "apify_api_..."
      }
    }
  }
}
```

## Popular Actors
- Google Search Scraper, Google Maps Scraper
- Instagram, TikTok, Twitter/X, YouTube scrapers
- Amazon, eBay product scrapers
- Website Content Crawler (for RAG)
- Web page screenshot/PDF capture

## Use Cases
- Large-scale web data extraction for AI training
- Social media data collection and analysis
- E-commerce price monitoring
- Lead generation from web sources
- Content aggregation for knowledge bases
