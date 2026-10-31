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

  /// Which side of the app this account uses. Any role containing
  /// "provider" counts as a Property Owner; every other account (including
  /// admins) gets the Tourist side.
  UserRole get role {
    final isProvider = roles.any((r) => r.toLowerCase().contains('provider'));
    return isProvider ? UserRole.owner : UserRole.buyer;
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
