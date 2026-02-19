---
name: CelestialAdmin
description: Skill for building admin dashboards with Starter Admin Template - CelestialAdmin, a Bootstrap-based admin template with modern design, charts, and authentication pages.
---

# CelestialAdmin Skill

## Overview
CelestialAdmin is a free, modern admin dashboard template built with Bootstrap. It features a celestial/dark-themed design with gradient accents, card-based layouts, and comprehensive dashboard widgets.

## Installation
```bash
# Download or clone from GitHub
git clone https://github.com/niceSoftware/CelestialAdmin.git
cd CelestialAdmin
npm install
npm start  # or open index.html directly
```

## Project Structure
```
CelestialAdmin/
├── assets/
│   ├── css/
│   │   ├── style.css          # Main stylesheet
│   │   └── custom.css         # Customizations
│   ├── js/
│   │   ├── dashboard.js       # Chart initializations
│   │   └── custom.js          # Custom scripts
│   ├── images/                # Assets
│   └── plugins/               # Third-party plugins
├── pages/
│   ├── charts/                # Chart pages
│   ├── forms/                 # Form elements
│   ├── tables/                # Data tables
│   ├── auth/                  # Login, register, forgot password
│   └── error/                 # 404, 500 pages
└── index.html                 # Dashboard
```

## Page Layout
```html
<body class="sidebar-fixed">
  <!-- Sidebar -->
  <nav class="sidebar sidebar-offcanvas" id="sidebar">
    <div class="sidebar-brand-wrapper">
      <a class="sidebar-brand brand-logo" href="index.html">CelestialAdmin</a>
    </div>
    <ul class="nav">
      <li class="nav-item active">
        <a class="nav-link" href="index.html">
          <span class="menu-icon"><i class="mdi mdi-speedometer"></i></span>
          <span class="menu-title">Dashboard</span>
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link" data-bs-toggle="collapse" href="#ui-elements" aria-expanded="false">
          <span class="menu-icon"><i class="mdi mdi-palette"></i></span>
          <span class="menu-title">UI Elements</span>
          <i class="menu-arrow"></i>
        </a>
        <div class="collapse" id="ui-elements">
          <ul class="nav flex-column sub-menu">
            <li class="nav-item"><a class="nav-link" href="pages/ui/buttons.html">Buttons</a></li>
            <li class="nav-item"><a class="nav-link" href="pages/ui/cards.html">Cards</a></li>
          </ul>
        </div>
      </li>
    </ul>
  </nav>

  <!-- Page content -->
  <div class="container-fluid page-body-wrapper">
    <!-- Navbar -->
    <nav class="navbar default-layout-navbar">
      <div class="navbar-menu-wrapper">
        <button class="navbar-toggler sidebar-toggler" type="button">
          <span class="mdi mdi-menu"></span>
        </button>
        <ul class="navbar-nav navbar-nav-right">
          <li class="nav-item dropdown">
            <a class="nav-link" data-bs-toggle="dropdown">
              <img src="avatar.jpg" alt="Profile" class="rounded-circle" />
            </a>
          </li>
        </ul>
      </div>
    </nav>

    <!-- Main panel -->
    <div class="main-panel">
      <div class="content-wrapper">
        <div class="row">
          <div class="col-md-4 grid-margin stretch-card">
            <div class="card bg-gradient-primary text-white">
              <div class="card-body">
                <h4 class="font-weight-bold">$15,000</h4>
                <p>Revenue</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
```

## Design Characteristics
- **Dark sidebar** with gradient accent highlights
- **Gradient stat cards** (`bg-gradient-primary`, `bg-gradient-success`)
- **Material Design Icons** (MDI)
- **Card-based dashboard** with stretch cards
- **Rounded avatars** and modern form elements

## Customization
```css
/* Custom brand colors */
.bg-gradient-primary {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
}
.sidebar .nav .nav-item.active > .nav-link {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
}
.sidebar {
  background: #1a1a2e;
}
```

## Rules Integration
- **UI/UX**: Leverage gradient cards and dark sidebar for premium feel
- **Accessibility**: Add ARIA labels to icon-only buttons and sidebar toggles
- **Dependencies**: Bootstrap, Material Design Icons, Chart.js, jQuery
