# Agent Self-Learning — Learned Knowledge Base

> This file contains everything the agent has learned from user interactions.
> The agent reads this file BEFORE every task and applies ALL relevant rules.
> Knowledge is cumulative — entries are NEVER deleted, only refined.
>
> **Format:** One entry per learned item, organized by category.
> **Last Updated:** 2026-02-19T20:48:00+07:00

## Quick Reference — Active Rules

<!-- Fast lookup table for all learned rules. Updated with each new entry. -->

| ID | Rule | Scope | Source |
|----|------|-------|--------|
| LRN-2026-02-19-001 | Respond in Bahasa Indonesia when user writes in Bahasa Indonesia | Global | Observed (3+) |
| LRN-2026-02-19-002 | User builds comprehensive agent skills & workflows for multi-framework support | Project-Specific | Observed (3+) |
| LRN-2026-02-19-003 | User values depth, detail, and completeness — never deliver shallow/minimal work | Global | Confirmed |
| LRN-2026-02-19-004 | User wants security-first approach in all development | Global | Confirmed |

---

## Category: Communication & Language

### LRN-2026-02-19-001 — Bahasa Indonesia Communication

**Date:** 2026-02-19 20:48
**Source:** Observed (3+)
**Confidence:** Observed (3+)
**Scope:** Global

#### 📝 What Was Learned
User consistently communicates in Bahasa Indonesia. Agent should respond in Bahasa Indonesia when user writes in Bahasa Indonesia, and English when user writes in English.

#### 💡 Apply When
All conversations where user writes in Bahasa Indonesia.

#### 🔧 Action Rule
- IF user writes in Bahasa Indonesia THEN respond in Bahasa Indonesia
- IF user writes in English THEN respond in English
- IF mixed language THEN follow the dominant language of the message

---

## Category: Workflow & Process

### LRN-2026-02-19-002 — Comprehensive Agent Framework

**Date:** 2026-02-19 20:48
**Source:** Observed (3+)
**Confidence:** Observed (3+)
**Scope:** Project-Specific

#### 📝 What Was Learned
User is building a comprehensive AI agent framework (gao-agent) with skills, workflows, and rules. User expects thorough, production-grade skill files covering APIs, code examples, and best practices for each technology.

#### 💡 Apply When
Creating or updating any skills, workflows, or rules in .agent/ directory.

#### 🔧 Action Rule
- IF creating skill files THEN include API examples, architecture overview, SDKs, best practices, and security notes
- IF creating workflows THEN bind to relevant skills and rules, include detailed step-by-step phases
- IF creating rules THEN make them comprehensive with enforcement, examples, and anti-patterns

---

### LRN-2026-02-19-003 — Depth & Completeness Expected

**Date:** 2026-02-19 20:48
**Source:** Confirmed
**Confidence:** Confirmed
**Scope:** Global

#### 📝 What Was Learned
User explicitly requested that all agent processes must be "tajam, mendalam, detail, jelas, lengkap" (sharp, deep, detailed, clear, complete). User does not tolerate shallow or minimal output.

#### 💡 Apply When
Every task — code, documentation, analysis, planning, debugging.

#### 🔧 Action Rule
- IF producing any output THEN ensure it is thorough, detailed, and complete
- NEVER deliver minimal/placeholder/stub responses
- ALWAYS consider edge cases, security, and error handling

---

## Category: Architecture & Patterns

<!-- No entries yet — will be populated as preferences are observed -->

## Category: Coding Style

<!-- No entries yet — will be populated as preferences are observed -->

## Category: Database & Schema

<!-- No entries yet — will be populated as preferences are observed -->

## Category: Technology Preferences

<!-- No entries yet — will be populated as preferences are observed -->

## Category: Project Conventions

### LRN-2026-02-19-004 — Security-First Development

**Date:** 2026-02-19 20:48
**Source:** Confirmed
**Confidence:** Confirmed
**Scope:** Global

#### 📝 What Was Learned
User emphasizes security awareness in every process. Agent must proactively consider security implications without being asked.

#### 💡 Apply When
All development tasks — coding, architecture, database design, deployment.

#### 🔧 Action Rule
- IF writing any code THEN consider security implications proactively
- IF designing database THEN consider data encryption, access control
- IF building API THEN include authentication, authorization, rate limiting, input validation
- NEVER skip security considerations even for prototypes

---

## Category: UI/UX Preferences

<!-- No entries yet — will be populated as preferences are observed -->
