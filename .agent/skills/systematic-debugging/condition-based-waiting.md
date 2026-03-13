# Condition-Based Waiting

Supporting debugging technique: Replace arbitrary timeouts with condition-based waiting.

---

## The Technique

Never use `sleep(N)` or arbitrary timeouts. Instead, wait for a **specific condition** to become true. Arbitrary waits are the #1 source of flaky tests and intermittent production issues.

### The Pattern

```
❌ BAD:  sleep(3000); // Hope 3 seconds is enough
✅ GOOD: waitFor(() => element.isVisible(), { timeout: 10000 });
```

### Types of Condition-Based Waiting

#### 1. Polling Wait (Check repeatedly)
```javascript
async function waitFor(condition, { timeout = 5000, interval = 100 } = {}) {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await condition()) return;
    await new Promise(r => setTimeout(r, interval));
  }
  throw new Error(`Condition not met within ${timeout}ms`);
}
```

#### 2. Event-Based Wait (React to events)
```javascript
await new Promise((resolve) => {
  emitter.once('data-loaded', resolve);
  setTimeout(() => reject(new Error('Timeout')), 5000);
});
```

#### 3. State-Based Wait (Watch state changes)
```javascript
await page.waitForSelector('[data-testid="results-loaded"]');
await page.waitForFunction(() => document.querySelectorAll('.item').length > 0);
```

### When to Use

- **Tests that fail intermittently** → Replace sleep with waitFor
- **API calls that need "time to complete"** → Poll for completion status
- **UI interactions** → Wait for element state, not arbitrary time
- **Database operations** → Wait for transaction commit, not sleep
- **Message queues** → Wait for message delivery confirmation

### Debugging Application

When you see a flaky test or intermittent failure:

1. **Search for arbitrary waits:** `grep -rn "sleep\|setTimeout\|delay\|wait(" test/`
2. **For each arbitrary wait, ask:** "What condition am I actually waiting for?"
3. **Replace with condition:** Use polling, event, or state-based waiting
4. **Add meaningful timeout:** Include error message explaining what was expected

### Anti-Pattern Table

| ❌ Anti-Pattern | ✅ Correct Pattern |
|----------------|-------------------|
| `sleep(2000)` | `waitFor(() => isReady())` |
| `setTimeout(check, 5000)` | `poll({ condition: check, interval: 200 })` |
| `await delay(1000)` | `await page.waitForSelector('.loaded')` |
| "Increase timeout to 10s" | "Wait for the correct condition" |

### See Also

- `condition-based-waiting-example.ts` — Full TypeScript implementation
