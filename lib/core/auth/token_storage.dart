import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

// ── Keys ──────────────────────────────────────────────────────────────────────
const _kAccessToken = 'edu_access_token';
const _kRefreshToken = 'edu_refresh_token';

// ── TokenStorage ─────────────────────────────────────────────────────────────
/// Wraps token persistence.
/// On web: uses SharedPreferences (localStorage) to avoid the Web Crypto API
/// race condition in flutter_secure_storage_web (OperationError on read after
/// write in the same session).
/// On mobile/desktop: uses flutter_secure_storage for OS-level encryption.
///
/// All token I/O must go through this class — never read storage directly.
class TokenStorage {
  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Persist both tokens after a successful login / token refresh.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_kAccessToken, accessToken),
        prefs.setString(_kRefreshToken, refreshToken),
      ]);
    } else {
      await Future.wait([
        _secure.write(key: _kAccessToken, value: accessToken),
        _secure.write(key: _kRefreshToken, value: refreshToken),
      ]);
    }
  }

  /// Returns the stored access token, or null if not present.
  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kAccessToken);
    }
    return _secure.read(key: _kAccessToken);
  }

  /// Returns the stored refresh token, or null if not present.
  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kRefreshToken);
    }
    return _secure.read(key: _kRefreshToken);
  }

  /// Returns true if an access token exists in storage.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Clears all tokens (called on logout or refresh failure).
  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_kAccessToken),
        prefs.remove(_kRefreshToken),
      ]);
    } else {
      await Future.wait([
        _secure.delete(key: _kAccessToken),
        _secure.delete(key: _kRefreshToken),
      ]);
    }
  }
}
