---
name: Chakra UI
description: Skill for building accessible React interfaces with Chakra UI, covering theming, component patterns, responsive styles, dark mode, and custom component creation.
---

# Chakra UI Skill

## Overview
Chakra UI is an accessible, modular React component library with a powerful theming system. It provides style props, responsive syntax, dark mode support, and composable components that follow WAI-ARIA standards. Chakra prioritizes developer experience and accessibility.

**References**:
- [Chakra UI Documentation](https://chakra-ui.com/docs/getting-started)
- [Chakra UI Components](https://chakra-ui.com/docs/components)
- [Chakra UI Theming](https://chakra-ui.com/docs/styled-system/theme)

---

## Setup

```bash
npm install @chakra-ui/react @emotion/react @emotion/styled framer-motion
```

```tsx
// src/App.tsx
import { ChakraProvider, extendTheme, type ThemeConfig } from '@chakra-ui/react';

const config: ThemeConfig = {
  initialColorMode: 'system',
  useSystemColorMode: true,
};

const theme = extendTheme({
  config,
  colors: {
    brand: {
      50: '#eef2ff', 100: '#e0e7ff', 200: '#c7d2fe', 300: '#a5b4fc',
      400: '#818cf8', 500: '#6366f1', 600: '#4f46e5', 700: '#4338ca',
      800: '#3730a3', 900: '#312e81',
    },
  },
  fonts: {
    heading: '"Inter", sans-serif',
    body: '"Inter", sans-serif',
  },
  styles: {
    global: (props: any) => ({
      body: {
        bg: props.colorMode === 'dark' ? 'gray.900' : 'gray.50',
      },
    }),
  },
  components: {
    Button: {
      defaultProps: { colorScheme: 'brand' },
      variants: {
        solid: { borderRadius: 'lg', fontWeight: 600 },
      },
    },
    Card: {
      baseStyle: (props: any) => ({
        container: {
          borderRadius: 'xl',
          border: '1px solid',
          borderColor: props.colorMode === 'dark' ? 'gray.700' : 'gray.100',
          boxShadow: 'sm',
        },
      }),
    },
  },
});

export default function App() {
  return (
    <ChakraProvider theme={theme}>
      {/* App content */}
    </ChakraProvider>
  );
}
```

---

## Component Patterns

### Dashboard Stats
```tsx
import {
  SimpleGrid, Card, CardBody, Stat, StatLabel, StatNumber,
  StatHelpText, StatArrow, Flex, Icon, useColorModeValue,
} from '@chakra-ui/react';
import { FiDollarSign, FiShoppingCart, FiUsers, FiPackage } from 'react-icons/fi';

const stats = [
  { label: 'Revenue', value: '$45,231', change: 20.1, icon: FiDollarSign, scheme: 'purple' },
  { label: 'Orders', value: '2,350', change: 12.5, icon: FiShoppingCart, scheme: 'green' },
  { label: 'Customers', value: '12,234', change: 8.2, icon: FiUsers, scheme: 'blue' },
  { label: 'Products', value: '573', change: -2.1, icon: FiPackage, scheme: 'orange' },
];

export function StatsCards() {
  const cardBg = useColorModeValue('white', 'gray.800');

  return (
    <SimpleGrid columns={{ base: 1, sm: 2, lg: 4 }} spacing={4}>
      {stats.map((stat) => (
        <Card key={stat.label} bg={cardBg}>
          <CardBody>
            <Flex justify="space-between" align="start" mb={3}>
              <Stat>
                <StatLabel color="gray.500" fontSize="sm">{stat.label}</StatLabel>
                <StatNumber fontSize="2xl" fontWeight={700}>{stat.value}</StatNumber>
                <StatHelpText mb={0}>
                  <StatArrow type={stat.change >= 0 ? 'increase' : 'decrease'} />
                  {Math.abs(stat.change)}%
                </StatHelpText>
              </Stat>
              <Flex p={2} borderRadius="lg" bg={`${stat.scheme}.50`}>
                <Icon as={stat.icon} boxSize={5} color={`${stat.scheme}.500`} />
              </Flex>
            </Flex>
          </CardBody>
        </Card>
      ))}
    </SimpleGrid>
  );
}
```

### Data Table
```tsx
import {
  Table, Thead, Tbody, Tr, Th, Td, TableContainer,
  Badge, IconButton, HStack, Box, useColorModeValue,
} from '@chakra-ui/react';
import { FiEdit2, FiTrash2 } from 'react-icons/fi';

export function ProductTable({ products }: { products: Product[] }) {
  const hoverBg = useColorModeValue('gray.50', 'gray.700');

  return (
    <TableContainer borderWidth={1} borderRadius="xl" borderColor={useColorModeValue('gray.100', 'gray.700')}>
      <Table variant="simple">
        <Thead bg={useColorModeValue('gray.50', 'gray.800')}>
          <Tr>
            <Th>Product</Th>
            <Th>Category</Th>
            <Th isNumeric>Price</Th>
            <Th>Status</Th>
            <Th>Actions</Th>
          </Tr>
        </Thead>
        <Tbody>
          {products.map((p) => (
            <Tr key={p.id} _hover={{ bg: hoverBg }}>
              <Td fontWeight={600}>{p.name}</Td>
              <Td>{p.category}</Td>
              <Td isNumeric>${p.price.toLocaleString()}</Td>
              <Td>
                <Badge colorScheme={p.status === 'active' ? 'green' : 'gray'} borderRadius="full" px={2}>
                  {p.status}
                </Badge>
              </Td>
              <Td>
                <HStack spacing={1}>
                  <IconButton aria-label="Edit" icon={<FiEdit2 />} size="sm" variant="ghost" colorScheme="blue" />
                  <IconButton aria-label="Delete" icon={<FiTrash2 />} size="sm" variant="ghost" colorScheme="red" />
                </HStack>
              </Td>
            </Tr>
          ))}
        </Tbody>
      </Table>
    </TableContainer>
  );
}
```

### Modal Form
```tsx
import {
  Modal, ModalOverlay, ModalContent, ModalHeader, ModalBody,
  ModalFooter, ModalCloseButton, FormControl, FormLabel,
  Input, Textarea, Select, Button, VStack,
} from '@chakra-ui/react';

export function ProductModal({ isOpen, onClose, onSubmit }: Props) {
  return (
    <Modal isOpen={isOpen} onClose={onClose} size="lg">
      <ModalOverlay backdropFilter="blur(4px)" />
      <ModalContent borderRadius="xl">
        <ModalHeader>Create Product</ModalHeader>
        <ModalCloseButton />
        <ModalBody>
          <VStack spacing={4}>
            <FormControl isRequired>
              <FormLabel>Product Name</FormLabel>
              <Input placeholder="Enter product name" />
            </FormControl>
            <FormControl isRequired>
              <FormLabel>Price</FormLabel>
              <Input type="number" placeholder="0" />
            </FormControl>
            <FormControl>
              <FormLabel>Category</FormLabel>
              <Select placeholder="Select category">
                <option value="electronics">Electronics</option>
                <option value="fashion">Fashion</option>
              </Select>
            </FormControl>
            <FormControl>
              <FormLabel>Description</FormLabel>
              <Textarea placeholder="Product description" rows={3} />
            </FormControl>
          </VStack>
        </ModalBody>
        <ModalFooter gap={2}>
          <Button variant="ghost" onClick={onClose}>Cancel</Button>
          <Button colorScheme="brand" onClick={onSubmit}>Create</Button>
        </ModalFooter>
      </ModalContent>
    </Modal>
  );
}
```

### Dark Mode Toggle
```tsx
import { IconButton, useColorMode, useColorModeValue } from '@chakra-ui/react';
import { FiSun, FiMoon } from 'react-icons/fi';

export function ColorModeToggle() {
  const { toggleColorMode } = useColorMode();
  const icon = useColorModeValue(<FiMoon />, <FiSun />);

  return (
    <IconButton
      aria-label="Toggle color mode"
      icon={icon}
      onClick={toggleColorMode}
      variant="ghost"
      size="md"
    />
  );
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **extendTheme** | Customize colors, fonts, component styles |
| **Style props** | Use `bg`, `p`, `fontSize`, etc. directly on components |
| **Responsive** | `{{ base: 1, md: 2, lg: 4 }}` responsive object syntax |
| **useColorModeValue** | Adapt colors for light/dark mode |
| **SimpleGrid** | Responsive grid layout with `columns` |
| **colorScheme** | Consistent color schemes for components |
| **WAI-ARIA** | Built-in accessibility (keyboard, screen reader) |
| **Framer Motion** | Integrated animations via `framer-motion` |
| **Icons** | Use `react-icons` or Chakra icons |
| **Composable** | Build complex UIs from small primitives |

---

## Rules Integration
- **Theme**: Extended with brand colors, fonts, component overrides
- **Components**: Stats, Table, Modal, Toggle with style props
- **Responsive**: Object syntax for breakpoint-based styling
- **Dark mode**: `useColorModeValue` for theme-aware colors
- **Accessibility**: WAI-ARIA compliant, keyboard navigation
