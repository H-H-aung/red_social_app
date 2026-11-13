part of '../app.dart';

const kUsdToMmkRate = 2100.0;
const kPremiumUsdToMmkRate = 2100.0;
int _usdToMmk(double value) => (value * kUsdToMmkRate).round();
String shortRelativeTime(String value) {
  final date = _parseApiDate(value);
  if (date == null) return value;
  final diff = DateTime.now().toUtc().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

/// API timestamps without a timezone are UTC (for example,
/// `2026-11-13 15:30:00`).  Dart otherwise treats those values as device
/// local time, which makes Myanmar users see times 6 hours 30 minutes wrong.
DateTime? _parseApiDate(String value) {
  final parsed = DateTime.tryParse(value.trim());
  if (parsed == null) return null;
  if (parsed.isUtc || RegExp(r'(Z|[+-]\d\d:?\d\d)$').hasMatch(value.trim())) {
    return parsed.toUtc();
  }
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  );
}
