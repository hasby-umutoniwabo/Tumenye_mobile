# Tumenye - Digital Literacy App for Rwandan Students

Tumenye is a mobile application developed to teach digital literacy skills to students in Rwanda. It covers topics such as word processing, spreadsheets, email, and internet safety, with support for both English and Kinyarwanda.

## Features

### Students
- Bilingual lessons (English and Kinyarwanda).
- Learning modules for Word, Excel, Email, and Safety.
- Quizzes with progress tracking.
- Achievement system and usage metrics.

### Parents
- Link parent and student accounts via email.
- Monitor child's progress and quiz results.
- View screen time and learning activity logs.

### Administrators
- Manage curriculum (modules, lessons, and quizzes).
- View student list and system-wide activity.
- Initial data seeding for new environments.

## Tech Stack

- **Framework:** Flutter
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Backend:** Firebase (Auth, Firestore, Storage)

## Setup and Installation

### Prerequisites

- Flutter SDK (version 3.3.0 or higher)
- Android Studio / Xcode
- Firebase account

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/hasby-umutoniwabo/Tumenye_mobile.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Firebase Configuration:
   - Create a new project in the Firebase Console.
   - Add Android/iOS apps and download configuration files.
   - Place `google-services.json` in `android/app/`.
   - Place `GoogleService-Info.plist` in `ios/Runner/`.
   - Enable Email/Password authentication and Firestore.

4. Run the application:
   ```bash
   flutter run
   ```

### Data Seeding
On the first launch, the app will check for existing data in Firestore. If the database is empty, it will automatically populate the initial curriculum modules and lessons.

## Project Structure

- `lib/core/`: Application core, themes, navigation, models, and services.
- `lib/features/`: Feature-specific logic and UI (auth, home, quiz, admin).
- `lib/shared/`: Common widgets and utilities.
- `lib/main.dart`: Application entry point.

## License
MIT License
