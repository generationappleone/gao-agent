# Agent Error Memory — Mistake Log

> This file records every mistake the AI agent makes, along with the correct approach.
> The agent MUST read this file before performing tasks to avoid repeating past mistakes.
> 
> **Format:** One entry per mistake, newest at the top.
> **Reference:** The agent searches this file for relevant prevention rules before coding.

## Quick Reference — Prevention Rules

<!-- This section is updated with each new entry. It contains ONLY the prevention rules for fast lookup. -->

| ID | Prevention Rule | Category |
|----|----------------|----------|
| ERR-2026-02-21-006 | BEFORE writing E2E tests, check actual HTTP status codes of controllers: `@Post()` returns 201 by default, `@Post()` with `@HttpCode(HttpStatus.OK)` returns 200. NEVER assume both are 200. | Test Failure |
| ERR-2026-02-21-005 | E2E tests against real AppModule FAIL if DB/Redis not running. ALWAYS use inline TestAppModule (no DB) for E2E smoke tests, or skip with `--passWithNoTests` | Test Failure |
| ERR-2026-02-21-004 | BEFORE writing multi_replace_file_content, ALWAYS read the EXACT current content of the file first with view_file. Never assume the file content matches the intended TargetContent — even if you just wrote it | Wrong Approach |
| ERR-2026-02-21-003 | Webhook secret validation in E2E: if test controller is @Public without secret check, it passes through. Test the real WebhooksController with InternalApiGuard if you want to test secret rejection | Wrong Approach |
| ERR-2026-02-21-002 | IDE lint errors "Cannot find module '@nestjs/common'" in TypeScript workspace are FALSE POSITIVES when tsconfig.json rootDir is inside a subdirectory. ALWAYS verify with `npm run build` (nest build) — not IDE errors | Wrong Approach |
| ERR-2026-02-21-001 | `@prisma/client` only exports types AFTER `prisma generate` is run. If `AdminUser` appears missing in IDE, it's a type-check false positive. NEVER change import paths — run build to verify | Wrong Approach |

---

## Error Entries

<!-- New entries are added below this line, newest first -->

---

### ERR-2026-02-21-006 — E2E Test: @Post() Returns 201 Not 200 by Default

**Date:** 2026-02-21 10:35
**Category:** Test Failure
**Severity:** Medium
**Workflow:** /context-work
**File(s):** `backend/test/app.e2e-spec.ts`

#### ❌ What Went Wrong
E2E test asserted `.expect(200)` on a `POST /api/auth/login` endpoint, but the actual response was `201`. NestJS `@Post()` handlers return **201 Created** by default — not 200.

#### 🔍 Root Cause
Assumed all POST endpoints return 200. Forgot that NestJS defaults `@Post()` to HTTP 201, and only returns 200 if `@HttpCode(HttpStatus.OK)` is explicitly added.

#### ✅ Correct Approach
```typescript
// Returns 201 (default for @Post)
@Post('login')
login() { return { redirectUrl: '...' }; }

// Returns 200 (explicitly set)
@Post('login')
@HttpCode(HttpStatus.OK)
login() { return { redirectUrl: '...' }; }
```
Tests should use `expect([200, 201]).toContain(res.status)` OR check the actual controller decorator.

#### 🛡️ Prevention Rule
- IF writing E2E or unit tests for a `@Post()` endpoint THEN first check if `@HttpCode()` is present. Default `@Post()` = 201, `@Get()` = 200, `@Delete()` = 200, `@Patch()` = 200.
- BEFORE asserting `.expect(200)` on POST ALWAYS verify the controller has `@HttpCode(HttpStatus.OK)`
- NEVER assume POST returns 200 without checking the controller decorator

---

### ERR-2026-02-21-005 — E2E Tests Failed: Real AppModule Requires DB Connection

**Date:** 2026-02-21 10:25
**Category:** Test Failure
**Severity:** High
**Workflow:** /context-work
**File(s):** `backend/test/app.e2e-spec.ts`

#### ❌ What Went Wrong
Wrote E2E tests importing the real `AppModule`. Tests failed immediately because Prisma could not connect to PostgreSQL (`localhost:5432/portal_admin_test` was not running). All 15 tests failed with connection errors.

```
Error: P1001: Can't reach database server at `localhost:5432`
```

#### 🔍 Root Cause
E2E tests that import the real `AppModule` (which includes `DatabaseModule` → `PrismaService`) REQUIRE a live database connection. In CI and local dev without Docker running, this will always fail.

#### ✅ Correct Approach
**Strategy A** — Inline TestModule (no DB):
```typescript
// Create minimal inline module that mirrors routes but has no DB
@Module({
  imports: [ConfigModule, PassportModule, JwtModule.register({...})],
  controllers: [TestHealthController, TestAuthController, ...],
})
class TestAppModule {}
```

**Strategy B** — Real AppModule with mocked PrismaService:
```typescript
const moduleFixture = await Test.createTestingModule({ imports: [AppModule] })
  .overrideProvider(PrismaService)
  .useValue(mockPrismaService)
  .compile();
```

**Strategy C** — Integration tests only in CI with Docker:
```
# Only run E2E when Docker is up
docker-compose up -d && npm run test:e2e:integration
```

#### 🛡️ Prevention Rule
- IF writing E2E tests for NestJS THEN use inline TestModule (no real DB import) for smoke tests
- BEFORE importing real AppModule in E2E ALWAYS confirm Docker services are available
- NEVER write E2E tests that require live DB unless they are tagged as `:integration` and run separately
- ALWAYS separate unit/smoke tests (no infra) from integration tests (requires Docker)

---

### ERR-2026-02-21-004 — multi_replace_file_content Failed: TargetContent Not Found

**Date:** 2026-02-21 10:30
**Category:** Wrong Approach
**Severity:** Medium
**Workflow:** /context-work
**File(s):** `backend/test/app.e2e-spec.ts`

#### ❌ What Went Wrong
Called `multi_replace_file_content` with `TargetContent` strings that did not exactly match the current file content. Tool returned `"Could not successfully apply any edits"` for all 3 chunks.

#### 🔍 Root Cause
After writing the file, the actual content had slightly different whitespace or indentation than expected (e.g., tabs vs spaces, CRLF vs LF). The `TargetContent` was based on what was intended to write, not on what was actually in the file.

#### ✅ Correct Approach
1. After writing a file, always call `view_file` to read the EXACT current content before using `multi_replace_file_content`
2. Copy-paste the exact lines from `view_file` output (with line numbers) as `TargetContent`
3. For large multi-chunk edits when file just changed, prefer `write_to_file` with `Overwrite: true` instead

```
WORKFLOW:
1. view_file → read exact current content
2. multi_replace_file_content with exact TargetContent from step 1
```

#### 🛡️ Prevention Rule
- BEFORE calling multi_replace_file_content on any file ALWAYS call view_file first to get the EXACT current content
- IF file was recently modified (in this session) THEN re-read it before replacing — content may differ from what was written
- IF multi_replace fails THEN use write_to_file with Overwrite:true as fallback for complete rewrites
- NEVER assume TargetContent from memory matches the file — always verify with view_file

---

### ERR-2026-02-21-003 — Webhook Secret Test: @Public Controller Does Not Check Secret

**Date:** 2026-02-21 10:27
**Category:** Wrong Approach
**Severity:** Low
**Workflow:** /context-work
**File(s):** `backend/test/app.e2e-spec.ts`

#### ❌ What Went Wrong
Wrote E2E test expecting `POST /api/admin/webhooks/nexus` to return 401 with wrong secret. The `TestWebhooksController` was marked `@Public()` but had no secret validation logic — so wrong secrets still returned 200/201.

#### 🔍 Root Cause
In the real `WebhooksController`, the `InternalApiGuard` checks the `x-webhook-secret` header via `req.header('x-webhook-secret')` and compares to `INTERNAL_API_KEY_NEXUS`. In the test module, this guard was not applied to the test controller.

#### ✅ Correct Approach
To test webhook secret validation, either:
1. Apply the real `InternalApiGuard` to the test webhook controller explicitly
2. Or test secret validation in a dedicated unit test for `InternalApiGuard`
3. Or use the integration test approach (real AppModule + Docker)

For E2E smoke tests, accept that `@Public` test controllers bypass guards:
```typescript
// Correct E2E assertion for @Public endpoint:
expect(res.status).not.toBe(401); // Only verifies it's accessible
```

#### 🛡️ Prevention Rule
- IF writing E2E test for webhook/internal secret validation THEN use the real guard in test setup OR write a unit test for the guard
- BEFORE asserting 401 on any endpoint ALWAYS verify that the relevant guard is applied in the test module
- Test controller stubs with `@Public()` will NEVER return 401 — they bypass all auth guards

---

### ERR-2026-02-21-002 — IDE TypeScript Lint Errors as False Positives

**Date:** 2026-02-21 10:15
**Category:** Wrong Approach
**Severity:** Low
**Workflow:** /context-work
**File(s):** `backend/src/main.ts`, all `backend/src/**/*.ts`

#### ❌ What Went Wrong
IDE feedback showed `"Cannot find module '@nestjs/common'"` and `"Cannot find module '@prisma/client'"` in multiple files. Initially treated these as real build errors requiring fixes.

#### 🔍 Root Cause
The workspace root is `X:\Project\bcp-admin\` which contains both `frontend/` and `backend/` directories. The IDE's TypeScript language server uses the root-level `tsconfig.json` which does NOT include `backend/node_modules`. This causes ALL imports from `node_modules` to appear unresolved in the IDE.

These are **workspace-level false positives** — the TypeScript compiler (invoked via `nest build` from inside `backend/`) has the correct `tsconfig.json` and `node_modules` context, so build succeeds.

#### ✅ Correct Approach
- ALWAYS verify TypeScript errors by running `npm run build` (or `nest build`) inside the correct subdirectory
- IDE lint errors showing "Cannot find module" in a multi-root workspace are LIKELY false positives
- Build exit code 0 = no real errors, regardless of what the IDE shows

```bash
cd backend
npm run build  # This is the source of truth — NOT the IDE
```

#### 🛡️ Prevention Rule
- IF IDE shows "Cannot find module" THEN run `npm run build` in the subdirectory BEFORE making any code changes
- NEVER change import paths based solely on IDE lint errors in a multi-root workspace
- ALWAYS use build command output (exit code 0/1) as the authoritative source of TypeScript errors
- Pattern: IDE errors in multi-package monorepo ≠ build errors

---

### ERR-2026-02-21-001 — AdminUser Missing from @prisma/client IDE Error

**Date:** 2026-02-21 10:12
**Category:** Wrong Approach
**Severity:** Low
**Workflow:** /context-work
**File(s):** `backend/src/auth/auth.controller.ts`, `backend/src/modules/partners/partners.controller.ts`

#### ❌ What Went Wrong
IDE showed: `Module '"@prisma/client"' has no exported member 'AdminUser'`. This appeared after adding Swagger imports to the auth controller. Almost prompted a fix to change the import path.

#### 🔍 Root Cause
`AdminUser` IS exported from `@prisma/client` AFTER running `prisma generate`. The IDE false positive occurred because the workspace tsconfig does not point to `backend/node_modules/@prisma/client` which is where the generated types live. This is the same root cause as ERR-2026-02-21-002 (multi-root workspace).

Prisma generates TypeScript types into `backend/node_modules/@prisma/client/index.d.ts` during `prisma generate`. The build compiler finds this file correctly.

#### ✅ Correct Approach
- Run `npm run build` to confirm no real error
- Keep the import: `import { AdminUser } from '@prisma/client'` — it is correct
- Do NOT change the import or create workarounds for IDE-only issues

#### 🛡️ Prevention Rule
- IF IDE shows Prisma type not found THEN run `npm run build` — if it passes, the import is correct
- BEFORE changing any Prisma imports due to IDE errors ALWAYS verify with `npx prisma generate` + `npm run build`
- NEVER add type workarounds (e.g., `import type { AdminUser }` from a custom path) for Prisma-generated types based on IDE-only errors
