---
name: Project Management
description: Skill for software project management — covering Agile (Scrum/Kanban), sprint planning, estimation, risk management, milestone tracking, team velocity, and project documentation.
---

# Project Management Skill

## Overview
Software project management ensures projects are delivered on time, within scope, and with quality. This skill covers Agile methodologies, estimation techniques, risk management, and project tracking.

---

## Agile Methodologies

### Scrum
```
Sprint Cycle (1-4 weeks):

Sprint Planning → Daily Standup → Sprint Review → Sprint Retrospective
     │                │                │                │
     ↓                ↓                ↓                ↓
  Select stories    15 min sync     Demo to          What went well?
  from backlog      What I did      stakeholders     What to improve?
  Define sprint     What I'll do    Get feedback     Action items
  goal              Blockers?       Accept/reject
```

### Kanban
```
┌──────────┬──────────┬────────────┬──────────┬────────┐
│ Backlog  │  To Do   │In Progress │  Review  │  Done  │
│          │  (WIP:3) │  (WIP:3)   │ (WIP:2)  │        │
├──────────┼──────────┼────────────┼──────────┼────────┤
│ Story 8  │ Story 5  │ Story 3    │ Story 1  │ ✅ A   │
│ Story 9  │ Story 6  │ Story 4    │ Story 2  │ ✅ B   │
│ Story 10 │ Story 7  │            │          │ ✅ C   │
│ Story 11 │          │            │          │        │
└──────────┴──────────┴────────────┴──────────┴────────┘
```

---

## Estimation

### Story Points (Fibonacci)
| Points | Complexity | Example |
|--------|-----------|---------|
| 1 | Trivial | Fix typo, update copy |
| 2 | Simple | Add field to existing form |
| 3 | Small | New API endpoint (simple CRUD) |
| 5 | Medium | Feature with frontend + backend |
| 8 | Large | Complex feature, multiple integrations |
| 13 | Very Large | Major feature, needs design review |
| 21 | Epic | Should be broken down further |

### T-Shirt Sizing (for roadmap level)
| Size | Duration | Description |
|------|----------|-------------|
| XS | 1-2 days | Minor change, well-understood |
| S | 3-5 days | Small feature, one developer |
| M | 1-2 weeks | Feature requiring design + implementation |
| L | 2-4 weeks | Major feature, multiple components |
| XL | 1-2 months | Epic, needs decomposition |

---

## Sprint Planning Template

```markdown
## Sprint [N] Planning — [Start Date] to [End Date]

### Sprint Goal
[One sentence describing what we aim to achieve]

### Capacity
| Team Member | Available Days | Carry-Over | Available Points |
|-------------|---------------|------------|-----------------|
| Developer A | 9/10 | 0 | 18 |
| Developer B | 8/10 | 3 | 13 |
| QA | 10/10 | 0 | N/A |
| **Total** | | **3** | **31 SP** |

### Selected Stories
| ID | Story | Points | Assignee | Priority |
|----|-------|--------|----------|----------|
| US-101 | User login with Google OAuth | 5 | Dev A | Must |
| US-102 | Dashboard KPI cards | 8 | Dev B | Must |
| US-103 | Email notification preferences | 3 | Dev A | Should |
| US-104 | Export data to CSV | 3 | Dev B | Should |
| BUG-22 | Fix date picker timezone | 2 | Dev A | Must |
| **Total** | | **21 / 31** | | |

### Risks & Dependencies
- US-101 depends on Google OAuth credentials (pending from IT)
- US-102 needs finalized KPI definitions from PM
```

---

## Risk Management

```markdown
## Risk Register

| ID | Risk | Impact | Likelihood | Mitigation | Owner | Status |
|----|------|--------|-----------|------------|-------|--------|
| R1 | Key developer leaves | High | Low | Knowledge sharing, documentation | PM | Monitor |
| R2 | Third-party API changes | Medium | Medium | Version pin, abstraction layer | Tech Lead | Active |
| R3 | Scope creep | High | High | Strict change control, sprint goals | PM | Active |
| R4 | Security vulnerability | High | Medium | Automated scanning, code review | Dev Lead | Active |
| R5 | Data breach (UU PDP) | Critical | Low | Encryption, access control, audit | DPO | Active |
```

---

## Project Status Report

```markdown
## Weekly Status Report — Week [N]

### Overall Status: 🟢 On Track / 🟡 At Risk / 🔴 Blocked

### Progress
- Sprint velocity: 24 SP (target: 28 SP)
- Burndown: 70% complete (day 7/10)
- Bugs found: 3 (2 fixed, 1 in progress)

### Completed This Week
- ✅ US-101: Google OAuth integration
- ✅ US-103: Email notification preferences

### In Progress
- 🔄 US-102: Dashboard KPI cards (80%)
- 🔄 BUG-22: Date picker timezone fix

### Blockers
- ⛔ US-104: Waiting for API credentials from vendor

### Next Week Focus
- Complete US-102, US-104
- Begin US-105: User profile settings
- Sprint review & demo (Friday)

### Metrics
| Metric | This Week | Last Week | Trend |
|--------|-----------|-----------|-------|
| Velocity | 24 SP | 28 SP | ↓ |
| Bug Count | 3 | 5 | ↑ |
| Deploy Frequency | 4 | 3 | ↑ |
| Lead Time | 3 days | 4 days | ↑ |
```

---

## Definition of Done (DoD)

```
Feature is DONE when:
□ Code complete and follows project conventions
□ Unit tests written (≥80% coverage for new code)
□ Integration tests for API endpoints
□ Code reviewed and approved (≥1 reviewer)
□ No lint errors or type errors
□ Security scan passed (no critical/high)
□ Documentation updated (if user-facing)
□ QA tested on staging environment
□ Product Owner accepted
□ Merged to main branch
□ Deployed to staging
```

## Best Practices
1. **Sprint goal over story count** — focus on outcome, not output
2. **Sustainable pace** — capacity planning prevents burnout
3. **Retrospective actions** — implement at least 1 improvement per sprint
4. **Transparent communication** — status should never be a surprise
5. **Technical debt budget** — allocate 20% of capacity for tech debt
6. **Definition of Done** — agreed by whole team, consistently enforced
