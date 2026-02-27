# Glass Aurora Design Tokens

## Color System

The Glass Aurora system uses an HSL-based CSS variable system that automatically adapts between light and dark modes.

### Dark Mode Colors (Primary)

The dark mode is the primary aesthetic with Glass Aurora styling.

**Background & Surfaces**:
- `--background: 275 20% 5%` - Deep dark purple background
- `--card: 275 15% 12%` - Slightly lighter purple for cards/surfaces
- `--foreground: 200 40% 90%` - Cyan-white text
- `--border: 275 15% 20%` - Dark purple borders
- `--ring: 180 100% 50%` - Bright cyan focus ring

**Interactive Colors**:
- `--primary: 270 80% 55%` - Bright violet `#9D4EDD` (primary CTA)
- `--secondary: 180 100% 50%` - Bright cyan `#06B6D4` (secondary accent)
- `--accent: 160 100% 50%` - Bright teal `#14B8A6` (tertiary accent)
- `--muted: 275 15% 24%` - Medium dark purple (disabled/muted state)
- `--destructive: 0 84.2% 60.2%` - Red for errors/destructive actions

**Component Styles**:
- `--card-foreground: 200 40% 90%` - Text on cards (cyan-white)
- `--primary-foreground: 210 40% 98%` - Text on primary buttons (near white)
- `--input: 275 20% 20%` - Input field background
- `--border-radius: 1rem` - 16px default border radius

### Light Mode Colors (Secondary)

Light mode uses softer colors for accessibility.

**Background & Surfaces**:
- `--background: 0 0% 100%` - Pure white
- `--card: 260 30% 98%` - Near-white with slight purple tint
- `--foreground: 260 15% 20%` - Dark blue-gray text
- `--border: 260 20% 90%` - Light purple-gray borders

**Interactive Colors**:
- `--primary: 263 70% 50%` - Vivid purple `#7C3AFF`
- `--secondary: 260 25% 96%` - Very light purple
- `--accent: 260 25% 96%` - Light purple-gray
- `--ring: 263 70% 50%` - Purple focus ring

## Aurora Gradient Colors

The core aurora animation uses three primary colors:

| Color | Hex | RGB | Role |
|-------|-----|-----|------|
| Purple | `#7C3AFF` | `rgb(124, 58, 255)` | Primary gradient stop |
| Blue | `#3B82F6` | `rgb(59, 130, 246)` | Secondary gradient stop |
| Green/Emerald | `#10B981` | `rgb(16, 185, 129)` | Tertiary gradient stop |
| Cyan | `#06B6D4` | `rgb(6, 182, 212)` | Accent and glow color |

These colors rotate in the aurora-shift animation to create the ethereal glassmorphic effect.

## Typography

**Fonts**:
- **Primary**: Outfit (Google Font)
  - Weights: 400, 500, 600, 700
  - Usage: Headings, titles, UI labels
  - CSS Variable: `--font-outfit`

- **Secondary**: DM Sans (Google Font)
  - Weights: 400, 500, 700
  - Usage: Body text, secondary content
  - CSS Variable: `--font-dm-sans`

**Font Scaling** (Tailwind defaults):
```
text-xs   = 0.75rem  (12px)
text-sm   = 0.875rem (14px)
text-base = 1rem     (16px)
text-lg   = 1.125rem (18px)
text-xl   = 1.25rem  (20px)
text-2xl  = 1.5rem   (24px)
text-3xl  = 1.875rem (30px)
```

**Font Weights**:
- Regular: 400
- Medium: 500
- Semibold: 600
- Bold: 700

## Spacing System

Uses Tailwind's default spacing scale:

```
gap-1  = 0.25rem (4px)
gap-2  = 0.5rem  (8px)
gap-3  = 0.75rem (12px)
gap-4  = 1rem    (16px)
gap-6  = 1.5rem  (24px)

p-2    = 0.5rem padding (8px)
p-3    = 0.75rem padding (12px)
p-4    = 1rem padding    (16px)
p-6    = 1.5rem padding  (24px)
```

## Border Radius

```
rounded-full = Pill shape (9999px)
rounded-xl   = 0.75rem (12px)   - Default for cards
rounded-lg   = 0.5rem (8px)
rounded-md   = 0.375rem (6px)
rounded-sm   = 0.125rem (2px)
```

## Shadow System

The Glass Aurora system uses custom neon glow shadows:

**Base Shadows**:
- `shadow-sm` - Subtle elevation
- `shadow` - Default elevation
- `shadow-lg` - Large elevation
- `shadow-xl` - Extra large elevation

**Neon Glow Shadows** (on interactive elements):
- `hover:shadow-purple-500/20` - Purple glow at 20% opacity
- `hover:shadow-purple-500/30` - Purple glow at 30% opacity
- `hover:shadow-blue-400/30` - Blue glow at 30% opacity
- `hover:shadow-cyan-400/30` - Cyan glow at 30% opacity
- `hover:shadow-emerald-400/30` - Emerald glow at 30% opacity

## Backdrop Blur Effects

**Glassmorphism Levels**:
- `backdrop-blur-sm` - 4px blur (subtle)
- `backdrop-blur-md` - 12px blur (medium)
- `backdrop-blur-lg` - 16px blur (strong)
- `backdrop-blur-xl` - 24px blur (very strong)

**Color Saturation**:
- `saturate-100` - Normal
- `saturate-150` - Enhanced vibrancy
- `saturate-200` - Maximum vibrancy
- Use `saturate(180%)` in style attribute for precise control

## Opacity Scale

For glassmorphic effects:

```
white/10   = 10% opacity  (very subtle)
white/20   = 20% opacity  (subtle border)
white/30   = 30% opacity  (visible)
white/40   = 40% opacity  (accent)
white/50   = 50% opacity  (strong)

rgba(124, 58, 255, 0.05)  = 5% opacity (very faint gradient)
rgba(124, 58, 255, 0.10)  = 10% opacity (faint)
rgba(124, 58, 255, 0.15)  = 15% opacity (subtle animation)
rgba(124, 58, 255, 0.25)  = 25% opacity (visible animation)
```

## Transitions

**Timing**:
- `duration-300` - 300ms (default)
- `duration-500` - 500ms (medium)
- `duration-1000` - 1000ms (slow)

**Easing**:
- `ease-in-out` - Smooth easing (default)
- `ease-out` - Quick start, smooth end
- `ease-in` - Slow start, quick end
- `linear` - Constant speed

**Common Patterns**:
- `transition-all duration-300` - All properties, 300ms
- `transition-colors` - Color-specific transitions
- `transition-transform` - Transform-specific transitions

## Responsive Breakpoints

```
sm  = 640px
md  = 768px
lg  = 1024px
xl  = 1280px
2xl = 1536px
```

Usage: `md:text-2xl dark:md:bg-purple-900`

## Color Palette (Vibrant Activity Colors)

A 20-color palette for activity images and visual distinction:

**Purple & Red Tones**:
1. Dark Purple: `#7c3f58`
2. Wine: `#7a3045`
3. Red: `#cf3e53`
4. Burgundy: `#9a4f50`

**Orange & Yellow Tones**:
5. Bright Red: `#ef4444`
6. Orange: `#f97316`
7. Bright Orange: `#fb923c`
8. Amber: `#fbbf24`

**Green Tones**:
9. Yellow: `#facc15`
10. Lime: `#a3e635`
11. Lime Green: `#84cc16`
12. Green: `#22c55e`

**Teal & Blue Tones**:
13. Emerald: `#10b981`
14. Teal: `#14b8a6`
15. Cyan: `#06b6d4`
16. Sky Blue: `#0ea5e9`

**Blue & Purple Tones**:
17. Blue: `#3b82f6`
18. Indigo: `#6366f1`
19. Violet: `#8b5cf6`
20. Purple: `#a855f7`

These are used for:
- Activity image background colors
- Visual distinction in lists
- Theme customization

## Accessibility

**Color Contrast**:
- Text on dark background: Use `text-white` or `text-gray-100` for sufficient contrast
- Text on light background: Use `text-gray-900` or `text-black` for sufficient contrast
- Focus indicators: `focus-visible:ring-1 focus-visible:ring-ring` provides 2px color ring

**Dark Mode**:
- Primary: `dark:bg-purple-900`, `dark:text-cyan-300`
- Secondary: `dark:bg-gray-800`, `dark:text-gray-100`
- Interactive: `dark:hover:bg-purple-800`, `dark:focus:ring-cyan-400`
