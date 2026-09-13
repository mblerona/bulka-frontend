import 'package:bulka_frontend/models/auth_user.dart';

/// The `data` payload of a successful `/api/auth/login` response. Field
/// names match the confirmed live response exactly; nothing here is guessed.
///
/// Every field except [twoFactorChallenge] is nullable even though the one
/// observed (non-2FA) login always populated them — a login that instead
/// returns a [twoFactorChallenge] very plausibly omits the tokens/user
/// entirely, but no such response has actually been observed, so this
/// doesn't assume tokens are always present. 2FA itself is out of scope for
/// this integration step; callers must treat a non-null [twoFactorChallenge]
/// (or missing tokens) as "login not completed" rather than crash on it.
class LoginResponseData {
  const LoginResponseData({
    this.accessToken,
    this.accessTokenExpiresAtUtc,
    this.refreshToken,
    this.user,
    this.twoFactorChallenge,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    final expiresRaw = json['accessTokenExpiresAtUtc'] as String?;
    final userRaw = json['user'] as Map<String, dynamic>?;
    return LoginResponseData(
      accessToken: json['accessToken'] as String?,
      accessTokenExpiresAtUtc: expiresRaw == null
          ? null
          : DateTime.tryParse(expiresRaw),
      refreshToken: json['refreshToken'] as String?,
      user: userRaw == null ? null : AuthUser.fromJson(userRaw),
      // Shape unconfirmed — no login response with a real (non-null)
      // challenge has been observed. Kept untyped on purpose rather than
      // guessed at; 2FA completion is a later integration step.
      twoFactorChallenge: json['twoFactorChallenge'],
    );
  }

  final String? accessToken;
  final DateTime? accessTokenExpiresAtUtc;
  final String? refreshToken;
  final AuthUser? user;
  final Object? twoFactorChallenge;

  /// True once tokens + user actually came back — i.e. the login is
  /// genuinely complete, not pending a 2FA step this app doesn't handle yet.
  bool get isCompleteLogin =>
      twoFactorChallenge == null &&
      accessToken != null &&
      refreshToken != null &&
      accessTokenExpiresAtUtc != null &&
      user != null;
}
