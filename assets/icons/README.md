# 📱 Иконки приложения PassGen

## 📋 Обзор

Эта папка содержит исходные файлы иконок для генерации иконок приложения во всех форматах.

---

## 🎨 Исходные файлы

| Файл | Размер | Назначение |
|---|---|---|
| `passgen_icon.svg` | 1024x1024 | Основная иконка (SVG) |
| `passgen_icon_fg.svg` | 1024x1024 | Foreground для адаптивной иконки Android |

---

## 🔧 Как сгенерировать иконки

### Шаг 1: Конвертируйте SVG в PNG

**Вариант A: Использовать Inkscape**
```bash
# Установите Inkscape: https://inkscape.org/

# Конвертация основной иконки
inkscape --export-type=png --export-width=1024 --export-height=1024 \
  --export-filename=app_icon_1024.png passgen_icon.svg

# Конвертация foreground иконки
inkscape --export-type=png --export-width=1024 --export-height=1024 \
  --export-filename=app_icon_fg_1024.png passgen_icon_fg.svg
```

**Вариант B: Использовать ImageMagick**
```bash
# Установите ImageMagick: https://imagemagick.org/

convert -density 300 -background none passgen_icon.svg app_icon_1024.png
convert -density 300 -background none passgen_icon_fg.svg app_icon_fg_1024.png
```

**Вариант C: Онлайн конвертер**
- https://cloudconvert.com/svg-to-png
- https://svgtopng.com/

**Вариант D: Использовать Figma/Sketch**
1. Откройте SVG файл
2. Export → PNG → 1024x1024

---

### Шаг 2: Запустите генерацию иконок

```bash
# Установите зависимости
flutter pub get

# Сгенерируйте иконки для всех платформ
flutter pub run flutter_launcher_icons
```

---

## 📱 Сгенерированные иконки

После генерации будут созданы:

### Android
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (адаптивные иконки)
- `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`
- `android/app/src/main/res/mipmap-*/ic_launcher_background.png`

### iOS
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`

### Windows
- `windows/runner/resources/app_icon.ico`
- `windows/flutter/assets/app_icon.png`

### Linux
- `linux/flutter/assets/app_icon.png`
- `linux/packaging/debian/icons/*.png`

---

## 🎨 Дизайн иконки

### Цветовая схема
| Цвет | Hex | Использование |
|---|---|---|
| Primary Blue | `#2196F3` | Основной цвет замка |
| Light Blue | `#64B5F6` | Внутренняя часть, блики |
| White | `#FFFFFF` | Буква "P" |

### Элементы
- 🔒 **Замок** — символ безопасности
- **P** — первая буква PassGen
- 🔵 **Синий фон** — соответствует цветовой схеме приложения

---

## 📐 Требования к иконкам

### Android
- **Размер:** 1024x1024 px
- **Формат:** PNG
- **Адаптивные иконки:** foreground + background
- **Foreground:** центрированный, 66% площади

### iOS
- **Размер:** 1024x1024 px
- **Формат:** PNG
- **Без прозрачности**

### Windows
- **Размер:** 256x256 px (генерируется автоматически)
- **Формат:** ICO/PNG

### Linux
- **Размер:** 512x512 px (генерируется автоматически)
- **Формат:** PNG

---

## 🔍 Проверка

После генерации проверьте:

```bash
# Android
ls android/app/src/main/res/mipmap-*/ic_launcher*.png

# iOS
ls ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png

# Windows
ls windows/runner/resources/app_icon.ico

# Linux
ls linux/flutter/assets/app_icon.png
```

---

## 🛠️ Устранение проблем

### Проблема: Иконки не отображаются

**Решение:**
```bash
# Очистите кэш
flutter clean

# Переустановите зависимости
flutter pub get

# Пересоберите
flutter build <platform>
```

### Проблема: Неправильный размер

**Решение:**
- Убедитесь, что исходные PNG 1024x1024
- Проверьте `icon_size` в pubspec.yaml

### Проблема: Адаптивная иконка обрезана

**Решение:**
- Foreground должен занимать 66% площади
- Важные элементы в центре 436x436 px

---

## 📚 Дополнительные ресурсы

- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS App Icon](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Material Design Icons](https://material.io/design/iconography/)

---

**Версия:** 1.0
**Дата:** 2026-03-07
