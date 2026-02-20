---
name: Material UI (MUI)
description: Skill for building React interfaces with Material UI (MUI), covering theming, component usage, data display, customization with sx prop, and responsive design patterns.
---

# Material UI (MUI) Skill

## Overview
Material UI (MUI) is the most popular React component library implementing Google's Material Design. It provides 50+ customizable components, a powerful theming system, the `sx` prop for inline styles, and integration with Emotion CSS-in-JS. MUI v5+ uses the `@mui/material` package.

**References**:
- [MUI Documentation](https://mui.com/material-ui/)
- [MUI Components](https://mui.com/material-ui/all-components/)
- [MUI Theming](https://mui.com/material-ui/customization/theming/)

---

## Setup

```bash
npm install @mui/material @emotion/react @emotion/styled @mui/icons-material
```

---

## Theme Configuration

```tsx
// src/theme.ts
import { createTheme } from '@mui/material/styles';

export const theme = createTheme({
  palette: {
    mode: 'light',
    primary: { main: '#6366f1', light: '#818cf8', dark: '#4f46e5' },
    secondary: { main: '#ec4899', light: '#f472b6', dark: '#db2777' },
    error: { main: '#ef4444' },
    warning: { main: '#f59e0b' },
    success: { main: '#10b981' },
    background: { default: '#f8fafc', paper: '#ffffff' },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: { fontSize: '2.5rem', fontWeight: 700 },
    h2: { fontSize: '2rem', fontWeight: 600 },
    h3: { fontSize: '1.5rem', fontWeight: 600 },
    body1: { fontSize: '1rem', lineHeight: 1.7 },
    button: { textTransform: 'none', fontWeight: 600 },
  },
  shape: { borderRadius: 12 },
  components: {
    MuiButton: {
      styleOverrides: {
        root: { borderRadius: 8, padding: '8px 24px' },
        contained: {
          boxShadow: 'none',
          '&:hover': { boxShadow: '0 4px 12px rgba(0,0,0,0.15)' },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 16,
          boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
          border: '1px solid rgba(0,0,0,0.06)',
        },
      },
    },
    MuiTextField: {
      defaultProps: { variant: 'outlined', size: 'small' },
    },
  },
});

// Dark theme
export const darkTheme = createTheme({
  ...theme,
  palette: {
    mode: 'dark',
    primary: { main: '#818cf8' },
    secondary: { main: '#f472b6' },
    background: { default: '#0f172a', paper: '#1e293b' },
  },
});
```

```tsx
// src/App.tsx
import { ThemeProvider, CssBaseline } from '@mui/material';
import { theme } from './theme';

export default function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {/* App content */}
    </ThemeProvider>
  );
}
```

---

## Component Patterns

### Dashboard Stats
```tsx
import { Grid, Card, CardContent, Typography, Box, Chip } from '@mui/material';
import { TrendingUp, TrendingDown, AttachMoney, ShoppingCart, People, Inventory } from '@mui/icons-material';

const stats = [
  { title: 'Revenue', value: '$45,231', change: '+20.1%', trend: 'up', icon: AttachMoney, color: 'primary' },
  { title: 'Orders', value: '2,350', change: '+12.5%', trend: 'up', icon: ShoppingCart, color: 'success' },
  { title: 'Customers', value: '12,234', change: '+8.2%', trend: 'up', icon: People, color: 'info' },
  { title: 'Products', value: '573', change: '-2.1%', trend: 'down', icon: Inventory, color: 'warning' },
];

export function StatsCards() {
  return (
    <Grid container spacing={3}>
      {stats.map((stat) => (
        <Grid item xs={12} sm={6} lg={3} key={stat.title}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                <Typography variant="body2" color="text.secondary">{stat.title}</Typography>
                <Box sx={{ p: 1, borderRadius: 2, bgcolor: `${stat.color}.50` }}>
                  <stat.icon sx={{ fontSize: 20, color: `${stat.color}.main` }} />
                </Box>
              </Box>
              <Typography variant="h4" fontWeight={700}>{stat.value}</Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', mt: 1, gap: 0.5 }}>
                {stat.trend === 'up' ? <TrendingUp fontSize="small" color="success" /> : <TrendingDown fontSize="small" color="error" />}
                <Typography variant="caption" color={stat.trend === 'up' ? 'success.main' : 'error.main'}>
                  {stat.change}
                </Typography>
                <Typography variant="caption" color="text.secondary">vs last month</Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      ))}
    </Grid>
  );
}
```

### Data Table
```tsx
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, IconButton, Chip, TablePagination } from '@mui/material';
import { Edit, Delete } from '@mui/icons-material';

export function ProductTable({ products, total, page, onPageChange }: Props) {
  return (
    <TableContainer component={Paper} variant="outlined">
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Product</TableCell>
            <TableCell>Category</TableCell>
            <TableCell align="right">Price</TableCell>
            <TableCell>Status</TableCell>
            <TableCell align="center">Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {products.map((p) => (
            <TableRow key={p.id} hover>
              <TableCell sx={{ fontWeight: 600 }}>{p.name}</TableCell>
              <TableCell>{p.category}</TableCell>
              <TableCell align="right">${p.price.toLocaleString()}</TableCell>
              <TableCell>
                <Chip
                  label={p.status}
                  size="small"
                  color={p.status === 'active' ? 'success' : 'default'}
                  variant="outlined"
                />
              </TableCell>
              <TableCell align="center">
                <IconButton size="small" color="primary"><Edit fontSize="small" /></IconButton>
                <IconButton size="small" color="error"><Delete fontSize="small" /></IconButton>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <TablePagination
        component="div"
        count={total}
        page={page}
        onPageChange={(_, p) => onPageChange(p)}
        rowsPerPage={20}
        rowsPerPageOptions={[10, 20, 50]}
      />
    </TableContainer>
  );
}
```

### Dialog Form
```tsx
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField, Stack } from '@mui/material';

export function ProductDialog({ open, onClose, onSubmit }: Props) {
  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>Create Product</DialogTitle>
      <DialogContent>
        <Stack spacing={3} sx={{ mt: 1 }}>
          <TextField label="Product Name" required fullWidth />
          <TextField label="Price" type="number" required fullWidth />
          <TextField label="Description" multiline rows={3} fullWidth />
        </Stack>
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={onSubmit}>Create</Button>
      </DialogActions>
    </Dialog>
  );
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **ThemeProvider** | Wrap app with ThemeProvider + CssBaseline |
| **sx prop** | Inline styles with theme token access |
| **createTheme** | Customize palette, typography, shape, components |
| **Component overrides** | Global style overrides in theme.components |
| **Grid** | Use Grid container/item for responsive layouts |
| **Icons** | Use `@mui/icons-material` for consistent icons |
| **Variants** | Use outlined, contained, text for visual hierarchy |
| **Size** | Use size="small" for compact layouts |
| **Dark mode** | Toggle palette.mode between light/dark |
| **Responsive** | Use breakpoints: xs, sm, md, lg, xl |

---

## Rules Integration
- **Theme**: Custom palette, typography, shape, component overrides
- **Components**: Cards, Tables, Dialogs, Chips, Grid
- **Styling**: `sx` prop with theme tokens, responsive breakpoints
- **Icons**: Material Icons for consistent iconography
- **Patterns**: Dashboard stats, data table, modal form
