/// Lowercase Macedonian month names, index 0 = January. Public so other
/// screens (e.g. the Provider Availability Calendar's "Август 2026" title)
/// can reuse this one list instead of keeping a second copy.
const List<String> mkMonthNames = [
  'јануари',
  'февруари',
  'март',
  'април',
  'мај',
  'јуни',
  'јули',
  'август',
  'септември',
  'октомври',
  'ноември',
  'декември',
];

/// Short Macedonian date-range label, e.g. "12–15 август" for a same-month
/// range or "28 јули – 2 август" across months. Shared by any screen that
/// needs to show a reservation/booking date range (currently the Provider
/// Dashboard; a future Calendar screen will likely need the same format).
String formatMkDateRange(DateTime start, DateTime end) {
  final startMonth = mkMonthNames[start.month - 1];
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} $startMonth';
  }
  final endMonth = mkMonthNames[end.month - 1];
  return '${start.day} $startMonth – ${end.day} $endMonth';
}
