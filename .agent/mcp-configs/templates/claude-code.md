# GAO Agent — Context7 MCP Config for Claude Code

> Claude Code uses CLI commands to configure MCP servers.
> Docs: https://docs.anthropic.com/en/docs/claude-code/mcp

## Quick Setup

### Remote Server Connection (Recommended)

```bash
claude mcp add --scope user --header "CONTEXT7_API_KEY: YOUR_API_KEY" --transport http context7 https://mcp.context7.com/mcp
```

### Local Server Connection

```bash
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY
```

> **Note:** Remove `--scope user` to install for the current project only.

## Auto-Invoke Rule

Add this to your `CLAUDE.md` file so Context7 is used automatically:

```
Always use Context7 MCP when I need library/API documentation, code generation,
setup or configuration steps without me having to explicitly ask.
```

## Get API Key

1. Go to https://context7.com/dashboard
2. Sign up (free)
3. Copy your API key
4. Replace `YOUR_API_KEY` in the commands above
