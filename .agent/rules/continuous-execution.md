# Continuous Execution Rule

## Purpose
Ensure all sprints, tasks, and plan items are executed **continuously and automatically** without stopping to ask the user for permission to continue to the next item.

---

## Rule (MANDATORY)

### 1. No Pause Between Tasks
When executing a plan (sprints, tasks, or any ordered list of work items), the agent **MUST NOT**:
- Ask the user "Continue?" or "Shall I proceed?" between tasks
- Wait for user confirmation before starting the next task/sprint
- Prompt "Ready for the next task?" or similar interruptions
- Stop execution to ask if the user wants to move on

### 2. Continuous Execution Until Completion
The agent **MUST**:
- Execute **ALL** tasks/sprints from start to finish in a single continuous flow
- Automatically proceed to the next task immediately after completing the current one
- Follow the priority order (URGENT → HIGH → MEDIUM → LOW) without pausing
- Only stop execution if a **critical blocking error** occurs that cannot be auto-resolved

### 3. Progress Reporting Without Pausing
- Show progress reports (e.g., task completion announcements) as **informational only**
- Progress reports are for visibility — they do NOT require user response
- Format: announce completion → immediately start the next task

### 4. When to Stop (Exceptions)
The agent should ONLY stop and ask the user in these specific cases:
- **Critical error**: Build failure that cannot be auto-fixed after 2 attempts
- **Architecture mismatch**: Plan conflicts with actual codebase structure
- **Dependency conflict**: Package version conflicts with no clear resolution
- **Security risk**: Implementation would introduce a known security vulnerability
- **Missing required information**: Plan references undefined requirements

### 5. Verification is Inline, Not a Pause
The `verification-gate` rule requires verification before completion claims. This does NOT conflict with continuous execution:
- Run verification commands (build, test, lint) **as part of the task flow** — do not stop and ask the user before running them
- If verification passes → continue to next task immediately
- If verification fails → attempt auto-fix (up to 2 attempts), then continue or escalate per Exception rules
- **Verification is a step within a task, not a pause between tasks**

### 6. Applies To
This rule applies to all execution workflows including but not limited to:
- `/context-work` task execution
- Sprint execution
- Multi-step implementation plans
- Batch file creation/modification
- Any sequential list of development tasks

---

## Example: Correct Behavior

```
✅ CORRECT (Continuous):

━━━ TASK #1 — Create migration ━━━
[executes task 1]
✅ Task #1 completed.

━━━ TASK #2 — Create model ━━━
[immediately executes task 2]
✅ Task #2 completed.

━━━ TASK #3 — Create service ━━━
[immediately executes task 3]
✅ Task #3 completed.

━━━ PROGRESS: 3/8 tasks completed (37.5%) ━━━

━━━ TASK #4 — Create controller ━━━
[immediately continues without asking]
...continues until ALL tasks are done...

━━━ ✅ ALL TASKS COMPLETED ━━━
```

```
❌ WRONG (Pausing):

✅ Task #1 completed.
"Shall I continue to Task #2?" ← NEVER DO THIS

✅ Sprint 1 completed.
"Ready to start Sprint 2?" ← NEVER DO THIS

"3/8 tasks completed. Continue? (Y/n)" ← NEVER DO THIS
```
