import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/models/backend_role_mapper.dart';
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
  }

  static final SessionController instance = SessionController._();

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthUser? _currentUser;
  String? _accessToken;
  DateTime? _accessTokenExpiresAtUtc;
  bool _isLoading = false;
  String? _errorMessage;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _accessToken != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get accessTokenExpiresAtUtc => _accessTokenExpiresAtUtc;

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

      await _tokenStorage.saveSession(
        accessToken: data.accessToken!,
        refreshToken: data.refreshToken!,
        accessTokenExpiresAtUtc: data.accessTokenExpiresAtUtc!,
      );

      _accessToken = data.accessToken;
      _accessTokenExpiresAtUtc = data.accessTokenExpiresAtUtc;
      _currentUser = data.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
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
