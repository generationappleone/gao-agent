---
name: Chakra UI
description: Skill for building accessible React interfaces with Chakra UI, covering theming, component patterns, responsive styles, dark mode, and custom component creation.
---

# Chakra UI Skill

## Overview
Chakra UI is a modular, accessible component library for React. It provides a set of composable building blocks with built-in dark mode, responsive styles, and a powerful theme system.

## Installation
```bash
npm install @chakra-ui/react @emotion/react @emotion/styled framer-motion
```

```tsx
// main.tsx / _app.tsx
import { ChakraProvider, extendTheme } from '@chakra-ui/react';

const theme = extendTheme({
  colors: {
    brand: {
      50: '#eef2ff', 100: '#e0e7ff', 200: '#c7d2fe', 300: '#a5b4fc',
      400: '#818cf8', 500: '#6366f1', 600: '#4f46e5', 700: '#4338ca',
      800: '#3730a3', 900: '#312e81',
    },
  },
  fonts: {
    heading: `'Inter', sans-serif`,
    body: `'Inter', sans-serif`,
  },
  config: {
    initialColorMode: 'system',
    useSystemColorMode: true,
  },
});

function App({ children }) {
  return <ChakraProvider theme={theme}>{children}</ChakraProvider>;
}
```

## Component Patterns

### Layout
```tsx
import { Box, Flex, Grid, GridItem, Container, Stack, HStack, VStack } from '@chakra-ui/react';

// Dashboard layout
<Flex minH="100vh">
  <Box w="64" bg={useColorModeValue('white', 'gray.900')} borderRightWidth="1px" p={4}>
    Sidebar
  </Box>
  <Box flex="1" p={8} bg={useColorModeValue('gray.50', 'gray.950')}>
    <Container maxW="7xl">
      <Grid templateColumns={{ base: '1fr', md: 'repeat(2, 1fr)', xl: 'repeat(4, 1fr)' }} gap={6}>
        <GridItem><StatCard title="Revenue" value="$45K" /></GridItem>
        <GridItem><StatCard title="Users" value="2,340" /></GridItem>
      </Grid>
    </Container>
  </Box>
</Flex>
```

### Cards
```tsx
import { Card, CardHeader, CardBody, CardFooter, Heading, Text, Button } from '@chakra-ui/react';

<Card
  variant="outline"
  borderRadius="xl"
  shadow="sm"
  transition="all 0.2s"
  _hover={{ transform: 'translateY(-4px)', shadow: 'xl' }}
>
  <CardHeader>
    <Heading size="md">Feature Title</Heading>
  </CardHeader>
  <CardBody>
    <Text color="gray.500">Description of this feature.</Text>
  </CardBody>
  <CardFooter>
    <Button colorScheme="brand" borderRadius="full">Learn More</Button>
  </CardFooter>
</Card>
```

### Forms
```tsx
import { FormControl, FormLabel, FormErrorMessage, Input, Select, Textarea } from '@chakra-ui/react';

<FormControl isInvalid={!!errors.email}>
  <FormLabel>Email</FormLabel>
  <Input type="email" placeholder="you@example.com" borderRadius="lg" {...register('email')} />
  <FormErrorMessage>{errors.email?.message}</FormErrorMessage>
</FormControl>
```

### Modal
```tsx
import { Modal, ModalOverlay, ModalContent, ModalHeader, ModalBody, ModalFooter, ModalCloseButton, useDisclosure } from '@chakra-ui/react';

function EditModal() {
  const { isOpen, onOpen, onClose } = useDisclosure();

  return (
    <>
      <Button onClick={onOpen}>Edit</Button>
      <Modal isOpen={isOpen} onClose={onClose} isCentered>
        <ModalOverlay bg="blackAlpha.600" backdropFilter="blur(4px)" />
        <ModalContent borderRadius="xl">
          <ModalHeader>Edit Item</ModalHeader>
          <ModalCloseButton />
          <ModalBody><Input placeholder="Name" /></ModalBody>
          <ModalFooter gap={2}>
            <Button variant="ghost" onClick={onClose}>Cancel</Button>
            <Button colorScheme="brand">Save</Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
}
```

## Responsive Props
```tsx
// Array syntax: [mobile, tablet, desktop]
<Box fontSize={['sm', 'md', 'lg']} p={[4, 6, 8]}>Responsive</Box>

// Object syntax: { base, md, lg, xl }
<Grid templateColumns={{ base: '1fr', md: 'repeat(2, 1fr)', lg: 'repeat(3, 1fr)' }} gap={6}>
```

## Dark Mode
```tsx
import { useColorMode, useColorModeValue, IconButton } from '@chakra-ui/react';
import { SunIcon, MoonIcon } from '@chakra-ui/icons';

function ThemeToggle() {
  const { colorMode, toggleColorMode } = useColorMode();
  return (
    <IconButton icon={colorMode === 'dark' ? <SunIcon /> : <MoonIcon />}
                onClick={toggleColorMode} aria-label="Toggle theme" variant="ghost" />
  );
}

// Use in components
const bg = useColorModeValue('white', 'gray.800');
const borderColor = useColorModeValue('gray.200', 'gray.700');
```

## Style Props Reference
| Prop | CSS Property |
|------|-------------|
| `bg`, `bgGradient` | background |
| `color` | color |
| `p`, `px`, `py` | padding |
| `m`, `mx`, `my` | margin |
| `w`, `h`, `minH` | width, height |
| `borderRadius`, `rounded` | border-radius |
| `shadow` | box-shadow |
| `transition` | transition |
| `_hover`, `_active`, `_focus` | pseudo-states |

## Rules Integration
- **UI/UX**: Use `extendTheme` for brand colors, `_hover` + transitions for interactions
- **Accessibility**: All Chakra components are WAI-ARIA compliant by default
- **Dependencies**: Requires `@emotion/react`, `@emotion/styled`, `framer-motion` as peers
