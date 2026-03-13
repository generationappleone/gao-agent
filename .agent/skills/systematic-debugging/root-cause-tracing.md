# Root Cause Tracing

Supporting debugging technique: 5-level backward tracing to find the true root cause.

---

## The Technique

When a symptom appears, trace backward through **5 levels** to find the actual root cause. Most developers stop at level 1 or 2 — the fix works but the problem recurs.

### The 5 Levels

```
Level 1: SYMPTOM     → What you see (error message, wrong output)
Level 2: MECHANISM   → What code produced the symptom (the function/line)
Level 3: TRIGGER     → What caused the mechanism to execute (the input/state)
Level 4: ORIGIN      → Where the bad input/state came from (upstream)
Level 5: ROOT CAUSE  → Why the system allowed this to happen (design flaw)
```

### Example: "API returns 500 error"

```
L1 SYMPTOM:    API returns 500 Internal Server Error
L2 MECHANISM:  `UserController.getUser()` throws NullPointerException on line 42
L3 TRIGGER:    `user.address` is null because user has no address record
L4 ORIGIN:     Registration form doesn't require address, but getUser() assumes it exists
L5 ROOT CAUSE: No validation contract between registration and user retrieval

FIX at L5:     Add nullable handling for optional fields across the entire user model
FIX at L2:     Would only add a null check (symptom fix — problem recurs for other nullable fields)
```

### When to Use

- Bug appears "randomly" or intermittently
- Fix keeps coming back in different forms
- Multiple symptoms seem related
- Junior developer's fix "works" but you're not convinced

### Application

1. Write down the symptom (what the user sees)
2. Find the mechanism (what code produced it)
3. Find the trigger (what input/state caused the mechanism)
4. Trace the origin (where did the bad state come from?)
5. Identify the root cause (why was this state possible?)
6. **Fix at the highest level possible** (L4 or L5)
