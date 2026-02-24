# Unicode & Encoding Standards

**Priority: HIGH**
**Mandatory for: All Text-Based Outputs (Code, Configs, Logs)**

To prevent "Mojibake" or Unicode Corruptions when opening the project across different AI models, code editors (Cursor, Visual Studio Code), and operating systems, you must strictly follow these encoding guidelines.

## Core Principle

**The sole universal truth for file encoding in this repository is `utf-8` (UTF-8 without BOM).**

## Enforcement Details

1. **Writing Files via Commands / Scripts:**
   Whenever you create a script (Python, Node.js) that reads or writes to a file, you MUST explicitly define the encoding as `utf-8`.
   - Python: `open(filepath, "r", encoding="utf-8")`
   - Node: `fs.readFileSync(filepath, "utf8")` or `fs.promises.readFile(filepath, { encoding: "utf8" })`

2. **No BOM Allowed:**
   Byte Order Marks (`\xef\xbb\xbf`) are strictly forbidden. They cause erratic parsing behavior for JSON and compiler crashes in strictly typed languages. Check and strip them if they exist in source files during text processing.

3. **Newline Characters:**
   Force `LF` (`\n`) for all regular files. The only exceptions are Windows-specific scripts like `.bat`, `.cmd`, or `.ps1`, which may use `CRLF` (`\r\n`).

4. **Honoring `.editorconfig`:**
   Rely on the existing `.editorconfig` file in the repository root. Do not tamper with standard coding encodings without user permission.

## Anti-Patterns (What NOT to Do)

❌ **Implicit Encoding:**
```python
# BAD: Fallbacks to OS default (cp1252 on Windows)
with open("data.json", "w") as f:
    f.write(content)
```

❌ **Wrong Tool Usage:**
Opening a file, corrupting multi-byte characters, and saving it permanently. (e.g., converting `é` to `Ã©` and then committing changes).
