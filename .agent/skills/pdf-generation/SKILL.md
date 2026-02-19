---
name: PDF Generation
description: Skill for generating PDF documents — covering invoices, reports, certificates using PDFKit, Puppeteer (HTML-to-PDF), jsPDF, and react-pdf with custom styles and templates.
---

# PDF Generation Skill

## Overview
PDF generation is essential for invoices, reports, certificates, and printable documents. This skill covers multiple approaches.

## PDFKit (Node.js — Programmatic)
```typescript
import PDFDocument from "pdfkit";
import fs from "fs";

function generateInvoice(invoice: Invoice): Promise<Buffer> {
  return new Promise((resolve) => {
    const doc = new PDFDocument({ margin: 50 });
    const chunks: Buffer[] = [];
    doc.on("data", (chunk) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));

    // Header
    doc.fontSize(20).text("INVOICE", { align: "right" });
    doc.fontSize(10).text(`#${invoice.number}`, { align: "right" });
    doc.moveDown();

    // Company info
    doc.fontSize(14).text(invoice.company.name);
    doc.fontSize(10).text(invoice.company.address);
    doc.moveDown(2);

    // Table header
    const tableTop = doc.y;
    doc.font("Helvetica-Bold");
    doc.text("Item", 50, tableTop);
    doc.text("Qty", 300, tableTop, { width: 50, align: "center" });
    doc.text("Price", 370, tableTop, { width: 80, align: "right" });
    doc.text("Total", 460, tableTop, { width: 80, align: "right" });

    // Table rows
    doc.font("Helvetica");
    let y = tableTop + 25;
    invoice.items.forEach(item => {
      doc.text(item.name, 50, y);
      doc.text(String(item.quantity), 300, y, { width: 50, align: "center" });
      doc.text(`$${item.price.toFixed(2)}`, 370, y, { width: 80, align: "right" });
      doc.text(`$${(item.quantity * item.price).toFixed(2)}`, 460, y, { width: 80, align: "right" });
      y += 20;
    });

    // Total
    doc.moveDown(2);
    doc.font("Helvetica-Bold").fontSize(14);
    doc.text(`Total: $${invoice.total.toFixed(2)}`, { align: "right" });

    doc.end();
  });
}
```

## Puppeteer (HTML-to-PDF)
```typescript
import puppeteer from "puppeteer";

async function htmlToPdf(html: string): Promise<Buffer> {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();
  await page.setContent(html, { waitUntil: "networkidle0" });
  const pdf = await page.pdf({
    format: "A4",
    margin: { top: "20mm", right: "15mm", bottom: "20mm", left: "15mm" },
    printBackground: true,
    displayHeaderFooter: true,
    headerTemplate: '<div style="font-size:8px;width:100%;text-align:center;">Company Name</div>',
    footerTemplate: '<div style="font-size:8px;width:100%;text-align:center;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>',
  });
  await browser.close();
  return Buffer.from(pdf);
}

// Express endpoint
app.get("/api/invoice/:id/pdf", async (req, res) => {
  const invoice = await getInvoice(req.params.id);
  const html = renderInvoiceTemplate(invoice);
  const pdf = await htmlToPdf(html);
  res.setHeader("Content-Type", "application/pdf");
  res.setHeader("Content-Disposition", `attachment; filename="invoice-${invoice.number}.pdf"`);
  res.send(pdf);
});
```

## jsPDF (Browser-side)
```typescript
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

function generateReport(data: ReportData) {
  const doc = new jsPDF();
  doc.setFontSize(18);
  doc.text("Monthly Report", 14, 22);

  autoTable(doc, {
    head: [["Name", "Email", "Amount"]],
    body: data.rows.map(r => [r.name, r.email, `$${r.amount}`]),
    startY: 30,
    theme: "striped",
  });

  doc.save("report.pdf");
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **HTML-to-PDF** | Preferred for complex layouts (use Puppeteer) |
| **PDFKit** | Best for programmatic, template-free generation |
| **Streaming** | Stream large PDFs to avoid memory issues |
| **Fonts** | Embed custom fonts for non-Latin characters |
| **Page numbers** | Always include in multi-page documents |
| **Accessible** | Add document metadata (title, author) |
| **Caching** | Cache generated PDFs when data doesn't change |
| **Async generation** | Queue long-running PDF jobs |
