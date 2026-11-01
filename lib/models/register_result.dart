/// The `data` payload of a successful `POST /api/auth/register/buyer`
/// response, confirmed live:
/// ```json
/// { "userId": "...", "status": "PendingVerification", "emailVerificationRequired": true }
/// ```
/// `backend/swagger.json` declares no response schema for this endpoint at
/// all, so every field here is taken from that one real observed response,
/// not guessed — treat as provisional for any status other than
/// `"PendingVerification"` until a different one is actually observed.
///
/// Not yet used for `/api/auth/register/provider` — that endpoint's response
/// hasn't been confirmed live yet, so [AuthRepository.registerProvider]
/// still returns the untyped envelope. Reuse this class for it too once that
/// response is confirmed to match this same shape; don't assume it does.
class RegisterResult {
  const RegisterResult({
    required this.userId,
    required this.status,
    required this.emailVerificationRequired,
  });

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      userId: json['userId'] as String,
      status: json['status'] as String,
      emailVerificationRequired: json['emailVerificationRequired'] as bool,
    );
  }

  final String userId;

  /// Raw backend status string — only `"PendingVerification"` has been
  /// observed. Not an enum on purpose: no other value is confirmed yet.
  final String status;
  final bool emailVerificationRequired;
}
