/// Backend base URL, overridable per build via:
///   flutter run --dart-define=API_BASE_URL=https://other-host.example.com
class ApiEnvironment {
  ApiEnvironment._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // The hosted AgroEco Mobile API — confirmed live at this host via its
    // Swagger UI and a real /api/auth/login round trip. Every path in the
    // OpenAPI contract already starts with "/api/...", so the API sits at
    // the domain root (no extra base path).
    defaultValue: 'https://agro.finki.net.mk',
  );
}
