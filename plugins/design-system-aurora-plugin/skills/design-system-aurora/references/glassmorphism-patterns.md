# Glassmorphism Patterns & Component Usage

## Core Glassmorphism Pattern

The fundamental pattern for Glass Aurora aesthetic:

```jsx
className="
  bg-white/10                    // 10% opacity white overlay
  backdrop-blur-xl               // 24px blur for frosted glass
  border border-white/20         // Subtle translucent border
  hover:border-purple-400/40     // Purple accent on hover
  hover:shadow-xl                // Enhanced shadow
  hover:shadow-purple-500/20     // Neon purple glow
  transition-all duration-300    // Smooth animation
  rounded-xl                     // 12px border radius
"
```

This creates:
1. Frosted glass appearance (bg-white + backdrop-blur)
2. Subtle depth (border + shadow)
3. Interactive feedback (hover states)
4. Aurora aesthetic (purple/cyan glow)

## Animation Effects

### Aurora Shift Animation
Cycling aurora borealis gradient effect (6-second duration):

```css
@keyframes aurora-shift {
  0% {
    background: linear-gradient(135deg,
      rgba(124, 58, 255, 0.15) 0%,      // Purple
      rgba(59, 130, 246, 0.1) 50%,      // Blue
      rgba(16, 185, 129, 0.05) 100%);   // Green
  }
  33% {
    background: linear-gradient(135deg,
      rgba(59, 130, 246, 0.15) 0%,      // Blue
      rgba(16, 185, 129, 0.1) 50%,      // Green
      rgba(124, 58, 255, 0.05) 100%);   // Purple
  }
  66% {
    background: linear-gradient(135deg,
      rgba(16, 185, 129, 0.15) 0%,      // Green
      rgba(124, 58, 255, 0.1) 50%,      // Purple
      rgba(59, 130, 246, 0.05) 100%);   // Blue
  }
  100% { /* Loops back to 0% */ }
}
```

Usage: `.animate-aurora-shift` for smooth aurora gradient animation.

### Neon Glow Pulse
Pulsing glow effect (3-second duration):

```css
@keyframes neon-glow-pulse {
  0%, 100% {
    box-shadow: 0 0 10px rgba(124, 58, 255, 0.15),
                0 0 20px rgba(59, 130, 246, 0.1);
  }
  50% {
    box-shadow: 0 0 20px rgba(124, 58, 255, 0.25),
                0 0 40px rgba(59, 130, 246, 0.15),
                inset 0 0 10px rgba(16, 185, 129, 0.05);
  }
}
```

Usage: `.animate-neon-glow-pulse` for interactive element emphasis.

### Shimmer Glass
Subtle shimmer across glass surface (3-second duration):

```css
@keyframes shimmer-glass {
  0% { background-position: -1000% 0; }
  100% { background-position: 1000% 0; }
}
```

Usage: `.animate-shimmer-glass` for delicate surface effect.

### Flip Animation
Card flip/rotation (600ms duration):

```css
@keyframes flip {
  0% { transform: rotateY(0deg); }
  50% { transform: rotateY(90deg); }
  100% { transform: rotateY(0deg); }
}
```

Usage: `.animate-flip` for interactive card state changes.

### Fade In Up
Entrance animation (300ms duration):

```css
@keyframes fade-in-up {
  0% { opacity: 0; transform: translateY(20px); }
  100% { opacity: 1; transform: translateY(0); }
}
```

Usage: `.animate-fade-in-up` for component entrance.

### Floating Up
Particle/floating effect (3-second duration):

```css
@keyframes floating-up {
  0% { transform: translateY(0); opacity: 0; }
  10% { opacity: 1; }
  90% { opacity: 1; }
  100% { transform: translateY(-4px); opacity: 0; }
}
```

Usage: `.animate-floating-up` for floating particle effects.

## Component Patterns

### Card/Container Pattern
Basic glassmorphic container:

```jsx
<Card className="
  bg-white/10 backdrop-blur-xl
  border border-white/20
  hover:border-purple-400/40
  hover:shadow-xl hover:shadow-purple-500/20
  transition-all duration-300
">
  {/* Content */}
</Card>
```

**Variations**:
- **Active state**: Use `border-cyan-400/40` and `shadow-cyan-400/30`
- **Muted state**: Use `opacity-50` and `grayscale`
- **Gradient background**: Add `bg-gradient-to-br from-purple-500/10 to-cyan-500/10`

### Gradient Text Pattern
For headings and emphasis:

```jsx
<h1 className="
  text-3xl font-outfit font-bold
  bg-gradient-to-r from-purple-400 to-cyan-400
  bg-clip-text text-transparent
  leading-tight
">
  Page Title
</h1>
```

**Variations**:
- `from-emerald-400 to-cyan-400` - Green to cyan
- `from-purple-500 to-pink-400` - Purple to pink
- `from-blue-400 to-emerald-400` - Blue to green

### Button with Neon Glow Pattern
Primary interactive element:

```jsx
<Button className="
  w-full
  bg-gradient-to-r from-purple-500 to-cyan-500
  hover:from-purple-400 hover:to-cyan-400
  text-white font-outfit font-semibold
  shadow-lg hover:shadow-xl hover:shadow-purple-500/30
  hover:scale-[1.02]
  transition-all
  backdrop-blur-sm
  border border-white/20
  shadow-[inset_0_1px_0_0_rgba(255,255,255,0.2)]
">
  Submit
</Button>
```

**Key Elements**:
- Gradient background with smooth hover transition
- Scale effect (1.02 = 2% increase)
- Neon glow shadow on hover
- Inset highlight shadow for depth
- White border for subtle definition

### Secondary Button Pattern
For secondary actions:

```jsx
<Button variant="outline" className="
  border border-blue-500 dark:border-cyan-400/50
  text-blue-600 dark:text-cyan-300
  hover:bg-blue-50 dark:hover:bg-cyan-400/10
  hover:border-blue-600 dark:hover:border-cyan-300
  transition-all
  shadow-lg hover:shadow-blue-400/30 dark:hover:shadow-cyan-400/30
  backdrop-blur-sm
">
  Undo
</Button>
```

**Characteristics**:
- Outline style with colored border
- Subtle hover background
- Matching glow shadow on hover
- Works in both light and dark modes

### Badge/Pill Pattern
For status indicators:

```jsx
<div className={`
  flex items-center gap-2
  px-3 py-1.5
  rounded-full
  transition-colors
  ${isActive
    ? 'bg-emerald-100 dark:bg-emerald-900/30 ring-2 ring-emerald-400'
    : 'bg-gray-100 dark:bg-gray-800'
  }
`}>
  {label}
</div>
```

**Active State**:
- `bg-emerald-100 dark:bg-emerald-900/30` - Subtle colored background
- `ring-2 ring-emerald-400` - Colored border ring
- Color matches interaction state

### Dialog/Modal Pattern
Overlay dialog with solid, readable background:

```jsx
<DialogContent className="
  fixed left-[50%] top-[50%]
  translate-x-[-50%] translate-y-[-50%]
  z-50
  w-full max-w-lg
  bg-white dark:bg-gray-900
  text-gray-900 dark:text-gray-100
  ring-1 ring-purple-200/50 dark:ring-purple-500/30
  rounded-xl
  p-6
  shadow-xl
  animate-fade-in-up
">
  {/* Dialog content */}
</DialogContent>
```

**Overlay Backdrop**:
```jsx
<DialogOverlay className="
  fixed inset-0 z-50
  bg-black/80
  backdrop-blur-sm
  data-[state=open]:animate-in
  data-[state=closed]:animate-out
"/>
```

### Input Field Pattern
Glassmorphic form input:

```jsx
<Input className="
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
"/>
```

### Dropdown Menu Pattern
Interactive menu with solid, readable background:

```jsx
<div className="
  absolute mt-2 w-56
  rounded-md
  shadow-lg
  bg-white dark:bg-gray-900
  text-gray-900 dark:text-gray-100
  ring-1 ring-purple-200/50 dark:ring-purple-500/30
  z-50
">
  {/* Menu items */}
</div>
```

## Dark Mode Adaptation

All components must work in both light and dark modes using `dark:` prefix:

```jsx
className="
  bg-white dark:bg-gray-800
  text-gray-900 dark:text-cyan-300
  border border-gray-300 dark:border-purple-500/30
  hover:bg-gray-50 dark:hover:bg-purple-900/30
  shadow-sm dark:shadow-purple-500/20
"
```

**Key Patterns**:
- Light backgrounds: `bg-white`, `bg-gray-50`, `bg-purple-50`
- Dark backgrounds: `dark:bg-gray-800`, `dark:bg-gray-900`, `dark:bg-purple-950`
- Light text: `text-gray-900`, `text-gray-700`
- Dark text: `dark:text-cyan-300`, `dark:text-white`
- Light borders: `border-gray-300`, `border-purple-200`
- Dark borders: `dark:border-purple-500/30`, `dark:border-cyan-400/50`

## Responsive Design Patterns

Mobile-first approach using Tailwind breakpoints:

```jsx
className="
  text-sm md:text-base lg:text-lg     // Font scaling
  px-4 md:px-6 lg:px-8                // Horizontal padding
  grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3  // Layout
  gap-4 md:gap-6 lg:gap-8             // Spacing
"
```

**Common Breakpoints**:
- `sm:` - 640px (tablets)
- `md:` - 768px (small laptops)
- `lg:` - 1024px (standard laptops)
- `xl:` - 1280px (wide screens)

## Accessibility Patterns

**Focus Indicators**:
```jsx
focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring
```

**High Contrast Text**:
```jsx
text-white dark:text-cyan-300  // Ensure sufficient contrast
```

**Semantic HTML**:
- Use `<button>`, `<a>`, `<form>` elements
- Never use `<div>` for interactive elements
- Include proper ARIA attributes for complex components

**Screen Reader Support**:
```jsx
aria-label="Submit"
aria-describedby="action-description"
role="status"  // For dynamic content updates
```

## Hover & Interactive States

**Standard Button Hover**:
```jsx
hover:from-purple-400 hover:to-cyan-400  // Gradient shift
hover:shadow-purple-500/30                // Glow intensification
hover:scale-[1.02]                        // Slight scale
```

**Focus State**:
```jsx
focus-visible:ring-1 focus-visible:ring-ring
focus-visible:outline-none
```

**Active/Pressed State**:
```jsx
active:scale-95  // Slight compress on click
active:shadow-sm // Reduced shadow
```

**Disabled State**:
```jsx
disabled:opacity-50 disabled:cursor-not-allowed
dark:disabled:opacity-40
```

## Performance Considerations

**Optimization**:
- Use `transition-all duration-300` for general transitions
- Prefer `transform` and `opacity` for better performance
- Avoid animating `width` or `height` - use `scale` instead
- Use `will-change: transform` for frequently animated elements

**Reduce Motion**:
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

Include this in globals.css for accessibility.
