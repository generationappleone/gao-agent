---
description: "Reload all agent rules mid-conversation. Use after editing any file in .agent/rules/ to apply changes without starting a new chat."
---

# Context Reload — Hot-Reload Agent Configuration

## Purpose
This workflow re-reads ALL agent configuration files (rules, workflows, skills index) so changes take effect immediately in the current conversation, without requiring a new session.

---

## Steps

1. **Scan rule files** — Enumerate all rules:
   // turbo
   ```bash
   find .agent/rules/ -name "*.md" -type f | sort
   ```

2. **Re-read ALL rules** — Read every `.md` file in `.agent/rules/`:
   // turbo
   - Read each rule file completely
   - Compare with known state to detect changes

3. **Scan workflow files** — Enumerate all workflows:
   // turbo
   ```bash
   find .agent/workflows/ -name "*.md" -type f | sort
   ```

4. **Re-read ALL workflows** — Read every `.md` file in `.agent/workflows/`:
   // turbo
   - Read each workflow file header (description)
   - Note new/modified/removed workflows

5. **Scan skills directory** — Check for new or removed skills:
   // turbo
   ```bash
   ls -d .agent/skills/*/SKILL.md 2>/dev/null | wc -l
   ls .agent/skills/ | head -50
   ```

6. **Detect changes** — Compare the current state with previous:
   - New files added
   - Files modified (content changed)
   - Files removed
   - New skills added

7. **Report reload results**:
   ```markdown
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ CONFIGURATION RELOADED
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   📏 Rules:
     Total:    [N] rules loaded
     Changed:  [list of modified/new files]

   🔧 Workflows:
     Total:    [N] workflows loaded
     Changed:  [list of modified/new files]

   🧰 Skills:
     Total:    [N] skills available

   ✅ All subsequent responses in this conversation
      now follow the updated configuration.
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

8. **Apply immediately** — All subsequent responses in this conversation follow the updated rules, including any new deep-thinking requirements, security rules, or architecture enforcement changes.

---

## When to Use
- After editing any file in `.agent/rules/`
- After adding/removing workflows in `.agent/workflows/`
- After adding new skills in `.agent/skills/`
- After changing project config (preset, tech stack, commands)
- After updating architecture or quality gate settings
- Mid-conversation when rules feel outdated or misaligned
