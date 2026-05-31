import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';

/// Format an integer with locale-aware grouping (e.g. 12,450).
String formatNumber(int n, String localeCode) {
  return NumberFormat.decimalPattern(localeCode).format(n);
}

/// Short relative time, localized: "just now", "5m ago", "2h ago", "3d ago".
String relativeTime(DateTime when, AppLocalizations l) {
  final diff = DateTime.now().difference(when);
  if (diff.inSeconds < 60) return l.justNow;
  if (diff.inMinutes < 60) return l.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l.hoursAgo(diff.inHours);
  return l.daysAgo(diff.inDays);
}

/// Short date label like "May 31".
String shortDate(DateTime d, String localeCode) {
  return DateFormat.MMMd(localeCode).format(d);
}

/// Month + year label like "May 2026".
String monthYear(DateTime d, String localeCode) {
  return DateFormat.yMMMM(localeCode).format(d);
}
