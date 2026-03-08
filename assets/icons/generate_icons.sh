#!/bin/bash

# Скрипт генерации иконок для PassGen
# Требует установленного Inkscape или ImageMagick

set -e

echo "🎨 Генерация иконок PassGen..."
echo ""

ICONS_DIR="assets/icons"
SVG_MAIN="$ICONS_DIR/passgen_icon.svg"
SVG_FG="$ICONS_DIR/passgen_icon_fg.svg"
PNG_MAIN="$ICONS_DIR/app_icon_1024.png"
PNG_FG="$ICONS_DIR/app_icon_fg_1024.png"

# Проверка наличия исходных файлов
if [ ! -f "$SVG_MAIN" ]; then
    echo "❌ Ошибка: $SVG_MAIN не найден"
    exit 1
fi

if [ ! -f "$SVG_FG" ]; then
    echo "❌ Ошибка: $SVG_FG не найден"
    exit 1
fi

# Проверка доступности инструментов
if command -v inkscape &> /dev/null; then
    echo "✅ Inkscape найден"
    CONVERTER="inkscape"
elif command -v magick &> /dev/null; then
    echo "✅ ImageMagick найден"
    CONVERTER="imagemagick"
elif command -v convert &> /dev/null; then
    echo "✅ ImageMagick (convert) найден"
    CONVERTER="imagemagick"
else
    echo "❌ Не найден Inkscape или ImageMagick"
    echo ""
    echo "Установите один из инструментов:"
    echo "  macOS:   brew install inkscape"
    echo "  Linux:   sudo apt install inkscape"
    echo "  Windows: https://inkscape.org/"
    echo ""
    echo "Или сконвертируйте SVG в PNG вручную:"
    echo "  https://cloudconvert.com/svg-to-png"
    exit 1
fi

# Конвертация
echo ""
echo "🔄 Конвертация SVG в PNG..."

if [ "$CONVERTER" = "inkscape" ]; then
    echo "  → $PNG_MAIN"
    inkscape --export-type=png --export-width=1024 --export-height=1024 \
      --export-filename="$PNG_MAIN" "$SVG_MAIN"
    
    echo "  → $PNG_FG"
    inkscape --export-type=png --export-width=1024 --export-height=1024 \
      --export-filename="$PNG_FG" "$SVG_FG"
else
    echo "  → $PNG_MAIN"
    magick -density 300 -background none "$SVG_MAIN" "$PNG_MAIN" 2>/dev/null || \
    convert -density 300 -background none "$SVG_MAIN" "$PNG_MAIN"
    
    echo "  → $PNG_FG"
    magick -density 300 -background none "$SVG_FG" "$PNG_FG" 2>/dev/null || \
    convert -density 300 -background none "$SVG_FG" "$PNG_FG"
fi

echo ""
echo "✅ PNG иконки созданы"
echo ""

# Проверка размеров
echo "📏 Проверка размеров..."
if command -v identify &> /dev/null; then
    identify "$PNG_MAIN" "$PNG_FG"
else
    echo "  (установите ImageMagick для проверки размеров)"
fi

echo ""
echo "🚀 Генерация иконок для платформ..."
echo ""

# Запуск flutter_launcher_icons
flutter pub get
flutter pub run flutter_launcher_icons

echo ""
echo "✅ Готово!"
echo ""
echo "📱 Иконки сгенерированы для:"
echo "  • Android"
echo "  • iOS"
echo "  • Windows"
echo "  • Linux"
echo ""
echo "🔍 Проверьте иконки в соответствующих папках:"
echo "  • android/app/src/main/res/mipmap-*/"
echo "  • ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "  • windows/runner/resources/"
echo "  • linux/flutter/assets/"
echo ""
