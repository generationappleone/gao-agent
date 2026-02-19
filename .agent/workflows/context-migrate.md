---
description: Manage database migrations safely — generate, review, apply, rollback, and seed. Use for any database schema changes.
---

# Context Migrate Workflow

This workflow provides a **safe, structured approach** to database migrations. It handles migration generation, review, application, rollback, and seeding across different ORMs and frameworks.

## Steps

1. **Read project context** — Load `DATABASE_SCHEMA.md` and `ARCHITECTURE.md`.
   // turbo

2. **Detect ORM/migration tool** — Auto-detect:
   // turbo
   ```bash
   # Check for migration tools
   ls prisma/schema.prisma 2>/dev/null && echo "Prisma detected"
   ls database/migrations/ 2>/dev/null && echo "Laravel migrations detected"
   find . -path "*/migrations/*.py" -not -path '*/venv/*' 2>/dev/null | head -1 && echo "Django/Alembic detected"
   ls -d */migrations/ 2>/dev/null
   ```

3. **Determine action** — Ask the user:
   ```markdown
   🗄️ Database Migration

   What do you need?
   1. ➕ Create new migration (add table, column, index)
   2. ✏️ Modify existing table (add/drop column, change type)
   3. 🔄 Run pending migrations
   4. ⏪ Rollback last migration
   5. 🔍 Check migration status
   6. 🌱 Seed database with test data
   7. 🔄 Fresh migration (drop all + re-migrate + seed)
   ```

4. **For new/modify migrations** — Follow `rules/database-design.md`:
   - UUID primary keys (never auto-increment for public-facing)
   - Audit columns: `created_at`, `updated_at`
   - Soft delete: `deleted_at` column
   - snake_case naming, plural table names
   - Indexes on foreign keys and frequently queried columns
   - Generate migration file following framework conventions

5. **Review migration** — Present the migration for review:
   ```markdown
   ## Migration Review

   **File:** `[migration path]`
   **Action:** [CREATE TABLE / ALTER TABLE / DROP TABLE]

   ### Changes
   | Column | Type | Nullable | Default | Index | Notes |
   |--------|------|----------|---------|-------|-------|
   | id | UUID | No | gen_random_uuid() | PK | Primary key |
   | ... | ... | ... | ... | ... | ... |

   ### Compliance Check
   - [x] UUID primary key ✅
   - [x] created_at + updated_at ✅
   - [x] deleted_at (soft delete) ✅
   - [x] Foreign key indexes ✅
   - [x] snake_case naming ✅
   ```

6. **⛔ Ask approval** — "Migration looks correct? Shall I apply it?"

7. **Apply migration** — Execute:
   // turbo
   ```bash
   # Prisma
   npx prisma migrate dev --name [name] 2>&1

   # Laravel
   php artisan migrate 2>&1

   # Django
   python manage.py migrate 2>&1

   # TypeORM
   npx typeorm migration:run 2>&1
   ```

8. **Verify** — Confirm migration applied:
   // turbo
   ```bash
   # Prisma
   npx prisma migrate status 2>&1

   # Laravel
   php artisan migrate:status 2>&1

   # Django
   python manage.py showmigrations 2>&1
   ```

9. **Update documentation** — Update `DATABASE_SCHEMA.md` with new tables/columns.

10. **Report** — Migration summary.

## When to Use
- Adding new database tables
- Modifying existing columns
- Adding indexes or constraints
- Database seeding
- Migration troubleshooting

## When to Skip
- No database changes needed
- Using NoSQL without schema (check anyway)
