---
name: Data Visualization
description: Skill for creating beautiful, animated charts and dashboards using Recharts, Chart.js, Nivo, and D3.js — covering chart types, theming, responsiveness, animation, and dashboard layout patterns.
---

# Data Visualization Skill

## Overview
Beautiful data visualization transforms raw numbers into **insight and storytelling**. This skill covers the most effective charting libraries for modern frontend development with focus on aesthetics, animation, and responsiveness.

## Library Decision Matrix

| Scenario | Recommended | Why |
|----------|-------------|-----|
| React dashboards (general) | **Recharts** | Best DX, composable, responsive |
| React dashboards (design-heavy) | **Nivo** | Stunning defaults, many chart types |
| Vanilla JS / multi-framework | **Chart.js** | Most popular, lightweight, versatile |
| React + Chart.js | **react-chartjs-2** | Chart.js wrapper for React |
| Complex custom visualizations | **D3.js** | Most powerful, full control |
| Simple inline charts | **Sparklines / Trend** | Tiny, inline data |
| Maps / geospatial | **react-simple-maps** + D3 | SVG-based map charts |

---

## 1. Recharts (React — Primary Choice)

### Installation
```bash
npm install recharts
```

### Line Chart (KPI Trend)
```tsx
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, Legend,
} from 'recharts';

const data = [
  { month: 'Jan', revenue: 4000, users: 2400 },
  { month: 'Feb', revenue: 5200, users: 2800 },
  { month: 'Mar', revenue: 4800, users: 3200 },
  { month: 'Apr', revenue: 6100, users: 3600 },
  { month: 'May', revenue: 7200, users: 4100 },
  { month: 'Jun', revenue: 8400, users: 4800 },
];

// ✅ Premium styled line chart
function RevenueChart() {
  return (
    <ResponsiveContainer width="100%" height={320}>
      <LineChart data={data} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
        <defs>
          {/* Gradient for area fill */}
          <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#6366f1" stopOpacity={0.15} />
            <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid
          strokeDasharray="3 3"
          stroke="hsl(220, 14%, 90%)"
          vertical={false}
        />
        <XAxis
          dataKey="month"
          axisLine={false}
          tickLine={false}
          tick={{ fill: '#64748b', fontSize: 12 }}
        />
        <YAxis
          axisLine={false}
          tickLine={false}
          tick={{ fill: '#64748b', fontSize: 12 }}
          tickFormatter={(v) => `$${(v / 1000).toFixed(0)}k`}
        />
        <Tooltip
          contentStyle={{
            backgroundColor: 'rgba(15, 23, 42, 0.95)',
            border: 'none',
            borderRadius: '12px',
            boxShadow: '0 20px 40px rgba(0,0,0,0.3)',
            color: '#f1f5f9',
            padding: '12px 16px',
          }}
          labelStyle={{ color: '#94a3b8', marginBottom: 4 }}
          itemStyle={{ color: '#e2e8f0' }}
        />
        <Legend
          iconType="circle"
          wrapperStyle={{ paddingTop: 16, fontSize: 13 }}
        />
        <Line
          type="monotone"
          dataKey="revenue"
          stroke="#6366f1"
          strokeWidth={2.5}
          dot={false}
          activeDot={{ r: 6, fill: '#6366f1', stroke: '#fff', strokeWidth: 2 }}
          name="Revenue"
          animationDuration={1200}
          animationEasing="ease-out"
        />
        <Line
          type="monotone"
          dataKey="users"
          stroke="#8b5cf6"
          strokeWidth={2}
          strokeDasharray="6 4"
          dot={false}
          activeDot={{ r: 5, fill: '#8b5cf6', stroke: '#fff', strokeWidth: 2 }}
          name="Users"
          animationDuration={1500}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

### Area Chart (Filled Trend)
```tsx
import { AreaChart, Area } from 'recharts';

// ✅ Gradient area chart
<ResponsiveContainer width="100%" height={280}>
  <AreaChart data={data}>
    <defs>
      <linearGradient id="gradient" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stopColor="#6366f1" stopOpacity={0.3} />
        <stop offset="100%" stopColor="#6366f1" stopOpacity={0.02} />
      </linearGradient>
    </defs>
    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
    <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} />
    <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} />
    <Tooltip />
    <Area
      type="monotone"
      dataKey="revenue"
      stroke="#6366f1"
      strokeWidth={2.5}
      fill="url(#gradient)"
      animationDuration={1200}
    />
  </AreaChart>
</ResponsiveContainer>
```

### Bar Chart
```tsx
import { BarChart, Bar, Cell } from 'recharts';

const COLORS = ['#6366f1', '#8b5cf6', '#a855f7', '#c084fc', '#d8b4fe'];

// ✅ Premium bar chart with rounded corners + gradient
<ResponsiveContainer width="100%" height={300}>
  <BarChart data={data} barGap={8}>
    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
    <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} />
    <YAxis axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} />
    <Tooltip />
    <Bar dataKey="revenue" radius={[6, 6, 0, 0]} animationDuration={1200}>
      {data.map((_, index) => (
        <Cell key={index} fill={COLORS[index % COLORS.length]} />
      ))}
    </Bar>
  </BarChart>
</ResponsiveContainer>
```

### Donut / Pie Chart
```tsx
import { PieChart, Pie, Cell } from 'recharts';

const donutData = [
  { name: 'Desktop', value: 55 },
  { name: 'Mobile', value: 35 },
  { name: 'Tablet', value: 10 },
];

const DONUT_COLORS = ['#6366f1', '#8b5cf6', '#a855f7'];

// ✅ Premium donut chart with center label
<ResponsiveContainer width="100%" height={260}>
  <PieChart>
    <Pie
      data={donutData}
      cx="50%"
      cy="50%"
      innerRadius={65}
      outerRadius={95}
      paddingAngle={4}
      dataKey="value"
      animationDuration={1200}
      animationEasing="ease-out"
    >
      {donutData.map((_, index) => (
        <Cell key={index} fill={DONUT_COLORS[index]} stroke="none" />
      ))}
    </Pie>
    <Tooltip />
    <Legend iconType="circle" />
  </PieChart>
</ResponsiveContainer>
```

---

## 2. Chart.js + react-chartjs-2

### Installation
```bash
npm install chart.js react-chartjs-2
```

### Setup
```tsx
import {
  Chart as ChartJS, CategoryScale, LinearScale, PointElement,
  LineElement, BarElement, ArcElement, Title, Tooltip, Legend, Filler,
} from 'chart.js';

// Register once at app entry
ChartJS.register(
  CategoryScale, LinearScale, PointElement,
  LineElement, BarElement, ArcElement, Title, Tooltip, Legend, Filler,
);
```

### Line Chart
```tsx
import { Line } from 'react-chartjs-2';

const options = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
    tooltip: {
      backgroundColor: 'rgba(15, 23, 42, 0.95)',
      titleColor: '#94a3b8',
      bodyColor: '#f1f5f9',
      borderColor: 'rgba(99, 102, 241, 0.3)',
      borderWidth: 1,
      cornerRadius: 12,
      padding: { x: 14, y: 10 },
    },
  },
  scales: {
    x: { grid: { display: false }, ticks: { color: '#64748b' } },
    y: { grid: { color: '#f1f5f9' }, ticks: { color: '#64748b' } },
  },
  elements: {
    line: { tension: 0.4, borderWidth: 2.5 },
    point: { radius: 0, hoverRadius: 6, hoverBorderWidth: 2 },
  },
  animation: { duration: 1200, easing: 'easeOutQuart' as const },
};

const data = {
  labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
  datasets: [{
    label: 'Revenue',
    data: [4000, 5200, 4800, 6100, 7200, 8400],
    borderColor: '#6366f1',
    backgroundColor: (ctx: any) => {
      const gradient = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300);
      gradient.addColorStop(0, 'rgba(99, 102, 241, 0.2)');
      gradient.addColorStop(1, 'rgba(99, 102, 241, 0)');
      return gradient;
    },
    fill: true,
  }],
};

function RevenueChart() {
  return (
    <div style={{ height: 320 }}>
      <Line options={options} data={data} />
    </div>
  );
}
```

---

## 3. Dashboard Layout Patterns

### Stat Card Component
```tsx
// ✅ Premium stat card with trend indicator
interface StatCardProps {
  label: string;
  value: string | number;
  change: number;        // percentage change
  icon: React.ReactNode;
  color: 'indigo' | 'emerald' | 'amber' | 'rose';
}

const colorMap = {
  indigo: { bg: 'bg-indigo-50', icon: 'text-indigo-600', ring: 'ring-indigo-500/20' },
  emerald: { bg: 'bg-emerald-50', icon: 'text-emerald-600', ring: 'ring-emerald-500/20' },
  amber: { bg: 'bg-amber-50', icon: 'text-amber-600', ring: 'ring-amber-500/20' },
  rose: { bg: 'bg-rose-50', icon: 'text-rose-600', ring: 'ring-rose-500/20' },
};

function StatCard({ label, value, change, icon, color }: StatCardProps) {
  const colors = colorMap[color];
  const isPositive = change >= 0;

  return (
    <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm
                    transition-all duration-300 hover:-translate-y-1 hover:shadow-lg
                    dark:border-gray-800 dark:bg-gray-900">
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-gray-500 dark:text-gray-400">
          {label}
        </span>
        <div className={`rounded-lg ${colors.bg} p-2.5 ring-1 ${colors.ring}`}>
          <span className={colors.icon}>{icon}</span>
        </div>
      </div>
      <div className="mt-3 flex items-end gap-3">
        <span className="text-3xl font-bold tracking-tight text-gray-900 dark:text-white">
          {typeof value === 'number' ? value.toLocaleString() : value}
        </span>
        <span className={`mb-1 flex items-center gap-1 text-sm font-medium
                         ${isPositive ? 'text-emerald-600' : 'text-rose-600'}`}>
          {isPositive ? '↑' : '↓'} {Math.abs(change)}%
        </span>
      </div>
    </div>
  );
}
```

### Dashboard Grid Layout
```tsx
// ✅ Responsive dashboard layout
function Dashboard() {
  return (
    <div className="space-y-6 p-6">
      {/* Stat cards — 4 columns on desktop, 2 on tablet, 1 on mobile */}
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Total Revenue" value="$84,254" change={12.5} icon={<DollarSign />} color="indigo" />
        <StatCard label="Active Users" value={12847} change={8.2} icon={<Users />} color="emerald" />
        <StatCard label="Orders" value={1423} change={-2.1} icon={<ShoppingCart />} color="amber" />
        <StatCard label="Conversion" value="3.24%" change={4.1} icon={<TrendingUp />} color="rose" />
      </div>

      {/* Charts — 2 columns on desktop */}
      <div className="grid gap-6 lg:grid-cols-7">
        <div className="lg:col-span-4">
          <ChartCard title="Revenue Overview" subtitle="Last 6 months">
            <RevenueChart />
          </ChartCard>
        </div>
        <div className="lg:col-span-3">
          <ChartCard title="Traffic Sources" subtitle="Current month">
            <TrafficDonut />
          </ChartCard>
        </div>
      </div>

      {/* Table + Activity — 2 columns */}
      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2">
          <ChartCard title="Recent Orders">
            <OrdersTable />
          </ChartCard>
        </div>
        <div>
          <ChartCard title="Activity Feed">
            <ActivityFeed />
          </ChartCard>
        </div>
      </div>
    </div>
  );
}
```

### Chart Card Wrapper
```tsx
// ✅ Consistent card wrapper for all charts
function ChartCard({
  title,
  subtitle,
  action,
  children,
}: {
  title: string;
  subtitle?: string;
  action?: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <div className="rounded-xl border border-gray-200 bg-white shadow-sm
                    dark:border-gray-800 dark:bg-gray-900">
      <div className="flex items-center justify-between border-b border-gray-100
                      px-6 py-4 dark:border-gray-800">
        <div>
          <h3 className="text-base font-semibold text-gray-900 dark:text-white">{title}</h3>
          {subtitle && (
            <p className="mt-0.5 text-sm text-gray-500 dark:text-gray-400">{subtitle}</p>
          )}
        </div>
        {action}
      </div>
      <div className="p-6">{children}</div>
    </div>
  );
}
```

---

## 4. Chart Theming (Dark Mode Support)

```tsx
// ✅ Create a theme-aware chart config
const chartTheme = {
  light: {
    gridColor: '#f1f5f9',
    textColor: '#64748b',
    tooltipBg: 'rgba(15, 23, 42, 0.95)',
    tooltipText: '#f1f5f9',
  },
  dark: {
    gridColor: '#1e293b',
    textColor: '#94a3b8',
    tooltipBg: 'rgba(241, 245, 249, 0.95)',
    tooltipText: '#0f172a',
  },
};

// ✅ Brand color palette for charts (harmonious)
const CHART_COLORS = {
  primary: '#6366f1',    // Indigo
  secondary: '#8b5cf6',  // Violet
  tertiary: '#a855f7',   // Purple
  success: '#10b981',    // Emerald
  warning: '#f59e0b',    // Amber
  danger: '#ef4444',     // Red
  info: '#06b6d4',       // Cyan
  neutral: '#64748b',    // Slate
};

// Sequential palette (for single-metric different segments)
const SEQUENTIAL = ['#6366f1', '#818cf8', '#a5b4fc', '#c7d2fe', '#e0e7ff'];

// Categorical palette (for multi-metric comparison)
const CATEGORICAL = ['#6366f1', '#8b5cf6', '#06b6d4', '#10b981', '#f59e0b', '#ef4444'];
```

---

## Best Practices

1. **Always use `ResponsiveContainer`** (Recharts) or `maintainAspectRatio: false` (Chart.js) — charts must be responsive
2. **Remove chart borders/axes** where unnecessary — cleaner is more premium
3. **Use gradient fills** under line/area charts — adds depth
4. **Animate on mount** — use 1000-1500ms animation with ease-out for chart entrance
5. **Dark mode tooltips** — dark background tooltips look premium in light mode
6. **Rounded bar corners** — `radius={[6, 6, 0, 0]}` makes bars look modern
7. **Hide dots on line charts** — show only on hover (`activeDot`)
8. **Use consistent color palette** — match brand colors across all charts
9. **Add trend indicators** — ↑/↓ with green/red next to numbers
10. **Skeleton loading** — show chart skeleton while data loads

## Rules Integration
- **UI/UX Rule**: Charts must use the design token color system from `rules/ui-ux-design.md`
- **Accessibility**: Include text alternatives, meaningful tooltips, color-blind friendly palettes
- **Animation Rule**: Chart animations should follow `rules/ui-ux-design.md` timing tokens
- **Type Safety**: All chart data must have TypeScript interfaces
