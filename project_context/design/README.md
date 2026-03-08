# PassGen Design Resources

**Version:** 1.0.0  
**Last Updated:** March 8, 2026  
**Designer:** AI UI/UX Agent

---

## 📁 Folder Structure

```
design/
├── README.md                    # This file
├── changelog.md                 # Design change history
├── guidelines/
│   └── guidelines.md            # Complete design system documentation
├── for_development/             # Developer handoff files
│   ├── colors.json              # Color tokens (light/dark themes)
│   ├── typography.json          # Type scale and font settings
│   └── components.json          # Component specifications
├── assets/
│   └── icons/                   # SVG category icons
│       ├── social.svg
│       ├── finance.svg
│       ├── shopping.svg
│       ├── entertainment.svg
│       ├── work.svg
│       ├── health.svg
│       └── other.svg
├── animations/                  # Lottie animation files
│   ├── pin_error.json           # PIN input shake animation
│   ├── copy_success.json        # Copy to clipboard success
│   └── strength_pulse.json      # Password strength indicator
├── prototypes/                  # Figma/XD source files (versioned)
│   └── [screen_name]_v[number].fig
└── final/                       # Exported mockups (PNG/PDF)
    └── [screen_name].png
```

---

## 🎨 Design System Overview

### Color Palette
- **Primary**: Blue `#2196F3` (Light) / `#64B5F6` (Dark)
- **Secondary**: Blue `#1976D2` (Light) / `#42A5F5` (Dark)
- **Password Strength**: 5-level scale (Very Weak → Very Strong)
- **Functional**: Success, Warning, Error, Info

### Typography
- **Font**: Lato (Google Fonts)
- **Scale**: 9 text styles (displayLarge → labelSmall)

### Components (18 total)
- Buttons (Primary, Secondary, Text, Icon)
- Inputs (Text, Password, PIN, Dropdown, Search)
- Navigation (Bottom Nav, Navigation Rail)
- Feedback (Snackbar, Dialog, Progress)

### Screens (8 total)
1. Auth Screen (PIN authentication)
2. Generator (Password generation)
3. Storage (Password vault)
4. Encryptor (Message encryption)
5. Settings (App configuration)
6. Categories (Category management)
7. Logs (Security audit)
8. About (App information)

---

## 🚀 Quick Start for Developers

### 1. Import Design Tokens

```dart
// Load colors from JSON
final colors = jsonDecode(await rootBundle.loadString('design/for_development/colors.json'));

// Or use directly from lib/app/app.dart
final primaryColor = Color(0xFF2196F3);
```

### 2. Use Theme

The theme is already configured in `lib/app/app.dart`:

```dart
MaterialApp(
  theme: getTheme(false),      // Light theme
  darkTheme: getTheme(true),   // Dark theme
  themeMode: ThemeMode.system, // Auto
)
```

### 3. Use Components

All components follow Material 3 guidelines. See `guidelines/guidelines.md` for detailed specs.

```dart
// Primary button
ElevatedButton(
  onPressed: () {},
  child: Text('Action'),
)

// Text field
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    border: OutlineInputBorder(),
  ),
)
```

### 4. Use Icons

Category icons are in `assets/icons/`:

```dart
// SVG icons (use flutter_svg package)
SvgPicture.asset('assets/icons/social.svg', width: 24, height: 24)

// Or use Material Icons
Icon(Icons.people, size: 24)
```

### 5. Use Animations

Lottie animations (use lottie package):

```dart
Lottie.asset('design/animations/copy_success.json', width: 48, height: 48)
```

---

## 📐 Responsive Breakpoints

| Breakpoint | Value | Navigation |
|------------|-------|------------|
| Mobile | < 600px | Bottom Navigation |
| Tablet | 600-1023px | Navigation Rail |
| Desktop | ≥ 1024px | Navigation Rail |

---

## ♿ Accessibility

- **Color Contrast**: WCAG AA compliant (4.5:1 minimum)
- **Touch Targets**: Minimum 48x48px
- **Screen Reader**: Semantics widgets on all interactive elements
- **Keyboard Navigation**: Full Tab/Enter/Escape support
- **Dynamic Type**: System font scaling supported

---

## 🔄 Design Workflow

### For New Features

1. **Analyze Requirements**: Review feature specifications
2. **Create Prototype**: Design in Figma/XD → save to `prototypes/`
3. **Review**: Iterate based on feedback
4. **Export Final**: Export to `final/` (PNG + PDF)
5. **Update Guidelines**: Document in `guidelines.md`
6. **Handoff**: Copy assets to `for_development/`
7. **Update Changelog**: Log changes in `changelog.md`

### For Updates

1. **Review Change**: Understand the requirement
2. **Update Prototype**: Create new version (v2, v3, etc.)
3. **Update Changelog**: Document what changed and why
4. **Notify Developers**: Update `for_development/` files

---

## 📋 Checklist for Design Handoff

Before marking a design as complete:

- [ ] All screens designed and exported
- [ ] Color tokens documented (light + dark)
- [ ] Typography scale documented
- [ ] Component specs complete
- [ ] Icons exported (SVG + PNG)
- [ ] Animations created (Lottie JSON)
- [ ] Guidelines updated
- [ ] Changelog updated
- [ ] Developer handoff files prepared

---

## 🛠 Tools Used

- **Design**: Figma, Adobe XD
- **Icons**: Material Icons, Custom SVG
- **Animations**: Lottie, After Effects
- **Prototyping**: Figma prototypes
- **Accessibility**: Contrast checkers, Screen readers

---

## 📞 Contact

For design-related questions:

- **Designer**: AI UI/UX Agent
- **Developer**: @azazlov
- **Repository**: https://github.com/azazlov/passgen
- **Guidelines**: `guidelines/guidelines.md`

---

## 📚 Additional Resources

- [Material 3 Guidelines](https://m3.material.io/)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [Lottie Files](https://lottiefiles.com/)
- [WCAG Accessibility](https://www.w3.org/WAI/WCAG21/quickref/)
