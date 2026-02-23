# Memory Pruning & Maintenance — Mandatory Agent Rule

> **Priority: MEDIUM** — This rule governs the lifecycle management of memory files to prevent unbounded growth and maintain relevance.

## Core Directive

The agent's memory files (`ERROR_LOG.md` and `LEARNED_KNOWLEDGE.md`) must be actively maintained to remain useful. Without pruning, memory files grow indefinitely, slow down pre-task reading, and accumulate stale or redundant entries.

---

## 1. Memory File Size Limits

| File | Max Entries | Max Size | Action When Exceeded |
|------|------------|----------|---------------------|
| `ERROR_LOG.md` | 50 entries | ~50 KB | Archive oldest entries |
| `LEARNED_KNOWLEDGE.md` | 30 entries | ~30 KB | Consolidate similar entries |

---

## 2. Auto-Pruning Protocol

### When to Prune
The agent MUST check and prune memory files when:
1. **Adding a new entry** — Check current entry count before appending
2. **Starting a new session** — Quick size check during pre-task protocol
3. **Explicitly requested** — User runs `/context-reload` or asks to clean memory

### How to Prune

#### Step 1: Count Entries
```
Count entries matching pattern: ### ERR-* (for ERROR_LOG)
Count entries matching pattern: ### LRN-* (for LEARNED_KNOWLEDGE)
```

#### Step 2: Evaluate Entries for Removal
Entries are candidates for removal if:
- **Duplicated** — Same root cause documented multiple times
- **Superseded** — A newer entry covers the same topic with better information
- **Obsolete** — The technology, version, or context is no longer relevant to the project
- **Low confidence** — Learned knowledge marked as "Initial (1)" that was never reinforced

#### Step 3: Archive (Do Not Delete)
Move pruned entries to archive files:
- `ERROR_LOG.md` → `.agent/memory/archive/ERROR_LOG_ARCHIVE.md`
- `LEARNED_KNOWLEDGE.md` → `.agent/memory/archive/LEARNED_KNOWLEDGE_ARCHIVE.md`

Archive format:
```markdown
## Archived Entries — [Date]

### [Original Entry ID]
**Archived On:** [Date]
**Reason:** [Duplicate | Superseded | Obsolete | Low Confidence]
**Original Content:**
[Full original entry content]
```

---

## 3. Consolidation Rules

### For ERROR_LOG.md
When multiple errors share the same root cause:
1. Keep the **most recent** entry with the best prevention rule
2. Add a note: `**Consolidated from:** ERR-XXX, ERR-YYY`
3. Archive the older entries

### For LEARNED_KNOWLEDGE.md
When multiple learnings are about the same topic:
1. Merge into a **single comprehensive entry**
2. Update the confidence level to the highest observed
3. Combine all action rules into one entry
4. Add: `**Consolidated from:** LRN-XXX, LRN-YYY`

---

## 4. Entry Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Created    │ →  │   Active    │ →  │   Stale     │ →  │  Archived   │
│  (new entry) │    │ (referenced │    │ (>6 months  │    │ (moved to   │
│              │    │  regularly) │    │  no use)    │    │  archive/)  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Staleness Criteria
An entry is considered **stale** if:
- It has not been referenced or triggered in the last 6 months
- The project no longer uses the technology it refers to
- The framework version has changed significantly (e.g., Laravel 10 → 12)

---

## 5. Forbidden Actions

- ❌ **NEVER hard-delete** memory entries without archiving first
- ❌ **NEVER prune entries** that were triggered in the current session
- ❌ **NEVER remove entries** about security vulnerabilities (they are always relevant)
- ❌ **NEVER consolidate** entries from different categories into one

---

## 6. Maintenance Schedule

| Trigger | Action |
|---------|--------|
| New entry added + total > limit | Prune oldest/lowest-value entries |
| User runs `/context-reload` | Quick health check on memory file sizes |
| Every 10th session (approximate) | Full review: consolidate, archive stale entries |
| User explicitly requests cleanup | Full prune + consolidation + report |

---

## 7. Reporting

After any pruning operation, report:
```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧹 MEMORY MAINTENANCE REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ERROR_LOG.md:    [X] entries → [Y] entries ([Z] archived)
LEARNED_KNOWLEDGE.md: [X] entries → [Y] entries ([Z] consolidated)
Archive location: .agent/memory/archive/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
