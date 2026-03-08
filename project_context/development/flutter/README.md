# Flutter Development Structure

This folder contains the Flutter frontend development artifacts for the PassGen project.

## Folder Structure

```
flutter/
├── lib/                    # Source code (symlink/copy from project root lib/)
├── test/                   # Unit, widget, and integration tests
├── reports/                # Build logs and test reports
├── docs/                   # Development documentation
└── builds/                 # Build artifacts for QA/Testing
```

## Development Stages

1. **Project Setup** - Flutter initialization, dependencies
2. **Adaptive Layouts** - LayoutBuilder, breakpoints implementation
3. **Design System Integration** - Themes, styles, components
4. **Screen Development** - Auth, Generator, Storage, Settings, About
5. **Animations & Micro-interactions** - Transitions, feedback
6. **Testing** - Unit, widget, integration tests
7. **Performance Optimization** - Profiling, reducing rebuilds

## Coordination

- **Design Assets**: Received from `project_context/design/for_development/`
- **Backend Integration**: Coordinated with backend development
- **QA Handoff**: Builds shared via `builds/` folder
- **Documentation**: Updated in `docs/` for technical writer

## Automated Tasks

- Code generation for repetitive components (PasswordCard, AdaptiveDialog)
- Resource generation via `flutter_gen` (icons, fonts)
- Automated test reports via `flutter_test` and `integration_test`
