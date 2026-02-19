---
name: AdminKit
description: Skill for building admin dashboards with AdminKit, a Bootstrap 5 admin template with clean design, covering setup, layout, pages, and customization.
---

# AdminKit Skill

## Overview
AdminKit is a professional Bootstrap 5 admin dashboard template. It features a clean, modern design with focus on developer experience. Available in HTML, React, and Vue versions.

## Installation

### HTML Version
```bash
git clone https://github.com/adminkit/adminkit.git
cd adminkit
npm install
npm run dev  # Starts with Webpack dev server
```

### React Version
```bash
npx -y create-react-app my-admin --template adminkit
# or clone from repo
git clone https://github.com/adminkit/adminkit-react.git
npm install && npm start
```

## Project Structure
```
src/
├── html/
│   ├── dashboard.html
│   ├── pages/           # Auth, errors, blank
│   └── layouts/         # Default, sidebar collapsed
├── js/
│   ├── modules/         # Chart.js, DataTables init
│   └── app.js           # Main entry
├── scss/
│   ├── _variables.scss  # Theme variables
│   ├── _sidebar.scss
│   ├── _navbar.scss
│   └── app.scss         # Main stylesheet
└── img/                 # Assets
```

## Page Layout
```html
<div class="wrapper">
  <!-- Sidebar -->
  <nav id="sidebar" class="sidebar">
    <div class="sidebar-content">
      <a class="sidebar-brand" href="#">AdminKit</a>
      <ul class="sidebar-nav">
        <li class="sidebar-header">Pages</li>
        <li class="sidebar-item active">
          <a class="sidebar-link" href="dashboard.html">
            <i class="align-middle" data-feather="sliders"></i>
            <span class="align-middle">Dashboard</span>
          </a>
        </li>
        <li class="sidebar-item">
          <a data-bs-target="#users-nav" data-bs-toggle="collapse" class="sidebar-link collapsed">
            <i class="align-middle" data-feather="users"></i>
            <span class="align-middle">Users</span>
          </a>
          <ul id="users-nav" class="sidebar-dropdown list-unstyled collapse">
            <li class="sidebar-item"><a class="sidebar-link" href="#">All Users</a></li>
            <li class="sidebar-item"><a class="sidebar-link" href="#">Add User</a></li>
          </ul>
        </li>
      </ul>
    </div>
  </nav>

  <div class="main">
    <!-- Navbar -->
    <nav class="navbar navbar-expand navbar-light navbar-bg">
      <a class="sidebar-toggle"><i class="hamburger align-self-center"></i></a>
      <div class="navbar-collapse collapse">
        <ul class="navbar-nav navbar-align">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
              <img src="avatar.jpg" class="avatar rounded-circle" alt="User" /> <span>John Doe</span>
            </a>
          </li>
        </ul>
      </div>
    </nav>

    <!-- Content -->
    <main class="content">
      <div class="container-fluid p-0">
        <h1 class="h3 mb-3">Dashboard</h1>
        <div class="row">
          <div class="col-xl-3 col-md-6">
            <div class="card">
              <div class="card-body">
                <h5 class="card-title">Revenue</h5>
                <h1 class="mt-1 mb-3">$45,000</h1>
                <div class="mb-0"><span class="text-success">+12.5%</span> Since last month</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <footer class="footer"><p>&copy; 2026 AdminKit</p></footer>
  </div>
</div>
```

## Customization (SCSS Variables)
```scss
// _variables.scss
$primary:    #6366f1;
$success:    #22c55e;
$info:       #3b82f6;
$warning:    #f59e0b;
$danger:     #ef4444;

$sidebar-bg: #1e293b;
$sidebar-width: 260px;
$sidebar-link-color: #e2e8f0;

$font-family-sans-serif: 'Inter', sans-serif;
$border-radius: 0.5rem;
```

## Key Features
| Feature | Description |
|---------|-------------|
| **Charts** | Chart.js integration (line, bar, pie, doughnut) |
| **Maps** | Vector maps with jsvectormap |
| **DataTables** | Sortable, searchable tables |
| **Auth Pages** | Sign in, sign up, reset password |
| **Icons** | Feather Icons (via data attributes) |
| **Dark Sidebar** | Default dark sidebar with light content |

## Rules Integration
- **UI/UX**: Customize SCSS variables for brand, upgrade Feather Icons with transitions
- **Accessibility**: Add `aria-label` to sidebar toggle, ensure keyboard navigation works
- **Dependencies**: Bootstrap 5, Chart.js, Feather Icons, jsvectormap
