import 'package:bulka_frontend/models/user_role.dart';

/// Carries the data collected at registration forward through the
/// post-registration flow (Terms & Privacy -> Email Verification -> Profile).
///
/// [city] is not collected at registration; it's filled in by the user on
/// the Profile screen itself.
class TouristProfile {
  const TouristProfile({
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

  TouristProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? city,
  }) {
    return TouristProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      role: role,
    );
  }
}
