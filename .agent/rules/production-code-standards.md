# Production Code Standards — Sharp & Production-Ready

> **Rule #7 — NON-NEGOTIABLE**
> Every line of code produced MUST be production-ready. No drafts, no placeholders,
> no "TODO: implement later". Ship-quality or don't ship.

---

## Pillar 1: FULL CONTEXT AWARENESS (@codebase equivalent)

### 1.1 — Mandatory Pre-Edit Analysis

**BEFORE writing or editing ANY code, the agent MUST:**

```
┌─────────────────────────────────────────────────────────┐
│  CONTEXT LOADING SEQUENCE (Execute in order)            │
├─────────────────────────────────────────────────────────┤
│  1. Read CONTEXT_INDEX.md          → Project overview   │
│  2. Read ARCHITECTURE.md           → System design      │
│  3. Read relevant source files     → Current state      │
│  4. Read related test files        → Expected behavior  │
│  5. Read package.json/composer.json→ Available deps     │
│  6. Read .env.example              → Environment vars   │
│  7. Trace import chain             → Dependencies       │
│  8. Check git diff / recent changes→ What changed       │
└─────────────────────────────────────────────────────────┘
```

### 1.2 — File Dependency Mapping

Before editing ANY file, trace ALL files that:

| Relationship | Action | Example |
|-------------|--------|---------|
| **Import from** this file | Read to understand consumers | `UserService` imported by `UserController` |
| **Are imported by** this file | Read to understand dependencies | `UserService` imports `UserRepository` |
| **Share types/interfaces** | Read to ensure type consistency | `UserDTO` used in service + controller |
| **Test** this file | Read to understand expected behavior | `userService.test.ts` |
| **Configure** this file | Read to understand environment | `.env`, config files |
| **Mirror** this file | Read to maintain consistency | i18n, API docs, OpenAPI spec |

```
Rule: NEVER edit a file without reading every file that imports it
      and every file it imports. The dependency chain MUST be complete.
```

### 1.3 — Pattern Detection Protocol

Before writing new code, the agent MUST identify:

```markdown
### Pattern Scan Results

1. **Naming Convention:** [camelCase / PascalCase / snake_case]
   Source: [file where pattern was observed]

2. **Error Handling Pattern:** [try-catch / Result type / Either monad / error callback]
   Source: [file where pattern was observed]

3. **Async Pattern:** [async/await / Promises / callbacks / RxJS]
   Source: [file where pattern was observed]

4. **State Management:** [Redux / Zustand / Context / Vuex / Pinia]
   Source: [file where pattern was observed]

5. **API Call Pattern:** [fetch / axios / ky / got / custom wrapper]
   Source: [file where pattern was observed]

6. **Validation Pattern:** [Zod / Joi / class-validator / manual / Yup]
   Source: [file where pattern was observed]

7. **Database Pattern:** [Raw SQL / Query Builder / ORM / Repository]
   Source: [file where pattern was observed]

8. **Logging Pattern:** [console.log / winston / pino / custom logger]
   Source: [file where pattern was observed]

9. **Response Format:** [{ data, error, meta } / raw / envelope / HAL]
   Source: [file where pattern was observed]

10. **Import Style:** [relative / alias (@/) / barrel exports / named]
    Source: [file where pattern was observed]
```

**VIOLATION: Introducing a new pattern without explicit user instruction = REJECT**

### 1.4 — Cross-Reference Verification

After ANY edit, verify:

```
□ All imports still resolve (no broken references)
□ All exports are consumed (no dead exports)
□ All types are compatible across files (no type mismatch)
□ All function signatures match their callers (no arg mismatch)
□ All environment variables referenced exist in .env.example
□ All database columns referenced exist in schema
□ All API endpoints referenced exist in routes
□ All constants/enums referenced are defined
```

---

## Pillar 2: SURGICAL MULTI-FILE EDITS

### 2.1 — Minimal Change Principle

```
Rule: Change ONLY what is necessary. Never rewrite a file when
      a 3-line patch will do. Every line changed is a line that
      could break something.
```

**The Surgical Edit Checklist:**

| ❌ WRONG | ✅ RIGHT |
|----------|---------|
| Rewrite entire file | Edit only changed lines |
| Reformat existing code | Preserve existing formatting |
| Rename variables for "clarity" | Keep existing naming unless buggy |
| Add "nice-to-have" improvements | Only add what was requested |
| Move code around "for organization" | Keep code in existing locations |
| Update unrelated imports | Touch only affected imports |

### 2.2 — Multi-File Edit Protocol

When a change spans multiple files, execute in this EXACT order:

```
Phase 1: TYPES & INTERFACES (contracts first)
  → Define/update types, interfaces, DTOs
  → These are the "contracts" everything depends on

Phase 2: DATABASE / SCHEMA (data layer)
  → Migrations, schema changes, seed updates
  → Data structure must exist before code references it

Phase 3: REPOSITORY / DATA ACCESS (query layer)
  → Repository methods, query functions
  → Data access must exist before services call it

Phase 4: SERVICE / BUSINESS LOGIC (logic layer)
  → Service classes, business rules, validators
  → Logic must exist before controllers use it

Phase 5: CONTROLLER / HANDLER (API layer)
  → Route handlers, middleware, request/response
  → Controllers wire everything together

Phase 6: FRONTEND / UI (presentation layer)
  → Components, pages, hooks, stores
  → UI consumes the API layer

Phase 7: TESTS (verification layer)
  → Unit tests, integration tests, E2E tests
  → Tests verify everything works together

Phase 8: CONFIGURATION & DOCS (support layer)
  → Config files, environment vars, documentation
  → Config supports the implementation
```

### 2.3 — Atomic Edit Rule

```
Rule: Each file edit MUST be atomic and independently valid.
      If the agent crashes mid-edit, every file edited so far
      must still be in a working state.
```

**Prohibited Patterns:**
- ❌ Adding an import without adding the usage
- ❌ Adding a function call without defining the function
- ❌ Changing a type without updating all usages
- ❌ Adding a route without adding the handler
- ❌ Creating a migration without updating the model
- ❌ Adding an env var reference without documenting it

### 2.4 — Edit Verification After Each File

After editing each file, mentally verify:

```typescript
// Self-check questions:
// 1. Does this file still compile/parse without errors?
// 2. Does this file still satisfy its existing tests?
// 3. Are all imports valid and used?
// 4. Are all exports consumed by at least one file?
// 5. Does the function signature match what callers expect?
// 6. Are there any undefined variables or missing types?
```

---

## Pillar 3: TEST-DRIVEN IMPLEMENTATION

### 3.1 — Test-First Mandate

```
Rule: For ANY new function, class, or endpoint — write the test
      FIRST or SIMULTANEOUSLY. Never deliver untested code.
      "I'll add tests later" = "I won't add tests."
```

### 3.2 — Test Coverage Requirements

| Code Type | Minimum Coverage | Test Types Required |
|-----------|-----------------|-------------------|
| Business logic / services | **90%** | Unit + Integration |
| API endpoints / controllers | **85%** | Integration + E2E |
| Utility functions | **95%** | Unit |
| Database queries / repos | **80%** | Integration |
| Frontend components | **75%** | Component + E2E |
| Auth / Security code | **95%** | Unit + Integration + E2E |
| Error handling paths | **100%** | Unit |
| Edge cases documented in plan | **100%** | Unit |

### 3.3 — Mandatory Test Cases for Every Function

Every function MUST have tests for:

```
┌──────────────────────────────────────────────┐
│  MANDATORY TEST MATRIX                       │
├──────────────────────────────────────────────┤
│  ✅ Happy path (normal operation)            │
│  ✅ Invalid input (bad types, missing fields)│
│  ✅ Empty input (null, undefined, "", [], {})│
│  ✅ Boundary values (0, -1, MAX_INT, etc.)   │
│  ✅ Error conditions (exceptions, failures)  │
│  ✅ Auth context (logged in, logged out)     │
│  ✅ Concurrent access (if applicable)        │
│  ✅ Idempotency (calling twice = same result)│
└──────────────────────────────────────────────┘
```

### 3.4 — Test Code Quality Standards

```typescript
// ❌ BAD: Vague test name
test('should work', () => { ... });

// ✅ GOOD: Descriptive test name with scenario
test('createUser returns 400 when email is already registered', () => { ... });

// ❌ BAD: Testing implementation details
test('calls repository.save', () => { ... });

// ✅ GOOD: Testing behavior/outcome
test('created user appears in getUserById response', () => { ... });

// ❌ BAD: Multiple assertions testing different behaviors
test('user operations', () => {
  expect(create()).toBeDefined();
  expect(update()).toBeDefined();
  expect(delete()).toBeUndefined();
});

// ✅ GOOD: One behavior per test
test('createUser returns created user with id', () => { ... });
test('updateUser updates email successfully', () => { ... });
test('deleteUser soft-deletes the record', () => { ... });
```

### 3.5 — Test File Naming & Location

```
Source:  src/services/UserService.ts
Test:    tests/unit/services/UserService.test.ts (unit)
         tests/integration/services/UserService.integration.test.ts (integration)

Source:  src/controllers/OrderController.ts
Test:    tests/integration/controllers/OrderController.test.ts

Source:  src/components/UserProfile.tsx
Test:    src/components/__tests__/UserProfile.test.tsx (co-located)
         tests/e2e/user-profile.spec.ts (E2E)
```

### 3.6 — Run Tests After Every Change

```
Rule: After completing ANY code change, the agent MUST run the
      relevant test suite and verify ALL tests pass.
      
      If tests fail → FIX IMMEDIATELY before moving to next task.
      Never leave behind failing tests.
```

```bash
# After every edit:
npm test -- --related          # run related tests
npm test -- --coverage         # verify coverage
npm run lint                   # verify code quality
npm run typecheck              # verify types (if applicable)
```

---

## Pillar 4: ZERO HALLUCINATIONS

### 4.1 — The Existence Verification Protocol

```
Rule: NEVER reference, import, call, or use ANYTHING without first
      verifying it EXISTS in the current codebase or installed packages.
```

**Before using ANY identifier, verify:**

| What | How to Verify | Consequence if Hallucinated |
|------|--------------|---------------------------|
| Import path | `ls` / `find` the actual file | ❌ Module not found error |
| Package/library | Check `package.json` / `requirements.txt` | ❌ Module not found error |
| Function/method | Read the file, find the function definition | ❌ `undefined is not a function` |
| Type/interface | Read the file, find the type definition | ❌ TypeScript compilation error |
| Database column | Read migration/schema file | ❌ SQL error at runtime |
| API endpoint | Read routes file | ❌ 404 Not Found |
| Environment variable | Read `.env.example` | ❌ `undefined` at runtime |
| CSS class | Read the stylesheet | ❌ Missing styles |
| Config property | Read config file | ❌ `undefined` config |
| CLI command | Verify tool is installed | ❌ Command not found |

### 4.2 — API/Library Usage Verification

```
Rule: When using a library API, verify the EXACT function signature
      from the installed version. Do NOT rely on memory — libraries
      change between versions.
```

**Verification Steps:**
```bash
# 1. Check installed version
cat package.json | grep "library-name"

# 2. Check actual exports (Node.js)
node -e "console.log(Object.keys(require('library-name')))"

# 3. Check TypeScript definitions
cat node_modules/library-name/dist/index.d.ts | head -50

# 4. If unsure, read the docs for the EXACT installed version
```

### 4.3 — Prohibited Hallucination Patterns

```typescript
// ❌ HALLUCINATED: Inventing a function that doesn't exist
import { validateEmail } from '@/utils/validators';  
// → Does validateEmail actually exist in that file? VERIFY FIRST.

// ❌ HALLUCINATED: Using a library method from wrong version
const result = await prisma.user.createMany({ skipDuplicates: true });
// → Does the installed Prisma version support skipDuplicates? VERIFY.

// ❌ HALLUCINATED: Referencing a database column that doesn't exist
const user = await db.query('SELECT phone_number FROM users WHERE id = ?', [id]);
// → Does the users table have a phone_number column? CHECK SCHEMA.

// ❌ HALLUCINATED: Using a CSS class that doesn't exist
<div className="card-elevated-shadow">
// → Does card-elevated-shadow exist in any stylesheet? VERIFY.

// ❌ HALLUCINATED: Using an env var that's not defined
const apiKey = process.env.STRIPE_SECRET_KEY;
// → Is STRIPE_SECRET_KEY in .env.example? VERIFY.
```

### 4.4 — When Uncertain, Ask

```
Rule: If you are not 100% certain something exists, DO NOT guess.
      Either:
      1. Read the file to verify
      2. Run a command to check
      3. Ask the user
      
      "I assumed it existed" is NEVER an acceptable excuse.
```

### 4.5 — Generated Code Audit Checklist

Before delivering ANY code, run this mental audit:

```
□ Every import path verified (file exists)
□ Every package verified (in dependency list)
□ Every function call verified (function exists with correct signature)
□ Every type reference verified (type exists in scope)
□ Every database operation verified (table/column exists)
□ Every env var verified (defined in .env.example)
□ Every API call verified (endpoint exists in routes)
□ Every file path in strings verified (file/directory exists)
□ No placeholder comments (TODO, FIXME, HACK — unless pre-existing)
□ No lorem ipsum or dummy data in production code
□ No console.log in production code (use proper logger)
□ No commented-out code blocks
```

---

## Pillar 5: TYPE-SAFE EVERYTHING

### 5.1 — Type Safety Mandate

```
Rule: Every variable, parameter, return value, and property
      MUST have an explicit type. `any` is BANNED.
      `unknown` is acceptable ONLY with proper type narrowing.
```

### 5.2 — TypeScript Strict Mode (Non-Negotiable)

The following `tsconfig.json` options are MANDATORY:

```jsonc
{
  "compilerOptions": {
    "strict": true,                    // enables ALL strict checks
    "noImplicitAny": true,             // no implicit any
    "strictNullChecks": true,          // null/undefined must be handled
    "strictFunctionTypes": true,       // strict function type checking
    "strictBindCallApply": true,       // strict bind/call/apply
    "strictPropertyInitialization": true, // class props must be initialized
    "noImplicitReturns": true,         // all paths must return
    "noFallthroughCasesInSwitch": true, // switch must have break/return
    "noUncheckedIndexedAccess": true,  // array[i] is T | undefined
    "exactOptionalPropertyTypes": true, // optional != undefined
    "noImplicitOverride": true,        // override keyword required
    "forceConsistentCasingInFileNames": true
  }
}
```

### 5.3 — Type Definition Standards

```typescript
// ❌ BAD: No types, any, implicit types
function processData(data) { ... }
function getUser(id: any): any { ... }
const result = someFunction();  // implicit any

// ✅ GOOD: Explicit types everywhere
function processData(data: ProcessDataInput): ProcessDataOutput { ... }
function getUser(id: string): Promise<User | null> { ... }
const result: CalculationResult = calculateTotal(items);
```

### 5.4 — Banned Type Patterns

| Pattern | Why Banned | Use Instead |
|---------|-----------|-------------|
| `any` | Defeats type safety entirely | Specific type, `unknown`, generic `<T>` |
| `as any` | Silences real errors | Proper type assertion with validation |
| `// @ts-ignore` | Hides type errors | Fix the actual type error |
| `// @ts-expect-error` without comment | Unclear suppression | Add explanation or fix the type |
| `!` (non-null assertion) without proof | Assumes non-null | Use optional chaining `?.` or null check |
| `Object` | Too broad | Specific interface or `Record<string, T>` |
| `Function` | No parameter/return types | Specific function signature |
| `{}` (empty object type) | Matches almost anything | Specific interface |
| Implicit return types | Consumers can't verify | Explicit return type annotation |

### 5.5 — Type Narrowing Requirements

```typescript
// ❌ BAD: Non-null assertion without proof
const user = getUser(id)!;
user.name;

// ✅ GOOD: Proper null check
const user = getUser(id);
if (!user) {
  throw new NotFoundException(`User ${id} not found`);
}
user.name; // TypeScript knows user is not null here

// ❌ BAD: Type assertion without validation
const data = JSON.parse(body) as UserInput;

// ✅ GOOD: Runtime validation + type inference
const parsed = JSON.parse(body);
const data = UserInputSchema.parse(parsed); // Zod validates and infers type

// ❌ BAD: Unchecked array access
const firstItem = items[0];
firstItem.process();

// ✅ GOOD: Checked array access
const firstItem = items[0];
if (!firstItem) {
  throw new Error('Expected at least one item');
}
firstItem.process();
```

### 5.6 — API Response Types

```typescript
// ❌ BAD: Untyped API response
app.get('/api/users', (req, res) => {
  const users = await getUsers();
  res.json(users);  // What shape is this?
});

// ✅ GOOD: Fully typed API response
interface ApiResponse<T> {
  data: T;
  error: null;
  meta: { total: number; page: number; perPage: number };
}

interface ApiErrorResponse {
  data: null;
  error: { code: string; message: string; details?: Record<string, string[]> };
  meta: null;
}

app.get('/api/users', async (req: Request, res: Response<ApiResponse<User[]> | ApiErrorResponse>) => {
  const { users, total } = await userService.findAll(req.query);
  res.json({
    data: users,
    error: null,
    meta: { total, page: Number(req.query.page) || 1, perPage: 20 },
  });
});
```

### 5.7 — Database Query Type Safety

```typescript
// ❌ BAD: Untyped raw query
const result = await db.query('SELECT * FROM users WHERE id = ?', [id]);
return result[0];  // What type is this?

// ✅ GOOD: Typed query result
interface UserRow {
  id: string;
  email: string;
  name: string;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

const [rows] = await db.query<UserRow[]>(
  'SELECT id, email, name, created_at, updated_at, deleted_at FROM users WHERE id = ?',
  [id]
);
const user: UserRow | undefined = rows[0];
if (!user) return null;
return user;
```

### 5.8 — Environment Variable Type Safety

```typescript
// ❌ BAD: Untyped env vars
const port = process.env.PORT;  // string | undefined
app.listen(port);  // could be undefined!

// ✅ GOOD: Validated and typed env
import { z } from 'zod';

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  NODE_ENV: z.enum(['development', 'staging', 'production']).default('development'),
  REDIS_URL: z.string().url().optional(),
});

export const env = envSchema.parse(process.env);
// env.PORT is number (not string | undefined)
// env.DATABASE_URL is string (guaranteed)
// env.JWT_SECRET is string with min 32 chars
```

### 5.9 — PHP Type Safety (when applicable)

```php
// ❌ BAD: No type declarations
function getUser($id) {
    return User::find($id);
}

// ✅ GOOD: Full type declarations (PHP 8.1+)
function getUser(string $id): ?User
{
    return User::find($id);
}

// ✅ GOOD: Typed properties
class CreateUserRequest extends FormRequest
{
    /** @return array<string, array<int, string>> */
    public function rules(): array
    {
        return [
            'name'  => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
        ];
    }
}
```

### 5.10 — Python Type Safety (when applicable)

```python
# ❌ BAD: No type hints
def get_user(id):
    return db.query(User).filter_by(id=id).first()

# ✅ GOOD: Full type hints
from typing import Optional

def get_user(id: str) -> Optional[User]:
    return db.query(User).filter_by(id=id).first()

# ✅ GOOD: Pydantic models for validation + types
from pydantic import BaseModel, EmailStr

class CreateUserInput(BaseModel):
    name: str
    email: EmailStr
    password: str  # min_length etc. via Field()
    
class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    created_at: datetime

    class Config:
        from_attributes = True
```

---

## Enforcement Summary

### Pre-Code Checklist (MUST complete before writing ANY code)

```
□ [PILLAR 1] Read all related source files and their imports
□ [PILLAR 1] Identified all existing patterns (naming, error handling, etc.)
□ [PILLAR 1] Mapped file dependency chain (who imports what)
□ [PILLAR 2] Identified minimal set of files to change
□ [PILLAR 2] Planned edit order (types → data → logic → API → UI → tests)
□ [PILLAR 3] Identified all test cases needed (happy + error + edge)
□ [PILLAR 4] Verified every import, function, type, column EXISTS
□ [PILLAR 5] All types explicitly defined (no any, no implicit)
```

### Post-Code Checklist (MUST complete after writing ANY code)

```
□ [PILLAR 1] All cross-references still valid (imports, exports, types)
□ [PILLAR 2] Only necessary lines were changed (no unnecessary refactoring)
□ [PILLAR 3] Tests written and passing for all new/changed code
□ [PILLAR 3] Coverage meets minimum threshold for code type
□ [PILLAR 4] No hallucinated imports, functions, types, or columns
□ [PILLAR 4] No placeholder comments (TODO/FIXME) in new code
□ [PILLAR 4] No console.log in production code
□ [PILLAR 5] No `any` type anywhere in new code
□ [PILLAR 5] All function parameters and returns have explicit types
□ [PILLAR 5] All null/undefined cases handled with proper narrowing
□ [PILLAR 5] Environment variables validated at startup
```

### Violation Severity

| Violation | Severity | Action |
|-----------|----------|--------|
| Using `any` type | 🔴 CRITICAL | Reject code, fix immediately |
| Hallucinated import/function | 🔴 CRITICAL | Reject code, verify and fix |
| Missing tests for new code | 🔴 CRITICAL | Write tests before delivering |
| Introducing new pattern without approval | 🟠 HIGH | Revert to existing pattern |
| Editing unrelated code | 🟠 HIGH | Revert unnecessary changes |
| Missing null check | 🟠 HIGH | Add proper type narrowing |
| Using `@ts-ignore` | 🟠 HIGH | Fix underlying type error |
| Missing return type | 🟡 MEDIUM | Add explicit return type |
| Test with vague name | 🟡 MEDIUM | Rename with scenario description |
| Implicit type from inference | 🟡 MEDIUM | Add explicit type annotation |

---

## Quick Reference Card

```
╔══════════════════════════════════════════════════════╗
║  PRODUCTION CODE STANDARDS — 5 PILLARS              ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  1. FULL CONTEXT AWARENESS                           ║
║     → Read EVERYTHING before writing ANYTHING        ║
║     → Map ALL file dependencies                      ║
║     → Follow ALL existing patterns                   ║
║                                                      ║
║  2. SURGICAL MULTI-FILE EDITS                        ║
║     → Change ONLY what's necessary                   ║
║     → Edit in order: types→data→logic→API→UI→tests   ║
║     → Each edit must be atomic and valid              ║
║                                                      ║
║  3. TEST-DRIVEN IMPLEMENTATION                       ║
║     → Write tests FIRST or SIMULTANEOUSLY            ║
║     → Cover happy + error + edge cases               ║
║     → Run tests after EVERY change                   ║
║                                                      ║
║  4. ZERO HALLUCINATIONS                              ║
║     → VERIFY everything exists before using it       ║
║     → No guessing imports, functions, types, columns ║
║     → When uncertain: READ the source, don't assume  ║
║                                                      ║
║  5. TYPE-SAFE EVERYTHING                             ║
║     → Explicit types on ALL params and returns       ║
║     → `any` is BANNED — use proper types             ║
║     → Validate external data at boundaries           ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```
