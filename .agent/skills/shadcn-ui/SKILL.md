---
name: shadcn/ui
description: Skill for building React interfaces with shadcn/ui, covering installation, component usage, theming, customization, and integration with Next.js and Vite projects.
---

# shadcn/ui Skill

## Overview
shadcn/ui is NOT a component library — it's a collection of re-usable components that you **copy into your project**. Built on Radix UI primitives + Tailwind CSS. Full control, full customization.

## Installation

### Next.js
```bash
npx -y shadcn@latest init
# Select: TypeScript, Default style, CSS variables, base color, tailwind.config path
```

### Vite + React
```bash
npx -y shadcn@latest init
```

### Adding Components
```bash
# Add individual components
npx shadcn@latest add button
npx shadcn@latest add card dialog input form table
npx shadcn@latest add dropdown-menu sheet avatar badge

# Add all components
npx shadcn@latest add --all
```

## Project Structure
```
src/
├── components/
│   └── ui/              # shadcn/ui components (auto-generated here)
│       ├── button.tsx
│       ├── card.tsx
│       ├── dialog.tsx
│       ├── input.tsx
│       └── ...
├── lib/
│   └── utils.ts         # cn() utility function
└── app/
    └── globals.css      # CSS variables / theme
```

## Usage Patterns

### Button Variants
```tsx
import { Button } from '@/components/ui/button';

// All variants
<Button variant="default">Primary</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>
<Button variant="destructive">Delete</Button>

// Sizes
<Button size="sm">Small</Button>
<Button size="default">Default</Button>
<Button size="lg">Large</Button>
<Button size="icon"><IconX /></Button>

// With loading state
<Button disabled={isLoading}>
  {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
  Submit
</Button>
```

### Card
```tsx
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card';

<Card className="shadow-sm">
  <CardHeader>
    <CardTitle>Dashboard</CardTitle>
    <CardDescription>Overview of your metrics</CardDescription>
  </CardHeader>
  <CardContent>
    <p>Content goes here</p>
  </CardContent>
  <CardFooter className="flex justify-end gap-2">
    <Button variant="outline">Cancel</Button>
    <Button>Save</Button>
  </CardFooter>
</Card>
```

### Dialog (Modal)
```tsx
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from '@/components/ui/dialog';

<Dialog>
  <DialogTrigger asChild>
    <Button>Open Dialog</Button>
  </DialogTrigger>
  <DialogContent className="sm:max-w-[425px]">
    <DialogHeader>
      <DialogTitle>Edit Profile</DialogTitle>
      <DialogDescription>Make changes to your profile here.</DialogDescription>
    </DialogHeader>
    <div className="grid gap-4 py-4">
      <Input id="name" placeholder="Enter your name" />
    </div>
    <DialogFooter>
      <Button type="submit">Save changes</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

### Data Table
```tsx
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';

<Table>
  <TableHeader>
    <TableRow>
      <TableHead>Name</TableHead>
      <TableHead>Email</TableHead>
      <TableHead>Status</TableHead>
      <TableHead className="text-right">Actions</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {users.map(user => (
      <TableRow key={user.id}>
        <TableCell className="font-medium">{user.name}</TableCell>
        <TableCell>{user.email}</TableCell>
        <TableCell>
          <Badge variant={user.isActive ? 'default' : 'secondary'}>
            {user.isActive ? 'Active' : 'Inactive'}
          </Badge>
        </TableCell>
        <TableCell className="text-right">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon"><MoreHorizontal className="h-4 w-4" /></Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem>Edit</DropdownMenuItem>
              <DropdownMenuItem className="text-destructive">Delete</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </TableCell>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

### Form with React Hook Form + Zod
```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  name: z.string().min(2, 'Name must be at least 2 characters'),
});

function UserForm() {
  const form = useForm({ resolver: zodResolver(schema) });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField control={form.control} name="name" render={({ field }) => (
          <FormItem>
            <FormLabel>Name</FormLabel>
            <FormControl><Input placeholder="John Doe" {...field} /></FormControl>
            <FormMessage />
          </FormItem>
        )} />
        <Button type="submit">Submit</Button>
      </form>
    </Form>
  );
}
```

## Theming (CSS Variables)
```css
/* globals.css — customize the theme */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 245 58% 51%;    /* Indigo-ish */
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --muted: 210 40% 96.1%;
    --destructive: 0 84.2% 60.2%;
    --border: 214.3 31.8% 91.4%;
    --radius: 0.5rem;
  }
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --primary: 245 58% 63%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --border: 217.2 32.6% 17.5%;
  }
}
```

## Key Libraries Used With shadcn/ui
| Library | Purpose |
|---------|---------|
| `@radix-ui/*` | Accessible primitives (auto-installed) |
| `tailwindcss` | Styling |
| `class-variance-authority` | Component variants |
| `clsx` + `tailwind-merge` | Class name merging (via `cn()`) |
| `lucide-react` | Icons |
| `react-hook-form` + `zod` | Form handling + validation |
| `@tanstack/react-table` | Advanced data tables |

## Rules Integration
- **UI/UX**: Customize CSS variables for brand colors, all components have dark mode by default
- **Accessibility**: Built on Radix — fully accessible, keyboard navigable, screen reader ready
- **SOLID**: Components are copied into your project — customize without affecting upstream
