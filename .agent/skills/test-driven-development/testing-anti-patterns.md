# Testing Anti-Patterns Reference

Reference document for common testing anti-patterns. Read this before writing tests.

> **"Violating the letter of the rules is violating the spirit of the rules."**

---

## Anti-Pattern #1: Testing Mock Behavior Instead of Real Behavior

### Description
Writing tests that verify mock objects work as configured, rather than testing actual business logic.

### Example (Bad)
```javascript
const mockDb = { findUser: jest.fn().mockReturnValue({ id: 1, name: 'Alice' }) };
test('finds user', () => {
  const result = mockDb.findUser(1);
  expect(result).toEqual({ id: 1, name: 'Alice' }); // Testing the mock, not the service!
});
```

### Gate Function
Before writing a test with mocks, ask: **"If I replace the mock return value, would the test tell me my code is broken?"** If no, you're testing the mock.

---

## Anti-Pattern #2: Creating Test-Only Methods

### Description
Adding methods to production code solely for testing purposes (e.g., `_testGetPrivateState()`).

### Example (Bad)
```javascript
class UserService {
  _testGetInternalCache() { return this.cache; } // Exists only for tests!
}
```

### Gate Function
Before adding a method, ask: **"Would a production user ever call this method?"** If no, find another way to test (dependency injection, public interface, etc.).

---

## Anti-Pattern #3: Mocking Without Understanding

### Description
Adding mocks until the test passes without understanding what each mock does or why it's needed.

### Example (Bad)
```javascript
// "I don't know why this test fails, let me mock more things"
jest.mock('./database');
jest.mock('./cache');
jest.mock('./logger');
jest.mock('./config');
jest.mock('./utils'); // Mocking everything blindly
```

### Gate Function
Before adding a mock, ask: **"Can I explain in one sentence why this dependency needs to be mocked?"** If no, investigate the dependency first.

---

## Anti-Pattern #4: Incomplete Mocks That Hide Bugs

### Description
Mocking a dependency but not implementing all the behaviors that matter, causing tests to pass when they shouldn't.

### Example (Bad)
```javascript
const mockAuth = { isAuthenticated: () => true }; // Always returns true!
// Doesn't test: expired tokens, invalid tokens, missing tokens, revoked tokens
```

### Gate Function
Before finalizing a mock, ask: **"What are the 3 most common failure modes of this dependency?"** Ensure your mock covers at least those scenarios in separate tests.

---

## Anti-Pattern #5: Integration Tests as an Afterthought

### Description
Writing only unit tests with mocks, then adding integration tests "later" (which means never).

### Example (Bad)
```
✅ 50 unit tests passing (all with mocks)
❌ 0 integration tests
❌ 0 end-to-end tests
→ "Works on my machine" but fails in production
```

### Gate Function
Before marking a feature as "tested", ask: **"Do I have at least ONE test that exercises the real dependency chain?"** If no, write an integration test.

---

## Summary Gate Checklist

Before submitting tests, verify:

```
☐ Tests verify REAL behavior, not mock configuration
☐ No test-only methods in production code
☐ Every mock has a clear, stated purpose
☐ Mocks cover failure modes, not just happy path
☐ At least one integration test per feature exists
```
