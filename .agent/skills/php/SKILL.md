---
name: PHP
description: Skill for modern PHP development, covering project setup, OOP patterns, Composer, PSR standards, security, testing with PHPUnit, and best practices for PHP 8.3+.
---

# PHP Skill

## Overview
PHP is a server-side scripting language powering ~77% of websites with known server-side technology, including WordPress, Laravel, Symfony, and Drupal. This skill covers modern PHP 8.3+ development following PSR standards, SOLID principles, and clean code practices. For framework-specific patterns, see the Laravel or Symfony skill.

**Minimum Version**: PHP 8.2+ (recommended: PHP 8.3+)
**References**:
- [Official PHP Documentation](https://www.php.net/docs.php)
- [PHP: The Right Way](https://phptherightway.com/)
- [PSR Standards](https://www.php-fig.org/psr/)
- [PHP RFC Tracker](https://wiki.php.net/rfc)
- [Packagist](https://packagist.org/)

---

## Project Setup

### Composer Init
```bash
# Initialize project
composer init --name=myorg/my-project --type=project --require="php:>=8.3"

# Install common packages
composer require psr/log psr/container psr/http-message
composer require vlucas/phpdotenv               # Environment variables
composer require monolog/monolog                  # Logging (PSR-3)
composer require ramsey/uuid                      # UUID generation

# Development
composer require --dev phpunit/phpunit
composer require --dev phpstan/phpstan
composer require --dev friendsofphp/php-cs-fixer
```

### Project Structure (PSR-4 Autoloading)
```
my-project/
├── src/                         # Application source (PSR-4 namespace)
│   ├── Entity/                  # Domain entities
│   │   └── User.php
│   ├── Service/                 # Business logic
│   │   └── UserService.php
│   ├── Repository/              # Data access
│   │   ├── UserRepositoryInterface.php
│   │   └── UserRepository.php
│   ├── DTO/                     # Data Transfer Objects
│   │   └── CreateUserDto.php
│   ├── Exception/               # Custom exceptions
│   │   ├── AppException.php
│   │   └── ResourceNotFoundException.php
│   ├── Enum/                    # Backed enums (PHP 8.1+)
│   │   └── UserStatus.php
│   └── Util/                    # Shared utilities
│       └── Validator.php
├── tests/                       # Test files (mirrors src/ structure)
│   ├── Unit/
│   │   └── Service/
│   │       └── UserServiceTest.php
│   └── Integration/
├── config/                      # Configuration files
├── public/                      # Web-accessible root
│   └── index.php                # Front controller
├── var/                         # Runtime (cache, logs)
│   ├── cache/
│   └── log/
├── composer.json
├── phpstan.neon                 # PHPStan configuration
└── phpunit.xml                  # PHPUnit configuration
```

### composer.json Autoloading
```json
{
    "autoload": {
        "psr-4": {
            "App\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "require": {
        "php": ">=8.3"
    },
    "config": {
        "sort-packages": true,
        "optimize-autoloader": true,
        "preferred-install": "dist"
    }
}
```

---

## Modern PHP 8.3+ Features

### Readonly Classes & Properties
```php
<?php
// WHY: Immutable data structures prevent accidental modification
// and make code easier to reason about.

// Readonly class (PHP 8.2+) — all properties are readonly
readonly class Money
{
    public function __construct(
        public int $amount,           // Stored in cents
        public string $currency = 'USD',
    ) {
        if ($amount < 0) {
            throw new \InvalidArgumentException('Amount cannot be negative');
        }
        if (strlen($currency) !== 3) {
            throw new \InvalidArgumentException('Currency must be ISO 4217 (3 chars)');
        }
    }

    public function add(self $other): self
    {
        if ($this->currency !== $other->currency) {
            throw new \InvalidArgumentException(
                "Cannot add {$this->currency} and {$other->currency}"
            );
        }
        return new self($this->amount + $other->amount, $this->currency);
    }

    public function toDollars(): float
    {
        return $this->amount / 100;
    }

    public function format(): string
    {
        return number_format($this->toDollars(), 2) . ' ' . $this->currency;
    }
}

// Usage
$price = new Money(9999, 'USD');        // $99.99
$tax = new Money(800, 'USD');           // $8.00
$total = $price->add($tax);            // $107.99
echo $total->format();                  // "107.99 USD"
// $price->amount = 0;                  // ❌ Error: Cannot modify readonly property
```

### Backed Enums (PHP 8.1+)
```php
<?php
// WHY: Type-safe constants with associated values. Replace class constants
// and magic strings. Backed by string or int for database storage.

enum UserStatus: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case Suspended = 'suspended';
    case PendingVerification = 'pending_verification';

    /**
     * Human-readable label for display.
     */
    public function label(): string
    {
        return match($this) {
            self::Active => 'Active',
            self::Inactive => 'Inactive',
            self::Suspended => 'Suspended',
            self::PendingVerification => 'Pending Verification',
        };
    }

    /**
     * CSS color class for UI rendering.
     */
    public function color(): string
    {
        return match($this) {
            self::Active => 'green',
            self::Inactive => 'gray',
            self::Suspended => 'red',
            self::PendingVerification => 'yellow',
        };
    }

    /**
     * Whether user can access the system.
     */
    public function canAccess(): bool
    {
        return $this === self::Active;
    }

    /**
     * Valid transitions from current status.
     */
    public function allowedTransitions(): array
    {
        return match($this) {
            self::PendingVerification => [self::Active, self::Suspended],
            self::Active => [self::Inactive, self::Suspended],
            self::Inactive => [self::Active],
            self::Suspended => [self::Active],
        };
    }

    public function canTransitionTo(self $target): bool
    {
        return in_array($target, $this->allowedTransitions(), true);
    }
}

// Usage
$status = UserStatus::Active;
echo $status->value;                   // "active" (for database)
echo $status->label();                 // "Active" (for UI)

$fromDb = UserStatus::from('active');  // UserStatus::Active
$maybe = UserStatus::tryFrom('invalid'); // null (no exception)

// Type-safe in function signatures
function deactivateUser(User $user): void
{
    if (!$user->status->canTransitionTo(UserStatus::Inactive)) {
        throw new \LogicException("Cannot deactivate user with status: {$user->status->value}");
    }
    $user->setStatus(UserStatus::Inactive);
}
```

### Constructor Property Promotion
```php
<?php
// WHY: Eliminates boilerplate — property declaration, assignment, and type
// all in one place.

// ❌ Old way (verbose)
class OldUser {
    private string $name;
    private string $email;
    private UserStatus $status;
    
    public function __construct(string $name, string $email, UserStatus $status) {
        $this->name = $name;
        $this->email = $email;
        $this->status = $status;
    }
}

// ✅ Modern way (PHP 8.0+)
class User {
    public function __construct(
        private readonly string $id,
        private string $name,
        private string $email,
        private UserStatus $status = UserStatus::PendingVerification,
        private ?string $phone = null,
        private readonly \DateTimeImmutable $createdAt = new \DateTimeImmutable(),
    ) {}

    // Getters
    public function getId(): string { return $this->id; }
    public function getName(): string { return $this->name; }
    public function getEmail(): string { return $this->email; }
    public function getStatus(): UserStatus { return $this->status; }

    // Setters (only for mutable properties)
    public function setName(string $name): void { $this->name = $name; }
    public function setStatus(UserStatus $status): void { $this->status = $status; }
}
```

### Match Expression (PHP 8.0+)
```php
<?php
// WHY: Strict comparison (===), returns value, no fallthrough, exhaustive

// ✅ match (use instead of switch)
$response = match($statusCode) {
    200 => 'OK',
    201 => 'Created',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'Not Found',
    422 => 'Unprocessable Entity',
    429 => 'Too Many Requests',
    500 => 'Internal Server Error',
    default => 'Unknown Status',
};

// match with no argument (replaces if-elseif chains)
$category = match(true) {
    $age < 13 => 'child',
    $age < 18 => 'teenager',
    $age < 65 => 'adult',
    default => 'senior',
};
```

### Named Arguments (PHP 8.0+)
```php
<?php
// WHY: Improves readability, especially with many parameters

$user = new User(
    id: Uuid::uuid4()->toString(),
    name: 'John Doe',
    email: 'john@example.com',
    status: UserStatus::Active,
    phone: '+1234567890',
);

// Skip optional parameters
htmlspecialchars(
    string: $input,
    encoding: 'UTF-8',
    double_encode: false,
);
```

### Fiber (PHP 8.1+)
```php
<?php
// WHY: Lightweight concurrency — pause and resume execution
// Used internally by frameworks for async I/O (ReactPHP, Swoole, etc.)

$fiber = new Fiber(function (): void {
    $value = Fiber::suspend('paused');
    echo "Resumed with: $value\n";
});

$result = $fiber->start();          // "paused"
$fiber->resume('hello');             // "Resumed with: hello"
```

### First-class Callable Syntax (PHP 8.1+)
```php
<?php
$users = [new User('Alice'), new User('Bob'), new User('Charlie')];

// ✅ First-class callable syntax
$names = array_map($this->getUserName(...), $users);
$admins = array_filter($users, $this->isAdmin(...));

// Also works with static methods and built-in functions
$trimmed = array_map(trim(...), $strings);
$sorted = usort($items, strcmp(...));
```

---

## Design Patterns

### DTOs (Data Transfer Objects)
```php
<?php

namespace App\DTO;

// WHY: DTOs decouple external input from internal domain.
// Validated input → DTO → Service → Repository

readonly class CreateUserDto
{
    public function __construct(
        public string $name,
        public string $email,
        public string $password,
        public ?string $phone = null,
    ) {}

    /**
     * Create DTO from validated request data.
     */
    public static function fromArray(array $data): self
    {
        return new self(
            name: $data['name'],
            email: $data['email'],
            password: $data['password'],
            phone: $data['phone'] ?? null,
        );
    }
}
```

### Repository Pattern
```php
<?php

namespace App\Repository;

interface UserRepositoryInterface
{
    public function findById(string $id): ?User;
    public function findByEmail(string $email): ?User;
    public function create(CreateUserDto $dto): User;
    public function update(string $id, array $data): User;
    public function delete(string $id): bool;
    public function paginate(int $page = 1, int $perPage = 15): PaginatedResult;
}

class UserRepository implements UserRepositoryInterface
{
    public function __construct(
        private readonly \PDO $pdo,
    ) {}

    public function findById(string $id): ?User
    {
        $stmt = $this->pdo->prepare(
            'SELECT * FROM users WHERE id = :id AND deleted_at IS NULL'
        );
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(\PDO::FETCH_ASSOC);

        return $row ? User::fromRow($row) : null;
    }

    public function findByEmail(string $email): ?User
    {
        $stmt = $this->pdo->prepare(
            'SELECT * FROM users WHERE email = :email AND deleted_at IS NULL'
        );
        $stmt->execute(['email' => $email]);
        $row = $stmt->fetch(\PDO::FETCH_ASSOC);

        return $row ? User::fromRow($row) : null;
    }

    public function create(CreateUserDto $dto): User
    {
        $id = \Ramsey\Uuid\Uuid::uuid4()->toString();
        $passwordHash = password_hash($dto->password, PASSWORD_BCRYPT, ['cost' => 12]);

        $stmt = $this->pdo->prepare(
            'INSERT INTO users (id, name, email, password_hash, phone, created_at, updated_at)
             VALUES (:id, :name, :email, :password_hash, :phone, NOW(), NOW())'
        );

        $stmt->execute([
            'id' => $id,
            'name' => $dto->name,
            'email' => $dto->email,
            'password_hash' => $passwordHash,
            'phone' => $dto->phone,
        ]);

        return $this->findById($id);
    }
}
```

### Service Layer
```php
<?php

namespace App\Service;

use App\DTO\CreateUserDto;
use App\Entity\User;
use App\Exception\EmailAlreadyExistsException;
use App\Repository\UserRepositoryInterface;

class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepo,
    ) {}

    public function register(CreateUserDto $dto): User
    {
        // Business rule: unique email
        $existing = $this->userRepo->findByEmail($dto->email);
        if ($existing !== null) {
            throw new EmailAlreadyExistsException($dto->email);
        }

        return $this->userRepo->create($dto);
    }

    public function findById(string $id): User
    {
        $user = $this->userRepo->findById($id);

        if ($user === null) {
            throw new \App\Exception\ResourceNotFoundException('User', $id);
        }

        return $user;
    }
}
```

---

## Custom Exceptions
```php
<?php

namespace App\Exception;

abstract class AppException extends \RuntimeException
{
    abstract public function getErrorCode(): string;
    abstract public function getHttpStatus(): int;
}

class ResourceNotFoundException extends AppException
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

class EmailAlreadyExistsException extends AppException
{
    public function __construct(string $email)
    {
        parent::__construct("Email {$email} is already registered");
    }

    public function getErrorCode(): string { return 'EMAIL_ALREADY_EXISTS'; }
    public function getHttpStatus(): int { return 409; }
}

class InsufficientPermissionsException extends AppException
{
    public function __construct(string $requiredPermission)
    {
        parent::__construct("Missing permission: {$requiredPermission}");
    }

    public function getErrorCode(): string { return 'INSUFFICIENT_PERMISSIONS'; }
    public function getHttpStatus(): int { return 403; }
}
```

---

## Security

```php
<?php
// ── Password Hashing ──
// ✅ ALWAYS use password_hash() with BCRYPT or ARGON2ID
$hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
$hash = password_hash($password, PASSWORD_ARGON2ID);  // PHP 7.3+

// ✅ Verify
if (password_verify($inputPassword, $storedHash)) {
    // Authentication successful
}

// ✅ Check if hash needs rehashing (algorithm upgrade)
if (password_needs_rehash($storedHash, PASSWORD_BCRYPT, ['cost' => 12])) {
    $newHash = password_hash($inputPassword, PASSWORD_BCRYPT, ['cost' => 12]);
    updatePasswordHash($userId, $newHash);
}

// ❌ NEVER: Use md5(), sha1(), or sha256() for passwords
// ❌ NEVER: Use plain text passwords
// ❌ NEVER: Create your own hashing scheme

// ── Input Validation ──
// ✅ Use filter_var for basic validation
$email = filter_var($input, FILTER_VALIDATE_EMAIL);
$url = filter_var($input, FILTER_VALIDATE_URL);
$int = filter_var($input, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1, 'max_range' => 100]]);

// ✅ Use prepared statements for ALL database queries
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email');
$stmt->execute(['email' => $email]);

// ❌ NEVER: String interpolation in SQL
$pdo->query("SELECT * FROM users WHERE email = '$email'");  // SQL INJECTION!

// ── Output Encoding ──
// ✅ Always escape output
echo htmlspecialchars($userInput, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');

// ── CSRF Protection ──
// ✅ Generate token
$token = bin2hex(random_bytes(32));
$_SESSION['csrf_token'] = $token;

// ✅ Verify token
if (!hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
    throw new \RuntimeException('CSRF token mismatch');
}
// WHY hash_equals: Prevents timing attacks (constant-time comparison)

// ── Random Token Generation ──
// ✅ Use cryptographically secure randomness
$token = bin2hex(random_bytes(32));         // 64 hex chars
$apiKey = base64_encode(random_bytes(32));  // Base64 encoded

// ❌ NEVER: Use rand(), mt_rand(), or uniqid() for security tokens
```

---

## Testing with PHPUnit

```php
<?php

namespace Tests\Unit\Service;

use App\DTO\CreateUserDto;
use App\Entity\User;
use App\Exception\EmailAlreadyExistsException;
use App\Repository\UserRepositoryInterface;
use App\Service\UserService;
use PHPUnit\Framework\TestCase;

class UserServiceTest extends TestCase
{
    private UserRepositoryInterface $mockRepo;
    private UserService $service;

    protected function setUp(): void
    {
        $this->mockRepo = $this->createMock(UserRepositoryInterface::class);
        $this->service = new UserService($this->mockRepo);
    }

    public function test_register_creates_user_successfully(): void
    {
        $dto = new CreateUserDto(
            name: 'John Doe',
            email: 'john@example.com',
            password: 'SecureP@ss123',
        );

        $expectedUser = new User('uuid', 'John Doe', 'john@example.com');

        $this->mockRepo
            ->expects($this->once())
            ->method('findByEmail')
            ->with('john@example.com')
            ->willReturn(null);

        $this->mockRepo
            ->expects($this->once())
            ->method('create')
            ->with($dto)
            ->willReturn($expectedUser);

        $user = $this->service->register($dto);

        $this->assertSame('john@example.com', $user->getEmail());
    }

    public function test_register_throws_on_duplicate_email(): void
    {
        $this->expectException(EmailAlreadyExistsException::class);

        $this->mockRepo
            ->method('findByEmail')
            ->willReturn(new User('uuid', 'Existing', 'exists@example.com'));

        $this->service->register(new CreateUserDto(
            name: 'Test',
            email: 'exists@example.com',
            password: 'Password123!',
        ));
    }

    /**
     * @dataProvider invalidEmailProvider
     */
    public function test_rejects_invalid_emails(string $email): void
    {
        $this->assertFalse(filter_var($email, FILTER_VALIDATE_EMAIL));
    }

    public static function invalidEmailProvider(): array
    {
        return [
            'missing @' => ['invalid-email'],
            'missing domain' => ['user@'],
            'spaces' => ['user @example.com'],
            'double dots' => ['user@example..com'],
        ];
    }
}
```

### phpunit.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="https://schema.phpunit.de/11.0/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         colors="true"
         failOnRisky="true"
         failOnWarning="true">

    <testsuites>
        <testsuite name="Unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="Integration">
            <directory>tests/Integration</directory>
        </testsuite>
    </testsuites>

    <source>
        <include>
            <directory>src</directory>
        </include>
    </source>
</phpunit>
```

---

## PHPStan Configuration
```neon
# phpstan.neon
parameters:
    level: 8                          # Maximum strictness
    paths:
        - src
    treatPhpDocTypesAsCertain: false
    reportUnmatchedIgnoredErrors: false
    checkMissingIterableValueType: true
    checkGenericClassInNonGenericObjectType: true
```

---

## Anti-Patterns

```php
// ❌ NEVER: Suppress errors with @
$result = @file_get_contents($url);  // ❌ Hides errors
// ✅ Handle errors properly
$result = file_get_contents($url);
if ($result === false) {
    throw new \RuntimeException("Failed to fetch: $url");
}

// ❌ NEVER: Mixed return types without union declaration
function badFind($id) {         // ❌ Returns User or false or null?
    // ...
}
function goodFind(string $id): ?User {  // ✅ Clear: returns User or null
    // ...
}

// ❌ NEVER: Using global variables or superglobals directly
$name = $_GET['name'];          // ❌ Unvalidated, XSS risk
$name = filter_input(INPUT_GET, 'name', FILTER_SANITIZE_SPECIAL_CHARS); // ✅

// ❌ NEVER: Tight coupling (use interfaces)
class BadService {
    public function __construct() {
        $this->repo = new UserRepository();  // ❌ Untestable, tightly coupled
    }
}
// ✅ Use dependency injection
class GoodService {
    public function __construct(
        private readonly UserRepositoryInterface $repo,  // ✅ Interface, injectable
    ) {}
}
```

---

## Rules Integration
- **PSR Standards**: PSR-4 (Autoloading), PSR-12 (Code Style), PSR-3 (Logging), PSR-7 (HTTP Messages)
- **SOLID**: Service-Repository pattern, DI via constructor, interfaces for contracts
- **Security**: `password_hash()` with BCRYPT/ARGON2ID, prepared statements, `htmlspecialchars()`, `hash_equals()`, CSRF tokens
- **Quality**: PHPStan level 8, PHP-CS-Fixer, PHPUnit with data providers
- **Modern PHP**: Readonly classes, backed enums, match expression, named arguments, constructor promotion
