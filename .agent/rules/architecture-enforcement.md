# Architecture Enforcement

## Mandatory Checks Before Writing Code

Every new file and import MUST be verified against the project's architecture:

1. **File Placement** — Verify new files go in the correct directory for the framework
2. **Dependency Direction** — Verify imports follow allowed dependency rules
3. **Naming Conventions** — Follow the framework's established patterns

## Complexity Limits

These limits are **non-negotiable**:

| Metric | Limit | Action |
|--------|-------|--------|
| File length | ≤ 1000 lines | Split into modules |
| Function/method length | ≤ 50 lines | Extract sub-functions |
| Nesting depth | ≤ 3 levels | Refactor with guard clauses or early returns |
| Function parameters | ≤ 5 params | Use options/config object |

## Anti-Spaghetti Detection

Stop and refactor when you detect:

| Pattern | Problem | Fix |
|---------|---------|-----|
| File > 1000 lines | God file | Split by responsibility |
| Function > 50 lines | God function | Extract helper functions |
| Nesting > 3 levels | Arrow code | Guard clauses, early returns |
| Circular imports | Tangled deps | Introduce shared module or interface |
| Business logic in controllers | Wrong layer | Move to service layer |
| Copy-pasted blocks | DRY violation | Extract reusable function/component |

## Dependency Direction Rules

These rules prevent architectural decay:

```
RULE: Lower layers NEVER import upper layers.
RULE: Business logic NEVER imports framework/HTTP code.
RULE: Models/entities NEVER import services or controllers.
```

**General flow:**
```
Controller/Route → Service/Use Case → Repository/Data → Model/Entity
     ↓ imports          ↓ imports         ↓ imports       ↓ imports
     ↓                  ↓                 ↓               NOTHING
```

## Architecture Presets

For detailed framework-specific folder structures and dependency rules, use the `architecture-enforcement` skill which contains:
- 10 ready-to-use presets (Next.js, React+Express, Vue/Nuxt, FastAPI, Django, Go Gin, Laravel, SvelteKit, React Native, General)
- Per-framework folder structure guides
- Universal security architecture patterns

## Violations Are P1 Critical

Architecture violations discovered during code review are classified as **P1 Critical** — must fix before merge/ship.
