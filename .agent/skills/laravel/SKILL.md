---
name: Laravel
description: Skill for building applications with the Laravel PHP framework, covering project setup, architecture patterns, Eloquent ORM, API development, authentication, testing, and deployment.
---

# Laravel Skill

## Overview
Laravel is a PHP web application framework following the MVC pattern, created by Taylor Otwell. It provides elegant syntax, powerful ORM (Eloquent), built-in authentication, queue system, and extensive ecosystem. Use this skill when building web applications, REST APIs, or backend services with Laravel.

**Minimum Version**: Laravel 11+ (PHP 8.2+)
**References**:
- [Official Laravel Documentation](https://laravel.com/docs)
- [Laravel API Reference](https://laravel.com/api/)
- [Laracasts](https://laracasts.com/)
- [Laravel News](https://laravel-news.com/)

---

## Project Setup

### New Project
```bash
# Create new project (latest stable version)
composer create-project laravel/laravel project-name
cd project-name

# Environment setup
cp .env.example .env
php artisan key:generate

# Database setup
php artisan migrate

# Start development server
php artisan serve  # http://localhost:8000

# Or with Laravel Herd / Valet for automatic virtual hosts
```

### Essential Packages
```bash
# Development
composer require --dev phpstan/phpstan larastan/larastan php-cs-fixer/shim
composer require --dev phpunit/phpunit  # Included by default

# Production essentials
composer require laravel/sanctum       # API authentication
composer require spatie/laravel-permission  # Roles & permissions
composer require spatie/laravel-data    # DTOs & data objects
composer require spatie/laravel-query-builder  # API filtering
```

### Directory Structure
```
app/
├── Http/
│   ├── Controllers/         # Request handlers (thin — delegate to services)
│   ├── Middleware/           # HTTP middleware
│   ├── Requests/            # Form request validation
│   └── Resources/           # API resource transformers
├── Models/                  # Eloquent models
├── Services/                # Business logic (create this — REQUIRED)
├── Repositories/            # Data access layer (create this — REQUIRED)
│   └── Contracts/           # Repository interfaces
├── DTOs/                    # Data Transfer Objects (create this)
├── Events/                  # Event classes
├── Listeners/               # Event listeners
├── Jobs/                    # Queue jobs
├── Policies/                # Authorization policies
├── Enums/                   # PHP 8.1 backed enums (create this)
├── Exceptions/              # Custom exceptions (create this)
└── Providers/               # Service providers
config/                      # Configuration files
database/
├── migrations/              # Database migrations
├── seeders/                 # Database seeders
└── factories/               # Model factories
routes/
├── api.php                  # API routes (stateless)
├── web.php                  # Web routes (session-based)
└── console.php              # Artisan commands
resources/
├── views/                   # Blade templates
└── lang/                    # Translations
tests/
├── Feature/                 # Feature/integration tests
└── Unit/                    # Unit tests
```

---

## Architecture Patterns

### MUST Follow: Service-Repository Pattern (SOLID)
```php
<?php
// WHY: Separates concerns — Controller handles HTTP, Service handles business logic,
// Repository handles data access. Each layer is independently testable.

// ───────────────────────────────────────────────
// 1. Repository Interface (Dependency Inversion Principle)
// ───────────────────────────────────────────────
// app/Repositories/Contracts/UserRepositoryInterface.php
namespace App\Repositories\Contracts;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface UserRepositoryInterface
{
    public function findById(string $id): ?User;
    public function findByEmail(string $email): ?User;
    public function create(array $data): User;
    public function update(string $id, array $data): User;
    public function delete(string $id): bool;
    public function paginate(int $perPage = 15, array $filters = []): LengthAwarePaginator;
    public function findActiveByTenant(string $tenantId): \Illuminate\Database\Eloquent\Collection;
}

// ───────────────────────────────────────────────
// 2. Repository Implementation
// ───────────────────────────────────────────────
// app/Repositories/UserRepository.php
namespace App\Repositories;

use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class UserRepository implements UserRepositoryInterface
{
    public function __construct(private readonly User $model) {}

    public function findById(string $id): ?User
    {
        return $this->model
            ->where('id', $id)
            ->whereNull('deleted_at')
            ->first();
    }

    public function findByEmail(string $email): ?User
    {
        return $this->model
            ->where('email', $email)
            ->whereNull('deleted_at')
            ->first();
    }

    public function create(array $data): User
    {
        return $this->model->create($data);
    }

    public function update(string $id, array $data): User
    {
        $user = $this->findById($id);

        if (!$user) {
            throw new \App\Exceptions\ResourceNotFoundException('User', $id);
        }

        $user->update($data);
        return $user->fresh();
    }

    public function delete(string $id): bool
    {
        $user = $this->findById($id);
        return $user ? $user->delete() : false; // Soft delete via SoftDeletes trait
    }

    public function paginate(int $perPage = 15, array $filters = []): LengthAwarePaginator
    {
        $query = $this->model->query()->whereNull('deleted_at');

        if (isset($filters['status'])) {
            $query->where('is_active', $filters['status'] === 'active');
        }

        if (isset($filters['search'])) {
            $query->where(function ($q) use ($filters) {
                $q->where('first_name', 'LIKE', "%{$filters['search']}%")
                  ->orWhere('last_name', 'LIKE', "%{$filters['search']}%")
                  ->orWhere('email', 'LIKE', "%{$filters['search']}%");
            });
        }

        return $query->orderBy('created_at', 'desc')->paginate($perPage);
    }

    public function findActiveByTenant(string $tenantId): \Illuminate\Database\Eloquent\Collection
    {
        return $this->model
            ->where('tenant_id', $tenantId)
            ->where('is_active', true)
            ->whereNull('deleted_at')
            ->get();
    }
}

// ───────────────────────────────────────────────
// 3. DTO (Data Transfer Object)
// ───────────────────────────────────────────────
// app/DTOs/CreateUserDto.php
namespace App\DTOs;

use App\Http\Requests\CreateUserRequest;

readonly class CreateUserDto
{
    public function __construct(
        public string $name,
        public string $email,
        public string $password,
        public ?string $phone = null,
        public ?string $avatarUrl = null,
    ) {}

    public static function fromRequest(CreateUserRequest $request): self
    {
        return new self(
            name: $request->validated('name'),
            email: $request->validated('email'),
            password: $request->validated('password'),
            phone: $request->validated('phone'),
            avatarUrl: $request->validated('avatar_url'),
        );
    }
}

// ───────────────────────────────────────────────
// 4. Service (Business Logic — the CORE)
// ───────────────────────────────────────────────
// app/Services/UserService.php
namespace App\Services;

use App\DTOs\CreateUserDto;
use App\DTOs\UpdateUserDto;
use App\Events\UserRegistered;
use App\Exceptions\EmailAlreadyExistsException;
use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepo,
    ) {}

    public function register(CreateUserDto $dto): User
    {
        // Business rule: email must be unique
        $existing = $this->userRepo->findByEmail($dto->email);
        if ($existing) {
            throw new EmailAlreadyExistsException($dto->email);
        }

        return DB::transaction(function () use ($dto) {
            $user = $this->userRepo->create([
                'id' => Str::uuid()->toString(),
                'name' => $dto->name,
                'email' => $dto->email,
                'password' => Hash::make($dto->password),
                'phone' => $dto->phone,
                'is_active' => true,
            ]);

            // Dispatch event (Observer pattern — decouples side effects)
            event(new UserRegistered($user));

            return $user;
        });
    }

    public function updateProfile(string $userId, UpdateUserDto $dto): User
    {
        $data = array_filter([
            'name' => $dto->name,
            'phone' => $dto->phone,
            'avatar_url' => $dto->avatarUrl,
        ], fn($v) => $v !== null);

        return $this->userRepo->update($userId, $data);
    }

    public function deactivate(string $userId): User
    {
        return $this->userRepo->update($userId, ['is_active' => false]);
    }
}

// ───────────────────────────────────────────────
// 5. Controller (THIN — only handles HTTP)
// ───────────────────────────────────────────────
// app/Http/Controllers/Api/UserController.php
namespace App\Http\Controllers\Api;

use App\DTOs\CreateUserDto;
use App\Http\Controllers\Controller;
use App\Http\Requests\CreateUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Symfony\Component\HttpFoundation\Response;

class UserController extends Controller
{
    public function __construct(
        private readonly UserService $userService,
    ) {}

    public function index(Request $request): AnonymousResourceCollection
    {
        $users = $this->userService->paginate(
            perPage: $request->integer('per_page', 15),
            filters: $request->only(['status', 'search']),
        );

        return UserResource::collection($users);
    }

    public function store(CreateUserRequest $request): JsonResponse
    {
        $user = $this->userService->register(
            CreateUserDto::fromRequest($request)
        );

        return UserResource::make($user)
            ->response()
            ->setStatusCode(Response::HTTP_CREATED)
            ->header('Location', route('api.users.show', $user->id));
    }

    public function show(string $id): UserResource
    {
        $user = $this->userService->findById($id);
        return UserResource::make($user);
    }

    public function update(UpdateUserRequest $request, string $id): UserResource
    {
        $user = $this->userService->updateProfile(
            $id,
            UpdateUserDto::fromRequest($request)
        );

        return UserResource::make($user);
    }

    public function destroy(string $id): JsonResponse
    {
        $this->userService->deactivate($id);
        return response()->json(null, Response::HTTP_NO_CONTENT);
    }
}

// ───────────────────────────────────────────────
// 6. Service Provider (Binding Interface → Implementation)
// ───────────────────────────────────────────────
// app/Providers/RepositoryServiceProvider.php
namespace App\Providers;

use App\Repositories\Contracts\UserRepositoryInterface;
use App\Repositories\UserRepository;
use App\Repositories\Contracts\OrderRepositoryInterface;
use App\Repositories\OrderRepository;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // WHY: Binding interfaces allows swapping implementations
        // (e.g., EloquentUserRepository → CacheDecoratorUserRepository)
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);
        $this->app->bind(OrderRepositoryInterface::class, OrderRepository::class);
    }
}
```

---

## Eloquent ORM

### Model Best Practices
```php
<?php

namespace App\Models;

use App\Enums\UserStatus;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Builder;

class User extends Model
{
    use HasUuids, HasFactory, SoftDeletes;

    // UUID configuration
    protected $keyType = 'string';
    public $incrementing = false;

    // Mass assignment protection
    protected $fillable = [
        'name', 'email', 'password', 'phone',
        'avatar_url', 'is_active', 'tenant_id',
    ];

    // Hidden from serialization (API/JSON)
    protected $hidden = ['password', 'remember_token', 'deleted_at'];

    // Attribute casting
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',          // Auto-hash on set (Laravel 10+)
        'is_active' => 'boolean',
        'metadata' => 'array',           // JSON ↔ array
        'status' => UserStatus::class,   // Backed enum
    ];

    // Default attribute values
    protected $attributes = [
        'is_active' => true,
    ];

    // ─── Relationships ────────────────────────────

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(Tenant::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class)
            ->withPivot('assigned_at', 'assigned_by')
            ->withTimestamps();
    }

    public function latestOrder(): HasMany
    {
        return $this->hasMany(Order::class)->latestOfMany();
    }

    // ─── Scopes (Reusable Query Constraints) ──────

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    public function scopeByTenant(Builder $query, string $tenantId): Builder
    {
        return $query->where('tenant_id', $tenantId);
    }

    public function scopeSearch(Builder $query, string $term): Builder
    {
        return $query->where(function (Builder $q) use ($term) {
            $q->where('name', 'LIKE', "%{$term}%")
              ->orWhere('email', 'LIKE', "%{$term}%");
        });
    }

    // ─── Accessors & Mutators ─────────────────────

    protected function fullName(): \Illuminate\Database\Eloquent\Casts\Attribute
    {
        return \Illuminate\Database\Eloquent\Casts\Attribute::make(
            get: fn() => "{$this->first_name} {$this->last_name}",
        );
    }

    // ─── Business Methods ─────────────────────────

    public function hasRole(string $role): bool
    {
        return $this->roles()->where('name', $role)->exists();
    }

    public function isAdmin(): bool
    {
        return $this->hasRole('admin');
    }
}
```

### Enum (PHP 8.1+)
```php
<?php

namespace App\Enums;

enum UserStatus: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case Suspended = 'suspended';
    case PendingVerification = 'pending_verification';

    public function label(): string
    {
        return match($this) {
            self::Active => 'Active',
            self::Inactive => 'Inactive',
            self::Suspended => 'Suspended',
            self::PendingVerification => 'Pending Verification',
        };
    }

    public function color(): string
    {
        return match($this) {
            self::Active => 'green',
            self::Inactive => 'gray',
            self::Suspended => 'red',
            self::PendingVerification => 'yellow',
        };
    }

    public function isAccessible(): bool
    {
        return $this === self::Active;
    }
}

enum OrderStatus: string
{
    case Pending = 'pending';
    case Confirmed = 'confirmed';
    case Processing = 'processing';
    case Shipped = 'shipped';
    case Delivered = 'delivered';
    case Cancelled = 'cancelled';
    case Refunded = 'refunded';

    public function isTerminal(): bool
    {
        return match($this) {
            self::Delivered, self::Cancelled, self::Refunded => true,
            default => false,
        };
    }

    public function canTransitionTo(self $status): bool
    {
        return match($this) {
            self::Pending => in_array($status, [self::Confirmed, self::Cancelled]),
            self::Confirmed => in_array($status, [self::Processing, self::Cancelled]),
            self::Processing => in_array($status, [self::Shipped, self::Cancelled]),
            self::Shipped => in_array($status, [self::Delivered]),
            self::Delivered => in_array($status, [self::Refunded]),
            default => false,
        };
    }
}
```

### Migration Best Practices
```php
<?php

return new class extends Migration {
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            // Primary key: UUID
            $table->uuid('id')->primary();

            // Business fields
            $table->string('email', 255)->unique();
            $table->string('password', 255);
            $table->string('first_name', 100);
            $table->string('last_name', 100);
            $table->string('phone', 20)->nullable();
            $table->string('avatar_url', 500)->nullable();

            // Status
            $table->boolean('is_active')->default(true);
            $table->string('status', 30)->default('active');
            $table->timestamp('email_verified_at')->nullable();

            // Multi-tenancy
            $table->uuid('tenant_id');
            $table->foreign('tenant_id')
                  ->references('id')
                  ->on('tenants')
                  ->onDelete('restrict');  // NEVER cascade delete business data

            // Metadata (JSONB for flexible attributes)
            $table->json('metadata')->nullable();

            // Audit columns (REQUIRED on every table)
            $table->uuid('created_by')->nullable();
            $table->uuid('updated_by')->nullable();
            $table->foreign('created_by')->references('id')->on('users')->nullOnDelete();
            $table->foreign('updated_by')->references('id')->on('users')->nullOnDelete();
            $table->timestamps();       // created_at, updated_at
            $table->softDeletes();       // deleted_at

            // Indexes
            $table->index(['tenant_id', 'is_active']);
            $table->index(['last_name', 'first_name']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
```

### Query Performance (N+1 Prevention)
```php
// ❌ N+1 Problem: Each iteration triggers a new query
$users = User::all();
foreach ($users as $user) {
    echo $user->orders->count();     // 1 query per user!
}

// ✅ Eager loading: 2 queries total (users + orders)
$users = User::with('orders')->get();

// ✅ Eager loading with constraints
$users = User::with(['orders' => function ($query) {
    $query->where('status', 'completed')
          ->orderBy('created_at', 'desc')
          ->take(5);
}])->get();

// ✅ Lazy eager loading (when you already have the collection)
$users->load('roles', 'tenant');

// ✅ withCount for counting without loading
$users = User::withCount('orders')
    ->having('orders_count', '>', 5)
    ->get();

// ✅ Chunking for large datasets (memory efficient)
User::where('is_active', true)
    ->chunk(200, function ($users) {
        foreach ($users as $user) {
            // Process each user
        }
    });

// ✅ Cursor for even lower memory usage
foreach (User::where('is_active', true)->cursor() as $user) {
    // Only 1 model in memory at a time
}
```

---

## API Development

### Form Request Validation
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class CreateUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Authorization check (or use Policies)
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:100'],
            'email' => ['required', 'email:rfc,dns', 'max:255', 'unique:users,email'],
            'password' => [
                'required',
                'confirmed',
                Password::min(8)
                    ->letters()
                    ->mixedCase()
                    ->numbers()
                    ->symbols()
                    ->uncompromised(),  // Check against HIBP
            ],
            'phone' => ['nullable', 'string', 'regex:/^\+?[1-9]\d{1,14}$/'],
            'avatar_url' => ['nullable', 'url', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'This email is already registered.',
            'password.uncompromised' => 'This password has appeared in a data breach. Please choose a different password.',
        ];
    }
}

class UpdateUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'min:2', 'max:100'],
            'phone' => ['sometimes', 'nullable', 'string', 'regex:/^\+?[1-9]\d{1,14}$/'],
            'avatar_url' => ['sometimes', 'nullable', 'url', 'max:500'],
        ];
    }
}
```

### API Resources (Transformers)
```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->when($this->phone, $this->phone),
            'avatar_url' => $this->avatar_url,
            'is_active' => $this->is_active,
            'status' => $this->status,
            'email_verified_at' => $this->email_verified_at?->toISOString(),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),

            // Conditional fields (only included when loaded)
            'orders_count' => $this->whenCounted('orders'),
            'roles' => RoleResource::collection($this->whenLoaded('roles')),
            'tenant' => new TenantResource($this->whenLoaded('tenant')),
            'latest_order' => new OrderResource($this->whenLoaded('latestOrder')),

            // HATEOAS links
            'links' => [
                'self' => route('api.users.show', $this->id),
                'orders' => route('api.users.orders.index', $this->id),
            ],
        ];
    }
}
```

### API Routes
```php
<?php
// routes/api.php
use App\Http\Controllers\Api\{UserController, OrderController, AuthController};

Route::prefix('v1')->group(function () {
    // Public routes
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);

    // Protected routes
    Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
        // Auth
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/auth/me', [AuthController::class, 'me']);

        // Users
        Route::apiResource('users', UserController::class);

        // Nested resources
        Route::apiResource('users.orders', OrderController::class)->shallow();
    });
});
```

---

## Authentication

### Laravel Sanctum (SPA/Mobile)
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\LoginRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if (!$user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Your account has been deactivated.'],
            ]);
        }

        // Create token with abilities (scopes)
        $token = $user->createToken(
            name: $request->device_name ?? 'api-token',
            abilities: $this->getAbilities($user),
            expiresAt: now()->addDays(7),
        );

        return response()->json([
            'success' => true,
            'data' => [
                'user' => new UserResource($user),
                'token' => $token->plainTextToken,
                'expires_at' => $token->accessToken->expires_at->toISOString(),
            ],
        ]);
    }

    public function logout(): JsonResponse
    {
        // Revoke current token
        auth()->user()->currentAccessToken()->delete();

        return response()->json(['success' => true, 'message' => 'Logged out']);
    }

    private function getAbilities(User $user): array
    {
        $abilities = ['read'];

        if ($user->isAdmin()) {
            $abilities = ['*']; // Full access
        } elseif ($user->hasRole('editor')) {
            $abilities = array_merge($abilities, ['create', 'update']);
        }

        return $abilities;
    }
}
```

---

## Exception Handling
```php
<?php
// app/Exceptions/Handler.php (Laravel 11 uses bootstrap/app.php)

// bootstrap/app.php
use Illuminate\Foundation\Configuration\Exceptions;
use App\Exceptions\ResourceNotFoundException;
use App\Exceptions\BusinessRuleException;

return Application::configure(basePath: dirname(__DIR__))
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->renderable(function (ResourceNotFoundException $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => $e->getErrorCode(),
                    'message' => $e->getMessage(),
                    'requestId' => request()->header('X-Request-ID', \Str::uuid()),
                ],
            ], $e->getHttpStatus());
        });

        $exceptions->renderable(function (BusinessRuleException $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => $e->getErrorCode(),
                    'message' => $e->getMessage(),
                ],
            ], $e->getHttpStatus());
        });
    })
    ->create();

// app/Exceptions/ResourceNotFoundException.php
namespace App\Exceptions;

class ResourceNotFoundException extends \RuntimeException
{
    public function __construct(
        private readonly string $resource,
        private readonly string $identifier,
    ) {
        parent::__construct("{$resource} with ID {$identifier} not found");
    }

    public function getErrorCode(): string { return 'RESOURCE_NOT_FOUND'; }
    public function getHttpStatus(): int { return 404; }
}

class EmailAlreadyExistsException extends \RuntimeException
{
    public function __construct(string $email)
    {
        parent::__construct("User with email {$email} already exists");
    }

    public function getErrorCode(): string { return 'EMAIL_ALREADY_EXISTS'; }
    public function getHttpStatus(): int { return 409; }
}
```

---

## Testing

```php
<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Tenant;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserApiTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;
    private Tenant $tenant;

    protected function setUp(): void
    {
        parent::setUp();
        $this->tenant = Tenant::factory()->create();
        $this->admin = User::factory()->for($this->tenant)->create(['role' => 'admin']);
    }

    public function test_can_list_users(): void
    {
        User::factory()->count(5)->for($this->tenant)->create();

        $response = $this->actingAs($this->admin)
            ->getJson('/api/v1/users?per_page=10');

        $response
            ->assertOk()
            ->assertJsonStructure([
                'data' => [['id', 'name', 'email', 'is_active', 'created_at']],
                'meta' => ['current_page', 'total', 'per_page'],
            ])
            ->assertJsonCount(6, 'data');  // 5 + admin
    }

    public function test_can_create_user(): void
    {
        $response = $this->actingAs($this->admin)
            ->postJson('/api/v1/users', [
                'name' => 'John Doe',
                'email' => 'john@example.com',
                'password' => 'SecureP@ss123',
                'password_confirmation' => 'SecureP@ss123',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.email', 'john@example.com');

        $this->assertDatabaseHas('users', ['email' => 'john@example.com']);
    }

    public function test_cannot_create_user_with_duplicate_email(): void
    {
        User::factory()->create(['email' => 'exists@example.com']);

        $response = $this->actingAs($this->admin)
            ->postJson('/api/v1/users', [
                'name' => 'Another User',
                'email' => 'exists@example.com',
                'password' => 'SecureP@ss123',
                'password_confirmation' => 'SecureP@ss123',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    public function test_unauthenticated_user_gets_401(): void
    {
        $this->getJson('/api/v1/users')
            ->assertUnauthorized();
    }
}

// Unit test for Service layer
namespace Tests\Unit;

use App\DTOs\CreateUserDto;
use App\Exceptions\EmailAlreadyExistsException;
use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Services\UserService;
use Mockery;
use Tests\TestCase;

class UserServiceTest extends TestCase
{
    private UserService $service;
    private UserRepositoryInterface $mockRepo;

    protected function setUp(): void
    {
        parent::setUp();
        $this->mockRepo = Mockery::mock(UserRepositoryInterface::class);
        $this->service = new UserService($this->mockRepo);
    }

    public function test_register_creates_user_and_dispatches_event(): void
    {
        \Illuminate\Support\Facades\Event::fake();

        $dto = new CreateUserDto(name: 'John', email: 'john@example.com', password: 'password123');

        $this->mockRepo->shouldReceive('findByEmail')
            ->once()
            ->with('john@example.com')
            ->andReturnNull();

        $this->mockRepo->shouldReceive('create')
            ->once()
            ->andReturn(new User(['id' => 'uuid', 'name' => 'John', 'email' => 'john@example.com']));

        $user = $this->service->register($dto);

        $this->assertEquals('john@example.com', $user->email);
        \Illuminate\Support\Facades\Event::assertDispatched(\App\Events\UserRegistered::class);
    }

    public function test_register_throws_if_email_exists(): void
    {
        $this->mockRepo->shouldReceive('findByEmail')
            ->andReturn(new User(['email' => 'exists@example.com']));

        $this->expectException(EmailAlreadyExistsException::class);

        $this->service->register(
            new CreateUserDto(name: 'Test', email: 'exists@example.com', password: 'pass123')
        );
    }
}
```

---

## Key Commands

```bash
# ─── Project ──────────────────────────
php artisan serve                          # Start dev server
php artisan key:generate                   # Generate app key
php artisan optimize                       # Cache config, routes, views
php artisan optimize:clear                 # Clear all caches

# ─── Make ─────────────────────────────
php artisan make:model User -mfsc          # Model + Migration + Factory + Seeder + Controller
php artisan make:controller Api/UserController --api  # API resource controller
php artisan make:request CreateUserRequest  # Form request validation
php artisan make:resource UserResource      # API resource transformer
php artisan make:event UserRegistered       # Event class
php artisan make:listener SendWelcomeEmail  # Listener
php artisan make:job ProcessOrderJob        # Queue job
php artisan make:policy UserPolicy          # Authorization policy
php artisan make:middleware EnsureTenantMiddleware  # Custom middleware
php artisan make:enum UserStatus            # Enum (Laravel 11+)
php artisan make:test UserApiTest           # Feature test
php artisan make:test UserServiceTest --unit  # Unit test

# ─── Database ─────────────────────────
php artisan migrate                        # Run migrations
php artisan migrate:rollback               # Rollback last batch
php artisan migrate:fresh --seed           # Drop all, re-migrate, seed
php artisan db:seed --class=UserSeeder     # Run specific seeder

# ─── Testing ──────────────────────────
php artisan test                           # Run all tests
php artisan test --filter=UserApiTest      # Run specific test
php artisan test --parallel                # Parallel execution
php artisan test --coverage                # With coverage report

# ─── Debug ────────────────────────────
php artisan route:list --name=api          # List API routes
php artisan tinker                         # Interactive REPL
php artisan queue:work                     # Process queue jobs
php artisan schedule:run                   # Run scheduled tasks
```

---

## Anti-Patterns (❌ DON'T)

```php
// ❌ DON'T: Put business logic in controllers
class BadController extends Controller {
    public function store(Request $request) {
        // Validation, business logic, DB queries, emails ALL in controller ❌
        $validated = $request->validate([...]);
        $user = User::create($validated);
        Mail::to($user)->send(new WelcomeEmail());
        return response()->json($user);
    }
}

// ❌ DON'T: Use raw queries without prepared statements
DB::select("SELECT * FROM users WHERE email = '{$email}'");  // SQL injection!
// ✅ DO: Use Eloquent or DB::select with bindings
DB::select('SELECT * FROM users WHERE email = ?', [$email]);

// ❌ DON'T: Return Eloquent models directly from controllers
return User::find($id);  // Exposes hidden fields, no transformation
// ✅ DO: Use API Resources
return new UserResource(User::find($id));

// ❌ DON'T: Use env() outside config files
function getDbHost() { return env('DB_HOST'); }  // Returns null in cached config!
// ✅ DO: Access via config()
function getDbHost() { return config('database.connections.pgsql.host'); }

// ❌ DON'T: Forget to validate input
$data = $request->all();  // Unvalidated! Mass assignment vulnerability
// ✅ DO: Always use Form Requests or $request->validated()
$data = $request->validated();
```

---

## Rules Integration
- **SOLID**: Service-Repository pattern, DI via Service Providers, DTOs for data transfer, thin controllers
- **Security**: Sanctum/Passport for auth, CSRF protection, Form Request validation, prepared statements (Eloquent default), rate limiting, CORS
- **Database**: UUID primary keys (`HasUuids` trait), soft deletes, migrations with audit columns, enum status fields, eager loading (N+1 prevention)
- **Testing**: Feature tests for API endpoints, Unit tests for services, factories for test data
- **Dependencies**: Check Laravel version compatibility with `composer audit`, locked versions in `composer.lock`
