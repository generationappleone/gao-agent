---
name: Context7 Integration
description: Automatically fetch up-to-date library documentation from Context7 REST API before generating code for third-party libraries.
priority: MEDIUM
---

# Context7 Integration — Real-Time Library Documentation

## Core Principle

> **BEFORE generating code that uses any third-party library, framework, or SDK,
> the agent MUST fetch current documentation from Context7 REST API
> to prevent hallucination and outdated API usage.**

## When to Fetch Context7 Docs

The agent MUST call Context7 when:

1. **User explicitly asks** — prompt contains "use context7", "cek docs", "check documentation"
2. **Generating code for third-party libraries** — React, Next.js, Laravel, Express, Prisma, etc.
3. **User asks about a specific API** — "how to use X in Y", "cara pakai X"
4. **Framework setup/configuration** — middleware, routing, authentication, ORM
5. **Version-specific questions** — "Next.js 15 server actions", "Laravel 12 eloquent"

The agent should NOT call Context7 for:
- Pure HTML/CSS/vanilla JS (no library)
- Internal project code (not third-party)
- General programming questions (algorithms, data structures)
- When CONTEXT7_API_KEY is not set (inform user to set it up)

## How to Call Context7

### Step 1: Search for the library ID

```bash
node .agent/scripts/context7-api.mjs search "<library_name>" "<user_query>"
```

Example:
```bash
node .agent/scripts/context7-api.mjs search "next.js" "server actions"
# Returns: LIBRARY_ID=/vercel/next.js
```

### Step 2: Fetch relevant documentation

```bash
node .agent/scripts/context7-api.mjs docs "<library_id>" "<specific_query>"
```

Example:
```bash
node .agent/scripts/context7-api.mjs docs "/vercel/next.js" "middleware authentication"
# Returns: code snippets + documentation
```

### Step 3: Use the documentation to generate accurate code

Read the returned code snippets and documentation, then generate code that follows
the CURRENT API patterns — not training data patterns that may be outdated.

## Windows Alternative

If Node.js `fetch` is not available (Node < 18), use PowerShell:

```powershell
.\.agent\scripts\context7-api.ps1 -Action search -LibraryName "next.js" -Query "server actions"
.\.agent\scripts\context7-api.ps1 -Action docs -LibraryId "/vercel/next.js" -Query "middleware"
```

## Prerequisites

The user must set `CONTEXT7_API_KEY` in their `.env` file:

```
CONTEXT7_API_KEY=your_key_here
```

If not set, the agent should:
1. Inform the user: "Context7 API key belum di-set"
2. Provide setup link: https://context7.com/dashboard
3. Continue without Context7 (use skill files as fallback)

## Prompt Examples

Users can trigger Context7 documentation fetch with these patterns:

```
# Explicit trigger
"Buatkan login page dengan Next.js 15. use context7"
"Cara setup Prisma schema untuk e-commerce. use context7"

# Auto-detected (agent detects third-party library usage)
"Create a REST API with Express and Prisma"
"Buat middleware authentication di Laravel"
"Setup Redux Toolkit store for user management"
```

## Integration with Other Rules

- **deep-thinking.md** — Context7 check is part of the "understand requirements" step
- **production-code-standards.md** — Ensures code follows current API patterns
- **verification-gate.md** — Context7 docs serve as verification source
