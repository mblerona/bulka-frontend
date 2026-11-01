/// One region from `GET /api/regions` (e.g. "Пелагониски Регион"), used by
/// the search filter's location picker.
///
/// [name] is already translated by the backend (from the `Accept-Language`
/// header).
class Region {
  const Region({required this.id, required this.name});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  final String id;
  final String name;
}
