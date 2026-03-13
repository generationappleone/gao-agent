# Defense in Depth

Supporting debugging technique: 4-layer validation to prevent bugs from reaching production.

---

## The Technique

Instead of relying on a single validation point, add validation at **4 layers** so bugs are caught even when one layer fails.

### The 4 Layers

```
Layer 1: INPUT VALIDATION    → Reject bad data at the boundary
Layer 2: BUSINESS LOGIC      → Assert invariants within the domain
Layer 3: DATA PERSISTENCE    → Database constraints enforce correctness
Layer 4: OUTPUT VALIDATION   → Verify response matches expectations
```

### Example: User Age Field

```
L1 INPUT:      Validate age is number, 0-150, required field
L2 BUSINESS:   Assert age >= minAge for the operation
L3 DATABASE:   CHECK constraint: age >= 0 AND age <= 150
L4 OUTPUT:     API response schema validates age is present and numeric
```

### When to Use

- Critical data paths (payments, authentication, user data)
- Data that flows through multiple services
- Fields that multiple consumers depend on
- Any place where "garbage in" causes "garbage out" in downstream systems

### Debugging Application

When debugging, check all 4 layers:

1. **Is input validation present and correct?** → Missing validation is the #1 bug source
2. **Do business rules assert their invariants?** → "Impossible" states happen when assertions are missing
3. **Do database constraints match business rules?** → Constraint mismatches cause data corruption
4. **Does output validation catch inconsistencies?** → Bad data in responses causes client-side bugs

### Anti-Pattern

❌ **Single-layer validation:** "We validate on the frontend, so the backend is fine."
→ Frontend validation can be bypassed. Every layer MUST validate independently.
