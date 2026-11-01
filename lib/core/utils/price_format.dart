import 'package:intl/intl.dart';

/// A price as a whole number with the current language's thousands
/// separator, e.g. `2770.0` -> "2.770" (MK) / "2,770" (EN). The currency
/// suffix (ден. / MKD) is added by the caller from AppStrings.
String formatPrice(double price) => NumberFormat('#,##0').format(price.round());
