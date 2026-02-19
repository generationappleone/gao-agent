---
name: MCP Server — Playwright
description: MCP Server for Playwright — enables AI assistants to automate browsers, interact with web pages, take screenshots, generate PDFs, execute JavaScript, and run end-to-end tests.
---

# MCP Server — Playwright

## Overview
Playwright MCP Server gives AI assistants full browser automation capabilities via the Playwright framework. It enables page navigation, element interaction, screenshot capture, and test execution through a standardized MCP interface.

## Tools Provided

| Tool | Description |
|------|-------------|
| `navigate` | Navigate to a URL |
| `screenshot` | Take a screenshot of the current page or element |
| `click` | Click an element by selector |
| `fill` | Type text into an input field |
| `select` | Select an option from a dropdown |
| `hover` | Hover over an element |
| `evaluate` | Execute JavaScript in the browser context |
| `get_text` | Extract text content from elements |
| `get_attribute` | Get element attribute values |
| `wait_for_selector` | Wait for an element to appear |
| `pdf` | Generate PDF from current page |
| `get_title` | Get page title |
| `get_url` | Get current URL |
| `go_back` | Navigate back in history |
| `go_forward` | Navigate forward in history |

## Configuration

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@anthropics/mcp-server-playwright"],
      "env": {
        "PLAYWRIGHT_BROWSER": "chromium"
      }
    }
  }
}
```

## Browser Options
- **Chromium** (default), **Firefox**, **WebKit**
- Headless or headed mode
- Custom viewport sizes
- Device emulation (mobile, tablet)

## Use Cases
- AI-assisted web testing and QA
- Web scraping with full JS rendering
- Form automation and data entry
- Visual regression testing
- Accessibility auditing
- PDF report generation from web pages
