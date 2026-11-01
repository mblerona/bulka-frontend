/// The `data` payload of a successful `POST /api/auth/resend-email-verification`
/// response, confirmed live:
/// ```json
/// { "sent": true }
/// ```
/// `backend/swagger.json` declares no response schema for this endpoint at
/// all, so this field is taken from that one real observed response, not
/// guessed.
class ResendEmailVerificationResult {
  const ResendEmailVerificationResult({required this.sent});

  factory ResendEmailVerificationResult.fromJson(Map<String, dynamic> json) {
    return ResendEmailVerificationResult(sent: json['sent'] as bool);
  }

  final bool sent;
}
