# FinFlow - Smart Finance Tracker

A modern, feature-rich expense tracking application built with Flutter. Take control of your finances with FinFlow - an intuitive and powerful tool for tracking expenses, managing budgets, and visualizing your financial journey with beautiful analytics.

## Project Architecture

```
lib/
├── main.dart                 # Application entry point
├── l10n/                    # Localization
│   ├── app_localizations.dart
│   ├── app_localizations_delegate.dart
│   └── translations/
│       ├── en.dart          # English translations
│       └── ru.dart          # Russian translations
│
├── models/                  # Data models
│   ├── expense_hive.dart    # Expense model
│   ├── income.dart          # Income model
│   └── budget.dart          # Budget model
│
├── providers/              # State management
│   ├── theme_provider.dart  # Theme state management
│   └── locale_provider.dart # Localization state management
│
├── screens/               # UI screens
│   ├── home_screen.dart    # Main dashboard
│   ├── statistics_screen.dart # Analytics and charts
│   ├── budget_screen.dart    # Budget management
│   └── settings_screen.dart  # App settings
│
├── services/              # Business logic
│   └── isar_service.dart   # Database operations
│
├── utils/                # Helper functions
│   └── constants.dart     # App-wide constants
│
└── widgets/              # Reusable UI components
    ├── charts/           # Chart widgets
    ├── forms/            # Form components
    └── common/           # Shared widgets
```

### Architectural Patterns

#### 1. Provider Pattern
- Uses `ChangeNotifier` for state management
- Separates UI from business logic
- Provides efficient widget rebuilding

#### 2. Repository Pattern
- Implemented in `isar_service.dart`
- Abstracts data source from business logic
- Handles all database operations

#### 3. Clean Architecture Principles
- **Presentation Layer** (`screens/`, `widgets/`)
  - Handles UI rendering
  - Manages user interactions
  - Uses providers for state management

- **Business Logic Layer** (`providers/`, `services/`)
  - Contains application business rules
  - Manages application state
  - Handles data transformation

- **Data Layer** (`models/`, `services/isar_service.dart`)
  - Defines data structures
  - Handles data persistence
  - Manages database operations

### Key Components

#### Database (Isar)
- NoSQL database for local storage
- High-performance data operations
- Supports complex queries and indexing

#### State Management
- Provider package for state management
- Centralized state handling
- Efficient widget rebuilding

#### UI Components
- Material Design widgets
- Custom themed components
- Responsive layouts

#### Localization
- Multi-language support
- Locale-specific formatting
- Easy to add new languages

### Data Flow
1. User interacts with UI (`screens/`)
2. Actions dispatched through providers (`providers/`)
3. Business logic processed in services (`services/`)
4. Data persisted in Isar database
5. UI updated through provider notifications

### Security
- Local data encryption
- Secure storage for sensitive information
- Input validation and sanitization

## Features

### Expense Management
- Add, edit, and delete expenses with detailed information
- Categorize expenses for better organization
- Add descriptions and dates to each transaction
- Support for both expenses and income tracking

### Budget Management
- Set monthly budget limits
- Category-specific budget limits
- Visual progress bars for budget tracking
- Overspending alerts and notifications
- Real-time budget vs. actual spending comparison

### Statistics and Analytics
- Detailed expense analytics with interactive charts
- Category-wise expense breakdown
- Daily expense trends visualization
- Income vs. expenses comparison
- Monthly and yearly expense summaries

### Customization
- Multi-language support (English and Russian)
- Dark and light theme options
- Multiple color themes
- Customizable currency settings
- Personalized categories

### Data Management
- Secure local data storage
- Data backup and restore functionality
- Export and import capabilities
- Data persistence across sessions

## Technical Details

### Architecture
- Built with Flutter for cross-platform compatibility
- Uses Provider pattern for state management
- Implements clean architecture principles
- Follows Material Design guidelines

### Dependencies
- `flutter_localizations`: For internationalization
- `provider`: For state management
- `shared_preferences`: For local storage
- `fl_chart`: For interactive charts and graphs
- `intl`: For date and number formatting
- `isar`: For database management

### Local Storage
- Uses Isar database for efficient data storage
- Implements data models for expenses, income, and budgets
- Maintains user preferences and settings

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter plugins

### Installation
1. Clone the repository:
```bash
git clone https://github.com/wstyx-hh/tracker_app.git
```

2. Navigate to the project directory:
```bash
cd tracker_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the application:
```bash
flutter run
```

### Configuration
- Default language: English (can be changed in settings)
- Default theme: System theme
- Default currency: USD (can be changed in settings)

## Usage

### Adding Transactions
1. Tap the '+' button on the home screen
2. Select transaction type (expense/income)
3. Enter amount and select category
4. Add description (optional)
5. Select date
6. Save transaction

### Managing Budgets
1. Navigate to Budget screen
2. Set monthly budget limit
3. Add category-specific budgets
4. Monitor spending progress

### Viewing Statistics
1. Go to Statistics screen
2. View expense breakdowns
3. Analyze spending patterns
4. Check budget compliance

## Contributing
Contributions are welcome! Please feel free to submit pull requests.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- Flutter team for the amazing framework
- Contributors and package maintainers
- UI/UX inspiration from various finance apps

## Screenshots
[Add screenshots of key features here]
