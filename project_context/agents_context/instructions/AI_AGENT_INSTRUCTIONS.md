# 📋 Инструкция для ИИ-агентов: Работа с проектом PassGen

**Версия:** 3.0
**Дата:** 8 марта 2026 г.
**Статус:** ✅ Актуально

---

## 1. ОБЩАЯ СТРУКТУРА PROJECT_CONTEXT

```
project_context/
├── agents_context/              # 📚 ОБЩИЙ КОНТЕКСТ (для всех агентов)
│   ├── README.md                # Навигация по контексту
│   ├── common/                  # Общие документы проекта
│   ├── planning/                # Планы и ТЗ
│   ├── progress/                # Текущий прогресс
│   ├── stages/                  # Отчёты по этапам
│   ├── reviews/                 # Код-ревью и аудиты
│   ├── logs/                    # Логи операций
│   ├── diagrams/                # Диаграммы и схемы
│   └── instructions/            # Общие инструкции для агентов
│
├── frontend_engineer/           # 👨‍💻 FRONTEND РАЗРАБОТЧИК
├── qa_engineer/                 # 🧪 QA ИНЖЕНЕР
├── data_security_specialist/    # 🔐 DATA & SECURITY
├── ui_ux_designer/              # 🎨 UI/UX ДИЗАЙНЕР
├── technical_writer/            # 📝 ТЕХНИЧЕСКИЙ ПИСАТЕЛЬ
└── devops_engineer/             # ⚙️ DEVOPS ИНЖЕНЕР
```

**Важно:** Все документы хранятся в централизованной структуре `agents_context/` и персональных папках агентов.

---

## 2. СОХРАНЕНИЕ ДОКУМЕНТОВ

### 2.1 Планы развития → planning/

**Когда использовать:** Создание нового плана или обновление существующего

**Формат файла:** `PROJECT_PLAN.md` или `TASK_PLAN_YYYY-MM-DD.md`

**Структура:**
```markdown
# 📋 План [Название]

**Дата:** YYYY-MM-DD
**Версия:** X.X
**Статус:** Черновик/Актуально/Завершено

## 1. Цель
[Описание цели]

## 2. Задачи
- [ ] Задача 1
- [ ] Задача 2

## 3. Сроки
[Дедлайны]

## 4. Ресурсы
[Необходимые ресурсы]
```

**Пример команды:**
```
Сохрани этот план в project_context/planning/PROJECT_PLAN.md
```

---

### 2.2 Отчёты по этапам → stages/

**Когда использовать:** Завершение этапа разработки

**Формат файла:** `STAGE_N_COMPLETE.md` где N — номер этапа

**Структура:**
```markdown
# 📋 Отчёт о завершении Этапа N: [Название]

**Дата завершения:** YYYY-MM-DD
**Статус:** ✅ ЗАВЕРШЕНО

## 1. Реализованный функционал
[Таблица с функциями]

## 2. Созданные файлы
[Список файлов]

## 3. Обновлённые файлы
[Список файлов]

## 4. Проверка работоспособности
[Результаты тестов]

## 5. Выводы
[Готовность в %]
```

**Пример команды:**
```
Создай отчёт о завершении этапа в project_context/stages/STAGE_7_COMPLETE.md
```

---

### 2.3 Код-ревью → reviews/

**Когда использовать:** Проведение ревью кода

**Формат файла:** `CODE_REVIEW_YYYY-MM-DD.md` или `TOPIC_REVIEW.md`

**Структура:**
```markdown
# 🔍 Код-ревью [Компонент]

**Дата:** YYYY-MM-DD
**Основание:** [ТЗ/Стандарты]

## 1. Проверяемые файлы
[Таблица файлов]

## 2. Критерии проверки
[Таблица критериев]

## 3. Найденные проблемы
[Список проблем с приоритетами]

## 4. Рекомендации
[Список рекомендаций]

## 5. Итоговая оценка
[Процент соответствия]
```

**Пример команды:**
```
Сохрани код-ревью в project_context/reviews/UI_UX_REVIEW.md
```

---

### 2.4 Логи операций → logs/

**Когда использовать:** Логирование важных операций

**Формат файла:** `LOG_YYYY-MM-DD_TOPIC.md`

**Структура:**
```markdown
# 📝 Лог операций: [Тема]

**Дата:** YYYY-MM-DD
**Операция:** [Название]

## Хронология

### Время: HH:MM
- Действие 1
- Результат 1

### Время: HH:MM
- Действие 2
- Результат 2

## Итоги
[Краткий итог]
```

**Пример команды:**
```
За логируй эту операцию в project_context/logs/LOG_2026-03-07_MERGE.md
```

---

### 2.5 Текущий прогресс → current_progress/

**Когда использовать:** Обновление текущего состояния проекта

**Формат файла:** `CURRENT_PROGRESS.md`

**Структура:**
```markdown
# 📊 Текущий прогресс проекта PassGen

**Дата обновления:** YYYY-MM-DD
**Версия:** X.X.X
**Статус:** Готов к релизу/В разработке

## 1. Общий прогресс
[Диаграмма прогресса по разделам]

## 2. Статистика
[Таблица метрик]

## 3. Завершённые этапы
[Список этапов]

## 4. Открытые задачи
[Список задач]

## 5. Следующие шаги
[План действий]
```

**Пример команды:**
```
Обнови текущий прогресс в project_context/current_progress/CURRENT_PROGRESS.md
```

---

### 2.6 Диаграммы → agents_context/diagrams/

**Когда использовать:** Создание диаграмм и схем

**Формат файлов:**
- `*.puml` — PlantUML
- `*.drawio` — draw.io
- `*.md` — Описание диаграммы

**Структура описания:**
```markdown
# 📊 Описание диаграммы [Название]

**Версия:** X.X
**Дата:** YYYY-MM-DD

## 1. Обзор
[Назначение диаграммы]

## 2. Компоненты
[Описание элементов]

## 3. Взаимодействия
[Последовательности]

## 4. Визуализация
[Инструкции по просмотру]
```

**Пример команды:**
```
Сохрани диаграмму в agents_context/diagrams/database_interaction_diagram.puml
```

---

### 2.7 Персональные папки агентов

**Когда использовать:** Работа в рамках роли агента

**Папки:**
- `frontend_engineer/` — Frontend разработчик
- `qa_engineer/` — QA инженер
- `data_security_specialist/` — Data & Security специалист
- `ui_ux_designer/` — UI/UX дизайнер
- `technical_writer/` — Технический писатель
- `devops_engineer/` — DevOps инженер

**Пример команды:**
```
Сохрани отчёт в qa_engineer/reports/TEST_REPORT_2026-03-08.md
```

---

## 3. ИНСТРУКЦИИ ДЛЯ ИИ-АГЕНТОВ

### 3.1 Перед началом работы

1. **Проверь текущий прогресс:**
   ```
   Прочитай agents_context/progress/CURRENT_PROGRESS.md
   ```

2. **Ознакомься с планом:**
   ```
   Прочитай agents_context/planning/COMPREHENSIVE_TASK_PLAN.md
   ```

3. **Проверь ТЗ:**
   ```
   Прочитай agents_context/planning/passgen.tz.md
   ```

4. **Прочитай инструкцию своего агента:**
   ```
   Прочитай agents_context/instructions/[YOUR_ROLE]_INSTRUCTIONS.md
   ```

5. **Ознакомься с навигацией:**
   ```
   Прочитай agents_context/README.md
   ```

---

### 3.2 При выполнении задачи

1. **Создай план задачи:**
   ```
   Создай план в agents_context/planning/TASK_PLAN_YYYY-MM-DD.md
   ```

2. **Выполни задачу:**
   ```
   [Выполнение задачи в коде или документации]
   ```

3. **За логируй результат:**
   ```
   Создай лог в agents_context/logs/LOG_YYYY-MM-DD_TASK.md
   ```

4. **Для агентов — используй свою папку:**
   ```
   QA Engineer: qa_engineer/reports/TEST_REPORT_YYYY-MM-DD.md
   Frontend: frontend_engineer/docs/FEATURE_DOC.md
   DevOps: devops_engineer/docs/DEPLOYMENT_REPORT.md
   ```

---

### 3.3 После завершения задачи

1. **Обнови прогресс:**
   ```
   Обнови agents_context/progress/CURRENT_PROGRESS.md
   ```

2. **Создай отчёт об этапе:**
   ```
   Создай отчёт в agents_context/stages/STAGE_N_COMPLETE.md
   ```

3. **Проведи ревью:**
   ```
   Создай ревью в agents_context/reviews/CODE_REVIEW_YYYY-MM-DD.md
   ```

4. **Закоммить изменения:**
   ```bash
   git add .
   git commit -m "Завершён этап N: [Название]"
   git push
   ```

---

## 4. СОГЛАШЕНИЯ ОБ ИМЕНОВАНИИ

### 4.1 Файлы планов
- `PROJECT_PLAN.md` — основной план проекта
- `TASK_PLAN_YYYY-MM-DD.md` — план задачи на дату
- `SPRINT_PLAN_N.md` — план спринта N

### 4.2 Файлы отчётов
- `STAGE_N_COMPLETE.md` — отчёт о завершении этапа N
- `WEEKLY_REPORT_YYYY-WW.md` — недельный отчёт (WW — неделя)

### 4.3 Файлы ревью
- `CODE_REVIEW_YYYY-MM-DD.md` — ревью кода на дату
- `TOPIC_REVIEW.md` — тематическое ревью

### 4.4 Файлы логов
- `LOG_YYYY-MM-DD_TOPIC.md` — лог операции на дату
- `MEETING_YYYY-MM-DD.md` — лог встречи

### 4.5 Файлы диаграмм
- `[component]_diagram.puml` — PlantUML диаграмма
- `[component]_diagram.drawio` — draw.io диаграмма
- `[component]_diagram_description.md` — описание

---

## 5. ВЕРСИОНИРОВАНИЕ ДОКУМЕНТОВ

### 5.1 Формат версии
```
MAJOR.MINOR.PATCH
```

- **MAJOR** — крупные изменения архитектуры
- **MINOR** — добавление функциональности
- **PATCH** — исправления и уточнения

### 5.1 Статусы документов
- `Черновик` — начальная версия
- `На рассмотрении` — ожидает утверждения
- `Актуально` — утверждённая версия
- `Завершено` — работа завершена
- `Устарело` — заменено новой версией

### 5.3 История изменений
В конце каждого файла:
```markdown
## История изменений

| Версия | Дата | Автор | Изменения |
|---|---|---|---|
| 1.0 | 2026-03-07 | AI | Первая версия |
| 1.1 | 2026-03-08 | AI | Добавлены разделы |
```

---

## 6. ШАБЛОНЫ ДОКУМЕНТОВ

### 6.1 Шаблон плана
```markdown
# 📋 План [Название]

**Дата:** YYYY-MM-DD
**Версия:** 1.0
**Статус:** Черновик

## 1. Цель
[Описание]

## 2. Задачи
- [ ] Задача 1
- [ ] Задача 2

## 3. Сроки
[Дедлайны]

## 4. Ресурсы
[Ресурсы]

## 5. Критерии успеха
[Критерии]
```

### 6.2 Шаблон отчёта
```markdown
# 📋 Отчёт о завершении [Название]

**Дата:** YYYY-MM-DD
**Статус:** ✅ ЗАВЕРШЕНО

## 1. Реализовано
[Список]

## 2. Файлы
[Список файлов]

## 3. Проверка
[Результаты]

## 4. Выводы
[Готовность %]
```

### 6.3 Шаблон ревью
```markdown
# 🔍 Код-ревью [Компонент]

**Дата:** YYYY-MM-DD
**Основание:** [Стандарт]

## 1. Файлы
[Таблица]

## 2. Проблемы
[Список]

## 3. Оценка
[Процент]
```

### 6.4 Шаблон лога
```markdown
# 📝 Лог: [Тема]

**Дата:** YYYY-MM-DD

## Хронология

### HH:MM
- Действие
- Результат

## Итоги
[Итог]
```

---

## 7. ПРОВЕРКА АКТУАЛЬНОСТИ

### 7.1 Еженедельно
- [ ] Проверить актуальность `CURRENT_PROGRESS.md`
- [ ] Обновить `PROJECT_PLAN.md`
- [ ] Создать `WEEKLY_REPORT_YYYY-WW.md`

### 7.2 После этапа
- [ ] Создать `STAGE_N_COMPLETE.md`
- [ ] Провести ревью
- [ ] Обновить прогресс

### 7.3 После релиза
- [ ] Создать `RELEASE_NOTES_X.X.X.md`
- [ ] Обновить `README.md`
- [ ] Архивировать старые планы

---

## 8. ПОИСК ДОКУМЕНТОВ

### 8.1 По типу
```bash
# Планы
ls agents_context/planning/*.md

# Отчёты по этапам
ls agents_context/stages/*.md

# Код-ревью
ls agents_context/reviews/*.md

# Логи
ls agents_context/logs/*.md

# Инструкции
ls agents_context/instructions/*.md

# Папки агентов
ls frontend_engineer/
ls qa_engineer/
ls ui_ux_designer/
ls technical_writer/
ls devops_engineer/
```

### 8.2 По дате
```bash
# За март 2026
ls agents_context/*/*2026-03*.md

# За сегодня
ls agents_context/*/*$(date +%Y-%m-%d)*.md
```

### 8.3 По ключевым словам
```bash
# Поиск по всем файлам
grep -r "критический" agents_context/

# Поиск по названию
find agents_context -name "*PLAN*.md"

# Поиск в папке агента
find qa_engineer -name "*TEST*.md"
```

# Поиск по названию
find project_context -name "*PLAN*.md"
```

---

## 9. ЭКСВОРТ ДОКУМЕНТОВ

### 9.1 В PDF
```bash
# С помощью pandoc
pandoc PROJECT_PLAN.md -o PROJECT_PLAN.pdf

# С помощью wkhtmltopdf
wkhtmltopdf PROJECT_PLAN.md PROJECT_PLAN.pdf
```

### 9.2 В HTML
```bash
pandoc PROJECT_PLAN.md -o PROJECT_PLAN.html --css=style.css
```

### 9.3 Архивация
```bash
# Создать архив за месяц
tar -czvf project_context_2026-03.tar.gz project_context/
```

---

## 10. БЕЗОПАСНОСТЬ

### 10.1 Конфиденциальные данные
- ❌ Не хранить пароли в логах
- ❌ Не хранить ключи шифрования
- ✅ Использовать маскирование

### 10.2 Контроль версий
- ✅ Коммитить после каждого этапа
- ✅ Использовать понятные сообщения
- ✅ Создавать теги для релизов

### 10.3 Резервное копирование
- ✅ Еженедельно на внешний носитель
- ✅ Использовать git push
- ✅ Проверять целостность архивов

---

## 11. ПРИЛОЖЕНИЯ

### A. Список всех файлов agents_context (новая структура)

```
agents_context/
├── README.md                          # Навигация по контексту
├── common/
│   ├── README.md
│   ├── faq.md
│   └── user_guide.md
├── planning/
│   ├── passgen.tz.md                  # Техническое задание
│   ├── COMPREHENSIVE_TASK_PLAN.md     # Сводный план
│   ├── WORK_PLAN.md
│   └── TASK_PLAN_*.md
├── progress/
│   └── CURRENT_PROGRESS.md            # Текущий прогресс
├── stages/
│   ├── STAGE_1_COMPLETE.md
│   ├── STAGE_2_COMPLETE.md
│   ├── STAGE_3_4_COMPLETE.md
│   ├── STAGE_5_COMPLETE.md
│   ├── STAGE_6_COMPLETE.md
│   ├── STAGE_8_COMPLETE.md
│   ├── STAGE_9_COMPLETE.md
│   ├── STAGE_13_COMPLETE.md
│   └── FINAL_REPORT.md
├── reviews/
│   ├── CODE_REVIEW_*.md
│   ├── DATA_SECURITY_AUDIT.md
│   └── UI_UX_CODE_REVIEW.md
├── logs/
│   └── LOG_*.md
├── diagrams/
│   └── *.puml, *.drawio
└── instructions/
    ├── AI_AGENT_INSTRUCTIONS.md       # Этот файл
    ├── frontend_developer_instructions.md
    ├── QA_ENGINEER_INSTRUCTIONS.md
    ├── TECHNICAL_WRITER_INSTRUCTIONS.md
    ├── UI_UX_DESIGNER.md
    └── *.md
```

### A.1. Папки агентов

```
frontend_engineer/
├── lib/
├── test/
├── reports/
└── docs/

qa_engineer/
├── test_cases/
├── bug_reports/
├── auto_tests/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── reports/
└── checklists/

data_security_specialist/
├── security/
├── encryption/
├── audit/
└── reports/

ui_ux_designer/
└── design/
    ├── guidelines/
    ├── for_development/
    ├── assets/
    ├── animations/
    ├── prototypes/
    └── final/

technical_writer/
└── documentation/
    ├── technical/
    ├── presentation/
    └── ...

devops_engineer/
├── scripts/
├── docs/
├── logs/
└── ci_cd/
```

### B. Чек-лист для ИИ-агента (обновлённый)

```markdown
## Перед началом работы
- [ ] Прочитал agents_context/progress/CURRENT_PROGRESS.md
- [ ] Прочитал agents_context/planning/COMPREHENSIVE_TASK_PLAN.md
- [ ] Прочитал agents_context/planning/passgen.tz.md
- [ ] Прочитал agents_context/instructions/[YOUR_ROLE]_INSTRUCTIONS.md
- [ ] Ознакомился с agents_context/README.md

## Во время работы
- [ ] Создал план задачи (agents_context/planning/)
- [ ] Выполняю задачу
- [ ] Логирую результаты (agents_context/logs/)
- [ ] Использую свою папку агента

## После завершения
- [ ] Обновил CURRENT_PROGRESS.md
- [ ] Создал отчёт об этапе (agents_context/stages/)
- [ ] Провёл ревью (agents_context/reviews/)
- [ ] Закоммитил изменения
```

---

**Документ утверждён:** 8 марта 2026 г.  
**Версия:** 3.0 (Оптимизация структуры)  
**Статус:** ✅ Актуально

**Изменения в версии 3.0:**
- Удалена старая структура (дубликаты)
- Оптимизирована иерархия папок
- Обновлены все ссылки и пути

**Изменения в версии 2.0:**
- Добавлена общая папка `agents_context/` для всех агентов
- Созданы персональные папки для 6 агентов
- Обновлены все пути к документам
- Добавлена навигация через README.md
