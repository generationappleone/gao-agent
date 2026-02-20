---
name: Data Visualization
description: Skill for creating beautiful, animated charts and dashboards using Recharts, Chart.js, Nivo, and D3.js — covering chart types, theming, responsiveness, animation, and dashboard layout patterns.
---

# Data Visualization Skill

## Overview
Data visualization transforms data into interactive charts and dashboards. Recharts (React), Chart.js, and Nivo are the most popular libraries. This skill covers line charts, bar charts, pie charts, area charts, and dashboard patterns with responsive design.

**References**:
- [Recharts](https://recharts.org/)
- [Chart.js](https://www.chartjs.org/)
- [Nivo](https://nivo.rocks/)

---

## Recharts (React)

```tsx
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar, PieChart, Pie, Cell, AreaChart, Area } from 'recharts';

const revenueData = [
  { month: 'Jan', revenue: 4000, orders: 240 },
  { month: 'Feb', revenue: 3000, orders: 198 },
  { month: 'Mar', revenue: 5000, orders: 300 },
  { month: 'Apr', revenue: 4500, orders: 278 },
  { month: 'May', revenue: 6000, orders: 389 },
  { month: 'Jun', revenue: 5500, orders: 349 },
];

const COLORS = ['#6366f1', '#ec4899', '#10b981', '#f59e0b', '#3b82f6'];

// Revenue Line Chart
export function RevenueChart() {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <AreaChart data={revenueData}>
        <defs>
          <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#6366f1" stopOpacity={0.3} />
            <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
        <XAxis dataKey="month" stroke="#94a3b8" fontSize={12} />
        <YAxis stroke="#94a3b8" fontSize={12} tickFormatter={(v) => `$${v / 1000}k`} />
        <Tooltip contentStyle={{ borderRadius: '12px', border: '1px solid #e5e7eb' }} />
        <Area type="monotone" dataKey="revenue" stroke="#6366f1" strokeWidth={2} fill="url(#colorRevenue)" />
      </AreaChart>
    </ResponsiveContainer>
  );
}

// Category Pie Chart
export function CategoryPieChart({ data }: { data: { name: string; value: number }[] }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie data={data} cx="50%" cy="50%" innerRadius={60} outerRadius={100} paddingAngle={5} dataKey="value">
          {data.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
        </Pie>
        <Tooltip />
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
}

// Orders Bar Chart
export function OrdersBarChart() {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart data={revenueData}>
        <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
        <XAxis dataKey="month" stroke="#94a3b8" />
        <YAxis stroke="#94a3b8" />
        <Tooltip contentStyle={{ borderRadius: '12px' }} />
        <Bar dataKey="orders" fill="#6366f1" radius={[6, 6, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **ResponsiveContainer** | Always wrap charts for responsive sizing |
| **Tooltips** | Custom styled tooltips with border-radius |
| **Colors** | Curated palette, consistent across charts |
| **Gradients** | SVG gradients for area charts |
| **Grid** | Subtle grid lines with dashed strokes |
| **Formatting** | Format axis labels ($, %, k) |
| **Animation** | Built-in animation with Recharts |
| **Legend** | Position outside chart for clarity |
| **Dark mode** | Adjust stroke colors for dark backgrounds |
| **Accessibility** | Include ARIA labels and descriptions |

---

## Rules Integration
- **Charts**: Area, Line, Bar, Pie with Recharts
- **Responsive**: ResponsiveContainer for all sizes
- **Styling**: Custom colors, gradients, tooltips
- **Dashboard**: Grid layout with multiple chart types
