/// Formats a price as whole-number Macedonian denar digits with a `.`
/// thousands separator (e.g. `2770.0` -> `'2.770'`) — matches the Create
/// Offer wizard's Review step formatting exactly (extracted here so
/// Tourist Home's listing cards can use the same formatting instead of a
/// second copy of this logic).
String formatMkPrice(double price) {
  final rounded = price.round();
  final digits = rounded.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
