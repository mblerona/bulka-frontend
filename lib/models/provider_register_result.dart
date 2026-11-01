/// The `data` payload of a successful `POST /api/auth/register/provider`
/// response, confirmed live:
/// ```json
/// {
///   "userId": "...",
///   "providerProfileId": "...",
///   "userStatus": "PendingVerification",
///   "providerProfileStatus": "Draft",
///   "emailVerificationRequired": true
/// }
/// ```
/// `backend/swagger.json` declares no response schema for this endpoint at
/// all, so every field here is taken from that one real observed response,
/// not guessed. Deliberately a separate class from [RegisterResult]
/// (`/api/auth/register/buyer`'s response) rather than a shared type — the
/// user-status field is named `userStatus` here vs. plain `status` on the
/// Buyer response, so reusing one class would either silently paper over
/// that mismatch or require guessing the two are otherwise identical.
class ProviderRegisterResult {
  const ProviderRegisterResult({
    required this.userId,
    required this.providerProfileId,
    required this.userStatus,
    required this.providerProfileStatus,
    required this.emailVerificationRequired,
  });

  factory ProviderRegisterResult.fromJson(Map<String, dynamic> json) {
    return ProviderRegisterResult(
      userId: json['userId'] as String,
      providerProfileId: json['providerProfileId'] as String,
      userStatus: json['userStatus'] as String,
      providerProfileStatus: json['providerProfileStatus'] as String,
      emailVerificationRequired: json['emailVerificationRequired'] as bool,
    );
  }

  final String userId;
  final String providerProfileId;

  /// Raw backend status string — only `"PendingVerification"` has been
  /// observed. Not an enum on purpose: no other value is confirmed yet.
  final String userStatus;

  /// Raw backend status string — only `"Draft"` has been observed. Not an
  /// enum on purpose: no other value is confirmed yet.
  final String providerProfileStatus;
  final bool emailVerificationRequired;
}
