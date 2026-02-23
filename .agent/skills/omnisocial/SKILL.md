---
name: omnisocial
description: >
  Skill untuk mengerjakan proyek OmniSocial — platform analitik & manajemen sosial media
  enterprise pada folder X:\Project\omnisocial\. Gunakan skill ini SETIAP KALI mengerjakan
  task di repositori ini. Mencakup: arsitektur tiga-layer (Laravel 12 API, React 19 + TypeScript
  FE, Python Flask AI Agent), konvensi kode per-layer, PostgreSQL schema, OAuth patterns untuk
  10 platform sosial media, credit system, recipe guide per jenis task, dan environment setup.
---

# OmniSocial Platform Skill

> **Lokasi Proyek:** `X:\Project\omnisocial\`
> **Gunakan skill ini WAJIB** setiap kali mengerjakan sesuatu di repositori OmniSocial.

---

## Quick Reference

| Kebutuhan | Lokasi |
|-----------|--------|
| Tambah endpoint baru | [§4 Backend Patterns](#4-backend-laravel-patterns) |
| Tambah halaman React baru | [§5 Frontend Patterns](#5-frontend-react--typescript-patterns) |
| Tambah Python Agent feature | [§6 Python Agent Patterns](#6-python-agent-patterns) |
| Connect platform baru | [§7 Platform Integrations](#7-platform-integrations-guide) |
| Tambah tabel DB baru | [§8 Database Schema](#8-database-schema-overview) |
| Recipe how-to | [§9 Common Tasks](#9-common-tasks--recipes) |
| Environment variables | [§11 Env Vars](#11-environment-variables) |
| Jalankan project | [§12 Running Project](#12-running-the-project) |

---

## 1. Overview & Architecture

OmniSocial adalah **platform analitik & manajemen sosial media enterprise** dengan tiga layer utama:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     OMNISOCIAL ECOSYSTEM                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐   ┌──────────────────┐   ┌────────────────┐  │
│  │  Landing Page    │   │  React Frontend  │   │  Python Agent  │  │
│  │  React+Vite      │   │  (omnisocial-fe) │   │  (omnisocial-  │  │
│  │  (landingpage/)  │   │  Port: 5173      │   │   agent/)      │  │
│  └──────────────────┘   └────────┬─────────┘   │  Port: 5001    │  │
│                                  │              └───────┬────────┘  │
│                                  │ REST API             │ REST API  │
│                                  └──────────┬───────────┘           │
│                                             │                       │
│                                  ┌──────────▼───────────────────┐  │
│                                  │   Laravel API Backend        │  │
│                                  │   (omnisocial-api/)          │  │
│                                  │   Port: 8000                 │  │
│                                  │   Laravel 12 + Sanctum Auth  │  │
│                                  └──────────┬───────────────────┘  │
│                                             │                       │
│                                  ┌──────────▼───────────────────┐  │
│                                  │   PostgreSQL Database        │  │
│                                  │   omnisocial_db              │  │
│                                  └──────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Modul-modul Utama

| Kategori | Modul | Keterangan |
|----------|-------|-----------|
| **Social Connectors** | YouTube, Instagram, Meta/Facebook, LinkedIn (Organic+Ads), TikTok (Organic+Ads), X/Twitter (Organic+Ads), Threads, Google Ads, Website/Sitemap | OAuth 2.0, auto token refresh |
| **AI Features** | Smart Audit, Cognitive Funnel, Content Analyzer, Keyword Agent (Trend IQ), Social Media AI, Video Processor | Powered by Google Gemini |
| **Productivity** | Kanban Board, Calendar/Post Scheduler, File Manager | Full CRUD |
| **Administration** | User & Role Management, Credit System, Activity Logs, Global Settings | RBAC + audit trail |
| **Analytics** | Dashboard (aggregated), Website Health Check, SEO Reporting | Real-time + scheduled |

---

## 2. Tech Stack

### Backend (omnisocial-api/)
| Teknologi | Versi | Package |
|-----------|-------|---------|
| PHP | ^8.2 | — |
| Laravel | ^12.0 | `laravel/framework` |
| Authentication | ^4.0 | `laravel/sanctum` |
| Google Ads SDK | ^31.1 | `googleads/google-ads-php` |

### Frontend (omnisocial-fe/)
| Teknologi | Versi | Package |
|-----------|-------|---------|
| React | ^19.2.0 | `react` |
| TypeScript | — | `typescript` |
| Vite | ^7.2.4 | `vite` |
| React Router | ^7.9.6 | `react-router-dom` |
| Charts | ^3.5.0 | `recharts` |
| Gemini AI SDK | ^1.30.0 | `@google/genai` |
| Icons | ^0.555.0 | `lucide-react` |
| Guided Tour | — | `react-joyride` |
| Markdown | — | `react-markdown` |

### Python Agent (omnisocial-agent/)
| Teknologi | Versi | Package |
|-----------|-------|---------|
| Python | 3.10+ | — |
| Flask | >=2.3.0 | `flask` |
| CORS | — | `flask-cors` |
| HTTP async | — | `aiohttp`, `httpx` |
| ORM | >=2.0.0 | `sqlalchemy` |
| AI SDK | >=1.0.0 | `google-genai` |
| Scheduler | >=3.10.0 | `apscheduler` |
| Browser Automation | — | `playwright` |
| Video Processing | — | `opencv-python-headless`, `mediapipe`, `ffmpeg-python` |
| CLI | — | `click`, `rich` |

### Database
| Item | Value |
|------|-------|
| Engine | PostgreSQL 14+ |
| Database Name | `omnisocial_db` |
| ORM (Laravel) | Eloquent |
| ORM (Python) | SQLAlchemy |
| Primary Key | UUID (semua tabel) |

---

## 3. Project Structure

```
X:\Project\omnisocial\
├── omnisocial-api/              ← Laravel 12 Backend
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── Api/         ← Semua API controllers (extends BaseController)
│   │   │   │   └── ActivityLogController.php
│   │   │   └── Middleware/
│   │   │       └── LogApiActivity.php
│   │   ├── Models/              ← Eloquent models (UUID primary key)
│   │   └── Services/
│   │       ├── ActivityLogger.php
│   │       ├── AgentService.php
│   │       └── FunnelContentSyncService.php
│   ├── database/migrations/     ← 37 migration files
│   ├── routes/
│   │   └── api.php              ← SEMUA routes di sini (prefix v1)
│   └── .env                    ← Laravel environment
│
├── omnisocial-fe/               ← React 19 + TypeScript Frontend
│   ├── pages/                   ← Route-level page components
│   ├── components/              ← Reusable UI components
│   ├── services/
│   │   ├── api.ts               ← Central API client (SELALU gunakan ini)
│   │   ├── geminiService.ts     ← AI operations (Gemini)
│   │   ├── creditService.ts     ← Credit operations
│   │   ├── youtubeService.ts    ← YouTube API
│   │   ├── metaService.ts       ← Meta/Facebook/Instagram API
│   │   ├── linkedinService.ts   ← LinkedIn organic API
│   │   ├── linkedinAdsService.ts← LinkedIn Ads API
│   │   ├── tiktokService.ts     ← TikTok organic API
│   │   ├── tiktokAdsService.ts  ← TikTok Ads API
│   │   ├── xTwitterService.ts   ← X/Twitter API
│   │   ├── xAdsService.ts       ← X Ads API
│   │   ├── threadsService.ts    ← Threads API
│   │   ├── googleAdsService.ts  ← Google Ads API
│   │   ├── keywordScopeService.ts← Keyword tracking
│   │   ├── fileStorageService.ts← File management
│   │   ├── videoProcessorService.ts← Video clip generator
│   │   └── connectorService.ts  ← Generic connector helper
│   ├── hooks/
│   │   └── useCreditCheck.ts    ← Credit check hook (WAJIB untuk AI ops)
│   ├── utils/
│   │   └── security.ts          ← Security utilities
│   ├── config/
│   │   └── apiConfig.ts         ← BASE_URL, AGENT_URL, TOKEN_KEY constants
│   └── types.ts                 ← Shared TypeScript types
│
├── omnisocial-agent/            ← Python Flask AI Agent
│   ├── api/
│   │   ├── audit_api.py         ← Smart Audit endpoints
│   │   ├── content_api.py       ← Content recommendation endpoints
│   │   ├── funnel_api.py        ← Cognitive Funnel endpoints
│   │   └── video_api.py         ← Video processing endpoints
│   ├── branding_agent/          ← Smart Audit core (Playwright + Gemini)
│   ├── content_analyzer/        ← SEO content analysis
│   ├── keyword_agent/           ← Keyword trend analysis + scheduler
│   ├── funnel_agent/            ← TOFU/MOFU/BOFU classifier
│   ├── video_processor/         ← 16:9 → 9:16 viral clip pipeline
│   ├── checker/                 ← Website health check engine
│   ├── crawler/                 ← Sitemap parser
│   ├── scheduler/               ← APScheduler for periodic tasks
│   ├── database/                ← SQLAlchemy models + connection
│   ├── config/
│   │   └── settings.py          ← All config (reads from .env)
│   ├── api_server.py            ← Entry point (Flask app)
│   ├── requirements.txt         ← Python dependencies
│   └── .env                    ← Python agent environment
│
└── landingpage/                 ← Public landing page (React + Vite)
```

---

## 4. Backend (Laravel) Patterns

### 4.1 Controller Pattern — WAJIB ikuti ini

Semua controller harus `extends BaseController` dan menggunakan `sendResponse()` / `sendError()`.

```php
<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Api\BaseController as BaseController;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use App\Models\SomeModel;
use App\Services\ActivityLogger;

class SomeController extends BaseController
{
    /**
     * Ambil semua item milik user yang sedang login.
     */
    public function index(Request $request)
    {
        try {
            $userId = $request->user()->id; // Selalu gunakan ini untuk isolasi user
            $items = SomeModel::where('user_id', $userId)
                ->orderBy('created_at', 'desc')
                ->get();

            return $this->sendResponse($items, 'Items retrieved successfully.');
        } catch (\Exception $e) {
            \Log::error('SomeController@index error: ' . $e->getMessage());
            return $this->sendError('Failed to retrieve items', ['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Buat item baru.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'        => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return $this->sendError('Validation Error.', $validator->errors(), 422);
        }

        try {
            $item = SomeModel::create([
                'id'          => (string) Str::uuid(), // SELALU generate UUID
                'user_id'     => Auth::id(),
                'name'        => $request->name,
                'description' => $request->description,
            ]);

            // Log sukses (opsional tapi sangat dianjurkan)
            ActivityLogger::logSuccess(Auth::id(), 'some_item_created', [
                'item_id' => $item->id,
                'name'    => $item->name,
            ]);

            return $this->sendResponse($item, 'Item created successfully.');
        } catch (\Exception $e) {
            \Log::error('SomeController@store error: ' . $e->getMessage());
            return $this->sendError('Failed to create item', ['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Update item (pastikan item milik user yang sedang login).
     */
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->sendError('Validation Error.', $validator->errors(), 422);
        }

        try {
            // PENTING: Selalu filter by user_id untuk security
            $item = SomeModel::where('id', $id)
                ->where('user_id', Auth::id())
                ->first();

            if (!$item) {
                return $this->sendError('Item not found.', [], 404);
            }

            $item->update($request->only(['name', 'description']));
            return $this->sendResponse($item->fresh(), 'Item updated successfully.');
        } catch (\Exception $e) {
            \Log::error('SomeController@update error: ' . $e->getMessage());
            return $this->sendError('Failed to update item', ['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Hapus item.
     */
    public function destroy($id)
    {
        try {
            $item = SomeModel::where('id', $id)
                ->where('user_id', Auth::id())
                ->first();

            if (!$item) {
                return $this->sendError('Item not found.', [], 404);
            }

            $item->delete();
            return $this->sendResponse([], 'Item deleted successfully.');
        } catch (\Exception $e) {
            \Log::error('SomeController@destroy error: ' . $e->getMessage());
            return $this->sendError('Failed to delete item', ['error' => $e->getMessage()], 500);
        }
    }
}
```

**`sendResponse()` format:**
```json
{ "code": 200, "message": "...", "data": {...} }
```

**`sendError()` format:**
```json
{ "code": 404, "message": "...", "data": {...} }
```

> ⚠️ **JANGAN** pernah return `response()->json()` langsung — selalu gunakan `sendResponse()` / `sendError()`.

### 4.2 Model Pattern

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SomeModel extends Model
{
    protected $table = 'some_models'; // snake_case, plural

    // WAJIB untuk UUID primary key
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'name',
        'description',
        'status',
        'metadata', // Untuk JSON columns
    ];

    protected $casts = [
        'metadata'   => 'array',   // JSON column → PHP array otomatis
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relations
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
```

### 4.3 Migration Pattern

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('some_models', function (Blueprint $table) {
            $table->uuid('id')->primary();           // UUID primary key — WAJIB
            $table->uuid('user_id');
            $table->foreign('user_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('cascade');

            $table->string('name');
            $table->text('description')->nullable();
            $table->string('status')->default('active');
            $table->json('metadata')->nullable();    // Untuk flexible data

            $table->timestamps();                    // created_at + updated_at — WAJIB
            // TIDAK ada softDeletes() — OmniSocial pakai hard delete
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('some_models');
    }
};
```

> **Konvensi Migration:**
> - File format: `YYYY_MM_DD_HHMMSS_create_{table}_table.php`
> - Jalankan: `php artisan migrate` (dari folder `omnisocial-api/`)
> - Rollback: `php artisan migrate:rollback`

### 4.4 Route Registration

```php
// routes/api.php — SEMUA routes ada di sini

// Di bagian atas file: import controller
use App\Http\Controllers\Api\SomeController;

// Di dalam: Route::prefix('v1')->group(function () {
//            Route::middleware(['auth:sanctum', 'log.api.activity'])->group(function () {

// Resource routes (tambahkan di dalam middleware group)
Route::get('/some-feature', [SomeController::class, 'index']);
Route::post('/some-feature', [SomeController::class, 'store']);
Route::get('/some-feature/{id}', [SomeController::class, 'show']);
Route::put('/some-feature/{id}', [SomeController::class, 'update']);
Route::delete('/some-feature/{id}', [SomeController::class, 'destroy']);
```

> **Route Conventions:**
> - Semua di prefix `/api/v1/` (otomatis lewat `RouteServiceProvider`)
> - Auth: `auth:sanctum` middleware
> - Activity log: `log.api.activity` middleware (otomatis log ke JSON daily file)
> - Public routes (tanpa auth): hanya `/signin`, `/login`, `/smart-audit/callback`

### 4.5 Activity Logger Usage

```php
// Log success
ActivityLogger::logSuccess(Auth::id(), 'action_name', [
    'key' => 'value', // detail bebas dalam array
]);

// Log failure
ActivityLogger::logFailure(Auth::id(), 'action_name_failed', [
    'error' => $e->getMessage(),
]);

// sendError() otomatis memanggil ActivityLogger::logFailure() — tidak perlu manual
```

Log disimpan ke `storage/logs/user_activities/YYYY-MM-DD.json` (per hari).

### 4.6 Auth Pattern

```php
// Mendapatkan user yang sedang login
$user = Auth::user();       // User model
$userId = Auth::id();       // UUID string
$userId = $request->user()->id; // Alternatif (lebih eksplisit)

// WAJIB: Selalu filter query dengan user_id untuk isolasi data
SomeModel::where('user_id', Auth::id())->get();
```

### 4.7 API Response Format dari Frontend

Frontend mengharapkan format standar dari semua endpoint:
```json
{
  "code": 200,
  "message": "Success message",
  "data": { ... }
}
```

---

## 5. Frontend (React + TypeScript) Patterns

### 5.1 API Client — WAJIB gunakan `apiFetch` dari `api.ts`

```typescript
// services/api.ts — sudah tersedia, jangan dibuat ulang
// apiFetch internal function yang dipakai oleh semua service

// Cara menggunakan api.ts untuk feature baru:
// 1. Tambahkan method di objek `api` dalam api.ts
// 2. JANGAN import apiFetch langsung ke component — gunakan via service

// Contoh: tambahkan method baru di api.ts
export const api = {
  // ... existing methods ...
  
  // Method baru
  getSomeData: async (): Promise<SomeItem[]> => {
    const response = await apiFetch('/some-feature');
    return response.data || [];
  },

  createSomeItem: async (data: { name: string; description?: string }): Promise<SomeItem> => {
    const response = await apiFetch('/some-feature', {
      method: 'POST',
      body: JSON.stringify(data),
    });
    return response.data;
  },

  updateSomeItem: async (id: string, data: Partial<SomeItem>): Promise<SomeItem> => {
    const response = await apiFetch(`/some-feature/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
    return response.data;
  },

  deleteSomeItem: async (id: string): Promise<void> => {
    await apiFetch(`/some-feature/${id}`, { method: 'DELETE' });
  },
};
```

### 5.2 Service File Pattern (Platform-specific)

Jika feature membutuhkan service tersendiri, buat file baru di `services/`:

```typescript
// services/someFeatureService.ts

import { api } from './api';

export interface SomeItem {
  id: string;
  user_id: string;
  name: string;
  description: string | null;
  status: string;
  created_at: string;
  updated_at: string;
}

export const someFeatureService = {
  getAll: () => api.getSomeData(),                // Delegation ke api.ts
  create: (data: { name: string }) => api.createSomeItem(data),
  update: (id: string, data: Partial<SomeItem>) => api.updateSomeItem(id, data),
  delete: (id: string) => api.deleteSomeItem(id),
};
```

### 5.3 Page Component Pattern

```typescript
// pages/SomeFeaturePage.tsx

import React, { useState, useEffect, useCallback } from 'react';
import { api } from '../services/api';
import { useCreditCheck } from '../hooks/useCreditCheck';
import { AIActionType } from '../types';

interface SomeItem {
  id: string;
  name: string;
  status: string;
}

const SomeFeaturePage: React.FC = () => {
  const [items, setItems] = useState<SomeItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Untuk operasi AI — SELALU gunakan hook ini
  const { state: creditState, executeWithCredit, closeInsufficientModal } = useCreditCheck();

  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getSomeData();
      setItems(data);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to load';
      setError(message);
    } finally {
      setLoading(false);
    }
  }, []);

  // Untuk operasi AI: gunakan executeWithCredit
  const handleAiOperation = useCallback(async () => {
    const result = await executeWithCredit(
      'text_generation' as AIActionType, // action type sesuai credit_settings
      async () => {
        // AI function — di sini lakukan AI call
        return await someAiFunction();
      },
      'Generated content for Some Feature' // description untuk activity log
    );

    if (result) {
      // Process result
    }
  }, [executeWithCredit]);

  // Untuk operasi non-AI (CRUD biasa)
  const handleCreate = useCallback(async (name: string) => {
    try {
      const newItem = await api.createSomeItem({ name });
      setItems(prev => [newItem, ...prev]);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to create';
      setError(message);
    }
  }, []);

  const handleDelete = useCallback(async (id: string) => {
    try {
      await api.deleteSomeItem(id);
      setItems(prev => prev.filter(item => item.id !== id));
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to delete';
      setError(message);
    }
  }, []);

  if (loading) return <div className="loading-spinner">Loading...</div>;

  return (
    <div>
      {error && <div className="error-message">{error}</div>}

      {/* Credit insufficient modal */}
      {creditState.insufficientCredits.show && (
        <InsufficientCreditsModal
          required={creditState.insufficientCredits.required}
          available={creditState.insufficientCredits.available}
          onClose={closeInsufficientModal}
        />
      )}

      {/* Main content */}
      {items.map(item => (
        <div key={item.id}>
          {item.name}
          <button onClick={() => handleDelete(item.id)}>Delete</button>
        </div>
      ))}
    </div>
  );
};

export default SomeFeaturePage;
```

### 5.4 Credit Check Hook — Cara Benar

```typescript
// useCreditCheck menyediakan executeWithCredit yang menangani:
// 1. Check balance sebelum operasi
// 2. Tampilkan InsufficientCreditsModal jika tidak cukup
// 3. Jalankan AI function jika cukup
// 4. Deduct kredit setelah operasi sukses

const { state, executeWithCredit, closeInsufficientModal } = useCreditCheck();

// Eksekusi dengan credit check:
const result = await executeWithCredit(
  'text_generation',           // AIActionType dari types.ts
  () => callAiApi(data),       // AI function → harus return Promise<T>
  'Description for log'        // Optional: activity log description
);
// result = null jika kredit tidak cukup
// result = T jika berhasil

// State yang tersedia:
// state.isChecking      → true saat cek kredit
// state.isProcessing    → true saat AI sedang berjalan
// state.error           → error message jika ada
// state.insufficientCredits.show → true jika modal harus ditampilkan
```

### 5.5 TypeScript Types

Semua shared types ada di `types.ts`. Tambahkan tipe baru di sini:

```typescript
// types.ts — tambahkan di sini untuk shared types

export interface SomeItem {
  id: string;
  name: string;
  status: 'active' | 'inactive';
  created_at: string;
}

// AIActionType — sesuaikan dengan data di credit_settings table
// Nilai ini harus match dengan action_type di tabel credit_settings
export type AIActionType =
  | 'content_analysis'
  | 'ad_analysis'
  | 'text_generation'
  | 'chat_text'
  | 'image_generation'
  | 'image_editing'
  | 'thumbnail_generation'
  | 'video_generation'
  | 'video_strategy'
  | 'viral_clips'
  | 'seo_analysis'
  | 'youtube_seo'
  | 'account_audit'
  | 'smart_branding_audit'
  | 'ad_performance_rating';
```

### 5.6 API Config Constants

```typescript
// config/apiConfig.ts — jangan hardcode URL, gunakan ini
import { BASE_URL, AGENT_URL, TOKEN_KEY } from '../config/apiConfig';
// BASE_URL  = VITE_API_URL   ?? 'http://localhost:8001/api/v1' (Laravel — port 8001!)
// AGENT_URL = VITE_AGENT_URL ?? 'http://localhost:5001/api/v1' (Python Agent)
// TOKEN_KEY = 'omnisocial_auth_token'  (localStorage key — BUKAN 'auth_token')
```

### 5.7 Auth Token Storage

```typescript
// Login → simpan token
localStorage.setItem('omnisocial_auth_token', token); // TOKEN_KEY = 'omnisocial_auth_token'

// Logout → hapus token
localStorage.removeItem('omnisocial_auth_token');

// apiFetch otomatis membaca TOKEN_KEY dari localStorage dan menyertakan
// header: Authorization: Bearer {token}
```

---

## 6. Python Agent Patterns

### 6.1 Flask Blueprint Structure

```python
# api/some_feature_api.py

from flask import Blueprint, request, jsonify
from database.connection import get_session
from config.settings import AGENT_SECRET_KEY
import logging

logger = logging.getLogger(__name__)

# WAJIB: url_prefix sesuai konvensi
some_feature_bp = Blueprint('some_feature', __name__, url_prefix='/api/v1/some-feature')


@some_feature_bp.route('/run', methods=['POST'])
def run_feature():
    """
    Run some feature.
    
    Untuk calls dari Laravel, validasi secret key.
    Request JSON: { "account_id": "...", "user_id": "...", "callback_url": "..." }
    """
    try:
        # Validasi secret key (untuk Laravel → Agent calls)
        secret = request.headers.get('X-Secret-Key', '')
        if secret != AGENT_SECRET_KEY:
            return jsonify({'error': 'Unauthorized'}), 401

        data = request.get_json()
        if not data:
            return jsonify({'error': 'Invalid JSON body'}), 400

        account_id = data.get('account_id')
        if not account_id:
            return jsonify({'error': 'account_id is required'}), 400

        # Lakukan pekerjaan...
        result = {
            'status': 'completed',
            'data': {}
        }

        return jsonify(result), 200

    except Exception as e:
        logger.error(f"Error in run_feature: {e}", exc_info=True)
        return jsonify({'error': str(e), 'status': 'failed'}), 500


@some_feature_bp.route('/status/<job_id>', methods=['GET'])
def get_status(job_id):
    """Poll status untuk async jobs."""
    try:
        # Query job status dari database
        return jsonify({'status': 'running', 'progress': 50}), 200
    except Exception as e:
        logger.error(f"Error getting status: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500
```

### 6.2 Register Blueprint di api_server.py

```python
# api_server.py — tambahkan blueprint baru di sini

from api.some_feature_api import some_feature_bp

# Di dalam main() atau create_app():
app.register_blueprint(some_feature_bp)
```

### 6.3 Gemini AI Integration

```python
# Gunakan google.genai SDK (BUKAN google.generativeai)
import google.genai as genai
from config.settings import GEMINI_API_KEY

# Initialize client
client = genai.Client(api_key=GEMINI_API_KEY)

# Text generation
response = client.models.generate_content(
    model='gemini-2.0-flash',
    contents=prompt_text,
    config=genai.types.GenerateContentConfig(
        temperature=0.7,
        max_output_tokens=2048,
    )
)
result_text = response.text

# Multimodal (text + image)
response = client.models.generate_content(
    model='gemini-2.0-flash',
    contents=[
        'Analyze this image:',
        genai.types.Part.from_bytes(image_bytes, mime_type='image/png')
    ]
)
```

> ⚠️ **PENTING:** Gunakan `google.genai` (bukan `google.generativeai`). Import: `import google.genai as genai`

### 6.4 Database (SQLAlchemy)

```python
# database/connection.py — sudah ada, gunakan ini
from database.connection import get_session, get_engine

# Cara menggunakan:
with get_session() as session:
    # Query
    items = session.query(SomeModel).filter_by(user_id=user_id).all()
    
    # Insert
    new_item = SomeModel(
        id=str(uuid.uuid4()),
        user_id=user_id,
        name='...'
    )
    session.add(new_item)
    session.commit()
    session.refresh(new_item)
```

### 6.5 Configuration Pattern

```python
# config/settings.py — semua config dibaca dari .env
from config.settings import (
    DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD,
    DATABASE_URL,
    GEMINI_API_KEY,          # Tambahkan jika belum ada
    AGENT_SECRET_KEY,
    DEFAULT_TIMEOUT,
    LOG_LEVEL,
)
```

Untuk menambah config baru:
```python
# Di config/settings.py
NEW_CONFIG = os.getenv('NEW_CONFIG', 'default_value')
```

### 6.6 Async HTTP Calls ke Laravel Callback

```python
import httpx
import asyncio

async def send_callback(callback_url: str, data: dict, secret_key: str):
    """Kirim result kembali ke Laravel via callback."""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                callback_url,
                json=data,
                headers={
                    'Content-Type': 'application/json',
                    'X-Secret-Key': secret_key,
                }
            )
            response.raise_for_status()
            return response.json()
    except Exception as e:
        logger.error(f"Callback failed: {e}")
        raise
```

---

## 7. Platform Integrations Guide

### 7.1 OAuth Flow Pattern (Semua Platform)

```
1. Frontend: Generate OAuth URL → redirect user ke platform
2. Platform: User authorize → redirect ke callback URL
3. Callback page (React): Extract auth_code dari URL params
4. Frontend: POST /api/v1/connectedaccounts/{platform}/exchange
   Body: { code, redirect_uri }
5. Laravel: Exchange code → access_token + refresh_token
6. Laravel: Store di connected_accounts table (UUID PK)
7. Frontend: Poll GET /api/v1/connectedaccounts/{platform}
```

### 7.2 Token Refresh Strategy

```php
// Di setiap ConnectedAccount controller, cek token sebelum API call
private function getValidToken(ConnectedAccounts $account): string
{
    // Refresh 5 menit sebelum expiry
    if ($account->token_expires_at && $account->token_expires_at->subMinutes(5)->isPast()) {
        if ($account->refresh_token) {
            $newToken = $this->refreshToken($account->refresh_token);
            $account->update([
                'access_token'    => $newToken['access_token'],
                'token_expires_at' => now()->addSeconds($newToken['expires_in']),
            ]);
        } else {
            $account->update(['status' => 'Expired']);
            throw new \Exception('Token expired. Please reconnect.');
        }
    }
    return $account->access_token;
}
```

### 7.3 Connected Accounts Table Schema

```sql
connected_accounts:
  id UUID PRIMARY KEY
  user_id UUID FK → users.id
  platform VARCHAR        -- 'youtube', 'instagram', 'meta', 'linkedin',
                          -- 'linkedin_ads', 'tiktok', 'tiktok_ads',
                          -- 'x_twitter', 'x_ads', 'google_ads', 'threads'
  account_type VARCHAR    -- 'organic', 'ads'
  provider_id VARCHAR     -- Platform user ID
  provider_name VARCHAR   -- Display name dari platform
  provider_email VARCHAR
  provider_avatar VARCHAR -- Avatar URL
  account_name VARCHAR    -- Nama akun yang ditampilkan di UI
  account_handle VARCHAR  -- Handle/username (e.g. @handle)
  access_token TEXT
  refresh_token TEXT
  token_expires_at TIMESTAMP
  expires_in INTEGER      -- Token expiry duration in seconds
  scopes TEXT             -- OAuth scopes yang diberikan
  last_sync TIMESTAMP     -- Kapan terakhir sync data
  status VARCHAR          -- 'Active', 'Expired'
  sitemap_url VARCHAR     -- Untuk website/sitemap monitoring
  niche VARCHAR           -- Niche/industri akun
  created_at TIMESTAMP
  updated_at TIMESTAMP
```

### 7.4 Platform-specific Notes

| Platform | Auth Type | Refresh Token | Notes |
|----------|-----------|---------------|-------|
| **YouTube** | OAuth 2.0 (Google) | ✅ Yes | exchange + `/youtube/refresh` endpoint |
| **Instagram** | Meta OAuth | ✅ Yes (Long-lived) | via MetaController |
| **Meta/Facebook** | Meta OAuth | ✅ Yes | Shared dengan Instagram |
| **LinkedIn Organic** | OAuth 2.0 | ✅ Yes | via LinkedInController |
| **LinkedIn Ads** | OAuth 2.0 | ✅ Yes | exchange endpoint terpisah |
| **TikTok Organic** | TikTok OAuth | ✅ Yes | via TikTokController |
| **TikTok Ads** | TikTok OAuth | ✅ Yes | exchange endpoint terpisah |
| **X/Twitter Organic** | OAuth 2.0 PKCE | ✅ Yes | PKCE: code_verifier diperlukan |
| **X Ads** | OAuth 2.0 PKCE | ✅ Yes | PKCE: code_verifier diperlukan |
| **Google Ads** | OAuth 2.0 | ✅ Yes | Perlu developer token |
| **Threads** | Meta OAuth | ✅ Yes | via ThreadsController |

### 7.5 Frontend — Cara Pindahkan Token ke Backend

```typescript
// services/api.ts — pattern yang digunakan semua platform

// 1. Exchange code → tokens
await api.exchangeYouTubeCode(code, redirectUri);
// atau
await api.exchangeXTwitterCode(code, redirectUri, codeVerifier);

// 2. Save connection (untuk platform dengan direct token)
await api.saveSocialConnection('instagram', {
  provider_id: instagramUserId,
  access_token: accessToken,
  refresh_token: refreshToken,
  expires_in: 3600,
  scopes: 'instagram_basic,instagram_content_publish',
});

// 3. Get connected accounts
const accounts = await api.getAllConnectedAccounts();
// Returns: { youtube: [...], instagram: [...], meta: [...], ... }

// 4. Fresh token (for platforms with auto-refresh)
const tokenData = await api.getYouTubeFreshToken();
// Returns: { access_token, expires_at, status }
```

---

## 8. Database Schema Overview

### 8.1 Core Tables

```
users
  id UUID PK
  name, email, password (hashed)
  role_id UUID FK → roles.id
  status ENUM('Active','Inactive')
  credits INTEGER
  created_at, updated_at

roles
  id UUID PK
  name VARCHAR
  color VARCHAR       -- CSS class string
  permissions JSON    -- Array of permission strings

permissions
  id UUID PK
  name VARCHAR
  description VARCHAR

role_permissions (pivot)
  role_id UUID FK, permission_id UUID FK

connected_accounts
  (lihat §7.3)

scheduled_posts
  id UUID PK
  user_id UUID FK
  connected_account_id UUID FK (nullable, untuk multi-account)
  platform VARCHAR
  title, description TEXT
  tags JSON
  date DATETIME
  time VARCHAR
  type VARCHAR
  status ENUM('pending','published','failed')
  created_at, updated_at
```

### 8.2 Feature Tables

```
kanban_columns    → id, user_id, title, position, color
kanban_tasks      → id, column_id, user_id, title, description, priority (string), due_date
kanban_comments   → id, task_id, user_id, content
kanban_priorities → id, user_id, name, color, order

files             → id, user_id, original_name, stored_name, file_path, 
                    mime_type, file_size, disk

credit_transactions → id, user_id, amount, balance_after, action_type, 
                      description, transaction_date
credit_settings     → id, action_type, credit_cost, description
user_ai_configs     → id, user_id, text_model, image_model, video_model, 
                      speech_model, gemini_api_key (encrypted)
global_settings     → id, key, value
```

### 8.3 AI & Analytics Tables

```
smart_audit_scans     → id, user_id, connected_account_id, status, 
                        result JSON, started_at, completed_at
seo_reports           → id, user_id, url, score, issues JSON, recommendations JSON
seo_page_analyses     → id, user_id, url, keyword, score, analysis JSON
content_analyses      → id, user_id, url, funnel_stage, analysis JSON
funnel_content_items  → id, user_id, platform, stage (tofu/mofu/bofu), content, status
funnel_mind_maps      → id, user_id, url, map_data JSON

website_health_checks → id, user_id, url, status, response_time, 
                        check_type, results JSON, checked_at
keyword_scopes        → id, user_id, keyword, location_code, language_code
```

---

## 9. Common Tasks & Recipes

### Recipe 1: Tambah Endpoint CRUD Baru

```
1. Buat migration:
   php artisan make:migration create_{table}_table
   → Edit sesuai §4.3 Migration Pattern (UUID PK!)

2. Buat Model:
   php artisan make:model {ModelName}
   → Edit sesuai §4.2 Model Pattern (incrementing=false, keyType='string')

3. Buat Controller:
   php artisan make:controller Api/{FeatureName}Controller
   → Edit sesuai §4.1 Controller Pattern (extends BaseController)

4. Register Route di routes/api.php:
   → Import use statement di atas file
   → Tambahkan routes di dalam middleware group

5. Jalankan migration:
   php artisan migrate

6. Test endpoint:
   curl -H "Authorization: Bearer {token}" http://localhost:8000/api/v1/{route}
```

### Recipe 2: Tambah Halaman Frontend Baru

```
1. Buat Page component: pages/{FeatureName}Page.tsx
   → Gunakan §5.3 Page Component Pattern

2. Tambahkan API methods di services/api.ts
   → Gunakan §5.1 API Client Pattern

3. Jika perlu service tersendiri: services/{feature}Service.ts
   → Gunakan §5.2 Service File Pattern

4. Register route di App.tsx (atau file routing utama):
   <Route path="/feature" element={<FeaturePage />} />

5. Tambahkan navigation link di sidebar/header component
```

### Recipe 3: Tambah Python Agent Feature Baru

```
1. Buat Blueprint: api/{feature}_api.py
   → Gunakan §6.1 Flask Blueprint Pattern

2. Register di api_server.py:
   from api.{feature}_api import {feature}_bp
   app.register_blueprint({feature}_bp)

3. Buat business logic di {feature}_agent/ folder jika kompleks

4. Tambahkan endpoint di routes/api.php (Laravel) jika butuh callback
   (Lihat contoh: /smart-audit/callback)

5. Test endpoint agent:
   curl -X POST http://localhost:5001/api/v1/{feature}/run \
     -H "X-Secret-Key: {AGENT_SECRET_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"account_id": "...", "user_id": "..."}'
```

### Recipe 4: Tambah Platform Sosial Media Baru

```
1. Backend (Laravel):
   a. Buat Controller: app/Http/Controllers/Api/{Platform}Controller.php
      - Method: exchange(Request $request) → OAuth code exchange
      - Method: callback() → Ambil data akun
      - Method: getProfile/getData() → Ambil data platform spesifik
   b. Register routes di api.php:
      - POST /connectedaccounts/{platform}/exchange
      - GET /connectedaccounts/{platform}
   c. Store di connected_accounts table (UUID PK)

2. Frontend:
   a. Buat service: services/{platform}Service.ts
   b. Tambahkan exchange method di api.ts:
      exchange{Platform}Code: async (code, redirectUri) => ...
   c. Buat callback page: pages/{Platform}Callback.tsx
      - Baca code dari URL params
      - Panggil api.exchange{Platform}Code()
   d. Register callback route di App.tsx

3. UI Integration:
   a. Tambahkan platform di Connector/Settings page
   b. Update getAllConnectedAccounts() response handling di frontend
```

### Recipe 5: Tambah AI Feature dengan Credit Check

```typescript
// 1. Definisikan action_type di credit_settings table (via migration atau seeder)

// 2. Tambahkan ke AIActionType union di types.ts:
export type AIActionType = 'existing_action' | 'new_ai_action';

// 3. Implementasi di page component:
const { state, executeWithCredit, closeInsufficientModal } = useCreditCheck();

const handleNewAiFeature = async () => {
  const result = await executeWithCredit(
    'new_ai_action',
    async () => {
      // Panggil AI API di sini
      const response = await geminiService.generateSomething(data);
      return response;
    },
    'Used new AI feature'
  );
  if (result) setResult(result);
};

// 4. Tampilkan modal jika kredit tidak cukup:
{state.insufficientCredits.show && (
  <InsufficientCreditsModal onClose={closeInsufficientModal} />
)}
```

---

## 10. Security Considerations

### 10.1 User Data Isolation — CRITICAL

```php
// SELALU filter dengan user_id. JANGAN pernah return data semua user.
SomeModel::where('user_id', Auth::id())->get();    // ✅ Benar
SomeModel::all();                                   // ❌ SALAH — kebocoran data!
```

### 10.2 Secret Key untuk Agent Callback

```php
// routes/api.php — callback route tidak pakai Sanctum auth
Route::post('/smart-audit/callback', [SmartAuditController::class, 'agentCallback']);

// Di controller — validasi secret key
$secretKey = $request->header('X-Secret-Key');
if ($secretKey !== config('app.agent_secret_key')) {
    return $this->sendError('Unauthorized', [], 401);
}
```

```python
# Python agent — kirim secret key ke Laravel callback
headers = {'X-Secret-Key': AGENT_SECRET_KEY}
```

### 10.3 Token Penyimpanan

```typescript
// Frontend: token Sanctum di localStorage
// JANGAN simpan di cookie tanpa HttpOnly flag
localStorage.setItem('auth_token', token);

// apiFetch otomatis menambahkan header Authorization: Bearer {token}
```

### 10.4 URL Sanitization (Python Agent)

```python
# config/settings.py — BLOCKED_HOSTS sudah didefinisikan
# Selalu validasi URL sebelum request ke external domain
from config.settings import BLOCKED_HOSTS, ALLOWED_SCHEMES

def is_safe_url(url: str) -> bool:
    from urllib.parse import urlparse
    parsed = urlparse(url)
    if parsed.scheme not in ALLOWED_SCHEMES:
        return False
    for blocked in BLOCKED_HOSTS:
        if parsed.hostname and parsed.hostname.startswith(blocked):
            return False
    return True
```

### 10.5 Input Validation

```php
// Laravel: SELALU validasi input sebelum proses
$validator = Validator::make($request->all(), [
    'field' => 'required|string|max:255',
    'url'   => 'required|url|max:2048',
]);
if ($validator->fails()) {
    return $this->sendError('Validation Error.', $validator->errors(), 422);
}
```

---

## 11. Environment Variables

### Laravel (`omnisocial-api/.env`)

```env
# App
APP_NAME=OmniSocial
APP_ENV=local
APP_KEY=base64:...           # php artisan key:generate
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=omnisocial_db
DB_USERNAME=postgres
DB_PASSWORD=root

# Auth
SANCTUM_STATEFUL_DOMAINS=localhost:5173,127.0.0.1:5173

# Python Agent
AGENT_URL=http://localhost:5001
AGENT_SECRET_KEY=your-secret-key-here     # Harus sama dengan agent .env

# Google OAuth (YouTube, Google Ads)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_DEVELOPER_TOKEN=                   # Google Ads developer token
GOOGLE_REDIRECT_URI=http://localhost:5173/google-callback

# Meta/Facebook/Instagram
META_APP_ID=
META_APP_SECRET=
META_REDIRECT_URI=http://localhost:5173/meta-callback

# LinkedIn
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=
LINKEDIN_REDIRECT_URI=http://localhost:5173/linkedin-callback

# TikTok
TIKTOK_CLIENT_KEY=
TIKTOK_CLIENT_SECRET=
TIKTOK_REDIRECT_URI=http://localhost:5173/tiktok-callback

# X/Twitter
TWITTER_CLIENT_ID=
TWITTER_CLIENT_SECRET=
TWITTER_REDIRECT_URI=http://localhost:5173/x-callback
```

### Python Agent (`omnisocial-agent/.env`)

```env
# Database (sama dengan Laravel)
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=omnisocial_db
DB_USERNAME=postgres
DB_PASSWORD=root

# AI
GEMINI_API_KEY=AIza...                    # Google Gemini API key
GEMINI_API_BASE_URL=https://generativelanguage.googleapis.com

# Security
AGENT_SECRET_KEY=your-secret-key-here    # Harus sama dengan Laravel .env

# Agent Config
LOG_LEVEL=INFO
DEFAULT_TIMEOUT=30
DEFAULT_CONCURRENT_REQUESTS=5
SSL_VERIFY=true
ALLOW_PRIVATE_IPS=false

# Laravel callback base URL
LARAVEL_BASE_URL=http://localhost:8000/api/v1
```

### Frontend (`omnisocial-fe/.env` atau `config/apiConfig.ts`)

```typescript
// config/apiConfig.ts
export const BASE_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:8000/api/v1';
export const AGENT_URL = import.meta.env.VITE_AGENT_URL || 'http://127.0.0.1:5001';
export const TOKEN_KEY = 'auth_token';
```

---

## 12. Running the Project

### Development Setup

```powershell
# Windows PowerShell

# ======================
# 1. Database (PostgreSQL)
# ======================
# Pastikan PostgreSQL berjalan dan database 'omnisocial_db' sudah dibuat

# ======================
# 2. Backend (Laravel API)
# ======================
cd X:\Project\omnisocial\omnisocial-api

# Install dependencies (pertama kali)
composer install

# Setup environment
copy .env.example .env
php artisan key:generate

# Jalankan migrations
php artisan migrate

# (Optional) Seed database
php artisan db:seed

# Jalankan server
php artisan serve
# → Running at http://localhost:8000

# Di terminal TERPISAH: Queue worker (untuk scheduled posts)
php artisan queue:listen --tries=1

# ======================
# 3. Frontend (React)
# ======================
cd X:\Project\omnisocial\omnisocial-fe

# Install dependencies (pertama kali)
npm install

# Jalankan dev server
npm run dev
# → Running at http://localhost:5173

# ======================
# 4. Python Agent
# ======================
cd X:\Project\omnisocial\omnisocial-agent

# Install dependencies (pertama kali)
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Jalankan agent server
python api_server.py
# → Running at http://localhost:5001

# Jika first run, create DB tables:
python api_server.py --create-tables

# ======================
# 5. Landing Page (Opsional)
# ======================
cd X:\Project\omnisocial\landingpage
npm install
npm run dev
```

### Useful Commands

```powershell
# Laravel (port default 8001 bukan 8000 — lihat apiConfig.ts)
php artisan serve --port=8001             # Start di port 8001
php artisan route:list                    # Lihat semua routes
php artisan migrate:status                # Lihat status migrations
php artisan migrate:rollback              # Rollback last migration
php artisan route:clear && php artisan config:clear && php artisan cache:clear

# Frontend
npm run build                             # Build production
npm run preview                           # Preview production build

# Python Agent
python -m py_compile api_server.py       # Syntax check
python api_server.py --debug             # Debug mode
```

---

## 13. Catatan Arsitektur Penting

1. **Python Agent berbagi database PostgreSQL** dengan Laravel — keduanya membaca/menulis ke `omnisocial_db` yang sama. Agent menggunakan SQLAlchemy secara langsung.

2. **Callback mechanism**: Laravel memanggil Python Agent untuk memulai task long-running (audit). Agent mengirim hasil kembali ke Laravel via HTTP callback dengan `X-Secret-Key`. Frontend menunggu dengan polling.

3. **No global state management di Frontend**: Tidak ada Redux/Zustand. Setiap page mengelola state lokalnya sendiri dengan `useState`/`useReducer`. Data fetching per-component mount.

4. **Credit System**: Setiap operasi AI wajib melewati credit check. Hapus asumsi bahwa user selalu punya kredit cukup. Selalu gunakan `useCreditCheck` hook.

5. **UUID everywhere**: Semua primary key adalah UUID string, bukan integer. Jangan pernah gunakan auto-increment di tabel baru.

6. **Tidak ada soft delete**: OmniSocial menggunakan hard delete. Jangan tambahkan `$table->softDeletes()` kecuali ada permintaan eksplisit.

7. **Activity log otomatis**: Middleware `log.api.activity` di Laravel otomatis mencatat setiap request. `sendError()` di BaseController otomatis memanggil `ActivityLogger::logFailure()`.

---

*Skill ini harus diupdate setiap kali ada perubahan arsitektur signifikan di proyek OmniSocial.*
*Terakhir diupdate: 2026-02-23*
