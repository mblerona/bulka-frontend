/// Backend base URL, overridable per build via:
///   flutter run --dart-define=API_BASE_URL=https://staging.example.com
///
/// No trailing `/api` — every endpoint path already starts with `/api/...`
/// (see docs/api/openapi.json).
class ApiEnvironment {
  ApiEnvironment._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://agro.finki.net.mk',
  );
}
