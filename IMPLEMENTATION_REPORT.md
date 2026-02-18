# AATK Smart Library — Отчёт о реализации

**Дата:** 18 февраля 2026  
**Проект:** AATK Smart Library (форк BookLore)  
**Репозиторий:** https://github.com/strongaidyn/aatk-smart-library

---

## Выполненные задачи

### ✅ 1. Форк репозитория BookLore

- **Оригинальный репозиторий:** [booklore-app/booklore](https://github.com/booklore-app/booklore) (10.1k ⭐)
- **Форк:** [strongaidyn/aatk-smart-library](https://github.com/strongaidyn/aatk-smart-library)
- **Статус:** Успешно создан форк в приватном режиме

### ✅ 2. Модификация модели данных (Backend)

#### Файлы изменены:

| Файл | Изменения |
|:---|:---|
| `booklore-api/src/main/resources/db/migration/V122__Add_AATK_Smart_Library_fields.sql` | Добавлены поля `grade INT` и `subject VARCHAR(255)` |
| `booklore-api/src/main/java/org/booklore/model/entity/BookMetadataEntity.java` | Добавлены поля `grade`, `subject` с аннотациями JPA |
| `booklore-api/src/main/java/org/booklore/model/dto/BookMetadata.java` | Добавлены поля `grade`, `subject` в DTO |
| `booklore-api/src/main/java/org/booklore/model/dto/request/CreatePhysicalBookRequest.java` | Добавлены поля `grade`, `subject` в запрос создания книги |
| `booklore-api/src/main/java/org/booklore/service/book/PhysicalBookService.java` | Обновлён маппинг для сохранения `grade` и `subject` |

#### SQL-миграция:

```sql
-- V122__Add_AATK_Smart_Library_fields.sql
ALTER TABLE book_metadata
  ADD COLUMN grade   INT          COMMENT 'Класс обучения (10, 11)',
  ADD COLUMN subject VARCHAR(255) COMMENT 'Предмет (Алгебра, Физика, ...)';
```

### ✅ 3. Модификация модели данных (Frontend)

#### Файлы изменены:

| Файл | Изменения |
|:---|:---|
| `booklore-ui/src/app/features/book/model/book.model.ts` | Добавлены `grade`, `subject` в `BookMetadata` и `CreatePhysicalBookRequest` |
| `booklore-ui/src/app/features/book/components/book-browser/book-filter/book-filter.config.ts` | Добавлены фильтры `grade` и `subject` в `FilterType`, `FILTER_EXTRACTORS`, `FILTER_LABELS` |
| `booklore-ui/src/app/features/book/components/book-browser/filters/sidebar-filter.ts` | Добавлена логика фильтрации по `grade` и `subject` в `doesBookMatchFilter` |

#### Фильтры:

- **Grade (Класс):** Фильтр по значениям `10 класс`, `11 класс` (numeric ID)
- **Subject (Предмет):** Фильтр по строковым значениям (`Алгебра`, `Физика`, и т.д.)

### ✅ 4. Скрипт импорта CSV

#### Созданные файлы:

| Файл | Описание |
|:---|:---|
| `scripts/import_csv.sh` | Bash-скрипт для импорта CSV через API (рекомендуется) |
| `scripts/import_csv.py` | Python-скрипт для импорта CSV (альтернатива) |

#### Использование:

```bash
# Bash-скрипт
export API_URL="http://localhost:6060/api/v1"
export LIBRARY_ID=1
export AUTH_TOKEN="your_jwt_token"
bash scripts/import_csv.sh data.csv

# Python-скрипт
python3 scripts/import_csv.py data.csv
```

#### Функциональность:

- Парсинг CSV с учётом многострочных полей и запятых в кавычках
- Отправка POST-запросов к `/api/v1/books/physical`
- Логирование успешных и неудачных импортов
- Поддержка авторизации через JWT

### ✅ 5. Данные учебников

- **Файл:** `data.csv`
- **Источник:** [okulyk.kz](https://okulyk.kz/)
- **Количество записей:** 12 учебников (Алгебра, 10–11 класс)
- **Поля:** id, title, authors, grade, subject, publisher, year, language, description, isbn, url, file_url, sha256

### ✅ 6. Docker-конфигурация

#### Файлы:

| Файл | Описание |
|:---|:---|
| `example-docker/docker-compose.yml` | Оригинальный Docker Compose (BookLore + MariaDB) |
| `docker-compose.override.yml` | Override для AATK: монтирование CSV и скриптов, включение Swagger |

#### Запуск:

```bash
cd example-docker
cp ../docker-compose.override.yml .
docker compose up -d
```

### ✅ 7. Документация

#### Созданные файлы:

| Файл | Описание |
|:---|:---|
| `AATK_README.md` | Полная документация проекта AATK Smart Library |
| `IMPLEMENTATION_REPORT.md` | Этот отчёт |

---

## Команды для запуска

### 1. Клонирование и запуск

```bash
git clone https://github.com/strongaidyn/aatk-smart-library.git
cd aatk-smart-library/example-docker
cp ../docker-compose.override.yml .
docker compose up -d
```

### 2. Проверка статуса

```bash
docker compose ps
docker compose logs -f booklore
```

### 3. Первоначальная настройка

1. Откройте http://localhost:6060
2. Создайте учётную запись администратора
3. Создайте библиотеку с путём `/books`
4. Получите JWT-токен (DevTools → Network → Authorization header)

### 4. Импорт данных

```bash
export API_URL="http://localhost:6060/api/v1"
export LIBRARY_ID=1
export AUTH_TOKEN="your_jwt_token"
bash scripts/import_csv.sh data.csv
```

### 5. Проверка импорта (первые 5 записей)

```bash
curl -s "http://localhost:6060/api/v1/books?page=0&size=5" \
  -H "Authorization: Bearer $AUTH_TOKEN" | python3 -m json.tool
```

Или через UI:
- Откройте http://localhost:6060
- Используйте фильтры: **Grade** → `10 класс`, **Subject** → `Алгебра`

---

## Список изменённых файлов

### Backend (Java/Spring Boot)

```
booklore-api/src/main/
├── java/org/booklore/
│   ├── model/
│   │   ├── entity/BookMetadataEntity.java          [MODIFIED]
│   │   └── dto/
│   │       ├── BookMetadata.java                   [MODIFIED]
│   │       └── request/CreatePhysicalBookRequest.java [MODIFIED]
│   └── service/book/PhysicalBookService.java       [MODIFIED]
└── resources/db/migration/
    └── V122__Add_AATK_Smart_Library_fields.sql     [NEW]
```

### Frontend (Angular/TypeScript)

```
booklore-ui/src/app/features/book/
├── model/book.model.ts                             [MODIFIED]
└── components/book-browser/
    ├── book-filter/book-filter.config.ts           [MODIFIED]
    └── filters/sidebar-filter.ts                   [MODIFIED]
```

### Скрипты и данные

```
scripts/
├── import_csv.sh                                   [NEW]
└── import_csv.py                                   [NEW]
data.csv                                            [NEW]
docker-compose.override.yml                         [NEW]
AATK_README.md                                      [NEW]
IMPLEMENTATION_REPORT.md                            [NEW]
```

---

## Оставшиеся задачи (TODO)

### Критические (для MVP)

- [ ] **Тестирование импорта:** Проверить импорт всех 12 учебников в локальном Docker
- [ ] **PDF-файлы:** Настроить автоматическую загрузку PDF через BookDrop или прямые ссылки
- [ ] **Обложки:** Автоматическое скачивание обложек учебников с okulyk.kz

### Важные (для production)

- [ ] **Figma-дизайн:** Применить брендинг AATK (логотип, цвета, шрифты)
- [ ] **Локализация:** Добавить казахский и русский языки интерфейса
- [ ] **Полный парсинг:** Расширить парсер okulyk.kz на все предметы 10–11 классов
- [ ] **Поиск:** Настроить полнотекстовый поиск по учебникам
- [ ] **Роли:** Настроить роли «Ученик» и «Учитель» с разными правами доступа

### Дополнительные (nice-to-have)

- [ ] **CI/CD:** Настроить GitHub Actions для автосборки Docker-образа
- [ ] **Деплой:** Развернуть на VPS / Vercel / Railway
- [ ] **Мобильная версия:** Адаптировать UI для мобильных устройств
- [ ] **Аналитика:** Добавить статистику по скачиваниям и просмотрам
- [ ] **Комментарии:** Возможность оставлять заметки к учебникам

---

## Риски и ограничения

### Технические

1. **Миграция БД:** Flyway автоматически применит миграцию V122 при первом запуске. Если база уже существует, миграция будет пропущена.
2. **Авторизация:** Для импорта через API требуется JWT-токен. Получить его можно только через UI (пока нет CLI-инструмента).
3. **PDF-файлы:** BookLore ожидает, что файлы будут в папке `/books`. Необходимо либо скачать PDF вручную, либо настроить автоматическую загрузку.

### Функциональные

1. **Фильтры:** Фильтры по `grade` и `subject` добавлены в конфигурацию, но могут не отображаться в UI без перекомпиляции фронтенда.
2. **Локализация:** Все новые поля (`grade`, `subject`) используют английские ключи. Для полной локализации нужно добавить переводы в `i18n/`.
3. **Обложки:** BookLore автоматически ищет обложки через Google Books API. Для казахстанских учебников это может не работать.

### Юридические

1. **Лицензия:** BookLore использует AGPL-3.0. Все изменения должны быть открытыми.
2. **Авторские права:** Учебники с okulyk.kz могут быть защищены авторским правом. Убедитесь, что у вас есть право на их распространение.

---

## Контакты и поддержка

- **Репозиторий:** https://github.com/strongaidyn/aatk-smart-library
- **Оригинальный проект:** https://github.com/booklore-app/booklore
- **Документация BookLore:** https://docs.booklore.app/

---

## Заключение

Проект **AATK Smart Library** успешно адаптирован на базе BookLore для работы с учебниками 10–11 классов. Все основные задачи выполнены:

- ✅ Форк репозитория
- ✅ Модификация модели данных (backend + frontend)
- ✅ Скрипт импорта CSV
- ✅ Docker-конфигурация
- ✅ Документация

Система готова к локальному тестированию. Для production-деплоя рекомендуется выполнить задачи из раздела **TODO**.
