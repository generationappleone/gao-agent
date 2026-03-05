# 🔌 MCP Configuration Templates

> **Ready-to-use configuration templates for connecting Context7 MCP (and other MCP servers) to 20+ AI coding clients.**

---

## ⚡ Quick Start (3 Steps)

### Step 1: Get Your API Key

1. Go to [context7.com/dashboard](https://context7.com/dashboard)
2. Sign up (free)
3. Copy your API key

### Step 2: Choose Your Template

Find your AI client in the table below and copy the template file.

### Step 3: Add Your API Key

Replace `YOUR_API_KEY` in the template with your actual API key.

---

## 📋 Supported AI Clients

| # | AI Client | Template File | Config Location | Notes |
|---|-----------|--------------|-----------------|-------|
| 1 | **Google Antigravity** ⭐ | [`antigravity.mcp.json`](templates/antigravity.mcp.json) | `.mcp.json` (project root) | Uses `serverUrl` |
| 2 | **Cursor** | [`cursor.mcp.json`](templates/cursor.mcp.json) | `~/.cursor/mcp.json` or `.cursor/mcp.json` | Uses `url` |
| 3 | **VS Code** | [`vscode.mcp.json`](templates/vscode.mcp.json) | `.vscode/mcp.json` | Nested under `mcp.servers` |
| 4 | **Claude Code** | [`claude-code.md`](templates/claude-code.md) | Via CLI command | Uses `claude mcp add` |
| 5 | **Claude Desktop** | [`claude-desktop.mcp.json`](templates/claude-desktop.mcp.json) | `~/Library/.../claude_desktop_config.json` | Local connection only |
| 6 | **Windsurf** | [`windsurf.mcp.json`](templates/windsurf.mcp.json) | Via Windsurf UI | Uses `serverUrl` |
| 7 | **Gemini CLI** | [`gemini-cli.json`](templates/gemini-cli.json) | `~/.gemini/settings.json` | Uses `httpUrl` + Accept header |
| 8 | **OpenAI Codex** | [`openai-codex.toml`](templates/openai-codex.toml) | Codex config | TOML format |
| 9 | **GitHub Copilot** | [`copilot.mcp.json`](templates/copilot.mcp.json) | `.github/copilot/mcp.json` | Requires `tools` array |
| 10 | **JetBrains** | [`jetbrains.mcp.json`](templates/jetbrains.mcp.json) | Settings > Tools > AI Assistant > MCP | Via JSON paste |
| 11 | **Kiro** | [`kiro.mcp.json`](templates/kiro.mcp.json) | Kiro > MCP Servers > + Add | Has `autoApprove` |
| 12 | **Kilo Code** | [`kilocode.mcp.json`](templates/kilocode.mcp.json) | `.kilocode/mcp.json` | Uses `streamable-http` type |
| 13 | **Roo Code** | [`roo-code.mcp.json`](templates/roo-code.mcp.json) | MCP config | Uses `streamable-http` type |
| 14 | **Cline** | [`cline.mcp.json`](templates/cline.mcp.json) | Via MCP Servers UI | Uses `streamableHttp` type |
| 15 | **Augment Code** | [`augment-code.json`](templates/augment-code.json) | `settings.json` > `augment.advanced` | Array format |
| 16 | **Opencode** | [`opencode.mcp.json`](templates/opencode.mcp.json) | Opencode config file | Uses `type: remote` |
| 17 | **Zed** | [`zed.json`](templates/zed.json) | `settings.json` > `context_servers` | Different key name |
| 18 | **Warp** | [`warp.mcp.json`](templates/warp.mcp.json) | Settings > AI > MCP servers | Has `start_on_launch` |
| 19 | **Qwen Code** | [`qwen-code.json`](templates/qwen-code.json) | `~/.qwen/settings.json` | Uses `httpUrl` |
| 20 | **Amazon Q** | [`amazon-q.mcp.json`](templates/amazon-q.mcp.json) | Amazon Q config | Standard format |
| 21 | **LM Studio** | [`lm-studio.mcp.json`](templates/lm-studio.mcp.json) | Program > Install > mcp.json | Standard format |
| 22 | **Visual Studio 2022** | [`visual-studio.mcp.json`](templates/visual-studio.mcp.json) | MCP config | Has `inputs` array |
| 23 | **Trae** | [`trae.mcp.json`](templates/trae.mcp.json) | Trae MCP config | Standard format |
| 24 | **Windows (CMD)** | [`windows-cmd.mcp.json`](templates/windows-cmd.mcp.json) | Any client on Windows | CMD wrapper for npx |

---

## 🔑 API Key Management

### Environment Variable Template

Copy `.env.mcp.example` to `.env` in your project root:

```bash
cp .agent/mcp-configs/.env.mcp.example .env
```

Then fill in the API keys you need. See [`.env.mcp.example`](.env.mcp.example) for the full list.

### Security Rules

- ❌ **NEVER** commit `.env` files or config files containing real API keys to Git
- ✅ Add to `.gitignore`:
  ```
  .env
  .env.local
  .env.*.local
  .cursor/mcp.json
  .mcp.json
  ```
- ✅ Use environment variables or secret managers for production
- ✅ Rotate API keys periodically

---

## 🔄 Remote vs Local Connection

Each template supports two connection modes:

| Mode | Pros | Cons |
|------|------|------|
| **Remote** (recommended) | No local install, works everywhere, faster setup | Requires internet, subject to API rate limits |
| **Local** | Works offline after first download, no external dependency at runtime | Requires Node.js 18+, first run downloads package |

Templates default to **Remote** mode. To switch to Local, use:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp", "--api-key", "YOUR_API_KEY"]
    }
  }
}
```

For **Windows**, wrap with CMD:

```json
{
  "mcpServers": {
    "context7": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@upstash/context7-mcp", "--api-key", "YOUR_API_KEY"]
    }
  }
}
```

---

## 🛠️ Workflow Integration

Use the GAO Agent workflow to validate your MCP setup:

```
/context-mcp-check
```

This will:
1. Auto-detect your AI client
2. Check if MCP config exists
3. Validate API key and connectivity
4. Offer to generate config from templates if needed

---

## 📚 References

- [Context7 GitHub](https://github.com/upstash/context7)
- [Context7 All Clients Guide](https://context7.com/docs/resources/all-clients)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [GAO Agent MCP Skills](../skills/) — 65+ MCP server integration skills
