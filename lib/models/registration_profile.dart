import 'package:bulka_frontend/models/user_role.dart';

/// Carries the data collected at registration forward through the
/// post-registration flow (Terms & Privacy -> Email Verification -> the
/// role-specific Profile screen), regardless of which role was chosen.
///
/// [city] only applies to the Tourist profile; it's not collected at
/// registration and is filled in by the user on that screen itself.
///
/// [firstName]/[lastName]/[displayName]/[password]/[businessName] exist only
/// to carry the real `/api/auth/register/*` request fields from
/// `RegisterScreen` to `TermsPrivacyScreen` (the point where terms/privacy
/// are actually accepted, which is when the real registration call fires) —
/// nothing downstream of that call reads them. [password] is never logged
/// and is discarded once the registration screens are left.
class RegistrationProfile {
  const RegistrationProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    this.city = '',
    this.role = UserRole.buyer,
    this.firstName = '',
    this.lastName = '',
    this.displayName = '',
    this.password = '',
    this.businessName,
  });

  final String fullName;
  final String email;
  final String phone;
  final String city;
  final UserRole role;

  final String firstName;
  final String lastName;
  final String displayName;
  final String password;

  /// Provider-only; null for a Buyer registration.
  final String? businessName;

  RegistrationProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? city,
  }) {
    return RegistrationProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      role: role,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
      password: password,
      businessName: businessName,
    );
  }
}
