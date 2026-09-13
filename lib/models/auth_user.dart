/// The `user` object inside a successful `/api/auth/login` response.
/// `backend/swagger.json` documents no response schema at all, so every
/// field/nullability here is inferred from one real observed response, not
/// from the OpenAPI contract — treat as provisional until more accounts
/// (a Buyer, a Provider) have actually been observed.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.roles = const [],
    this.status,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.twoFactorEnabled = false,
    this.providerProfileStatus,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      providerProfileStatus: json['providerProfileStatus'] as String?,
    );
  }

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? displayName;

  /// Raw backend role strings (e.g. `["Admin"]`) — only ever compared via
  /// `mapBackendRoleToUserRole`, never elsewhere.
  final List<String> roles;
  final String? status;
  final bool emailVerified;
  final bool phoneVerified;
  final bool twoFactorEnabled;

  /// Null for the one observed (Admin) account — presumably only set for
  /// Provider accounts, but that's inferred, not confirmed.
  final String? providerProfileStatus;
}
