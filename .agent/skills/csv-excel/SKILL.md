---
name: CSV / Excel Processing
description: Skill for CSV and Excel file processing — covering parsing, generation, streaming large files, data transformation, and integration with Node.js (PapaParse, ExcelJS) and Python (pandas, openpyxl).
---

# CSV / Excel Processing Skill

## Overview
This skill covers CSV/Excel file parsing, generation, and data transformation for import/export functionality.

## Node.js — CSV (PapaParse)
```typescript
import Papa from "papaparse";
import fs from "fs";

// Parse CSV
const csvString = fs.readFileSync("data.csv", "utf-8");
const result = Papa.parse<UserRow>(csvString, {
  header: true,
  skipEmptyLines: true,
  transformHeader: (h) => h.trim().toLowerCase().replace(/\s+/g, "_"),
  transform: (value) => value.trim(),
});

if (result.errors.length) console.error("Parse errors:", result.errors);
const rows: UserRow[] = result.data;

// Generate CSV
const csvOutput = Papa.unparse(data, { header: true });
fs.writeFileSync("output.csv", csvOutput, "utf-8");
```

## Node.js — Excel (ExcelJS)
```typescript
import ExcelJS from "exceljs";

// Read Excel
const workbook = new ExcelJS.Workbook();
await workbook.xlsx.readFile("data.xlsx");
const sheet = workbook.getWorksheet("Sheet1")!;

const rows: Record<string, any>[] = [];
const headers = sheet.getRow(1).values as string[];
sheet.eachRow((row, rowNumber) => {
  if (rowNumber === 1) return; // Skip header
  const obj: Record<string, any> = {};
  row.eachCell((cell, colNumber) => {
    obj[headers[colNumber]] = cell.value;
  });
  rows.push(obj);
});

// Generate Excel
const wb = new ExcelJS.Workbook();
const ws = wb.addWorksheet("Users");

ws.columns = [
  { header: "ID", key: "id", width: 15 },
  { header: "Name", key: "name", width: 30 },
  { header: "Email", key: "email", width: 35 },
  { header: "Created At", key: "createdAt", width: 20 },
];

// Style header
ws.getRow(1).font = { bold: true, color: { argb: "FFFFFF" } };
ws.getRow(1).fill = { type: "pattern", pattern: "solid", fgColor: { argb: "4472C4" } };
ws.getRow(1).alignment = { horizontal: "center" };

users.forEach(user => ws.addRow(user));

// Auto-filter
ws.autoFilter = "A1:D1";

await wb.xlsx.writeFile("users.xlsx");

// Stream to response (Express)
res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
res.setHeader("Content-Disposition", 'attachment; filename="users.xlsx"');
await wb.xlsx.write(res);
```

## Python (pandas)
```python
import pandas as pd

# Read
df = pd.read_csv("data.csv")
df = pd.read_excel("data.xlsx", sheet_name="Sheet1")

# Transform
df["full_name"] = df["first_name"] + " " + df["last_name"]
df = df[df["age"] > 18]

# Write
df.to_csv("output.csv", index=False, encoding="utf-8")
df.to_excel("output.xlsx", index=False, sheet_name="Users")

# Multiple sheets
with pd.ExcelWriter("report.xlsx") as writer:
    users_df.to_excel(writer, sheet_name="Users", index=False)
    orders_df.to_excel(writer, sheet_name="Orders", index=False)
```

## Streaming Large Files
```typescript
// Stream read (memory-efficient for large files)
const stream = fs.createReadStream("large.csv");
Papa.parse(stream, {
  header: true,
  step: (row) => {
    processRow(row.data);  // Process one row at a time
  },
  complete: () => console.log("Done"),
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Streaming** | Stream large files — don't load into memory |
| **Validation** | Validate each row before processing |
| **Error handling** | Collect parse errors, don't fail silently |
| **Encoding** | Always specify UTF-8 encoding |
| **Headers** | Normalize headers (lowercase, underscore) |
| **Dates** | Parse dates explicitly, don't rely on auto-detection |
| **BOM** | Handle UTF-8 BOM in CSV files |
| **Chunking** | Process in batches for database imports |
