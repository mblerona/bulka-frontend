import 'package:bulka_frontend/models/user_role.dart';

/// Carries the data collected at registration forward through the
/// post-registration flow (Terms & Privacy -> Email Verification -> the
/// role-specific Profile screen), regardless of which role was chosen.
///
/// [city] only applies to the Tourist profile; it's not collected at
/// registration and is filled in by the user on that screen itself.
class RegistrationProfile {
  const RegistrationProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    this.city = '',
    this.role = UserRole.buyer,
  });

  final String fullName;
  final String email;
  final String phone;
  final String city;
  final UserRole role;

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
    );
  }
}
