# Firebase Setup Guide

This guide will walk you through setting up Firebase for the Family Management app.

## Prerequisites

- A Google account
- Flutter installed on your machine
- The Family Management app cloned to your local machine

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter a project name (e.g., "Family Management App")
4. (Optional) Enable Google Analytics for your project
5. Click **"Create project"**
6. Wait for the project to be created, then click **"Continue"**

## Step 2: Enable Authentication

1. In the Firebase Console, select your project
2. Click on **"Authentication"** in the left sidebar
3. Click on the **"Get started"** button
4. Under the **"Sign-in method"** tab, enable the following:
   - **Anonymous**: Click on it, toggle "Enable", then click "Save"
   - (Optional) **Email/Password**: Enable if you want user accounts

## Step 3: Create Firestore Database

1. In the Firebase Console, click on **"Firestore Database"** in the left sidebar
2. Click **"Create database"**
3. Choose a location for your database (select the one closest to your users)
4. Start in **"Test mode"** for now (we'll update security rules later)
5. Click **"Enable"**

### Set Up Collections

The app will automatically create collections, but you can manually create them:

1. **events** collection
2. **shoppingList** collection
3. **familyMembers** collection

The app will automatically initialize default family members on first launch.

## Step 4: Configure Firestore Security Rules

1. In Firestore Database, go to the **"Rules"** tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read and write all data
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // More restrictive rules for production:
    // match /events/{eventId} {
    //   allow read: if request.auth != null;
    //   allow create: if request.auth != null;
    //   allow update, delete: if request.auth != null && 
    //     request.auth.uid == resource.data.createdBy;
    // }
    
    // match /shoppingList/{itemId} {
    //   allow read, write: if request.auth != null;
    // }
    
    // match /familyMembers/{memberId} {
    //   allow read: if request.auth != null;
    //   allow write: if request.auth != null;
    // }
  }
}
```

3. Click **"Publish"**

**Note**: The rules above allow any authenticated user to read and write. For production, use the commented rules or create more specific rules based on your needs.

## Step 5: Add Android App to Firebase

1. In the Firebase Console, click on the **Android icon** (or "Add app" if it's your first app)
2. Register your app with the following details:
   - **Android package name**: `com.example.family_managment`
   - **App nickname** (optional): "Family Management Android"
   - **Debug signing certificate SHA-1** (optional, needed for some features)
3. Click **"Register app"**
4. Download the `google-services.json` file
5. Move `google-services.json` to your project's `android/app/` directory

   ```bash
   # From your project root
   cp ~/Downloads/google-services.json android/app/
   ```

6. Click **"Next"** through the remaining steps (SDK setup is already done)
7. Click **"Continue to console"**

### Verify Android Configuration

Ensure your `android/app/build.gradle` includes:
```gradle
apply plugin: 'com.google.gms.google-services'
```

And your `android/build.gradle` includes:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

## Step 6: Add iOS App to Firebase

1. In the Firebase Console, click on the **iOS icon** (or "Add app")
2. Register your app with the following details:
   - **iOS bundle ID**: `com.example.familyManagment`
   - **App nickname** (optional): "Family Management iOS"
3. Click **"Register app"**
4. Download the `GoogleService-Info.plist` file
5. Open Xcode and add the file to your project:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on "Runner" in the project navigator
   - Select "Add Files to Runner"
   - Select the downloaded `GoogleService-Info.plist` file
   - Make sure "Copy items if needed" is checked
   - Click "Add"

   Or manually copy it:
   ```bash
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/
   ```

6. Click **"Next"** through the remaining steps
7. Click **"Continue to console"**

### Verify iOS Configuration

Ensure your `ios/Podfile` includes Firebase dependencies (already configured in the project).

## Step 7: Initialize Default Data

The app will automatically:
1. Sign in users anonymously
2. Create default family members with colors:
   - You (Yellow - #FFEB3B)
   - Sister (Pink - #E91E63)
   - Mom (Red - #F44336)
   - Dad (Blue - #2196F3)
   - Brother (Green - #4CAF50)

You can also manually add family members through the Firestore console or the Settings screen in the app.

## Step 8: Test Your Setup

1. Make sure you've placed the configuration files in the correct locations:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

2. Run the app:
   ```bash
   flutter pub get
   flutter run
   ```

3. Check for any Firebase-related errors in the console
4. Try creating an event and a shopping list item
5. Check the Firebase Console to see if data is being saved in Firestore

## Troubleshooting

### Android Issues

**Problem**: "google-services.json not found"
- **Solution**: Make sure the file is in `android/app/` directory

**Problem**: "Failed to resolve: firebase-***"
- **Solution**: Make sure you have the correct dependencies in `android/app/build.gradle`

**Problem**: Build fails with "Execution failed for task ':app:processDebugGoogleServices'"
- **Solution**: Ensure your `google-services.json` package name matches your `android/app/build.gradle` applicationId

### iOS Issues

**Problem**: "GoogleService-Info.plist not found"
- **Solution**: Make sure the file is added to the Xcode project, not just copied to the directory

**Problem**: Pod install fails
- **Solution**: 
  ```bash
  cd ios
  pod deintegrate
  pod install
  cd ..
  flutter clean
  flutter pub get
  ```

### Firestore Issues

**Problem**: "Permission denied" errors
- **Solution**: Check your Firestore security rules and make sure authentication is enabled

**Problem**: Data not syncing
- **Solution**: 
  - Check your internet connection
  - Verify Firebase is initialized in `main.dart`
  - Check the Firebase Console for any errors

### Authentication Issues

**Problem**: Anonymous sign-in fails
- **Solution**: Make sure Anonymous authentication is enabled in Firebase Console → Authentication → Sign-in method

## Security Considerations

### For Production

1. **Update Firestore Rules**: Replace test mode rules with production rules
2. **Enable App Check**: Protect your Firebase resources from abuse
3. **Set up proper authentication**: Use email/password or other secure methods
4. **Restrict API keys**: In Firebase Console → Project Settings → API Keys
5. **Monitor usage**: Set up billing alerts in Firebase Console

### Recommended Production Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Events: authenticated users can read all, but only creator can modify
    match /events/{eventId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && isOwner(resource.data.createdBy);
    }
    
    // Shopping list: all authenticated users can manage
    match /shoppingList/{itemId} {
      allow read, write: if isSignedIn();
    }
    
    // Family members: authenticated users can read, but write is restricted
    match /familyMembers/{memberId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn(); // Adjust based on your needs
    }
  }
}
```

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

## Support

If you encounter any issues not covered in this guide:
1. Check the [FlutterFire GitHub Issues](https://github.com/firebase/flutterfire/issues)
2. Review the [Firebase Console](https://console.firebase.google.com/) for error messages
3. Open an issue in this repository with detailed error messages

---

**Important Notes**:
- Keep your `google-services.json` and `GoogleService-Info.plist` files secure
- Add these files to `.gitignore` if sharing your code publicly
- Never commit Firebase private keys or credentials to version control
