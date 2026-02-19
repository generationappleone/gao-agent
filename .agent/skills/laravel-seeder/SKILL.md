---
name: Laravel Seeder
description: Skill for creating database seeders in Laravel — covering DatabaseSeeder, model factories, Faker, relationships, conditional seeding, chunked inserts, environment-aware seeding, and production-safe patterns.
---

# Laravel Seeder Skill

## Overview
Laravel Seeders populate databases with initial or test data. Combined with Model Factories and Faker, they enable reproducible, realistic data generation for development, testing, and production initialization.

**Reference**: [Laravel Database Seeding](https://laravel.com/docs/seeding)

---

## 1. Artisan Commands

```bash
# Create seeder
php artisan make:seeder UserSeeder
php artisan make:seeder RoleSeeder
php artisan make:seeder ProductSeeder

# Create factory
php artisan make:factory UserFactory --model=User
php artisan make:factory ProductFactory --model=Product

# Run all seeders
php artisan db:seed

# Run specific seeder
php artisan db:seed --class=UserSeeder

# Migrate fresh + seed (development only)
php artisan migrate:fresh --seed

# Run seeder in specific environment
php artisan db:seed --env=staging
```

---

## 2. DatabaseSeeder (Master Seeder)

```php
<?php
// database/seeders/DatabaseSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\App;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     * 
     * ⚠️ RULE: Order matters — seed parent tables before child tables
     * ⚠️ RULE: Use call() method, never instantiate seeders directly
     */
    public function run(): void
    {
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Phase 1: Master Data (always needed)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        $this->call([
            RoleSeeder::class,
            PermissionSeeder::class,
            CategorySeeder::class,
            SettingSeeder::class,
        ]);

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Phase 2: Users & Auth (always needed)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        $this->call([
            AdminUserSeeder::class, // Production-safe: creates default admin
        ]);

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Phase 3: Dummy Data (development/testing only)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (App::environment(['local', 'testing', 'staging'])) {
            $this->call([
                UserSeeder::class,
                ProductSeeder::class,
                OrderSeeder::class,
                ReviewSeeder::class,
            ]);
        }
    }
}
```

---

## 3. Model Factory

### 3.1 Basic Factory

```php
<?php
// database/factories/UserFactory.php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserFactory extends Factory
{
    protected $model = User::class;

    /**
     * Define the model's default state.
     */
    public function definition(): array
    {
        return [
            'name'              => fake()->name(),
            'email'             => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'phone'             => fake()->unique()->phoneNumber(),
            'password'          => Hash::make('password'), // ✅ Same default for dev
            'avatar'            => fake()->imageUrl(200, 200, 'people'),
            'address'           => fake()->address(),
            'city'              => fake()->city(),
            'country'           => fake()->country(),
            'date_of_birth'     => fake()->dateTimeBetween('-60 years', '-18 years'),
            'bio'               => fake()->paragraph(3),
            'is_active'         => true,
            'remember_token'    => Str::random(10),
        ];
    }

    // ━━━ Factory States ━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * State: Admin user
     */
    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'admin',
            'is_active' => true,
        ]);
    }

    /**
     * State: Inactive user
     */
    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }

    /**
     * State: Unverified email
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    /**
     * State: With specific role
     */
    public function withRole(string $role): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => $role,
        ]);
    }

    /**
     * State: With Indonesian locale data
     */
    public function indonesian(): static
    {
        $faker = \Faker\Factory::create('id_ID');
        return $this->state(fn (array $attributes) => [
            'name'    => $faker->name(),
            'phone'   => $faker->phoneNumber(),
            'address' => $faker->address(),
            'city'    => $faker->city(),
            'country' => 'Indonesia',
        ]);
    }
}
```

### 3.2 Complex Factory with Relationships

```php
<?php
// database/factories/ProductFactory.php

namespace Database\Factories;

use App\Models\Product;
use App\Models\Category;
use App\Models\Brand;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition(): array
    {
        $name = fake()->words(3, true);
        $price = fake()->randomFloat(2, 10000, 5000000);

        return [
            'name'        => ucfirst($name),
            'slug'        => Str::slug($name) . '-' . Str::random(5),
            'sku'         => strtoupper(Str::random(3)) . '-' . fake()->numerify('####'),
            'description' => fake()->paragraphs(3, true),
            'price'       => $price,
            'sale_price'  => fake()->boolean(30) ? $price * 0.8 : null, // 30% chance sale
            'stock'       => fake()->numberBetween(0, 500),
            'weight'      => fake()->randomFloat(2, 0.1, 50),
            'category_id' => Category::factory(),
            'brand_id'    => Brand::factory(),
            'is_active'   => fake()->boolean(90), // 90% active
            'is_featured' => fake()->boolean(10), // 10% featured
            'views'       => fake()->numberBetween(0, 10000),
            'rating'      => fake()->randomFloat(1, 1, 5),
            'meta_title'       => ucfirst($name),
            'meta_description' => fake()->sentence(15),
        ];
    }

    // States
    public function outOfStock(): static
    {
        return $this->state(fn () => ['stock' => 0, 'is_active' => false]);
    }

    public function featured(): static
    {
        return $this->state(fn () => ['is_featured' => true, 'is_active' => true]);
    }

    public function onSale(): static
    {
        return $this->state(fn (array $attr) => [
            'sale_price' => $attr['price'] * fake()->randomFloat(2, 0.5, 0.9),
        ]);
    }

    /**
     * After creating: attach images & tags
     */
    public function configure(): static
    {
        return $this->afterCreating(function (Product $product) {
            // Attach 2-5 random tags
            $tagIds = \App\Models\Tag::inRandomOrder()->limit(rand(2, 5))->pluck('id');
            $product->tags()->attach($tagIds);
        });
    }
}
```

### 3.3 Factory for Pivot / Many-to-Many

```php
<?php
// database/factories/OrderFactory.php

namespace Database\Factories;

use App\Models\Order;
use App\Models\User;
use App\Models\Product;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
    {
        $subtotal = fake()->randomFloat(2, 50000, 10000000);
        $tax = $subtotal * 0.11; // PPN 11%
        $shipping = fake()->randomElement([0, 15000, 25000, 50000]);

        return [
            'user_id'        => User::factory(),
            'order_number'   => 'ORD-' . now()->format('Ymd') . '-' . strtoupper(\Str::random(6)),
            'status'         => fake()->randomElement(['pending', 'processing', 'shipped', 'delivered', 'cancelled']),
            'payment_method' => fake()->randomElement(['bank_transfer', 'credit_card', 'e_wallet', 'cod']),
            'payment_status' => fake()->randomElement(['pending', 'paid', 'failed', 'refunded']),
            'subtotal'       => $subtotal,
            'tax'            => $tax,
            'shipping_cost'  => $shipping,
            'total'          => $subtotal + $tax + $shipping,
            'shipping_address' => fake()->address(),
            'notes'          => fake()->boolean(30) ? fake()->sentence() : null,
            'ordered_at'     => fake()->dateTimeBetween('-6 months', 'now'),
        ];
    }

    /**
     * After creating: attach order items
     */
    public function configure(): static
    {
        return $this->afterCreating(function (Order $order) {
            $products = Product::inRandomOrder()->limit(rand(1, 5))->get();
            foreach ($products as $product) {
                $qty = rand(1, 3);
                $order->items()->create([
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'quantity' => $qty,
                    'unit_price' => $product->price,
                    'subtotal' => $product->price * $qty,
                ]);
            }
            // Recalculate total
            $order->update([
                'subtotal' => $order->items->sum('subtotal'),
                'total'    => $order->items->sum('subtotal') + $order->tax + $order->shipping_cost,
            ]);
        });
    }

    // States
    public function paid(): static
    {
        return $this->state(fn () => [
            'status' => 'processing',
            'payment_status' => 'paid',
        ]);
    }

    public function delivered(): static
    {
        return $this->state(fn () => [
            'status' => 'delivered',
            'payment_status' => 'paid',
        ]);
    }
}
```

---

## 4. Seeder Patterns

### 4.1 Master Data Seeder (Production-Safe)

```php
<?php
// database/seeders/RoleSeeder.php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * ✅ Production-safe: uses updateOrCreate
     * Can run multiple times without duplicating data
     */
    public function run(): void
    {
        $roles = [
            [
                'name'        => 'super_admin',
                'display_name' => 'Super Administrator',
                'description' => 'Full system access with all permissions',
                'is_system'   => true,
            ],
            [
                'name'        => 'admin',
                'display_name' => 'Administrator',
                'description' => 'Administrative access to manage data',
                'is_system'   => true,
            ],
            [
                'name'        => 'manager',
                'display_name' => 'Manager',
                'description' => 'Department-level management access',
                'is_system'   => false,
            ],
            [
                'name'        => 'staff',
                'display_name' => 'Staff',
                'description' => 'Standard staff access',
                'is_system'   => false,
            ],
            [
                'name'        => 'user',
                'display_name' => 'User',
                'description' => 'Default user role',
                'is_system'   => true,
            ],
        ];

        foreach ($roles as $role) {
            Role::updateOrCreate(
                ['name' => $role['name']],  // unique key
                $role                        // data to insert/update
            );
        }

        $this->command->info('✅ Roles seeded: ' . count($roles) . ' roles');
    }
}
```

### 4.2 Permission Seeder

```php
<?php
// database/seeders/PermissionSeeder.php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Seeder;

class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Define permissions by module
        $modules = [
            'users'      => ['view', 'create', 'edit', 'delete', 'export'],
            'products'   => ['view', 'create', 'edit', 'delete', 'export', 'import'],
            'orders'     => ['view', 'create', 'edit', 'delete', 'export', 'approve'],
            'reports'    => ['view', 'export', 'generate'],
            'settings'   => ['view', 'edit'],
            'roles'      => ['view', 'create', 'edit', 'delete', 'assign'],
        ];

        $allPermissions = [];

        foreach ($modules as $module => $actions) {
            foreach ($actions as $action) {
                $permission = Permission::updateOrCreate(
                    ['name' => "{$module}.{$action}"],
                    [
                        'display_name' => ucfirst($action) . ' ' . ucfirst($module),
                        'module'       => $module,
                    ]
                );
                $allPermissions[] = $permission->id;
            }
        }

        // Assign all permissions to super_admin
        $superAdmin = Role::where('name', 'super_admin')->first();
        if ($superAdmin) {
            $superAdmin->permissions()->sync($allPermissions);
        }

        // Assign limited permissions to admin
        $admin = Role::where('name', 'admin')->first();
        if ($admin) {
            $adminPermissions = Permission::whereIn('name', [
                'users.view', 'users.create', 'users.edit',
                'products.view', 'products.create', 'products.edit', 'products.delete',
                'orders.view', 'orders.edit', 'orders.approve',
                'reports.view', 'reports.export',
            ])->pluck('id');
            $admin->permissions()->sync($adminPermissions);
        }

        $this->command->info('✅ Permissions seeded: ' . count($allPermissions) . ' permissions');
    }
}
```

### 4.3 Admin User Seeder (Production-Safe)

```php
<?php
// database/seeders/AdminUserSeeder.php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Role;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * ✅ Production-safe: creates default admin if not exists
     * ⚠️ MUST change password after first login
     */
    public function run(): void
    {
        $admin = User::updateOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name'              => 'System Administrator',
                'password'          => Hash::make(env('ADMIN_DEFAULT_PASSWORD', 'Ch@ngeM3!')),
                'email_verified_at' => now(),
                'is_active'         => true,
                'must_change_password' => true, // Force password change
            ]
        );

        // Assign super_admin role
        $superAdminRole = Role::where('name', 'super_admin')->first();
        if ($superAdminRole && !$admin->roles->contains($superAdminRole->id)) {
            $admin->roles()->attach($superAdminRole->id);
        }

        $this->command->info("✅ Admin user seeded: {$admin->email}");
    }
}
```

### 4.4 Dummy Data Seeder (Development Only)

```php
<?php
// database/seeders/UserSeeder.php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Role;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // ⚠️ Guard: prevent running in production
        if (app()->environment('production')) {
            $this->command->error('❌ Cannot run UserSeeder in production!');
            return;
        }

        $this->command->info('🔄 Seeding users...');

        // Get roles for assignment
        $adminRole   = Role::where('name', 'admin')->first();
        $managerRole = Role::where('name', 'manager')->first();
        $staffRole   = Role::where('name', 'staff')->first();
        $userRole    = Role::where('name', 'user')->first();

        // Create admin users
        User::factory()
            ->count(3)
            ->create()
            ->each(fn ($user) => $user->roles()->attach($adminRole));

        // Create managers with Indonesian locale
        User::factory()
            ->count(5)
            ->indonesian()
            ->create()
            ->each(fn ($user) => $user->roles()->attach($managerRole));

        // Create staff
        User::factory()
            ->count(10)
            ->indonesian()
            ->create()
            ->each(fn ($user) => $user->roles()->attach($staffRole));

        // Create regular users
        User::factory()
            ->count(50)
            ->indonesian()
            ->create()
            ->each(fn ($user) => $user->roles()->attach($userRole));

        // Create some inactive users
        User::factory()
            ->count(5)
            ->inactive()
            ->unverified()
            ->create()
            ->each(fn ($user) => $user->roles()->attach($userRole));

        $total = User::count();
        $this->command->info("✅ Users seeded: {$total} total users");
    }
}
```

### 4.5 Product Seeder with Categories & Tags

```php
<?php
// database/seeders/ProductSeeder.php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\Category;
use App\Models\Brand;
use App\Models\Tag;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        if (app()->environment('production')) {
            $this->command->error('❌ Cannot run ProductSeeder in production!');
            return;
        }

        $this->command->info('🔄 Seeding products...');

        // 1. Create categories first
        $categories = collect([
            'Electronics', 'Clothing', 'Books', 'Home & Garden',
            'Sports', 'Toys', 'Health', 'Automotive',
        ])->map(fn ($name) => Category::updateOrCreate(
            ['slug' => \Str::slug($name)],
            ['name' => $name, 'description' => fake()->sentence()]
        ));

        // 2. Create brands
        $brands = collect([
            'Samsung', 'Apple', 'Sony', 'Nike', 'Adidas',
            'Uniqlo', 'Toyota', 'Honda',
        ])->map(fn ($name) => Brand::updateOrCreate(
            ['slug' => \Str::slug($name)],
            ['name' => $name]
        ));

        // 3. Create tags
        $tags = collect([
            'New Arrival', 'Best Seller', 'Limited', 'Eco-Friendly',
            'Premium', 'Budget', 'Trending', 'Sale',
        ])->map(fn ($name) => Tag::updateOrCreate(
            ['slug' => \Str::slug($name)],
            ['name' => $name]
        ));

        // 4. Create products
        $categories->each(function ($category) use ($brands) {
            // 10-20 products per category
            Product::factory()
                ->count(rand(10, 20))
                ->for($category)
                ->for($brands->random(), 'brand')
                ->create();
        });

        // 5. Create featured products
        Product::factory()
            ->count(5)
            ->featured()
            ->for($categories->random())
            ->for($brands->random(), 'brand')
            ->create();

        // 6. Create products on sale
        Product::factory()
            ->count(10)
            ->onSale()
            ->for($categories->random())
            ->for($brands->random(), 'brand')
            ->create();

        $this->command->info('✅ Products seeded: ' . Product::count() . ' products');
    }
}
```

### 4.6 Setting Seeder

```php
<?php
// database/seeders/SettingSeeder.php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    /**
     * ✅ Production-safe: uses updateOrCreate
     */
    public function run(): void
    {
        $settings = [
            // General
            ['group' => 'general', 'key' => 'app_name',     'value' => 'MyApp',            'type' => 'string'],
            ['group' => 'general', 'key' => 'app_tagline',  'value' => 'Your tagline here', 'type' => 'string'],
            ['group' => 'general', 'key' => 'timezone',     'value' => 'Asia/Jakarta',      'type' => 'string'],
            ['group' => 'general', 'key' => 'locale',       'value' => 'id',                'type' => 'string'],
            ['group' => 'general', 'key' => 'currency',     'value' => 'IDR',               'type' => 'string'],

            // Mail
            ['group' => 'mail',    'key' => 'from_name',    'value' => 'MyApp',             'type' => 'string'],
            ['group' => 'mail',    'key' => 'from_address', 'value' => 'noreply@myapp.com', 'type' => 'string'],

            // Features
            ['group' => 'feature', 'key' => 'registration_enabled', 'value' => 'true',     'type' => 'boolean'],
            ['group' => 'feature', 'key' => 'maintenance_mode',     'value' => 'false',    'type' => 'boolean'],
            ['group' => 'feature', 'key' => 'max_upload_size_mb',   'value' => '10',       'type' => 'integer'],

            // Pagination
            ['group' => 'display', 'key' => 'items_per_page', 'value' => '20',             'type' => 'integer'],
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }

        $this->command->info('✅ Settings seeded: ' . count($settings) . ' settings');
    }
}
```

---

## 5. Chunked Insert (Large Data)

```php
<?php
// database/seeders/LargeDataSeeder.php

namespace Database\Seeders;

use App\Models\Transaction;
use Illuminate\Database\Seeder;
use Illuminate\Support\LazyCollection;

class LargeDataSeeder extends Seeder
{
    /**
     * Seed 100,000 records efficiently using chunked insert
     * ✅ Memory-efficient — does NOT load all records at once
     */
    public function run(): void
    {
        $totalRecords = 100000;
        $chunkSize = 1000;
        $bar = $this->command->getOutput()->createProgressBar($totalRecords);

        $this->command->info("🔄 Seeding {$totalRecords} transactions...");

        // Disable query log to save memory
        \DB::disableQueryLog();

        // Insert in chunks
        collect(range(1, $totalRecords))
            ->chunk($chunkSize)
            ->each(function ($chunk) use ($bar) {
                $records = $chunk->map(fn () => [
                    'id'          => \Str::uuid()->toString(),
                    'user_id'     => \App\Models\User::inRandomOrder()->value('id'),
                    'type'        => fake()->randomElement(['credit', 'debit']),
                    'amount'      => fake()->randomFloat(2, 1000, 50000000),
                    'description' => fake()->sentence(),
                    'status'      => fake()->randomElement(['pending', 'completed', 'failed']),
                    'created_at'  => fake()->dateTimeBetween('-1 year', 'now'),
                    'updated_at'  => now(),
                ])->toArray();

                Transaction::insert($records); // ✅ Bulk insert
                $bar->advance(count($records));
            });

        $bar->finish();
        $this->command->newLine();
        $this->command->info("✅ Transactions seeded: {$totalRecords} records");
    }
}
```

---

## 6. Indonesian Locale Faker

```php
<?php
// In factory or seeder
$faker = \Faker\Factory::create('id_ID');

// Indonesian-specific data
$faker->name();          // "Galih Pratama", "Siti Nurhaliza"
$faker->address();       // "Jl. Merdeka No. 45, Jakarta Selatan"
$faker->city();          // "Surabaya", "Bandung", "Yogyakarta"
$faker->phoneNumber();   // "021-7654321", "0812-3456-7890"
$faker->nik();           // NIK (16 digit)
$faker->company();       // "PT Maju Jaya"

// Configure in AppServiceProvider for global usage
// config/app.php
'faker_locale' => 'id_ID',
```

---

## 7. Testing with Factories

```php
<?php
// tests/Feature/OrderTest.php

use App\Models\User;
use App\Models\Product;
use App\Models\Order;

test('user can create order', function () {
    // Arrange
    $user = User::factory()->create();
    $products = Product::factory()->count(3)->create();

    // Act
    $response = $this->actingAs($user)->postJson('/api/orders', [
        'items' => $products->map(fn ($p) => [
            'product_id' => $p->id,
            'quantity' => 2,
        ])->toArray(),
    ]);

    // Assert
    $response->assertCreated();
    $this->assertDatabaseCount('orders', 1);
    $this->assertDatabaseCount('order_items', 3);
});

test('admin can view all orders', function () {
    // Arrange
    $admin = User::factory()->admin()->create();
    Order::factory()->count(10)->paid()->create();

    // Act & Assert
    $this->actingAs($admin)
        ->getJson('/api/orders')
        ->assertOk()
        ->assertJsonCount(10, 'data');
});
```

---

## 8. Best Practices

| # | Practice | Description |
|---|----------|-------------|
| 1 | **`updateOrCreate`** | Use for master data — safe to run multiple times (idempotent) |
| 2 | **Environment guard** | Check `app()->environment()` — never seed dummy data in production |
| 3 | **Order of execution** | Seed parent tables before child tables (roles → users → orders) |
| 4 | **Factory states** | Use `->admin()`, `->inactive()` for variations, not separate factories |
| 5 | **`configure()`** | Use for automatic relationship seeding after creation |
| 6 | **Chunked insert** | Use `Model::insert()` with chunks for 1000+ records |
| 7 | **Progress bar** | Show progress for large seeders via `$this->command` |
| 8 | **Indonesian locale** | Set `faker_locale => 'id_ID'` in `config/app.php` |
| 9 | **Consistent passwords** | Use `Hash::make('password')` in dev for easy testing |
| 10 | **No hardcoded IDs** | Use `Model::factory()` or `inRandomOrder()->value('id')` |
| 11 | **Disable query log** | `DB::disableQueryLog()` for large data seeding |
| 12 | **Test integration** | Use same factories in feature tests for consistency |

---

## 9. Common Faker Methods

| Method | Output | Description |
|--------|--------|-------------|
| `fake()->name()` | "John Doe" | Full name |
| `fake()->email()` | "john@example.com" | Email address |
| `fake()->unique()->email()` | Unique email | Guaranteed unique |
| `fake()->phoneNumber()` | "+1-555-123-4567" | Phone number |
| `fake()->address()` | "123 Main St..." | Full address |
| `fake()->sentence()` | "Lorem ipsum..." | One sentence |
| `fake()->paragraph()` | Multiple sentences | One paragraph |
| `fake()->randomFloat(2, 0, 1000)` | 123.45 | Decimal number |
| `fake()->numberBetween(1, 100)` | 42 | Integer range |
| `fake()->randomElement([...])` | Random item | From array |
| `fake()->boolean(70)` | true/false | 70% chance true |
| `fake()->dateTimeBetween('-1y', 'now')` | DateTime | Date in range |
| `fake()->imageUrl(640, 480)` | URL string | Placeholder image |
| `fake()->uuid()` | UUID string | UUID v4 |
| `fake()->url()` | "https://..." | Random URL |
| `fake()->ipv4()` | "192.168.1.1" | IPv4 address |
| `fake()->hexColor()` | "#fa3cc2" | Hex color code |
| `fake()->creditCardNumber()` | "4111..." | Fake CC number |
| `fake()->iban()` | "GB82..." | IBAN number |

---

## 10. File Naming & Organization

```
database/
├── factories/
│   ├── UserFactory.php          # One factory per model
│   ├── ProductFactory.php
│   ├── OrderFactory.php
│   ├── CategoryFactory.php
│   └── BrandFactory.php
├── seeders/
│   ├── DatabaseSeeder.php       # Master seeder (orchestrator)
│   ├── RoleSeeder.php           # Master data (production-safe)
│   ├── PermissionSeeder.php     # Master data (production-safe)
│   ├── SettingSeeder.php        # Master data (production-safe)
│   ├── AdminUserSeeder.php      # Default admin (production-safe)
│   ├── CategorySeeder.php       # Master data (production-safe)
│   ├── UserSeeder.php           # Dummy data (dev only)
│   ├── ProductSeeder.php        # Dummy data (dev only)
│   └── OrderSeeder.php          # Dummy data (dev only)
└── migrations/
    └── ...
```

**Naming Convention**: `{ModelName}Seeder.php` — singular, PascalCase, ends with `Seeder`
