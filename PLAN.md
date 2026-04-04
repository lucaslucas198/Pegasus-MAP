# Find Your Way Around — Development Plan

## Context

**App Name:** Find Your Way Around  
**School:** The Pegasus School  
**Platform:** Flutter (iOS & Android)  
**Goal:** A public-facing mobile app for parents to navigate The Pegasus School — finding rooms on a map, viewing upcoming events, and browsing teacher information. A hidden admin panel allows staff to manage teacher data.

---

## Tech Stack

| Layer | Choice | Reason |
|---|---|---|
| UI Framework | Flutter (Dart) | Cross-platform iOS + Android from one codebase |
| State Management | Riverpod | Modern, testable, minimal boilerplate |
| Navigation | go_router | Declarative routing, deep link support |
| Backend / DB | Firebase Firestore | Real-time, free tier, easy setup |
| File Storage | Firebase Storage | Teacher profile photos |
| Admin Auth | Firebase Authentication | Secure admin-only login |
| Calendar | Google Calendar API (`googleapis` package) | Sync with existing school calendar |
| Map Rendering | `flutter_svg` + `InteractiveViewer` | Zoomable/pannable map with room overlays |

---

## App Architecture

```
lib/
├── main.dart
├── app.dart                  # MaterialApp, theme, router setup
├── core/
│   ├── theme/                # Colors, typography, spacing
│   ├── router/               # go_router config + route names
│   └── firebase/             # Firebase initialization
├── features/
│   ├── home/
│   │   └── home_page.dart
│   ├── map/
│   │   ├── map_page.dart
│   │   ├── map_controller.dart
│   │   └── room_data.dart    # Room name → coordinates mapping
│   ├── calendar/
│   │   ├── calendar_page.dart
│   │   └── calendar_service.dart  # Google Calendar API calls
│   ├── teachers/
│   │   ├── teachers_page.dart
│   │   ├── teacher_detail_page.dart
│   │   └── teachers_repository.dart  # Firestore reads
│   └── admin/
│       ├── admin_login_page.dart
│       ├── admin_dashboard_page.dart
│       └── admin_teachers_page.dart  # Add/edit/delete teachers
└── shared/
    ├── widgets/              # Reusable UI components
    └── models/
        ├── teacher.dart
        └── event.dart
```

---

## Pages

### 1. Home Page
- Four large tappable cards — one per section (Map, Calendar, Teachers)
- School logo / name at top
- Each card has an icon, label, and short description
- Tapping navigates to the respective page

### 2. Map Page
- `InteractiveViewer` wrapping a placeholder school map image (later: real SVG floor plan)
- Search bar at the top — user types a room name
- Matching room is highlighted with a colored overlay/pin
- Room data (name → x/y coordinates on the image) stored in a local `room_data.dart` file; updated when the real floor plan arrives
- Multi-floor support deferred until real floor plan is available

### 3. Calendar Page
- Fetches upcoming events from The Pegasus School's Google Calendar via the Google Calendar API
- Events displayed in a scrollable list, ordered by date
- Each event shows: title, date/time, location (if provided), description (if provided)
- Pull-to-refresh to sync latest events
- Read-only (no editing from this page)

### 4. Teachers Page
- Grid or list of teacher cards pulled from Firestore
- Each card shows: name, subject, profile photo (from Firebase Storage)
- Tapping a card opens a detail view: full name, subject, room number, email
- Data is live — updates when admin makes changes

### 5. Admin Panel (hidden)
- Accessible via a secret route (e.g. `/admin`) — not shown in main navigation
- Admin logs in with email/password via Firebase Auth
- After login: list of all teachers with Add / Edit / Delete actions
- Photo upload via Firebase Storage
- Changes reflect immediately in the Teachers page

---

## Data Models

### `Teacher`
```dart
class Teacher {
  final String id;
  final String name;
  final String subject;
  final String roomNumber;
  final String email;
  final String photoUrl;
}
```

### `Event`
```dart
class Event {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? location;
  final String? description;
}
```

---

## Firebase Firestore Structure

```
/teachers/{teacherId}
  - name: string
  - subject: string
  - roomNumber: string
  - email: string
  - photoUrl: string (Firebase Storage URL)
```

Firestore rules: read = public, write = authenticated admin only.

---

## Development Phases

### Phase 0 — Environment Setup
- [ ] Install Flutter SDK
- [ ] Install Android Studio (for Android emulator + Android SDK)
- [ ] Install Xcode (for iOS simulator — Mac required)
- [ ] Set up VS Code with Flutter + Dart extensions
- [ ] Run `flutter doctor` and resolve all issues
- [ ] Create Firebase project, enable Firestore, Storage, and Authentication
- [ ] Create Google Cloud project, enable Google Calendar API, obtain API key

### Phase 1 — Project Scaffolding
- [ ] `flutter create find_your_way_around`
- [ ] Add dependencies to `pubspec.yaml`: `go_router`, `flutter_riverpod`, `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `googleapis`, `flutter_svg`, `cached_network_image`
- [ ] Set up app theme (colors, fonts — Pegasus School branding TBD)
- [ ] Configure go_router with named routes for all 5 pages
- [ ] Build the shared bottom navigation bar (Home, Map, Calendar, Teachers)

### Phase 2 — Home Page
- [ ] Layout with 3 feature cards (Map, Calendar, Teachers)
- [ ] School name/logo header
- [ ] Navigation wired to each section

### Phase 3 — Map Page
- [ ] Placeholder map image integrated with `InteractiveViewer`
- [ ] Search bar with basic room lookup
- [ ] Room highlight overlay on search result
- [ ] `room_data.dart` with placeholder room coordinates

### Phase 4 — Calendar Page
- [ ] `CalendarService` calling Google Calendar API
- [ ] Event list UI
- [ ] Pull-to-refresh
- [ ] Empty/error states

### Phase 5 — Teachers Page + Admin Panel
- [ ] `TeachersRepository` reading from Firestore
- [ ] Teachers grid/list + detail view
- [ ] Admin login page
- [ ] Admin CRUD interface for teacher records
- [ ] Firebase Storage photo upload

### Phase 6 — Polish & Deployment
- [ ] Replace placeholder map with real Pegasus School floor plan
- [ ] Populate real teacher data
- [ ] Connect real Google Calendar
- [ ] App icons + splash screen
- [ ] Test on physical iOS and Android devices
- [ ] Publish to App Store and Google Play

---

## Key Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
  flutter_riverpod: ^2.5.0
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  firebase_auth: ^5.0.0
  firebase_storage: ^12.0.0
  googleapis: ^13.0.0
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
  image_picker: ^1.1.0       # for admin photo upload
```

---

## Open Questions / Deferred Decisions

- **School branding**: Exact colors and logo for The Pegasus School not yet confirmed — use neutral placeholders until provided.
- **Floor plan**: No image yet — placeholder used in Phase 3; real map swapped in during Phase 6.
- **Google Calendar ID**: Need the specific calendar ID (or sharing settings) from the school to wire up the API.
- **Admin credentials**: Decide who holds the admin Firebase account and how login details are shared securely.
- **App Store accounts**: Apple Developer Program ($99/yr) and Google Play Developer account ($25 one-time) needed before Phase 6.
