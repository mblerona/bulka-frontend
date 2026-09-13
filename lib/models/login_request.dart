/// Request body for `POST /api/auth/login`, matching `LoginRequest` in
/// `backend/swagger.json` exactly (`email`, `password`, `turnstileToken`).
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    required this.turnstileToken,
  });

  final String email;
  final String password;
  final String turnstileToken;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'turnstileToken': turnstileToken,
  };
}
