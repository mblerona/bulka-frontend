import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/models/backend_role_mapper.dart';
import 'package:bulka_frontend/models/login_response_data.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/services/auth_repository.dart';

/// Single shared source of truth for "am I logged in, as whom" — same
/// `ChangeNotifier` singleton pattern as `ProviderListingController`/
/// `ReservationController`/etc. Registers itself with [ApiClient] as its
/// access-token provider so the Bearer interceptor stays centralized;
/// nothing else should read a token directly, and no screen should touch
/// [TokenStorage] itself.
class SessionController extends ChangeNotifier {
  SessionController._({AuthRepository? authRepository, TokenStorage? tokenStorage})
    : _authRepository = authRepository ?? AuthRepository(),
      _tokenStorage = tokenStorage ?? TokenStorage() {
    ApiClient.instance.setAccessTokenProvider(() => _accessToken);
    ApiClient.instance.setUnauthorizedRefreshHandler(attemptTokenRefresh);
  }

  static final SessionController instance = SessionController._();

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthUser? _currentUser;
  String? _accessToken;
  DateTime? _accessTokenExpiresAtUtc;
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailNotVerified = false;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _accessToken != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get accessTokenExpiresAtUtc => _accessTokenExpiresAtUtc;

  /// True when the most recent failed [login] failed specifically because
  /// the account's email isn't verified yet — confirmed live as a 403 with
  /// error code `AUTH_EMAIL_NOT_VERIFIED`. Lets callers (e.g. `LoginScreen`)
  /// redirect straight to email verification instead of just showing
  /// [errorMessage] inline. Reset to `false` at the start of every [login]
  /// call, so a stale `true` never survives into an unrelated attempt.
  bool get emailNotVerified => _emailNotVerified;

  /// The app-level role derived from the backend's raw `roles` list — can
  /// legitimately be `null` even after a successful login (e.g. "Admin", or
  /// any role not yet mapped in [mapBackendRoleToUserRole]). Callers must
  /// treat `null` as "logged in, but no app destination for this role yet",
  /// never default it to [UserRole.buyer].
  UserRole? get appRole =>
      _currentUser == null ? null : mapBackendRoleToUserRole(_currentUser!.roles);

  /// Attempts a real login against the backend. Returns `true` only when a
  /// complete (non-2FA-pending) session was established and stored; `false`
  /// otherwise, with [errorMessage] set to a message safe to show the user.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _emailNotVerified = false;
    notifyListeners();

    try {
      final data = await _authRepository.login(email: email, password: password);

      if (!data.isCompleteLogin) {
        // Two-factor challenge (or an incomplete response) — not
        // implemented yet; don't fabricate a session out of partial data.
        _errorMessage = AppStrings.loginTwoFactorUnsupported;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _applyAuthenticatedSession(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _emailNotVerified = e.hasErrorCode('AUTH_EMAIL_NOT_VERIFIED');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Persists [data]'s tokens and applies them in-memory — the shared
  /// tail end of both [login] and [attemptTokenRefresh], since a
  /// successful refresh hands back the exact same shape (and, on
  /// `/api/auth/refresh`, a rotated refresh token that needs to overwrite
  /// the old one the same way a fresh login's does). Doesn't touch
  /// [isLoading]/[errorMessage]/[notifyListeners] — callers do that
  /// themselves, since they need different timing around it.
  Future<void> _applyAuthenticatedSession(LoginResponseData data) async {
    await _tokenStorage.saveSession(
      accessToken: data.accessToken!,
      refreshToken: data.refreshToken!,
      accessTokenExpiresAtUtc: data.accessTokenExpiresAtUtc!,
    );

    _accessToken = data.accessToken;
    _accessTokenExpiresAtUtc = data.accessTokenExpiresAtUtc;
    _currentUser = data.user;
  }

  /// Attempts to restore a previous session from [TokenStorage] on app
  /// start — the counterpart to [login] for a cold start where a valid
  /// session may already exist on disk (tokens are saved on every real
  /// login, but nothing ever read them back until now). Returns `true`
  /// only once `GET /api/users/me` actually confirms the stored access
  /// token still works (and [currentUser]/[appRole] get populated from
  /// that); `false` for "nothing stored" and "stored token no longer
  /// works" alike — callers should treat both the same way (go to Login).
  /// A no-op returning `true` immediately if a session is already in
  /// memory ([isAuthenticated]) — safe to call more than once.
  Future<bool> restoreSession() async {
    if (isAuthenticated) return true;

    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();
    final expiresAt = await _tokenStorage.readAccessTokenExpiresAtUtc();
    if (accessToken == null || refreshToken == null || expiresAt == null) {
      return false;
    }

    _accessToken = accessToken;
    _accessTokenExpiresAtUtc = expiresAt;

    try {
      // If the stored access token had expired, `ApiClient`'s 401-retry
      // interceptor will have already called `attemptTokenRefresh` and
      // transparently retried this same call with a refreshed token
      // before this line ever sees a failure — so this succeeding doesn't
      // necessarily mean the original stored access token was still good.
      _currentUser = await _authRepository.getCurrentUser();
      notifyListeners();
      return true;
    } on ApiException {
      // Either the refresh attempt above also failed (`attemptTokenRefresh`
      // already cleared storage itself in that case) or this failed for a
      // reason that was never about the token at all (e.g. no network) —
      // clear this instance's own in-memory fields regardless, so a
      // half-restored session never lingers either way.
      _accessToken = null;
      _accessTokenExpiresAtUtc = null;
      _currentUser = null;
      await _tokenStorage.clear();
      notifyListeners();
      return false;
    }
  }

  /// Registered with [ApiClient] as its 401-retry handler (same `core` →
  /// `services` import-cycle reasoning as [setAccessTokenProvider] in
  /// [ApiClient]). Returning `true` tells the interceptor to retry the
  /// request that got the 401 — which only makes sense once a new access
  /// token has actually been obtained and applied, which
  /// [_applyAuthenticatedSession] does before this ever returns `true`.
  ///
  /// Confirmed live: `/api/auth/refresh` rotates the refresh token on
  /// every use, so [_applyAuthenticatedSession] persisting the *new* one
  /// in place of the old is required for correctness, not optional — reusing
  /// the old refresh token after this call would fail on the next attempt.
  ///
  /// Falls back to a forced local logout — clearing tokens/[currentUser]
  /// and returning `false` — whenever there's no stored refresh token to
  /// try, or the backend call itself fails (expired/revoked refresh token,
  /// no connectivity, etc.): an unrecoverable session must never be left
  /// looking authenticated.
  Future<bool> attemptTokenRefresh() async {
    final storedRefreshToken = await _tokenStorage.readRefreshToken();
    if (storedRefreshToken != null) {
      final data = await _authRepository.refreshToken(
        refreshToken: storedRefreshToken,
      );
      if (data != null) {
        await _applyAuthenticatedSession(data);
        notifyListeners();
        return true;
      }
    }

    await _tokenStorage.clear();
    _accessToken = null;
    _accessTokenExpiresAtUtc = null;
    _currentUser = null;
    notifyListeners();
    return false;
  }

  /// Refreshes [currentUser] from `GET /api/users/me` — confirmed live to
  /// return exactly the same shape as `/api/auth/login`'s `data.user`, so
  /// this reuses [AuthUser] rather than a separate model. Requires an
  /// already-authenticated session (the Bearer interceptor handles that
  /// automatically); does not touch tokens or [isLoading]/[errorMessage] —
  /// this is a background refresh, not the primary login flow.
  Future<bool> refreshCurrentUser() async {
    try {
      _currentUser = await _authRepository.getCurrentUser();
      notifyListeners();
      return true;
    } on ApiException {
      return false;
    }
  }

  /// Logs out. Calls the backend so it can revoke the stored refresh token
  /// server-side, but the local session is cleared regardless of whether
  /// that call succeeds — a failed/unreachable backend must never leave the
  /// app stuck in a logged-in state with a token it can no longer use
  /// correctly. Does nothing to `isLoading`/`errorMessage`; this isn't a
  /// form submission with its own error UI, it always "succeeds" locally.
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _authRepository.logout(refreshToken: refreshToken);
      } on ApiException {
        // Best-effort revocation only — local logout proceeds either way.
      }
    }

    await _tokenStorage.clear();
    _accessToken = null;
    _accessTokenExpiresAtUtc = null;
    _currentUser = null;
    notifyListeners();
  }
}
