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
    this.businessName,
  });

  final String fullName;
  final String email;
  final String phone;
  final String city;
  final UserRole role;

  /// Provider ([UserRole.owner]) accounts only; null for Tourists.
  final String? businessName;

  /// The backend wants first and last name separately; the form has one
  /// field. The first word is the first name, the rest is the last name.
  String get firstName => _nameParts.first;
  String get lastName => _nameParts.skip(1).join(' ');

  List<String> get _nameParts {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? const [''] : parts;
  }

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
      businessName: businessName,
    );
  }
}
