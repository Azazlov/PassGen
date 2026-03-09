# 🔍 Комплексный поисковый запрос для сбора информации о Flutter UI/UX 2025-2026

**Дата составления:** 8 марта 2026 г.
**Цель:** Получить актуальную информацию о лучших практиках Flutter UI/UX перед реализацией улучшений

---

## 📋 СТРУКТУРА ЗАПРОСОВ

### Категория 1: Адаптивный дизайн и макеты

#### Запрос 1.1: Adaptive Layout
```
Flutter adaptive layout two-pane tablet desktop 2025 2026 best practices
```

**Что ищем:**
- Новые виджеты для адаптивных макетов
- Best practices для tablet/desktop макетов
- Примеры двухпанельных макетов
- NavigationRail vs Drawer для планшетов

**Ожидаемые результаты:**
- Flutter official documentation updates
- Medium/dev.to статьи от Flutter team
- GitHub репозитории с примерами

---

#### Запрос 1.2: Material 3 Adaptive
```
Flutter Material 3 responsive design breakpoints 2025 2026
```

**Что ищем:**
- Material 3 guidelines для адаптивности
- Рекомендуемые брейкпоинты (600/900/1200dp)
- Адаптивные компоненты Material 3
- Color scheme для разных размеров экрана

---

#### Запрос 1.3: Window Size Classes
```
Flutter window size classes breakpoints mobile tablet desktop 2025 2026
```

**Что ищем:**
- Новые WindowSizeClass API
- Рекомендации по брейкпоинтам
- Примеры использования в production

---

### Категория 2: Доступность (Accessibility)

#### Запрос 2.1: Semantics Best Practices
```
Flutter Semantics accessibility screen reader TalkBack VoiceOver 2025 2026
```

**Что ищем:**
- Новые возможности Semantics widget
- Best practices для screen readers
- Common mistakes и как избежать
- Testing с TalkBack/VoiceOver

**Ожидаемые результаты:**
- Flutter accessibility updates
- Accessibility audit tools
- Real-world examples

---

#### Запрос 2.2: Color Contrast WCAG
```
Flutter color contrast WCAG AA AAA checker 2025 2026 accessibility
```

**Что ищем:**
- Инструменты для проверки контрастности
- WCAG 2.2 обновления
- Автоматические checkers для Flutter
- Color palette generators с accessibility

---

#### Запрос 2.3: Keyboard Navigation
```
Flutter keyboard navigation focus management desktop 2025 2026
```

**Что ищем:**
- Focus traversal improvements
- Keyboard shortcuts для desktop
- Focus indicators best practices
- Desktop keyboard navigation patterns

---

### Категория 3: Производительность

#### Запрос 3.1: ListView Keys Performance
```
Flutter ListView keys ValueKey PageStorageKey performance 2025 2026
```

**Что ищем:**
- Когда использовать ValueKey vs PageStorageKey
- Performance benchmarks
- Common mistakes с ключами
- New key types в Flutter

**Ожидаемые результаты:**
- Flutter performance documentation
- Benchmark comparisons
- Real-world case studies

---

#### Запрос 3.2: Widget Rebuild Optimization
```
Flutter widget rebuild optimization const selector provider 2025 2026
```

**Что ищем:**
- const constructor best practices
- Provider select vs watch performance
- Memoization techniques
- DevTools for rebuild analysis

---

#### Запрос 3.3: Large Lists Performance
```
Flutter large lists ListView.builder performance optimization 2025 2026
```

**Что ищем:**
- ListView.builder optimizations
- Lazy loading patterns
- Image caching в списках
- Memory management

---

### Категория 4: Material 3 Updates

#### Запрос 4.1: Material 3 New Components
```
Flutter Material 3 new components widgets 2025 2026 updates
```

**Что ищем:**
- Новые виджеты Material 3
- Deprecated компоненты
- Migration guides
- Component comparison (M2 vs M3)

---

#### Запрос 4.2: Material 3 Color System
```
Flutter Material 3 color scheme dynamic color theming 2025 2026
```

**Что ищем:**
- Dynamic color extraction
- ColorScheme.fromSeed best practices
- Dark mode improvements
- Custom color schemes

---

### Категория 5: Navigation Patterns

#### Запрос 5.1: Adaptive Navigation
```
Flutter adaptive navigation BottomNavigationBar NavigationRail 2025 2026
```

**Что ищем:**
- Когда использовать BottomNavigationBar vs NavigationRail
- Adaptive navigation patterns
- Deep linking с адаптивной навигацией
- State management для навигации

---

#### Запрос 5.2: Multi-pane Navigation
```
Flutter multi-pane navigation master-detail tablet desktop 2025 2026
```

**Что ищем:**
- Master-detail паттерны
- Navigation с несколькими панелями
- Back button handling на планшетах
- State preservation

---

### Категория 6: Animation & Micro-interactions

#### Запрос 6.1: Lottie Animations Flutter
```
Flutter Lottie animations micro-interactions 2025 2026 best practices
```

**Что ищем:**
- Lottie performance optimization
- File size optimization
- Animation controllers
- Common micro-interactions patterns

---

#### Запрос 6.2: Implicit Animations
```
Flutter implicit animations AnimatedContainer AnimatedSwitcher 2025 2026
```

**Что ищем:**
- Performance comparison implicit vs explicit
- New animation widgets
- Animation best practices
- Common pitfalls

---

### Категория 7: Real-world Examples

#### Запрос 7.1: Open Source Flutter Apps
```
Flutter open source apps adaptive layout accessibility 2025 2026 GitHub
```

**Что ищем:**
- Production-ready примеры
- Code quality benchmarks
- Architecture patterns
- Accessibility implementations

---

#### Запрос 7.2: Flutter Showcase
```
Flutter showcase best apps design UX 2025 2026
```

**Что ищем:**
- Award-winning Flutter apps
- Design case studies
- UX patterns
- User feedback

---

## 📊 ТАБЛИЦА ДЛЯ ДОКУМЕНТИРОВАНИЯ

### Шаблон для записи результатов

| Категория | Запрос | Источник | Ключевые выводы | Применимость |
|-----------|--------|----------|-----------------|--------------|
| Adaptive  | [query] | [url] | [findings] | [High/Med/Low] |
| A11y      | [query] | [url] | [findings] | [High/Med/Low] |
| Perf      | [query] | [url] | [findings] | [High/Med/Low] |

---

## 🎯 ПРИОРИТЕТЫ ПОИСКА

### 🔴 Высокий приоритет (искать в первую очередь)
1. **Адаптивные макеты** — основа для всех улучшений
2. **Semantics/Accessibility** — критично для соответствия ТЗ
3. **Performance keys** — быстрая победа (quick win)

### 🟡 Средний приоритет
4. **Material 3 updates** — для актуальности дизайн-системы
5. **Navigation patterns** — для консистентности
6. **Color contrast** — для доступности

### 🟢 Низкий приоритет
7. **Animation best practices** — полировка
8. **Open source examples** — вдохновение

---

## 📁 ИСТОЧНИКИ ДЛЯ ПРОВЕРКИ

### Официальные источники
- [Flutter.dev Blog](https://medium.com/flutter)
- [Flutter YouTube](https://www.youtube.com/c/flutterdev)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)

### Сообщество
- [r/FlutterDev](https://www.reddit.com/r/FlutterDev/)
- [Flutter Community (Medium)](https://medium.com/flutter-community)
- [Dev.to Flutter](https://dev.to/t/flutter)
- [Stack Overflow Flutter](https://stackoverflow.com/questions/tagged/flutter)

### GitHub
- [Flutter official](https://github.com/flutter)
- [Flutter samples](https://github.com/flutter/samples)
- [Awesome Flutter](https://github.com/Solido/awesome-flutter)

---

## ✅ ЧЕК-ЛИСТ ПРОВЕРКИ

Перед началом реализации проверить:

### Адаптивность
- [ ] Найдены актуальные брейкпоинты (2025-2026)
- [ ] Изучены двухпанельные макеты
- [ ] Понятны паттерны для tablet/desktop

### Доступность
- [ ] Изучены Semantics best practices
- [ ] Найдены инструменты проверки контрастности
- [ ] Понятны требования WCAG AA

### Производительность
- [ ] Изучены best practices для ключей
- [ ] Понятна оптимизация rebuild
- [ ] Найдены DevTools для анализа

---

## 📝 ШАБЛОН ДЛЯ ЗАПИСЕЙ

```markdown
## [Тема]

**Запрос:** [search query]
**Дата поиска:** YYYY-MM-DD

### Найденные источники
1. [Title](url) — [Brief description]
2. [Title](url) — [Brief description]

### Ключевые выводы
- [Finding 1]
- [Finding 2]
- [Finding 3]

### Применимость к PassGen
- [ ] High: [что внедрить]
- [ ] Medium: [что рассмотреть]
- [ ] Low: [что отложить]

### Код примеры
```dart
// [Example code]
```
```

---

## 🚀 СЛЕДУЮЩИЕ ШАГИ

1. **Выполнить поисковые запросы** (1-2 часа)
2. **Документировать результаты** (2-3 часа)
3. **Обновить IMPROVEMENT_RECOMMENDATIONS_PLAN.md** (1 час)
4. **Приступить к реализации** с учётом новых данных

---

**Документ готов к использованию для сбора актуальной информации.** 🔍

**Версия:** 1.0
**Дата:** 2026-03-08
**Статус:** ✅ Готов к поиску
