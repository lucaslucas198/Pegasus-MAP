# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands must be run from inside `find_your_way_around/`:

```bash
# Run in Chrome (primary dev target)
flutter run -d chrome

# Production web build
flutter build web

# Analyze for type errors and lints
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart
```

## Architecture

### Project layout

The Flutter app lives entirely under `find_your_way_around/lib/`:

```
lib/
  main.dart                  # Firebase init → ProviderScope → App
  app.dart                   # MaterialApp.router wired to routerProvider
  core/
    router/app_router.dart   # All routes (GoRouter)
    theme/app_theme.dart     # AppColors constants + buildAppTheme()
  features/
    home/                    # Home page with hero carousel + content sections
    map/                     # Interactive campus map
      map_page.dart          # Map UI: InteractiveViewer + tappable rooms
      room_data.dart         # kRooms list — all room positions, photos, directions
    calendar/
      calendar_service.dart  # Google Calendar API fetch; falls back to _demoEvents()
      calendar_page.dart
    teachers/
      teachers_repository.dart  # Firestore stream; falls back to _demoTeachers()
      teachers_page.dart
      teacher_detail_page.dart
    admin/                   # Admin-only CRUD for teachers (Firebase Auth guarded)
  shared/
    models/                  # Teacher, Event data classes
    widgets/scaffold_with_nav.dart  # Shell widget with sidebar (≥720px) or bottom nav
```

### Routing

`app_router.dart` defines a `ShellRoute` that wraps `/home`, `/map`, `/calendar`, and `/teachers` inside `ScaffoldWithNav`. The `/admin` and `/admin/dashboard` routes sit outside the shell — they have no nav bar.

Navigation within the shell uses `context.go(route)`.

### State management

Riverpod is used throughout. Key providers:
- `routerProvider` — singleton GoRouter
- `teachersStreamProvider` — `StreamProvider` wrapping Firestore `watchAll()`
- `teachersRepositoryProvider` — `TeachersRepository` instance
- `eventsProvider` — `FutureProvider` wrapping `CalendarService.fetchUpcomingEvents()`

### Firebase / demo data

Firebase is fully configured but both live data sources gracefully degrade:
- **Teachers**: `TeachersRepository.watchAll()` returns `_demoTeachers()` when the Firestore collection is empty.
- **Calendar**: `CalendarService.fetchUpcomingEvents()` returns `_demoEvents()` when `_calendarId == 'TODO_CALENDAR_ID'` (the current state — no live calendar is connected).

To connect a real Google Calendar, replace `_calendarId` in `calendar_service.dart`.

### Interactive map

The campus map uses a fixed `1000×760` logical-pixel canvas inside `InteractiveViewer(constrained: false)`. Room positions in `room_data.dart` are stored as normalized coordinates `[0..1]` — multiply by `_kCanvasW`/`_kCanvasH` to get pixel positions.

The `Stack` layer order matters:
1. `_BackgroundPainter` — ground, walkways, courtyard, sports field
2. `_RoomWidget` list — `GestureDetector` + `AnimatedContainer` per room
3. `_OverlayPainter` wrapped in `IgnorePointer` — compass, legend, title banner (must be `IgnorePointer` or it blocks all room taps)
4. `_HintBadge` — shown only when no room is selected

Tapping a room calls `showModalBottomSheet` with `_RoomDetailSheet`, which shows the room photo, description, and numbered directions.

### Responsive layout

`MediaQuery.of(context).size.width >= 720` is the single breakpoint used across all pages. Below 720px uses a bottom `NavigationBar`; at or above uses the dark navy `_SideNavBar` (228px wide).

### Theme

`AppColors` in `app_theme.dart` defines all shared colors. Key values:
- `primary` — `Color(0xFF1B3A6B)` (navy)
- `secondary` — `Color(0xFFC5A028)` (gold)
- `navDark` — `Color(0xFF152E58)` (sidebar background)

Typography: `GoogleFonts.merriweather` for headings, `GoogleFonts.openSans` for body/labels.

The real Pegasus School circular seal is at `assets/images/logo.png`. School photos are loaded from the school's Finalsite CDN using `CachedNetworkImage`.
