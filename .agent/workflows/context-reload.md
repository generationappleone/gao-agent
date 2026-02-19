---
description: "Reload all agent rules mid-conversation. Use after editing any file in .agent/rules/ to apply changes without starting a new chat."
---

# Context Reload Workflow

This workflow re-reads all agent rule files so changes take effect immediately in the current conversation.

## Steps

1. **Re-read all rules** — Read every file in `.agent/rules/`:
   // turbo
   - Scan `.agent/rules/` directory for all `.md` files
   - Re-read each rule file

2. **Confirm changes** — Report what changed since last load:
   > "✅ Rules reloaded. Changes detected in: [list of modified files]"

3. **Apply immediately** — All subsequent responses in this conversation follow the updated rules.

## When to Use
- After editing any file in `.agent/rules/`
- After changing project config (preset, tech stack, commands)
- After updating architecture or quality gate settings
- Mid-conversation when rules feel outdated
