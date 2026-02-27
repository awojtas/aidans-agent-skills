---
name: design-system-aurora
description: Glass Aurora design system—ethereal glassmorphism, aurora gradients, neon glows, purple-cyan color scheme. Use when creating or modifying UI components to ensure consistency with the design language (glassmorphic cards, gradient text, neon buttons, animations). For design decisions on colors, typography, spacing, or component styling.
---
  
# Design System, Glass Aurora Aesthetic

You are a specialized design assistant applying the **Glass Aurora** aesthetic to the current project. This skill provides comprehensive guidance for maintaining design consistency across all UI changes, new components, and visual refinements.

## Core Design Philosophy

The Glass Aurora design language combines three key elements:

1. **Glassmorphism**: Frosted glass effect with backdrop blur, semi-transparent surfaces, and subtle borders
2. **Aurora Animation**: Ethereal rotating gradients using purple, blue, and green (simulating northern lights)
3. **Neon Glow**: Interactive elements with color-matched shadow effects for emphasis and feedback

The result is a modern, ethereal aesthetic that feels premium and interactive.

## Quick Reference

### When to Use This Skill

- **Creating new UI components** - Ensure glassmorphic appearance and proper color application
- **Modifying existing components** - Check for design consistency before making changes
- **Design decisions** - Color choices, typography, spacing, animations, shadows
- **Responsive design** - Mobile, tablet, desktop layout patterns
- **Dark mode implementation** - Both light and dark mode styling
- **Animation additions** - Hover effects, transitions, entrance animations
- **Accessibility review** - Contrast, focus states, interactive feedback

### Design System Resources

Comprehensive reference documentation is available:

- **[design-tokens.md](design-tokens.md)** - Color palette, typography system, spacing scale, shadows, and all design tokens
- **[glassmorphism-patterns.md](glassmorphism-patterns.md)** - Core patterns, animations, component patterns, and best practices
- **[component-examples.md](component-examples.md)** - Real implementation examples for cards, buttons, forms, modals, lists, and more

Load these references when you need specific implementation details or token values.

## Core Design Patterns

### 1. Glassmorphic Base Pattern

Every component should incorporate the fundamental glassmorphism pattern:

```jsx
className="
  bg-white/10 backdrop-blur-xl
  border border-white/20
  hover:border-purple-400/40
  hover:shadow-purple-500/20
  transition-all duration-300
  rounded-xl
"
```

**Essential Elements**:
- **Background**: `bg-white/10` (10% opacity white for frosted glass)
- **Blur**: `backdrop-blur-xl` (24px blur for strong frosted effect)
- **Border**: `border border-white/20` (subtle translucent edge definition)
- **Interaction**: `hover:border-purple-400/40` (purple accent on hover)
- **Glow**: `hover:shadow-purple-500/20` (neon glow shadow)
- **Smoothness**: `transition-all duration-300` (300ms transitions)
- **Shape**: `rounded-xl` (12px border radius, default for cards)

### 2. Aurora Gradient Animation

Use for animated backgrounds or emphasis sections:

```jsx
animate-aurora-shift  // 6-second cycling gradient animation
```

The animation cycles through three color stops:
- **Purple** (`rgba(124, 58, 255, ...)`)
- **Blue** (`rgba(59, 130, 246, ...)`)
- **Green** (`rgba(16, 185, 129, ...)`)

Create containers with: `bg-gradient-to-br from-purple-500/10 to-cyan-500/10 animate-aurora-shift`

### 3. Gradient Text for Emphasis

Headlines and key text use gradient:

```jsx
className="
  bg-gradient-to-r from-purple-400 to-cyan-400
  bg-clip-text text-transparent
"
```

Color variations:
- **Purple→Cyan** (primary): `from-purple-400 to-cyan-400`
- **Purple→Pink** (secondary): `from-purple-500 to-pink-400`
- **Blue→Green** (tertiary): `from-blue-400 to-emerald-400`

### 4. Neon Glow Buttons

Primary action buttons combine gradients with glow effects:

```jsx
className="
  bg-gradient-to-r from-purple-500 to-cyan-500
  hover:from-purple-400 hover:to-cyan-400
  hover:shadow-purple-500/30
  hover:scale-[1.02]
  transition-all
  shadow-[inset_0_1px_0_0_rgba(255,255,255,0.2)]
"
```

**Key interactions**:
- **Gradient shift** on hover (lighter colors)
- **Glow intensification** (neon shadow)
- **Slight scale** (1.02 = 2% growth)
- **Inset highlight** (subtle depth)

### 5. Color Palette

**Primary Colors** (dark mode):
- **Purple/Primary**: `#9D4EDD` (270 80% 55%) - Main CTAs
- **Cyan/Secondary**: `#06B6D4` (180 100% 50%) - Accents
- **Emerald/Tertiary**: `#10B981` (160 100% 50%) - Success/confirm

**Aurora Animation Colors**:
- **Purple**: `#7C3AFF` (124, 58, 255)
- **Blue**: `#3B82F6` (59, 130, 246)
- **Green**: `#10B981` (16, 185, 129)

**20-Color Palette** (for activity images, visual distinction):
See [design-tokens.md](design-tokens.md) for complete palette with hex codes.

### 6. Typography

**Font Family**:
- **Outfit**: Modern, geometric sans-serif - use for headings, titles, labels
- **DM Sans**: Humanist sans-serif - use for body text

**Font Weights**:
- Regular (400) - Body text
- Medium (500) - Labels, secondary text
- Semibold (600) - Subheadings
- Bold (700) - Headings, emphasis

**Font Sizes** (Tailwind scale):
- Headings: `text-2xl` (24px) to `text-3xl` (30px)
- Body: `text-base` (16px) to `text-lg` (18px)
- Small text: `text-sm` (14px)

### 7. Dark Mode Implementation

All components must work seamlessly in both modes using `dark:` prefix:

```jsx
className="
  bg-white dark:bg-gray-800
  text-gray-900 dark:text-cyan-300
  border-gray-300 dark:border-purple-500/30
  hover:bg-gray-50 dark:hover:bg-purple-900/30
"
```

**Key Conversions**:
- Light text: `text-gray-900` → Dark text: `dark:text-cyan-300`
- Light bg: `bg-white` → Dark bg: `dark:bg-gray-800`
- Light border: `border-gray-300` → Dark border: `dark:border-purple-500/30`
- Light hover: `hover:bg-gray-50` → Dark hover: `dark:hover:bg-purple-900/30`

### 8. Animations & Transitions

**Available Custom Animations**:
- `animate-aurora-shift` - 6s aurora gradient cycle
- `animate-neon-glow-pulse` - 3s glow pulse effect
- `animate-shimmer-glass` - 3s shimmer effect
- `animate-flip` - 600ms card flip
- `animate-fade-in-up` - 300ms entrance animation
- `animate-floating-up` - 3s particle float effect

**Standard Transitions**:
- Always include: `transition-all duration-300`
- For hover states: Add `hover:scale-[1.02]`, `hover:shadow-xl`, `hover:border-purple-400/40`
- For interactive feedback: Use `active:scale-95` for pressed state

### 9. Spacing & Layout

Use Tailwind's standard spacing scale (all increments of 4px):

**Padding**: `p-4`, `p-6`, `px-3`, `py-2`
**Gap/Margin**: `gap-4`, `gap-6`, `mb-4`, `mt-8`
**Responsive**: `md:gap-6`, `lg:p-8`

**Grid Layouts**:
- Mobile first: `grid-cols-1`
- Tablet: `md:grid-cols-2`
- Desktop: `lg:grid-cols-3`

### 10. Logo & App Name Pattern (Project-Specific)

When displaying the project logo with the app name (for auth pages, headers, etc.):

```jsx
<div className="flex items-center gap-3">
  <Image
    src="/logo.png"
    alt="App Logo"
    width={100}
    height={40}
    priority
    className="drop-shadow-lg"
  />
  <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-cyan-400 bg-clip-text text-transparent">
    App Name
  </h1>
</div>
```

**Key Elements**:
- **Logo**: Use the project logo at 100x40px for standalone displays
- **App Name**: Always use gradient text (`from-purple-400 to-cyan-400`)
- **Layout**: Flex container with `items-center gap-3` for proper alignment
- **Font**: Text should be `text-3xl font-bold` for standalone branding
- **Shadow**: Apply `drop-shadow-lg` to logo for depth

**Variations**:
- **Header/Nav**: Smaller logo (40x40 rounded) + `text-2xl` app name
- **Auth Pages**: Medium logo (100x40) + `text-3xl` app name (as shown above)
- **Landing Pages**: Larger logo + `text-4xl` or `text-5xl` app name

## Implementation Workflow

### Step 1: Identify Component Type

Determine what you're building:
- **Card/Container** → Use glassmorphic card pattern
- **Button/CTA** → Use gradient + neon glow pattern
- **Text/Heading** → Consider gradient text effect
- **Form Input** → Use subtle border with focus ring
- **Status/Badge** → Use colored pill with ring pattern
- **Modal/Overlay** → Use **solid** white/dark background (never transparent/translucent)
- **Dropdown Menu** → Use **solid** white/dark background (never transparent/translucent)
- **Animation** → Choose from available keyframes

> **IMPORTANT — Modal & overlay readability**: Modals, dialogs, dropdown menus, and any floating overlay that contains text **must** use a solid, opaque background (`bg-white dark:bg-gray-900`) with explicit high-contrast text color (`text-gray-900 dark:text-gray-100`). **Never** use semi-transparent or gradient backgrounds (e.g. `from-white/95`, `bg-white/10`) on these components — they cause grey-on-grey text that is unreadable. Glassmorphism is for cards and decorative containers only, not for content-bearing overlays.

### Step 2: Select Base Pattern

Pick the appropriate pattern from above and apply the base classes.

### Step 3: Customize Colors

Choose colors based on context:
- **Primary actions** → Purple-to-cyan gradient
- **Secondary actions** → Emerald or blue accent
- **Success states** → Emerald green
- **Error states** → Red
- **Neutral/muted** → Gray with purple tint

### Step 4: Add Dark Mode Support

Always include `dark:` variants for:
- Background colors
- Text colors
- Border colors
- Hover/active states
- Shadow colors

### Step 5: Apply Transitions & Animations

Add smooth transitions:
- Hover effects with scale/shadow changes
- Entrance animations with `animate-fade-in-up`
- Loading states with `animate-pulse`
- Special effects with custom keyframes

### Step 6: Test & Validate

- [ ] Looks good in light mode
- [ ] Looks good in dark mode
- [ ] Hover/focus states work
- [ ] Animations are smooth
- [ ] Contrast meets accessibility standards
- [ ] Mobile responsive

## Common Patterns & Solutions

### Hover Glow Effect
```jsx
hover:shadow-purple-500/30 hover:shadow-cyan-400/20
```
Creates dual-color neon glow on interaction.

### Responsive Text Sizing
```jsx
text-sm md:text-base lg:text-lg
```
Scales gracefully across breakpoints.

### Active/Selected State
```jsx
border-purple-400/40 ring-2 ring-purple-400
```
Use border color and ring for clear active indication.

### Loading Skeleton
```jsx
bg-white/10 dark:bg-white/5 animate-pulse
```
Subtle placeholder with pulse animation.

### Form Group Spacing
```jsx
space-y-4
```
Consistent vertical spacing between form elements.

## References & Resources

**For detailed information, consult**:

1. **[design-tokens.md](design-tokens.md)**
   - Complete color system with hex values
   - Typography specifications
   - All spacing scales
   - Shadow definitions
   - CSS custom properties
   - Use when: You need specific color codes, token values, or complete design token reference

2. **[glassmorphism-patterns.md](glassmorphism-patterns.md)**
   - Core glassmorphic pattern breakdown
   - All animation keyframes with CSS code
   - Dark mode adaptation patterns
   - Responsive design patterns
   - Use when: You need CSS animation code, pattern variations, or dark mode details

3. **[component-examples.md](component-examples.md)**
   - Real implementation examples
   - Cards, buttons, inputs, modals
   - Lists, grids, navigation
   - Complete working code snippets
   - Use when: You need actual implementation examples or component code

## Key Principles

1. **Consistency Over Innovation** - Use established patterns; don't create new styles
2. **Accessibility First** - Ensure sufficient contrast, focus states, and keyboard navigation
3. **Mobile First** - Design for mobile, enhance for larger screens
4. **Performance** - Prefer transform/opacity animations over layout shifts
5. **Dark Mode Default** - Design primarily for dark mode (primary aesthetic)
6. **Glassmorphism Foundation** - Every component benefits from frosted glass treatment

## When in Doubt

If uncertain about:
- **A color choice** → Check [design-tokens.md](design-tokens.md)
- **An animation** → Look in [glassmorphism-patterns.md](glassmorphism-patterns.md) for keyframes
- **Implementation details** → Reference [component-examples.md](component-examples.md) for working code
- **A pattern** → Review the "Core Design Patterns" section above

## Design Vision

The Glass Aurora aesthetic captures an ethereal, premium feel through:

- Ethereal glassmorphism effect
- Aurora borealis gradient animations
- Dark background (nearly black)
- Deep purples, cyan, and emerald glows
- Floating cards with backdrop blur
- Neon glow elements
- Outfit (primary) and DM Sans (secondary) typography

All UI changes should maintain this vision while allowing for refinements and improvements.
