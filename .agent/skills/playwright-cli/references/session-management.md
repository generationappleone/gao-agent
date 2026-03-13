# Session Management — Playwright CLI

## Named Sessions

```bash
# Start named session
playwright open --session checkout-flow https://shop.example.com

# Resume session later
playwright --session checkout-flow snapshot
playwright --session checkout-flow click e3

# List active sessions
playwright sessions

# Close session
playwright --session checkout-flow close
```

## Session Isolation

Each named session has its own:
- Browser context (cookies, localStorage)
- Navigation history
- Open tabs
- Network interceptions

## Concurrent Sessions

```bash
# Session 1: Admin view
playwright open --session admin https://app.example.com/admin

# Session 2: User view (separate browser context)
playwright open --session user https://app.example.com/dashboard

# Compare views
playwright --session admin screenshot --path admin-view.png
playwright --session user screenshot --path user-view.png
```

## Use Cases

### A/B Testing

```bash
# Variant A
playwright open --session variant-a https://example.com?variant=a
playwright --session variant-a screenshot --path variant-a.png

# Variant B
playwright open --session variant-b https://example.com?variant=b
playwright --session variant-b screenshot --path variant-b.png
```

### Multi-Role Testing

```bash
# Login as admin
playwright open --session admin https://app.example.com/login
playwright --session admin fill e1 "admin@example.com"
playwright --session admin fill e2 "adminpass"
playwright --session admin click e3

# Login as user
playwright open --session user https://app.example.com/login
playwright --session user fill e1 "user@example.com" 
playwright --session user fill e2 "userpass"
playwright --session user click e3

# Verify admin sees admin panel
playwright --session admin navigate https://app.example.com/admin
playwright --session admin snapshot
# Should see admin controls

# Verify user doesn't
playwright --session user navigate https://app.example.com/admin
playwright --session user snapshot
# Should see 403 or redirect
```

### Persistent Profiles

```bash
# Use persistent browser profile (survives restart)
playwright open --user-data-dir ./profiles/admin https://example.com

# All cookies, localStorage, IndexedDB persist across sessions
```

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `PLAYWRIGHT_DEFAULT_SESSION` | Default session name |
| `PLAYWRIGHT_SESSION_TIMEOUT` | Auto-close idle sessions (ms) |
