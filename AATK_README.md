# AATK Smart Library

**Цифровая библиотека учебников 10–11 классов Казахстана**, построенная на базе [BookLore](https://github.com/booklore-app/booklore).

---

## Что изменено относительно оригинального BookLore

| Компонент | Файл | Что добавлено |
|:---|:---|:---|
| **SQL-миграция** | `booklore-api/.../db/migration/V122__Add_AATK_Smart_Library_fields.sql` | Поля `grade INT` и `subject VARCHAR(255)` в таблице `book_metadata` |
| **Entity (Java)** | `BookMetadataEntity.java` | Поля `grade`, `subject` |
| **DTO (Java)** | `BookMetadata.java` | Поля `grade`, `subject` |
| **Request (Java)** | `CreatePhysicalBookRequest.java` | Поля `grade`, `subject` |
| **Service (Java)** | `PhysicalBookService.java` | Маппинг `grade` и `subject` при создании книги |
| **Model (Angular)** | `book.model.ts` | Поля `grade`, `subject` в `BookMetadata` и `CreatePhysicalBookRequest` |
| **Filter config** | `book-filter.config.ts` | Новые фильтры `grade` (по классу) и `subject` (по предмету) |
| **Filter logic** | `sidebar-filter.ts` | Логика фильтрации по `grade` и `subject` |
| **Скрипт импорта** | `scripts/import_csv.sh`, `scripts/import_csv.py` | Импорт учебников из `data.csv` через API |
| **Данные** | `data.csv` | 12 учебников (Алгебра, 10–11 класс) с okulyk.kz |
| **Docker override** | `docker-compose.override.yml` | Монтирование CSV и скриптов в контейнер |

---

## Быстрый старт (Docker)

### 1. Клонирование

```bash
git clone https://github.com/strongaidyn/aatk-smart-library.git
cd aatk-smart-library
```

### 2. Запуск

```bash
cd example-docker
cp ../docker-compose.override.yml .
docker compose up -d
```

Приложение будет доступно по адресу: **http://localhost:6060**

### 3. Первоначальная настройка

1. Откройте **http://localhost:6060** в браузере.
2. Создайте учётную запись администратора (при первом запуске).
3. Создайте библиотеку (Library) — укажите путь `/books`.

### 4. Импорт учебников из CSV

#### Вариант A: Bash-скрипт (рекомендуется)

```bash
# Из корня проекта
export API_URL="http://localhost:6060/api/v1"
export LIBRARY_ID=1
export AUTH_TOKEN="ваш_jwt_токен"

bash scripts/import_csv.sh data.csv
```

#### Вариант B: Python-скрипт

```bash
pip install requests
python3 scripts/import_csv.py data.csv
```

> **Получение JWT-токена:** Авторизуйтесь через UI, откройте DevTools → Network → найдите запрос к `/api/v1/` → скопируйте значение заголовка `Authorization`.

### 5. Проверка импорта (5 записей)

```bash
curl -s http://localhost:6060/api/v1/books | python3 -m json.tool | head -n 100
```

Или откройте **http://localhost:6060** и используйте фильтры:
- **Grade** → `10 класс` или `11 класс`
- **Subject** → `Алгебра`

---

## Структура проекта

```
aatk-smart-library/
├── booklore-api/                    # Java Spring Boot backend
│   └── src/main/
│       ├── java/org/booklore/
│       │   ├── model/
│       │   │   ├── entity/BookMetadataEntity.java   ← grade, subject
│       │   │   └── dto/BookMetadata.java            ← grade, subject
│       │   ├── controller/BookController.java
│       │   └── service/book/PhysicalBookService.java ← grade, subject
│       └── resources/db/migration/
│           └── V122__Add_AATK_Smart_Library_fields.sql
├── booklore-ui/                     # Angular frontend
│   └── src/app/features/book/
│       ├── model/book.model.ts                      ← grade, subject
│       └── components/book-browser/
│           ├── book-filter/book-filter.config.ts    ← фильтры
│           └── filters/sidebar-filter.ts            ← логика фильтрации
├── scripts/
│   ├── import_csv.sh                # Bash-скрипт импорта
│   └── import_csv.py                # Python-скрипт импорта
├── data.csv                         # Данные учебников с okulyk.kz
├── docker-compose.override.yml      # Docker override для AATK
├── example-docker/
│   └── docker-compose.yml           # Основной Docker Compose
└── AATK_README.md                   # Эта документация
```

---

## Структура базы данных (новые поля)

```sql
-- Миграция V122
ALTER TABLE book_metadata
  ADD COLUMN grade   INT,            -- 10 или 11 (класс)
  ADD COLUMN subject VARCHAR(255);   -- Предмет (Алгебра, Физика, ...)
```

Существующие поля BookLore, которые используются:
- `title` — название учебника
- `publisher` — издательство
- `published_date` — год издания
- `language` — язык обучения
- `description` — описание
- `isbn_13` / `isbn_10` — ISBN

---

## Оставшиеся задачи (TODO)

- [ ] **Figma-дизайн:** Применить брендинг AATK (логотип, цветовая схема)
- [ ] **PDF-файлы:** Настроить автоматическую загрузку PDF через BookDrop
- [ ] **Полный импорт:** Расширить парсер okulyk.kz на все предметы
- [ ] **Локализация:** Добавить казахский и русский языки интерфейса
- [ ] **Поиск:** Настроить полнотекстовый поиск по учебникам
- [ ] **CI/CD:** Настроить GitHub Actions для автосборки Docker-образа
- [ ] **Деплой:** Развернуть на VPS / Vercel / Railway
- [ ] **Мобильная версия:** Адаптировать UI для мобильных устройств
- [ ] **Обложки:** Автоматическое скачивание обложек учебников
- [ ] **Роли:** Настроить роли «Ученик» и «Учитель»

---

## Лицензия

Оригинальный проект BookLore распространяется под лицензией **AGPL-3.0**.
Все изменения в рамках AATK Smart Library наследуют эту лицензию.
