---
name: Ample Admin Lite
description: Skill for building admin dashboards with Ample Admin Lite, a free Bootstrap admin template by WrapPixel with material-inspired design, charts, and pre-built pages.
---

# Ample Admin Lite Skill

## Overview
Ample Admin Lite is a free Bootstrap admin template by WrapPixel. It features a material-inspired design with clean typography, card widgets, and essential dashboard components. Suitable as a starting point for admin panels.

## Installation
```bash
# Download from WrapPixel or GitHub
git clone https://github.com/wrappixel/ample-admin-lite.git
cd ample-admin-lite
npm install
npm start
# Or open index.html directly
```

## Project Structure
```
ample-admin-lite/
├── assets/
│   ├── css/
│   │   └── style.min.css       # Compiled CSS
│   ├── js/
│   │   ├── custom.js            # Custom scripts
│   │   ├── sidebarmenu.js       # Sidebar logic
│   │   └── waves.js             # Material ripple effect
│   ├── images/
│   └── plugins/
│       ├── bower_components/
│       │   ├── bootstrap/
│       │   └── jquery/
│       ├── chartist/            # Chartist.js charts
│       └── datatables/
├── pages/
│   ├── forms-basic.html
│   ├── table-basic.html
│   ├── chart-chartist.html
│   ├── login.html
│   ├── register.html
│   ├── 404.html
│   └── blank.html
├── scss/
│   ├── _variables.scss
│   ├── _sidebar.scss
│   ├── _topbar.scss
│   └── style.scss
└── index.html                   # Dashboard
```

## Page Layout
```html
<body class="fix-header fix-sidebar card-no-border">
  <div id="main-wrapper">
    <!-- Top navigation -->
    <header class="topbar">
      <nav class="navbar top-navbar navbar-expand-md navbar-light">
        <div class="navbar-header">
          <a class="navbar-brand" href="index.html">
            <span class="logo-text">AmpleAdmin</span>
          </a>
        </div>
        <div class="navbar-collapse">
          <ul class="navbar-nav me-auto">
            <li class="nav-item">
              <a class="nav-link sidebartoggler" href="javascript:void(0)" aria-label="Toggle sidebar">
                <i class="mdi mdi-menu"></i>
              </a>
            </li>
          </ul>
          <ul class="navbar-nav">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                <img src="avatar.jpg" alt="user" class="rounded-circle" width="31">
              </a>
              <div class="dropdown-menu dropdown-menu-end">
                <a class="dropdown-item" href="#"><i class="mdi mdi-account me-1"></i> Profile</a>
                <a class="dropdown-item" href="#"><i class="mdi mdi-logout me-1"></i> Logout</a>
              </div>
            </li>
          </ul>
        </div>
      </nav>
    </header>

    <!-- Left sidebar -->
    <aside class="left-sidebar">
      <div class="scroll-sidebar">
        <nav class="sidebar-nav">
          <ul id="sidebarnav">
            <li class="sidebar-item">
              <a class="sidebar-link active" href="index.html">
                <i class="mdi mdi-view-dashboard"></i>
                <span class="hide-menu">Dashboard</span>
              </a>
            </li>
            <li class="sidebar-item">
              <a class="sidebar-link has-arrow" href="javascript:void(0)">
                <i class="mdi mdi-account-multiple"></i>
                <span class="hide-menu">Users</span>
              </a>
              <ul class="collapse first-level">
                <li class="sidebar-item">
                  <a href="#" class="sidebar-link"><span class="hide-menu">All Users</span></a>
                </li>
              </ul>
            </li>
          </ul>
        </nav>
      </div>
    </aside>

    <!-- Page wrapper -->
    <div class="page-wrapper">
      <div class="container-fluid">
        <!-- Breadcrumb -->
        <div class="row page-titles">
          <div class="col-md-5">
            <h3 class="text-themecolor">Dashboard</h3>
          </div>
          <div class="col-md-7 text-end">
            <ol class="breadcrumb">
              <li class="breadcrumb-item"><a href="javascript:void(0)">Home</a></li>
              <li class="breadcrumb-item active">Dashboard</li>
            </ol>
          </div>
        </div>

        <!-- Stat cards -->
        <div class="row">
          <div class="col-lg-3 col-md-6">
            <div class="card">
              <div class="card-body">
                <div class="d-flex flex-row">
                  <div class="round round-lg align-self-center round-info">
                    <i class="mdi mdi-cart-outline"></i>
                  </div>
                  <div class="ms-2 align-self-center">
                    <h3 class="mb-0 font-weight-bold">1,260</h3>
                    <span class="text-muted">New Orders</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Charts -->
        <div class="row">
          <div class="col-lg-8">
            <div class="card">
              <div class="card-body">
                <h4 class="card-title">Revenue Statistics</h4>
                <div class="ct-chart" id="revenue-chart" style="height: 350px;"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <footer class="footer">© 2026 Ample Admin by WrapPixel</footer>
    </div>
  </div>
</body>
```

## Design Characteristics
- **Material-inspired** design with Material Design Icons
- **Waves.js** ripple effect on buttons
- **Chartist.js** for lightweight charts
- **Fixed header + sidebar** layout
- **Card-based** stat widgets with round icon backgrounds
- **Color-themed elements** via `.text-themecolor`, `.bg-theme`

## Customization (SCSS)
```scss
// _variables.scss
$themecolor: #6366f1;
$sidebar-bg: #1e293b;
$topbar-bg: #ffffff;

$font-family: 'Inter', 'Poppins', sans-serif;
$body-bg: #f5f7fa;
$card-border-radius: 12px;
$card-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);

// Round icon badges
.round-info  { background: rgba($info, 0.1);  color: $info; }
.round-primary { background: rgba($themecolor, 0.1); color: $themecolor; }
```

## Key Pages Included
| Page | Description |
|------|-------------|
| `index.html` | Main dashboard with stats, charts, tables |
| `pages/forms-basic.html` | Input elements, textareas, selects |
| `pages/table-basic.html` | Basic and striped tables |
| `pages/chart-chartist.html` | Line, bar, pie charts |
| `pages/login.html` | Login page |
| `pages/register.html` | Registration page |
| `pages/404.html` | Error page |
| `pages/blank.html` | Blank starter page |

## Rules Integration
- **UI/UX**: Customize `$themecolor` for brand identity, add transitions to cards for modern feel
- **Accessibility**: Add ARIA labels to sidebar toggles, ensure chart data is accessible via tables
- **Dependencies**: Bootstrap, jQuery, Chartist.js, Material Design Icons, Waves.js
