---
name: System Analyst
description: Skill for system analysis — covering requirements analysis, system modeling (UML, ERD, DFD), feasibility studies, technical specifications, and system integration planning.
---

# System Analyst Skill

## Overview
A **System Analyst (SA)** bridges business requirements and technical implementation. They analyze existing systems, design technical solutions, and create specifications that developers follow. This skill covers SA methodologies and deliverables.

---

## System Analysis Process

```
1. Problem Analysis    → Understand current system pain points
2. Feasibility Study   → Technical, economic, operational feasibility
3. Requirements Analysis→ Functional & non-functional specs
4. System Modeling     → UML, ERD, DFD, sequence diagrams
5. Technical Design    → Architecture, database, API design
6. Specification Doc   → SRS (Software Requirements Specification)
7. Integration Plan    → How new system connects with existing systems
```

---

## UML Diagrams

### Class Diagram
```
┌─────────────────┐     1    *  ┌─────────────────┐
│      User       │────────────│      Order      │
├─────────────────┤            ├─────────────────┤
│- id: UUID       │            │- id: UUID       │
│- email: string  │            │- userId: UUID   │
│- fullName: string│           │- status: enum   │
│- role: enum     │            │- totalAmount: decimal│
├─────────────────┤            ├─────────────────┤
│+ register()     │            │+ create()       │
│+ login()        │            │+ cancel()       │
│+ updateProfile()│            │+ calculateTotal()│
└─────────────────┘            └────────┬────────┘
                                   1   │   *
                               ┌───────┴────────┐
                               │   OrderItem    │
                               ├────────────────┤
                               │- productId: UUID│
                               │- quantity: int  │
                               │- unitPrice: decimal│
                               └────────────────┘
```

### Sequence Diagram
```
User          Frontend       API Server      Database       Email Service
 │               │               │               │               │
 │──Register────→│               │               │               │
 │               │──POST /register→              │               │
 │               │               │──Check email──→│               │
 │               │               │←─Not exists───│               │
 │               │               │──Insert user──→│               │
 │               │               │←─Created──────│               │
 │               │               │──Send verify──────────────────→│
 │               │               │←─Sent─────────────────────────│
 │               │←─201 Created──│               │               │
 │←─Success──────│               │               │               │
```

### Entity Relationship Diagram (ERD)
```
┌──────────┐    ┌──────────────┐    ┌──────────┐
│  users   │───<│   orders     │>───│ products │
├──────────┤    ├──────────────┤    ├──────────┤
│ PK id    │    │ PK id        │    │ PK id    │
│ email    │    │ FK user_id   │    │ name     │
│ name     │    │ FK address_id│    │ price    │
│ role     │    │ status       │    │ stock    │
│ password │    │ total        │    │ category │
└──────────┘    │ created_at   │    └──────────┘
                └──────────────┘
                       │
                ┌──────┴───────┐
                │ order_items  │
                ├──────────────┤
                │ FK order_id  │
                │ FK product_id│
                │ quantity     │
                │ unit_price   │
                └──────────────┘
```

### Data Flow Diagram (DFD)
```
Level 0 (Context):
  [User] → (System) → [External Payment Gateway]
                     → [Email Service]

Level 1:
  [User] → [1. Authentication] → [User Store]
  [User] → [2. Order Processing] → [Order Store] → [3. Payment] → [Payment Gateway]
  [3. Payment] → [4. Notification] → [Email Service]
```

---

## Software Requirements Specification (SRS)

```markdown
# SRS — [System Name]

## 1. Introduction
### 1.1 Purpose
### 1.2 Scope
### 1.3 Definitions & Abbreviations
### 1.4 References

## 2. System Overview
### 2.1 System Context (DFD Level 0)
### 2.2 System Functions
### 2.3 User Characteristics
### 2.4 Constraints & Assumptions

## 3. Functional Requirements
### FR-001: User Registration
- Input: email, password, full_name
- Process: Validate, hash password, store, send verification
- Output: User created, verification email sent
- Business Rules: BR-001, BR-002

### FR-002: [Next feature]...

## 4. Non-Functional Requirements
### NFR-001: Performance — Page load < 3s
### NFR-002: Availability — 99.9% uptime
### NFR-003: Security — UU PDP compliance

## 5. Data Model (ERD)
## 6. API Specifications
## 7. UI Wireframes
## 8. Integration Points
## 9. Appendices
```

---

## Feasibility Study Template

```markdown
## Feasibility Study: [Project Name]

### Technical Feasibility
- Technology stack available and mature? [Yes/No]
- Team has required skills? [Yes/No]
- Infrastructure can support requirements? [Yes/No]
- Integration with existing systems possible? [Yes/No]
- Risk: [Low / Medium / High]

### Economic Feasibility
- Development cost estimate: Rp [amount]
- Infrastructure cost (monthly): Rp [amount]
- Expected ROI: [percentage]
- Payback period: [months]
- Risk: [Low / Medium / High]

### Operational Feasibility
- Users willing to adopt new system? [Yes/No]
- Training requirements: [hours]
- Change management plan needed? [Yes/No]
- Compliance requirements met? [UU PDP, ISO 27001]
- Risk: [Low / Medium / High]

### Recommendation
[Proceed / Proceed with modifications / Do not proceed]
```

## Deliverables Checklist
```
□ System Context Diagram (DFD Level 0)
□ Use Case Diagram
□ Entity Relationship Diagram (ERD)
□ Sequence Diagrams (key flows)
□ Class Diagram (domain model)
□ Software Requirements Specification (SRS)
□ API Specification (OpenAPI/Swagger)
□ Database Design Document
□ Integration Architecture Diagram
□ Non-Functional Requirements Document
□ Feasibility Study (if new project)
□ Technical Risk Assessment
```

## Best Practices
1. **Start with business process** — understand workflow before designing systems
2. **Use standard notation** — UML, BPMN, ERD (not custom diagrams)
3. **Keep it visual** — diagrams > walls of text
4. **Validate with stakeholders** — review diagrams with business + tech teams
5. **Version control specs** — SRS changes should be tracked
6. **Traceability** — every FR maps to a user story, test case, and code module
