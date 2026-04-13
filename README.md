# EduAccess Frontend

Flutter client for EduAccess School Management.

## Prerequisites

- Flutter SDK (stable)
- Running EduAccess backend API

## API Base URL

Frontend reads API base URL from:

`EDUACCESS_BASE_URL` via `--dart-define`

If not provided, app uses local-development defaults:

- Web/Desktop: `http://localhost:8080/api/v1`
- Android emulator: `http://10.0.2.2:8080/api/v1`

## Run With Backend

1. Start backend first:

```bash
cd ../EduAccessBackend/eduaccess-api
go run ./cmd/main.go
```

2. Start Flutter app from this folder:

```bash
# Web/Desktop
flutter run --dart-define=EDUACCESS_BASE_URL=http://localhost:8080/api/v1

# Android emulator
flutter run --dart-define=EDUACCESS_BASE_URL=http://10.0.2.2:8080/api/v1
```

## Authentication Contract

Integrated endpoints used by frontend:

- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /profile`

All requests are sent under backend prefix `/api/v1`.
