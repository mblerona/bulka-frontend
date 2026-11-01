part of 'auth_bloc.dart';

/// Which request the state's [AuthState.status] and [AuthState.error] are
/// about, so each screen only reacts to its own request.
enum AuthOperation {
  login,
  register,
  verifyEmail,
  resendVerification,
  restoreSession,
  requestPasswordReset,
  resetPassword,
  logout,
  sessionExpired,
}

enum AuthOperationStatus { inProgress, succeeded, failed }

final class AuthState {
  const AuthState({
    this.user,
    this.operation,
    this.status,
    this.error,
    this.emailVerificationRequired = true,
  });

  /// The signed-in user, or null.
  final AuthUser? user;

  /// The most recent request, or null before the first one.
  final AuthOperation? operation;
  final AuthOperationStatus? status;

  /// Set when [status] is [AuthOperationStatus.failed]. Its message is
  /// always in the app's current language.
  final ApiException? error;

  /// After a successful [AuthOperation.register]: whether the user still
  /// has to confirm their email.
  final bool emailVerificationRequired;

  bool get isLoggedIn => user != null;

  bool isInProgress(AuthOperation operation) =>
      this.operation == operation && status == AuthOperationStatus.inProgress;

  AuthState started(AuthOperation operation) => AuthState(
    user: user,
    operation: operation,
    status: AuthOperationStatus.inProgress,
  );

  /// [user] replaces the signed-in user (login); [signedOut] clears it.
  AuthState succeeded({
    AuthUser? user,
    bool signedOut = false,
    bool emailVerificationRequired = true,
  }) => AuthState(
    user: signedOut ? null : (user ?? this.user),
    operation: operation,
    status: AuthOperationStatus.succeeded,
    emailVerificationRequired: emailVerificationRequired,
  );

  AuthState failed(ApiException error) => AuthState(
    user: user,
    operation: operation,
    status: AuthOperationStatus.failed,
    error: error,
  );
}
