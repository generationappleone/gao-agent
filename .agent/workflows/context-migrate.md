---
description: Manage database migrations safely — generate, review, apply, rollback, and seed. Use for any database schema changes.
---

# Context Migrate — Safe Database Migration Management

## Purpose
This workflow provides a **safe, structured approach** to database migrations. It handles migration generation, review, compliance checking, application, rollback, seeding, and documentation updates — all with safety verification at every step.

> **Key Principle:** Every migration is reviewed, approved, and verified before proceeding. Irreversible changes (DROP TABLE, DROP COLUMN) require extra confirmation.

---

## Activation
The user triggers this workflow by:
- Using `/context-migrate` to see migration options
- Using `/context-migrate create [table_name]` to create a new migration
- Using `/context-migrate status` to check migration status
- Using `/context-migrate rollback` to revert last migration
- Using `/context-migrate seed` to populate data

---

## Phase 0: State Recovery (Auto-Handoff)
// turbo
1. Check if `.agent/context/ACTIVE_TASK.md` exists.
2. If it exists AND is not marked as completed, read it immediately.
3. Acknowledge the exact last state and resume execution natively from that point without asking the user.
4. Every time you finish a step or reach rate limits, proactively update `ACTIVE_TASK.md` with current progress.

## Phase 0.5: Agent Lock Check (Race Condition Prevention)
// turbo
1. Check if `.agent/context/AGENT_LOCK` exists.
2. If it exists, STOP! Another agent is currently executing. Inform the user and abort.
3. If it does not exist, immediately create `.agent/context/AGENT_LOCK` with the current timestamp.
4. IMPORTANT: Meticulously delete `.agent/context/AGENT_LOCK` at the very end of this workflow OR whenever you pause to ask the user a question.

## Phase 1: Context & Detection

### Step 1.1 — Read Project Context
// turbo
```
1. .agent/context/DATABASE_SCHEMA.md ← Current schema
2. .agent/context/ARCHITECTURE.md    ← ORM/data layer patterns
3. .agent/rules/database-design.md   ← Database conventions (MANDATORY)
4. .agent/rules/deep-thinking.md     ← Deep thinking & quality standards (MANDATORY)
```

### Step 1.1b — Read Database & ORM Skills
// turbo
Based on detected database and ORM, read the relevant skills:
- **Prisma ORM**: `skills/prisma/SKILL.md`
- **Laravel/Eloquent**: `skills/laravel/SKILL.md`, `skills/laravel-seeder/SKILL.md`
- **Django ORM**: `skills/django/SKILL.md`
- **TypeORM/Sequelize**: `skills/nodejs/SKILL.md`
- **Entity Framework**: `skills/aspnet/SKILL.md`

Based on detected database engine:
- **PostgreSQL**: `skills/postgresql/SKILL.md`
- **MySQL**: `skills/mysql/SKILL.md`
- **MongoDB**: `skills/mongodb/SKILL.md`
- **SQL Server**: `skills/sql-server/SKILL.md`
- **Oracle**: `skills/oracle/SKILL.md`

### Step 1.2 — Detect ORM/Migration Tool
// turbo
```bash
# Auto-detect migration framework
ls prisma/schema.prisma 2>/dev/null && echo "✅ Prisma ORM detected"
ls database/migrations/ 2>/dev/null && echo "✅ Laravel migrations detected"
find . -path "*/migrations/*.py" -not -path '*/venv/*' 2>/dev/null | head -1 && echo "✅ Django/Alembic detected"
ls migrations/ 2>/dev/null && echo "✅ TypeORM/Sequelize migrations detected"
ls db/migrate/ 2>/dev/null && echo "✅ Rails migrations detected"
cat go.mod 2>/dev/null | grep "gorm\|goose\|migrate" && echo "✅ Go migration tool detected"
cat *.csproj 2>/dev/null | grep "EntityFramework" && echo "✅ EF Core detected"
```

### Step 1.3 — Check Current Status
// turbo
```bash
# Prisma
npx prisma migrate status 2>&1 | head -20

# Laravel
php artisan migrate:status 2>&1 | head -20

# Django
python manage.py showmigrations 2>&1 | head -20

# TypeORM
npx typeorm migration:show 2>&1 | head -20
```

### Step 1.4 — Determine Action

```markdown
🗄️ Database Migration

What do you need?
1. ➕ **Create migration** — Add new table, column, index
2. ✏️ **Modify table** — Alter existing columns/constraints
3. ▶️ **Run migrations** — Apply all pending migrations
4. ⏪ **Rollback** — Revert last migration(s)
5. 🔍 **Check status** — View migration status
6. 🌱 **Seed data** — Populate with test/initial data
7. 🔄 **Fresh** — Drop all + re-migrate + seed (development only)
8. 📊 **Schema dump** — Export current schema
```

---

## Phase 2: Migration Generation

### Step 2.1 — Apply Database Design Rules

ALL migrations MUST follow `.agent/rules/database-design.md`:

| Rule | Requirement | Check |
|------|-------------|-------|
| Primary Key | UUID (never auto-increment for public-facing tables) | ✅ Required |
| Audit Columns | `created_at` TIMESTAMP NOT NULL DEFAULT NOW() | ✅ Required |
| Audit Columns | `updated_at` TIMESTAMP NOT NULL DEFAULT NOW() | ✅ Required |
| Soft Delete | `deleted_at` TIMESTAMP NULL (optional, recommended) | 🔶 Recommended |
| Naming | snake_case for columns, plural for table names | ✅ Required |
| Foreign Keys | Explicit FK constraints with ON DELETE/ON UPDATE | ✅ Required |
| Indexes | On all FK columns and frequently queried columns | ✅ Required |
| Encoding | UTF-8 / utf8mb4 for text columns | ✅ Required |
| Constraints | NOT NULL by default, NULL only when justified | ✅ Required |

### Step 2.2 — Generate Migration

Based on the detected framework:

**Prisma:**
```bash
# Update schema.prisma first, then generate migration
npx prisma migrate dev --name [name] --create-only 2>&1
```

**Laravel:**
```bash
php artisan make:migration create_[table]_table 2>&1
# or
php artisan make:migration add_[column]_to_[table]_table 2>&1
```

**Django:**
```bash
python manage.py makemigrations [app_name] 2>&1
```

**TypeORM:**
```bash
npx typeorm migration:create src/migrations/[Name] 2>&1
```

### Step 2.3 — Write Migration Content

Generate the migration file content:

```markdown
### Migration: [action]_[table/column]

**File:** `[migration file path]`
**Action:** CREATE TABLE / ALTER TABLE / ADD INDEX / DROP COLUMN
```

Include the full migration code following framework conventions:

#### Example (Prisma):
```prisma
model Notification {
  id          String    @id @default(uuid()) @db.Uuid
  userId      String    @map("user_id") @db.Uuid
  title       String    @db.VarChar(255)
  body        String    @db.Text
  readAt      DateTime? @map("read_at")
  createdAt   DateTime  @default(now()) @map("created_at")
  updatedAt   DateTime  @updatedAt @map("updated_at")
  deletedAt   DateTime? @map("deleted_at")

  user        User      @relation(fields: [userId], references: [id])

  @@index([userId])
  @@index([deletedAt])
  @@map("notifications")
}
```

#### Example (Laravel):
```php
Schema::create('notifications', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('user_id')->constrained()->onDelete('cascade');
    $table->string('title', 255);
    $table->text('body');
    $table->timestamp('read_at')->nullable();
    $table->timestamps();  // created_at, updated_at
    $table->softDeletes(); // deleted_at
    $table->index('user_id');
    $table->index('deleted_at');
});
```

---

## Phase 3: Migration Review

### Step 3.1 — Compliance Check

```markdown
### 📋 Migration Compliance Check

| Rule | Status | Notes |
|------|--------|-------|
| UUID primary key | ✅ / ❌ | [details] |
| created_at column | ✅ / ❌ | [details] |
| updated_at column | ✅ / ❌ | [details] |
| deleted_at column | ✅ / ⬜ N/A | [details] |
| snake_case naming | ✅ / ❌ | [details] |
| plural table name | ✅ / ❌ | [details] |
| FK constraints | ✅ / ⬜ N/A | [details] |
| FK indexes | ✅ / ⬜ N/A | [details] |
| NOT NULL defaults | ✅ / ❌ | [details] |
| UTF-8 encoding | ✅ / ❌ | [details] |

**Result:** ✅ COMPLIANT / ❌ NON-COMPLIANT — [issues to fix]
```

### Step 3.2 — Destructive Change Warning

If the migration contains destructive operations:

```markdown
⚠️ DESTRUCTIVE MIGRATION DETECTED

This migration contains irreversible changes:

| # | Operation | Detail | Risk |
|---|-----------|--------|------|
| 1 | DROP TABLE | [table_name] | 🔴 DATA LOSS |
| 2 | DROP COLUMN | [table].[column] | 🔴 DATA LOSS |
| 3 | ALTER TYPE | [column] narrowing | 🟠 Potential data truncation |

**⛔ REQUIRES EXPLICIT CONFIRMATION:**
- Are you sure? This cannot be undone.
- Have you backed up the database?
- Is this on development or production?
```

### Step 3.3 — Rollback Plan

For every migration, verify a rollback exists:

```markdown
### Rollback Plan

**Forward (Up):** [what the migration does]
**Rollback (Down):** [what reverting the migration does]

Rollback verified: ✅ Yes — `down()` method exists
```

### Step 3.4 — User Approval

```markdown
⛔ Review the migration above.

- ✅ **Apply** — Run this migration
- ✏️ **Modify** — Change the migration
- ❌ **Cancel** — Don't apply
```

---

## Phase 4: Migration Execution

### Step 4.1 — Pre-Execution Check
// turbo
```bash
# Verify database connectivity
# Framework-specific connection test
```

### Step 4.2 — Apply Migration
// turbo
```bash
# Prisma
npx prisma migrate dev 2>&1 | tail -20

# Laravel
php artisan migrate 2>&1 | tail -20

# Django
python manage.py migrate 2>&1 | tail -20

# TypeORM
npx typeorm migration:run 2>&1 | tail -20
```

### Step 4.3 — Post-Migration Verification
// turbo
```bash
# Verify migration applied successfully
# Prisma
npx prisma migrate status 2>&1

# Laravel
php artisan migrate:status 2>&1 | tail -20

# Check the new table/column exists
# Framework-specific schema inspection
```

### Step 4.4 — Run Tests
// turbo
```bash
# Ensure migrations don't break existing tests
npm test 2>&1 | tail -30
# or
php artisan test 2>&1 | tail -30
# or
pytest 2>&1 | tail -30
```

---

## Phase 5: Rollback (If Requested)

### Step 5.1 — Rollback Confirmation

```markdown
⚠️ Migration Rollback

Rolling back: [last migration name]
This will: [undo description]

Proceed? (yes / no)
```

### Step 5.2 — Execute Rollback
// turbo
```bash
# Prisma
npx prisma migrate reset --skip-seed 2>&1

# Laravel
php artisan migrate:rollback 2>&1

# Django
python manage.py migrate [app_name] [previous_migration_number] 2>&1

# TypeORM
npx typeorm migration:revert 2>&1
```

### Step 5.3 — Verify Rollback
// turbo
```bash
# Check migration status
# Run tests to confirm nothing broken
npm test 2>&1 | tail -20
```

---

## Phase 6: Seeding

### Step 6.1 — Load Seeder Skill
// turbo
If Laravel, read `skills/laravel-seeder/SKILL.md` for patterns.

### Step 6.2 — Generate/Run Seeders
// turbo
```bash
# Laravel
php artisan db:seed 2>&1

# Prisma
npx prisma db seed 2>&1

# Django
python manage.py loaddata fixtures/*.json 2>&1
```

### Step 6.3 — Verify Seed Data
// turbo
```bash
# Quick verification that seed data exists
# Framework-specific queries
```

---

## Phase 7: Documentation & Report

### Step 7.1 — Update DATABASE_SCHEMA.md

Add new tables/columns to `.agent/context/DATABASE_SCHEMA.md`:

```markdown
### [table_name]
| Column | Type | Nullable | Default | Index | Description |
|--------|------|----------|---------|-------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| [column] | [type] | [yes/no] | [default] | [index] | [description] |
| created_at | TIMESTAMP | No | NOW() | — | Created timestamp |
| updated_at | TIMESTAMP | No | NOW() | — | Updated timestamp |
| deleted_at | TIMESTAMP | Yes | NULL | IDX | Soft delete |
```

### Step 7.2 — Migration Report

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ MIGRATION COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action:     [CREATE TABLE / ALTER TABLE / ROLLBACK / SEED]
Migration:  [migration file name]
Tables:     [affected tables]
Compliance: ✅ All rules followed
Tests:      ✅ All passing
Schema Doc: ✅ Updated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next: /context-work to continue implementation
```

---

## When to Use
- Adding new database tables
- Modifying existing columns or constraints
- Adding indexes
- Database seeding (test or initial data)
- Schema troubleshooting
- Before deploying schema changes

## When to Skip
- No database changes needed
- Using schemaless NoSQL without validation (but consider adding it)
- Migration is auto-handled by `/context-work` during plan execution
