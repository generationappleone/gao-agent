---
name: Invoicing System
description: Skill for building invoicing systems — covering invoice generation, payment tracking, recurring billing, multi-currency support, tax calculation, payment reminders, aging reports, and accounting integration.
---

# Invoicing Skill

## Overview
Invoicing systems generate, track, and manage invoices for B2B and B2C transactions. Features include invoice creation, PDF generation, payment tracking, recurring billing, late payment reminders, multi-currency, tax calculation, and aging reports.

**References**:
- [Invoice Standards](https://www.invoicing.co/)
- [PDF Generation](https://pdfkit.org/)

---

## Invoice Model

```typescript
interface Invoice {
  id: string;
  invoiceNumber: string;    // INV-2024-0001
  customerId: string;
  status: 'draft' | 'sent' | 'paid' | 'overdue' | 'cancelled';
  issueDate: Date;
  dueDate: Date;
  currency: string;
  subtotal: number;         // in cents
  taxRate: number;           // e.g., 11 for 11%
  taxAmount: number;
  discount: number;
  total: number;
  paidAmount: number;
  notes?: string;
  items: InvoiceItem[];
}

interface InvoiceItem {
  description: string;
  quantity: number;
  unitPrice: number;
  total: number;
}
```

---

## Invoice Generation

```typescript
export function generateInvoiceNumber(): string {
  const year = new Date().getFullYear();
  const sequence = await db.invoice.count({ where: { invoiceNumber: { startsWith: `INV-${year}` } } }) + 1;
  return `INV-${year}-${String(sequence).padStart(4, '0')}`;
}

export async function createInvoice(data: CreateInvoiceInput) {
  const subtotal = data.items.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);
  const taxAmount = Math.round(subtotal * (data.taxRate / 100));
  const total = subtotal + taxAmount - (data.discount || 0);

  return db.invoice.create({
    data: {
      invoiceNumber: await generateInvoiceNumber(),
      customerId: data.customerId,
      issueDate: new Date(),
      dueDate: addDays(new Date(), data.paymentTerms || 30),
      currency: data.currency || 'USD',
      subtotal, taxRate: data.taxRate, taxAmount, discount: data.discount || 0, total, paidAmount: 0,
      status: 'draft',
      items: { create: data.items.map(item => ({ ...item, total: item.unitPrice * item.quantity })) },
    },
  });
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Invoice number** | Sequential, immutable numbering |
| **Amounts** | Store in cents (integer) |
| **Tax** | Configurable tax rates per region |
| **PDF** | Generate downloadable invoice PDF |
| **Status** | Draft → Sent → Paid/Overdue → Cancelled |
| **Reminders** | Automated overdue reminders |
| **Multi-currency** | Support multiple currencies |
| **Aging reports** | 30/60/90 day accounts receivable |
| **Recurring** | Auto-generate for subscriptions |
| **Audit trail** | Track all status changes |

---

## Rules Integration
- **Generation**: Sequential numbering, item totals
- **Tax**: Configurable rate with amount calculation
- **Status**: Lifecycle from draft to paid/overdue
- **Reports**: Aging, outstanding, revenue reports
