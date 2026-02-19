---
name: Laravel
description: Skill for building applications with the Laravel PHP framework, covering project setup, architecture patterns, Eloquent ORM, API development, authentication, testing, and deployment.
---

# Laravel Skill

## Overview
Laravel is a PHP web application framework following the MVC pattern. Use this skill when building web applications, REST APIs, or backend services with Laravel.

## Project Setup

### New Project
```bash
composer create-project laravel/laravel project-name
cd project-name
cp .env.example .env
php artisan key:generate
```

### Directory Structure
```
app/
├── Http/
│   ├── Controllers/     # Request handlers
│   ├── Middleware/       # HTTP middleware
│   ├── Requests/        # Form request validation
│   └── Resources/       # API resource transformers
├── Models/              # Eloquent models
├── Services/            # Business logic (create this)
├── Repositories/        # Data access layer (create this)
├── Events/              # Event classes
├── Listeners/           # Event listeners
├── Jobs/                # Queue jobs
├── Policies/            # Authorization policies
└── Providers/           # Service providers
config/                  # Configuration files
database/
├── migrations/          # Database migrations
├── seeders/             # Database seeders
└── factories/           # Model factories
routes/
├── api.php              # API routes
├── web.php              # Web routes
└── console.php          # Artisan commands
resources/
├── views/               # Blade templates
└── lang/                # Translations
tests/
├── Feature/             # Feature/integration tests
└── Unit/                # Unit tests
```

## Architecture Patterns

### MUST Follow: Service-Repository Pattern (SOLID)
```php
// app/Repositories/Contracts/UserRepositoryInterface.php
interface UserRepositoryInterface
{
    public function findById(string $id): ?User;
    public function findByEmail(string $email): ?User;
    public function create(array $data): User;
    public function update(string $id, array $data): User;
    public function delete(string $id): bool;
    public function paginate(int $perPage = 15): LengthAwarePaginator;
}

// app/Repositories/UserRepository.php
class UserRepository implements UserRepositoryInterface
{
    public function __construct(private readonly User $model) {}

    public function findById(string $id): ?User
    {
        return $this->model->find($id);
    }

    public function create(array $data): User
    {
        return $this->model->create($data);
    }
    // ... other methods
}

// app/Services/UserService.php
class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepo,
        private readonly PasswordService $passwordService,
        private readonly EmailService $emailService,
    ) {}

    public function register(CreateUserDto $dto): User
    {
        $user = $this->userRepo->create([
            'id' => Str::uuid(),
            'name' => $dto->name,
            'email' => $dto->email,
            'password' => $this->passwordService->hash($dto->password),
        ]);

        $this->emailService->sendWelcome($user);
        return $user;
    }
}

// app/Http/Controllers/Api/UserController.php
class UserController extends Controller
{
    public function __construct(private readonly UserService $userService) {}

    public function store(CreateUserRequest $request): JsonResponse
    {
        $user = $this->userService->register(
            CreateUserDto::fromRequest($request)
        );

        return UserResource::make($user)
            ->response()
            ->setStatusCode(Response::HTTP_CREATED);
    }
}

// app/Providers/RepositoryServiceProvider.php
class RepositoryServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);
    }
}
```

## Eloquent ORM

### Model Best Practices
```php
class User extends Model
{
    use HasUuids, SoftDeletes;

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = ['name', 'email', 'password'];
    protected $hidden = ['password', 'remember_token'];
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'is_active' => 'boolean',
    ];

    // Relationships
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class);
    }

    // Scopes
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }
}
```

### Migration Best Practices
```php
return new class extends Migration {
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('email', 255)->unique();
            $table->string('password', 255);
            $table->string('first_name', 100);
            $table->string('last_name', 100);
            $table->boolean('is_active')->default(true);
            $table->timestamp('email_verified_at')->nullable();
            $table->uuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->uuid('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['last_name', 'first_name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
```

## API Development

### Form Request Validation
```php
class CreateUserRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }
}
```

### API Resources
```php
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'is_active' => $this->is_active,
            'created_at' => $this->created_at->toISOString(),
            'orders_count' => $this->whenCounted('orders'),
            'roles' => RoleResource::collection($this->whenLoaded('roles')),
        ];
    }
}
```

## Authentication
- Use **Laravel Sanctum** for SPA/mobile API authentication
- Use **Laravel Passport** for OAuth2 server
- Always use `Hash::make()` for passwords
- Implement rate limiting on auth routes

## Testing
```php
class UserServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_creates_user_and_sends_email(): void
    {
        Mail::fake();
        $dto = new CreateUserDto(name: 'John', email: 'john@example.com', password: 'password123');

        $user = app(UserService::class)->register($dto);

        $this->assertDatabaseHas('users', ['email' => 'john@example.com']);
        Mail::assertSent(WelcomeMail::class);
    }
}
```

## Key Commands
```bash
php artisan make:model ModelName -mfsc    # Model + Migration + Seeder + Controller
php artisan make:request RequestName       # Form request
php artisan make:resource ResourceName     # API resource
php artisan migrate                        # Run migrations
php artisan test                           # Run tests
php artisan route:list                     # List all routes
php artisan optimize                       # Cache config, routes, views
```

## Rules Integration
- **SOLID**: Service-Repository pattern, DI via Service Providers
- **Security**: Sanctum/Passport, CSRF protection, validation, prepared statements (Eloquent default)
- **Database**: UUID primary keys (`HasUuids` trait), soft deletes, migrations, audit columns
- **Dependencies**: Check Laravel version compatibility, use `composer audit`
