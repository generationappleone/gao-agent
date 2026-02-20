---
name: PDF Generation
description: Skill for generating PDF documents — covering invoices, reports, certificates using PDFKit, Puppeteer (HTML-to-PDF), jsPDF, and react-pdf with custom styles and templates.
---

# PDF Generation Skill

## Overview
PDF generation is essential for invoices, reports, certificates, receipts, and export functionality. This skill covers server-side (PDFKit, Puppeteer) and client-side (jsPDF, react-pdf) approaches.

**References**:
- [PDFKit](http://pdfkit.org/)
- [Puppeteer PDF](https://pptr.dev/guides/pdf-generation)
- [jsPDF](https://github.com/parallax/jsPDF)

---

## Puppeteer (HTML-to-PDF — Recommended)

```bash
npm install puppeteer
```

```typescript
// src/lib/pdf-generator.ts
import puppeteer from 'puppeteer';

let browser: puppeteer.Browser | null = null;

async function getBrowser() {
  if (!browser) {
    browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
    });
  }
  return browser;
}

// ── Generate PDF from HTML template ──
async function generatePdf(html: string, options?: puppeteer.PDFOptions): Promise<Buffer> {
  const browser = await getBrowser();
  const page = await browser.newPage();

  try {
    await page.setContent(html, { waitUntil: 'networkidle0' });

    const pdfBuffer = await page.pdf({
      format: 'A4',
      printBackground: true,
      margin: { top: '20mm', right: '15mm', bottom: '20mm', left: '15mm' },
      displayHeaderFooter: true,
      headerTemplate: '<div></div>',
      footerTemplate: `
        <div style="width: 100%; font-size: 9px; color: #999; text-align: center; padding: 0 20mm;">
          <span>Page <span class="pageNumber"></span> of <span class="totalPages"></span></span>
        </div>`,
      ...options,
    });

    return Buffer.from(pdfBuffer);
  } finally {
    await page.close();
  }
}
```

### Invoice Template
```typescript
// src/templates/invoice.ts
interface InvoiceData {
  invoiceNumber: string;
  date: string;
  dueDate: string;
  company: { name: string; address: string; phone: string; email: string; logo?: string };
  customer: { name: string; address: string; email: string };
  items: Array<{ description: string; quantity: number; unitPrice: number; total: number }>;
  subtotal: number;
  tax: number;
  discount: number;
  total: number;
  notes?: string;
}

function generateInvoiceHtml(data: InvoiceData): string {
  const itemRows = data.items.map(item => `
    <tr>
      <td>${item.description}</td>
      <td style="text-align: center;">${item.quantity}</td>
      <td style="text-align: right;">${formatCurrency(item.unitPrice)}</td>
      <td style="text-align: right;">${formatCurrency(item.total)}</td>
    </tr>
  `).join('');

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Helvetica Neue', Arial, sans-serif; color: #333; font-size: 12px; }
    .invoice { padding: 40px; }
    .header { display: flex; justify-content: space-between; margin-bottom: 40px; }
    .company-info h1 { font-size: 24px; color: #2563eb; margin-bottom: 8px; }
    .company-info p { color: #666; line-height: 1.6; }
    .invoice-details { text-align: right; }
    .invoice-details h2 { font-size: 28px; color: #2563eb; margin-bottom: 8px; }
    .invoice-details p { color: #666; line-height: 1.6; }
    .bill-to { margin-bottom: 30px; padding: 15px; background: #f8fafc; border-radius: 8px; }
    .bill-to h3 { color: #2563eb; margin-bottom: 8px; font-size: 11px; text-transform: uppercase; letter-spacing: 1px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
    th { background: #2563eb; color: white; padding: 12px 15px; text-align: left; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; }
    td { padding: 12px 15px; border-bottom: 1px solid #e2e8f0; }
    tr:nth-child(even) { background: #f8fafc; }
    .totals { display: flex; justify-content: flex-end; }
    .totals-table { width: 280px; }
    .totals-table tr td { padding: 8px 15px; border: none; }
    .totals-table tr:last-child { font-size: 16px; font-weight: bold; color: #2563eb; border-top: 2px solid #2563eb; }
    .notes { margin-top: 30px; padding: 15px; background: #fffbeb; border-radius: 8px; border-left: 4px solid #f59e0b; }
    .notes h3 { font-size: 11px; margin-bottom: 5px; color: #92400e; }
  </style>
</head>
<body>
  <div class="invoice">
    <div class="header">
      <div class="company-info">
        <h1>${data.company.name}</h1>
        <p>${data.company.address}<br>${data.company.phone}<br>${data.company.email}</p>
      </div>
      <div class="invoice-details">
        <h2>INVOICE</h2>
        <p><strong>Invoice:</strong> ${data.invoiceNumber}<br>
        <strong>Date:</strong> ${data.date}<br>
        <strong>Due Date:</strong> ${data.dueDate}</p>
      </div>
    </div>
    <div class="bill-to">
      <h3>Bill To</h3>
      <p><strong>${data.customer.name}</strong><br>${data.customer.address}<br>${data.customer.email}</p>
    </div>
    <table>
      <thead><tr><th>Description</th><th style="text-align:center;">Qty</th><th style="text-align:right;">Unit Price</th><th style="text-align:right;">Total</th></tr></thead>
      <tbody>${itemRows}</tbody>
    </table>
    <div class="totals">
      <table class="totals-table">
        <tr><td>Subtotal</td><td style="text-align:right;">${formatCurrency(data.subtotal)}</td></tr>
        ${data.discount > 0 ? `<tr><td>Discount</td><td style="text-align:right;">-${formatCurrency(data.discount)}</td></tr>` : ''}
        <tr><td>Tax (11%)</td><td style="text-align:right;">${formatCurrency(data.tax)}</td></tr>
        <tr><td>Total</td><td style="text-align:right;">${formatCurrency(data.total)}</td></tr>
      </table>
    </div>
    ${data.notes ? `<div class="notes"><h3>Notes</h3><p>${data.notes}</p></div>` : ''}
  </div>
</body>
</html>`;
}

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(amount);
}

// ── API Route ──
app.get('/api/invoices/:id/pdf', async (req, res) => {
  const invoice = await getInvoiceData(req.params.id);
  const html = generateInvoiceHtml(invoice);
  const pdf = await generatePdf(html);

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `inline; filename="invoice-${invoice.invoiceNumber}.pdf"`);
  res.send(pdf);
});
```

---

## PDFKit (Programmatic)

```typescript
// src/lib/pdfkit-generator.ts
import PDFDocument from 'pdfkit';

async function generateInvoicePdfKit(data: InvoiceData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: 'A4', margin: 50 });
    const chunks: Buffer[] = [];

    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    // Header
    doc.fontSize(24).fillColor('#2563eb').text(data.company.name, 50, 50);
    doc.fontSize(10).fillColor('#666')
      .text(data.company.address, 50, 80)
      .text(data.company.phone, 50, 95);

    // Invoice title
    doc.fontSize(28).fillColor('#2563eb').text('INVOICE', 400, 50, { align: 'right' });
    doc.fontSize(10).fillColor('#666')
      .text(`Invoice: ${data.invoiceNumber}`, 400, 85, { align: 'right' })
      .text(`Date: ${data.date}`, 400, 100, { align: 'right' });

    // Table
    let y = 200;
    const cols = [50, 300, 380, 460];
    doc.fontSize(10).fillColor('#fff');
    doc.rect(50, y, 500, 25).fill('#2563eb');
    doc.text('Description', cols[0] + 5, y + 7).text('Qty', cols[1], y + 7).text('Price', cols[2], y + 7).text('Total', cols[3], y + 7);

    y += 25;
    doc.fillColor('#333');
    for (const item of data.items) {
      doc.text(item.description, cols[0] + 5, y + 5);
      doc.text(String(item.quantity), cols[1], y + 5);
      doc.text(formatCurrency(item.unitPrice), cols[2], y + 5);
      doc.text(formatCurrency(item.total), cols[3], y + 5);
      y += 25;
      doc.moveTo(50, y).lineTo(550, y).strokeColor('#e2e8f0').stroke();
    }

    // Total
    y += 20;
    doc.fontSize(14).fillColor('#2563eb').text(`Total: ${formatCurrency(data.total)}`, 400, y, { align: 'right' });

    doc.end();
  });
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Puppeteer for complex** | HTML/CSS templates are easier to design than programmatic |
| **PDFKit for simple** | Faster, no browser dependency, good for simple layouts |
| **Browser reuse** | Keep Puppeteer browser instance alive, close pages only |
| **Streaming** | Stream large PDFs to response instead of buffering |
| **Templates** | Separate HTML templates from generation logic |
| **Fonts** | Embed custom fonts for consistent rendering |
| **Caching** | Cache generated PDFs if data doesn't change frequently |
| **Queue processing** | Generate PDFs in background queue for large batches |
| **Docker** | Install Chromium dependencies in Docker for Puppeteer |
| **Filename** | Set Content-Disposition for download with meaningful name |

---

## Rules Integration
- **Puppeteer**: HTML/CSS templates → PDF with headers, footers, page numbers
- **PDFKit**: Programmatic PDF creation for simple documents
- **Templates**: Invoice, report, certificate with professional styling
- **API**: Stream PDF as response with proper Content-Type headers
- **Performance**: Browser reuse, queue for batch, cache for repeat downloads
