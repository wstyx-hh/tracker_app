# Expense Tracker

**Expense Tracker** — это полнофункциональное приложение для управления личными финансами, написанное на Flutter.  
Оно позволяет отслеживать доходы, расходы, планировать платежи, анализировать статистику и управлять счетами.

## Основные возможности

- Ведение доходов и расходов с подробным описанием и датой
- Категоризация расходов
- Управление счетами
- Планирование будущих платежей
- Просмотр статистики и графиков (fl_chart)
- Тёмная и светлая тема (ThemeProvider)
- Локальное хранение данных с помощью Hive
- Удобный и современный интерфейс

## Структура проекта

- `lib/main.dart` — точка входа, инициализация Hive и запуск приложения
- `lib/models/` — модели данных (доходы, расходы, счета, плановые платежи)
- `lib/services/` — сервисы для работы с Hive
- `lib/providers/` — провайдеры состояния (расходы, тема)
- `lib/screens/` — основные экраны приложения:
  - `home_screen.dart` — главный экран
  - `transactions_screen.dart` — список операций
  - `statistics_screen.dart` — статистика и графики
  - `budget_screen.dart` — бюджет
  - `settings_screen.dart` — настройки
  - `add_transaction_screen.dart` — добавление дохода/расхода/счёта
  - `planned_payments_screen.dart`, `add_planned_payment_screen.dart` — плановые платежи

## Быстрый старт

1. **Клонируйте репозиторий:**
   ```sh
   git clone <repo_url>
   cd expense_tracker
   ```

2. **Установите зависимости:**
   ```sh
   flutter pub get
   ```

3. **Запустите приложение:**
   ```sh
   flutter run -d windows   # или -d chrome, -d android, -d ios
   ```

> ⚠️ В текущей версии для целей тестирования при запуске происходит автоматическая очистка всех данных Hive (см. main.dart). Удалите этот блок кода для сохранения данных между сессиями.

## Зависимости

- [Flutter](https://flutter.dev/)
- [Hive](https://pub.dev/packages/hive), [hive_flutter](https://pub.dev/packages/hive_flutter)
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
