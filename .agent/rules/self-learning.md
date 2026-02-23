# Self-Learning — Adaptive Knowledge from User Interactions

> **Priority: HIGHEST** — This rule applies to ALL agent interactions. The agent MUST continuously learn from the user and persist that knowledge for all future tasks.

## Core Principle

The AI agent is a **learning system**. It MUST:
1. **Observe** — Pay attention to every user correction, preference, and request pattern
2. **Record** — Store learned knowledge in a persistent file
3. **Apply** — Use stored knowledge in ALL future tasks without being told again
4. **Evolve** — Continuously refine understanding of the user's style and expectations

> **The user should NEVER have to repeat the same correction or preference twice.**

---

## 1. Knowledge Storage

### Location
All learned knowledge is stored in:
```
.agent/memory/LEARNED_KNOWLEDGE.md
```

If the file does not exist, create it with the template (see Section 5).

---

## 2. What to Learn — Detection Triggers

### 2.1 — User Corrections (HIGHEST Priority)
When the user **corrects** the agent's output, ALWAYS learn from it.

| Signal | Example | What to Record |
|--------|---------|---------------|
| **"Don't do it like that"** | "Don't use `var`, use `const`" | Coding style preference |
| **"That's not right"** | "Don't use a regular table, use UUID" | Technical preference |
| **"It should be..."** | "Comments should be in Bahasa Indonesia" | Language/convention preference |
| **"Always..."** | "Always use snake_case for database" | Naming convention |
| **"Never..."** | "Never use `any` in TypeScript" | Anti-pattern rule |
| **User edits agent's code** | User modifies the import order | Style preference |
| **User rejects suggestion** | User says "no, I prefer X over Y" | Technology preference |

### 2.2 — User Preferences (HIGH Priority)
Observe and record how the user likes things done.

| Category | Examples |
|----------|---------|
| **Language** | User communicates in Bahasa Indonesia → respond in Bahasa Indonesia |
| **Code style** | Prefers functional over OOP, arrow functions over regular |
| **Naming** | camelCase vs snake_case, singular vs plural table names |
| **Architecture** | Prefers service-repository pattern, prefers modular structure |
| **Framework choices** | Prefers Laravel over Django, React over Vue |
| **Database** | Prefers UUID over auto-increment, always soft delete |
| **Testing** | Prefers TDD, or prefers testing after implementation |
| **Documentation** | Prefers inline comments, or prefers JSDoc/PHPDoc |
| **Git** | Prefers conventional commits, specific branch naming |
| **Communication style** | Prefers brief answers, or prefers detailed explanations |
| **Error handling** | Prefers throwing exceptions, or prefers Result type |
| **API design** | Prefers REST over GraphQL, specific response format |

### 2.3 — User Request Patterns (MEDIUM Priority)
Track recurring request patterns to anticipate needs.

| Pattern | What to Learn |
|---------|--------------|
| User always asks for dark mode | Default to including dark mode in UI work |
| User always wants test files | Auto-generate tests with implementations |
| User always asks for Bahasa Indonesia | Default language for comments/docs |
| User always requests security review | Include security check in every task |
| User frequently asks about specific tech | Proactively reference that tech's skill |

### 2.4 — Project-Specific Knowledge (MEDIUM Priority)
Learn project conventions that aren't in the documentation.

| Type | Example |
|------|---------|
| **Custom patterns** | "We use X pattern for all services" |
| **Team conventions** | "Our team prefixes interfaces with I" |
| **Business rules** | "Prices are always in IDR, smallest unit (rupiah)" |
| **Deployment** | "We always deploy to X cloud provider" |
| **Dependencies** | "We never use library X, we use Y instead" |

---

## 3. Knowledge Entry Format

Each learned item MUST follow this structure:

```markdown
### LRN-[YYYY-MM-DD]-[NNN] — [Short Title]

**Date:** [YYYY-MM-DD HH:mm]
**Source:** [User Correction | User Preference | Request Pattern | Project Convention]
**Confidence:** [Confirmed | Observed | Inferred]
**Scope:** [Global | Project-Specific | Framework-Specific]

#### 📝 What Was Learned
[Clear description of the knowledge/preference/rule]

#### 💡 Apply When
[In what situations should this knowledge be applied]

#### 🔧 Action Rule
[Specific, actionable rule in IF-THEN format]

**Examples:**
- IF writing database migration THEN use UUID for primary keys, NEVER auto-increment
- IF writing TypeScript THEN use `const` by default, NEVER use `any`
- IF responding to user THEN use Bahasa Indonesia
- IF creating API endpoint THEN always include rate limiting
```

---

## 4. Mandatory Application Protocol

### Before Starting ANY Task

```
┌─────────────────────────────────────────────────────────────┐
│              SELF-LEARNING CHECK (BEFORE TASK)              │
├─────────────────────────────────────────────────────────────┤
│ 1. ☐ Read .agent/memory/LEARNED_KNOWLEDGE.md               │
│ 2. ☐ Scan Quick Reference for applicable rules             │
│ 3. ☐ Apply ALL matching knowledge rules to this task       │
│ 4. ☐ If unsure about user preference → check history first │
│ 5. ☐ If still unsure → ask the user (max 1 question)       │
└─────────────────────────────────────────────────────────────┘
```

### During Task Execution

When the agent detects a learning opportunity:

1. **Immediate capture** — Record the knowledge in LEARNED_KNOWLEDGE.md
2. **Acknowledge learning** — Briefly confirm to the user:
   ```
   📚 Noted: [brief description of what was learned].
      I'll apply this going forward.
   ```
3. **Apply retroactively** — If current task has already violated the new knowledge, fix it

### When User Corrects
1. **STOP** current action
2. **Acknowledge** the correction: `"Understood, thank you for the correction."`
3. **Record** the correction as a new knowledge entry
4. **Apply** the correction to current and ALL future work
5. **Review** current task output for other violations of this new rule

### After Task Completion
1. **Reflect** — Were there any implicit preferences shown by the user?
2. **Update** knowledge file if new patterns observed
3. **Verify** all known preferences were honored

---

## 5. Knowledge File Template

```markdown
# Agent Self-Learning — Learned Knowledge Base

> This file contains everything the agent has learned from user interactions.
> The agent reads this file BEFORE every task and applies ALL relevant rules.
> Knowledge is cumulative — entries are NEVER deleted, only refined.
>
> **Format:** One entry per learned item, organized by category.
> **Last Updated:** [auto-updated timestamp]

## Quick Reference — Active Rules

<!-- Fast lookup table for all learned rules. Updated with each new entry. -->

| ID | Rule | Scope | Source |
|----|------|-------|--------|
<!-- New rules added here -->

---

## Category: Coding Style

<!-- Learned coding style preferences -->

## Category: Architecture & Patterns

<!-- Learned architecture preferences -->

## Category: Database & Schema

<!-- Learned database preferences -->

## Category: Communication & Language

<!-- Learned communication preferences -->

## Category: Technology Preferences

<!-- Learned technology/framework preferences -->

## Category: Workflow & Process

<!-- Learned workflow preferences -->

## Category: Project Conventions

<!-- Learned project-specific conventions -->

## Category: UI/UX Preferences

<!-- Learned design preferences -->
```

---

## 6. Learning Priority & Conflict Resolution

### Priority Order (highest first)
1. **Explicit user correction** — "Don't do X, do Y" → Immediate, highest confidence
2. **Explicit user request** — "I want all comments in Bahasa Indonesia" → Immediate
3. **Repeated pattern** (3+ times) — User always does X → High confidence
4. **Single observation** — User did X once → Low confidence, observe more
5. **Inferred preference** — Based on project conventions → Verify before applying

### When Rules Conflict
If two learned rules conflict:
1. **Newer rule wins** — More recent correction overrides older one
2. **Explicit wins over implicit** — Direct correction > inferred pattern
3. **Specific wins over general** — "In this project, use X" > "Generally use Y"
4. **Ask user** — If truly ambiguous, ask once and record the answer

```markdown
⚠️ Rule Conflict Detected:
  Rule A (LRN-2026-02-10-001): "Use camelCase for variables"
  Rule B (LRN-2026-02-19-005): "Use snake_case for all naming"

  Rule B is newer and more explicit → Applying Rule B.
  Updated Rule A status to: Superseded by LRN-2026-02-19-005
```

---

## 7. Knowledge Refinement

### Confidence Levels
| Level | Meaning | Action |
|-------|---------|--------|
| **Confirmed** | User explicitly stated this | Apply always, no question |
| **Observed (3+)** | Seen 3+ times in user behavior | Apply by default, mention if unsure |
| **Observed (1-2)** | Seen 1-2 times | Apply cautiously, verify if critical |
| **Inferred** | Deduced from context | Ask before first application |

### Upgrading Confidence
- 1 observation → `Inferred`
- User confirms → `Confirmed`
- 3+ observations without correction → `Observed (3+)`
- User explicitly states → `Confirmed` (immediate)

### Knowledge Expiration
- **Never delete** learned knowledge
- **Mark as superseded** when newer conflicting knowledge arrives
- **Archive** to `.agent/memory/KNOWLEDGE_ARCHIVE.md` if scope changes (e.g., user moves to new project)

---

## 8. Specific Learning Areas

### Language & Communication
```
DETECT: What language does the user write in?
LEARN:  If user consistently uses Bahasa Indonesia → respond in Bahasa Indonesia
LEARN:  If user uses formal/informal tone → match their tone
LEARN:  If user prefers brief/detailed answers → adjust verbosity
```

### Code Style
```
DETECT: How does the user format/style their code?
LEARN:  Indentation (tabs vs spaces, 2 vs 4)
LEARN:  Naming conventions (camelCase, snake_case, PascalCase)
LEARN:  Import ordering preferences
LEARN:  Comment style (inline, block, JSDoc)
LEARN:  Error handling pattern (try-catch, Result type, Either)
LEARN:  Function style (arrow vs traditional, async patterns)
```

### Architecture
```
DETECT: What patterns does the user prefer?
LEARN:  Layer structure (MVC, Clean Architecture, Hexagonal)
LEARN:  Directory organization preferences
LEARN:  Service communication patterns
LEARN:  State management choices
LEARN:  API design patterns (REST, GraphQL, RPC)
```

### Database
```
DETECT: How does the user design schemas?
LEARN:  Primary key type (UUID, BIGINT, ULID)
LEARN:  Naming (singular/plural, prefix conventions)
LEARN:  Soft delete preference
LEARN:  Timestamp columns (created_at, updated_at, etc.)
LEARN:  Index strategy
LEARN:  Migration tool preference
```

### Security
```
DETECT: What security level does the user expect?
LEARN:  Auth method preference (JWT, session, OAuth)
LEARN:  Encryption requirements
LEARN:  Input validation style
LEARN:  Rate limiting expectations
LEARN:  CORS policy preferences
```

---

## 9. Integration with Other Systems

### With Error Memory (error-memory.md)
- When an error is caused by violating a learned preference → reference the knowledge entry
- When a correction leads to new knowledge → link both entries

### With Deep Thinking (deep-thinking.md)
- Checklist item: "Have I applied all learned knowledge rules?"
- Before any decision, check if user has expressed preference for this type of decision

### With All Workflows
Every workflow MUST include in its context-loading phase:
```
Read .agent/memory/LEARNED_KNOWLEDGE.md — Apply user's known preferences
```

---

## 10. Enforcement

- This rule is **MANDATORY** and **NON-NEGOTIABLE**
- The agent MUST read LEARNED_KNOWLEDGE.md at the start of EVERY task
- The agent MUST record user corrections **immediately** — never delay
- The agent MUST apply learned knowledge **proactively** — don't wait to be told
- The agent MUST acknowledge when learning something new
- The agent MUST NEVER argue against a user correction — learn and adapt
- The user can request their knowledge profile at any time
- Knowledge entries are **append-only** — never delete, only supersede
- When in doubt about a preference → **check knowledge first, then ask**
