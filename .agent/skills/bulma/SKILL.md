---
name: Bulma
description: Skill for building responsive web interfaces with Bulma CSS framework, covering layout system, components, customization with Sass, and modern design patterns.
---

# Bulma Skill

## Overview
Bulma is a modern CSS framework based on Flexbox. It's **CSS-only** (no JavaScript required), modular, and easy to customize. Use this skill for clean, readable HTML interfaces.

## Installation

### CDN
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.0/css/bulma.min.css" />
```

### npm
```bash
npm install bulma
```

```scss
// Import with Sass customization
@use "bulma/sass" with (
  $primary: #6366f1,
  $link: #6366f1,
  $family-sans-serif: ('Inter', sans-serif),
  $radius: 0.5rem,
  $radius-large: 0.75rem,
);
```

## Layout System
```html
<!-- Container -->
<div class="container is-max-desktop">
  <!-- Columns (Flexbox-based) -->
  <div class="columns is-multiline is-variable is-6">
    <div class="column is-4-desktop is-6-tablet is-12-mobile">
      Card 1
    </div>
    <div class="column is-4-desktop is-6-tablet is-12-mobile">
      Card 2
    </div>
    <div class="column is-4-desktop is-12-tablet is-12-mobile">
      Card 3
    </div>
  </div>
</div>
```

## Key Components
```html
<!-- Card -->
<div class="card">
  <div class="card-content">
    <p class="title is-4">Card Title</p>
    <p class="subtitle is-6 has-text-grey">Card description here</p>
    <div class="content">Body content goes here.</div>
  </div>
  <footer class="card-footer">
    <a href="#" class="card-footer-item has-text-primary">Save</a>
    <a href="#" class="card-footer-item">Cancel</a>
  </footer>
</div>

<!-- Navbar -->
<nav class="navbar is-white has-shadow" role="navigation" aria-label="main navigation">
  <div class="container">
    <div class="navbar-brand">
      <a class="navbar-item has-text-weight-bold is-size-5" href="#">Brand</a>
      <a role="button" class="navbar-burger" aria-label="menu" aria-expanded="false" data-target="main-nav">
        <span aria-hidden="true"></span><span aria-hidden="true"></span><span aria-hidden="true"></span>
      </a>
    </div>
    <div id="main-nav" class="navbar-menu">
      <div class="navbar-end">
        <a class="navbar-item is-active">Home</a>
        <a class="navbar-item">Features</a>
        <div class="navbar-item">
          <a class="button is-primary is-rounded">Sign Up</a>
        </div>
      </div>
    </div>
  </div>
</nav>

<!-- Hero -->
<section class="hero is-primary is-medium">
  <div class="hero-body">
    <div class="container has-text-centered">
      <p class="title is-1">Welcome</p>
      <p class="subtitle is-4">Build amazing things</p>
      <a class="button is-white is-rounded is-medium mt-4">Get Started</a>
    </div>
  </div>
</section>

<!-- Form -->
<div class="field">
  <label class="label">Email</label>
  <div class="control has-icons-left">
    <input class="input is-medium" type="email" placeholder="you@example.com" />
    <span class="icon is-left"><i class="fas fa-envelope"></i></span>
  </div>
</div>

<!-- Notification -->
<div class="notification is-info is-light">
  <button class="delete"></button>
  An informational notification message.
</div>

<!-- Tags -->
<div class="tags">
  <span class="tag is-primary is-light is-medium">Active</span>
  <span class="tag is-danger is-light is-medium">Overdue</span>
  <span class="tag is-success is-light is-medium">Completed</span>
</div>
```

## Modifiers (Helper Classes)
| Category | Examples |
|----------|---------|
| **Color** | `is-primary`, `is-link`, `is-info`, `is-success`, `is-warning`, `is-danger` |
| **Size** | `is-small`, `is-medium`, `is-large` |
| **Typography** | `is-size-{1-7}`, `has-text-weight-bold`, `has-text-centered` |
| **Spacing** | `mt-{0-6}`, `mb-{0-6}`, `mx-auto`, `p-{0-6}` |
| **Display** | `is-hidden-mobile`, `is-hidden-desktop`, `is-flex`, `is-block` |
| **Light variant** | `is-primary is-light` (soft background with colored text) |
| **Rounded** | `is-rounded` (for buttons, inputs, images) |

## Rules Integration
- **UI/UX**: Customize Sass variables for brand colors, use `is-light` variants for soft modern look
- **Accessibility**: Bulma includes ARIA patterns in docs — always add `role` and `aria-` attributes
- **Dependencies**: CSS-only — no JS dependencies, add your own for interactive components
