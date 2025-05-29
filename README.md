# Expense Tracker

**Expense Tracker** — это полнофункциональное приложение для управления личными финансами на Flutter.

## Особенности

- Учёт доходов, расходов, счетов
- Категоризация расходов
- Планирование платежей
- Статистика и графики (fl_chart)
- Тёмная/светлая тема
- Локальное хранение данных с помощью [Isar](https://isar.dev/)
- Экспорт/импорт данных (JSON)
- Очистка всех данных одним кликом
- Современный интерфейс

## Структура проекта

- `lib/main.dart` — точка входа, запуск приложения
- `lib/models/` — модели данных (Isar коллекции)
- `lib/services/isar_service.dart` — сервис для работы с Isar
- `lib/screens/` — основные экраны (транзакции, статистика, бюджет, настройки и др.)
- `lib/providers/` — провайдеры состояния

## Быстрый старт

1. **Клонируйте репозиторий:**
   ```sh
   git clone https://github.com/wstyx-hh/tracker_app.git
   cd expense_tracker
   ```

2. **Установите зависимости:**
   ```sh
   flutter pub get
   ```

3. **Сгенерируйте адаптеры Isar:**
   ```sh
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Запустите приложение:**
   ```sh
   flutter run -d windows   # или -d chrome, -d android, -d ios
   ```

## Экспорт/Импорт/Очистка данных

- **Экспорт:** В настройках выберите "Export Data" — ваши данные будут сохранены в JSON-файл.
- **Импорт:** В настройках выберите "Import Data" и выберите ранее сохранённый JSON-файл.
- **Очистка:** Кнопка "Clear All Data" удаляет все ваши данные из приложения.

## Зависимости

- [Flutter](https://flutter.dev/)
- [Isar](https://isar.dev/)
- [Provider](https://pub.dev/packages/provider)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [google_fonts](https://pub.dev/packages/google_fonts)
- [intl](https://pub.dev/packages/intl)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [uuid](https://pub.dev/packages/uuid)

## Скриншоты

_Добавьте сюда скриншоты приложения для наглядности._

## Лицензия

_Укажите лицензию, если требуется._
