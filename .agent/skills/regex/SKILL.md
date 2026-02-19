---
name: Regex (Regular Expressions)
description: Skill for regular expressions — covering syntax, character classes, quantifiers, groups, lookahead/lookbehind, common patterns (email, URL, phone), and usage in JavaScript, Python, and PHP.
---

# Regex (Regular Expressions) Skill

## Overview
Regular expressions are patterns for matching text. This skill covers regex syntax, common patterns, and language-specific implementations.

## Core Syntax

| Symbol | Description | Example |
|--------|-------------|---------|
| `.` | Any character (except newline) | `a.c` → "abc", "a1c" |
| `^` | Start of string | `^Hello` |
| `$` | End of string | `world$` |
| `\d` | Digit [0-9] | `\d{3}` → "123" |
| `\w` | Word char [a-zA-Z0-9_] | `\w+` → "hello_123" |
| `\s` | Whitespace | `\s+` → " " |
| `\b` | Word boundary | `\bword\b` |
| `*` | 0 or more | `ab*c` → "ac", "abc", "abbc" |
| `+` | 1 or more | `ab+c` → "abc", "abbc" |
| `?` | 0 or 1 (optional) | `colou?r` → "color", "colour" |
| `{n}` | Exactly n | `\d{4}` → "2024" |
| `{n,m}` | Between n and m | `\d{2,4}` → "12", "1234" |
| `[abc]` | Character class | `[aeiou]` → vowels |
| `[^abc]` | Negated class | `[^0-9]` → non-digit |
| `(...)` | Capture group | `(\d{3})-(\d{4})` |
| `(?:...)` | Non-capture group | `(?:https?)://` |
| `\|` | Alternation (OR) | `cat\|dog` |
| `(?=...)` | Positive lookahead | `\d+(?=px)` → "12" in "12px" |
| `(?<=...)` | Positive lookbehind | `(?<=\$)\d+` → "50" in "$50" |

## Common Patterns
```javascript
// Email (simplified, RFC-compliant is much more complex)
/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

// URL
/^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&/=]*)$/

// Phone (international)
/^\+?[1-9]\d{1,14}$/

// Phone (Indonesia)
/^(\+62|62|0)8[1-9][0-9]{6,10}$/

// IPv4
/^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$/

// Date (YYYY-MM-DD)
/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/

// Time (HH:MM:SS)
/^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/

// Strong password (min 8, upper, lower, digit, special)
/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/

// Hex color
/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

// Slug
/^[a-z0-9]+(?:-[a-z0-9]+)*$/

// UUID v4
/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

// HTML tag
/<\/?[\w\s="'-]*\/?>/g

// Credit card (Visa/MC/Amex)
/^(?:4\d{12}(?:\d{3})?|5[1-5]\d{14}|3[47]\d{13})$/
```

## JavaScript Usage
```javascript
const regex = /(\d{4})-(\d{2})-(\d{2})/;
const match = "2024-01-15".match(regex);
// match[0] = "2024-01-15", match[1] = "2024", match[2] = "01", match[3] = "15"

// Named groups
const dateRegex = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/;
const { groups } = "2024-01-15".match(dateRegex);
// groups.year = "2024", groups.month = "01", groups.day = "15"

// Replace
"Hello World".replace(/world/i, "Regex");               // "Hello Regex"
"2024-01-15".replace(/(\d{4})-(\d{2})-(\d{2})/, "$3/$2/$1"); // "15/01/2024"

// Test
/^\d+$/.test("12345");    // true
/^\d+$/.test("123abc");   // false

// matchAll (global)
const matches = [...text.matchAll(/\b\w{5,}\b/g)];
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Named groups** | Use `(?<name>...)` for readability |
| **Non-greedy** | Use `*?` and `+?` to match minimum |
| **Test thoroughly** | Edge cases: empty, special chars, unicode |
| **Comment complex regex** | Use `x` flag or break into parts |
| **Don't parse HTML** | Use DOM parser instead of regex |
| **Validate, don't parse** | Regex for validation, proper parser for parsing |
| **Character classes** | `\d` over `[0-9]`, `\w` over `[a-zA-Z0-9_]` |
| **Anchors** | Always use `^` and `$` for full-string validation |
