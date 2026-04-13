import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

// ── Keys ──────────────────────────────────────────────────────────────────────
const _kAccessToken  = 'edu_access_token';
const _kRefreshToken = 'edu_refresh_token';

// ── TokenStorage ─────────────────────────────────────────────────────────────
/// Wraps flutter_secure_storage for JWT token persistence.
/// All token I/O must go through this class — never read SecureStorage directly.
class TokenStorage {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Persist both tokens after a successful login / token refresh.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  /// Returns the stored access token, or null if not present.
  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  /// Returns the stored refresh token, or null if not present.
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  /// Returns true if an access token exists in storage.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Clears all tokens (called on logout or refresh failure).
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
  }
}
