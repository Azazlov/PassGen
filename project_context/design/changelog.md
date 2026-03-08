# PassGen Design Changelog

All notable changes to the UI/UX design of PassGen will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Biometric authentication UI (fingerprint/face ID)
- Auto-clear clipboard indicator (60 sec timer)
- CSV export functionality
- Dark mode improvements for OLED displays
- Custom category icon picker

---

## [1.9.0] - 2026-03-08

### Added

#### Empty States (ТЗ раздел 7)
- Created 4 ASCII mockups for empty states
- Added Flutter implementation examples
- Added to `guidelines/guidelines.md` (Section 11.6)

**Empty State Types:**
- `empty_state_storage.txt` — No passwords (archive icon)
- `empty_state_search.txt` — No search results (search_off icon)
- `empty_state_logs.txt` — No security events (receipt_long icon)
- `empty_state_categories.txt` — No user categories (folder_open icon)

**Common Elements:**
- Icon: 64px, grey[400]
- Title: headlineSmall (24px)
- Subtitle: bodyMedium (14px, 2 lines max)
- Action buttons: TextButton or ElevatedButton

### Files Added
- `final/empty_state_storage.txt` — empty storage mockup
- `final/empty_state_search.txt` — empty search results mockup
- `final/empty_state_logs.txt` — empty logs mockup
- `final/empty_state_categories.txt` — empty categories mockup

### Files Modified
- `changelog.md` (this file) — v1.9.0 added

---

## [1.8.0] - 2026-03-08

### Added

#### Category Icons Specification (ТЗ раздел 6.4)
- Created `category_icons_spec.md` with icon specifications
- Documented all 7 existing category icons
- Added Flutter implementation guide
- Added accessibility guidelines for icons
- Added asset organization structure

**Icon Set:**
- `social.svg` — Social networks (👥)
- `finance.svg` — Banks, finance (🏦)
- `shopping.svg` — Shopping, stores (🛒)
- `entertainment.svg` — Entertainment, media (🎬)
- `work.svg` — Work, business (💼)
- `health.svg` — Health, medical (❤️)
- `other.svg` — Default, other (📁)

**Technical Specifications:**
- Format: SVG 1.1
- Size: 24x24px (viewBox)
- Stroke: 2px
- Fill: CurrentColor
- Style: Material Design Outlined

### Files Added
- `prototypes/category_icons_spec.md` — category icon specifications

### Files Modified
- `changelog.md` (this file) — v1.8.0 added

---

## [1.7.0] - 2026-03-08

### Added

#### Error Handling UI Guidelines (ТЗ раздел 10)
- Created `error_states_spec.md` with comprehensive error handling specs
- Added Section 11 to `guidelines.md` — Error Handling UI
- Added error type classification (Validation, Success, Warning, Critical)
- Added validation error specifications for TextFields
- Added success notification specs (SnackBar)
- Added warning notification specs (Banner)
- Added critical error specs (AlertDialog)
- Added empty state specifications (No passwords, No search results)
- Added loading state specs (Shimmer, Circular Progress)
- Added error handling best practices
- Added accessibility guidelines for errors

**New Sections in guidelines.md:**
- 11.1 Error Types
- 11.2 Validation Errors
- 11.3 Success Notifications (SnackBar)
- 11.4 Warning Notifications (Banner)
- 11.5 Critical Errors (AlertDialog)
- 11.6 Empty States (No passwords, No search results)
- 11.7 Loading States (Shimmer, Circular Progress)
- 11.8 Best Practices
- 11.9 Accessibility

### Files Added
- `prototypes/error_states_spec.md` — error handling specifications

### Files Modified
- `guidelines/guidelines.md` (Section 11 added) — error handling guidelines
- `changelog.md` (this file) — v1.7.0 added

---

## [1.6.0] - 2026-03-08

### Added

#### Micro-interactions & Animations (ТЗ раздел 10.2)
- Created `animations_spec.md` with full animation specifications
- Created 3 Lottie JSON animations:
  - `copy_success.json` — Checkmark animation (200ms, scale+fade)
  - `pin_error.json` — Shake animation (400ms, 3 iterations)
  - `strength_pulse.json` — Strength indicator pulse (300ms, color transition)
- Added Animation Timing Chart with 9 animations
- Added Flutter implementation examples for all animations
- Added Reduced Motion support specifications

**New Sections in guidelines.md:**
- 8.1 Animation Timing Chart
- 8.2 Button Press Animation (Ripple Effect)
- 8.3 Copy Success Animation
- 8.4 Password Strength Pulse
- 8.5 PIN Input Animations (Dot Fill + Error Shake)
- 8.6 List Item Swipe-to-Delete
- 8.7 Page Transitions
- 8.8 Loading States (Button + Shimmer)
- 8.9 Reduced Motion Support

### Updated

#### Guidelines.md
- Section 8 expanded from ~50 lines to ~300 lines
- Added Lottie file references
- Added Flutter implementation examples
- Added Reduced Motion support guide

### Files Added
- `prototypes/animations_spec.md` — animation specifications
- `animations/copy_success.json` — Lottie animation
- `animations/pin_error.json` — Lottie animation
- `animations/strength_pulse.json` — Lottie animation

### Files Modified
- `guidelines/guidelines.md` (Section 8 expanded) — animation guidelines
- `changelog.md` (this file) — v1.6.0 added

---

## [1.5.0] - 2026-03-08

### Added

#### Two-Pane Storage Layout (ТЗ раздел 6.3)
- Created `storage_two_pane_spec.md` with full layout specifications
- Created `storage_two_pane.json` for developers
- **Mobile (< 600dp)**: Single pane with full-screen list
- **Tablet (600-899dp)**: Two-pane (40% list + 60% detail)
- **Desktop (900-1199dp)**: Three-pane (NavigationRail + List + Detail)
- **Wide (≥ 1200dp)**: Three-pane with permanent sidebar
- Added state management specifications
- Added interaction specifications (tap, long press, selection)
- Added accessibility specifications for two-pane layout

#### Button Specifications Update (ТЗ раздел 3.4)
- Updated `components.json` with adaptive button specs
- **Mobile**: 48dp height, fullWidth, 16sp font
- **Desktop**: 40dp height, 200dp min-width, 14sp font
- Added `loading` state with CircularProgressIndicator
- Added `disabled` state with full specifications
- Added hover and pressed states with elevation changes

### Updated

#### Components.json
- Version bumped to 1.1.0
- Expanded `buttons.primary` with mobile/desktop variants
- Expanded `buttons.secondary` with mobile/desktop variants
- Added `loading` state for both button types
- Added `disabled` state with backgroundColor and borderColor

### Files Added
- `prototypes/storage_two_pane_spec.md` — two-pane layout specification
- `for_development/storage_two_pane.json` — developer specs

### Files Modified
- `for_development/components.json` (button specs updated)
- `changelog.md` (this file) — v1.5.0 added

---

## [1.4.0] - 2026-03-08

### Added

#### Accessibility Guidelines Update (ТЗ раздел 11)
- Expanded Section 10 in `guidelines.md` with comprehensive accessibility specs
- Added WCAG AA contrast requirements (4.5:1 for text, 3:1 for UI)
- Added Semantics requirements for all interactive components
- Added Keyboard Navigation specifications (Tab, Enter, Escape, Arrow keys)
- Added Touch Target requirements (48x48dp minimum)
- Added Dynamic Type support guidelines (up to 200%)
- Added Reduced Motion support specifications
- Added Accessibility Checklist for developers
- Added Testing with Accessibility Tools guide

**New Sections in guidelines.md:**
- 10.1 Color Contrast (WCAG AA) — PassGen standards
- 10.2 Semantics Requirements — IconButton, TextField, Card, Checkbox, Switch
- 10.3 Keyboard Navigation — Full key mapping
- 10.4 Touch Target Requirements — Minimum sizes
- 10.5 Dynamic Type Support — Scaling guidelines
- 10.6 Reduced Motion Support — Animation preferences
- 10.7 Accessibility Checklist — Pre-submission checklist
- 10.8 Testing with Accessibility Tools — Screen readers, DevTools
- 10.9 Common Accessibility Issues — Solutions table

#### Components.json Accessibility Section
- Added `accessibility` object with:
  - Semantics specifications for 5 component types
  - Keyboard navigation mapping
  - Focus indicator specifications
  - Contrast requirements
  - Accessibility checklist (5 categories)

### Updated

#### Guidelines.md
- Section 10 expanded from ~50 lines to ~350 lines
- Added Russian translations for better understanding
- Added Flutter implementation examples
- Added accessibility checklist for developers

### Files Modified
- `guidelines/guidelines.md` (Section 10 expanded) — accessibility guidelines
- `for_development/components.json` (accessibility section added) — dev specs
- `changelog.md` (this file) — v1.4.0 added

---

## [1.3.0] - 2026-03-08

### Added

#### Responsive Typography System (ТЗ раздел 2.3)
- Updated `typography.json` with breakpoints for mobile/tablet/desktop
- Added 3-tier font sizes for all 9 text styles
- **Mobile (< 600dp)**: Optimized for small screens
- **Tablet (600-899dp)**: Intermediate sizes
- **Desktop (≥ 900dp)**: Full sizes per ТЗ

**Font Size Changes:**
| Style | Mobile | Tablet | Desktop |
|-------|--------|--------|---------|
| displayLarge | 48px | 52px | 57px |
| headlineLarge | 28px | 30px | 32px |
| headlineMedium | 24px | 26px | 28px |
| titleLarge | 18px | 20px | 22px |
| titleMedium | 15px | 15px | 16px |
| bodyLarge | 15px | 15px | 16px |
| bodyMedium | 13px | 13px | 14px |
| labelLarge | 13px | 13px | 14px |
| labelSmall | 10px | 10px | 11px |

#### Flutter Implementation Guide
- Added helper function `_fontSizeForWidth()` for responsive fonts
- Added `ResponsiveText` extension for BuildContext
- Updated Flutter implementation examples in `typography.json`

### Updated

#### Guidelines.md (Section 3: Typography)
- Added responsive type scale table with all breakpoints
- Added line height values for all styles
- Updated Flutter implementation examples
- Added responsive helper code snippet

### Files Modified
- `for_development/typography.json` (v1.1.0) — responsive typography
- `guidelines/guidelines.md` (Section 3 updated) — typography documentation
- `changelog.md` (this file)

---

## [1.2.0] - 2026-03-08

### Added

#### Adaptive Navigation (ТЗ раздел 3.2, 3.4)
- Created `navigation.json` with full navigation specifications
- **Mobile (< 600dp)**: BottomNavigationBar (80dp height, 5 tabs)
- **Tablet (600-899dp)**: NavigationRail (72dp width)
- **Desktop (900-1199dp)**: NavigationRail + Sidebar (80dp + 240dp)
- **Wide (≥ 1200dp)**: Permanent Sidebar + NavigationRail (three-column)
- Added 4 ASCII mockups for each device type
- Added Flutter implementation examples
- Added animation specifications (tab switching, icon scale)
- Added accessibility specifications (screen reader, keyboard nav)

#### Two-Pane Storage Layout (ТЗ раздел 6.3)
- Created `storage_layout.json` with master-detail specifications
- **Mobile**: Single pane with full-screen list
- **Tablet**: Two-pane (40% list + 60% detail)
- **Desktop**: Three-pane (NavigationRail + List + Detail)
- Added detailed ASCII mockups for mobile/tablet/desktop
- Added PasswordCard specifications
- Added empty state designs (no passwords, no search results)
- Added interaction specifications (tap, long press, selection)
- Added state management examples

#### Navigation Prototypes
- Created `navigation_spec.md` with full prototype specification
- Created 4 ASCII mockups in `final/`:
  - `navigation_mobile.txt`
  - `navigation_tablet.txt`
  - `navigation_desktop.txt`
  - `navigation_wide.txt`

#### Storage Layout Prototypes
- Created `storage_layout_spec.md` with two-pane specification
- Created 3 ASCII mockups in `final/`:
  - `storage_mobile.txt`
  - `storage_tablet.txt`
  - `storage_desktop.txt`

### Updated

#### Components.json
- Expanded `navigation` section with detailed specs
- Added `sidebar` component specification
- Added Flutter implementation examples for all navigation types
- Added touch target specifications (48x48dp)

### Files Added (Этап 5: Критические исправления)
- `for_development/breakpoints.json` ✅
- `for_development/spacing.json` ✅
- `for_development/navigation.json` ✅
- `for_development/storage_layout.json` ✅
- `prototypes/navigation_spec.md` ✅
- `prototypes/storage_layout_spec.md` ✅
- `final/navigation_mobile.txt` ✅
- `final/navigation_tablet.txt` ✅
- `final/navigation_desktop.txt` ✅
- `final/navigation_wide.txt` ✅
- `final/storage_mobile.txt` ✅
- `final/storage_tablet.txt` ✅
- `final/storage_desktop.txt` ✅

### Files Modified
- `guidelines/guidelines.md` (Sections 5 and 9 expanded)
- `for_development/components.json` (navigation section)
- `changelog.md` (this file)

---

## [1.1.0] - 2026-03-08

### Added

#### Breakpoints System (ТЗ раздел 3.1)
- Created `breakpoints.json` with 4 breakpoint values
- **mobileMax**: 600dp (BottomNavigationBar)
- **tabletMin**: 600dp (NavigationRail)
- **desktopMin**: 900dp (NavigationRail + Sidebar)
- **wideMin**: 1200dp (Permanent Sidebar)
- Added device type definitions (Mobile, Tablet, Desktop, Wide)
- Flutter implementation guide in `breakpoints.json`

#### Spacing System (ТЗ раздел 2.4)
- Created `spacing.json` with 6-level spacing scale
- **xs**: 4dp (tight spacing)
- **sm**: 8dp (icon padding)
- **md**: 16dp (standard padding)
- **lg**: 24dp (section padding)
- **xl**: 32dp (large sections)
- **xxl**: 48dp (page margins)
- Base grid rule: 8dp (all spacing multiples of 4dp)
- Component spacing specifications
- Screen spacing for mobile/tablet/desktop
- Layout patterns (Column, Row, GridView)

#### Updated Guidelines
- **Section 5**: Expanded spacing documentation with Flutter implementation
- **Section 9**: Complete responsive breakpoints documentation
- Added adaptive component specifications (Buttons, Text Fields, Dialogs, Cards)
- Added layout patterns for mobile/tablet/desktop

### Changed

#### Breakpoint Values
- **Before**: mobileMax (599px), tabletMin (600px), desktopMin (1024px)
- **After**: mobileMax (600dp), tabletMin (600dp), desktopMin (900dp), wideMin (1200dp)
- **Reason**: Align with ТЗ v2.0 requirements

#### Documentation Language
- Updated guidelines with Russian translations for better developer understanding
- Added ТЗ section references throughout documentation

### Files Modified
- `guidelines/guidelines.md` (Sections 5 and 9 expanded)
- `changelog.md` (this file)

### Files Added
- `for_development/breakpoints.json` (new)
- `for_development/spacing.json` (new)

---

## [1.0.0] - 2026-03-08

### Added - Initial Design System

#### Design Infrastructure
- Created complete folder structure for design assets
- Established design workflow documentation
- Set up Figma/Adobe XD prototype organization

#### Color System
- **Primary Blue**: `#2196F3` (Light), `#64B5F6` (Dark)
- **Secondary Blue**: `#1976D2` (Light), `#42A5F5` (Dark)
- **Password Strength Colors**: 5-level scale (Very Weak → Very Strong)
- **Functional Colors**: Success, Warning, Error, Info

#### Typography
- **Font Family**: Lato (Google Fonts)
- **Type Scale**: 9 text styles (displayLarge → labelSmall)
- **Line Heights**: Optimized for readability
- **Letter Spacing**: Proper tracking for each style

#### Components (18 total)
- **Buttons**: Primary, Secondary, Text, Icon, Loading states
- **Inputs**: Text Field, Password Field, PIN Input, Dropdown, Search
- **Navigation**: Bottom Navigation, Navigation Rail, App Bar
- **Feedback**: Snackbar, Dialog, Progress Indicator, Toast
- **Cards**: Standard card with elevation
- **Password Strength Indicator**: 5-segment progress bar

#### Screen Designs (8 screens)
1. **Auth Screen**: PIN input with numeric keypad
2. **Generator Screen**: Password generation with strength indicator
3. **Storage Screen**: Password vault with search/filter
4. **Encryptor Screen**: Message encryption/decryption
5. **Settings Screen**: App configuration
6. **Categories Screen**: Category management
7. **Logs Screen**: Security audit log
8. **About Screen**: App information

#### Responsive Design
- **Breakpoints**: mobileMax (599px), tabletMin (600px), desktopMin (1024px)
- **Adaptive Navigation**: Bottom nav (mobile) → Navigation rail (tablet/desktop)
- **Touch Targets**: Minimum 48x48px

#### Animations & Micro-interactions
- **Page Transitions**: Cupertino (mobile), Fade upwards (desktop)
- **PIN Error**: Shake animation (400ms, 3 iterations)
- **Password Copy**: Checkmark animation (200ms)
- **Strength Indicator**: Smooth color transition (300ms)
- **Button Feedback**: Ripple effect (Material 3)

#### Accessibility
- **Color Contrast**: WCAG AA compliant (4.5:1 for text, 3:1 for UI)
- **Screen Reader**: Semantics widgets for all interactive elements
- **Keyboard Navigation**: Full Tab/Enter/Escape support
- **Dynamic Type**: System font scaling support
- **Reduced Motion**: Respect system preferences

#### Iconography
- **Library**: Material Icons (filled)
- **Screen Icons**: Generator, Encryptor, Storage, Settings, About
- **Category Icons**: 7 system categories
- **Action Icons**: Search, Copy, Delete, Edit, Visibility

#### Design Assets Organization
- `prototypes/`: Figma/XD source files with versioning
- `final/`: Exported PNG/PDF mockups
- `assets/icons/`: SVG icon files
- `animations/`: Lottie JSON animations
- `for_development/`: Developer handoff files

---

## [0.4.0] - Previous Version (Pre-Design System)

### Existing UI Elements (Documented)
- Material 3 theme implementation
- Google Fonts Lato integration
- Blue color scheme (`#2196F3`)
- Bottom navigation (5 tabs)
- Navigation rail for desktop
- PIN input widget (8 cells)
- Password strength evaluation display
- Category selector dropdown
- Search and filter functionality
- Copyable password fields
- Loading states for async operations

### Existing Animations
- Page transitions (Cupertino/Fade)
- Inactivity timer (5 minutes auto-lock)
- Tab switching with state preservation

---

## Design Decisions Log

### 2026-03-08: Color System
- **Decision**: Use Blue (`#2196F3`) as primary color
- **Rationale**: Conveys trust, security, professionalism
- **Alternatives Considered**: Green (too associated with money), Purple (less universal)

### 2026-03-08: Typography
- **Decision**: Lato font family
- **Rationale**: Clean, modern, highly readable, excellent for UI
- **Alternatives Considered**: Roboto (too generic), Inter (less character)

### 2026-03-08: Navigation Pattern
- **Decision**: Adaptive navigation (bottom nav → nav rail)
- **Rationale**: Follows Material 3 guidelines, optimal for each form factor
- **Alternatives Considered**: Drawer navigation (less discoverable), Top tabs (doesn't scale)

### 2026-03-08: PIN Input Design
- **Decision**: 8-cell visual with numeric keypad
- **Rationale**: Clear visual feedback, familiar pattern, supports 4-8 digit PINs
- **Alternatives Considered**: Standard text field (less secure feeling), Dots only (confusing)

---

## Future Considerations

### Q2 2026
- [ ] Biometric authentication UI patterns
- [ ] Onboarding flow for new users
- [ ] Empty states illustrations
- [ ] Error state illustrations

### Q3 2026
- [ ] Custom themes/user customization
- [ ] Widget designs (home screen widgets)
- [ ] Watch/Companion app designs

### Q4 2026
- [ ] Cloud sync UI (if implemented)
- [ ] Multi-device management UI
- [ ] Advanced security features UI

---

## Contact

For design-related questions or contributions:
- **Designer**: AI UI/UX Agent
- **Developer**: @azazlov
- **Repository**: https://github.com/azazlov/passgen
