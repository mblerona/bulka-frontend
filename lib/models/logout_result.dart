/// The `data` payload of a successful `POST /api/auth/logout` response,
/// confirmed live:
/// ```json
/// { "loggedOut": true }
/// ```
/// `backend/swagger.json` declares no response schema for this endpoint at
/// all, so this field is taken from that one real observed response, not
/// guessed.
class LogoutResult {
  const LogoutResult({required this.loggedOut});

  factory LogoutResult.fromJson(Map<String, dynamic> json) {
    return LogoutResult(loggedOut: json['loggedOut'] as bool);
  }

  final bool loggedOut;
}
