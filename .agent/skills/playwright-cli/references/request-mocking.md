# Request Mocking — Playwright CLI

## Route Commands

Intercept and mock network requests during CLI sessions:

```bash
# Mock all API responses
playwright route "https://api.example.com/**" --body '{"status": "ok"}' --status 200

# Mock specific endpoint
playwright route "https://api.example.com/users" --body-file ./fixtures/users.json

# Block resources (images, fonts, analytics)
playwright route "**/*.{png,jpg,gif}" --abort
playwright route "https://analytics.example.com/**" --abort
```

## URL Patterns

| Pattern | Matches |
|---------|---------|
| `**/api/**` | Any URL with `/api/` path segment |
| `https://api.example.com/**` | All paths under this domain |
| `**/*.{png,jpg}` | All PNG and JPG files |
| `**/api/users?page=*` | Users endpoint with any page param |

## Conditional Responses

```bash
# Return different responses based on method
playwright route "https://api.example.com/users" \
  --method GET --body '[]' --status 200

playwright route "https://api.example.com/users" \
  --method POST --body '{"id": 1}' --status 201
```

## Simulating Failures

```bash
# Network error
playwright route "https://api.example.com/critical" --abort

# Timeout simulation
playwright route "https://api.example.com/slow" --delay 30000

# Server error
playwright route "https://api.example.com/error" --status 500 \
  --body '{"error": "Internal Server Error"}'
```

## Use Cases

- **Offline testing:** Mock all external APIs
- **Error handling:** Simulate server failures
- **Performance:** Block heavy resources
- **Deterministic data:** Return fixed responses for screenshots
