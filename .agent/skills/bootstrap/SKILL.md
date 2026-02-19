---
name: Bootstrap
description: Skill for building responsive web interfaces with Bootstrap 5, covering grid system, components, utilities, customization with Sass, and accessibility best practices.
---

# Bootstrap 5 Skill

## Overview
Bootstrap is the most popular CSS framework for building responsive, mobile-first websites. Use this skill for rapid UI development with a comprehensive component library.

## Installation

### CDN (Quick Start)
```html
<!-- CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
      integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YcnS49Xn..." crossorigin="anonymous">
<!-- JS Bundle (Popper included) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaA..." crossorigin="anonymous"></script>
```

### npm (Recommended for Projects)
```bash
npm install bootstrap@5.3.3
npm install -D sass  # For customization
```

```javascript
// main.js
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';

// Or import only what you need (tree-shaking)
import { Modal, Tooltip, Dropdown } from 'bootstrap';
```

## Grid System
```html
<!-- ✅ REQUIRED: Mobile-first responsive grid -->
<div class="container">
  <div class="row g-4"> <!-- g-4 = gap/gutter -->
    <div class="col-12 col-md-6 col-lg-4">Card 1</div>
    <div class="col-12 col-md-6 col-lg-4">Card 2</div>
    <div class="col-12 col-md-12 col-lg-4">Card 3</div>
  </div>
</div>

<!-- Breakpoints: sm(576px) md(768px) lg(992px) xl(1200px) xxl(1400px) -->
```

## Sass Customization
```scss
// _custom-variables.scss — Override BEFORE importing Bootstrap
$primary:       #6366f1;
$secondary:     #8b5cf6;
$success:       #22c55e;
$warning:       #f59e0b;
$danger:        #ef4444;

$font-family-sans-serif: 'Inter', system-ui, -apple-system, sans-serif;
$border-radius:          0.5rem;
$border-radius-lg:       0.75rem;

$enable-dark-mode:       true;
$enable-shadows:         true;
$enable-gradients:       false;
$enable-rounded:         true;

// Import Bootstrap
@import "bootstrap/scss/bootstrap";
```

## Key Components
```html
<!-- Card with premium styling -->
<div class="card border-0 shadow-sm rounded-3">
  <div class="card-body p-4">
    <h5 class="card-title fw-bold">Title</h5>
    <p class="card-text text-body-secondary">Description text</p>
    <a href="#" class="btn btn-primary rounded-pill px-4">Action</a>
  </div>
</div>

<!-- Modal -->
<div class="modal fade" id="myModal" tabindex="-1" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow-lg">
      <div class="modal-header border-0">
        <h5 class="modal-title" id="myModalLabel">Title</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">Content</div>
    </div>
  </div>
</div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg bg-body-tertiary shadow-sm">
  <div class="container">
    <a class="navbar-brand fw-bold" href="#">Brand</a>
    <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#nav"
            aria-controls="nav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="nav">
      <ul class="navbar-nav ms-auto gap-1">
        <li class="nav-item"><a class="nav-link active" href="#">Home</a></li>
        <li class="nav-item"><a class="nav-link" href="#">Features</a></li>
      </ul>
    </div>
  </div>
</nav>
```

## Utility Classes (Most Used)
| Category | Classes |
|----------|---------|
| **Spacing** | `m-{0-5}`, `p-{0-5}`, `mx-auto`, `gap-{0-5}` |
| **Flexbox** | `d-flex`, `justify-content-{start\|center\|end\|between}`, `align-items-center` |
| **Grid** | `row`, `col-{1-12}`, `g-{0-5}` |
| **Typography** | `fw-{bold\|semibold}`, `fs-{1-6}`, `text-{start\|center\|end}` |
| **Colors** | `text-primary`, `bg-primary`, `text-body-secondary` |
| **Display** | `d-{none\|block\|flex\|grid}`, `d-md-block` |
| **Borders** | `border`, `border-0`, `rounded-{0-5\|pill\|circle}` |
| **Shadow** | `shadow-sm`, `shadow`, `shadow-lg`, `shadow-none` |

## Dark Mode (Bootstrap 5.3+)
```html
<!-- Set globally -->
<html data-bs-theme="dark">

<!-- Per-component -->
<div data-bs-theme="light" class="card">Light card in dark page</div>

<!-- Toggle with JS -->
<script>
  document.documentElement.setAttribute('data-bs-theme',
    document.documentElement.getAttribute('data-bs-theme') === 'dark' ? 'light' : 'dark'
  );
</script>
```

## Rules Integration
- **UI/UX**: Customize variables for premium look, use `shadow-sm` + `border-0` + `rounded-3` for modern cards
- **Accessibility**: Bootstrap includes ARIA attributes — always keep them, add `aria-label` for icon-only buttons
- **Dependencies**: Check Bootstrap version compatibility with popper.js and project framework
