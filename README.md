# EduAccess — Flutter App

Aplikasi manajemen sekolah multiplatform (Flutter) yang terhubung ke EduAccess API backend.

---

## Quick Start

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) stable channel (≥ 3.11)
- Chrome browser (untuk Flutter Web) atau Android emulator / device fisik

### Jalankan dengan Backend (Mode Penuh)

Pastikan backend EduAccess API sudah berjalan di `http://localhost:8080` terlebih dahulu.

```bash
# Install dependencies
flutter pub get

# Jalankan di Chrome (web)
flutter run -d chrome \
  --dart-define=EDUACCESS_BASE_URL=http://localhost:8080/api/v1 \
  --dart-define=EDUACCESS_WS_BASE=ws://localhost:8080

# Jalankan di Android emulator
flutter run -d emulator-5554 \
  --dart-define=EDUACCESS_BASE_URL=http://10.0.2.2:8080/api/v1 \
  --dart-define=EDUACCESS_WS_BASE=ws://10.0.2.2:8080

# Jalankan di device fisik (ganti IP sesuai IP komputer di jaringan yang sama)
flutter run \
  --dart-define=EDUACCESS_BASE_URL=http://192.168.x.x:8080/api/v1 \
  --dart-define=EDUACCESS_WS_BASE=ws://192.168.x.x:8080
```

### Jalankan Tanpa Backend (Fallback Demo)

```bash
flutter pub get
flutter run -d chrome
```

App akan berjalan dengan data mock — fungsi core tetap bisa dieksplorasi.

---

## Environment Variables

Dikonfigurasi via `--dart-define` saat build/run (tidak ada file `.env` di Flutter).

| Variabel               | Default                          | Keterangan                                  |
| ---------------------- | -------------------------------- | ------------------------------------------- |
| `EDUACCESS_BASE_URL`   | `http://localhost:8080/api/v1`   | Base URL REST API backend                   |
| `EDUACCESS_WS_BASE`    | `ws://localhost:8080`            | Base URL WebSocket (tanpa path `/api/v1`)   |

Untuk Android emulator gunakan `10.0.2.2` sebagai pengganti `localhost`.

---

## Arsitektur

Setiap fitur mengikuti pola **Clean Architecture** dengan tiga layer yang terpisah:

```
lib/
├── core/
│   ├── api/          # Dio client, interceptors, endpoint constants, cache policies
│   ├── auth/         # Auth state, token storage (FlutterSecureStorage)
│   ├── providers/    # Root Riverpod providers
│   ├── router/       # GoRouter + RBAC route guard
│   ├── theme/        # AppTheme, warna, typography
│   └── widgets/      # Shared layout widgets (AppSidebar, AppLayout)
└── features/
    └── {feature}/
        ├── domain/
        │   ├── entities/         # Pure Dart class (tanpa Flutter/Dio)
        │   └── repositories/     # Abstract interface
        ├── data/
        │   ├── models/           # JSON ↔ entity mapping (fromJson/toJson)
        │   ├── datasources/      # HTTP call via Dio (implementasi akses data)
        │   └── repositories/     # Implementasi domain repository interface
        └── presentation/
            ├── pages/            # Widget layar utama
            ├── widgets/          # Widget komponen per fitur
            └── providers/        # Riverpod StateNotifier / FutureProvider / StreamProvider
```

**Pemisahan layer:**
- `presentation/` hanya berinteraksi dengan Riverpod provider — tidak ada `Dio.get()` di layer UI
- `domain/` tidak punya import Flutter/Dio sama sekali — murni logika dan kontrak
- `data/` menangani semua akses jaringan dan mapping JSON

---

## State Management — Riverpod

Semua state global dikelola dengan **Riverpod 2** (`StateNotifierProvider`, `FutureProvider`, `StreamProvider`).

Contoh alur ketika halaman daftar siswa dibuka:

1. `StudentListPage` melakukan `ref.watch(studentListProvider)`
2. `studentListProvider` adalah `FutureProvider` yang memanggil `StudentRepository.getStudents()`
3. Repository memanggil `StudentRemoteDataSource.fetchStudents()` via Dio
4. UI bereaksi otomatis terhadap state: loading → data → error

Halaman admin, guru, orang tua, dan staff mengikuti pola yang sama persis — hanya berbeda entity dan endpoint yang dipanggil.

---

## Async — Future & Stream

### Future (REST API)

Semua operasi REST API menggunakan `Future` — operasi satu kali yang resolve ketika response diterima:

```dart
// lib/features/students/data/datasources/student_remote_data_source.dart
Future<List<StudentModel>> fetchStudents({int page = 1}) async {
  final response = await _dio.get(
    ApiEndpoints.students,
    queryParameters: {'page': page, 'per_page': 20},
  );
  return (response.data['data'] as List)
      .map((e) => StudentModel.fromJson(e))
      .toList();
}
```

### Stream (WebSocket Real-time)

Notifikasi real-time menggunakan `StreamProvider` — data mengalir terus-menerus dari koneksi WebSocket:

```dart
// lib/features/notifications/presentation/providers/notifications_provider.dart
final notificationWsProvider = StreamProvider.autoDispose<NotificationEntity>((ref) async* {
  final token = await ref.read(tokenStorageProvider).getAccessToken();
  final channel = WebSocketChannel.connect(
    Uri.parse('${_resolveWsBase()}/ws/notifications?token=${Uri.encodeComponent(token!)}'),
  );
  await channel.ready;

  await for (final message in channel.stream) {
    final json = jsonDecode(message as String) as Map<String, dynamic>;
    final notification = NotificationModel.fromJson(json);
    ref.invalidate(unreadNotificationsProvider); // refresh badge count
    yield notification;
  }
});
```

`StreamProvider` di-dispose otomatis saat widget keluar dari tree — tidak ada memory leak.

---

## Caching HTTP

Dio dikonfigurasi dengan `dio_cache_interceptor` yang menghormati header `Cache-Control` dan `ETag` dari backend:

- Request pertama: data diambil dari server, disimpan di `MemCacheStore`
- Request berikutnya (dalam TTL): data dikembalikan dari cache tanpa hit network
- Setelah TTL habis: request dikirim dengan `If-None-Match: <etag>`, server membalas `304 Not Modified` jika data tidak berubah

Cache dibersihkan saat logout agar data satu user tidak bocor ke user berikutnya.

---

## Tech Stack

| Layer            | Library                    | Versi   |
| ---------------- | -------------------------- | ------- |
| State Management | `flutter_riverpod`         | ^2.6.1  |
| Navigation       | `go_router`                | ^14.6.3 |
| HTTP Client      | `dio`                      | ^5.8.0  |
| HTTP Cache       | `dio_cache_interceptor`    | ^4.0.6  |
| WebSocket        | `web_socket_channel`       | ^3.0.1  |
| Token Storage    | `flutter_secure_storage`   | ^9.2.4  |
| Charts           | `fl_chart`                 | ^0.69.0 |
| QR Scanner       | `mobile_scanner`           | ^6.0.0  |

---

## Struktur Navigasi & Role

Akses halaman dikontrol oleh **RBAC guard** di GoRouter (`lib/core/router/`). Setiap role mendapat akses berbeda:

| Role           | Akses                                                           |
| -------------- | --------------------------------------------------------------- |
| `superadmin`   | Semua halaman + manajemen sekolah dan langganan                 |
| `admin_sekolah`| Dashboard, siswa, guru, staff, orang tua, notifikasi            |
| `kepala_sekolah`| Dashboard, laporan, data siswa dan guru                        |
| `guru`         | Dashboard, jadwal kelas, absensi, notifikasi                    |
| `siswa`        | Dashboard pribadi, jadwal, absensi sendiri                      |
| `orangtua`     | Dashboard, absensi anak, notifikasi                             |
| `staff`        | Dashboard, absensi                                              |
