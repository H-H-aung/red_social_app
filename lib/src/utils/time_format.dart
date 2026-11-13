part of '../app.dart';

const kUsdToMmkRate = 2100.0;
const kPremiumUsdToMmkRate = 2100.0;
int _usdToMmk(double value) => (value * kUsdToMmkRate).round();
String shortRelativeTime(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
