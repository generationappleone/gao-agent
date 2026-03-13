# Running Code — Playwright CLI

## JavaScript Execution

```bash
# Execute JS in page context
playwright evaluate "document.title"
playwright evaluate "document.querySelectorAll('a').length"

# Return structured data
playwright evaluate "JSON.stringify(Array.from(document.querySelectorAll('h2')).map(h => h.textContent))"
```

## Geolocation

```bash
# Set geolocation
playwright open --geolocation "40.7128,-74.0060" https://maps.example.com

# With permission granted
playwright open --geolocation "40.7128,-74.0060" --permissions geolocation https://maps.example.com
```

## Permissions

```bash
# Grant permissions
playwright open --permissions "geolocation,notifications,camera" https://example.com
```

## Media Emulation

```bash
# Dark mode
playwright open --color-scheme dark https://example.com

# Reduced motion
playwright open --reduced-motion reduce https://example.com

# Forced colors
playwright open --forced-colors active https://example.com
```

## Device Emulation

```bash
# Mobile viewport
playwright open --viewport-size 375,812 https://example.com

# With user agent
playwright open --viewport-size 375,812 \
  --user-agent "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0)" \
  https://example.com
```

## Wait Strategies

```bash
# Wait for navigation
playwright click e3 --wait-for navigation

# Wait for element
playwright wait-for-selector ".success-message"

# Wait for network idle
playwright wait-for-load-state networkidle

# Explicit wait
playwright wait 2000
```

## Frames

```bash
# List frames
playwright frames

# Switch to frame
playwright frame 1

# Switch back to main
playwright frame main
```

## Downloads

```bash
# Trigger download and save
playwright click e5 --expect-download --download-path ./downloads/

# Wait for download
playwright download --save-as ./report.pdf
```

## Clipboard

```bash
# Copy to clipboard
playwright evaluate "navigator.clipboard.writeText('test')"

# Read clipboard (requires permission)
playwright evaluate "navigator.clipboard.readText()"
```

## Error Handling

```bash
# Set timeout
playwright click e3 --timeout 5000

# Continue on error
playwright click e3 --timeout 5000 --ignore-error
```

## Complex Workflows

### Multi-Step Form with Validation

```bash
playwright open https://app.example.com/register
playwright snapshot
playwright fill e1 "John"               # First name
playwright fill e2 "Doe"                 # Last name
playwright fill e3 "john@example.com"    # Email
playwright fill e4 "SecurePass123!"      # Password
playwright click e5                       # Next step
playwright wait-for-selector ".step-2"
playwright snapshot                       # Get new elements
playwright select e1 "United States"     # Country
playwright fill e2 "10001"               # ZIP code
playwright click e3                       # Submit
playwright wait-for-selector ".success"
playwright screenshot --path ./registered.png
```
