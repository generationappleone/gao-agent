---
name: PHPStan & Larastan
description: Skill for PHP static analysis with PHPStan and Larastan (Laravel), covering rule levels, custom rules, baseline management, and CI integration.
---

# PHPStan & Larastan Skill

## Overview
PHPStan finds bugs in PHP code without running it. Larastan extends PHPStan with Laravel-specific features (models, facades, config).

## Installation
```bash
# PHPStan
composer require --dev phpstan/phpstan

# Larastan (for Laravel projects)
composer require --dev larastan/larastan

# Extensions
composer require --dev phpstan/phpstan-strict-rules
composer require --dev phpstan/phpstan-deprecation-rules
```

## Configuration — `phpstan.neon`
```neon
includes:
    - vendor/larastan/larastan/extension.neon   # Laravel only
    - vendor/phpstan/phpstan-strict-rules/rules.neon

parameters:
    level: 8          # 0-9 (9 = strictest)
    paths:
        - app
        - config
        - database
        - routes
    excludePaths:
        - app/Console/Kernel.php
        - vendor
    checkMissingIterableValueType: true
    checkGenericClassInNonGenericObjectType: true
    reportUnmatchedIgnoredErrors: true
    ignoreErrors:
        - '#Call to an undefined method Illuminate\\Database\\Eloquent\\Builder#'
```

## Levels Explained

| Level | Checks |
|-------|--------|
| 0 | Basic checks, unknown classes, functions |
| 1 | + possibly undefined variables |
| 2 | + unknown methods on all expressions |
| 3 | + return types, type hints |
| 4 | + dead code, unreachable statements |
| 5 | + argument types in function calls |
| 6 | + missing typehints |
| 7 | + union types fully checked |
| 8 | + nullable types |
| 9 | + mixed type (strictest) |

**Recommendation:** Start at level 5, gradually increase to 8+.

## CLI
```bash
vendor/bin/phpstan analyse                    # run analysis
vendor/bin/phpstan analyse --level 8          # specific level
vendor/bin/phpstan analyse app/Models         # specific path
vendor/bin/phpstan analyse --error-format=json > phpstan.json  # JSON
vendor/bin/phpstan analyse --generate-baseline    # create baseline
vendor/bin/phpstan analyse --memory-limit=2G      # increase memory
```

## Baseline Management
```bash
# Generate baseline (ignore existing errors)
vendor/bin/phpstan analyse --generate-baseline

# This creates phpstan-baseline.neon
# Add to phpstan.neon:
# includes:
#     - phpstan-baseline.neon
```

---

## Pest PHP (Testing Framework)

### Installation
```bash
composer require --dev pestphp/pest
php artisan pest:install   # Laravel
./vendor/bin/pest --init   # Non-Laravel
```

### Test Example
```php
test('user can be created', function () {
    $user = User::factory()->create();
    expect($user->id)->not()->toBeNull();
    expect($user->email)->toBeString();
});

test('api returns users', function () {
    User::factory()->count(3)->create();
    $response = $this->getJson('/api/users');
    $response->assertOk()
        ->assertJsonCount(3, 'data');
});

it('validates required fields', function () {
    $response = $this->postJson('/api/users', []);
    $response->assertUnprocessable()
        ->assertJsonValidationErrors(['name', 'email']);
});

// Dataset testing
it('rejects invalid emails', function (string $email) {
    $response = $this->postJson('/api/users', ['email' => $email, 'name' => 'Test', 'password' => 'Pass123!']);
    $response->assertUnprocessable();
})->with(['not-email', '@invalid', 'missing@', '']);
```

### CLI
```bash
./vendor/bin/pest                          # run all
./vendor/bin/pest --filter="user"          # filter
./vendor/bin/pest --coverage               # coverage
./vendor/bin/pest --parallel               # parallel execution
./vendor/bin/pest --type-coverage          # type coverage
```

## Best Practices
- Start PHPStan at level 5, increase gradually
- Use baseline for legacy code — fix errors incrementally
- Run PHPStan in CI/CD — fail on new errors above baseline
- Use Larastan for Laravel — it understands Eloquent, Facades, config
- Combine PHPStan with Pest for complete quality assurance
- Use `@phpstan-ignore-next-line` only with justification comment
