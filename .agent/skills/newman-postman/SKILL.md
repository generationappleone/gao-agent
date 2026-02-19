---
name: Newman & Postman
description: Skill for API testing with Postman collections and Newman CLI runner, covering collection creation, environment variables, test scripts, assertions, and CI/CD integration.
---

# Newman & Postman Skill

## Overview
Postman is an API development/testing platform. Newman is its CLI companion that runs Postman collections in CI/CD pipelines without the GUI.

## Installation
```bash
npm install -D newman
npm install -D newman-reporter-htmlextra   # rich HTML reports
```

## Collection Structure (JSON)
```json
{
  "info": {
    "name": "API Test Suite",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "url": "{{baseUrl}}/api/auth/login",
            "header": [{ "key": "Content-Type", "value": "application/json" }],
            "body": {
              "mode": "raw",
              "raw": "{\"email\": \"{{email}}\", \"password\": \"{{password}}\"}"
            }
          },
          "event": [{
            "listen": "test",
            "script": {
              "exec": [
                "pm.test('Status is 200', () => pm.response.to.have.status(200));",
                "pm.test('Has token', () => {",
                "  const json = pm.response.json();",
                "  pm.expect(json.token).to.be.a('string');",
                "  pm.environment.set('authToken', json.token);",
                "});"
              ]
            }
          }]
        }
      ]
    },
    {
      "name": "Users",
      "item": [
        {
          "name": "Get Users",
          "request": {
            "method": "GET",
            "url": "{{baseUrl}}/api/users",
            "header": [{ "key": "Authorization", "value": "Bearer {{authToken}}" }]
          },
          "event": [{
            "listen": "test",
            "script": {
              "exec": [
                "pm.test('Status is 200', () => pm.response.to.have.status(200));",
                "pm.test('Returns array', () => {",
                "  pm.expect(pm.response.json().data).to.be.an('array');",
                "});",
                "pm.test('Response time < 500ms', () => {",
                "  pm.expect(pm.response.responseTime).to.be.below(500);",
                "});"
              ]
            }
          }]
        }
      ]
    }
  ]
}
```

## Environment File
```json
{
  "name": "Development",
  "values": [
    { "key": "baseUrl", "value": "http://localhost:3000" },
    { "key": "email", "value": "admin@test.com" },
    { "key": "password", "value": "password" },
    { "key": "authToken", "value": "" }
  ]
}
```

## Newman CLI
```bash
# Basic run
npx newman run collection.json -e environment.json

# With HTML report
npx newman run collection.json -e environment.json \
  -r htmlextra --reporter-htmlextra-export ./report.html

# With multiple reporters
npx newman run collection.json -e environment.json \
  -r cli,json,htmlextra \
  --reporter-json-export results.json

# Specific folder only
npx newman run collection.json --folder "Auth" -e environment.json

# With iterations and data
npx newman run collection.json -d test-data.csv -n 5

# Bail on first failure
npx newman run collection.json --bail
```

## Common Test Scripts (Postman syntax)
```javascript
// Status checks
pm.test('Status 200', () => pm.response.to.have.status(200));
pm.test('Status 2xx', () => pm.response.to.be.success);

// Body checks
pm.test('Has required fields', () => {
  const json = pm.response.json();
  pm.expect(json).to.have.property('id');
  pm.expect(json).to.have.property('email');
  pm.expect(json.email).to.be.a('string');
});

// Schema validation
const schema = { type: 'object', required: ['id', 'name'], properties: { id: { type: 'string' } } };
pm.test('Schema valid', () => pm.response.to.have.jsonSchema(schema));

// Response time
pm.test('Fast response', () => pm.expect(pm.response.responseTime).to.be.below(500));

// Header checks
pm.test('Has security headers', () => {
  pm.response.to.have.header('X-Content-Type-Options');
  pm.response.to.have.header('X-Frame-Options');
});
```

## Best Practices
- Organize collections by feature/module folders
- Use environment variables for URLs, tokens, IDs
- Chain requests — capture tokens in login, reuse in subsequent requests
- Add `pm.test` assertions to EVERY request
- Check response time in critical endpoints
- Use pre-request scripts for dynamic data generation
- Export collections to version control alongside code
