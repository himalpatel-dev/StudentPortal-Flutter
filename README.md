# Stradia Ace

A premium athletic portal for students to manage their tournament registrations, track match results, and maintain their athlete profile.

## Features

- **Athlete ID Card**: Digital identification for student athletes.
- **Tournament Management**: Register for upcoming tournaments and view ongoing participation.
- **Career Archive**: Historical record of all matches, bouts, and medals (Gold, Silver, Bronze).
- **Real-time Fixtures**: View match schedules, ring assignments, and reporting times.
- **Profile Management**: Maintain personal, physical, and document records.

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **API Integration**: RESTful APIs via `http`
- **Data Persistence**: `shared_preferences`
- **Modern UI**: Custom gradients, animated transitions, and premium typography.

## Getting Started

1. **Clone the repository**
2. **Install dependencies**: `flutter pub get`
3. **Run the application**: `flutter run`

## Production Notes

- API endpoints are configured in `lib/utils/api_constants.dart`.
- The app uses `google_fonts` for premium typography.
- Built for both Android and iOS platforms.
