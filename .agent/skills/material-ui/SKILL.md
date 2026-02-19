---
name: Material UI (MUI)
description: Skill for building React interfaces with Material UI (MUI), covering theming, component usage, data display, customization with sx prop, and responsive design patterns.
---

# Material UI (MUI) Skill

## Overview
MUI is a comprehensive React component library implementing Google's Material Design. Use for enterprise React applications requiring a robust, accessible component system.

## Installation
```bash
npm install @mui/material @emotion/react @emotion/styled
npm install @mui/icons-material    # Icons
npm install @mui/x-data-grid       # Advanced data grid
npm install @mui/x-date-pickers    # Date/time pickers
```

## Theme Setup
```tsx
import { createTheme, ThemeProvider, CssBaseline } from '@mui/material';

const theme = createTheme({
  palette: {
    mode: 'light', // or 'dark'
    primary: { main: '#6366f1', light: '#818cf8', dark: '#4f46e5' },
    secondary: { main: '#8b5cf6' },
    background: { default: '#fafafa', paper: '#ffffff' },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: { fontWeight: 800, letterSpacing: '-0.03em' },
    button: { textTransform: 'none', fontWeight: 600 },
  },
  shape: { borderRadius: 12 },
  components: {
    MuiButton: {
      styleOverrides: {
        root: { borderRadius: 8, padding: '8px 20px' },
        containedPrimary: {
          boxShadow: '0 2px 8px rgba(99,102,241,0.3)',
          '&:hover': { boxShadow: '0 4px 16px rgba(99,102,241,0.4)' },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: { borderRadius: 16, boxShadow: '0 1px 3px rgba(0,0,0,0.08)' },
      },
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {/* App content */}
    </ThemeProvider>
  );
}
```

## Component Patterns

### Buttons
```tsx
import { Button, IconButton, ButtonGroup, LoadingButton } from '@mui/material';
import { Add, Delete, Save } from '@mui/icons-material';

<Button variant="contained" startIcon={<Save />}>Save</Button>
<Button variant="outlined">Cancel</Button>
<Button variant="text">Learn More</Button>
<Button variant="contained" color="error" startIcon={<Delete />}>Delete</Button>
<IconButton color="primary" aria-label="add"><Add /></IconButton>
```

### Cards
```tsx
import { Card, CardContent, CardActions, Typography, Chip } from '@mui/material';

<Card sx={{ transition: 'all 0.2s', '&:hover': { transform: 'translateY(-4px)', boxShadow: 6 } }}>
  <CardContent>
    <Typography variant="overline" color="primary">Category</Typography>
    <Typography variant="h6" fontWeight={700}>Card Title</Typography>
    <Typography variant="body2" color="text.secondary" mt={1}>
      Description of this card content goes here.
    </Typography>
    <Chip label="Active" color="success" size="small" sx={{ mt: 2 }} />
  </CardContent>
  <CardActions sx={{ px: 2, pb: 2 }}>
    <Button size="small">View Details</Button>
  </CardActions>
</Card>
```

### Data Grid
```tsx
import { DataGrid, GridColDef } from '@mui/x-data-grid';

const columns: GridColDef[] = [
  { field: 'name', headerName: 'Name', flex: 1, minWidth: 150 },
  { field: 'email', headerName: 'Email', flex: 1 },
  { field: 'status', headerName: 'Status', width: 120,
    renderCell: (params) => <Chip label={params.value} color={params.value === 'Active' ? 'success' : 'default'} size="small" />
  },
];

<DataGrid rows={users} columns={columns} pageSizeOptions={[10, 25, 50]}
  initialState={{ pagination: { paginationModel: { pageSize: 10 } } }}
  checkboxSelection disableRowSelectionOnClick
  sx={{ border: 0, '& .MuiDataGrid-cell': { borderBottom: '1px solid', borderColor: 'divider' } }} />
```

### Dialog
```tsx
import { Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions } from '@mui/material';

<Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth PaperProps={{ sx: { borderRadius: 3 } }}>
  <DialogTitle fontWeight={700}>Confirm Action</DialogTitle>
  <DialogContent>
    <DialogContentText>Are you sure you want to proceed?</DialogContentText>
  </DialogContent>
  <DialogActions sx={{ p: 2.5 }}>
    <Button onClick={handleClose} variant="outlined">Cancel</Button>
    <Button onClick={handleConfirm} variant="contained">Confirm</Button>
  </DialogActions>
</Dialog>
```

## sx Prop (Inline Styles)
```tsx
// The sx prop supports theme-aware responsive values
<Box sx={{
  display: 'flex',
  gap: 2,
  p: { xs: 2, md: 4 },           // Responsive padding
  bgcolor: 'background.paper',    // Theme-aware color
  borderRadius: 2,                // theme.shape.borderRadius * 2
  boxShadow: 1,                   // theme.shadows[1]
  '&:hover': { boxShadow: 4 },   // Pseudo-selectors
}}>
```

## Dark Mode Toggle
```tsx
import { useState, useMemo } from 'react';
import { createTheme, ThemeProvider } from '@mui/material';

function App() {
  const [mode, setMode] = useState<'light' | 'dark'>('light');
  const theme = useMemo(() => createTheme({ palette: { mode } }), [mode]);

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <IconButton onClick={() => setMode(m => m === 'light' ? 'dark' : 'light')}>
        {mode === 'dark' ? <LightMode /> : <DarkMode />}
      </IconButton>
    </ThemeProvider>
  );
}
```

## Rules Integration
- **UI/UX**: Customize theme for brand colors, use `sx` hover/transition for interactions
- **Accessibility**: MUI components are WAI-ARIA compliant
- **Dependencies**: Requires `@emotion/react`, `@emotion/styled` as peers
