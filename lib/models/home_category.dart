/// One category from `GET /api/categories`. Tourist Home's "Категории" row
/// shows the top-level ones (no [parentCategoryId]).
///
/// [name] is already translated by the backend (from the `Accept-Language`
/// header); it falls back to Macedonian where a translation is missing.
class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.code,
    required this.name,
    this.parentCategoryId,
  });

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    return HomeCategory(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      parentCategoryId: json['parentCategoryId'] as String?,
    );
  }

  final String id;

  /// Stable backend key, e.g. "rural-stay". Unlike [name], it doesn't
  /// change with the language.
  final String code;
  final String name;
  final String? parentCategoryId;

  bool get isTopLevel => parentCategoryId == null;

  String get label => name;

  /// The backend has no icons for categories, so the chip's emoji is
  /// picked by [code].
  String get emoji => _emojiByCode[code] ?? _defaultEmoji;

  static const String _defaultEmoji = '🌾';

  static const Map<String, String> _emojiByCode = {
    'rural-stay': '🏠',
    'gastronomy': '🍽️',
    'food-tasting': '🧀',
    'nature-activities': '🌿',
    // "Shop" / "Продавница".
    'svc-0050': '🧺',
  };
}
