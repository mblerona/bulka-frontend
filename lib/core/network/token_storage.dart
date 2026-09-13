import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The only place the access/refresh token session is persisted. Nothing
/// else — not [SessionController]'s callers, not any screen — should touch
/// [FlutterSecureStorage] directly. Passwords are never written here or
/// anywhere else.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _accessTokenExpiresAtKey = 'auth_access_token_expires_at_utc';

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAtUtc,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(
        key: _accessTokenExpiresAtKey,
        value: accessTokenExpiresAtUtc.toIso8601String(),
      ),
    ]);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<DateTime?> readAccessTokenExpiresAtUtc() async {
    final raw = await _storage.read(key: _accessTokenExpiresAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _accessTokenExpiresAtKey),
    ]);
  }
}
