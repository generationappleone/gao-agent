---
description: Validate MCP server availability, configuration, and connectivity. Use when troubleshooting MCP integrations or verifying environment setup.
---

# Context MCP Check — MCP Server Health Validation

## Purpose
This workflow validates the availability and configuration of MCP (Model Context Protocol) servers referenced in the agent's skill library. It checks connectivity, authentication, and basic functionality.

---

## Activation
The user triggers this workflow by:
- Using `/context-mcp-check` to run a full MCP health check
- Using `/context-mcp-check [server-name]` to check a specific server

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 0.5: Agent Lock Check (Race Condition Prevention)
// turbo
1. Check if `.agent/context/AGENT_LOCK` exists.
2. If it exists, STOP! Another agent is currently executing. Inform the user and abort.
3. If it does not exist, immediately create `.agent/context/AGENT_LOCK` with the current timestamp.
4. IMPORTANT: Meticulously delete `.agent/context/AGENT_LOCK` at the very end of this workflow OR whenever you pause to ask the user a question.

## Phase 1: Discover MCP Configuration

### Step 1.1 — Locate MCP Config Files
// turbo
Search for MCP configuration:
```bash
# Check common MCP config locations
find . -maxdepth 3 \( -name "mcp.json" -o -name "mcp-config.json" -o -name ".mcp.json" -o -name "mcp-servers.json" \) -not -path '*/node_modules/*' 2>/dev/null | head -10

# Check VS Code / Cursor settings
find . -maxdepth 2 -path '*/.vscode/settings.json' 2>/dev/null | head -5
find . -maxdepth 2 -path '*/.cursor/mcp.json' 2>/dev/null | head -5

# Check environment for MCP variables
env | grep -i MCP 2>/dev/null | head -10
```

### Step 1.2 — List Available MCP Skills
// turbo
```bash
# Count MCP skill directories
ls -d .agent/skills/mcp-*/ 2>/dev/null | wc -l

# List all MCP skills
ls -d .agent/skills/mcp-*/ 2>/dev/null
```

---

## Phase 2: Validate Configuration

### Step 2.1 — Parse MCP Config
Read the MCP configuration file and extract:
- Server names
- Transport type (stdio, sse, streamable-http)
- Command / URL
- Environment variables required
- Arguments

### Step 2.2 — Check Environment Variables
For each configured MCP server, verify required environment variables:
```
For each server:
  1. Read the corresponding skill file: .agent/skills/mcp-{name}/SKILL.md
  2. Extract required environment variables
  3. Check if they are set in the environment
  4. Report missing variables
```

---

## Phase 3: Connectivity Check

### Step 3.1 — Test Each Server
For each configured MCP server:

1. **stdio transport:**
   - Check if the command binary exists
   - Verify the command is executable
   - Check file permissions

2. **SSE/HTTP transport:**
   - Check if the URL is reachable
   - Verify authentication credentials
   - Test with a simple ping/list request

### Step 3.2 — Use Built-in MCP Tools
If the agent has access to MCP tools:
```
For each configured server:
  1. Call list_resources(ServerName) to verify connectivity
  2. Note any errors or timeouts
  3. Record available resources/tools
```

---

## Phase 4: Generate Report

### Step 4.1 — Health Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔌 MCP SERVER HEALTH CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Config file: [path to mcp config]
Total configured: [N] servers
Checked at: [timestamp]

| # | Server | Transport | Status | Tools | Notes |
|---|--------|-----------|--------|-------|-------|
| 1 | github | stdio     | ✅ OK  | 12    |       |
| 2 | supabase | stdio   | ✅ OK  | 8     |       |
| 3 | stripe  | stdio    | ❌ FAIL | —    | Missing STRIPE_API_KEY |
| 4 | notion  | stdio    | ⚠️ WARN | 5    | Rate limited |

Summary:
  ✅ Healthy: [N]
  ❌ Failed:  [N]
  ⚠️ Warning: [N]
  ⬚ Not configured: [N] (skills available but not configured)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4.2 — Unconfigured MCP Skills Report
List MCP skills that exist in `.agent/skills/mcp-*/` but are NOT in the MCP config:

```markdown
📋 Available but Unconfigured MCP Servers:

| Skill | Description | Setup Required |
|-------|-------------|----------------|
| mcp-github | GitHub API access | GITHUB_TOKEN |
| mcp-stripe | Payment management | STRIPE_API_KEY |
| ... | ... | ... |

To configure: Add to your MCP config file and set required env vars.
```

---

## Phase 5: Remediation Suggestions

### Step 5.1 — Fix Suggestions
For each failed or warning server, provide:
1. **Root cause** — Why it failed
2. **Fix steps** — Exact commands to resolve
3. **Environment variables** — What needs to be set
4. **Documentation link** — Link to the corresponding skill

### Step 5.2 — Quick Setup Commands
```markdown
# To configure a new MCP server:
1. Read the skill: .agent/skills/mcp-{name}/SKILL.md
2. Set required environment variables
3. Add server to MCP config
4. Restart the IDE/agent
5. Run /context-mcp-check {name} to verify
```

---

## When to Use
- After initial project setup
- When MCP tools are not responding
- After changing environment variables
- When adding a new MCP integration
- Periodic health checks

## When to Skip
- No MCP servers are configured or needed
- Working on a project without external integrations
