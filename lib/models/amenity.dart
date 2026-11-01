/// One amenity from `GET /api/amenities` (e.g. Parking, Wi-Fi), as listed
/// in the search filters.
///
/// [name] is already translated by the backend (from the `Accept-Language`
/// header); it falls back to Macedonian where a translation is missing.
class Amenity {
  const Amenity({required this.id, required this.code, required this.name});

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  final String id;

  /// Stable backend key, e.g. "wi-fi". Unlike [name], it doesn't change
  /// with the language; filters store this.
  final String code;
  final String name;

  /// The backend only sends an icon name meant for the web app, so the
  /// emoji is picked by [code].
  String get emoji => _emojiByCode[code] ?? _defaultEmoji;

  static const String _defaultEmoji = '✨';

  static const Map<String, String> _emojiByCode = {
    'parking': '🅿️',
    'family-friendly': '👨‍👩‍👧',
    'pets-allowed': '🐾',
    'guide': '🧭',
    'meal-included': '🍽️',
    'accessible': '♿',
    'wi-fi': '📶',
    'toilet': '🚻',
  };
}
