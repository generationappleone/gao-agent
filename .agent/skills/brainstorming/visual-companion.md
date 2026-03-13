# Visual Companion for Brainstorming

How to use visual tools as part of the brainstorming process.

---

## When to Use Visual Brainstorming

- User describes a UI, dashboard, or landing page
- The idea involves layout or component placement
- Abstract concepts benefit from visual representation
- User says "I want something that looks like..."

## Image Generation (Primary)

Use the `generate_image` tool to create visual mockups during brainstorming:

### Phase 2 — Explore Approaches Visually

When presenting 2-3 approaches, offer: "Want me to generate a quick visual mockup of each approach?"

### Prompt Writing Guide

| Element | Good Prompt | Bad Prompt |
|---------|-------------|-----------|
| Layout | "Clean dashboard layout with sidebar nav, header stats, data table" | "A dashboard" |
| Style | "Dark theme, glassmorphism cards, blue-purple gradient accents" | "Make it look nice" |
| Content | "Show user analytics: active users chart, revenue KPI, recent orders table" | "Show some data" |
| Specificity | "Mobile-first, cards stacked vertically, bottom tab navigation" | "Mobile version" |

### Iteration Pattern

```
1. Generate initial mockup
2. Ask: "Does this capture the direction? What would you change?"
3. Refine based on feedback
4. Max 3 iterations during brainstorming (detail comes in planning)
```

## Browser Subagent (Secondary)

Use `browser_subagent` to research visual references:

```markdown
"Let me look at how [competing product] handles this UI pattern."
```

### Use Cases
- Finding UI patterns from existing products
- Checking how a specific component looks in practice
- Comparing different design approaches
- Validating responsiveness of similar implementations

## Integration with Brainstorming

| Brainstorming Phase | Visual Tool Use |
|--------------------|-----------------| 
| Phase 1 (Understand) | Reference similar UIs via browser |
| Phase 2 (Explore) | Generate mockups for each approach |
| Phase 4 (Capture) | Include final mockup in brainstorm document |
| Phase 4.6 (Visual Companion) | Offer to generate implementation-ready mockup |

## Key Principle

> Visual mockups during brainstorming are for **direction**, not **pixel-perfection**.
> Save detailed design for the planning and implementation phases.
