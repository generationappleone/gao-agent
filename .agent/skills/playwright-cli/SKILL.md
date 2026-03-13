---
name: playwright-cli
description: "Skill for token-efficient browser automation via Playwright CLI commands — covering snapshot-based element refs, session management, and CLI-over-MCP guidance."
---

# Playwright CLI — Token-Efficient Browser Automation

## Overview

Playwright CLI provides **command-line browser automation** as an alternative to the MCP-based Playwright integration. It's significantly more token-efficient for simple browser tasks: form filling, navigation, data extraction, and screenshot capture.

**Announce:** "Using playwright-cli skill for browser automation."

## When to Use CLI vs MCP

| Scenario | Use CLI | Use MCP |
|----------|---------|---------|
| Simple navigation | ✅ | ❌ |
| Form submission | ✅ | ❌ |
| Data extraction | ✅ | ❌ |
| Complex multi-step flows | ❌ | ✅ |
| Visual testing | ❌ | ✅ |
| API interception | ❌ | ✅ |
| Token budget limited | ✅ | ❌ |

## Core Commands

### Navigation

```bash
# Open a URL
playwright open https://example.com

# Navigate within session
playwright navigate https://example.com/about

# Go back/forward
playwright go-back
playwright go-forward

# Reload
playwright reload
```

### Taking Snapshots

```bash
# Get accessible elements snapshot (returns element refs: e1, e2, ...)
playwright snapshot

# Screenshot
playwright screenshot --path ./screenshot.png
playwright screenshot --full-page --path ./full.png
```

### Element Interaction

Snapshots return numbered element references (`e1`, `e2`, etc.):

```bash
# After taking a snapshot and seeing:
# e1: [textbox] "Email"
# e2: [textbox] "Password"  
# e3: [button] "Sign In"

# Click element
playwright click e3

# Fill text field
playwright fill e1 "user@example.com"
playwright fill e2 "password123"

# Select dropdown
playwright select e5 "option-value"

# Check/uncheck
playwright check e7
playwright uncheck e7
```

### Keyboard

```bash
# Type text
playwright type "Hello World"

# Press key
playwright press Enter
playwright press Tab
playwright press Control+A

# Key combinations
playwright press Control+Shift+I
```

### Mouse

```bash
# Click coordinates
playwright click --x 100 --y 200

# Hover
playwright hover e4

# Drag and drop
playwright drag e1 e2
```

### Tabs

```bash
# List tabs
playwright tabs

# Switch tab
playwright tab 2

# New tab
playwright new-tab https://example.com

# Close tab
playwright close-tab
```

## Session Management

### Named Sessions

```bash
# Start named session
playwright open https://example.com --session my-session

# Resume session
playwright --session my-session snapshot
```

### Persistent Profiles

```bash
# Use persistent browser profile
playwright open --user-data-dir ./browser-profile https://example.com

# Reuse auth state
playwright open --storage-state auth.json https://example.com
```

### Save/Load Storage State

```bash
# Save cookies + localStorage
playwright save-storage-state --path auth.json

# Load in new session
playwright open --storage-state auth.json https://dashboard.example.com
```

## Configuration

### Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `PLAYWRIGHT_BROWSER` | Browser engine | `chromium` |
| `PLAYWRIGHT_HEADLESS` | Headless mode | `true` |
| `PLAYWRIGHT_TIMEOUT` | Default timeout (ms) | `30000` |
| `PLAYWRIGHT_VIEWPORT_WIDTH` | Viewport width | `1280` |
| `PLAYWRIGHT_VIEWPORT_HEIGHT` | Viewport height | `720` |

## Common Workflows

### Login Flow

```bash
playwright open https://app.example.com/login
playwright snapshot
# e1: [textbox] "Email", e2: [textbox] "Password", e3: [button] "Login"
playwright fill e1 "admin@example.com"
playwright fill e2 "password123"
playwright click e3
playwright save-storage-state --path auth.json
```

### Form Submission

```bash
playwright open --storage-state auth.json https://app.example.com/new-form
playwright snapshot
playwright fill e1 "John Doe"
playwright fill e2 "john@example.com"
playwright select e3 "premium"
playwright check e4
playwright click e5  # Submit button
playwright snapshot  # Verify result
```

### Data Extraction

```bash
playwright open https://example.com/products
playwright snapshot
# Read element text from snapshot output
# Extract structured data from visible elements
```

## Token Efficiency

CLI commands are ~5-10x more token-efficient than MCP equivalent:

| Operation | CLI Tokens | MCP Tokens |
|-----------|-----------|------------|
| Navigate + fill form | ~50 | ~300 |
| Take screenshot | ~20 | ~150 |
| Multi-page flow | ~200 | ~1500 |

## Integration

**This skill is an alternative to:**
- `skills/playwright/SKILL.md` — Full Playwright test authoring (more powerful, more tokens)

**Paradigm difference:**
- **Playwright skill** = Test authoring framework (write `.spec.ts` files)
- **Playwright CLI** = Browser automation tool (run commands directly)

**This skill pairs with:**
- `skills/systematic-debugging/SKILL.md` — Debug UI issues by inspecting live pages
- `skills/recording-replay-testing/SKILL.md` — Record interactions for test fixtures
