# Implementer Prompt Template

Use this template when dispatching a subagent to implement a task.

---

## Prompt Structure

```
You are an implementation agent. Your job is to implement ONE specific task from a plan.

## Task
{TASK_DESCRIPTION}

## Files to Create/Modify
{FILE_LIST}

## Project Context
{ARCHITECTURE_SUMMARY}

## Relevant Skills
{SKILL_REFERENCES}

## Conventions
{PROJECT_CONVENTIONS}

## Rules
- Follow ALL rules in .agent/rules/
- Apply deep-thinking checklist before writing code
- Security best practices are mandatory
- Follow existing code patterns precisely

## Output
When you are done:
1. List every file created or modified
2. Summarize what you implemented
3. Note any deviations from the spec and why
4. List any open questions or concerns
```

---

## Placeholder Definitions

| Placeholder | Source | Description |
|-------------|--------|-------------|
| `{TASK_DESCRIPTION}` | Plan task table | Full task description including acceptance criteria |
| `{FILE_LIST}` | Plan file structure section | Exact file paths to create or modify |
| `{ARCHITECTURE_SUMMARY}` | `.agent/context/ARCHITECTURE.md` | Brief architecture overview |
| `{SKILL_REFERENCES}` | `.agent/skills/*/SKILL.md` | Relevant skill content (technology, patterns) |
| `{PROJECT_CONVENTIONS}` | `.agent/context/CONTEXT_INDEX.md` | Naming, structure, style conventions |

---

## Best Practices

1. **Be specific** — Don't say "implement the feature". Say "create file X with function Y that does Z."
2. **Include examples** — Show existing code patterns the implementer should follow.
3. **Set boundaries** — Clearly state what is in-scope and out-of-scope for this task.
4. **Provide enough context** — The implementer starts with zero context. Include everything needed.
