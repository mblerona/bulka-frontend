import 'package:bulka_frontend/models/user_role.dart';

/// The signed-in user, as returned in the `user` field of the login
/// response.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.roles,
    this.firstName,
    this.lastName,
    this.displayName,
    this.phone,
    this.status,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.phoneCompletionRequired = false,
    this.twoFactorEnabled = false,
    this.providerProfileStatus,
    this.providerQuestionnaireRequired = false,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      roles: [
        for (final role in json['roles'] as List<dynamic>? ?? const [])
          role as String,
      ],
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      phoneCompletionRequired:
          json['phoneCompletionRequired'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      providerProfileStatus: json['providerProfileStatus'] as String?,
      providerQuestionnaireRequired:
          json['providerQuestionnaireRequired'] as bool? ?? false,
    );
  }

  final String id;
  final String email;

  /// Backend role names, e.g. "Admin". Use [role] for the app's own
  /// Tourist/Provider split.
  final List<String> roles;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? phone;
  final String? status;
  final bool emailVerified;
  final bool phoneVerified;
  final bool phoneCompletionRequired;
  final bool twoFactorEnabled;
  final String? providerProfileStatus;
  final bool providerQuestionnaireRequired;

  /// Which side of the app this account uses, or null for accounts the
  /// mobile app doesn't support (e.g. "Admin"). Provider accounts also have
  /// the "Buyer" role (`["Buyer", "Provider"]`), so Provider is checked
  /// first.
  UserRole? get role {
    final lower = roles.map((r) => r.toLowerCase());
    if (lower.contains('provider')) return UserRole.owner;
    if (lower.contains('buyer')) return UserRole.buyer;
    return null;
  }

  String get fullName {
    final name = [
      firstName,
      lastName,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
    if (name.isNotEmpty) return name;
    return displayName ?? email;
  }
}
