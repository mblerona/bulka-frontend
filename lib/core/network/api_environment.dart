/// Backend base URL, overridable per build via:
///   flutter run --dart-define=API_BASE_URL=https://staging.example.com/api
class ApiEnvironment {
  ApiEnvironment._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // TODO: replace with the real local/dev backend URL once known.
    defaultValue: 'http://localhost:8080/api',
  );
}
