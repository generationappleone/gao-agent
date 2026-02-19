# 🏗️ SOLID Principles — Mandatory Coding Rule

> **Severity:** STRICT  
> **Scope:** All code written, modified, or refactored by the agent  
> **Applies to:** All programming languages (TypeScript, JavaScript, Python, Go, etc.)

---

## Overview

When writing or modifying code, the agent **MUST** apply **SOLID** principles. If existing code violates these principles, the agent must refactor it before completing the task.

---

## 1. Single Responsibility Principle (SRP)

> *"A class/module/function should have only ONE reason to change."*

### ✅ MUST do:
- Each class/module handles only **one specific responsibility**
- Each function performs only **one clear task**
- Separate business logic, data access, and presentation into different files/classes
- Use naming that reflects a single responsibility (e.g., `UserValidator`, `EmailSender`, `OrderRepository`)

### ❌ MUST NOT do:
- Create "God classes" or "God functions" that handle multiple concerns at once
- Mix business logic with UI logic in a single file
- Place validation, transformation, and persistence in a single function

### 📏 Guidelines:
- Maximum **20-30 lines** per function (soft limit, may exceed if genuinely necessary)
- Maximum **200 lines** per file/class (soft limit)
- If a class has more than **5 public methods**, consider splitting it

### 💡 Example: User Registration System

```typescript
// ❌ FORBIDDEN: God class that handles everything
class UserManager {
  async registerUser(data: any) {
    // Validation (responsibility #1)
    if (!data.email || !data.email.includes('@')) throw new Error('Invalid email');
    if (!data.password || data.password.length < 8) throw new Error('Weak password');

    // Password hashing (responsibility #2)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(data.password, salt);

    // Database insertion (responsibility #3)
    const user = await db.query(
      'INSERT INTO users (email, password) VALUES ($1, $2) RETURNING *',
      [data.email, hashedPassword]
    );

    // Send welcome email (responsibility #4)
    const transporter = nodemailer.createTransport({ host: 'smtp.example.com' });
    await transporter.sendMail({
      to: data.email,
      subject: 'Welcome!',
      html: `<h1>Welcome ${data.email}</h1>`,
    });

    // Generate JWT token (responsibility #5)
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    return { user, token };
  }
}
```

```typescript
// ✅ REQUIRED: Each class has a single responsibility

// --- validators/user.validator.ts ---
class UserValidator {
  validate(data: CreateUserDto): ValidationResult {
    const errors: string[] = [];
    if (!data.email || !data.email.includes('@')) errors.push('Invalid email');
    if (!data.password || data.password.length < 8) errors.push('Weak password');
    return { isValid: errors.length === 0, errors };
  }
}

// --- services/password.service.ts ---
class PasswordService {
  private readonly SALT_ROUNDS = 10;

  async hash(plainPassword: string): Promise<string> {
    const salt = await bcrypt.genSalt(this.SALT_ROUNDS);
    return bcrypt.hash(plainPassword, salt);
  }

  async verify(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }
}

// --- repositories/user.repository.ts ---
class UserRepository {
  constructor(private readonly db: Database) {}

  async create(data: { email: string; password: string }): Promise<User> {
    const result = await this.db.query(
      'INSERT INTO users (id, email, password) VALUES ($1, $2, $3) RETURNING *',
      [uuidv7(), data.email, data.password]
    );
    return result.rows[0];
  }

  async findByEmail(email: string): Promise<User | null> {
    const result = await this.db.query('SELECT * FROM users WHERE email = $1', [email]);
    return result.rows[0] || null;
  }
}

// --- services/email.service.ts ---
class EmailService {
  constructor(private readonly transporter: Transporter) {}

  async sendWelcomeEmail(email: string): Promise<void> {
    await this.transporter.sendMail({
      to: email,
      subject: 'Welcome!',
      html: `<h1>Welcome ${email}</h1>`,
    });
  }
}

// --- services/auth.service.ts ---
class AuthService {
  constructor(private readonly jwtSecret: string) {}

  generateToken(userId: string): string {
    return jwt.sign({ userId }, this.jwtSecret, { expiresIn: '1h' });
  }
}

// --- services/user.service.ts (orchestrator) ---
class UserService {
  constructor(
    private readonly validator: UserValidator,
    private readonly passwordService: PasswordService,
    private readonly userRepo: UserRepository,
    private readonly emailService: EmailService,
    private readonly authService: AuthService,
  ) {}

  async register(data: CreateUserDto): Promise<{ user: User; token: string }> {
    const validation = this.validator.validate(data);
    if (!validation.isValid) throw new ValidationError(validation.errors);

    const hashedPassword = await this.passwordService.hash(data.password);
    const user = await this.userRepo.create({ email: data.email, password: hashedPassword });
    await this.emailService.sendWelcomeEmail(user.email);
    const token = this.authService.generateToken(user.id);

    return { user, token };
  }
}
```

```python
# ✅ REQUIRED: Python — SRP applied to a data pipeline

# --- extractors/csv_extractor.py ---
class CsvExtractor:
    """Responsible ONLY for reading CSV files."""
    def extract(self, file_path: str) -> list[dict]:
        with open(file_path, 'r') as f:
            reader = csv.DictReader(f)
            return list(reader)

# --- transformers/sales_transformer.py ---
class SalesTransformer:
    """Responsible ONLY for transforming raw sales data."""
    def transform(self, raw_data: list[dict]) -> list[SalesRecord]:
        return [
            SalesRecord(
                product_id=row['product_id'],
                amount=Decimal(row['amount']),
                sold_at=datetime.fromisoformat(row['date']),
            )
            for row in raw_data
        ]

# --- loaders/database_loader.py ---
class DatabaseLoader:
    """Responsible ONLY for persisting data to the database."""
    def __init__(self, session: AsyncSession):
        self._session = session

    async def load(self, records: list[SalesRecord]) -> int:
        self._session.add_all(records)
        await self._session.commit()
        return len(records)

# --- pipelines/sales_pipeline.py ---
class SalesPipeline:
    """Orchestrates the ETL pipeline — delegates to single-responsibility classes."""
    def __init__(self, extractor: CsvExtractor, transformer: SalesTransformer, loader: DatabaseLoader):
        self._extractor = extractor
        self._transformer = transformer
        self._loader = loader

    async def run(self, file_path: str) -> int:
        raw_data = self._extractor.extract(file_path)
        records = self._transformer.transform(raw_data)
        return await self._loader.load(records)
```

---

## 2. Open/Closed Principle (OCP)

> *"Software entities should be OPEN for extension but CLOSED for modification."*

### ✅ MUST do:
- Use **abstractions** (interfaces, abstract classes, protocols) to enable extension
- Use **strategy pattern**, **plugin pattern**, or **composition** to add new behavior
- Design systems so new features can be added **without modifying existing code**
- Use **dependency injection** to swap different implementations

### ❌ MUST NOT do:
- Use long chains of `if/else` or `switch` statements to determine behavior based on type
- Modify stable, existing classes to add new features
- Hardcode logic that is likely to change in the future

### 💡 Example: Payment Processing System

```typescript
// ❌ FORBIDDEN: Adding a new payment method requires modifying existing code
class PaymentProcessor {
  processPayment(method: string, amount: number): Promise<PaymentResult> {
    if (method === 'credit_card') {
      // 50 lines of credit card logic...
      return this.chargeCreditCard(amount);
    } else if (method === 'paypal') {
      // 50 lines of PayPal logic...
      return this.chargePayPal(amount);
    } else if (method === 'bank_transfer') {
      // Every new method = modify this class!
      return this.chargeBankTransfer(amount);
    }
    throw new Error(`Unsupported payment method: ${method}`);
  }
}
```

```typescript
// ✅ REQUIRED: Strategy pattern — new payment methods added without modifying existing code

// --- interfaces/payment-strategy.interface.ts ---
interface PaymentStrategy {
  readonly methodName: string;
  charge(amount: number, details: PaymentDetails): Promise<PaymentResult>;
  refund(transactionId: string, amount: number): Promise<RefundResult>;
  validate(details: PaymentDetails): ValidationResult;
}

// --- strategies/credit-card.strategy.ts ---
class CreditCardStrategy implements PaymentStrategy {
  readonly methodName = 'credit_card';

  async charge(amount: number, details: PaymentDetails): Promise<PaymentResult> {
    const { cardNumber, expiryDate, cvv } = details;
    // Credit card specific logic...
    return { success: true, transactionId: uuidv7() };
  }

  async refund(transactionId: string, amount: number): Promise<RefundResult> {
    // Credit card refund logic...
    return { success: true };
  }

  validate(details: PaymentDetails): ValidationResult {
    // Luhn algorithm validation, etc.
    return { isValid: true, errors: [] };
  }
}

// --- strategies/paypal.strategy.ts ---
class PayPalStrategy implements PaymentStrategy {
  readonly methodName = 'paypal';

  async charge(amount: number, details: PaymentDetails): Promise<PaymentResult> {
    // PayPal specific logic...
    return { success: true, transactionId: uuidv7() };
  }

  async refund(transactionId: string, amount: number): Promise<RefundResult> { /* ... */ }
  validate(details: PaymentDetails): ValidationResult { /* ... */ }
}

// --- To add a new payment method (e.g., crypto), just create a new class:
// --- strategies/crypto.strategy.ts ---
class CryptoStrategy implements PaymentStrategy {
  readonly methodName = 'crypto';
  async charge(amount: number, details: PaymentDetails): Promise<PaymentResult> { /* ... */ }
  async refund(transactionId: string, amount: number): Promise<RefundResult> { /* ... */ }
  validate(details: PaymentDetails): ValidationResult { /* ... */ }
}

// --- services/payment.service.ts ---
class PaymentService {
  private readonly strategies: Map<string, PaymentStrategy>;

  constructor(strategies: PaymentStrategy[]) {
    this.strategies = new Map(strategies.map(s => [s.methodName, s]));
  }

  async processPayment(method: string, amount: number, details: PaymentDetails): Promise<PaymentResult> {
    const strategy = this.strategies.get(method);
    if (!strategy) throw new UnsupportedPaymentError(method);

    const validation = strategy.validate(details);
    if (!validation.isValid) throw new ValidationError(validation.errors);

    return strategy.charge(amount, details);
  }
}

// --- Registration (no modification to PaymentService needed) ---
const paymentService = new PaymentService([
  new CreditCardStrategy(),
  new PayPalStrategy(),
  new CryptoStrategy(),  // Just add the new strategy here!
]);
```

```python
# ✅ REQUIRED: Python — OCP with notification channels

from abc import ABC, abstractmethod

# --- interfaces ---
class NotificationChannel(ABC):
    @abstractmethod
    async def send(self, recipient: str, message: str) -> bool:
        ...

# --- implementations ---
class EmailNotification(NotificationChannel):
    async def send(self, recipient: str, message: str) -> bool:
        # SMTP sending logic...
        return True

class SmsNotification(NotificationChannel):
    async def send(self, recipient: str, message: str) -> bool:
        # Twilio API logic...
        return True

class SlackNotification(NotificationChannel):
    async def send(self, recipient: str, message: str) -> bool:
        # Slack Webhook logic...
        return True

# --- service (never needs modification) ---
class NotificationService:
    def __init__(self, channels: list[NotificationChannel]):
        self._channels = channels

    async def notify_all(self, recipient: str, message: str) -> dict[str, bool]:
        results = {}
        for channel in self._channels:
            results[channel.__class__.__name__] = await channel.send(recipient, message)
        return results

# Adding WhatsApp? Just create WhatsAppNotification(NotificationChannel) — no existing code modified!
```

---

## 3. Liskov Substitution Principle (LSP)

> *"Subtypes must be substitutable for their base types without breaking the program."*

### ✅ MUST do:
- Subclasses must fulfill **all contracts** (interface/type) of the parent class
- Overridden methods must have behavior **consistent** with parent expectations
- Use **composition over inheritance** when inheritance is not semantically appropriate
- Ensure return types and parameter types remain consistent when overriding

### ❌ MUST NOT do:
- Create subclasses that throw `NotImplementedError` on parent methods
- Override methods with behavior that contradicts the parent
- Use inheritance solely for code reuse without a valid "is-a" relationship

### 💡 Example: Shape Area Calculation

```typescript
// ❌ FORBIDDEN: Square violates LSP — changing width unexpectedly changes height
class Rectangle {
  constructor(protected width: number, protected height: number) {}

  setWidth(w: number): void { this.width = w; }
  setHeight(h: number): void { this.height = h; }
  getArea(): number { return this.width * this.height; }
}

class Square extends Rectangle {
  setWidth(w: number): void {
    this.width = w;
    this.height = w;  // ❌ Violates LSP — caller doesn't expect height to change!
  }

  setHeight(h: number): void {
    this.width = h;   // ❌ Same problem — unexpected side effect
    this.height = h;
  }
}

// This code breaks with Square:
function doubleWidth(rect: Rectangle): number {
  rect.setWidth(rect.getArea() / rect.getArea() * 10);
  rect.setHeight(5);
  return rect.getArea(); // Expected: 50, but Square returns 25!
}
```

```typescript
// ✅ REQUIRED: Use an interface — each shape is independently correct

interface Shape {
  getArea(): number;
  getPerimeter(): number;
}

class Rectangle implements Shape {
  constructor(private readonly width: number, private readonly height: number) {}

  getArea(): number {
    return this.width * this.height;
  }

  getPerimeter(): number {
    return 2 * (this.width + this.height);
  }
}

class Square implements Shape {
  constructor(private readonly side: number) {}

  getArea(): number {
    return this.side * this.side;
  }

  getPerimeter(): number {
    return 4 * this.side;
  }
}

class Circle implements Shape {
  constructor(private readonly radius: number) {}

  getArea(): number {
    return Math.PI * this.radius * this.radius;
  }

  getPerimeter(): number {
    return 2 * Math.PI * this.radius;
  }
}

// Any Shape can be used interchangeably — LSP satisfied
function printShapeInfo(shape: Shape): void {
  console.log(`Area: ${shape.getArea()}, Perimeter: ${shape.getPerimeter()}`);
}

printShapeInfo(new Rectangle(10, 5));  // Works correctly
printShapeInfo(new Square(7));          // Works correctly
printShapeInfo(new Circle(3));          // Works correctly
```

```python
# ❌ FORBIDDEN: ReadOnlyFileStorage violates LSP — it breaks the parent's write contract
class FileStorage:
    def read(self, path: str) -> bytes: ...
    def write(self, path: str, data: bytes) -> None: ...
    def delete(self, path: str) -> None: ...

class ReadOnlyFileStorage(FileStorage):
    def read(self, path: str) -> bytes:
        return open(path, 'rb').read()

    def write(self, path: str, data: bytes) -> None:
        raise NotImplementedError("This is read-only!")  # ❌ Violates LSP!

    def delete(self, path: str) -> None:
        raise NotImplementedError("This is read-only!")  # ❌ Violates LSP!
```

```python
# ✅ REQUIRED: Segregated interfaces — use composition
from abc import ABC, abstractmethod

class Readable(ABC):
    @abstractmethod
    def read(self, path: str) -> bytes: ...

class Writable(ABC):
    @abstractmethod
    def write(self, path: str, data: bytes) -> None: ...

class Deletable(ABC):
    @abstractmethod
    def delete(self, path: str) -> None: ...

class ReadOnlyStorage(Readable):
    def read(self, path: str) -> bytes:
        return open(path, 'rb').read()

class FullStorage(Readable, Writable, Deletable):
    def read(self, path: str) -> bytes: ...
    def write(self, path: str, data: bytes) -> None: ...
    def delete(self, path: str) -> None: ...

# Now ReadOnlyStorage never breaks any contract — it only promises to read
def process_data(source: Readable) -> bytes:
    return source.read('/data/input.bin')  # Works with both ReadOnlyStorage and FullStorage
```

---

## 4. Interface Segregation Principle (ISP)

> *"Clients should not be forced to depend on interfaces they do not use."*

### ✅ MUST do:
- Create **small, specific** interfaces (lean interfaces)
- Split large interfaces into multiple smaller ones based on client needs
- Use **composition** of multiple small interfaces rather than one large interface
- Design interfaces around the needs of the **consumer**, not the provider

### ❌ MUST NOT do:
- Create "fat interfaces" with many methods that not all implementors need
- Force classes to implement irrelevant methods
- Create a single interface for all use cases

### 📏 Guidelines:
- Ideally an interface should have **1-5 methods**
- If more than 5, consider splitting it

### 💡 Example: Worker / Robot / Human System

```typescript
// ❌ FORBIDDEN: Fat interface — Robot can't eat or sleep!
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
  reportHours(): number;
  attendMeeting(): void;
  takeBreak(): void;
}

class HumanWorker implements Worker {
  work(): void { /* ... */ }
  eat(): void { /* lunch break */ }
  sleep(): void { /* rest */ }
  reportHours(): number { return 8; }
  attendMeeting(): void { /* join meeting */ }
  takeBreak(): void { /* take a break */ }
}

class RobotWorker implements Worker {
  work(): void { /* ... */ }
  eat(): void { throw new Error('Robots cannot eat!'); }         // ❌ Forced to implement!
  sleep(): void { throw new Error('Robots cannot sleep!'); }     // ❌ Forced to implement!
  reportHours(): number { return 24; }
  attendMeeting(): void { throw new Error('Robots skip meetings!'); }  // ❌
  takeBreak(): void { /* recharge */ }
}
```

```typescript
// ✅ REQUIRED: Segregated, small interfaces

interface Workable {
  work(): void;
  reportHours(): number;
}

interface Feedable {
  eat(): void;
  takeBreak(): void;
}

interface Restable {
  sleep(): void;
}

interface Meetable {
  attendMeeting(): void;
}

// Human implements all relevant interfaces
class HumanWorker implements Workable, Feedable, Restable, Meetable {
  work(): void { /* productive work */ }
  reportHours(): number { return 8; }
  eat(): void { /* lunch break */ }
  takeBreak(): void { /* coffee break */ }
  sleep(): void { /* rest at night */ }
  attendMeeting(): void { /* join standup */ }
}

// Robot only implements what it can actually do
class RobotWorker implements Workable {
  work(): void { /* automated task */ }
  reportHours(): number { return 24; }
  // No eat(), sleep(), or attendMeeting() — clean!
}

// Functions only require what they need:
function assignTask(worker: Workable): void {
  worker.work();  // Works with both Human and Robot
}

function scheduleLunch(employee: Feedable): void {
  employee.eat();  // Only works with entities that can eat
}
```

```python
# ✅ REQUIRED: Python — ISP with Protocols (structural typing)

from typing import Protocol, runtime_checkable

@runtime_checkable
class Printable(Protocol):
    def to_string(self) -> str: ...

@runtime_checkable
class Serializable(Protocol):
    def to_json(self) -> dict: ...
    def from_json(cls, data: dict) -> 'Serializable': ...

@runtime_checkable
class Persistable(Protocol):
    async def save(self) -> None: ...
    async def delete(self) -> None: ...

# A simple DTO only needs Serializable
class UserDto:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email

    def to_json(self) -> dict:
        return {"name": self.name, "email": self.email}

    @classmethod
    def from_json(cls, data: dict) -> 'UserDto':
        return cls(name=data["name"], email=data["email"])

# A database entity needs Serializable + Persistable
class UserEntity:
    def to_json(self) -> dict: ...
    @classmethod
    def from_json(cls, data: dict) -> 'UserEntity': ...
    async def save(self) -> None: ...
    async def delete(self) -> None: ...

# Functions use only the interface they need
def serialize_response(obj: Serializable) -> str:
    return json.dumps(obj.to_json())  # Works with both UserDto and UserEntity

async def remove_record(record: Persistable) -> None:
    await record.delete()  # Only works with entities that support persistence
```

---

## 5. Dependency Inversion Principle (DIP)

> *"High-level modules should not depend on low-level modules. Both should depend on abstractions."*

### ✅ MUST do:
- Depend on **abstractions** (interfaces/abstract classes), not concrete implementations
- Use **dependency injection** (constructor injection, parameter injection)
- Define interfaces in the **layer that needs them**, not in the layer that implements them
- Use **factory pattern** or **IoC containers** to manage dependencies

### ❌ MUST NOT do:
- Import and instantiate dependencies directly inside a class (`new ConcreteService()`)
- Use global singletons directly without abstraction
- Create tight coupling between high-level and low-level modules

### 💡 Example: Order Processing Service

```typescript
// ❌ FORBIDDEN: High-level OrderService directly depends on low-level implementations
import { MySQLDatabase } from './databases/mysql';
import { StripePaymentGateway } from './payments/stripe';
import { SendGridEmailer } from './emails/sendgrid';
import { ConsoleLogger } from './loggers/console';

class OrderService {
  private db = new MySQLDatabase('mysql://localhost:3306/shop');         // ❌ Tightly coupled!
  private payment = new StripePaymentGateway('sk_live_xxx');            // ❌ Tightly coupled!
  private emailer = new SendGridEmailer('SG.xxx');                      // ❌ Tightly coupled!
  private logger = new ConsoleLogger();                                 // ❌ Tightly coupled!

  async placeOrder(orderData: CreateOrderDto): Promise<Order> {
    const order = await this.db.insert('orders', orderData);            // ❌ Can't swap DB!
    await this.payment.charge(order.total);                             // ❌ Can't swap payment!
    await this.emailer.send(order.customerEmail, 'Order confirmed');    // ❌ Can't swap emailer!
    this.logger.info(`Order ${order.id} placed`);                       // ❌ Can't swap logger!
    return order;
  }
}
```

```typescript
// ✅ REQUIRED: Depend on abstractions, inject dependencies

// --- interfaces/ (defined in the HIGH-LEVEL module) ---
interface OrderRepository {
  create(data: CreateOrderDto): Promise<Order>;
  findById(id: string): Promise<Order | null>;
  updateStatus(id: string, status: OrderStatus): Promise<void>;
}

interface PaymentGateway {
  charge(amount: number, currency: string, details: PaymentDetails): Promise<PaymentResult>;
  refund(transactionId: string): Promise<RefundResult>;
}

interface EmailSender {
  send(to: string, subject: string, body: string): Promise<void>;
}

interface Logger {
  info(message: string, meta?: Record<string, unknown>): void;
  error(message: string, meta?: Record<string, unknown>): void;
  warn(message: string, meta?: Record<string, unknown>): void;
}

// --- service (depends ONLY on abstractions) ---
class OrderService {
  constructor(
    private readonly orderRepo: OrderRepository,
    private readonly paymentGateway: PaymentGateway,
    private readonly emailSender: EmailSender,
    private readonly logger: Logger,
  ) {}

  async placeOrder(data: CreateOrderDto): Promise<Order> {
    const order = await this.orderRepo.create(data);
    const payment = await this.paymentGateway.charge(order.total, 'USD', data.paymentDetails);
    await this.orderRepo.updateStatus(order.id, 'confirmed');
    await this.emailSender.send(order.customerEmail, 'Order Confirmed', `Order #${order.id}`);
    this.logger.info('Order placed', { orderId: order.id, transactionId: payment.transactionId });
    return order;
  }
}

// --- implementations (LOW-LEVEL — can be swapped freely) ---
class PostgresOrderRepository implements OrderRepository {
  constructor(private readonly pool: Pool) {}
  async create(data: CreateOrderDto): Promise<Order> { /* PostgreSQL logic */ }
  async findById(id: string): Promise<Order | null> { /* ... */ }
  async updateStatus(id: string, status: OrderStatus): Promise<void> { /* ... */ }
}

class StripePaymentGateway implements PaymentGateway {
  constructor(private readonly apiKey: string) {}
  async charge(amount: number, currency: string, details: PaymentDetails): Promise<PaymentResult> { /* Stripe logic */ }
  async refund(transactionId: string): Promise<RefundResult> { /* ... */ }
}

class ResendEmailSender implements EmailSender {
  constructor(private readonly apiKey: string) {}
  async send(to: string, subject: string, body: string): Promise<void> { /* Resend logic */ }
}

class PinoLogger implements Logger {
  private readonly pino = pino();
  info(message: string, meta?: Record<string, unknown>): void { this.pino.info(meta, message); }
  error(message: string, meta?: Record<string, unknown>): void { this.pino.error(meta, message); }
  warn(message: string, meta?: Record<string, unknown>): void { this.pino.warn(meta, message); }
}

// --- composition root (wiring everything together) ---
const orderService = new OrderService(
  new PostgresOrderRepository(pool),
  new StripePaymentGateway(process.env.STRIPE_KEY!),
  new ResendEmailSender(process.env.RESEND_KEY!),
  new PinoLogger(),
);

// --- For testing — easily swap with mocks! ---
const testOrderService = new OrderService(
  new InMemoryOrderRepository(),
  new MockPaymentGateway(),
  new MockEmailSender(),
  new SilentLogger(),
);
```

```python
# ✅ REQUIRED: Python — DIP with dependency injection

from abc import ABC, abstractmethod

# --- abstractions (high-level defines what it needs) ---
class CacheStore(ABC):
    @abstractmethod
    async def get(self, key: str) -> str | None: ...

    @abstractmethod
    async def set(self, key: str, value: str, ttl_seconds: int = 3600) -> None: ...

    @abstractmethod
    async def delete(self, key: str) -> None: ...

class MessageBroker(ABC):
    @abstractmethod
    async def publish(self, topic: str, message: dict) -> None: ...

    @abstractmethod
    async def subscribe(self, topic: str, handler: Callable) -> None: ...

# --- high-level service (depends on abstractions) ---
class ProductService:
    def __init__(self, cache: CacheStore, broker: MessageBroker, repo: ProductRepository):
        self._cache = cache
        self._broker = broker
        self._repo = repo

    async def get_product(self, product_id: str) -> Product:
        # Try cache first
        cached = await self._cache.get(f"product:{product_id}")
        if cached:
            return Product.from_json(json.loads(cached))

        product = await self._repo.find_by_id(product_id)
        await self._cache.set(f"product:{product_id}", product.to_json())
        return product

    async def update_price(self, product_id: str, new_price: Decimal) -> Product:
        product = await self._repo.update_price(product_id, new_price)
        await self._cache.delete(f"product:{product_id}")
        await self._broker.publish("product.price_changed", {
            "product_id": product_id,
            "new_price": str(new_price),
        })
        return product

# --- low-level implementations (can be swapped) ---
class RedisCacheStore(CacheStore):
    def __init__(self, redis_client: Redis):
        self._redis = redis_client

    async def get(self, key: str) -> str | None:
        return await self._redis.get(key)

    async def set(self, key: str, value: str, ttl_seconds: int = 3600) -> None:
        await self._redis.setex(key, ttl_seconds, value)

    async def delete(self, key: str) -> None:
        await self._redis.delete(key)

class RabbitMQBroker(MessageBroker):
    async def publish(self, topic: str, message: dict) -> None: ...
    async def subscribe(self, topic: str, handler: Callable) -> None: ...

# --- wiring ---
product_service = ProductService(
    cache=RedisCacheStore(redis_client),
    broker=RabbitMQBroker(connection),
    repo=PostgresProductRepository(session),
)
```

---

## 📋 Checklist Before Completing a Task

Before declaring a task complete, the agent **MUST** verify:

- [ ] **SRP**: Does each class/function have only one responsibility?
- [ ] **OCP**: Does the design allow extension without modifying existing code?
- [ ] **LSP**: Can all subclasses replace their parent without issues?
- [ ] **ISP**: Are interfaces small and specific enough?
- [ ] **DIP**: Do dependencies rely on abstractions, not concrete implementations?

---

## ⚠️ Exceptions

SOLID principles may be **relaxed** in the following situations, but the agent must **explain the reasoning**:

1. **Prototypes / Proof of Concept** — If the user explicitly requests a quick prototype
2. **Simple scripts** — One-off utility scripts under 50 lines
3. **Configuration files** — Files that are declarative in nature
4. **Performance trade-offs** — If applying SOLID would significantly degrade performance

> In exception cases, the agent must add a comment `// TODO: Refactor to SOLID` on sections that need improvement.

---

## 📚 Language-Specific Reference

| Language | Abstraction | DI Pattern |
|----------|-------------|------------|
| **TypeScript** | `interface`, `abstract class` | Constructor injection, module DI |
| **Python** | `ABC`, `Protocol`, `typing` | Constructor injection, `@inject` decorator |
| **Go** | `interface` (implicit) | Constructor injection, functional options |
| **Java/Kotlin** | `interface`, `abstract class` | Spring DI, Dagger, Hilt |
