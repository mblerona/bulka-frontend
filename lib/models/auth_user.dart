/// The `user` object inside a successful `/api/auth/login` response.
/// `backend/swagger.json` documents no response schema at all, so every
/// field/nullability here is inferred from real observed responses, not
/// from the OpenAPI contract — confirmed against an Admin account, a real
/// Buyer account, and a real Provider account (whose `roles` was
/// `["Buyer", "Provider"]` — see `mapBackendRoleToUserRole`'s doc comment).
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
    this.phone,
    this.phoneCompletionRequired = false,
    this.phoneVerified = false,
    this.twoFactorEnabled = false,
    this.providerProfileStatus,
    this.providerQuestionnaireRequired = false,
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
      phone: json['phone'] as String?,
      phoneCompletionRequired:
          json['phoneCompletionRequired'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      providerProfileStatus: json['providerProfileStatus'] as String?,
      providerQuestionnaireRequired:
          json['providerQuestionnaireRequired'] as bool? ?? false,
    );
  }

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? displayName;

  /// Raw backend role strings — e.g. `["Buyer"]` for a Buyer account, or
  /// `["Buyer", "Provider"]` for a Provider account (confirmed live; a
  /// Provider account is apparently also a Buyer). Only ever compared via
  /// `mapBackendRoleToUserRole`, never elsewhere.
  final List<String> roles;
  final String? status;
  final bool emailVerified;

  /// Confirmed live on both a Buyer (`"+38970100004"`) and a Provider
  /// (`"+38970100005"`) account.
  final String? phone;

  /// True would mean the account still needs to supply a phone number —
  /// only observed as `false` so far, on accounts that already had one on
  /// file.
  final bool phoneCompletionRequired;
  final bool phoneVerified;
  final bool twoFactorEnabled;

  /// Null on Admin/Buyer accounts; confirmed live as `"Approved"` on a
  /// real Provider account. Raw backend status string — no other value is
  /// confirmed yet, so this isn't an enum.
  final String? providerProfileStatus;

  /// Confirmed live as `false` on both a Buyer and a Provider account — no
  /// `true` case has actually been observed yet.
  final bool providerQuestionnaireRequired;
}
