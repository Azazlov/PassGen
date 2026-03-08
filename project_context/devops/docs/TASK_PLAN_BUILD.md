# 🏗️ План задач: Сборка и развёртывание PassGen

**Дата создания:** 2026-03-08  
**Версия:** 1.0  
**Статус:** ⏳ В работе  
**Приоритет:** 🔴 Высокий (для релиза)  
**Оценка:** 10 часов  

---

## 1. ЦЕЛЬ ЭТАПА

Обеспечить автоматизированную сборку PassGen для всех платформ:
- Linux (native binary + tar.gz)
- Windows (EXE + ZIP)
- Android (APK + AAB)
- Web (static files)

**Целевые метрики:**
- Сборка одной командой
- Полная автоматизация
- Документация актуальна

---

## 2. ЗАДАЧИ

### Задача 1.1: Тестирование build_android.sh

**Статус:** ⏳ Ожидает  
**Оценка:** 1 час  
**Фактически:** TBD  

#### Описание
Протестировать скрипт сборки Android на работоспособность.

#### Файлы
- `project_context/devops/scripts/build_android.sh`

#### Чек-лист
- [ ] Flutter установлен
- [ ] Java установлен
- [ ] Android SDK настроен
- [ ] Запуск `./build_android.sh release`
- [ ] Проверка `build/android/` на наличие APK
- [ ] Проверка наличия AAB

#### Команды для теста
```bash
cd project_context/devops/scripts
chmod +x build_android.sh
./build_android.sh release

# Проверка результатов
ls -lh ../../build/android/
```

#### Критерии приёмки
- [ ] APK создан в `build/android/`
- [ ] AAB создан
- [ ] Ошибок нет
- [ ] Логи сохранены

---

### Задача 1.2: Тестирование build_desktop.sh (Linux)

**Статус:** ⏳ Ожидает  
**Оценка:** 1 час  
**Фактически:** TBD  

#### Описание
Протестировать скрипт сборки для Linux.

#### Файлы
- `project_context/devops/scripts/build_desktop.sh`

#### Чек-лист
- [ ] Запуск `./build_desktop.sh linux release`
- [ ] Проверка `build/desktop/linux/`
- [ ] Проверка tar.gz пакета

#### Команды для теста
```bash
./build_desktop.sh linux release

# Проверка результатов
ls -lh ../../build/desktop/linux/
ls -lh ../../build/deployments/
```

#### Критерии приёмки
- [ ] Binary создан в `build/desktop/linux/`
- [ ] tar.gz пакет создан
- [ ] Ошибок нет

---

### Задача 2.1: Создание build_android.ps1

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Описание
Создать PowerShell версию скрипта для Android.

#### Файлы
- `project_context/devops/scripts/build_android.ps1`

#### Содержание
```powershell
param([string]$BuildType = "release")

$ProjectRoot = Split-Path -Parent $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
$OutputDir = Join-Path $ProjectRoot "build\android"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

flutter pub get
flutter clean

if ($BuildType -eq "debug") {
    flutter build apk --debug
} else {
    flutter build apk --release --split-per-abi
}

# Copy artifacts
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
# ... copy logic ...
```

#### Критерии приёмки
- [ ] Скрипт создаётся
- [ ] Запускается без ошибок
- [ ] APK создан

---

### Задача 2.2: Создание build_desktop.ps1

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Описание
Создать PowerShell версию скрипта для Desktop.

#### Файлы
- `project_context/devops/scripts/build_desktop.ps1`

#### Содержание
```powershell
param(
    [string]$Target = "windows",
    [string]$BuildType = "release"
)

# Configuration
# ... setup ...

flutter config --enable-${Target}-desktop
flutter build $Target $(if ($BuildType -eq "debug") { "--debug" } else { "--release" })

# Copy artifacts
# ... copy logic ...
```

#### Критерии приёмки
- [ ] Скрипт создаётся
- [ ] Запускается без ошибок
- [ ] Binary создан

---

### Задача 2.3: Создание build_all.ps1

**Статус:** ⏳ Ожидает  
**Оценка:** 1 час  
**Фактически:** TBD  

#### Описание
Создать unified PowerShell скрипт для всех платформ.

#### Файлы
- `project_context/devops/scripts/build_all.ps1`

#### Содержание
```powershell
param([string]$BuildType = "release")

$scripts = @("build_android.ps1", "build_desktop.ps1", "build_web.ps1")

foreach ($script in $scripts) {
    $scriptPath = Join-Path $PSScriptRoot $script
    if (Test-Path $scriptPath) {
        Write-Host "Building: $script" -ForegroundColor Green
        & $scriptPath -BuildType $BuildType
    }
}
```

#### Критерии приёмки
- [ ] Скрипт создаётся
- [ ] Запускает все скрипты последовательно
- [ ] Ошибок нет

---

### Задача 3.1: Создание DEPLOYMENT_GUIDE.md

**Статус:** ⏳ Ожидает  
**Оценка:** 1.5 часа  
**Фактически:** TBD  

#### Описание
Создать полное руководство по развёртыванию.

#### Файлы
- `project_context/devops/docs/DEPLOYMENT_GUIDE.md`

#### Содержание
```markdown
# 📦 Руководство по развёртыванию PassGen

## 1. Требования
- Flutter SDK ^3.9.0
- Java JDK 11+
- Android SDK

## 2. Сборка
### Android
./build_android.sh release

### Linux
./build_desktop.sh linux release

### Windows
.\build_desktop.ps1 -Target windows

## 3. Развёртывание
### Test
./deploy_test.sh [platform]

### Production
./deploy_prod.sh [platform]
```

#### Критерии приёмки
- [ ] Документ создан
- [ ] Все команды работают
- [ ] Troubleshooting раздел есть

---

### Задача 3.2: Обновление devops/README.md

**Статус:** ⏳ Ожидает  
**Оценка:** 1 час  
**Фактически:** TBD  

#### Описание
Обновить README с актуальной информацией.

#### Файлы
- `project_context/devops/README.md`

#### Содержание
```markdown
# DevOps для PassGen

## Структура
scripts/ - Скрипты сборки
ci_cd/ - CI/CD конфигурации
docs/ - Документация
logs/ - Логи сборок

## Быстрый старт
./scripts/build_all.sh release

## Документация
См. docs/DEPLOYMENT_GUIDE.md
```

#### Критерии приёмки
- [ ] README обновлён
- [ ] Структура описана
- [ ] Примеры есть

---

### Задача 4.1: Создание GitHub Actions workflow

**Статус:** ⏳ Ожидает  
**Оценка:** 2 часа  
**Фактически:** TBD  

#### Описание
Настроить автоматическую сборку при push/tag.

#### Файлы
- `.github/workflows/build.yml`

#### Содержание
```yaml
name: Build and Release

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: cd project_context/devops/scripts && ./build_android.sh release
      - uses: actions/upload-artifact@v3
        with:
          name: android-build
          path: build/android/*.apk

  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: cd project_context/devops/scripts && ./build_desktop.sh linux release
      - uses: actions/upload-artifact@v3
        with:
          name: linux-build
          path: build/desktop/linux/
```

#### Критерии приёмки
- [ ] Workflow создан
- [ ] Сборка запускается
- [ ] Артефакты загружаются

---

### Задача 5.1: Улучшение логирования

**Статус:** ⏳ Ожидает  
**Оценка:** 1 час  
**Фактически:** TBD  

#### Описание
Добавить детальное логирование и метрики.

#### Файлы
- `project_context/devops/scripts/build_all.sh`

#### Улучшения
```bash
# Добавить JSON логирование
log_build_info() {
    local platform=$1
    local status=$2
    local duration=$3
    
    echo "{\"timestamp\":\"$(date -Iseconds)\",\"platform\":\"$platform\",\"status\":\"$status\",\"duration\":\"$duration\"}" >> "$LOGS_DIR/build_metrics.json"
}

# Добавить тайминг
start_time=$(date +%s)
# ... build ...
end_time=$(date +%s)
duration=$((end_time - start_time))
log_build_info "android" "success" "${duration}s"
```

#### Критерии приёмки
- [ ] Логи в JSON формате
- [ ] Метрики записываются
- [ ] Тайминг считается

---

## 3. КРИТЕРИИ УСПЕХА ЭТАПА

- [ ] Все 9 задач выполнены
- [ ] Сборка работает для всех платформ
- [ ] PowerShell скрипты работают
- [ ] Документация полная
- [ ] CI/CD настроен

---

## 4. ЗАВИСИМОСТИ

### Блокирующие
- ✅ Этап 8 (Критические исправления) — для стабильности кода

### Зависит от
- ✅ Flutter SDK установлен
- ✅ Java установлен (для Android)
- ✅ Android SDK настроен

### Блокирует
- ⬜ Этап 12 (Финальная подготовка к релизу)

---

## 5. РИСКИ

| Риск | Вероятность | Влияние | Митигация |
|---|---|---|---|
| Нет Android SDK | Средняя | Высокое | Документировать установку |
| Проблемы с подписью APK | Низкая | Высокое | Создать debug ключ |
| CI/CD не работает | Средняя | Среднее | Тестировать локально |

---

## 6. ХРОНОЛОГИЯ ВЫПОЛНЕНИЯ

### День 1 (2026-03-08)
- [x] Аудит существующих скриптов
- [x] Создание стратегии
- [ ] Задача 1.1: Тест build_android.sh
- [ ] Задача 1.2: Тест build_desktop.sh

### День 2 (2026-03-09)
- [ ] Задача 2.1: build_android.ps1
- [ ] Задача 2.2: build_desktop.ps1
- [ ] Задача 2.3: build_all.ps1

### День 3 (2026-03-10)
- [ ] Задача 3.1: DEPLOYMENT_GUIDE.md
- [ ] Задача 3.2: devops/README.md
- [ ] Задача 4.1: GitHub Actions workflow

### День 4 (2026-03-11)
- [ ] Задача 5.1: Улучшение логирования
- [ ] Финальное тестирование

---

## 7. ОТВЕТСТВЕННЫЕ

| Роль | Ответственный |
|---|---|
| Build Engineer | AI Build Agent |
| Разработчик | AI Flutter Agent |
| Код-ревью | AI Code Reviewer |

---

## 8. ПРИЛОЖЕНИЯ

### A. Команды для сборки
```bash
# Все платформы (Bash)
./project_context/devops/scripts/build_all.sh release

# Android
./project_context/devops/scripts/build_android.sh release

# Linux
./project_context/devops/scripts/build_desktop.sh linux release

# Windows (PowerShell)
.\project_context\devops\scripts\build_all.ps1 release
```

### B. Структура output
```
build/
├── android/
│   ├── app-release-*.apk
│   └── app-release-*.aab
├── desktop/
│   ├── linux/
│   │   └── pass_gen
│   ├── windows/
│   │   └── pass_gen.exe
│   └── macos/
│       └── pass_gen.app
├── web/
│   └── index.html
└── deployments/
    ├── passgen-linux-*.tar.gz
    └── passgen-windows-*.zip
```

---

**План создал:** AI Build Engineer  
**Дата создания:** 2026-03-08  
**Версия:** 1.0  
**Статус:** ⏳ В работе
