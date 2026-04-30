---
description: Validate MCP server availability, configuration, and connectivity. Use when troubleshooting MCP integrations or verifying environment setup.
argument-hint: [--setup]
---

Execute the GAO Agent **`/context-mcp-check`** workflow.

**Authoritative source:** [`.agent/workflows/context-mcp-check.md`](../../.agent/workflows/context-mcp-check.md)

Read that file in full and execute every phase exactly as specified, applying the cross-platform translations documented in [`CLAUDE.md`](../../CLAUDE.md). For Claude Code specifically, MCP servers are managed via `claude mcp add ...` — see [`.agent/mcp-configs/templates/claude-code.md`](../../.agent/mcp-configs/templates/claude-code.md).

**User input:** $ARGUMENTS
