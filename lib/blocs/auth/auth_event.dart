part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;
}

final class AuthRegistrationRequested extends AuthEvent {
  const AuthRegistrationRequested({
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.businessName,
  });

  final UserRole role;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  /// Provider ([UserRole.owner]) accounts only.
  final String? businessName;
}

/// On app start: signs the user back in with the saved tokens, if any.
final class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested();
}

/// Forgot password: emails a reset code to [email].
final class AuthPasswordResetCodeRequested extends AuthEvent {
  const AuthPasswordResetCodeRequested(this.email);

  final String email;
}

/// Sets a new password using the code from the reset email.
final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;
}

/// The code from the verification email.
final class AuthEmailVerificationRequested extends AuthEvent {
  const AuthEmailVerificationRequested({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;
}

final class AuthVerificationEmailResendRequested extends AuthEvent {
  const AuthVerificationEmailResendRequested(this.email);

  final String email;
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Sent by the API client when the tokens can't be refreshed any more.
final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
