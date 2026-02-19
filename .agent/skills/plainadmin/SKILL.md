---
name: Plain Admin
description: Skill for building admin dashboards with PlainAdmin, a free Bootstrap 5 admin template with clean, minimal design and modern components.
---

# Plain Admin Skill

## Overview
PlainAdmin is a free, open-source Bootstrap 5 admin template focused on clean, minimal design. It provides a straightforward starting point for admin dashboards with essential components and pages.

## Installation
```bash
git clone https://github.com/PlainAdmin/plain-free-bootstrap5-admin-template.git
cd plain-free-bootstrap5-admin-template
npm install
npm run dev
```

## Project Structure
```
PlainAdmin/
├── assets/
│   ├── css/
│   │   ├── style.css           # Main styles (compiled)
│   │   └── lineicons.css       # Line Icons
│   ├── js/
│   │   └── main.js             # Custom JavaScript
│   ├── images/
│   └── fonts/
├── scss/
│   ├── _variables.scss         # Theme variables
│   ├── _sidebar.scss
│   ├── _header.scss
│   ├── _card.scss
│   └── style.scss              # Main entry
├── pages/
│   ├── auth/                   # Login, register
│   ├── profile.html
│   ├── tables.html
│   ├── forms.html
│   └── blank.html
└── index.html                  # Dashboard
```

## Page Layout
```html
<body>
  <!-- Sidebar -->
  <aside class="sidebar-nav-wrapper">
    <div class="sidebar-header">
      <a href="index.html" class="logo"><img src="logo.svg" alt="Logo"></a>
    </div>
    <nav class="sidebar-nav">
      <ul>
        <li class="nav-item active">
          <a href="index.html">
            <span class="icon"><i class="lni lni-dashboard"></i></span>
            <span class="text">Dashboard</span>
          </a>
        </li>
        <li class="nav-item nav-item-has-children">
          <a href="#" class="collapsed" data-bs-toggle="collapse" data-bs-target="#users-menu">
            <span class="icon"><i class="lni lni-users"></i></span>
            <span class="text">Users</span>
          </a>
          <ul id="users-menu" class="collapse dropdown-nav">
            <li><a href="#">All Users</a></li>
            <li><a href="#">Add User</a></li>
          </ul>
        </li>
      </ul>
    </nav>
  </aside>

  <!-- Overlay for mobile sidebar -->
  <div class="overlay"></div>

  <!-- Main wrapper -->
  <main class="main-wrapper">
    <!-- Header -->
    <header class="header">
      <div class="container-fluid">
        <div class="row">
          <div class="col-lg-5 col-md-5 col-6">
            <div class="header-left">
              <button class="sidebar-toggle" aria-label="Toggle sidebar">
                <span></span>
              </button>
            </div>
          </div>
          <div class="col-lg-7 col-md-7 col-6">
            <div class="header-right">
              <!-- Notifications, user menu -->
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Content -->
    <section class="section">
      <div class="container-fluid">
        <div class="title-wrapper pt-30">
          <h2 class="title mb-0">Dashboard</h2>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
              <li class="breadcrumb-item"><a href="#">Home</a></li>
              <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
            </ol>
          </nav>
        </div>

        <!-- Stat cards -->
        <div class="row">
          <div class="col-xl-3 col-lg-4 col-sm-6">
            <div class="card card-style-1">
              <div class="card-icon primary"><i class="lni lni-revenue"></i></div>
              <div class="card-content">
                <h6>Revenue</h6>
                <h3 class="mb-0">$45,000</h3>
                <span class="trend-badge success">+12.5%</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="footer"><p>&copy; 2026 PlainAdmin</p></footer>
  </main>
</body>
```

## Customization (SCSS)
```scss
// _variables.scss
$primary:       #6366f1;
$secondary:     #8b5cf6;
$success:       #22c55e;
$warning:       #f59e0b;
$danger:        #ef4444;

$sidebar-width: 260px;
$sidebar-bg:    #1e293b;
$sidebar-text:  #e2e8f0;

$font-family:   'Inter', sans-serif;
$border-radius:  0.5rem;
$card-shadow:    0 1px 3px rgba(0, 0, 0, 0.08);
```

## Design Characteristics
- **Clean, minimal aesthetic** — white backgrounds, subtle shadows
- **Line Icons** (LineIcons) for consistent icon style
- **Card-based stat widgets** with trend badges
- **Breadcrumb navigation** on all pages
- **Mobile responsive** with overlay sidebar

## Rules Integration
- **UI/UX**: Clean and minimal — enhance with micro-interactions and gradient accents for premium feel
- **Accessibility**: Includes breadcrumbs, semantic HTML, ARIA labels on toggle buttons
- **Dependencies**: Bootstrap 5, LineIcons — lightweight dependency stack
