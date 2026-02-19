---
name: Cypress
description: Skill for E2E and component testing with Cypress, covering page interactions, API testing, fixtures, custom commands, and CI/CD integration.
---

# Cypress Skill

## Overview
Cypress is a JavaScript E2E testing framework with real-time reloading, time-travel debugging, automatic waiting, and built-in screenshot/video capture.

## Installation
```bash
npm install -D cypress
npx cypress open    # interactive mode (first run initializes config)
```

## Configuration — `cypress.config.ts`
```typescript
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    specPattern: 'cypress/e2e/**/*.cy.{ts,js}',
    supportFile: 'cypress/support/e2e.ts',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: true,
    screenshotOnRunFailure: true,
    retries: { runMode: 2, openMode: 0 },
    defaultCommandTimeout: 10000,
    env: {
      apiUrl: 'http://localhost:3000/api',
    },
  },
  component: {
    devServer: {
      framework: 'react',
      bundler: 'vite',
    },
    specPattern: 'src/**/*.cy.{ts,tsx}',
  },
});
```

## Core Patterns

### Basic E2E Test
```typescript
describe('Login Page', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('should login successfully', () => {
    cy.get('[data-testid="email"]').type('user@example.com');
    cy.get('[data-testid="password"]').type('SecurePass123!');
    cy.get('[data-testid="login-btn"]').click();
    cy.url().should('include', '/dashboard');
    cy.get('[data-testid="welcome"]').should('be.visible');
  });

  it('should show error for invalid credentials', () => {
    cy.get('[data-testid="email"]').type('wrong@example.com');
    cy.get('[data-testid="password"]').type('wrong');
    cy.get('[data-testid="login-btn"]').click();
    cy.get('.error-message').should('contain', 'Invalid credentials');
  });
});
```

### API Testing
```typescript
describe('API Tests', () => {
  let token: string;

  before(() => {
    cy.request('POST', '/api/auth/login', {
      email: 'admin@test.com',
      password: 'password',
    }).then((res) => {
      token = res.body.token;
    });
  });

  it('GET /api/users returns list', () => {
    cy.request({
      method: 'GET',
      url: '/api/users',
      headers: { Authorization: `Bearer ${token}` },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.data).to.be.an('array');
    });
  });
});
```

### Custom Commands — `cypress/support/commands.ts`
```typescript
Cypress.Commands.add('login', (email: string, password: string) => {
  cy.session([email, password], () => {
    cy.request('POST', '/api/auth/login', { email, password }).then((res) => {
      window.localStorage.setItem('token', res.body.token);
    });
  });
});

// Usage: cy.login('admin@test.com', 'password');
```

### Fixtures & Intercepts
```typescript
it('displays user data from API', () => {
  cy.intercept('GET', '/api/users', { fixture: 'users.json' }).as('getUsers');
  cy.visit('/users');
  cy.wait('@getUsers');
  cy.get('[data-testid="user-row"]').should('have.length', 3);
});
```

### Network Stubbing
```typescript
it('handles server error gracefully', () => {
  cy.intercept('GET', '/api/data', { statusCode: 500 }).as('serverError');
  cy.visit('/dashboard');
  cy.wait('@serverError');
  cy.get('.error-fallback').should('be.visible');
});
```

## CLI Commands
```bash
npx cypress open                       # interactive mode
npx cypress run                        # headless mode
npx cypress run --spec "cypress/e2e/login.cy.ts"  # specific test
npx cypress run --browser chrome       # specific browser
npx cypress run --reporter json        # JSON output
npx cypress run --record --key <KEY>   # record to Cypress Cloud
```

## Best Practices
- Use `data-testid` or `data-cy` for selectors (never CSS classes)
- Use `cy.session()` for login state management
- Use `cy.intercept()` for API mocking, not `cy.server()/cy.route()` (deprecated)
- Keep tests independent — clean state in `beforeEach`
- Use fixtures for test data, not hardcoded values
- Avoid `cy.wait(ms)` — use `cy.wait('@alias')` instead
- Use TypeScript for type safety
