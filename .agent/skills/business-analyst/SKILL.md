---
name: Business Analyst
description: Skill for business analysis — covering requirements gathering, user stories, process modeling (BPMN), use case diagrams, acceptance criteria, gap analysis, and stakeholder management.
---

# Business Analyst Skill

## Overview
A **Business Analyst (BA)** bridges the gap between business needs and technical solutions. This skill covers methodologies for gathering requirements, modeling processes, and ensuring delivered solutions meet business objectives.

---

## Requirements Gathering

### Techniques
| Technique | When to Use | Output |
|-----------|-------------|--------|
| **Stakeholder Interview** | Discovery phase, understanding pain points | Interview notes, requirements list |
| **Workshop/JAD** | Group requirements, conflicting views | Consolidated requirements |
| **Survey/Questionnaire** | Large user base, quantitative data | Statistical analysis |
| **Observation** | Understanding current workflow | Process map, pain points |
| **Document Analysis** | Existing systems, regulations | Gap analysis, compliance matrix |
| **Prototyping** | Complex UI, unclear requirements | Wireframes, mockups |

### Requirements Template
```markdown
## Requirement: [REQ-001] User Registration

**Priority:** High | Medium | Low
**Type:** Functional | Non-Functional | Business Rule
**Source:** [Stakeholder name / Workshop date]
**Status:** Draft → Reviewed → Approved → Implemented → Verified

### Description
As a [user type], I want to [action] so that [business value].

### Acceptance Criteria
GIVEN [precondition]
WHEN [action]
THEN [expected result]

### Business Rules
- BR-001: Email must be unique
- BR-002: Password minimum 12 characters
- BR-003: Age must be ≥ 18 for Data Spesifik processing (UU PDP)

### Dependencies
- DEP-001: SMTP server for verification email
- DEP-002: Turnstile CAPTCHA integration

### Non-Functional Requirements
- NFR-001: Registration must complete within 3 seconds
- NFR-002: Support 100 concurrent registrations
```

---

## User Stories (Agile)

```markdown
## Epic: User Management

### User Story: US-001 — User Registration
**As a** new visitor
**I want to** create an account with my email
**So that** I can access personalized features

**Acceptance Criteria:**
- [ ] User can register with email + password
- [ ] Email verification is sent within 30 seconds
- [ ] Duplicate email shows clear error message
- [ ] Password strength indicator is shown
- [ ] User is redirected to dashboard after verification
- [ ] Consent for data processing is captured (UU PDP)

**Story Points:** 5
**Sprint:** Sprint 3
**Dependencies:** US-000 (Authentication system setup)

### Definition of Done:
- [ ] Code complete with unit tests (≥80% coverage)
- [ ] Code reviewed and approved
- [ ] Integration tests passing
- [ ] Documentation updated
- [ ] Product Owner acceptance
```

---

## Process Modeling (BPMN)

```
Order Processing Flow:

[Start] → [Customer Places Order] → [Validate Payment]
                                           │
                                    ┌──────┴──────┐
                                    ▼              ▼
                              [Payment OK]   [Payment Failed]
                                    │              │
                                    ▼              ▼
                          [Process Order]    [Notify Customer]
                                    │              │
                                    ▼              ▼
                          [Ship Order]        [End]
                                    │
                                    ▼
                          [Send Tracking]
                                    │
                                    ▼
                              [End]
```

---

## Use Case Template

```markdown
## Use Case: UC-003 — Process Refund

**Actor:** Customer, Admin
**Preconditions:** Order exists, within refund window (14 days)
**Trigger:** Customer requests refund

### Main Flow (Happy Path):
1. Customer navigates to order history
2. Customer selects order and clicks "Request Refund"
3. System validates refund eligibility
4. Customer selects reason and submits
5. Admin reviews refund request
6. System processes refund to original payment method
7. System sends confirmation email to customer
8. System updates order status to "Refunded"

### Alternative Flows:
- 3a. Order not eligible → Show reason, suggest contact support
- 5a. Admin rejects → Notify customer with reason
- 6a. Payment refund fails → Retry, if fail notify admin

### Postconditions:
- Refund amount credited to customer
- Order status updated
- Inventory updated (if product returned)
- Audit trail created
```

---

## Gap Analysis

```markdown
## Gap Analysis: Current vs Desired State

| Area | Current State | Desired State | Gap | Priority |
|------|--------------|---------------|-----|----------|
| Auth | Username/password only | SSO + MFA | No SSO integration | High |
| Data | Manual CSV exports | Automated reporting | No BI dashboards | High |
| Mobile | No mobile support | Responsive + PWA | Full redesign needed | Medium |
| Security | Basic auth | UU PDP compliant | No consent management | Critical |
| Payments | Bank transfer only | Multiple payment options | No payment gateway | High |
```

---

## RACI Matrix

```markdown
| Activity | Product Owner | BA | Developer | QA | DevOps |
|----------|:------------:|:--:|:---------:|:--:|:------:|
| Gather requirements | C | R | I | I | — |
| Write user stories | A | R | C | I | — |
| UI/UX design | A | C | R | I | — |
| Development | I | C | R | — | C |
| Testing | I | C | — | R | — |
| Deployment | A | — | C | C | R |

R = Responsible, A = Accountable, C = Consulted, I = Informed
```

---

## Deliverables Checklist

```
Discovery Phase
□ Stakeholder map
□ Current state analysis
□ Pain points documented
□ Business objectives defined
□ Success metrics (KPIs) defined

Analysis Phase
□ Requirements document (BRD)
□ User stories with acceptance criteria
□ Process flow diagrams
□ Use case diagrams
□ Data dictionary
□ Gap analysis
□ Non-functional requirements

Design Phase
□ Wireframes / mockups reviewed
□ Data model reviewed
□ Integration points identified
□ Security requirements (UU PDP checklist)

Delivery Phase
□ UAT test cases prepared
□ UAT executed and signed off
□ Training materials created
□ Handover documentation
```

## Best Practices
1. **Start with WHY** — understand business value before requirements
2. **Testable acceptance criteria** — GIVEN-WHEN-THEN format
3. **Prioritize ruthlessly** — MoSCoW (Must/Should/Could/Won't)
4. **Involve stakeholders early** — avoid surprise at UAT
5. **Document decisions** — ADR (Architecture Decision Records)
6. **Validate with prototypes** — wireframes before code
