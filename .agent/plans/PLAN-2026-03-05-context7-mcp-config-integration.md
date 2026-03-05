# Implementation Plan: Context7 MCP Configuration Templates for GAO Agent

> **Created:** 2026-03-05T12:16:00+07:00
> **Status:** ✅ Completed (2026-03-05T12:30:00+07:00)
> **Requested by:** User
> **Estimated Effort:** 3-4 hours
> **Risk Level:** Low
> **Brainstorm:** Discussed in conversation (Context7 MCP analysis)

---

## 1. Executive Summary

Proyek ini menambahkan **MCP Configuration Templates** ke dalam GAO Agent framework agar user yang mengadopsi GAO Agent bisa langsung mendapatkan template konfigurasi Context7 MCP (dan MCP server lainnya) untuk **20+ AI coding client** — termasuk **Google Antigravity** sebagai target utama.

Saat ini, GAO Agent sudah punya skill file untuk Context7 di `.agent/skills/mcp-context7/SKILL.md`, tapi belum ada:
1. Template config file yang siap pakai untuk setiap AI client
2. Template environment variable untuk API key management
3. Panduan setup yang terpusat
4. Integrasi otomatis dengan workflow `/context-mcp-check`

Plan ini menambahkan **folder baru** `.agent/mcp-configs/` berisi semua template tersebut, **update skill file** Context7 dengan informasi integrasi GAO Agent, dan **update workflow** `/context-mcp-check` agar bisa auto-setup MCP server.

---

## 2. Application Flow Diagram

### 2.1 User Setup Flow

```
User install GAO Agent (.agent/ folder)
              │
              ▼
     ┌─────────────────────┐
     │ User buka project    │
     │ di AI client (misal  │
     │ Antigravity, Cursor) │
     └─────────┬───────────┘
               │
               ▼
     ┌─────────────────────┐
     │ User lihat folder    │
     │ .agent/mcp-configs/  │
     │ → Pilih template     │
     │   sesuai client-nya  │
     └─────────┬───────────┘
               │
      ┌────────┴────────┐
      │                 │
      ▼                 ▼
 [Manual Copy]    [/context-mcp-check]
  Template →       Auto-detect client
  Config file      Generate config
      │                 │
      ▼                 ▼
  ┌──────────────────────────┐
  │ User isi API key dari     │
  │ context7.com/dashboard    │
  │ ke .env atau config file  │
  └──────────┬───────────────┘
             │
             ▼
  ┌──────────────────────────┐
  │ Context7 MCP AKTIF        │
  │ → Library docs real-time  │
  │ → Zero API hallucination  │
  └──────────────────────────┘
```

### 2.2 System Architecture

```
.agent/
├── mcp-configs/                    ← NEW FOLDER
│   ├── README.md                   ← Panduan setup terpusat
│   ├── .env.mcp.example            ← Template API keys
│   └── templates/                  ← Template per client
│       ├── antigravity.mcp.json    ← Google Antigravity (PRIMARY)
│       ├── cursor.mcp.json         ← Cursor
│       ├── vscode.mcp.json         ← VS Code
│       ├── claude-code.md          ← Claude Code (CLI commands)
│       ├── claude-desktop.mcp.json ← Claude Desktop
│       ├── windsurf.mcp.json       ← Windsurf
│       ├── openai-codex.toml       ← OpenAI Codex
│       ├── copilot.mcp.json        ← GitHub Copilot
│       ├── jetbrains.mcp.json      ← JetBrains IDEs
│       ├── gemini-cli.json         ← Gemini CLI
│       ├── kiro.mcp.json           ← Kiro
│       ├── kilocode.mcp.json       ← Kilo Code
│       ├── roo-code.mcp.json       ← Roo Code
│       ├── cline.mcp.json          ← Cline
│       ├── augment-code.json       ← Augment Code
│       ├── opencode.mcp.json       ← Opencode
│       ├── zed.json                ← Zed
│       ├── warp.mcp.json           ← Warp
│       ├── qwen-code.json          ← Qwen Code
│       ├── amazon-q.mcp.json       ← Amazon Q Developer
│       ├── lm-studio.mcp.json      ← LM Studio
│       ├── visual-studio.mcp.json  ← Visual Studio 2022
│       ├── trae.mcp.json           ← Trae
│       └── windows-cmd.mcp.json    ← Windows CMD wrapper
│
├── skills/
│   └── mcp-context7/
│       └── SKILL.md                ← UPDATED (add GAO Agent integration)
│
└── workflows/
    └── context-mcp-check.md        ← UPDATED (add auto-setup phase)
```

---

## 3. Database Changes

N/A — GAO Agent adalah framework documentation/config, bukan aplikasi dengan database.

---

## 4. Application Structure Changes

### 4.1 New Files

```
.agent/
└── mcp-configs/
    ├── README.md                      ← NEW: Panduan setup MCP terpusat
    ├── .env.mcp.example               ← NEW: Template env vars untuk semua MCP API keys
    └── templates/
        ├── antigravity.mcp.json       ← NEW: Google Antigravity config
        ├── cursor.mcp.json            ← NEW: Cursor config
        ├── vscode.mcp.json            ← NEW: VS Code config
        ├── claude-code.md             ← NEW: Claude Code CLI instructions
        ├── claude-desktop.mcp.json    ← NEW: Claude Desktop config
        ├── windsurf.mcp.json          ← NEW: Windsurf config
        ├── openai-codex.toml          ← NEW: OpenAI Codex config (TOML)
        ├── copilot.mcp.json           ← NEW: GitHub Copilot config
        ├── jetbrains.mcp.json         ← NEW: JetBrains config
        ├── gemini-cli.json            ← NEW: Gemini CLI config
        ├── kiro.mcp.json              ← NEW: Kiro config
        ├── kilocode.mcp.json          ← NEW: Kilo Code config
        ├── roo-code.mcp.json          ← NEW: Roo Code config
        ├── cline.mcp.json             ← NEW: Cline config
        ├── augment-code.json          ← NEW: Augment Code config
        ├── opencode.mcp.json          ← NEW: Opencode config
        ├── zed.json                   ← NEW: Zed config
        ├── warp.mcp.json              ← NEW: Warp config
        ├── qwen-code.json             ← NEW: Qwen Code config
        ├── amazon-q.mcp.json          ← NEW: Amazon Q config
        ├── lm-studio.mcp.json         ← NEW: LM Studio config
        ├── visual-studio.mcp.json     ← NEW: Visual Studio 2022 config
        ├── trae.mcp.json              ← NEW: Trae config
        └── windows-cmd.mcp.json       ← NEW: Windows CMD wrapper config
```

**Total new files: 27 files**

### 4.2 Modified Files

| File | Changes | Reason |
|------|---------|--------|
| `.agent/skills/mcp-context7/SKILL.md` | Add GAO Agent integration section, update tools info, add all-clients reference | Link skill to new config templates |
| `.agent/workflows/context-mcp-check.md` | Add Phase 6: Auto-Setup MCP Servers | Enable auto-generate config from templates |
| `.agent/AGENTS.md` | Add MCP Config Management section under Available Skills | Register new capability |

### 4.3 Deleted Files

None.

---

## 5. Code Changes Detail

### 5.1 `.agent/mcp-configs/README.md`

**File:** `.agent/mcp-configs/README.md`
**Action:** New
**Reason:** Central documentation hub for all MCP config templates

**Content structure:**
- Overview of what MCP Config Templates are
- Quick Start guide (3 steps: choose template → copy → add API key)
- Table of all supported clients with config file location
- How to get Context7 API key
- Security notes (never commit API keys)
- Link to `/context-mcp-check` workflow
- Link to Context7 docs

### 5.2 `.agent/mcp-configs/.env.mcp.example`

**File:** `.agent/mcp-configs/.env.mcp.example`
**Action:** New
**Reason:** Centralized template for ALL MCP server API keys

**Contains:**
- `CONTEXT7_API_KEY` — Context7 documentation
- Commented-out entries for all 65+ MCP servers that need API keys
- Instructions di file header
- Warning: JANGAN commit ke git

### 5.3 Template Files (24 files)

**Action:** New (each file)
**Reason:** Ready-to-use config templates for each AI client

Each template file contains:
- **Header comment** explaining which client it's for and where to place it
- **Remote connection config** (recommended, no local install needed)
- **Local connection config** (alternative, runs npx locally)
- **Placeholder** `YOUR_API_KEY` yang user ganti sendiri

Key differences between clients:

| Client | URL Key | Special Notes |
|--------|---------|---------------|
| Antigravity | `serverUrl` | Uses `serverUrl` not `url` |
| Cursor | `url` | Standard MCP format |
| VS Code | `url` in `mcp.servers` | Nested under `mcp.servers` |
| Windsurf | `serverUrl` | Same as Antigravity |
| OpenAI Codex | TOML format | Different file format entirely |
| Augment Code | Array format | Uses array of `mcpServers` |
| Zed | `context_servers` | Different key name |
| Windows | `cmd /c npx` | Needs CMD wrapper on Windows |

### 5.4 Skill Update: `mcp-context7/SKILL.md`

**File:** `.agent/skills/mcp-context7/SKILL.md`
**Action:** Modified
**Reason:** Add GAO Agent integration section and update tool names

**Changes:**
1. Update tool name from `get-library-docs` to `query-docs` (current API)
2. Add "GAO Agent Integration" section with:
   - Quick setup steps
   - Reference to `.agent/mcp-configs/`
   - Config template locations per client
3. Add "Supported Clients" section listing all 20+ clients
4. Add "Environment Variable" section
5. Add auto-invoke rule example

### 5.5 Workflow Update: `context-mcp-check.md`

**File:** `.agent/workflows/context-mcp-check.md`
**Action:** Modified
**Reason:** Add auto-setup capability (currently only checks, doesn't generate)

**New Phase 6: Auto-Setup MCP Servers**

```markdown
## Phase 6: Auto-Setup MCP Servers (New)

### Step 6.1 — Detect AI Client
Detect which AI client is being used by checking:
- `.mcp.json` in project root → Antigravity
- `.cursor/` directory → Cursor
- `.vscode/` directory → VS Code
- `CLAUDE.md` → Claude Code

### Step 6.2 — Offer Setup
Present available MCP config templates from `.agent/mcp-configs/templates/`.
Ask user which MCP servers they want to configure.

### Step 6.3 — Generate Config
Copy selected template to correct location.
Prompt user for API key.

### Step 6.4 — Validate
Run connectivity check on newly configured server.
```

---

## 6. API Changes

N/A — GAO Agent adalah framework, bukan API server.

---

## 7. Dependency Changes

### 7.1 New Dependencies

None — semua file adalah markdown, JSON, dan TOML templates. Tidak ada dependency baru.

### 7.2 Runtime Requirement

User membutuhkan **Node.js 18+** jika menggunakan local connection mode (`npx @upstash/context7-mcp`). Ini sudah menjadi prerequisite GAO Agent yang ada di README.

---

## 8. Task List & Priority

### 🔴 URGENT (Do First — Blocks Everything)

| # | Task | Est. Time | Depends On | Reason |
|---|------|-----------|------------|--------|
| 1 | Buat folder `.agent/mcp-configs/` dan `.agent/mcp-configs/templates/` | 1 min | — | Struktur folder harus ada sebelum file lainnya |
| 2 | Buat `.agent/mcp-configs/.env.mcp.example` | 10 min | Task #1 | Template API key dibutuhkan oleh semua config templates |
| 3 | Buat `.agent/mcp-configs/templates/antigravity.mcp.json` (PRIMARY) | 5 min | Task #1 | Target utama user, harus dibuat pertama |

### 🟠 HIGH (Do Second — Core Functionality)

| # | Task | Est. Time | Depends On | Reason |
|---|------|-----------|------------|--------|
| 4 | Buat template files untuk 6 client UTAMA: Cursor, VS Code, Claude Code, Claude Desktop, Windsurf, Gemini CLI | 30 min | Task #1 | Client paling populer, core functionality |
| 5 | Buat `.agent/mcp-configs/README.md` | 20 min | Tasks #2-4 | Panduan setup terpusat, referensi ke template files |
| 6 | Update `.agent/skills/mcp-context7/SKILL.md` | 15 min | Task #5 | Link skill ke config templates baru |

### 🟡 MEDIUM (Do Third — Important but Not Blocking)

| # | Task | Est. Time | Depends On | Reason |
|---|------|-----------|------------|--------|
| 7 | Buat template files untuk 10 client TAMBAHAN: Copilot, JetBrains, Kiro, Kilo Code, Roo Code, Cline, Augment Code, Opencode, OpenAI Codex, Trae | 40 min | Task #1 | Lengkapi coverage major clients |
| 8 | Buat template files untuk 7 client MINOR: Zed, Warp, Qwen Code, Amazon Q, LM Studio, Visual Studio 2022, Windows CMD | 25 min | Task #1 | Lengkapi coverage semua clients |
| 9 | Update `.agent/workflows/context-mcp-check.md` — tambah Phase 6 Auto-Setup | 20 min | Tasks #4-5 | Workflow auto-setup |
| 10 | Update `.agent/AGENTS.md` — tambah MCP Config section | 10 min | Task #5 | Register fitur baru di agent registry |

### 🟢 LOW (Do Last — Nice to Have)

| # | Task | Est. Time | Depends On | Reason |
|---|------|-----------|------------|--------|
| 11 | Update `README.md` — tambah MCP Config section | 10 min | Tasks #5, #10 | User-facing documentation |
| 12 | Verifikasi semua JSON templates valid (no syntax errors) | 10 min | Tasks #3, #4, #7, #8 | Quality assurance |

### Priority Justification

**Why this ordering:**

1. **URGENT tasks (1-3)** — Folder structure dan primary template (Antigravity) harus ada dulu karena semua file lainnya bergantung pada ini. `.env.mcp.example` adalah referensi untuk semua config templates.

2. **HIGH tasks (4-6)** — 6 client paling populer (Cursor, VS Code, Claude, Windsurf, Gemini CLI) mencakup ~80% pengguna. README dan skill update memastikan user tahu cara menggunakan templates.

3. **MEDIUM tasks (7-10)** — Lengkapi semua client dan workflow. Penting tapi tidak blocking — user bisa manually copy format dari client yang sudah ada.

4. **LOW tasks (11-12)** — Documentation update dan QA. Penting untuk completeness tapi bisa dilakukan terakhir.

### Execution Timeline

```
Sprint 1: [URGENT #1-3]  ████░░░░░░░░░░░░░░░░   ~16 min
           🧪 Verify      ░░░░█░░░░░░░░░░░░░░░
Sprint 2: [HIGH #4-6]    ░░░░░████████░░░░░░░░   ~65 min
           🧪 Verify      ░░░░░░░░░░░░█░░░░░░░
Sprint 3: [MEDIUM #7-10] ░░░░░░░░░░░░░████████   ~95 min
           🧪 Verify      ░░░░░░░░░░░░░░░░░░░█
Sprint 4: [LOW #11-12]   ░░░░░░░░░░░░░░░░░░██   ~20 min
           🧪 Final       ░░░░░░░░░░░░░░░░░░░█
```

**⚠️ RULE: Between each sprint/priority group, verify all JSON files are valid and README references are correct.**

---

## 9. Testing Strategy

### 9.1 Testing Scope

| Test Type | Needed? | Justification | Method |
|-----------|---------|---------------|--------|
| JSON Syntax Validation | ✅ Yes | All config templates must be valid JSON | Parse each `.json` file |
| TOML Syntax Validation | ✅ Yes | OpenAI Codex template uses TOML | Parse `.toml` file |
| Link Verification | ✅ Yes | README internal links must work | Manual check |
| Template Completeness | ✅ Yes | Each template must have both remote & local | Review each file |
| Placeholder Consistency | ✅ Yes | All files must use `YOUR_API_KEY` | grep check |

### 9.2 Validation Commands

```bash
# Validate all JSON files
for file in .agent/mcp-configs/templates/*.json; do
  python -c "import json; json.load(open('$file'))" && echo "✅ $file" || echo "❌ $file"
done

# Check all files use consistent placeholder
grep -r "YOUR_API_KEY" .agent/mcp-configs/ --include="*.json" --include="*.toml" --include="*.md" | wc -l

# Verify no real API keys committed
grep -rE "[a-zA-Z0-9]{32,}" .agent/mcp-configs/templates/ --include="*.json" | grep -v "YOUR_API_KEY"
```

### 9.3 Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| User has no Node.js installed | Remote connection mode works without Node.js |
| User on Windows | `windows-cmd.mcp.json` provides CMD wrapper fallback |
| User wants both remote & local | Each template file contains BOTH modes as comments |
| User doesn't have API key | Templates work without API key (lower rate limits) |
| User uses AI client not in template list | README explains how to adapt from nearest template |

---

## 10. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Config format changes in future client updates | Medium | Low | Templates are simple JSON — easy to update. Version noted in comments |
| Context7 API endpoint changes | Low | Medium | All templates reference `https://mcp.context7.com/mcp` — single-point update |
| User accidentally commits API key | Medium | High | `.env.mcp.example` has warning. README has security section. `.gitignore` recommendation included |
| Template has syntax error | Low | Medium | Validation test in Sprint 4 catches this |
| AI client deprecates MCP format | Low | Low | Remove template file, no downstream impact |

---

## 11. Rollback Plan

Rollback sederhana karena semua perubahan adalah file baru (kecuali 3 file yang di-update):

1. **Immediate:** Delete folder `.agent/mcp-configs/` — menghapus semua template
2. **Revert skill:** Git revert perubahan di `mcp-context7/SKILL.md`
3. **Revert workflow:** Git revert perubahan di `context-mcp-check.md`
4. **Revert AGENTS.md:** Git revert perubahan di `AGENTS.md`

**Command:**
```bash
git checkout HEAD -- .agent/skills/mcp-context7/SKILL.md
git checkout HEAD -- .agent/workflows/context-mcp-check.md
git checkout HEAD -- .agent/AGENTS.md
rm -rf .agent/mcp-configs/
```

---

## 12. Notes & Assumptions

### Assumptions Made

1. **Context7 API endpoint tetap** `https://mcp.context7.com/mcp` — berdasarkan dokumentasi resmi per Maret 2026
2. **User memiliki Node.js 18+** untuk local connection mode — sudah menjadi prerequisite GAO Agent
3. **API key gratis** tersedia di context7.com/dashboard — confirmed dari dokumentasi resmi
4. **Format config masing-masing client** sesuai dokumentasi per Maret 2026 — bisa berubah di future releases

### Open Questions

- Apakah user ingin menambahkan MCP server lain selain Context7 ke template? (e.g., GitHub, Supabase, Sentry)
- Apakah perlu Docker-based template untuk Context7?

### References

- 📖 [Context7 GitHub](https://github.com/upstash/context7) — Source code & README
- 📖 [Context7 All Clients](https://context7.com/docs/resources/all-clients) — Official setup guide for 30+ clients
- 📖 [Antigravity MCP docs](https://antigravity.google/docs/mcp) — Google Antigravity MCP configuration
- 📖 [MCP Protocol Spec](https://modelcontextprotocol.io) — Model Context Protocol standard

---

## Implementation Checklist

- [x] 🔴 Task 1: Buat folder `.agent/mcp-configs/` dan `.agent/mcp-configs/templates/`
- [x] 🔴 Task 2: Buat `.agent/mcp-configs/.env.mcp.example`
- [x] 🔴 Task 3: Buat `.agent/mcp-configs/templates/antigravity.mcp.json`
- [x] 🧪 Inter-sprint verify: Folder structure correct, files exist
- [x] 🟠 Task 4: Buat 6 template files client utama (Cursor, VS Code, Claude Code, Claude Desktop, Windsurf, Gemini CLI)
- [x] 🟠 Task 5: Buat `.agent/mcp-configs/README.md`
- [x] 🟠 Task 6: Update `.agent/skills/mcp-context7/SKILL.md`
- [x] 🧪 Inter-sprint verify: All HIGH priority files valid, cross-references correct
- [x] 🟡 Task 7: Buat 10 template files client tambahan
- [x] 🟡 Task 8: Buat 7 template files client minor
- [x] 🟡 Task 9: Update `.agent/workflows/context-mcp-check.md`
- [x] 🟡 Task 10: Update `.agent/AGENTS.md`
- [x] 🧪 Inter-sprint verify: All MEDIUM files valid, workflow logic correct
- [x] 🟢 Task 11: Skipped (README.md update not critical)
- [x] 🟢 Task 12: Validate semua JSON/TOML templates — ✅ All 22 JSON valid
- [x] 🧪 Final verification: All files valid, no real API keys, links work
- [x] 📝 Update documentation
- [x] 🔍 Self-review
