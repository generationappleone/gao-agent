---
name: Focus Admin
description: Skill for building admin dashboards with Focus Admin, a Bootstrap-based admin template with modern chart integrations, form components, and responsive layout.
---

# Focus Admin Skill

## Overview
Focus Admin is a free Bootstrap admin dashboard template featuring a focused, clean UI with comprehensive chart integrations, form elements, and data table components. Suitable for analytics-heavy admin panels.

## Installation
```bash
git clone https://github.com/niceSoftware/FocusAdmin.git
cd FocusAdmin
npm install
npm start
# Or open index.html directly for static version
```

## Project Structure
```
FocusAdmin/
├── assets/
│   ├── css/
│   │   ├── style.css          # Main stylesheet
│   │   └── responsive.css     # Media queries
│   ├── js/
│   │   ├── chart-init.js      # Chart.js / Morris.js initializations
│   │   ├── datatable-init.js  # DataTable configurations
│   │   └── custom.js          # Custom logic
│   ├── images/
│   └── plugins/               # Third-party (Chart.js, Morris, DataTables)
├── pages/
│   ├── charts/                # Chart variations
│   ├── forms/                 # Input, validation, file upload, wizard
│   ├── tables/                # Basic, DataTable, responsive
│   ├── auth/                  # Login, register, lock screen
│   ├── email/                 # Inbox, compose
│   └── ui/                    # UI elements (alerts, badges, cards)
└── index.html                 # Main dashboard
```

## Page Layout
```html
<body>
  <div id="wrapper">
    <!-- Sidebar -->
    <div class="sidebar">
      <div class="logo-details">
        <span class="logo-name">FocusAdmin</span>
      </div>
      <ul class="nav-links">
        <li class="active">
          <a href="index.html">
            <i class="bx bx-grid-alt"></i>
            <span class="link-name">Dashboard</span>
          </a>
        </li>
        <li>
          <div class="icon-link">
            <a href="#">
              <i class="bx bx-collection"></i>
              <span class="link-name">Category</span>
            </a>
            <i class="bx bxs-chevron-down arrow"></i>
          </div>
          <ul class="sub-menu">
            <li><a href="#">Sub Item 1</a></li>
            <li><a href="#">Sub Item 2</a></li>
          </ul>
        </li>
      </ul>
    </div>

    <!-- Main content -->
    <section class="home-section">
      <div class="home-content">
        <i class="bx bx-menu sidebar-toggle"></i>
        <span class="text">Dashboard</span>
      </div>

      <!-- Dashboard widgets -->
      <div class="container-fluid">
        <div class="row">
          <div class="col-xl-3 col-md-6">
            <div class="card stat-card primary-gradient">
              <div class="card-body">
                <div class="d-flex justify-content-between">
                  <div>
                    <p class="mb-0 text-white-50">Total Revenue</p>
                    <h3 class="text-white">$45,000</h3>
                  </div>
                  <div class="icon-box"><i class="bx bx-dollar-circle"></i></div>
                </div>
                <span class="badge bg-white bg-opacity-25 mt-2">+12.5% ↑</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Charts section -->
        <div class="row mt-4">
          <div class="col-xl-8">
            <div class="card">
              <div class="card-header"><h5>Revenue Analytics</h5></div>
              <div class="card-body">
                <canvas id="revenueChart"></canvas>
              </div>
            </div>
          </div>
          <div class="col-xl-4">
            <div class="card">
              <div class="card-header"><h5>Traffic Sources</h5></div>
              <div class="card-body">
                <canvas id="trafficChart"></canvas>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</body>
```

## Chart Integration
```javascript
// Chart.js — Revenue Analytics
const revenueCtx = document.getElementById('revenueChart').getContext('2d');
new Chart(revenueCtx, {
  type: 'line',
  data: {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [{
      label: 'Revenue',
      data: [12000, 19000, 15000, 25000, 22000, 30000],
      borderColor: '#6366f1',
      backgroundColor: 'rgba(99, 102, 241, 0.1)',
      fill: true,
      tension: 0.4,
      borderWidth: 2,
    }],
  },
  options: {
    responsive: true,
    plugins: { legend: { display: false } },
    scales: { y: { beginAtZero: true } },
  },
});
```

## Design Characteristics
- **Gradient stat cards** with icon boxes
- **Boxicons** icon library
- **Chart-focused** dashboard (Chart.js, Morris.js)
- **Collapsible sidebar** with smooth transitions
- **DataTables** for sortable, searchable tables

## Customization
```css
:root {
  --primary: #6366f1;
  --sidebar-bg: #11101d;
  --sidebar-width: 260px;
  --sidebar-collapsed: 78px;
}

.primary-gradient {
  background: linear-gradient(135deg, var(--primary), #8b5cf6) !important;
}
```

## Rules Integration
- **UI/UX**: Leverage Chart.js for interactive, animated data visualizations
- **Accessibility**: Ensure charts have `aria-label`, provide data tables as fallback
- **Dependencies**: Bootstrap, Chart.js, Morris.js, Boxicons, DataTables, jQuery
