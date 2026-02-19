---
name: Unit Testing Patterns
description: Skill for writing effective unit tests — covering AAA pattern, mocking, fixtures, test doubles, code coverage, TDD, property-based testing, and frameworks (Jest, Vitest, PHPUnit, pytest).
---

# Unit Testing Patterns Skill

## Overview
Unit testing validates individual units of code in isolation. This skill covers testing patterns, strategies, and best practices across frameworks.

## AAA Pattern (Arrange-Act-Assert)
```typescript
// Jest / Vitest
describe("UserService", () => {
  describe("createUser", () => {
    it("should create a user with hashed password", async () => {
      // Arrange
      const input = { name: "John", email: "john@example.com", password: "secret123" };
      const mockRepo = { save: vi.fn().mockResolvedValue({ id: "1", ...input }) };
      const service = new UserService(mockRepo);

      // Act
      const user = await service.createUser(input);

      // Assert
      expect(user.id).toBeDefined();
      expect(user.name).toBe("John");
      expect(mockRepo.save).toHaveBeenCalledTimes(1);
      expect(mockRepo.save).toHaveBeenCalledWith(expect.objectContaining({ name: "John", email: "john@example.com" }));
    });

    it("should throw if email already exists", async () => {
      const mockRepo = { findByEmail: vi.fn().mockResolvedValue({ id: "1" }) };
      const service = new UserService(mockRepo);
      await expect(service.createUser({ email: "exists@example.com" })).rejects.toThrow("Email already exists");
    });
  });
});
```

## Test Doubles
```typescript
// Stub — returns predefined data
const userRepo = { findById: vi.fn().mockResolvedValue({ id: "1", name: "John" }) };

// Mock — verifies interactions
const emailService = { send: vi.fn() };
// ... after action:
expect(emailService.send).toHaveBeenCalledWith("john@example.com", expect.stringContaining("Welcome"));

// Spy — wraps real implementation
const spy = vi.spyOn(console, "log");
// ... after action:
expect(spy).toHaveBeenCalled();
spy.mockRestore();

// Fake — simplified working implementation
class FakeUserRepository {
  private users = new Map<string, User>();
  async findById(id: string) { return this.users.get(id) ?? null; }
  async save(user: User) { this.users.set(user.id, user); return user; }
}
```

## Test Naming Convention
```typescript
// Format: should [expected behavior] when [condition]
it("should return null when user is not found");
it("should throw ValidationError when email is invalid");
it("should send welcome email when user is created");
it("should calculate 10% discount when order total exceeds $100");
```

## Coverage Targets
| Type | Target | Description |
|------|--------|-------------|
| **Line** | ≥ 80% | Lines executed |
| **Branch** | ≥ 75% | If/else paths covered |
| **Function** | ≥ 85% | Functions called |
| **Statement** | ≥ 80% | Statements executed |

## Best Practices

| Practice | Description |
|----------|-------------|
| **AAA pattern** | Arrange → Act → Assert, clearly separated |
| **One assert per concept** | Test one behavior per test |
| **Descriptive names** | `should...when...` naming convention |
| **No test interdependence** | Tests must run independently |
| **Test behavior** | Test what, not how (avoid implementation coupling) |
| **Avoid logic in tests** | No if/else/loops in test code |
| **Use factories** | Test data builders for complex objects |
| **Mock boundaries** | Mock external dependencies, not internal logic |
| **Fast execution** | Unit tests should run in milliseconds |
| **TDD** | Red → Green → Refactor cycle |
