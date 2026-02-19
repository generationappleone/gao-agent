---
name: AdminLTE
description: Skill for building admin panels with AdminLTE, a Bootstrap-based admin dashboard template, covering layout structure, plugins, widgets, and customization.
---

# AdminLTE Skill

## Overview
AdminLTE is one of the most popular open-source admin dashboard templates, built on Bootstrap 5. It includes 100+ widgets, plugins, and pre-built pages. Use for traditional server-rendered admin panels (Laravel, Django, ASP.NET) or SPAs.

## Installation

### npm
```bash
npm install admin-lte@4.0.0-beta3  # v4 (Bootstrap 5)
# or
npm install admin-lte@3.2.0        # v3 (Bootstrap 4, stable)
```

### CDN
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css">
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
```

## Page Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Admin Dashboard</title>
  <link rel="stylesheet" href="plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="dist/css/adminlte.min.css">
</head>
<body class="hold-transition sidebar-mini layout-fixed">
  <div class="wrapper">

    <!-- Navbar -->
    <nav class="main-header navbar navbar-expand navbar-white navbar-light">
      <ul class="navbar-nav">
        <li class="nav-item">
          <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
        </li>
      </ul>
      <ul class="navbar-nav ml-auto">
        <li class="nav-item"><a class="nav-link" href="#"><i class="fas fa-bell"></i></a></li>
      </ul>
    </nav>

    <!-- Sidebar -->
    <aside class="main-sidebar sidebar-dark-primary elevation-4">
      <a href="#" class="brand-link">
        <span class="brand-text font-weight-bold">AdminPanel</span>
      </a>
      <div class="sidebar">
        <nav class="mt-2">
          <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu">
            <li class="nav-item">
              <a href="#" class="nav-link active">
                <i class="nav-icon fas fa-tachometer-alt"></i>
                <p>Dashboard</p>
              </a>
            </li>
            <li class="nav-item has-treeview">
              <a href="#" class="nav-link">
                <i class="nav-icon fas fa-users"></i>
                <p>Users <i class="right fas fa-angle-left"></i></p>
              </a>
              <ul class="nav nav-treeview">
                <li class="nav-item"><a href="#" class="nav-link"><p>All Users</p></a></li>
                <li class="nav-item"><a href="#" class="nav-link"><p>Add User</p></a></li>
              </ul>
            </li>
          </ul>
        </nav>
      </div>
    </aside>

    <!-- Content -->
    <div class="content-wrapper">
      <div class="content-header">
        <div class="container-fluid">
          <h1 class="m-0">Dashboard</h1>
        </div>
      </div>
      <section class="content">
        <div class="container-fluid">
          <!-- Stat boxes -->
          <div class="row">
            <div class="col-lg-3 col-6">
              <div class="small-box bg-info">
                <div class="inner"><h3>150</h3><p>New Orders</p></div>
                <div class="icon"><i class="fas fa-shopping-cart"></i></div>
                <a href="#" class="small-box-footer">More info <i class="fas fa-arrow-circle-right"></i></a>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>

    <footer class="main-footer">
      <strong>&copy; 2026 MyApp.</strong>
    </footer>
  </div>

  <script src="plugins/jquery/jquery.min.js"></script>
  <script src="plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
  <script src="dist/js/adminlte.min.js"></script>
</body>
</html>
```

## Key Widgets
| Widget | Usage |
|--------|-------|
| **Small Box** | Stat cards with icon (`.small-box`) |
| **Info Box** | Horizontal stat with icon (`.info-box`) |
| **Card** | Content container (`.card .card-outline`) |
| **Timeline** | Activity timeline (`.timeline`) |
| **Direct Chat** | Chat widget (`.direct-chat`) |
| **DataTables** | Sortable, searchable tables (plugin) |

## Customization
```css
/* Override AdminLTE variables */
:root {
  --primary: #6366f1;
  --sidebar-bg: #1e293b;
}

.main-sidebar { background-color: var(--sidebar-bg) !important; }
.btn-primary { background-color: var(--primary) !important; border-color: var(--primary) !important; }
.small-box.bg-info { background-color: var(--primary) !important; }
```

## Rules Integration
- **UI/UX**: Customize brand colors, add transitions to widgets for modern feel
- **Accessibility**: Ensure sidebar `role="menu"`, ARIA labels on icon-only buttons
- **Dependencies**: Depends on jQuery (v3), Bootstrap (v4 or v5 depending on version)
