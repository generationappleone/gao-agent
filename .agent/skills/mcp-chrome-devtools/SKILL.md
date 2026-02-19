---
name: MCP Server — Chrome DevTools
description: MCP Server for Chrome DevTools — enables AI assistants to control Chrome via DevTools Protocol (CDP) for browser debugging, network analysis, DOM inspection, performance profiling, and console monitoring.
---

# MCP Server — Chrome DevTools

## Overview
Chrome DevTools MCP Server bridges AI assistants with Chrome's DevTools Protocol (CDP), enabling full browser inspection and debugging capabilities — including DOM manipulation, network monitoring, performance analysis, and JavaScript debugging.

## Tools Provided

| Tool | Description |
|------|-------------|
| `navigate` | Navigate browser to a URL |
| `screenshot` | Capture page screenshot |
| `get_console_logs` | Retrieve console output |
| `evaluate_javascript` | Execute JS in page context |
| `get_dom_tree` | Get the page DOM structure |
| `query_selector` | Query DOM elements |
| `get_network_requests` | List network requests with details |
| `get_cookies` | Get browser cookies |
| `set_cookie` | Set a cookie |
| `get_local_storage` | Read localStorage data |
| `get_performance_metrics` | Get page performance metrics |
| `start_performance_trace` | Begin performance recording |
| `stop_performance_trace` | Stop and get trace results |
| `emulate_device` | Emulate mobile/tablet device |
| `set_network_conditions` | Throttle network (3G, offline) |
| `click_element` | Click a DOM element |

## Configuration

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "@anthropics/mcp-server-chrome-devtools"],
      "env": {
        "CHROME_DEBUG_PORT": "9222"
      }
    }
  }
}
```

### Launch Chrome in Debug Mode
```bash
# Windows
chrome.exe --remote-debugging-port=9222

# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Linux
google-chrome --remote-debugging-port=9222
```

## Use Cases
- AI-assisted web debugging and troubleshooting
- Performance bottleneck identification
- Network request analysis and optimization
- Console error monitoring and diagnosis
- Responsive design testing with device emulation
- Cookie/storage inspection for auth debugging
