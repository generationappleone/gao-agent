# GAO Agent — Claude Code Bridge

> **This file makes Claude Code behave identically to Google Antigravity for this project.**
> Single source of truth lives in `.agent/`. This file and `.claude/commands/` are a thin adapter layer.

---

## Master Configuration

**You MUST read [`.agent/AGENTS.md`](.agent/AGENTS.md) in full before performing ANY task.** That file is the master rule registry, skill index, and convention guide. Every instruction inside it is mandatory.

When `.agent/AGENTS.md` references rules, workflows, skills, memory, or context files, follow the paths exactly as written. The framework is portable across AI clients — Antigravity, Claude Code, Cursor, etc. — and Claude Code is one consumer of the same files.

---

## Cross-Platform Adapter Notes

The framework was originally authored for Antigravity. When running on Claude Code, apply these translations automatically:

### 1. `// turbo` directives → auto-proceed

Workflows under `.agent/workflows/` contain lines like:

```
// turbo
```

This is an Antigravity directive meaning *"the following block is pre-approved; execute without asking the user."* On Claude Code, treat `// turbo` as a signal to proceed automatically without an extra confirmation, subject to the user's permission settings.

### 2. Tool name translation

Workflows occasionally reference Antigravity built-in tool names. Map them to Claude Code equivalents:

| Antigravity tool   | Claude Code equivalent              |
|--------------------|--------------------------------------|
| `list_dir`         | `Glob` (or `Bash ls`)                |
| `find_by_name`     | `Glob`                               |
| `grep_search`      | `Grep`                               |
| `view_file`        | `Read`                               |
| `replace`          | `Edit`                               |
| `write`            | `Write`                              |
| `run_command`      | `Bash`                               |

### 3. Shell

The user's primary shell is `bash` on Windows (Git Bash). Use Unix shell syntax (`/dev/null`, forward slashes), not Windows-style paths. PowerShell is also available via the `PowerShell` tool when needed (e.g. for Windows-specific automation).

### 4. Skills are accessed by path, not auto-loaded

Skills live in `.agent/skills/<name>/SKILL.md`, **not** `.claude/skills/`. They are NOT auto-discovered by Claude Code. When a workflow or rule says "read skill X", read the file directly via its path:

```
.agent/skills/laravel/SKILL.md
.agent/skills/reactjs/SKILL.md
.agent/skills/<name>/SKILL.md
```

The full skill index is in `.agent/AGENTS.md` under "Available Skills".

### 5. Memory & runtime files

These files persist across sessions and are part of the framework's self-learning system:

| Path                                       | Purpose                                                  |
|--------------------------------------------|----------------------------------------------------------|
| `.agent/memory/ERROR_LOG.md`               | Mistake log — read before EVERY task, append on errors  |
| `.agent/memory/LEARNED_KNOWLEDGE.md`       | User preferences & patterns — apply proactively         |
| `.agent/context/CONTEXT_INDEX.md`          | Master index of project documentation                    |
| `.agent/context/ACTIVE_TASK.md`            | In-progress task state for cross-model handoff           |
| `.agent/context/AGENT_LOCK`                | Race-condition lock; create at workflow start, delete at end |

### 6. MCP

Context7 MCP is the recommended documentation engine. To install it for Claude Code, run:

```bash
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp
```

(Or use the remote variant — see [`.agent/mcp-configs/templates/claude-code.md`](.agent/mcp-configs/templates/claude-code.md).)

---

## Slash Commands

All 19 GAO Agent workflows are exposed as Claude Code slash commands via thin wrappers in [`.claude/commands/`](.claude/commands/). Each wrapper points back to `.agent/workflows/context-<name>.md` as the source of truth.

| Command           | Source workflow                                  |
|-------------------|--------------------------------------------------|
| `/context-init`   | `.agent/workflows/context-init.md`               |
| `/context-plan`   | `.agent/workflows/context-plan.md`               |
| `/context-work`   | `.agent/workflows/context-work.md`               |
| `/context-build`  | `.agent/workflows/context-build.md`              |
| `/context-test`   | `.agent/workflows/context-test.md`               |
| `/context-review` | `.agent/workflows/context-review.md`             |
| `/context-deploy` | `.agent/workflows/context-deploy.md`             |
| `/context-launch` | `.agent/workflows/context-launch.md`             |
| `/context-debug`  | `.agent/workflows/context-debug.md`              |
| `/context-refactor` | `.agent/workflows/context-refactor.md`         |
| `/context-upgrade` | `.agent/workflows/context-upgrade.md`           |
| `/context-migrate` | `.agent/workflows/context-migrate.md`           |
| `/context-docs`   | `.agent/workflows/context-docs.md`               |
| `/context-ask`    | `.agent/workflows/context-ask.md`                |
| `/context-git`    | `.agent/workflows/context-git.md`                |
| `/context-ui-ux`  | `.agent/workflows/context-ui-ux.md`              |
| `/context-mcp-check` | `.agent/workflows/context-mcp-check.md`       |
| `/context-reload` | `.agent/workflows/context-reload.md`             |
| `/context-help`   | `.agent/workflows/context-help.md`               |

---

## Pre-Task Protocol (from AGENTS.md, summarized)

Before ANY task:

1. **Check `.agent/context/ACTIVE_TASK.md`** — if it exists with unfinished steps, resume from there.
2. **Check `.agent/context/AGENT_LOCK`** — if it exists, another agent is running; STOP. If absent and you're starting a workflow, create it.
3. **Check `.agent/context/CONTEXT_INDEX.md`** — if absent, run `/context-init` first.
4. **Read `.agent/memory/ERROR_LOG.md`** to avoid repeating past mistakes.
5. **Read `.agent/memory/LEARNED_KNOWLEDGE.md`** for user preferences.
6. **Read the rules referenced by the task** (see the rule registry in `AGENTS.md`).

For full details, edge cases, and rule definitions, **always defer to `.agent/AGENTS.md`** — that file is authoritative.
