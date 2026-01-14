# Quick Start Guide

This guide will help you get the Family Management app up and running quickly.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher): [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** (for Android development): [Download](https://developer.android.com/studio)
- **Xcode** (for iOS development, macOS only): [Download from Mac App Store](https://apps.apple.com/us/app/xcode/id497799835)
- **Git**: [Install Git](https://git-scm.com/downloads)
- **A Firebase account**: [Create account](https://firebase.google.com/)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/petaurodellozucchero/family-managment.git
cd family-managment
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This command downloads all the packages listed in `pubspec.yaml`.

### 3. Set Up Firebase

**This is the most important step!** The app requires Firebase to function.

Follow the detailed instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

Quick summary:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Anonymous Authentication**
3. Create a **Firestore Database**
4. Add your Android app and download `google-services.json` → place in `android/app/`
5. Add your iOS app and download `GoogleService-Info.plist` → place in `ios/Runner/`

### 4. Verify Setup

Check that your Firebase config files are in place:

```bash
# Check Android config
ls android/app/google-services.json

# Check iOS config (if developing for iOS)
ls ios/Runner/GoogleService-Info.plist
```

### 5. Run the App

#### For Android:

```bash
flutter run
```

Or in Android Studio:
1. Open the project
2. Select an Android device/emulator
3. Click the Run button (green play icon)

#### For iOS (macOS only):

```bash
cd ios
pod install
cd ..
flutter run
```

Or in Xcode:
1. Open `ios/Runner.xcworkspace` (not `.xcodeproj`)
2. Select a simulator or device
3. Click the Run button

## First Launch

On the first launch, the app will:

1. **Automatically sign you in anonymously** - No account creation needed!
2. **Initialize default family members** with predefined colors:
   - You (Yellow)
   - Sister (Pink)
   - Mom (Red)
   - Dad (Blue)
   - Brother (Green)

You can view these in the Settings tab.

## Using the App

### Creating an Event

1. Navigate to the **Calendar** tab
2. Tap the **"New Event"** floating action button
3. Fill in the event details:
   - Title (required)
   - Description (optional)
   - Start and end date/time
   - Assign to a family member
   - Set recurrence (none, daily, weekly, monthly)
   - Location (optional)
4. Tap **"Create Event"**

### Viewing Events

Switch between three view modes:
- **Day View**: See all events for a single day
- **Week View**: See events for the entire week
- **Month View**: Calendar grid with event markers

Use navigation buttons or swipe to change dates.

### Editing/Deleting Events

1. Tap on any event card
2. Modify the details
3. Tap **"Update Event"** to save or **Delete** icon to remove

### Managing Shopping List

1. Navigate to the **Shopping** tab
2. Type an item name in the input field
3. Tap the **+** button or press Enter
4. Check off items as you purchase them
5. Tap **"Clear Purchased"** to remove all checked items

### Settings

1. Navigate to the **Settings** tab
2. View all family members and their colors
3. If needed, reinitialize default members

## Troubleshooting

### "No Firebase App '[DEFAULT]' has been created"

**Solution**: Make sure you've added the Firebase configuration files:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### "Permission denied" when creating events

**Solution**: Check your Firestore security rules in Firebase Console. Make sure Anonymous authentication is enabled.

### Build errors on Android

**Solution**: 
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Build errors on iOS

**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### "Unable to connect to Firestore"

**Solution**:
- Check your internet connection
- Verify Firebase configuration files are correctly placed
- Check Firebase Console for any service issues

## Development Tips

### Hot Reload

While the app is running, you can make changes to the code and see them instantly:
- Press `r` in the terminal for hot reload
- Press `R` for hot restart

### Debugging

Enable debug mode in your IDE:
- Android Studio: Click the bug icon
- VS Code: Press F5

### Running Tests

```bash
flutter test
```

## Project Structure Overview

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
├── services/                    # Firebase & auth services
├── providers/                   # State management
├── screens/                     # Main app screens
└── widgets/                     # Reusable UI components
```

## Next Steps

- Customize family members in Firestore Console
- Adjust Firestore security rules for production
- Set up proper authentication (email/password)
- Customize app theme and colors
- Add more family members
- Create your family events and shopping lists!

## Support

For issues:
1. Check [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for Firebase-specific issues
2. Read [README.md](README.md) for general information
3. Open an issue on GitHub with:
   - Error messages
   - Steps to reproduce
   - Flutter doctor output: `flutter doctor -v`

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

Enjoy using the Family Management app! 🎉📅🛒
