# LifeDrop – Blood Donor Search & Request App

A modern, responsive Flutter application built for finding and connecting blood donors with recipients in urgent need. Designed for college exams and technical demonstrations with clean architecture, Material 3 design, Provider state management, and Firebase services.

---

## 1. Project Overview

**LifeDrop** enables users to:
1. Register as blood donors with their details, blood group, city, and last donation date.
2. Search and filter available donors in real time by blood group and city.
3. Securely view donor contact information on-demand via a modern modal bottom sheet.
4. Manage authentication seamlessly with Firebase Authentication (Email & Password).

---

## 2. Key Features

- **Material 3 Theme & Healthcare Aesthetics**: Clean, trustworthy medical visual identity featuring deep blood-red tones, rounded input fields, soft shadows, and custom blood group badges.
- **Firebase Authentication**:
  - Email & Password registration and login.
  - Form validation with informative error messages.
  - Forgot password dialog for password reset links.
  - Automatic session restoration with stream-based routing (`AuthWrapper`).
- **Cloud Firestore Integration**:
  - Donor documents stored under the `donors` collection.
  - Donor profile tied directly to authenticated user's `uid`.
  - Server-side and reactive client-side filtering.
- **Provider State Management**:
  - `DonorProvider` centralizes donor listings, filter queries, loading state, and error handling.
  - UI listens reactively via `Consumer<DonorProvider>`.
- **Responsive Layout**:
  - Works across mobile, tablet, and web/desktop form factors using `LayoutBuilder`, `SingleChildScrollView`, and max-width constraints.
- **Privacy First**:
  - Phone numbers are hidden by default on search cards and only revealed when the recipient clicks **Contact**.

---

## 3. Project Architecture

```
lib/
├── main.dart                      # App entry point, MultiProvider, AuthWrapper & routes
├── models/
│   └── donor.dart                 # Donor data model with Firestore serialization
├── providers/
│   └── donor_provider.dart        # Provider for state management & reactive search
├── services/
│   ├── auth_service.dart          # Firebase Authentication wrapper
│   └── donor_service.dart         # Cloud Firestore CRUD and query operations
├── screens/
│   ├── login_screen.dart          # Screen 1: Premium onboarding & login with entrance animation
│   ├── register_screen.dart       # Screen 2: 3-step guided donor registration with celebration
│   ├── donor_search_screen.dart   # Screen 3: Search, filter chips, and responsive donor grid/list
│   ├── home_shell_screen.dart     # Responsive shell (NavigationBar on mobile, NavigationRail on tablet)
│   └── profile_screen.dart        # Profile & donor settings screen
├── widgets/
│   ├── brand_logo.dart            # Custom blood-drop + heart brand identity with aura rings
│   ├── blood_group_badge.dart     # Material 3 pill badge for blood groups
│   ├── donor_card.dart            # Figma-grade donor card with contact modal sheet
│   ├── filter_section.dart        # Reactive city search & horizontal blood group chips
│   └── skeleton_donor_card.dart   # Shimmer skeleton loader for intentional loading states
└── theme/
    └── app_theme.dart             # Figma design system (Warm off-white, blood red, blush accents)
```

---

## 4. Dependencies Used

- `firebase_core`: Core Firebase initialization.
- `firebase_auth`: User authentication (Login, Register, Logout, Reset).
- `cloud_firestore`: Realtime Cloud Firestore NoSQL database.
- `provider`: State management adhering to Flutter recommended patterns.
- `intl`: Date formatting for donation date picker.

---

## 5. Firestore Document Structure

Donors are stored in the `donors` collection where the document ID is the user's `uid`:

```json
{
  "uid": "4F9kL2xZ...",
  "name": "John Doe",
  "email": "johndoe@example.com",
  "phone": "+91 9876543210",
  "bloodGroup": "O+",
  "city": "Mumbai",
  "lastDonationDate": "15 September 2026",
  "createdAt": "2026-10-01T06:30:00.000Z"
}
```

---

## 6. How Provider is Used (Exam & Viva Explanation)

1. **State Centralization**: `DonorProvider` extends `ChangeNotifier` to hold:
   - `_donors`: Complete list of donors from Firestore.
   - `_filteredDonors`: List filtered by active filters.
   - `_selectedBloodGroup`: Current blood group filter (default: `'All'`).
   - `_selectedCity`: Search keyword for the city.
   - `_isLoading` & `_errorMessage`: Status flags.

2. **Reactivity**:
   - Calling `donorProvider.setBloodGroup('O+')` or `donorProvider.setCity('Mumbai')` updates the state, recalculates `_filteredDonors`, and invokes `notifyListeners()`.
   - Widgets wrapped with `Consumer<DonorProvider>` automatically rebuild with updated results without needing local `setState`.

---

## 7. Firebase Connection & Setup Details

The application is fully connected to Firebase through official FlutterFire modules:

### Configured Files:
1. **`lib/firebase_options.dart`**: Contains `DefaultFirebaseOptions.currentPlatform` mapping configuration for Android, iOS, Web, and macOS.
2. **`lib/main.dart`**: Initializes Firebase at startup via `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
3. **`android/settings.gradle.kts`**: Registered Google Services Gradle plugin (`com.google.gms.google-services` v4.4.2).
4. **`android/app/build.gradle.kts`**: Applied Google Services plugin and set `minSdk = 23`.
5. **`android/app/google-services.json`**: Pre-configured configuration file for `com.lifedrop.lifedrop`.
6. **`lib/services/donor_service.dart`**: Direct Cloud Firestore CRUD, querying, and a `seedSampleDonorsToFirestore()` helper for exam demo seeding.

### To Link Your Live Firebase Project:
1. Log into your Google account via Firebase CLI:
   ```bash
   firebase login
   ```
2. Automatically configure your live project for all platforms:
   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```
   This automatically synchronizes `lib/firebase_options.dart` and `android/app/google-services.json` with your project's live credentials.
3. Ensure **Email/Password** authentication is enabled in Firebase Console.
4. Ensure **Cloud Firestore** database is created with read/write rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /donors/{donorId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == donorId;
       }
     }
   }
   ```

---

## 8. How to Run the App

```bash
# Get dependencies
flutter pub get

# Check for analysis issues
flutter analyze

# Run unit & widget tests
flutter test

# Run the app on your connected device, emulator, or Chrome
flutter run
```
