import 'package:bulka_frontend/core/constants/app_strings.dart';

/// "пред 2 дена" / "2 days ago" / "para 2 ditësh" style relative-time
/// label. Each language has its own word order and singular/plural forms,
/// so the whole phrase comes from the translations (`agoMinutes` etc.).
/// Shared by My Tickets ("Последна промена: пред X") and Provider Offers.
String agoLabel(DateTime since) {
  final diff = DateTime.now().difference(since);
  if (diff.inMinutes < 60) return AppStrings.agoMinutes(diff.inMinutes);
  if (diff.inHours < 24) return AppStrings.agoHours(diff.inHours);
  return AppStrings.agoDays(diff.inDays);
}
