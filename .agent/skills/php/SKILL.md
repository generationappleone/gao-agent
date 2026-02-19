---
name: PHP
description: Skill for modern PHP development, covering project setup, OOP patterns, Composer, PSR standards, security, testing with PHPUnit, and best practices for PHP 8.3+.
---

# PHP Skill

## Overview
PHP is a server-side scripting language. Use this skill for modern PHP 8.3+ development following PSR standards, SOLID principles, and clean code practices. For framework-specific patterns, see the Laravel skill.

## Project Setup
```bash
composer init --name=myorg/my-project --type=project --require="php:>=8.3"
composer require psr/log psr/container
composer require --dev phpunit/phpunit phpstan/phpstan php-cs-fixer/shim
```

## Directory Structure
```
src/
├── Domain/                   # Business logic (no framework deps)
│   ├── Model/                # Entities, value objects
│   ├── Repository/           # Repository interfaces
│   ├── Service/              # Domain services
│   └── Exception/            # Domain exceptions
├── Application/              # Use cases, DTOs, commands
│   ├── DTO/
│   ├── UseCase/
│   └── Mapper/
├── Infrastructure/           # External implementations
│   ├── Persistence/          # Database repositories
│   ├── Http/                 # HTTP client
│   └── Config/               # Configuration
└── Presentation/             # HTTP controllers, CLI commands
    ├── Controller/
    └── Middleware/
tests/
├── Unit/
└── Integration/
composer.json
phpstan.neon
phpunit.xml
```

## Modern PHP 8.3+ Features
```php
<?php

declare(strict_types=1);  // ✅ ALWAYS at the top of every file

// --- Enums (PHP 8.1+) ---
enum OrderStatus: string
{
    case Pending = 'pending';
    case Confirmed = 'confirmed';
    case Shipped = 'shipped';
    case Delivered = 'delivered';
    case Cancelled = 'cancelled';

    public function isTerminal(): bool
    {
        return match($this) {
            self::Delivered, self::Cancelled => true,
            default => false,
        };
    }
}

// --- Readonly Classes (PHP 8.2+) ---
readonly class CreateUserDto
{
    public function __construct(
        public string $email,
        public string $firstName,
        public string $lastName,
        public string $password,
    ) {}
}

// --- Typed Class Constants (PHP 8.3+) ---
class AppConfig
{
    public const string APP_NAME = 'MyApp';
    public const int MAX_LOGIN_ATTEMPTS = 5;
    public const float TAX_RATE = 0.1;
}

// --- Constructor Promotion + Interfaces (SOLID) ---
interface UserRepositoryInterface
{
    public function findById(string $id): ?User;
    public function findByEmail(string $email): ?User;
    public function save(User $user): void;
    public function delete(string $id): void;
}

class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepo,
        private readonly PasswordHasherInterface $passwordHasher,
        private readonly LoggerInterface $logger,
    ) {}

    public function register(CreateUserDto $dto): User
    {
        $existing = $this->userRepo->findByEmail($dto->email);
        if ($existing !== null) {
            throw new EmailAlreadyExistsException($dto->email);
        }

        $user = new User(
            id: Uuid::uuid7()->toString(),
            email: $dto->email,
            firstName: $dto->firstName,
            lastName: $dto->lastName,
            passwordHash: $this->passwordHasher->hash($dto->password),
        );

        $this->userRepo->save($user);
        $this->logger->info('User registered', ['user_id' => $user->id]);

        return $user;
    }
}
```

## PSR Standards (MUST follow)
| PSR | Standard | Purpose |
|-----|----------|---------|
| PSR-1 | Basic Coding Standard | Class naming, file organization |
| PSR-4 | Autoloading | Namespace-to-directory mapping |
| PSR-7 | HTTP Message | Request/Response interfaces |
| PSR-11 | Container | Dependency injection container |
| PSR-12 | Extended Coding Style | Code formatting rules |
| PSR-15 | HTTP Handlers | Middleware interfaces |

## Error Handling
```php
// ✅ Custom exception hierarchy
abstract class DomainException extends \RuntimeException
{
    abstract public function getErrorCode(): string;
    abstract public function getHttpStatus(): int;
}

class ResourceNotFoundException extends DomainException
{
    public function __construct(string $resource, string $id)
    {
        parent::__construct(sprintf('%s with id %s not found', $resource, $id));
    }

    public function getErrorCode(): string { return 'RESOURCE_NOT_FOUND'; }
    public function getHttpStatus(): int { return 404; }
}

// Global error handler
set_exception_handler(function (\Throwable $e) {
    $status = $e instanceof DomainException ? $e->getHttpStatus() : 500;
    $code = $e instanceof DomainException ? $e->getErrorCode() : 'INTERNAL_ERROR';
    $message = $status === 500 ? 'An unexpected error occurred' : $e->getMessage();

    error_log($e->getMessage() . "\n" . $e->getTraceAsString());

    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode(['error' => ['code' => $code, 'message' => $message]]);
});
```

## Security Best Practices
```php
// ✅ Password hashing
$hash = password_hash($password, PASSWORD_ARGON2ID, [
    'memory_cost' => 65536,
    'time_cost' => 4,
    'threads' => 3,
]);
$isValid = password_verify($password, $hash);

// ✅ Prepared statements (PDO)
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email AND deleted_at IS NULL');
$stmt->execute(['email' => $email]);

// ✅ CSRF token
$token = bin2hex(random_bytes(32));
$_SESSION['csrf_token'] = $token;

// ✅ Input validation
$email = filter_var($input, FILTER_VALIDATE_EMAIL);
if ($email === false) throw new ValidationException('Invalid email');
```

## Testing (PHPUnit)
```php
class UserServiceTest extends TestCase
{
    private UserService $service;
    private MockObject&UserRepositoryInterface $mockRepo;

    protected function setUp(): void
    {
        $this->mockRepo = $this->createMock(UserRepositoryInterface::class);
        $this->service = new UserService(
            $this->mockRepo,
            new FakePasswordHasher(),
            new NullLogger(),
        );
    }

    public function test_register_creates_user(): void
    {
        $this->mockRepo->expects($this->once())
            ->method('findByEmail')
            ->willReturn(null);

        $this->mockRepo->expects($this->once())
            ->method('save');

        $user = $this->service->register(new CreateUserDto(
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            password: 'password123',
        ));

        $this->assertSame('test@example.com', $user->email);
    }
}
```

## Tools
| Tool | Purpose |
|------|---------|
| `composer` | Package manager |
| `phpstan` | Static analysis (level 8+) |
| `php-cs-fixer` | Code style fixer |
| `phpunit` | Testing |
| `psalm` | Static analysis alternative |
| `rector` | Automated refactoring |
| `composer audit` | Security vulnerability scanning |

## Rules Integration
- **SOLID**: Interfaces for DIP, readonly DTOs (SRP), constructor promotion for DI
- **Security**: `password_hash(ARGON2ID)`, PDO prepared statements, CSRF tokens, `filter_var`
- **Dependencies**: `composer audit`, version constraints, `composer.lock` committed
