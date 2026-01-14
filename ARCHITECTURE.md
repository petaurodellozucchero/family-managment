# Architecture Documentation

This document describes the architecture and design patterns used in the Family Management App.

## Table of Contents

1. [Overview](#overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Project Structure](#project-structure)
4. [Data Flow](#data-flow)
5. [State Management](#state-management)
6. [Firebase Integration](#firebase-integration)
7. [UI Components](#ui-components)
8. [Key Design Decisions](#key-design-decisions)

## Overview

The Family Management App is built using Flutter with a clean, layered architecture that separates concerns between UI, business logic, and data access.

### Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Backend**: Firebase (Firestore + Authentication)
- **UI Library**: Material Design 3
- **Calendar Widget**: table_calendar
- **Date Formatting**: intl

## Architecture Pattern

The app follows a **Model-View-Provider (MVP)** architecture pattern, which is a variant of MVVM adapted for Flutter:

```
┌─────────────────────────────────────────────────────────┐
│                         View Layer                       │
│  (Screens & Widgets - UI Components)                    │
│  - calendar_screen.dart                                 │
│  - shopping_list_screen.dart                            │
│  - event_detail_screen.dart                             │
│  - settings_screen.dart                                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                      Provider Layer                      │
│  (State Management - Business Logic)                    │
│  - EventProvider (ChangeNotifier)                       │
│  - ShoppingProvider (ChangeNotifier)                    │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                      Service Layer                       │
│  (Data Access & External Services)                      │
│  - FirebaseService (Firestore Operations)               │
│  - AuthService (Authentication)                         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                       Model Layer                        │
│  (Data Models & Business Objects)                       │
│  - Event                                                │
│  - ShoppingItem                                         │
│  - FamilyMember                                         │
└─────────────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                    Firebase Backend                      │
│  - Cloud Firestore (Database)                           │
│  - Firebase Auth (Authentication)                       │
└─────────────────────────────────────────────────────────┘
```

## Project Structure

```
lib/
├── main.dart                   # App entry point, Firebase init, routing
│
├── models/                     # Data models (PODOs)
│   ├── event_model.dart       # Event with recurrence logic
│   ├── shopping_item_model.dart
│   └── family_member_model.dart
│
├── services/                   # External service integrations
│   ├── firebase_service.dart  # Firestore CRUD operations
│   └── auth_service.dart      # Authentication logic
│
├── providers/                  # State management (ChangeNotifier)
│   ├── event_provider.dart    # Event state & business logic
│   └── shopping_provider.dart # Shopping list state & logic
│
├── screens/                    # Full-page views
│   ├── calendar_screen.dart   # Main calendar with tabs
│   ├── shopping_list_screen.dart
│   ├── event_detail_screen.dart
│   └── settings_screen.dart
│
└── widgets/                    # Reusable UI components
    ├── day_view.dart
    ├── week_view.dart
    ├── month_view.dart
    ├── event_card.dart
    └── shopping_item_tile.dart
```

### Responsibility of Each Layer

#### 1. Models (`lib/models/`)
- Pure data classes
- No business logic (except simple computed properties)
- Serialization/deserialization to/from Firestore
- Immutable with `copyWith` methods

#### 2. Services (`lib/services/`)
- Interface with external systems (Firebase)
- CRUD operations for Firestore
- Authentication management
- No UI-related code
- Return Streams or Futures

#### 3. Providers (`lib/providers/`)
- Extend `ChangeNotifier`
- Manage app state
- Business logic (filtering, sorting, validation)
- Listen to service streams
- Notify listeners on state changes
- Error handling

#### 4. Screens (`lib/screens/`)
- Full-page widgets
- Use `Consumer` to listen to Providers
- Handle user interactions
- Navigation
- Display dialogs and snackbars

#### 5. Widgets (`lib/widgets/`)
- Reusable UI components
- Stateless or Stateful
- Receive data via constructor
- Emit events via callbacks

## Data Flow

### Reading Data (Firestore → UI)

```
Firebase Firestore
      ↓
FirebaseService.getEventsStream()
      ↓
EventProvider.initialize() subscribes
      ↓
EventProvider._events updated
      ↓
notifyListeners() called
      ↓
Consumer<EventProvider> rebuilds
      ↓
UI updates with new data
```

### Writing Data (UI → Firestore)

```
User taps "Create Event"
      ↓
EventDetailScreen validates input
      ↓
EventProvider.addEvent(event)
      ↓
FirebaseService.addEvent(event)
      ↓
Firestore writes data
      ↓
Stream emits update
      ↓
EventProvider receives update
      ↓
UI automatically updates
```

## State Management

### Why Provider?

- **Simple**: Easy to understand and implement
- **Built-in**: Part of the Flutter ecosystem
- **Performant**: Efficient rebuilds with `Consumer`
- **Testable**: Easy to mock and test
- **Scalable**: Sufficient for this app's complexity

### Provider Pattern

```dart
// 1. Create a Provider
class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  
  void addEvent(Event event) {
    // Business logic
    _events.add(event);
    notifyListeners(); // Trigger UI rebuild
  }
}

// 2. Provide it at the root
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => EventProvider()),
  ],
  child: MyApp(),
)

// 3. Consume in widgets
Consumer<EventProvider>(
  builder: (context, provider, child) {
    return ListView(
      children: provider.events.map((e) => EventCard(event: e)).toList(),
    );
  },
)
```

## Firebase Integration

### Authentication

- **Anonymous Sign-in**: Automatic on app launch
- **No User Management**: Simple, frictionless start
- **Upgradeable**: Can add email/password later

```dart
AuthService
  ├── signInAnonymously()
  ├── currentUser
  └── currentUserId
```

### Firestore Structure

```
/events/{eventId}
  - title: string
  - description: string
  - startTime: timestamp
  - endTime: timestamp
  - assignedTo: string (familyMemberId)
  - color: string (hex)
  - recurrence: string
  - location: string
  - createdBy: string (userId)
  - createdAt: timestamp

/shoppingList/{itemId}
  - name: string
  - isPurchased: boolean
  - addedBy: string (userId)
  - addedAt: timestamp

/familyMembers/{memberId}
  - name: string
  - color: string (hex)
```

### Real-time Synchronization

```dart
// Service provides Stream
Stream<List<Event>> getEventsStream() {
  return eventsCollection
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => Event.fromFirestore(doc))
      .toList());
}

// Provider subscribes to Stream
void initialize() {
  _firebaseService.getEventsStream().listen(
    (events) {
      _events = events;
      notifyListeners();
    },
  );
}
```

## UI Components

### Screen Hierarchy

```
MainScreen (Bottom Navigation)
  ├── CalendarScreen (Tab Controller)
  │   ├── DayView
  │   ├── WeekView
  │   └── MonthView (table_calendar)
  ├── ShoppingListScreen
  │   └── ShoppingItemTile (List)
  └── SettingsScreen
      └── Family Member Cards
```

### Widget Composition

**EventCard** (Reusable)
- Used in DayView, WeekView, MonthView
- Displays event with color coding
- Taps navigate to EventDetailScreen

**ShoppingItemTile** (Reusable)
- Used in ShoppingListScreen
- Checkbox for purchase status
- Delete button with confirmation

### Navigation

- **Bottom Navigation**: Switch between main screens
- **Push Navigation**: Open detail screens
- **Modal Dialogs**: Confirmations and alerts

```dart
// Bottom Navigation
NavigationBar(
  destinations: [Calendar, Shopping, Settings],
  onDestinationSelected: (index) => setState(),
)

// Push Navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => EventDetailScreen()),
)

// Modal Dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
)
```

## Key Design Decisions

### 1. Provider over Riverpod/Bloc

**Reason**: Simpler for this app's scope, built-in, less boilerplate

### 2. Anonymous Authentication

**Reason**: Remove friction for family members to start using immediately

### 3. Color-coded Family Members

**Reason**: Quick visual identification, improved UX

### 4. table_calendar Package

**Reason**: Robust, customizable, well-maintained

### 5. Real-time Streams over Polling

**Reason**: Instant updates, better UX, efficient

### 6. Firestore Security Rules

**Reason**: Server-side validation, protect data

### 7. No Local Database (yet)

**Reason**: Start simple, add offline support later if needed

### 8. Material Design 3

**Reason**: Modern, accessible, consistent

### 9. Single Shopping List

**Reason**: MVP simplicity, can extend to multiple later

### 10. Immutable Models with copyWith

**Reason**: Predictable state, easier debugging

## Performance Considerations

1. **Efficient Rebuilds**: Use `Consumer` with specific providers
2. **Pagination**: Future enhancement for large datasets
3. **Image Caching**: Not needed yet (no images)
4. **Firestore Indexes**: Auto-created for current queries
5. **Memory Management**: Dispose controllers and streams

## Security Considerations

1. **Authentication Required**: All Firestore operations require auth
2. **Security Rules**: Validate on server-side
3. **Data Validation**: Client-side for UX, server-side for security
4. **Sensitive Data**: No passwords stored (anonymous auth)

## Testing Strategy

1. **Unit Tests**: Models, utilities, business logic
2. **Widget Tests**: Individual widgets (planned)
3. **Integration Tests**: Full user flows (planned)
4. **Manual Testing**: UI/UX validation

## Future Enhancements

### Architecture Improvements

- [ ] Add Repository layer for data abstraction
- [ ] Implement offline-first with local cache
- [ ] Add dependency injection (get_it)
- [ ] Migrate to Riverpod for better testing
- [ ] Add error boundary for crash handling

### Feature Additions

- [ ] Push notifications
- [ ] Photo uploads
- [ ] User profiles
- [ ] Shared notes
- [ ] Recipe integration

## Resources

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Firebase Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

For questions about architecture decisions, open an issue on GitHub.
