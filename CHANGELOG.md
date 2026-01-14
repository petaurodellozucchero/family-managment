# Changelog

All notable changes to the Family Management App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-14

### Added

#### Core Features
- **Family Calendar** with multiple view modes:
  - Day view: See all events for a single day
  - Week view: Display events for the entire week
  - Month view: Calendar grid with event markers using table_calendar
- **Event Management**:
  - Create, edit, and delete calendar events
  - Support for multi-day events
  - Recurring events (daily, weekly, monthly)
  - Assign events to specific family members
  - Add location to events
  - Color-coded events by family member
- **Shopping List**:
  - Add and remove grocery items
  - Mark items as purchased with checkbox
  - Clear all completed items at once
  - Real-time synchronization
- **Family Members**:
  - Default family members with predefined colors
  - View family members in Settings
  - Color-coded event display

#### Technical Implementation
- **State Management**: Provider pattern for reactive UI updates
- **Firebase Integration**:
  - Anonymous authentication
  - Cloud Firestore for data storage
  - Real-time data synchronization
- **UI/UX**:
  - Material Design 3 theming
  - Light and dark mode support
  - Mobile-first responsive design
  - Large, readable fonts
  - Bottom navigation bar
  - Pull-to-refresh functionality
  - Loading indicators
  - Error handling with user-friendly messages
  - Confirmation dialogs for destructive actions

#### Documentation
- Comprehensive README.md
- Detailed FIREBASE_SETUP.md guide
- Quick start guide (QUICKSTART.md)
- Contributing guidelines (CONTRIBUTING.md)
- MIT License
- Code quality with analysis_options.yaml

#### Configuration
- Android configuration with Gradle 8.1.0
- iOS configuration with Podfile
- Firebase security rules template
- .gitignore for Flutter projects
- Basic unit tests for data models

### Project Structure
```
lib/
├── main.dart                          # App entry point with navigation
├── models/
│   ├── event_model.dart              # Event data model with recurrence logic
│   ├── shopping_item_model.dart      # Shopping item data model
│   └── family_member_model.dart      # Family member data model
├── services/
│   ├── firebase_service.dart         # Firestore CRUD operations
│   └── auth_service.dart             # Authentication services
├── providers/
│   ├── event_provider.dart           # Calendar state management
│   └── shopping_provider.dart        # Shopping list state management
├── screens/
│   ├── calendar_screen.dart          # Main calendar with tabs
│   ├── shopping_list_screen.dart     # Shopping list interface
│   ├── event_detail_screen.dart      # Event creation/editing form
│   └── settings_screen.dart          # App settings and family members
└── widgets/
    ├── day_view.dart                 # Day calendar widget
    ├── week_view.dart                # Week calendar widget
    ├── month_view.dart               # Month calendar with table_calendar
    ├── event_card.dart               # Event display card
    └── shopping_item_tile.dart       # Shopping list item tile
```

### Dependencies
- firebase_core: ^2.24.2
- firebase_auth: ^4.16.0
- cloud_firestore: ^4.14.0
- provider: ^6.1.1
- table_calendar: ^3.0.9
- intl: ^0.18.1

### Notes
- Initial release
- Requires Firebase configuration to run
- Anonymous authentication enabled by default
- Default family members auto-initialized on first launch

---

## [Unreleased]

### Planned Features
- Custom family member creation interface
- Event notifications and reminders
- Shopping list categories
- Multiple shopping lists
- Photo attachments to events
- Export calendar to ICS format
- Recipe integration
- Enhanced accessibility features
- Offline mode improvements

---

[1.0.0]: https://github.com/petaurodellozucchero/family-managment/releases/tag/v1.0.0
