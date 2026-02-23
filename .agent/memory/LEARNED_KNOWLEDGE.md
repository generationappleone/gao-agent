# Agent Self-Learning — Learned Knowledge Base

> This file contains everything the agent has learned from user interactions.
> The agent reads this file BEFORE every task and applies ALL relevant rules.
> Knowledge is cumulative — entries are NEVER deleted, only refined.
>
> **Format:** One entry per learned item, organized by category.
> **Last Updated:** 2026-02-21T10:41:00+07:00

## Quick Reference — Active Rules

<!-- Fast lookup table for all learned rules. Updated with each new entry. -->

| ID | Rule | Scope | Source |
|----|------|-------|--------|
| LRN-2026-02-19-001 | Respond in Bahasa Indonesia when user writes in Bahasa Indonesia | Global | Observed (3+) |
| LRN-2026-02-19-002 | User builds comprehensive agent skills & workflows for multi-framework support | Project-Specific | Observed (3+) |
| LRN-2026-02-19-003 | User values depth, detail, and completeness — never deliver shallow/minimal work | Global | Confirmed |
| LRN-2026-02-19-004 | User wants security-first approach in all development | Global | Confirmed |
| LRN-2026-02-21-001 | NestJS @Post() returns 201 by default — NOT 200. Use @HttpCode(HttpStatus.OK) to override | NestJS | Confirmed |
| LRN-2026-02-21-002 | E2E tests must NEVER import real AppModule unless Docker services are confirmed running | NestJS/Testing | Confirmed |
| LRN-2026-02-21-003 | multi_replace_file_content: ALWAYS view_file first to get exact current content | Agent Behavior | Confirmed |
| LRN-2026-02-21-004 | IDE "Cannot find module" in multi-root workspace = false positive. Use `npm run build` to confirm | TypeScript/Monorepo | Confirmed |
| LRN-2026-02-21-005 | Prisma-generated types (AdminUser, etc.) are only visible after `prisma generate`. IDE errors are false positives | Prisma | Confirmed |
| LRN-2026-02-21-006 | User expects errors to be logged in memory immediately during/after task — not just fixed silently | Global | Confirmed |

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

### LRN-2026-02-21-006 — Error Must Be Logged Immediately

**Date:** 2026-02-21 10:41
**Source:** Confirmed (user request)
**Confidence:** Confirmed
**Scope:** Global

#### 📝 What Was Learned
User expects that after any session involving errors-and-fixes, the agent PROACTIVELY updates `ERROR_LOG.md` and `LEARNED_KNOWLEDGE.md` WITHOUT being asked. The agent must not wait for the user to request this — it should happen as part of standard workflow completion.

#### 💡 Apply When
After every task/sprint/session that involved any error detection, wrong approach, or multi-step fix cycle.

#### 🔧 Action Rule
- IF any error was encountered and fixed during a task THEN log it in ERROR_LOG.md BEFORE marking the task complete
- AFTER a plan is completed ALWAYS check if any errors occurred during execution and log them
- NEVER silently fix errors without logging them — the user values traceability
- IF user never specifically asks to log errors THEN STILL log them (self-initiated)

---

## Category: Architecture & Patterns

### LRN-2026-02-21-002 — NestJS E2E Testing: Never Use Real AppModule Without Infrastructure

**Date:** 2026-02-21 10:25
**Source:** Confirmed
**Confidence:** Confirmed
**Scope:** NestJS Projects

#### 📝 What Was Learned
E2E tests in NestJS that import the real `AppModule` (containing `DatabaseModule`, `RedisModule`, etc.) WILL FAIL in any environment where the external services (PostgreSQL, Redis) are not running. This is a very common mistake.

#### 💡 Apply When
Any NestJS project with E2E tests.

#### 🔧 Action Rule
- IF writing E2E smoke tests (can run without Docker) THEN create inline `TestAppModule` with minimal controllers (no DB/Redis)
- IF writing integration tests (require Docker) THEN tag them separately as `*.e2e-integration.spec.ts` and run only in CI with Docker
- ALWAYS separate "smoke" (no infra) from "integration" (requires infra) test types
- Use `jest --testPathPattern='smoke'` and `jest --testPathPattern='integration'` to separate them

#### 🔧 Template: Inline Test Module
```typescript
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, ignoreEnvFile: true }),
    PassportModule,
    JwtModule.register({ secret: 'test-secret', signOptions: { expiresIn: '15m' } }),
  ],
  controllers: [/* minimal test controllers */],
})
class TestAppModule {}
```

---

## Category: Coding Style

### LRN-2026-02-21-001 — NestJS HTTP Status Code Defaults

**Date:** 2026-02-21 10:35
**Source:** Confirmed
**Confidence:** Confirmed
**Scope:** NestJS Projects

#### 📝 What Was Learned
NestJS HTTP decorator default status codes:
- `@Get()` → **200** OK
- `@Post()` → **201** Created  ← This is the common gotcha!
- `@Put()` → **200** OK
- `@Patch()` → **200** OK
- `@Delete()` → **200** OK

To override, use `@HttpCode(HttpStatus.OK)` on the method.

#### 💡 Apply When
Writing NestJS controllers and writing tests that assert specific HTTP status codes.

#### 🔧 Action Rule
- IF writing test for a `@Post()` endpoint THEN check if `@HttpCode()` decorator is present
- IF no `@HttpCode()` on `@Post()`, THEN expect 201, NOT 200
- IF writing auth login endpoint (convention: returns 200 with redirectUrl) THEN ALWAYS add `@HttpCode(HttpStatus.OK)` explicitly

---

## Category: Database & Schema

<!-- No entries yet — will be populated as preferences are observed -->

---

## Category: Technology Preferences

### LRN-2026-02-21-003 — TypeScript Monorepo: IDE Lint vs Build Reality

**Date:** 2026-02-21 10:15
**Source:** Confirmed
**Confidence:** Confirmed
**Scope:** TypeScript Monorepos / Multi-root Workspaces

#### 📝 What Was Learned
In a monorepo where the IDE workspace root is different from the individual app directory (e.g., `bcp-admin/` contains both `frontend/` and `backend/`), the IDE TypeScript language server uses the root `tsconfig.json`. This causes ALL dependencies from subdirectory `node_modules` to appear as unresolved, producing false "Cannot find module" errors.

#### 💡 Apply When
Any project with multiple apps in one workspace folder (monorepo or multi-app structure).

#### 🔧 Action Rule
- IF IDE shows "Cannot find module" for well-known packages (like `@nestjs/common`, `@prisma/client`) THEN FIRST run `npm run build` in the correct subdirectory
- IF `npm run build` exits with code 0 THEN the IDE errors are FALSE POSITIVES — do NOT change code
- IF `npm run build` fails THEN the errors are real — fix them
- NEVER modify import paths, tsconfig, or add workarounds based solely on IDE squiggles in a monorepo

### LRN-2026-02-21-004 — Prisma: Types Require `prisma generate`

**Date:** 2026-02-21 10:12
**Source:** Confirmed
**Confidence:** Confirmed
**Scope:** All Prisma Projects

#### 📝 What Was Learned
Prisma types (`AdminUser`, `PartnerStatus`, etc.) are generated into `node_modules/@prisma/client/index.d.ts` by running `prisma generate`. Before this runs, or if the IDE can't see `backend/node_modules`, types appear missing.

#### 💡 Apply When
Any project using Prisma ORM.

#### 🔧 Action Rule
- IF Prisma types appear missing in IDE THEN check if `prisma generate` was run
- BEFORE assuming a Prisma type doesn't exist ALWAYS try: `npx prisma generate` + `npm run build`
- IF `npm run build` passes with Prisma type imports THEN the types exist — IDE is wrong
- NEVER create manual type definitions for Prisma models — always use the generated types

---

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

## Category: Agent Behavior & Self-Improvement

### LRN-2026-02-21-005 — view_file Before multi_replace_file_content

**Date:** 2026-02-21 10:30
**Source:** Confirmed (error caused task rework)
**Confidence:** Confirmed
**Scope:** All Tasks

#### 📝 What Was Learned
The `multi_replace_file_content` tool requires **exact** character-sequence match for `TargetContent`. If the file was recently written or modified (even in the same session), the actual content may differ slightly from what was intended (whitespace, newlines, encoding). This causes ALL chunks to fail with "target content not found".

#### 💡 Apply When
Any time `multi_replace_file_content` or `replace_file_content` is used on a recently-modified file.

#### 🔧 Action Rule
- BEFORE calling `multi_replace_file_content` ALWAYS call `view_file` on the target file first
- Copy-paste exact lines from `view_file` output into `TargetContent` — never write from memory
- IF multiple chunks fail THEN use `write_to_file` with `Overwrite: true` as the fallback strategy (complete rewrite)
- IF the file is small (< 200 lines) AND multiple chunks need changing THEN prefer `write_to_file` over `multi_replace_file_content`

---

## Category: UI/UX Preferences

<!-- No entries yet — will be populated as preferences are observed -->
