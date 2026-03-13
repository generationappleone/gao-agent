# Storage State — Playwright CLI

## Overview

Storage state captures cookies, localStorage, and sessionStorage for reuse across sessions. Essential for maintaining authentication state.

## Save Storage State

```bash
# After logging in, save state
playwright save-storage-state --path auth.json
```

### auth.json Structure

```json
{
  "cookies": [
    {
      "name": "session_token",
      "value": "abc123...",
      "domain": ".example.com",
      "path": "/",
      "expires": 1710000000,
      "httpOnly": true,
      "secure": true,
      "sameSite": "Lax"
    }
  ],
  "origins": [
    {
      "origin": "https://example.com",
      "localStorage": [
        {
          "name": "user_preferences",
          "value": "{\"theme\":\"dark\"}"
        }
      ]
    }
  ]
}
```

## Load Storage State

```bash
# Start session with saved auth
playwright open --storage-state auth.json https://dashboard.example.com

# Verify logged in
playwright snapshot
# Should see dashboard, not login page
```

## Auth State Reuse Pattern

```bash
# Step 1: Login once
playwright open https://app.example.com/login
playwright snapshot
playwright fill e1 "admin@example.com"
playwright fill e2 "password"
playwright click e3  # Login button
playwright wait-for-selector ".dashboard"
playwright save-storage-state --path ./fixtures/admin-auth.json

# Step 2: Reuse in all subsequent sessions
playwright open --storage-state ./fixtures/admin-auth.json https://app.example.com/settings
playwright open --storage-state ./fixtures/admin-auth.json https://app.example.com/users
```

## Multiple Auth States

```bash
# Save different role states
playwright save-storage-state --path ./fixtures/admin-auth.json    # After admin login
playwright save-storage-state --path ./fixtures/user-auth.json     # After user login
playwright save-storage-state --path ./fixtures/viewer-auth.json   # After viewer login

# Use appropriate state per test
playwright open --storage-state ./fixtures/admin-auth.json https://app.example.com/admin
playwright open --storage-state ./fixtures/user-auth.json https://app.example.com/profile
```

## Cookies Management

```bash
# View current cookies
playwright evaluate "document.cookie"

# Set cookie via JS
playwright evaluate "document.cookie = 'debug=true; path=/'"

# Clear all cookies
playwright clear-cookies
```

## localStorage Management

```bash
# Get value
playwright evaluate "localStorage.getItem('user_preferences')"

# Set value
playwright evaluate "localStorage.setItem('feature_flag', 'true')"

# Clear
playwright evaluate "localStorage.clear()"
```

## sessionStorage Management

```bash
# Get value
playwright evaluate "sessionStorage.getItem('cart')"

# Set value
playwright evaluate "sessionStorage.setItem('cart', JSON.stringify([{id: 1}]))"
```

## IndexedDB

```bash
# List databases
playwright evaluate "indexedDB.databases().then(dbs => JSON.stringify(dbs))"
```

## Security Notes

> **⚠️ Never commit auth.json to version control.** It contains session tokens.

Add to `.gitignore`:
```
*-auth.json
fixtures/*-auth.json
```
