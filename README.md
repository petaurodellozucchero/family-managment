# Family Management App

A comprehensive Flutter application for family coordination with a shared calendar and grocery shopping list.

## 📱 Features

### Family Calendar
* 📅 **Multiple View Modes**: Day, Week, and Month views
* ⏰ **Rich Appointments**: 
  - Start and end times (can span multiple days)
  - Title, description, and location
  - Color-coded by assigned family member
  - Recurring events (daily, weekly, monthly)
* ✏️ **Easy Editing**: Tap any appointment to edit or delete it
* 🎨 **Color-Coded Members**: Each family member has a unique color
  - You: Yellow
  - Sister: Pink
  - Mom: Red
  - Dad: Blue
  - Brother: Green

### Shopping List
* ✅ **Simple Management**: Add, remove, and check off items
* 🗑️ **Clear Completed**: Remove all purchased items at once
* 📝 **Real-time Updates**: See changes instantly across all devices

### General
* 📱 **Mobile-First Design**: Optimized for phone screens
* 🔤 **Large Fonts**: Easy to read for all ages
* 🎯 **Intuitive Navigation**: Bottom navigation bar
* 🌓 **Light/Dark Mode**: System-aware theming
* ☁️ **Firebase Backend**: Real-time sync across all family members
* 🔐 **Anonymous Authentication**: No signup required

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- Firebase account (for backend services)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/petaurodellozucchero/family-managment.git
   cd family-managment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions)
   - Create a Firebase project
   - Add Android and/or iOS apps
   - Download configuration files:
     - `google-services.json` → `android/app/`
     - `GoogleService-Info.plist` → `ios/Runner/`
   - Enable Firestore and Authentication

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── event_model.dart              # Event data model
│   ├── shopping_item_model.dart      # Shopping item data model
│   └── family_member_model.dart      # Family member data model
├── services/
│   ├── firebase_service.dart         # Firestore operations
│   └── auth_service.dart             # Authentication
├── screens/
│   ├── calendar_screen.dart          # Main calendar view
│   ├── shopping_list_screen.dart     # Shopping list view
│   ├── event_detail_screen.dart      # Event creation/editing
│   └── settings_screen.dart          # App settings
├── widgets/
│   ├── day_view.dart                 # Day calendar widget
│   ├── week_view.dart                # Week calendar widget
│   ├── month_view.dart               # Month calendar widget
│   ├── event_card.dart               # Event display widget
│   └── shopping_item_tile.dart       # Shopping item widget
└── providers/
    ├── event_provider.dart           # Calendar state management
    └── shopping_provider.dart        # Shopping list state management
```

## 🔧 Technologies Used

- **Framework**: Flutter
- **State Management**: Provider
- **Backend**: Firebase (Firestore + Authentication)
- **Calendar UI**: table_calendar
- **Date/Time**: intl

## 📦 Dependencies

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  provider: ^6.1.1
  table_calendar: ^3.0.9
  intl: ^0.18.1
```

## 🔥 Firebase Data Structure

### Events Collection
```
/events/{eventId}
  - title: string
  - description: string
  - startTime: timestamp
  - endTime: timestamp
  - assignedTo: string (family member ID)
  - color: string (hex color)
  - recurrence: string (none/daily/weekly/monthly)
  - location: string
  - createdBy: string
  - createdAt: timestamp
```

### Shopping List Collection
```
/shoppingList/{itemId}
  - name: string
  - isPurchased: boolean
  - addedBy: string
  - addedAt: timestamp
```

### Family Members Collection
```
/familyMembers/{memberId}
  - name: string
  - color: string (hex color)
```

## 🎨 UI/UX Features

- **Material Design 3**: Modern, clean interface
- **Large Touch Targets**: Easy to tap buttons and items
- **Responsive Design**: Works on various screen sizes
- **Loading States**: Visual feedback during operations
- **Error Handling**: User-friendly error messages
- **Confirmation Dialogs**: Prevent accidental deletions
- **Toast Notifications**: Action feedback
- **Pull-to-Refresh**: Update data manually
- **Color Coding**: Quick visual identification

## 🛡️ Security

- Firebase security rules should be configured properly
- Anonymous authentication enabled by default
- Can be upgraded to email/password authentication

## 📖 Usage

### Creating an Event
1. Navigate to the Calendar tab
2. Tap the "New Event" button
3. Fill in event details (title, time, family member, etc.)
4. Tap "Create Event"

### Editing an Event
1. Tap on any event in the calendar
2. Modify the details
3. Tap "Update Event" or "Delete" to remove

### Managing Shopping List
1. Navigate to the Shopping tab
2. Type item name in the input field
3. Tap the + button or press Enter
4. Check off items as you purchase them
5. Use "Clear Purchased" to remove completed items

### Viewing Family Members
1. Navigate to the Settings tab
2. View all family members and their colors
3. Initialize default members if needed

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the MIT License.

## 📧 Support

For issues and questions, please use the GitHub issue tracker.

## ✨ Future Enhancements

- [ ] Custom family member creation
- [ ] Event reminders/notifications
- [ ] Shopping list categories
- [ ] Shared notes
- [ ] Photo attachments to events
- [ ] Export calendar to other formats
- [ ] Multiple shopping lists
- [ ] Recipe integration
