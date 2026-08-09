import 'package:bulka_frontend/core/constants/app_strings.dart';

/// Short relative-time label ("2 мин", "1 ч", "1 ден") shared by the
/// Notifications and Chat List screens — both show a list of timestamped
/// items and use the exact same short-form convention from Figma.
String relativeTimeLabel(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return AppStrings.timeJustNow;
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} ${AppStrings.timeMinutesSuffix}';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} ${AppStrings.timeHoursSuffix}';
  }
  return '${diff.inDays} ${AppStrings.timeDaysSuffix}';
}
