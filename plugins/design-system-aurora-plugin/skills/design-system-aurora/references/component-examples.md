# Component Examples & Implementation Guide

## Table of Contents
1. Card Components
2. Button Components
3. Badge & Status Indicators
4. Input & Form Fields
5. Navigation & Layout
6. Modals & Overlays
7. Lists & Grids
8. Animations & Transitions

---

## Card Components

### Glassmorphic Card
Primary card type with full aurora aesthetic:

```jsx
<Card className="
  bg-white/10 backdrop-blur-xl
  border border-white/20
  hover:border-purple-400/40
  hover:shadow-xl hover:shadow-purple-500/20
  transition-all duration-300
  overflow-hidden rounded-xl
">
  {/* Content */}
</Card>
```

**Features**:
- Frosted glass effect with 24px blur
- Subtle translucent border
- Purple glow on hover
- Smooth transitions

### Gradient Background Card
For sections with aurora animation:

```jsx
<div className="
  bg-gradient-to-br from-purple-500/10 to-cyan-500/10
  backdrop-blur-sm
  border border-cyan-400/20
  rounded-xl p-4
  space-y-2
  animate-aurora-shift
">
  {/* Content */}
</div>
```

### Minimal Card
Subtle card for secondary content:

```jsx
<Card className="
  bg-white/5 backdrop-blur-md
  border border-white/10
  hover:bg-white/10 hover:border-white/20
  transition-all
  rounded-lg
">
  {/* Content */}
</Card>
```

### Archived/Disabled Card
Muted appearance for inactive items:

```jsx
<Card className="
  bg-white/10 backdrop-blur-xl
  border border-white/20
  opacity-50 grayscale
  hover:opacity-60
  transition-all
">
  {/* Content */}
</Card>
```

---

## Button Components

### Primary CTA Button
Large, prominent action button:

```jsx
<Button className="
  w-full
  bg-gradient-to-r from-purple-500 to-cyan-500
  hover:from-purple-400 hover:to-cyan-400
  text-white font-outfit font-semibold
  text-base
  py-3
  shadow-lg hover:shadow-xl hover:shadow-purple-500/30
  hover:scale-[1.02]
  transition-all
  backdrop-blur-sm
  border border-white/20
  shadow-[inset_0_1px_0_0_rgba(255,255,255,0.2)]
  rounded-full
">
  Submit
</Button>
```

### Secondary Action Button
Outline style for secondary actions:

```jsx
<Button variant="outline" className="
  px-4 py-2
  border border-blue-500 dark:border-cyan-400/50
  text-blue-600 dark:text-cyan-300
  hover:bg-blue-50 dark:hover:bg-cyan-400/10
  hover:border-blue-600 dark:hover:border-cyan-300
  transition-all
  shadow-lg hover:shadow-blue-400/30 dark:hover:shadow-cyan-400/30
  backdrop-blur-sm
  rounded-full
">
  Undo
</Button>
```

### Icon Button
Compact button for icons:

```jsx
<Button
  size="icon"
  className="
    h-10 w-10
    rounded-full
    hover:bg-white/10 dark:hover:bg-white/5
    transition-colors
  "
  aria-label="Open menu"
>
  <MoreVertical className="h-5 w-5" />
</Button>
```

### Ghost Button
Minimal button style:

```jsx
<Button variant="ghost" className="
  text-gray-600 dark:text-gray-400
  hover:bg-gray-100 dark:hover:bg-gray-800
  hover:text-gray-900 dark:hover:text-gray-200
  transition-colors
">
  Cancel
</Button>
```

### Floating Action Button (FAB)
Large action button for important actions:

```jsx
<Button className="
  h-16 w-16
  rounded-full
  bg-gradient-to-r from-purple-500 to-cyan-500
  hover:from-purple-400 hover:to-cyan-400
  shadow-lg hover:shadow-2xl hover:shadow-purple-500/40
  hover:scale-[1.1]
  transition-all
  fixed bottom-6 right-6
  z-40
">
  <Plus className="h-6 w-6 text-white" />
</Button>
```

---

## Badge & Status Indicators

### Active Pill Badge
Shows active/selected item with emerald glow:

```jsx
<div className="
  flex items-center gap-2
  px-3 py-1.5
  rounded-full
  bg-emerald-100 dark:bg-emerald-900/30
  ring-2 ring-emerald-400
  transition-all
">
  <span className="
    text-sm font-medium
    text-emerald-900 dark:text-emerald-300
  ">
    {label}
  </span>
</div>
```

### Inactive Pill Badge
Shows non-active item:

```jsx
<div className="
  flex items-center gap-2
  px-3 py-1.5
  rounded-full
  bg-gray-100 dark:bg-gray-800
  transition-colors
">
  <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
    {label}
  </span>
</div>
```

### Status Badge
Generic status indicator:

```jsx
<div className="
  inline-flex items-center
  px-2.5 py-0.5
  rounded-full
  bg-blue-100 dark:bg-blue-900/30
  text-xs font-medium
  text-blue-700 dark:text-blue-300
">
  Active
</div>
```

### Activity Indicator
Animated status dot:

```jsx
<div className="
  flex items-center gap-2
">
  <div className="
    h-3 w-3 rounded-full
    bg-emerald-400
    animate-neon-glow-pulse
  " />
  <span className="text-sm text-gray-700 dark:text-gray-300">
    Online
  </span>
</div>
```

---

## Input & Form Fields

### Text Input
Standard text field:

```jsx
<Input
  type="text"
  placeholder="Enter activity name"
  className="
    flex h-9 w-full rounded-md
    border border-input
    bg-white dark:bg-gray-800
    px-3 py-1 text-sm
    text-foreground
    shadow-sm
    transition-colors
    focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring
    disabled:cursor-not-allowed disabled:opacity-50
    placeholder:text-muted-foreground
  "
/>
```

### Textarea
Multi-line text input:

```jsx
<textarea
  placeholder="Enter description"
  className="
    flex min-h-24 w-full rounded-md
    border border-input
    bg-white dark:bg-gray-800
    px-3 py-2 text-sm
    text-foreground
    shadow-sm
    focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring
    disabled:cursor-not-allowed disabled:opacity-50
    resize-none
  "
/>
```

### Select Dropdown
Styled select field:

```jsx
<select className="
  flex h-9 w-full rounded-md
  border border-input
  bg-white dark:bg-gray-800
  px-3 py-1 text-sm
  text-foreground
  focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring
">
  <option>Option 1</option>
  <option>Option 2</option>
</select>
```

### Checkbox
Interactive checkbox:

```jsx
<input
  type="checkbox"
  className="
    h-4 w-4 rounded
    border border-input
    accent-purple-500 dark:accent-cyan-400
    cursor-pointer
    focus-visible:ring-1 focus-visible:ring-ring
  "
/>
```

### Color Picker Input
For color selection:

```jsx
<input
  type="color"
  defaultValue="#7C3AFF"
  className="
    h-10 w-10 rounded-lg
    border-2 border-purple-500
    cursor-pointer
  "
/>
```

---

## Navigation & Layout

### Header Navigation
Top navigation bar:

```jsx
<header className="
  sticky top-0 z-40
  bg-white/10 dark:bg-gray-900/10
  backdrop-blur-md
  border-b border-white/20 dark:border-purple-500/20
  shadow-sm
">
  <nav className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
    {/* Logo and Navigation */}
  </nav>
</header>
```

### Sidebar Navigation
Side menu navigation:

```jsx
<aside className="
  w-64
  bg-white/5 dark:bg-gray-900/20
  backdrop-blur-xl
  border-r border-white/20 dark:border-purple-500/20
  fixed left-0 top-0 h-screen
  overflow-y-auto
  p-4
  space-y-2
">
  {/* Navigation items */}
</aside>
```

### Navigation Item (Active)
Active navigation link:

```jsx
<a href="/dashboard" className="
  block px-4 py-2
  rounded-lg
  bg-gradient-to-r from-purple-500/20 to-cyan-500/20
  border border-purple-400/40
  text-purple-600 dark:text-cyan-300
  font-semibold
  transition-all
">
  Dashboard
</a>
```

### Navigation Item (Inactive)
Inactive navigation link:

```jsx
<a href="/settings" className="
  block px-4 py-2
  rounded-lg
  text-gray-700 dark:text-gray-300
  hover:bg-white/5 dark:hover:bg-white/5
  transition-colors
">
  Settings
</a>
```

---

## Modals & Overlays

### Dialog Content
Modal dialog container — uses solid background for readability:

```jsx
<DialogContent className="
  fixed left-[50%] top-[50%]
  translate-x-[-50%] translate-y-[-50%]
  z-50
  w-full max-w-lg gap-4
  bg-white dark:bg-gray-900
  text-gray-900 dark:text-gray-100
  ring-1 ring-purple-200/50 dark:ring-purple-500/30
  rounded-xl
  p-6
  shadow-xl
  animate-fade-in-up
">
  <DialogHeader>
    <DialogTitle className="
      text-2xl font-outfit font-bold
      bg-gradient-to-r from-purple-600 to-cyan-600
      bg-clip-text text-transparent
    ">
      Create Item
    </DialogTitle>
  </DialogHeader>

  {/* Form content */}

  <DialogFooter className="
    flex gap-3 justify-end
    pt-4 border-t border-gray-200 dark:border-gray-700
  ">
    <Button variant="outline">Cancel</Button>
    <Button>Create</Button>
  </DialogFooter>
</DialogContent>
```

### Dialog Overlay
Backdrop for modals:

```jsx
<DialogOverlay className="
  fixed inset-0 z-50
  bg-black/80 backdrop-blur-sm
  data-[state=open]:animate-in
  data-[state=closed]:animate-out
  data-[state=closed]:fade-out-0
  data-[state=open]:fade-in-0
"/>
```

### Dropdown Menu
Styled dropdown menu:

```jsx
<DropdownMenu>
  <DropdownMenuTrigger asChild>
    <Button variant="ghost" size="icon">
      <MoreVertical className="h-4 w-4" />
    </Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent className="
    w-56
    bg-white dark:bg-gray-900
    text-gray-900 dark:text-gray-100
    ring-1 ring-purple-200/50 dark:ring-purple-500/30
    rounded-md
    shadow-lg
  ">
    <DropdownMenuItem>Edit</DropdownMenuItem>
    <DropdownMenuItem>Delete</DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

### Toast Notification
Success notification:

```jsx
toast.success("Item created!", {
  description: "Your new item is ready.",
  duration: 3000,
})
```

Styled with:
- Background: `hsl(var(--card))` with `backdrop-filter: blur(8px)`
- Border-left accent: Emerald for success
- Icon: Checkmark
- Auto-dismiss: 3 seconds

---

## Lists & Grids

### Card Grid (Responsive)
Grid layout for cards:

```jsx
<div className="
  grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3
  gap-4 md:gap-6
  auto-rows-max
">
  {items.map((item) => (
    <ItemCard key={item.id} item={item} />
  ))}
</div>
```

### List Item
Individual list row:

```jsx
<div className="
  flex items-center justify-between
  px-4 py-3
  rounded-lg
  bg-white/5 dark:bg-white/5
  border border-white/10
  hover:bg-white/10 dark:hover:bg-white/10
  transition-colors
">
  <span className="font-medium">{name}</span>
  <Button size="sm" variant="ghost">Edit</Button>
</div>
```

### Vertical Spacer
Add visual separation:

```jsx
<div className="h-4" />  {/* 16px */}
<div className="h-8" />  {/* 32px */}
```

---

## Animations & Transitions

### Fade In
Simple fade-in effect:

```jsx
<div className="animate-fade-in-up">
  {/* Content */}
</div>
```

### Skeleton Loader
Loading state placeholder:

```jsx
<div className="
  h-12 w-full
  rounded-lg
  bg-white/10 dark:bg-white/5
  animate-pulse
" />
```

### Loading Overlay
Full-page loading state:

```jsx
<div className="
  fixed inset-0 z-50
  bg-background/80 backdrop-blur-sm
  flex items-center justify-center
">
  <div className="text-center">
    <div className="
      h-12 w-12 mx-auto
      border-4 border-purple-500/30
      border-t-purple-500
      rounded-full
      animate-spin
    " />
    <p className="mt-4 text-gray-600 dark:text-gray-400">Loading...</p>
  </div>
</div>
```

### Page Transition
Enter/exit animation:

```jsx
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  exit={{ opacity: 0, y: -20 }}
  transition={{ duration: 0.3 }}
>
  {/* Page content */}
</motion.div>
```

---

## Best Practices

### Composition Pattern
Combine multiple patterns for complex components:

```jsx
<Card className="
  // Glassmorphism
  bg-white/10 backdrop-blur-xl border border-white/20
  // Gradient animation
  animate-aurora-shift
  // Responsive padding
  p-4 md:p-6 lg:p-8
  // Interactive states
  hover:border-purple-400/40 hover:shadow-purple-500/20
  // Transitions
  transition-all duration-300
">
  <h2 className="
    // Gradient text
    bg-gradient-to-r from-purple-400 to-cyan-400
    bg-clip-text text-transparent
    // Typography
    text-2xl font-outfit font-bold
    // Spacing
    mb-4
  ">
    Title
  </h2>

  <p className="
    text-gray-700 dark:text-gray-300
    text-sm
    mb-6
  ">
    Description
  </p>

  <Button className="
    // Primary button styling
    bg-gradient-to-r from-purple-500 to-cyan-500
    hover:shadow-purple-500/30
    transition-all
  ">
    Action
  </Button>
</Card>
```

### Theme Consistency
Always use the design tokens from `design-tokens.md`:
- Colors: Use CSS variables or Tailwind classes
- Typography: Use Outfit (headings) and DM Sans (body)
- Spacing: Use Tailwind spacing scale (gap-4, p-6, etc.)
- Shadows: Use neon glow patterns for interactive elements
- Animations: Use defined keyframes from `globals.css`

### Accessibility Checklist
- [ ] All interactive elements have `:focus-visible` states
- [ ] Color contrast ratio meets WCAG AA standards
- [ ] Form inputs have associated labels
- [ ] Icons have `aria-label` or descriptive text
- [ ] Modals have proper focus management
- [ ] Dark mode works for all components
