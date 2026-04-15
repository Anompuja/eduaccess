# EduAccess — School Management System

A Flutter multiplatform app for managing school operations: attendance, CBT exams, student/teacher/staff data, and more.

> **Demo Mode** — the app runs fully offline with no backend required. Pick any role on the login screen to explore the app.

## Quick Start — Docker (Recommended for Assessment)

> Requires: [Docker](https://www.docker.com/get-started) and [Docker Compose](https://docs.docker.com/compose/)

```bash
# Clone the repo
git clone <repo-url>
cd eduaccess

# Build and run (first run takes a few minutes to pull Flutter image)
docker compose up --build

# Open in browser
# http://localhost:8080
```

To stop:

```bash
docker compose down
```

---

## Local Development

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) stable channel
- Chrome browser (for web development)

### Run on Chrome

```bash
flutter pub get
flutter run -d chrome
```

### Run on other platforms

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>
```

### Build web release

```bash
flutter build web --release --web-renderer canvaskit
# Output: build/web/
```

---

## Using the App (Demo Mode)

The app starts in **Demo Mode** — no backend or credentials needed.

1. Open the app in Chrome (or via Docker at `http://localhost:8080`)
2. You are taken to the **Login** screen
3. Tap any role card to sign in instantly:

| Role           | Access                                    |
| -------------- | ----------------------------------------- |
| Super Admin    | All screens and all data                  |
| Admin Sekolah  | All screens except subscription           |
| Kepala Sekolah | Dashboard, reports, students, teachers    |
| Guru           | Dashboard, attendance, CBT                |
| Siswa          | Personal dashboard, own attendance, CBT   |
| Orang Tua      | Personal dashboard, child attendance, CBT |
| Staff          | Dashboard and attendance only             |

4. Use the sidebar (desktop) or bottom nav (mobile) to navigate
5. Tap your avatar or **Logout** in settings to switch roles

---

## Project Structure

```
lib/
├── core/
│   ├── auth/           # Auth state, notifier, token storage
│   ├── api/            # Dio client, interceptors, endpoints
│   ├── router/         # GoRouter config, route names, RBAC guard
│   ├── theme/          # AppTheme, AppColors, AppTextStyles, AppSpacing
│   ├── utils/          # Responsive breakpoints
│   └── widgets/        # AppLayout, AppSidebar, shared widgets
└── features/
    ├── auth/           # Login screen (demo mode role picker)
    ├── dashboard/      # Role-aware dashboard with charts
    ├── students/       # Student management (CRUD modals)
    ├── teachers/       # Teacher list
    ├── staff/          # Staff list
    ├── parents/        # Parent list
    ├── profile/        # User profile
    ├── settings/       # App settings
    └── notifications/  # Notifications

assets/
└── images/
    └── logo.png        # App logo (Image.asset)

docker/
└── nginx/
    └── default.conf    # SPA routing config for Flutter web
```

---

## Tech Stack

| Layer            | Technology                                                            |
| ---------------- | --------------------------------------------------------------------- |
| UI Framework     | Flutter 3 (Dart 3)                                                    |
| State Management | Riverpod 2 (`StateNotifierProvider`)                                  |
| Navigation       | GoRouter 14 (`ShellRoute`, role guards)                               |
| HTTP Client      | Dio 5 (interceptors, token refresh)                                   |
| Local Storage    | SharedPreferences (demo session) + FlutterSecureStorage (real tokens) |
| Typography       | Google Fonts — Inter                                                  |
| Charts           | fl_chart                                                              |
| Container        | Docker + nginx (SPA)                                                  |

---

## Environment Configuration

To point the app at a real backend, pass the API base URL at build time:

```bash
flutter run --dart-define=EDUACCESS_BASE_URL=http://your-api-host/api/v1
```

Default fallbacks (when no `--dart-define` is provided):

- Web / Desktop: `http://localhost:8080/api/v1`
- Android emulator: `http://10.0.2.2:8080/api/v1`

---

© 2025 EduAccess
