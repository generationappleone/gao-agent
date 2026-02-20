---
name: Regex (Regular Expressions)
description: Skill for regular expressions — covering syntax, character classes, quantifiers, groups, lookahead/lookbehind, common patterns (email, URL, phone), and usage in JavaScript, Python, and PHP.
---

# Regex Skill

## Overview
Regular expressions (regex) are patterns for matching, searching, and replacing text. They are essential for input validation, text parsing, log analysis, and data extraction. This skill covers syntax and practical patterns across JavaScript, Python, and PHP.

**References**:
- [regex101.com](https://regex101.com/) (Interactive tester)
- [MDN RegExp](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_expressions)
- [Regular-Expressions.info](https://www.regular-expressions.info/)

---

## Syntax Reference

### Character Classes
```
.       Any character (except newline)
\d      Digit [0-9]
\D      Non-digit [^0-9]
\w      Word character [a-zA-Z0-9_]
\W      Non-word character
\s      Whitespace [ \t\n\r\f]
\S      Non-whitespace
\b      Word boundary
[abc]   Character set (a, b, or c)
[a-z]   Range (lowercase letters)
[^abc]  Negated set (not a, b, or c)
```

### Quantifiers
```
*       0 or more (greedy)
+       1 or more (greedy)
?       0 or 1 (optional)
{3}     Exactly 3
{2,5}   2 to 5
{3,}    3 or more
*?      0 or more (lazy/non-greedy)
+?      1 or more (lazy/non-greedy)
```

### Anchors & Groups
```
^       Start of string (or line with m flag)
$       End of string (or line with m flag)
(abc)   Capturing group
(?:abc) Non-capturing group
(?<name>abc)  Named group
\1      Back-reference to group 1
|       Alternation (OR)
```

### Lookahead & Lookbehind
```
(?=abc)   Positive lookahead (followed by abc)
(?!abc)   Negative lookahead (NOT followed by abc)
(?<=abc)  Positive lookbehind (preceded by abc)
(?<!abc)  Negative lookbehind (NOT preceded by abc)
```

### Flags
```
g   Global (find all matches)
i   Case-insensitive
m   Multiline (^ and $ match line boundaries)
s   Dotall (. matches newline)
u   Unicode
```

---

## Common Validation Patterns

```typescript
// ── Email ──
const EMAIL = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

// ── Password (min 8 chars, 1 upper, 1 lower, 1 digit, 1 special) ──
const PASSWORD = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=]).{8,}$/;

// ── Phone (international) ──
const PHONE = /^\+?[1-9]\d{1,14}$/;                    // E.164 format
const PHONE_ID = /^(?:\+62|62|0)8[1-9][0-9]{6,10}$/;  // Indonesian

// ── URL ──
const URL_PATTERN = /^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_+.~#?&/=]*)$/;

// ── UUID v4 ──
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

// ── Slug ──
const SLUG = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

// ── IP Address (IPv4) ──
const IPV4 = /^(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?)$/;

// ── Date (YYYY-MM-DD) ──
const DATE_ISO = /^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$/;

// ── Credit Card (basic) ──
const CREDIT_CARD = /^\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}$/;

// ── Hex Color ──
const HEX_COLOR = /^#(?:[0-9a-fA-F]{3}){1,2}$/;

// ── Indonesian NIK (16 digits) ──
const NIK = /^\d{16}$/;
```

---

## JavaScript Usage

```typescript
// ── Test (boolean) ──
EMAIL.test('john@example.com');     // true

// ── Match (get matches) ──
const text = 'Contact: john@example.com or jane@test.com';
const matches = text.match(/\b[\w.+-]+@[\w.-]+\.\w{2,}\b/g);
// ['john@example.com', 'jane@test.com']

// ── Named groups ──
const dateStr = '2024-01-15';
const { groups } = dateStr.match(/^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})$/)!;
// groups = { year: '2024', month: '01', day: '15' }

// ── Replace ──
'Hello World'.replace(/world/i, 'Regex');                 // 'Hello Regex'
'2024-01-15'.replace(/(\d{4})-(\d{2})-(\d{2})/, '$3/$2/$1'); // '15/01/2024'

// ── Replace with function ──
'hello_world_foo'.replace(/_([a-z])/g, (_, c) => c.toUpperCase());
// 'helloWorldFoo'

// ── Split ──
'one, two , three'.split(/\s*,\s*/);  // ['one', 'two', 'three']

// ── matchAll (iterate) ──
const log = '[ERROR] 10:30 timeout\n[WARN] 10:31 retry\n[ERROR] 10:32 failed';
for (const match of log.matchAll(/\[(?<level>\w+)\]\s+(?<time>\S+)\s+(?<msg>.+)/g)) {
  console.log(match.groups);
  // { level: 'ERROR', time: '10:30', msg: 'timeout' }
}
```

---

## Text Processing Patterns

```typescript
// ── Slugify ──
function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')  // Remove accents
    .replace(/[^a-z0-9\s-]/g, '')                      // Remove special chars
    .replace(/[\s_]+/g, '-')                            // Spaces/underscores to hyphens
    .replace(/-+/g, '-')                                // Collapse multiple hyphens
    .replace(/^-|-$/g, '');                             // Trim hyphens
}
// slugify('Hello World!') → 'hello-world'
// slugify('Café Résumé') → 'cafe-resume'

// ── Extract numbers ──
'Price: $1,234.56'.match(/[\d,]+\.?\d*/g);   // ['1,234.56']

// ── Mask sensitive data ──
function maskEmail(email: string): string {
  return email.replace(/^(.{2})(.*)(@.*)$/, (_, start, middle, domain) =>
    start + '*'.repeat(middle.length) + domain
  );
}
// maskEmail('john@example.com') → 'jo**@example.com'

// ── Parse log entries ──
const logPattern = /^(?<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})\s+\[(?<level>\w+)\]\s+(?<message>.+)$/gm;

// ── Sanitize HTML tags ──
'<script>alert("xss")</script><p>Hello</p>'.replace(/<[^>]*>/g, '');
// 'alert("xss")Hello'

// ── camelCase to kebab-case ──
'camelCaseString'.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
// 'camel-case-string'

// ── Extract query parameters ──
const url = 'https://example.com?page=1&search=hello&sort=name';
const params = Object.fromEntries([...url.matchAll(/[?&](\w+)=([^&]*)/g)].map(m => [m[1], m[2]]));
// { page: '1', search: 'hello', sort: 'name' }
```

---

## Security Considerations

```typescript
// ❌ DANGEROUS: ReDoS (Regular Expression Denial of Service)
/^(a+)+$/;          // Catastrophic backtracking
/(a|a)*$/;          // Exponential complexity
/(\w+\s?)+$/;       // Evil regex with nested quantifiers

// ✅ SAFE: Bounded quantifiers, no nested repetition
/^[a-z]{1,100}$/;   // Bounded length
/^\w+$/;            // Simple quantifier
/^.{1,1000}$/s;     // Max length check

// ✅ Always validate input length BEFORE regex
function validateInput(input: string): boolean {
  if (input.length > 1000) return false;     // Length check first
  return /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(input);
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Test with regex101** | Always test patterns interactively at regex101.com |
| **Named groups** | `(?<name>...)` for readable extraction |
| **Non-greedy** | Use `*?` and `+?` when possible to avoid overmatching |
| **Anchors** | Always use `^` and `$` for full-string validation |
| **Character classes** | `[a-z]` is clear; `.` matches too broadly |
| **ReDoS prevention** | Avoid nested quantifiers `(a+)+`, bound lengths |
| **Length check first** | Validate string length before applying regex |
| **Escape user input** | Use libraries for escaping user input in regex patterns |
| **Readability** | Use `x` flag (verbose mode) or comments for complex patterns |

---

## Rules Integration
- **Validation**: Email, password, phone, URL, UUID patterns with anchors
- **Extraction**: Named groups for structured data, matchAll for iteration
- **Transformation**: Replace for formatting, slugify, camelCase conversion
- **Security**: Avoid ReDoS, bound quantifiers, length check before regex
- **Testing**: regex101.com for interactive development and debugging
