# One Percent Man - Mobile Design System

## 1. Visual Theme & Atmosphere

This design system defines the visual language for a modern, premium mobile application. It is engineered to feel native, responsive, and highly polished across both iOS and Android. The design relies heavily on a clean, high-contrast aesthetic with a signature purple accent that adapts seamlessly between Light and Dark modes.

The overarching goal is to provide an immersive mobile experience:
- **Consistent Context:** The app utilizes dedicated surface colors for cards, sheets, and navigation bars that stand out subtly against the main app background.
- **Dynamic Adaptability:** Every color, shadow, and interaction is designed with both Light and Dark themes in mind.
- **Ergonomics First:** Generous touch targets, bottom-heavy navigation, and modal bottom sheets prioritize comfortable one-handed use.

---

## 2. Color Palette & Roles

The color system is strictly tokenized for Light and Dark modes to ensure a cohesive switch between themes.

### Light Mode
- **App Background (`background`):** `#F5F6F7` - A soft off-white to provide contrast against pure white cards.
- **Surface / Navbar (`surface`):** `#FFFFFF` - Pure white for bottom navbars, cards, and bottom sheets.
- **Primary Accent (`primary`):** `#582FFF` - A vibrant, confident purple for active states, CTAs, and primary buttons.
- **Text Primary (`onBackground`):** `#1A1D21` - Deep charcoal for maximum readability on light backgrounds.
- **Text Secondary / Inactive (`onSurfaceVariant`):** `#484C52` - Muted gray for inactive icons, subtitles, and less critical text.
- **Borders / Dividers (`outline`):** `#E5E7EB` - Subtle gray for structural division without visual noise.

### Dark Mode
- **App Background (`background`):** `#131417` - A very deep, almost-black slate for the main immersive background.
- **Surface / Navbar (`surface`):** `#1D1F24` - A slightly lighter dark slate for elevated elements (cards, navbars) to create depth.
- **Primary Accent (`primary`):** `#9E86FF` - A luminous, pastel purple optimized for high contrast and glowing presence on dark screens.
- **Text Primary (`onBackground`):** `#FFFFFF` - Pure white for main headings and reading text.
- **Text Secondary / Inactive (`onSurfaceVariant`):** `#676D75` - Medium gray for inactive states and secondary metadata.
- **Borders / Dividers (`outline`):** `#2A2D35` - Dark, subtle lines to separate content on dark surfaces.

---

## 3. Typography Rules (Mobile Scale)

Mobile typography requires tighter line heights and larger base sizes for readability on high-density screens.

| Role | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| **Display / Hero** | 32px | 700 (Bold) | 1.2 | Major screen titles, onboarding headers. |
| **Heading 1** | 24px | 600 (Semi) | 1.25 | Section headers, sheet titles. |
| **Heading 2** | 20px | 600 (Semi) | 1.3 | Card titles, group headers. |
| **Body Large** | 16px | 400 (Regular) | 1.5 | Primary reading text, text input fields. |
| **Body Medium** | 14px | 400 (Regular) | 1.4 | Secondary text, descriptions, list item subtitles. |
| **Button / Label** | 16px | 600 (Semi) | 1.0 | Primary and secondary buttons. |
| **Caption** | 12px | 400 (Regular) | 1.3 | Small metadata, timestamps. |
| **Micro (Nav)** | 10px | 500 (Medium) | 1.1 | Bottom navigation labels. |

---

## 4. Component Stylings

### Navigation (Bottom Navbar)
The primary navigation anchors the user experience at the bottom of the screen.

- **Background:** `#FFFFFF` (Light) / `#1D1F24` (Dark).
- **Layout:** 4 to 5 icons with text labels underneath, evenly distributed.
- **Active State:** Icon and text use the Primary Accent (`#582FFF` Light / `#9E86FF` Dark).
- **Active Indicator:** In Dark mode, a subtle top border indicator line (2px height, colored `#9E86FF`) sits above the active icon for additional emphasis. In Light mode, a pill background or bold icon can be used.
- **Inactive State:** Icon and text use Secondary Color (`#484C52` Light / `#676D75` Dark).
- **Safe Area:** Must pad the bottom to accommodate iOS/Android home indicator bars.

### Buttons
**Primary Button**
- **Background:** `#582FFF` (Light) / `#9E86FF` (Dark)
- **Text:** `#FFFFFF` (Light) / `#131417` (Dark - for contrast against pastel purple)
- **Radius:** 12px (pill or rounded rectangle depending on context)
- **Height:** 48px or 56px (generous touch target)
- **Padding:** 16px horizontal minimum.

**Ghost / Secondary Button**
- **Background:** Transparent or 10% opacity of primary color.
- **Border:** None, or 1px solid Primary Accent.
- **Text:** Primary Accent (`#582FFF` / `#9E86FF`).

**Floating Action Button (FAB)**
- **Background:** Primary Accent (`#582FFF` / `#9E86FF`).
- **Icon Color:** `#FFFFFF` (Light) / `#131417` (Dark).
- **Radius:** 16px (rounded square) or fully circular.
- **Shadow:** Elevated shadow (`0px 8px 16px rgba(88,47,255,0.25)`) to stand out over content.

### Text Inputs & Form Fields
- **Background:** `#F5F6F7` (Light - matches app bg but sits on white surface) / `#131417` (Dark).
- **Border:** `1px solid transparent` or `#E5E7EB`. On focus: `2px solid Primary Accent`.
- **Radius:** 12px.
- **Text Color:** Primary Text.
- **Placeholder:** Secondary Text.
- **Padding:** 16px horizontal, 16px vertical.
- **Error State:** Red outline (`#FF4C4C`) and small red error text below the field.

### List Tiles (List Items)
Used for settings, task lists, and history logs.
- **Background:** Transparent (relies on Surface or App Background).
- **Height:** Min 56px to ensure tapability.
- **Leading/Trailing Elements:** Circular icons or avatars (40x40px).
- **Dividers:** Optional 1px line (`#E5E7EB` Light / `#2A2D35` Dark) between items, typically indented to align with the text, not full width.

### Cards & Surfaces
- **Background:** `#FFFFFF` (Light) / `#1D1F24` (Dark).
- **Border Radius:** 16px (softer corners for modern mobile feel).
- **Padding:** 16px internal padding.
- **Shadow (Light Mode):** Subtle ambient shadow (`0px 4px 12px rgba(0, 0, 0, 0.05)`).
- **Shadow (Dark Mode):** Shadows are barely visible on dark backgrounds; rely on the color contrast between Background (`#131417`) and Surface (`#1D1F24`).

### Badges & Chips
Used for status indicators, filters, and categories.
- **Background:** 15% opacity of Primary Accent (or semantic color like success/error).
- **Text Color:** Primary Accent (or semantic color).
- **Radius:** Pill-shaped (100px).
- **Padding:** 4px vertical, 12px horizontal.
- **Font:** Caption (12px), Semi-bold.

#### Task Priorities
- **Low:** Background: `#E5E7EB` (Light) / `#2A2D35` (Dark), Text: Secondary Text.
- **Medium:** Background: 15% Primary Accent, Text: Primary Accent.
- **High:** Background: `rgba(255,165,0,0.15)`, Text: `#FF9800` (Amber).
- **Urgent:** Background: `rgba(255,76,76,0.15)`, Text: `#FF4C4C` (Red).

### Bottom Sheets (Modals) & Dialogs
Instead of central popups, prioritize Bottom Sheets for context menus, filters, and sub-tasks.
- **Background:** Surface color.
- **Border Radius:** 24px top-left and top-right. Bottom is flat.
- **Drag Handle:** A small horizontal pill at the top center (`#E5E7EB` in Light, `#484C52` in Dark), 40px wide, 4px high, rounded.
- **Dimming:** The background behind the sheet dims to `rgba(0,0,0,0.5)`.
*(Note: Use central Dialogs only for destructive actions or critical alerts, with a 16px border radius).*

### Tabs (Segmented Controls)
Used to switch between views within the same screen (e.g., "Active" vs "Completed").
- **Background:** App Background.
- **Active Tab Pill:** Surface Color (creates a "floating" pill effect) or Primary Accent.
- **Radius:** 8px to 12px.
- **Padding:** 4px padding inside the container, 8px vertical on the text.

---

## 5. Layout & Ergonomics

### Spacing System (8pt Grid)
- **Scale:** 4px, 8px, 12px, 16px, 24px, 32px, 48px, 64px.
- **Screen Margins:** Standard horizontal margin for screens is **16px** or **20px** on both sides.
- **Component Gaps:** Use 8px between closely related items (e.g., icon and text), 16px between distinct sections.

### Touch Targets & Safe Areas
- **Minimum Touch Target:** Any interactive element must be at least **44x44px** (iOS) or **48x48px** (Android) to prevent accidental mis-taps.
- **Safe Areas:** Always wrap main scaffolds in `SafeArea` widgets to avoid overlapping the physical device notch, dynamic island, or system navigation bars.
- **Thumb Zone:** Critical actions (save, continue, primary FAB) should be placed in the bottom third of the screen, easily reachable by the thumb.

---

## 6. Implementation Guidelines (Flutter)

When implementing this in Flutter, use the standard `ThemeData` to centralize these rules:

1. Use `ColorScheme` to define `primary`, `background`, `surface`, `onBackground`, etc.
2. Define a dark theme (`ThemeData.dark()`) and a light theme (`ThemeData.light()`) with the exact hex codes above.
3. Map the typography rules into `TextTheme`.
4. Create global component themes (`BottomNavigationBarThemeData`, `ElevatedButtonThemeData`, `CardTheme`) so the design applies automatically across the app without redundant styling in individual widgets.
