# Tumenye

Tumenye is a cross-platform mobile application built with Flutter and Firebase. It is designed to help Rwandan students aged 8–18 build practical digital skills through structured, interactive lessons covering Word Processing, Spreadsheets, Email Communication, and Online Safety. The app runs on Android and iOS from a single codebase and supports English, Kinyarwanda, and French.

> African Leadership University — Software Engineering Final Project, March 2025

---


## Features

**Students** can work through four sequential learning modules — Word, Excel, Email, and Online Safety — with lessons available in English, Kinyarwanda, and French. Each lesson ends with a multiple-choice quiz; a score of 70% or above is required to progress. Completed lessons and quiz scores are tracked, and badges are awarded for milestones such as finishing a module or achieving a perfect score. A daily learning goal tracker shows progress against a user-defined time target.

**Parents** can link their account to a child's account using the child's email address. The parent dashboard shows recently completed lessons, quiz results, and a log of learning activity over time.

**Administrators** have full control over the curriculum. They can create, edit, and delete modules, lessons, and quiz questions directly within the app. The admin dashboard also shows a list of all registered students, a real-time activity feed, and key statistics such as total students and active lessons.

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | [Flutter](https://flutter.dev) — Dart, stable channel, version 3.19 or higher |
| State Management | [Riverpod](https://riverpod.dev) |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) |
| Backend | [Firebase](https://firebase.google.com) — Authentication, Firestore, Storage |
| Offline Storage | [Hive](https://docs.hivedb.dev) |
| Localization | [easy_localization](https://pub.dev/packages/easy_localization) |
| Notifications | Firebase Cloud Messaging (FCM) |

---

## Database Architecture

Tumenye uses Cloud Firestore as its primary database, organized into the following top-level collections:

| Collection | Purpose |
|------------|---------|
| `users` | User profiles, roles (student / parent / admin), language preference, FCM token |
| `modules` | Course modules with title, icon, color, and references to constituent lessons |
| `lessons` | Lesson content including title, body text, difficulty level, and estimated reading time |
| `quizzes` | Multiple-choice question sets linked to each lesson |
| `progress` | Per-user record of completed lessons, quiz scores, earned badges, streak count, and total learning time |
| `quiz_results` | Individual quiz attempt records with score and timestamp |
| `activity` | Log of student events surfaced in the admin dashboard |
| `notifications` | Push notification history per user |

### Offline Support

Offline functionality is handled by Hive, which manages three local storage boxes on the device:

- `LessonsBox` — lesson documents cached by lesson ID. Cached content is served immediately if it is less than seven days old; otherwise a fresh Firestore fetch is made and the cache is updated.
- `QuizzesBox` — quiz question sets cached by quiz ID.
- `PendingProgressBox` — progress updates (lesson completions, quiz scores) recorded while offline and flushed to Firestore when the device reconnects.

---

## Project Structure

```
lib/
├── main.dart                  # Application entry point
├── core/
│   ├── constants/             # App-wide constants and shared preference keys
│   ├── models/                # Data models: User, Module, Lesson, Quiz, Progress
│   ├── services/              # Firebase service wrappers: Auth, Firestore, Storage
│   ├── routing/               # GoRouter setup and role-based redirect logic
│   └── theme/                 # Light and dark theme definitions
├── features/
│   ├── auth/                  # Login, registration, email verification, password reset
│   ├── home/                  # Student home dashboard
│   ├── modules/               # Module list and lesson viewer
│   ├── quiz/                  # Quiz screen and results display
│   ├── achievements/          # Badge system
│   ├── parent/                # Parent dashboard and activity feed
│   ├── admin/                 # Admin dashboard, curriculum management, student list
│   └── settings/              # Theme toggle, language selection, daily goal, offline mode
└── shared/
    └── widgets/               # Reusable UI components shared across features
```

---

## Setup and Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — stable channel, version 3.19 or higher
- Dart SDK (bundled with Flutter)
- Android Studio (for Android emulation) or Xcode (for iOS)
- Git
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

---

### Step 1 — Clone the repository

```bash
git clone https://github.com/hasby-umutoniwabo/Tumenye_mobile.git
cd Tumenye_mobile
```

### Step 2 — Install dependencies

```bash
flutter pub get
```

### Step 3 — Configure Firebase

**For team members joining the existing project:**

Ask a project owner to add you under Firebase Console → Project Settings → Members and roles. Once you have access:

1. Go to [Firebase Console](https://console.firebase.google.com) and open the Tumenye project
2. Navigate to Project Settings → Your apps
3. Download `google-services.json` and place it in `android/app/`
4. Download `GoogleService-Info.plist` and place it in `ios/Runner/`
5. Run the FlutterFire CLI to generate `lib/firebase_options.dart`:

```bash
flutterfire configure
```

**For independent deployments:**

1. Create a new project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Email/Password and Google Sign-In under Authentication → Sign-in Method
3. Create a Cloud Firestore database in production mode
4. Enable Firebase Storage
5. Download the config files and place them as described above
6. Run `flutterfire configure` to generate `firebase_options.dart`

### Step 4 — Add Cloudinary credentials

Profile image uploads use Cloudinary. Create the file `lib/core/constants/secrets.dart` with the following content:

```dart
class Secrets {
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String cloudinaryApiKey = 'YOUR_API_KEY';
  static const String cloudinaryApiSecret = 'YOUR_API_SECRET';
}
```

Obtain the values from your Cloudinary dashboard. This file is listed in `.gitignore` and must not be committed to version control.

### Step 5 — Verify your environment

```bash
flutter doctor -v
```

All required dependencies should show a checkmark before proceeding.

### Step 6 — Run the application

```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

To target a specific device:

```bash
flutter run -d <device_id>
```

To build a release APK:

```bash
flutter build apk --release
```

---

## Data Seeding

On first launch, the app checks whether Firestore contains any curriculum data. If the database is empty, it automatically populates the initial modules, lessons, and quiz questions so the app is usable immediately without any manual data entry.

---

## Testing

### Running automated tests

```bash
flutter test
```

### Unit tests — `test/unit_test.dart`

Cover the following areas of application logic:

- **AppStrings** — confirms the app name and tagline constants are correctly defined
- **PrefKeys** — checks that all `shared_preferences` key constants are unique, catching key collision bugs at test time rather than runtime
- **ModuleData** — validates the progress calculation logic, including correct percentage output, protection against division by zero when `totalLessons` is 0, and that all computed values stay within the range [0.0, 1.0]

### Widget tests — `test/widget_test.dart`

Render key screens in a test environment and assert that they display correctly and handle state transitions as expected. Coverage includes the authentication screens, the home dashboard, and quiz screen interactions.

### Manual testing

The following scenarios were tested on physical Android devices and the Android emulator:

| Test Case | Result |
|-----------|--------|
| User registration with valid email | PASS |
| Registration with an email already in use | PASS |
| Google Sign-In routes to home dashboard | PASS |
| Login with incorrect password shows error | PASS |
| Unverified users are blocked from the home screen | PASS |
| Completing a lesson updates progress in Firestore | PASS |
| Correct quiz answer is highlighted green | PASS |
| Incorrect quiz answer is highlighted red | PASS |
| Quiz result is saved to Firestore with correct timestamp | PASS |
| Admin-added module appears on the student Modules screen immediately | PASS |
| Switching language to Kinyarwanda updates all UI text | PASS |
| Dark mode toggle persists after app restart | PASS |
| Admin user cannot access student routes | PASS |
| Parent dashboard correctly displays child activity | PASS |

---

## Localization

The app supports three languages, selectable from the Settings screen: English, Kinyarwanda, and French. Language preference is stored per user via `shared_preferences` and applied on next launch.

---

## Security

Firestore security rules are configured so that authenticated users can only read and write their own documents. Role-based routing in GoRouter ensures that students, parents, and admins cannot navigate to each other's screens. The following files contain sensitive credentials and are excluded from version control via `.gitignore`:

- `lib/firebase_options.dart`
- `lib/core/constants/secrets.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

---

