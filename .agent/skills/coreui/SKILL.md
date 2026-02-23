---
name: CoreUI
description: Skill for building admin dashboards and enterprise web applications with CoreUI for React.js — covering installation, 90+ Bootstrap 5 components, admin template setup, layout architecture, sidebar navigation, theming, SCSS customization, forms, tables, charts, modals, dark mode, PRO components, and integration patterns.
---

# CoreUI for React.js Skill

## Overview

CoreUI for React is a production-ready UI Component Library built on **Bootstrap 5** and **TypeScript**. It provides **90+ components** designed specifically for building admin dashboards, control panels, and enterprise web applications with React.js.

### Key Differentiators

| Feature | CoreUI Free | CoreUI PRO |
|---------|-------------|------------|
| Components | 50+ | 90+ |
| Admin Template | ✅ Free template | ✅ Advanced dashboards |
| TypeScript | ✅ Full support | ✅ Full support |
| Bootstrap 5 | ✅ Compatible | ✅ Extended |
| React 19 | ✅ Supported | ✅ Supported |
| Smart Table | ❌ | ✅ Sorting, filtering, pagination |
| Date/Time Pickers | ❌ | ✅ DatePicker, TimePicker, DateRangePicker |
| Multi-Select | ❌ | ✅ Advanced multi-select |
| License | MIT | Commercial |

### Version Info
- **@coreui/react**: v5.8+ (Free) / v5.23+ (PRO)
- **@coreui/coreui**: v5.x (CSS library)
- **React**: 18.x / 19.x supported
- **Bootstrap**: 5.x compatible
- **Docs**: https://coreui.io/react/docs/

---

## 1. Installation

### 1.1 Component Library (Into Existing Project)

Install CoreUI component library into an existing React project:

```bash
# Free version
npm install @coreui/react @coreui/coreui @coreui/icons @coreui/icons-react

# PRO version (requires license)
npm install @coreui/react-pro @coreui/coreui-pro @coreui/icons @coreui/icons-react
```

#### Import CSS — WAJIB

```tsx
// src/index.tsx or src/main.tsx — pilih SALAH SATU:

// Option A: CoreUI CSS (recommended — includes Bootstrap + CoreUI extensions)
import '@coreui/coreui/dist/css/coreui.min.css';

// Option B: Bootstrap CSS only (hanya Bootstrap, tanpa CoreUI-specific components)
// import 'bootstrap/dist/css/bootstrap.min.css';

// PRO version
// import '@coreui/coreui-pro/dist/css/coreui.min.css';
```

> ⚠️ **PENTING:** Jangan import keduanya sekaligus (CoreUI CSS + Bootstrap CSS). Pilih salah satu. CoreUI CSS sudah includes semua Bootstrap styles.

### 1.2 Admin Template (New Project)

Clone the pre-built admin dashboard template:

```bash
# Clone template
git clone https://github.com/coreui/coreui-free-react-admin-template.git
cd coreui-free-react-admin-template

# Install dependencies
npm install

# Start development server
npm start
# → Dev server at http://localhost:3000

# Build for production
npm run build
# → Output in build/ directory
```

---

## 2. Admin Template Project Structure

```
coreui-free-react-admin-template/
├── public/
│   ├── favicon.ico
│   └── manifest.json
├── src/
│   ├── assets/               ← Images, icons, static files
│   ├── components/            ← Shared UI components
│   │   ├── header/            ← AppHeader component
│   │   │   ├── AppHeaderDropdown.js
│   │   │   └── index.js
│   │   ├── AppBreadcrumb.js
│   │   ├── AppContent.js      ← Main content wrapper with <Suspense>
│   │   ├── AppFooter.js
│   │   ├── AppHeader.js       ← Top navigation bar
│   │   └── AppSidebar.js      ← Left sidebar with navigation
│   ├── layouts/               ← Layout containers
│   │   └── DefaultLayout.js   ← Main layout (sidebar + header + content)
│   ├── scss/                  ← SCSS styles & customization
│   │   ├── _custom.scss       ← Your custom overrides HERE
│   │   ├── _variables.scss    ← Theme variable overrides HERE
│   │   └── style.scss         ← Main entry SCSS file
│   ├── views/                 ← Page components (grouped by feature)
│   │   ├── dashboard/
│   │   │   └── Dashboard.js
│   │   ├── pages/             ← Auth pages (Login, Register, 404, 500)
│   │   ├── base/              ← Base component demos
│   │   ├── buttons/           ← Button demos
│   │   ├── forms/             ← Form demos
│   │   ├── icons/             ← Icon demos
│   │   ├── notifications/     ← Toast, Modal, Alert demos
│   │   └── widgets/           ← Widget demos
│   ├── _nav.js                ← Sidebar navigation configuration
│   ├── App.js                 ← Root component with Router
│   ├── index.js               ← Entry point
│   ├── routes.js              ← Route definitions
│   └── store.js               ← Redux store (sidebar state)
├── index.html
├── package.json
└── vite.config.mjs            ← Vite bundler config
```

---

## 3. Layout Architecture

### 3.1 DefaultLayout — Struktur Utama

```tsx
// src/layouts/DefaultLayout.tsx
import React from 'react';
import { AppContent, AppSidebar, AppFooter, AppHeader } from '../components/index';

const DefaultLayout: React.FC = () => {
  return (
    <div>
      {/* Sidebar — fixed left */}
      <AppSidebar />

      {/* Wrapper untuk content area */}
      <div className="wrapper d-flex flex-column min-vh-100">
        {/* Header — fixed top */}
        <AppHeader />

        {/* Main content area */}
        <div className="body flex-grow-1">
          <AppContent />
        </div>

        {/* Footer */}
        <AppFooter />
      </div>
    </div>
  );
};

export default DefaultLayout;
```

### 3.2 Sidebar Component

```tsx
// src/components/AppSidebar.tsx
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  CSidebar,
  CSidebarBrand,
  CSidebarHeader,
  CSidebarNav,
  CSidebarFooter,
  CSidebarToggler,
} from '@coreui/react';
import { AppSidebarNav } from './AppSidebarNav';
import navigation from '../_nav'; // Sidebar nav items

const AppSidebar: React.FC = () => {
  const dispatch = useDispatch();
  const unfoldable = useSelector((state: any) => state.sidebarUnfoldable);
  const sidebarShow = useSelector((state: any) => state.sidebarShow);

  return (
    <CSidebar
      className="border-end"
      colorScheme="dark"
      position="fixed"
      unfoldable={unfoldable}
      visible={sidebarShow}
      onVisibleChange={(visible) => {
        dispatch({ type: 'set', sidebarShow: visible });
      }}
    >
      <CSidebarHeader className="border-bottom">
        <CSidebarBrand>My App</CSidebarBrand>
      </CSidebarHeader>

      <CSidebarNav>
        <AppSidebarNav items={navigation} />
      </CSidebarNav>

      <CSidebarFooter className="border-top d-none d-lg-flex">
        <CSidebarToggler
          onClick={() =>
            dispatch({ type: 'set', sidebarUnfoldable: !unfoldable })
          }
        />
      </CSidebarFooter>
    </CSidebar>
  );
};

export default React.memo(AppSidebar);
```

### 3.3 Navigation Configuration

```tsx
// src/_nav.tsx — Definisi item navigasi sidebar
import React from 'react';
import CIcon from '@coreui/icons-react';
import {
  cilSpeedometer,
  cilPuzzle,
  cilNotes,
  cilStar,
  cilBell,
  cilCalculator,
  cilChartPie,
  cilPeople,
  cilSettings,
} from '@coreui/icons';
import { CNavGroup, CNavItem, CNavTitle } from '@coreui/react';

const _nav = [
  // Simple link — satu level
  {
    component: CNavItem,
    name: 'Dashboard',
    to: '/dashboard',
    icon: <CIcon icon={cilSpeedometer} customClassName="nav-icon" />,
    badge: {
      color: 'info',
      text: 'NEW',
    },
  },
  // Section divider
  {
    component: CNavTitle,
    name: 'Management',
  },
  // Nested group — dropdown
  {
    component: CNavGroup,
    name: 'Users',
    to: '/users',
    icon: <CIcon icon={cilPeople} customClassName="nav-icon" />,
    items: [
      {
        component: CNavItem,
        name: 'All Users',
        to: '/users/list',
      },
      {
        component: CNavItem,
        name: 'Add User',
        to: '/users/create',
      },
      {
        component: CNavItem,
        name: 'Roles & Permissions',
        to: '/users/roles',
      },
    ],
  },
  // Another group
  {
    component: CNavGroup,
    name: 'Settings',
    icon: <CIcon icon={cilSettings} customClassName="nav-icon" />,
    items: [
      {
        component: CNavItem,
        name: 'General',
        to: '/settings/general',
      },
      {
        component: CNavItem,
        name: 'Security',
        to: '/settings/security',
      },
    ],
  },
];

export default _nav;
```

### 3.4 Route Configuration

```tsx
// src/routes.tsx
import React from 'react';

const Dashboard = React.lazy(() => import('./views/dashboard/Dashboard'));
const UserList = React.lazy(() => import('./views/users/UserList'));
const UserCreate = React.lazy(() => import('./views/users/UserCreate'));
const Settings = React.lazy(() => import('./views/settings/Settings'));

const routes = [
  { path: '/', exact: true, name: 'Home' },
  { path: '/dashboard', name: 'Dashboard', element: Dashboard },
  { path: '/users/list', name: 'Users', element: UserList },
  { path: '/users/create', name: 'Add User', element: UserCreate },
  { path: '/settings/general', name: 'General Settings', element: Settings },
];

export default routes;
```

### 3.5 AppContent with Suspense

```tsx
// src/components/AppContent.tsx
import React, { Suspense } from 'react';
import { Navigate, Route, Routes } from 'react-router-dom';
import { CContainer, CSpinner } from '@coreui/react';
import routes from '../routes';

const AppContent: React.FC = () => {
  return (
    <CContainer className="px-4" lg>
      <Suspense fallback={<CSpinner color="primary" />}>
        <Routes>
          {routes.map((route, idx) => {
            return (
              route.element && (
                <Route
                  key={idx}
                  path={route.path}
                  exact={route.exact}
                  name={route.name}
                  element={<route.element />}
                />
              )
            );
          })}
          <Route path="/" element={<Navigate to="dashboard" replace />} />
        </Routes>
      </Suspense>
    </CContainer>
  );
};

export default React.memo(AppContent);
```

---

## 4. Core Components Reference

### 4.1 Buttons

```tsx
import { CButton, CButtonGroup } from '@coreui/react';

// Color variants
<CButton color="primary">Primary</CButton>
<CButton color="secondary">Secondary</CButton>
<CButton color="success">Success</CButton>
<CButton color="danger">Danger</CButton>
<CButton color="warning">Warning</CButton>
<CButton color="info">Info</CButton>
<CButton color="dark">Dark</CButton>
<CButton color="light">Light</CButton>

// Variant styles
<CButton color="primary" variant="outline">Outline</CButton>
<CButton color="primary" variant="ghost">Ghost</CButton>

// Sizes
<CButton color="primary" size="lg">Large</CButton>
<CButton color="primary" size="sm">Small</CButton>

// States
<CButton color="primary" disabled>Disabled</CButton>
<CButton color="primary" active>Active</CButton>

// Shapes
<CButton color="primary" shape="rounded-pill">Pill</CButton>
<CButton color="primary" shape="rounded-0">Square</CButton>

// As link
<CButton color="primary" href="https://example.com">Link</CButton>

// Button Group
<CButtonGroup role="group">
  <CButton color="primary">Left</CButton>
  <CButton color="primary">Middle</CButton>
  <CButton color="primary">Right</CButton>
</CButtonGroup>

// Loading button (PRO only)
<CLoadingButton color="primary" loading={isLoading} onClick={handleSubmit}>
  Save Changes
</CLoadingButton>
```

### 4.2 Cards

```tsx
import {
  CCard, CCardBody, CCardHeader, CCardFooter,
  CCardTitle, CCardText, CCardSubtitle, CCardImage, CCardLink,
  CCardGroup, CCol, CRow,
} from '@coreui/react';

// Basic Card
<CCard>
  <CCardHeader>Featured</CCardHeader>
  <CCardBody>
    <CCardTitle>Card Title</CCardTitle>
    <CCardSubtitle className="mb-2 text-body-secondary">Subtitle</CCardSubtitle>
    <CCardText>Some quick example text.</CCardText>
    <CCardLink href="#">Card link</CCardLink>
  </CCardBody>
  <CCardFooter className="text-body-secondary">2 days ago</CCardFooter>
</CCard>

// Colored Card
<CCard color="primary" textColor="white">
  <CCardBody>
    <CCardTitle>Primary card</CCardTitle>
    <CCardText>Primary colored card with white text.</CCardText>
  </CCardBody>
</CCard>

// Card with Image
<CCard style={{ width: '18rem' }}>
  <CCardImage orientation="top" src="/images/react.jpg" />
  <CCardBody>
    <CCardTitle>Card title</CCardTitle>
    <CCardText>Some text content here.</CCardText>
    <CButton color="primary">Go somewhere</CButton>
  </CCardBody>
</CCard>

// Card Group (equal height)
<CCardGroup>
  <CCard>...</CCard>
  <CCard>...</CCard>
  <CCard>...</CCard>
</CCardGroup>

// Accent border card
<CCard accentColor="primary">
  <CCardBody>Accented card with primary border top.</CCardBody>
</CCard>
```

### 4.3 Modal

```tsx
import {
  CModal, CModalHeader, CModalTitle, CModalBody, CModalFooter, CButton,
} from '@coreui/react';

const [visible, setVisible] = useState(false);

// Basic Modal
<CButton color="primary" onClick={() => setVisible(true)}>
  Open Modal
</CButton>
<CModal
  visible={visible}
  onClose={() => setVisible(false)}
  backdrop="static"    // 'static' = klik luar tidak tutup
  keyboard={false}     // ESC tidak tutup
>
  <CModalHeader>
    <CModalTitle>Confirm Action</CModalTitle>
  </CModalHeader>
  <CModalBody>
    Are you sure you want to delete this item?
  </CModalBody>
  <CModalFooter>
    <CButton color="secondary" onClick={() => setVisible(false)}>Cancel</CButton>
    <CButton color="danger" onClick={handleDelete}>Delete</CButton>
  </CModalFooter>
</CModal>

// Size options: size="sm" | "lg" | "xl"
<CModal size="lg" visible={visible} onClose={() => setVisible(false)}>...</CModal>

// Fullscreen: fullscreen={true | 'sm' | 'md' | 'lg' | 'xl' | 'xxl'}
<CModal fullscreen visible={visible} onClose={() => setVisible(false)}>...</CModal>

// Scrollable body
<CModal scrollable visible={visible} onClose={() => setVisible(false)}>...</CModal>

// Vertically centered
<CModal alignment="center" visible={visible} onClose={() => setVisible(false)}>...</CModal>
```

### 4.4 Alert & Toast

```tsx
import { CAlert, CToast, CToastBody, CToastHeader, CToaster, CToastClose } from '@coreui/react';

// Alert
<CAlert color="success" dismissible>
  <strong>Success!</strong> Operation completed successfully.
</CAlert>
<CAlert color="danger">Error: something went wrong.</CAlert>
<CAlert color="warning">Warning: check your input.</CAlert>
<CAlert color="info">Info: new version available.</CAlert>

// Toast (notifications)
const [toast, addToast] = useState<ReactElement | null>(null);
const toaster = useRef<HTMLDivElement>(null);

const showToast = () => {
  addToast(
    <CToast autohide={true} delay={5000}>
      <CToastHeader closeButton>
        <strong className="me-auto">Notification</strong>
        <small>Just now</small>
      </CToastHeader>
      <CToastBody>This is a success notification.</CToastBody>
    </CToast>
  );
};

<CToaster ref={toaster} placement="top-end" push={toast} />
```

### 4.5 Table

```tsx
import { CTable, CTableBody, CTableHead, CTableRow, CTableHeaderCell, CTableDataCell } from '@coreui/react';

// Method 1: Manual Table Structure
<CTable hover bordered striped responsive>
  <CTableHead color="dark">
    <CTableRow>
      <CTableHeaderCell scope="col">#</CTableHeaderCell>
      <CTableHeaderCell scope="col">Name</CTableHeaderCell>
      <CTableHeaderCell scope="col">Email</CTableHeaderCell>
      <CTableHeaderCell scope="col">Status</CTableHeaderCell>
      <CTableHeaderCell scope="col">Actions</CTableHeaderCell>
    </CTableRow>
  </CTableHead>
  <CTableBody>
    {users.map((user, index) => (
      <CTableRow key={user.id} active={user.selected}>
        <CTableDataCell>{index + 1}</CTableDataCell>
        <CTableDataCell>{user.name}</CTableDataCell>
        <CTableDataCell>{user.email}</CTableDataCell>
        <CTableDataCell>
          <CBadge color={user.status === 'Active' ? 'success' : 'danger'}>
            {user.status}
          </CBadge>
        </CTableDataCell>
        <CTableDataCell>
          <CButton color="info" size="sm" onClick={() => handleEdit(user.id)}>Edit</CButton>{' '}
          <CButton color="danger" size="sm" onClick={() => handleDelete(user.id)}>Delete</CButton>
        </CTableDataCell>
      </CTableRow>
    ))}
  </CTableBody>
</CTable>

// Method 2: Shorthand API (columns + items)
<CTable
  columns={[
    { key: 'name', label: 'Name', _style: { width: '30%' } },
    { key: 'email', label: 'Email' },
    { key: 'status', label: 'Status' },
    { key: 'actions', label: 'Actions', filter: false, sorter: false },
  ]}
  items={users}
  hover
  striped
/>

// Smart Table (PRO only) — built-in sorting, filtering, pagination
<CSmartTable
  columns={columns}
  items={users}
  columnFilter
  columnSorter
  pagination
  tableFilter
  itemsPerPage={10}
  itemsPerPageSelect
  selectable
  scopedColumns={{
    status: (item) => (
      <td>
        <CBadge color={item.status === 'Active' ? 'success' : 'danger'}>
          {item.status}
        </CBadge>
      </td>
    ),
    actions: (item) => (
      <td>
        <CButton color="info" size="sm">Edit</CButton>
      </td>
    ),
  }}
/>
```

### 4.6 Sidebar & Navigation

```tsx
import {
  CSidebar, CSidebarBrand, CSidebarHeader, CSidebarNav, CSidebarFooter,
  CSidebarToggler, CNavItem, CNavGroup, CNavTitle,
} from '@coreui/react';

<CSidebar
  colorScheme="dark"       // 'dark' | 'light'
  position="fixed"         // 'fixed' | 'sticky'
  unfoldable={false}       // Minimize ke icon-only
  visible={sidebarShow}    // Kontrol visibility
  onVisibleChange={(val) => setSidebarShow(val)}
>
  <CSidebarHeader className="border-bottom">
    <CSidebarBrand>
      <img src="/logo.svg" height={32} alt="Logo" />
    </CSidebarBrand>
  </CSidebarHeader>

  <CSidebarNav>
    {/* Section title */}
    <CNavTitle>Main Menu</CNavTitle>

    {/* Simple nav item */}
    <CNavItem href="/dashboard">
      <CIcon icon={cilSpeedometer} customClassName="nav-icon" />
      Dashboard
    </CNavItem>

    {/* Nested nav group */}
    <CNavGroup toggler="Users">
      <CNavItem href="/users/list">All Users</CNavItem>
      <CNavItem href="/users/create">Add User</CNavItem>
    </CNavGroup>
  </CSidebarNav>

  <CSidebarFooter className="border-top d-none d-lg-flex">
    <CSidebarToggler />
  </CSidebarFooter>
</CSidebar>
```

### 4.7 Navbar (Top Header)

```tsx
import {
  CContainer, CHeader, CHeaderBrand, CHeaderNav, CHeaderToggler,
  CNavItem, CNavLink, CDropdown, CDropdownToggle, CDropdownMenu,
  CDropdownItem, CDropdownDivider, CAvatar,
} from '@coreui/react';

<CHeader position="sticky" className="mb-4 p-0">
  <CContainer className="border-bottom px-4" fluid>
    <CHeaderToggler
      onClick={() => dispatch({ type: 'set', sidebarShow: !sidebarShow })}
    />
    <CHeaderBrand className="d-md-none">App Name</CHeaderBrand>

    <CHeaderNav className="d-none d-md-flex">
      <CNavItem>
        <CNavLink href="/dashboard" active>Dashboard</CNavLink>
      </CNavItem>
      <CNavItem>
        <CNavLink href="/users">Users</CNavLink>
      </CNavItem>
    </CHeaderNav>

    <CHeaderNav className="ms-auto">
      {/* Notifications */}
      <CNavItem>
        <CNavLink href="#">
          <CIcon icon={cilBell} size="lg" />
          <CBadge color="danger" shape="rounded-pill" className="ms-1">3</CBadge>
        </CNavLink>
      </CNavItem>
    </CHeaderNav>

    <CHeaderNav>
      {/* User dropdown */}
      <CDropdown variant="nav-item" placement="bottom-end">
        <CDropdownToggle caret={false}>
          <CAvatar src="/avatars/user.jpg" size="md" />
        </CDropdownToggle>
        <CDropdownMenu>
          <CDropdownItem href="/profile">Profile</CDropdownItem>
          <CDropdownItem href="/settings">Settings</CDropdownItem>
          <CDropdownDivider />
          <CDropdownItem onClick={handleLogout}>Logout</CDropdownItem>
        </CDropdownMenu>
      </CDropdown>
    </CHeaderNav>
  </CContainer>

  {/* Breadcrumbs */}
  <CContainer className="px-4" fluid>
    <AppBreadcrumb />
  </CContainer>
</CHeader>
```

---

## 5. Forms

### 5.1 Form Controls

```tsx
import {
  CForm, CFormInput, CFormLabel, CFormTextarea, CFormSelect,
  CFormCheck, CFormSwitch, CFormFeedback, CFormText,
  CInputGroup, CInputGroupText, CButton,
  CCol, CRow,
} from '@coreui/react';

const [validated, setValidated] = useState(false);

const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
  const form = event.currentTarget;
  if (form.checkValidity() === false) {
    event.preventDefault();
    event.stopPropagation();
  }
  setValidated(true);
};

<CForm noValidate validated={validated} onSubmit={handleSubmit}>
  <CRow className="mb-3">
    <CCol md={6}>
      <CFormLabel htmlFor="name">Full Name</CFormLabel>
      <CFormInput
        type="text"
        id="name"
        placeholder="Enter full name"
        required
        feedbackInvalid="Please enter a name."
        feedbackValid="Looks good!"
      />
    </CCol>
    <CCol md={6}>
      <CFormLabel htmlFor="email">Email</CFormLabel>
      <CFormInput
        type="email"
        id="email"
        placeholder="name@example.com"
        required
      />
      <CFormText>We'll never share your email.</CFormText>
    </CCol>
  </CRow>

  <CRow className="mb-3">
    <CCol md={6}>
      <CFormLabel htmlFor="role">Role</CFormLabel>
      <CFormSelect id="role" required>
        <option value="">Choose...</option>
        <option value="admin">Admin</option>
        <option value="editor">Editor</option>
        <option value="viewer">Viewer</option>
      </CFormSelect>
    </CCol>
    <CCol md={6}>
      <CFormLabel htmlFor="bio">Bio</CFormLabel>
      <CFormTextarea id="bio" rows={3} placeholder="Tell us about yourself" />
    </CCol>
  </CRow>

  {/* Input Group */}
  <div className="mb-3">
    <CFormLabel>Price</CFormLabel>
    <CInputGroup>
      <CInputGroupText>$</CInputGroupText>
      <CFormInput type="number" placeholder="0.00" />
      <CInputGroupText>.00</CInputGroupText>
    </CInputGroup>
  </div>

  {/* Checkboxes */}
  <div className="mb-3">
    <CFormCheck id="agree" label="I agree to terms" required />
    <CFormCheck id="newsletter" label="Subscribe to newsletter" />
  </div>

  {/* Switch */}
  <div className="mb-3">
    <CFormSwitch id="active" label="Active status" defaultChecked />
  </div>

  {/* Floating Labels */}
  <div className="mb-3">
    <CFormInput type="text" id="floatingName" floatingLabel="Full Name" placeholder="name" />
  </div>

  <CButton type="submit" color="primary">Submit</CButton>
</CForm>
```

### 5.2 Controlled Form Pattern

```tsx
interface UserForm {
  name: string;
  email: string;
  role: string;
  isActive: boolean;
}

const [form, setForm] = useState<UserForm>({
  name: '',
  email: '',
  role: '',
  isActive: true,
});

const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
  const { name, value, type } = e.target;
  setForm(prev => ({
    ...prev,
    [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value,
  }));
};

<CFormInput
  name="name"
  value={form.name}
  onChange={handleChange}
  label="Name"
  required
/>
<CFormSelect
  name="role"
  value={form.role}
  onChange={handleChange}
  label="Role"
>
  <option value="">Select role...</option>
  <option value="admin">Admin</option>
  <option value="user">User</option>
</CFormSelect>
<CFormSwitch
  name="isActive"
  checked={form.isActive}
  onChange={handleChange}
  label="Active"
/>
```

---

## 6. Theming & Customization

### 6.1 SCSS Variables Override

```scss
// src/scss/_variables.scss — Override SEMUA theme variables di sini

// Primary brand colors
$primary:       #6366f1;   // Indigo
$secondary:     #64748b;   // Slate
$success:       #10b981;   // Emerald
$danger:        #ef4444;   // Red
$warning:       #f59e0b;   // Amber
$info:          #06b6d4;   // Cyan
$dark:          #1e293b;   // Slate 800
$light:         #f8fafc;   // Slate 50

// Sidebar
$sidebar-bg:                 #1e293b;      // Dark sidebar
$sidebar-color:              #94a3b8;
$sidebar-brand-height:       64px;
$sidebar-brand-bg:           transparent;
$sidebar-nav-link-color:     rgba(255, 255, 255, 0.6);
$sidebar-nav-link-hover-bg:  rgba(255, 255, 255, 0.05);
$sidebar-nav-link-active-bg: rgba(99, 102, 241, 0.2);
$sidebar-nav-link-active-color: #fff;
$sidebar-nav-link-active-icon-color: $primary;
$sidebar-width:              256px;
$sidebar-narrow-width:       56px;

// Typography
$font-family-base:           'Inter', -apple-system, sans-serif;
$font-size-base:             0.9375rem;
$headings-font-weight:       600;

// Border radius
$border-radius:              0.5rem;
$border-radius-sm:           0.375rem;
$border-radius-lg:           0.75rem;

// Cards
$card-border-color:          rgba(0, 0, 0, 0.05);
$card-shadow:                0 1px 3px rgba(0, 0, 0, 0.06);

// Body
$body-bg:                    #f1f5f9;
$body-color:                 #334155;
```

### 6.2 Custom SCSS

```scss
// src/scss/_custom.scss — Custom styles SETELAH variables

// Custom sidebar styling
.sidebar {
  transition: all 0.3s ease;

  .nav-link {
    border-radius: 0.375rem;
    margin: 2px 8px;
    padding: 0.5rem 1rem;

    &.active {
      font-weight: 600;
    }
  }
}

// Card hover effect
.card {
  transition: box-shadow 0.2s ease, transform 0.2s ease;

  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    transform: translateY(-1px);
  }
}

// Dashboard stats card
.stats-card {
  .card-body {
    padding: 1.25rem;
  }

  .stats-value {
    font-size: 1.75rem;
    font-weight: 700;
    line-height: 1.2;
  }

  .stats-label {
    font-size: 0.8125rem;
    color: var(--cui-secondary-color);
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }
}
```

### 6.3 Main SCSS Entry

```scss
// src/scss/style.scss
// 1. Override variables first
@import 'variables';

// 2. Import CoreUI CSS
@import '@coreui/coreui/scss/coreui';
// PRO: @import '@coreui/coreui-pro/scss/coreui';

// 3. Add custom styles last
@import 'custom';
```

### 6.4 Dark Mode

CoreUI supports dark mode via the `data-coreui-theme` attribute:

```tsx
// Toggle dark mode
const [darkMode, setDarkMode] = useState(false);

useEffect(() => {
  document.body.setAttribute('data-coreui-theme', darkMode ? 'dark' : 'light');
}, [darkMode]);

// Toggle button
<CFormSwitch
  label="Dark Mode"
  checked={darkMode}
  onChange={() => setDarkMode(!darkMode)}
/>

// Auto-detect system preference
useEffect(() => {
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  setDarkMode(prefersDark);
}, []);
```

---

## 7. Charts & Data Visualization

CoreUI using `@coreui/react-chartjs` (wrapper for Chart.js):

```bash
npm install @coreui/react-chartjs chart.js
```

```tsx
import { CChart } from '@coreui/react-chartjs';

// Line Chart
<CChart
  type="line"
  data={{
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [
      {
        label: 'Revenue',
        backgroundColor: 'rgba(99, 102, 241, 0.1)',
        borderColor: '#6366f1',
        pointBackgroundColor: '#6366f1',
        data: [65, 59, 80, 81, 56, 55],
        fill: true,
        tension: 0.4,
      },
    ],
  }}
  options={{
    responsive: true,
    plugins: {
      legend: { display: true, position: 'top' },
      tooltip: { mode: 'index', intersect: false },
    },
    scales: {
      y: { beginAtZero: true },
    },
  }}
/>

// Bar Chart
<CChart
  type="bar"
  data={{
    labels: ['Q1', 'Q2', 'Q3', 'Q4'],
    datasets: [
      {
        label: 'Sales',
        backgroundColor: '#6366f1',
        data: [40, 20, 12, 39],
        borderRadius: 4,
      },
      {
        label: 'Expenses',
        backgroundColor: '#ef4444',
        data: [10, 15, 20, 25],
        borderRadius: 4,
      },
    ],
  }}
/>

// Doughnut Chart
<CChart
  type="doughnut"
  data={{
    labels: ['Desktop', 'Mobile', 'Tablet'],
    datasets: [{
      backgroundColor: ['#6366f1', '#10b981', '#f59e0b'],
      data: [55, 35, 10],
    }],
  }}
/>
```

---

## 8. Icons

```bash
npm install @coreui/icons @coreui/icons-react
```

```tsx
import CIcon from '@coreui/icons-react';
import { cilUser, cilSettings, cilTrash, cilPencil, cilSearch } from '@coreui/icons';

// Basic usage
<CIcon icon={cilUser} />
<CIcon icon={cilSettings} size="xl" />
<CIcon icon={cilTrash} className="text-danger" />

// Sizes: 'sm' | 'md' | 'lg' | 'xl' | 'xxl' | '3xl' | custom
<CIcon icon={cilUser} size="lg" />
<CIcon icon={cilUser} height={32} />

// In buttons
<CButton color="primary">
  <CIcon icon={cilSearch} className="me-2" />
  Search
</CButton>
```

---

## 9. Grid & Layout Utilities

```tsx
import { CContainer, CRow, CCol } from '@coreui/react';

// Responsive grid
<CContainer fluid>
  <CRow>
    <CCol xs={12} sm={6} md={4} lg={3} xl={2}>
      Column content
    </CCol>
  </CRow>
</CContainer>

// Auto layout
<CRow xs={{ cols: 1 }} md={{ cols: 2 }} lg={{ cols: 4 }} className="g-4">
  <CCol><CCard>...</CCard></CCol>
  <CCol><CCard>...</CCard></CCol>
  <CCol><CCard>...</CCard></CCol>
  <CCol><CCard>...</CCard></CCol>
</CRow>

// Alignment
<CRow className="align-items-center justify-content-between">
  <CCol xs="auto">Left content</CCol>
  <CCol xs="auto">Right content</CCol>
</CRow>
```

---

## 10. Widget & Dashboard Patterns

### 10.1 Stats Widget

```tsx
import { CWidgetStatsA, CWidgetStatsB, CWidgetStatsC } from '@coreui/react';
import { CChart } from '@coreui/react-chartjs';

// Stats Widget A — with chart background
<CWidgetStatsA
  className="mb-4"
  color="primary"
  value={
    <>
      $26K{' '}
      <span className="fs-6 fw-normal">
        (+12.4% <CIcon icon={cilArrowTop} />)
      </span>
    </>
  }
  title="Revenue"
  chart={
    <CChart
      type="line"
      className="mt-3 mx-3"
      style={{ height: '70px' }}
      data={{
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
        datasets: [{
          backgroundColor: 'transparent',
          borderColor: 'rgba(255,255,255,.55)',
          pointBackgroundColor: '#fff',
          data: [65, 59, 84, 84, 51, 55, 40],
        }],
      }}
      options={{
        plugins: { legend: { display: false } },
        scales: { x: { display: false }, y: { display: false } },
        elements: { line: { borderWidth: 2, tension: 0.4 } },
      }}
    />
  }
/>

// Stats Widget B — simple value + progress bar
<CWidgetStatsB
  className="mb-4"
  progress={{ color: 'success', value: 75 }}
  text="Widget helper text"
  title="Active Users"
  value="12,345"
/>
```

### 10.2 Dashboard Example Page

```tsx
// src/views/dashboard/Dashboard.tsx
import React from 'react';
import {
  CCard, CCardBody, CCardHeader, CCol, CRow,
  CWidgetStatsA, CProgress,
} from '@coreui/react';
import { CChart } from '@coreui/react-chartjs';

const Dashboard: React.FC = () => {
  return (
    <>
      {/* Stats Cards Row */}
      <CRow className="mb-4">
        <CCol sm={6} xl={3}>
          <CWidgetStatsA
            color="primary"
            value="$9,823"
            title="Total Revenue"
            chart={/* ... mini chart ... */}
          />
        </CCol>
        <CCol sm={6} xl={3}>
          <CWidgetStatsA
            color="info"
            value="1,234"
            title="New Users"
            chart={/* ... mini chart ... */}
          />
        </CCol>
        <CCol sm={6} xl={3}>
          <CWidgetStatsA
            color="warning"
            value="456"
            title="Orders"
            chart={/* ... mini chart ... */}
          />
        </CCol>
        <CCol sm={6} xl={3}>
          <CWidgetStatsA
            color="danger"
            value="2.5%"
            title="Bounce Rate"
            chart={/* ... mini chart ... */}
          />
        </CCol>
      </CRow>

      {/* Charts Row */}
      <CRow>
        <CCol md={8}>
          <CCard className="mb-4">
            <CCardHeader>Traffic Overview</CCardHeader>
            <CCardBody>
              <CChart type="line" data={/* ... */} />
            </CCardBody>
          </CCard>
        </CCol>
        <CCol md={4}>
          <CCard className="mb-4">
            <CCardHeader>Traffic Sources</CCardHeader>
            <CCardBody>
              <CChart type="doughnut" data={/* ... */} />
            </CCardBody>
          </CCard>
        </CCol>
      </CRow>
    </>
  );
};
```

---

## 11. More Components Reference

### Accordion
```tsx
import { CAccordion, CAccordionItem, CAccordionHeader, CAccordionBody } from '@coreui/react';

<CAccordion activeItemKey={1} alwaysOpen>
  <CAccordionItem itemKey={1}>
    <CAccordionHeader>Section 1</CAccordionHeader>
    <CAccordionBody>Content for section 1.</CAccordionBody>
  </CAccordionItem>
  <CAccordionItem itemKey={2}>
    <CAccordionHeader>Section 2</CAccordionHeader>
    <CAccordionBody>Content for section 2.</CAccordionBody>
  </CAccordionItem>
</CAccordion>
```

### Badge
```tsx
import { CBadge } from '@coreui/react';

<CBadge color="primary">Primary</CBadge>
<CBadge color="success" shape="rounded-pill">Active</CBadge>
<CBadge color="danger" size="sm">3</CBadge>

// As button badge
<CButton color="primary">
  Notifications <CBadge color="secondary" className="ms-2">4</CBadge>
</CButton>
```

### Offcanvas (Slide Panel)
```tsx
import { COffcanvas, COffcanvasHeader, COffcanvasTitle, COffcanvasBody, CCloseButton } from '@coreui/react';

<COffcanvas placement="end" visible={visible} onHide={() => setVisible(false)}>
  <COffcanvasHeader>
    <COffcanvasTitle>Settings</COffcanvasTitle>
    <CCloseButton className="text-reset" onClick={() => setVisible(false)} />
  </COffcanvasHeader>
  <COffcanvasBody>
    Panel content here...
  </COffcanvasBody>
</COffcanvas>
```

### Pagination
```tsx
import { CPagination, CPaginationItem } from '@coreui/react';

<CPagination>
  <CPaginationItem disabled>Previous</CPaginationItem>
  <CPaginationItem active>1</CPaginationItem>
  <CPaginationItem>2</CPaginationItem>
  <CPaginationItem>3</CPaginationItem>
  <CPaginationItem>Next</CPaginationItem>
</CPagination>
```

### Spinner & Placeholder
```tsx
import { CSpinner, CPlaceholder } from '@coreui/react';

// Spinner
<CSpinner color="primary" />
<CSpinner color="primary" size="sm" />
<CSpinner color="primary" variant="grow" />

// Placeholder (skeleton loading)
<CPlaceholder xs={6} />
<CPlaceholder xs={8} animation="glow" />
<CPlaceholder xs={12} animation="wave" size="lg" />
```

### Popover & Tooltip
```tsx
import { CPopover, CTooltip, CButton } from '@coreui/react';

<CTooltip content="This is a tooltip" placement="top">
  <CButton color="primary">Hover me</CButton>
</CTooltip>

<CPopover title="Popover title" content="And here's some content." placement="right">
  <CButton color="secondary">Click me</CButton>
</CPopover>
```

### Avatar
```tsx
import { CAvatar } from '@coreui/react';

<CAvatar src="/avatars/1.jpg" size="xl" status="success" />
<CAvatar color="primary" textColor="white" size="md">CU</CAvatar>
<CAvatar src="/avatars/2.jpg" shape="rounded" />
```

### Progress
```tsx
import { CProgress, CProgressBar } from '@coreui/react';

<CProgress className="mb-3">
  <CProgressBar value={25} />
</CProgress>

<CProgress className="mb-3">
  <CProgressBar color="success" value={50}>50%</CProgressBar>
</CProgress>

// Stacked
<CProgress className="mb-3">
  <CProgressBar value={15} />
  <CProgressBar color="success" value={30} />
  <CProgressBar color="info" value={20} />
</CProgress>
```

### Breadcrumb
```tsx
import { CBreadcrumb, CBreadcrumbItem } from '@coreui/react';

<CBreadcrumb>
  <CBreadcrumbItem href="/">Home</CBreadcrumbItem>
  <CBreadcrumbItem href="/users">Users</CBreadcrumbItem>
  <CBreadcrumbItem active>John Doe</CBreadcrumbItem>
</CBreadcrumb>
```

---

## 12. PRO Components (Requires License)

| Component | Description |
|-----------|-------------|
| `CSmartTable` | Advanced table with sorting, filtering, pagination, selectable rows |
| `CDatePicker` | Date picker with i18n, range mode, disabled dates |
| `CDateRangePicker` | Dual calendar date range selection |
| `CTimePicker` | Time selection with AM/PM toggle |
| `CMultiSelect` | Multi-select dropdown with search |
| `CLoadingButton` | Button with built-in spinner state |
| `CSmartPagination` | Pagination with page size selection |
| `CRangeSlider` | Dual-thumb range slider |
| `CAutocomplete` | Input with typeahead suggestions |
| `COneTimePassword` | OTP input (6-digit code) |
| `CPasswordInput` | Password with visibility toggle |
| `CStepper` | Multi-step wizard/form |
| `CRating` | Star rating input |

---

## 13. Auth Pages Pattern

```tsx
// src/views/pages/Login.tsx
import React, { useState } from 'react';
import {
  CButton, CCard, CCardBody, CCardGroup, CCol, CContainer,
  CForm, CFormInput, CInputGroup, CInputGroupText, CRow,
} from '@coreui/react';
import CIcon from '@coreui/icons-react';
import { cilLockLocked, cilUser } from '@coreui/icons';

const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <div className="bg-body-tertiary min-vh-100 d-flex flex-row align-items-center">
      <CContainer>
        <CRow className="justify-content-center">
          <CCol md={8}>
            <CCardGroup>
              <CCard className="p-4">
                <CCardBody>
                  <CForm>
                    <h1>Login</h1>
                    <p className="text-body-secondary">Sign In to your account</p>
                    <CInputGroup className="mb-3">
                      <CInputGroupText>
                        <CIcon icon={cilUser} />
                      </CInputGroupText>
                      <CFormInput
                        placeholder="Email"
                        autoComplete="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                      />
                    </CInputGroup>
                    <CInputGroup className="mb-4">
                      <CInputGroupText>
                        <CIcon icon={cilLockLocked} />
                      </CInputGroupText>
                      <CFormInput
                        type="password"
                        placeholder="Password"
                        autoComplete="current-password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                      />
                    </CInputGroup>
                    <CRow>
                      <CCol xs={6}>
                        <CButton color="primary" className="px-4">Login</CButton>
                      </CCol>
                      <CCol xs={6} className="text-right">
                        <CButton color="link" className="px-0">Forgot password?</CButton>
                      </CCol>
                    </CRow>
                  </CForm>
                </CCardBody>
              </CCard>
              <CCard className="text-white bg-primary py-5" style={{ width: '44%' }}>
                <CCardBody className="text-center">
                  <div>
                    <h2>Sign up</h2>
                    <p>Don't have an account yet? Register now!</p>
                    <CButton color="primary" className="mt-3" variant="outline">
                      Register Now!
                    </CButton>
                  </div>
                </CCardBody>
              </CCard>
            </CCardGroup>
          </CCol>
        </CRow>
      </CContainer>
    </div>
  );
};
```

---

## 14. Useful Patterns & Tips

### State Management with Redux

```tsx
// src/store.js — CoreUI template menggunakan Redux untuk sidebar state
import { legacy_createStore as createStore } from 'redux';

const initialState = {
  sidebarShow: true,
  sidebarUnfoldable: false,
  theme: 'light',
};

const changeState = (state = initialState, { type, ...rest }) => {
  switch (type) {
    case 'set':
      return { ...state, ...rest };
    default:
      return state;
  }
};

const store = createStore(changeState);
export default store;
```

### Responsive Design Classes

```tsx
// CoreUI follows Bootstrap 5 breakpoints
// xs: 0, sm: 576px, md: 768px, lg: 992px, xl: 1200px, xxl: 1400px

// Visibility
<div className="d-none d-md-block">Visible on md+</div>
<div className="d-block d-md-none">Visible on xs/sm only</div>

// Spacing
<div className="p-3 p-md-4 p-lg-5">Responsive padding</div>
<div className="mb-3 mb-md-4">Responsive margin-bottom</div>
```

---

## 15. Resources

| Resource | URL |
|----------|-----|
| Documentation | https://coreui.io/react/docs/ |
| Component Library | `@coreui/react` on npm |
| Admin Template (Free) | https://github.com/coreui/coreui-free-react-admin-template |
| Admin Template (PRO) | https://coreui.io/product/react-dashboard-template/ |
| Icons | https://coreui.io/icons/ |
| Chart.js Wrapper | `@coreui/react-chartjs` on npm |
| SCSS Variables | https://coreui.io/react/docs/customize/sass/ |
| Changelog | https://github.com/coreui/coreui-react/releases |

---

*Skill ini mencakup CoreUI v5.x untuk React.js. Periksa dokumentasi resmi untuk update terbaru.*
