---
name: Cypress
description: Skill for E2E and component testing with Cypress, covering page interactions, API testing, fixtures, custom commands, and CI/CD integration.
---

# Cypress Skill

## Overview
Cypress is a JavaScript E2E testing framework that runs in the browser alongside your application. It provides automatic waiting, time-travel debugging, network stubbing, screenshots, and video recording. Cypress is ideal for web application testing.

**References**:
- [Cypress Documentation](https://docs.cypress.io/)
- [Cypress API](https://docs.cypress.io/api/table-of-contents)

---

## Configuration

```typescript
// cypress.config.ts
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: true,
    screenshotOnRunFailure: true,
    retries: { runMode: 2, openMode: 0 },
  },
});
```

---

## E2E Tests

```typescript
describe('Products', () => {
  beforeEach(() => cy.visit('/products'));

  it('should display product list', () => {
    cy.get('[data-testid="product-card"]').should('have.length.greaterThan', 0);
    cy.get('[data-testid="product-card"]').first().should('contain', 'Product');
  });

  it('should search products', () => {
    cy.get('[data-testid="search-input"]').type('laptop');
    cy.get('[data-testid="search-button"]').click();
    cy.get('[data-testid="product-card"]').should('have.length', 5);
  });

  it('should add product to cart', () => {
    cy.get('[data-testid="add-to-cart"]').first().click();
    cy.get('[data-testid="cart-count"]').should('contain', '1');
    cy.get('[data-testid="toast"]').should('contain', 'Added to cart');
  });
});

describe('Authentication', () => {
  it('should login successfully', () => {
    cy.visit('/login');
    cy.get('#email').type('user@example.com');
    cy.get('#password').type('password123');
    cy.get('[data-testid="login-button"]').click();
    cy.url().should('include', '/dashboard');
    cy.get('[data-testid="welcome"]').should('be.visible');
  });
});
```

---

## API Testing

```typescript
describe('API', () => {
  it('should create a product', () => {
    cy.request({
      method: 'POST',
      url: '/api/products',
      headers: { Authorization: `Bearer ${Cypress.env('TOKEN')}` },
      body: { name: 'Test Product', price: 9999 },
    }).then((response) => {
      expect(response.status).to.eq(201);
      expect(response.body.name).to.eq('Test Product');
    });
  });
});
```

---

## Custom Commands

```typescript
// cypress/support/commands.ts
Cypress.Commands.add('login', (email = 'user@example.com', password = 'password123') => {
  cy.request('POST', '/api/auth/login', { email, password }).then((res) => {
    window.localStorage.setItem('token', res.body.accessToken);
  });
});

// Usage: cy.login();
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **data-testid** | Use data attributes for test selectors |
| **Custom commands** | Reusable login, setup actions |
| **Fixtures** | Mock data in cypress/fixtures/ |
| **Intercept** | cy.intercept() for network stubbing |
| **Auto-wait** | Cypress auto-waits for elements |
| **Assertions** | should('be.visible'), should('contain') |
| **Videos** | Record test runs for debugging |
| **Retries** | Configure retries for CI stability |
| **API testing** | cy.request() for backend testing |
| **Best selectors** | Prefer data-testid over CSS classes |

---

## Rules Integration
- **E2E**: Page interaction with auto-wait
- **API**: cy.request for backend testing
- **Commands**: Custom reusable commands
- **CI**: Video recording, retries, screenshots
