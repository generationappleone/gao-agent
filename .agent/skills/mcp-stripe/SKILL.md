---
name: MCP Server — Stripe
description: MCP Server for Stripe — enables AI assistants to manage payments, customers, subscriptions, invoices, products, and Stripe operations through a standardized MCP interface.
---

# MCP Server — Stripe

## Overview
Stripe MCP Server provides AI assistants with access to Stripe's payment infrastructure including customer management, payment processing, subscription handling, and financial reporting.

## Tools Provided

| Tool | Description |
|------|-------------|
| `list_customers` | List Stripe customers |
| `create_customer` | Create a new customer |
| `get_customer` | Get customer details with payment methods |
| `list_payments` | List payment intents |
| `create_payment_intent` | Create a payment intent |
| `list_subscriptions` | List subscriptions |
| `create_subscription` | Create a subscription |
| `cancel_subscription` | Cancel a subscription |
| `list_invoices` | List invoices |
| `create_invoice` | Create an invoice |
| `list_products` | List products and their prices |
| `create_product` | Create a product with pricing |
| `get_balance` | Get current Stripe balance |
| `list_charges` | List recent charges |
| `create_refund` | Issue a refund |
| `list_disputes` | List payment disputes |

## Configuration

```json
{
  "mcpServers": {
    "stripe": {
      "command": "npx",
      "args": ["-y", "@stripe/mcp-server-stripe"],
      "env": {
        "STRIPE_SECRET_KEY": "sk_..."
      }
    }
  }
}
```

## Security
- Use **test mode keys** (`sk_test_...`) during development
- Never expose live keys in configuration files
- Restrict API key permissions to required operations

## Use Cases
- AI-assisted payment troubleshooting
- Automated customer and subscription management
- Revenue reporting and analysis
- Product catalog management
- Refund processing and dispute handling
