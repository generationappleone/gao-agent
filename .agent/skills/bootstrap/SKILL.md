---
name: Bootstrap
description: Skill for building responsive web interfaces with Bootstrap 5, covering grid system, components, utilities, customization with Sass, and accessibility best practices.
---

# Bootstrap Skill

## Overview
Bootstrap 5 is a popular CSS framework for building responsive, mobile-first web interfaces. It provides a 12-column grid system, utility classes, components (navbar, cards, modals, tables, forms), JavaScript plugins, and Sass customization.

**References**:
- [Bootstrap Documentation](https://getbootstrap.com/docs/)
- [Bootstrap Examples](https://getbootstrap.com/docs/5.3/examples/)

---

## Setup

```html
<!-- CDN -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3/dist/js/bootstrap.bundle.min.js"></script>
```

```bash
# npm
npm install bootstrap @popperjs/core
```

---

## Grid System

```html
<div class="container">
  <div class="row g-4">
    <div class="col-12 col-sm-6 col-lg-3">
      <div class="card">...</div>
    </div>
    <div class="col-12 col-sm-6 col-lg-3">
      <div class="card">...</div>
    </div>
    <div class="col-12 col-sm-6 col-lg-3">
      <div class="card">...</div>
    </div>
    <div class="col-12 col-sm-6 col-lg-3">
      <div class="card">...</div>
    </div>
  </div>
</div>
```

---

## Dashboard Layout

```html
<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">MyApp</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link active" href="#">Dashboard</a></li>
        <li class="nav-item"><a class="nav-link" href="#">Products</a></li>
        <li class="nav-item"><a class="nav-link" href="#">Orders</a></li>
      </ul>
    </div>
  </div>
</nav>

<!-- Stats Cards -->
<div class="container-fluid mt-4">
  <div class="row g-3">
    <div class="col-sm-6 col-xl-3">
      <div class="card border-0 shadow-sm">
        <div class="card-body">
          <div class="d-flex justify-content-between">
            <div>
              <p class="text-muted small mb-1">Revenue</p>
              <h4 class="fw-bold">$45,231</h4>
            </div>
            <div class="bg-primary bg-opacity-10 rounded-3 p-3">
              <i class="bi bi-currency-dollar text-primary fs-4"></i>
            </div>
          </div>
          <small class="text-success"><i class="bi bi-arrow-up"></i> 20.1% vs last month</small>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Data Table -->
<div class="card mt-4">
  <div class="card-body">
    <table class="table table-hover">
      <thead class="table-light">
        <tr><th>Product</th><th>Category</th><th>Price</th><th>Status</th><th>Actions</th></tr>
      </thead>
      <tbody>
        <tr>
          <td class="fw-semibold">Product Name</td>
          <td>Electronics</td>
          <td>$99.00</td>
          <td><span class="badge bg-success">Active</span></td>
          <td>
            <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
            <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<!-- Modal -->
<div class="modal fade" id="productModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Create Product</h5></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label">Name</label><input class="form-control" required></div>
        <div class="mb-3"><label class="form-label">Price</label><input type="number" class="form-control"></div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary">Create</button>
      </div>
    </div>
  </div>
</div>
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Mobile-first** | Design for mobile, then enhance for larger |
| **Grid** | Use 12-column grid with responsive breakpoints |
| **Utilities** | Use utility classes (d-flex, p-3, mb-4, fw-bold) |
| **Components** | Cards, modals, badges, tables, navbars |
| **Icons** | Bootstrap Icons library |
| **Sass** | Customize with Sass variables |
| **Accessibility** | Use aria-labels, semantic HTML |
| **Bundle** | Include bootstrap.bundle.min.js for JS plugins |
| **Dark mode** | Use `data-bs-theme="dark"` attribute |
| **Spacing** | Consistent spacing with m-*/p-* utilities |

---

## Rules Integration
- **Layout**: Grid system with responsive columns
- **Components**: Cards, tables, modals, navbars, badges
- **Utilities**: Flex, spacing, typography, colors
- **Responsive**: Mobile-first with breakpoints
